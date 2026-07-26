import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String _status = "Isi data WiFi di atas, lalu tekan tombol Cari.";

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _scanResults = [];
      _status = "Mencari alat ESP32 terdekat...";
    });
    
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          // Hanya tampilkan alat yang ada namanya
          _scanResults = results.where((r) => r.device.platformName.isNotEmpty).toList();
        });
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          if (_scanResults.isEmpty) {
            _status = "Gagal: Tidak ada alat ditemukan.";
          } else {
            _status = "Scan selesai. Silakan pilih alat di daftar bawah.";
          }
        });
      }
    });
  }

  Future<void> _sendData(BluetoothDevice device) async {
    if (_ssidController.text.isEmpty || _passController.text.isEmpty) {
      setState(() => _status = "Gagal: Harap isi SSID dan Password WiFi dulu!");
      return;
    }

    setState(() {
      _isConnecting = true;
      _status = "Menghubungkan ke ${device.platformName}...";
    });

    try {
      await device.connect(license: License.nonprofit);
      
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == "4fafc201-1fb5-459e-8fcc-c5c9c331914b") {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
              
              String data = "${_ssidController.text};${_passController.text}";
              await characteristic.write(utf8.encode(data));
              
              setState(() => _status = "Berhasil! ESP32 tersambung & restart.");
              await device.disconnect();
              return;
            }
          }
        }
      }
      setState(() => _status = "Gagal: Layanan alat ini tidak cocok.");
      await device.disconnect();
    } catch (e) {
      setState(() => _status = "Gagal: $e");
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Perangkat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Text(
                'Info: Masukkan WiFi rumah, lakukan Scan, lalu tekan tombol "Kirim" pada alat yang bernama HydroSense_Setup di daftar.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            
            // Inputs
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'Nama WiFi SSID (Rumah/Greenhouse)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password WiFi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tombol Scan & Status
            ElevatedButton.icon(
              onPressed: _isScanning || _isConnecting ? null : _startScan,
              icon: _isScanning 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.bluetooth_searching),
              label: Text(_isScanning ? 'Mencari...' : 'Cari Perangkat Bluetooth'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6E6E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _status.contains('Gagal') ? Colors.red : 
                         _status.contains('Berhasil') ? Colors.green : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const Divider(),
            
            // Daftar Perangkat
            Expanded(
              child: _scanResults.isEmpty 
                ? const Center(child: Text("Belum ada perangkat ditemukan.", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final r = _scanResults[index];
                      final isTarget = r.device.platformName == "HydroSense_Setup";
                      
                      return Card(
                        elevation: isTarget ? 6 : 2,
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isTarget 
                              ? const BorderSide(color: Color(0xFF0D6E6E), width: 2) 
                              : BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        color: isTarget ? const Color(0xFFE0F2F1) : Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: isTarget ? const Color(0xFF0D6E6E).withOpacity(0.2) : Colors.grey.shade100,
                            child: Icon(Icons.bluetooth, color: isTarget ? const Color(0xFF0D6E6E) : Colors.grey.shade600),
                          ),
                          title: Text(
                            r.device.platformName, 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: isTarget ? const Color(0xFF0D6E6E) : Colors.black87,
                              fontSize: 16,
                            )
                          ),
                          subtitle: Text(
                            r.device.remoteId.toString(), 
                            style: const TextStyle(fontSize: 11, color: Colors.grey)
                          ),
                          trailing: ElevatedButton(
                            onPressed: _isConnecting ? null : () => _sendData(r.device),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isTarget ? const Color(0xFF0D6E6E) : Colors.blue.shade600, 
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: isTarget ? 4 : 0,
                            ),
                            child: Text(isTarget ? 'Pilih & Kirim' : 'Kirim'),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}