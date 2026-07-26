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
  
  BluetoothDevice? _targetDevice;
  bool _isConnecting = false;
  String _status = "Siap scan";

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

  void _startScanAndConnect() async {
    if (_ssidController.text.isEmpty || _passController.text.isEmpty) {
      setState(() => _status = "Gagal: Harap isi SSID dan Password dulu!");
      return;
    }

    setState(() {
      _isConnecting = true;
      _status = "Mencari alat ESP32...";
    });
    
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.platformName == "HydroSense_Setup") {
          FlutterBluePlus.stopScan();
          _targetDevice = r.device;
          setState(() => _status = "Alat ditemukan! Menghubungkan...");
          await _sendData();
          break;
        }
      }
    });
    
    Future.delayed(const Duration(seconds: 10), () {
      if (_targetDevice == null && mounted) {
        setState(() {
          _isConnecting = false;
          _status = "Gagal: Alat ESP32 tidak ditemukan.";
        });
      }
    });
  }

  Future<void> _sendData() async {
    if (_targetDevice == null) return;

    try {
      await _targetDevice!.connect(license: License.nonprofit);
      
      List<BluetoothService> services = await _targetDevice!.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == "4fafc201-1fb5-459e-8fcc-c5c9c331914b") {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
              
              String data = "${_ssidController.text};${_passController.text}";
              await characteristic.write(utf8.encode(data));
              
              setState(() => _status = "Berhasil! ESP32 tersambung & restart.");
              await _targetDevice!.disconnect();
              return;
            }
          }
        }
      }
      setState(() => _status = "Gagal: Layanan Bluetooth tidak cocok.");
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
      appBar: AppBar(title: const Text('Pengaturan WiFi Perangkat')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.bluetooth_connected, size: 70, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Hubungkan ESP32 ke Internet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Kotak Penjelasan Fitur
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Tentang Fitur Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fitur ini akan mengirim nama jaringan WiFi dan password dari HP ke alat ESP32 Anda melalui Bluetooth.\n\n'
                      'Setelah berhasil dikirim, alat ESP32 akan menyimpannya secara permanen dan otomatis melakukan restart untuk menyambung ke internet.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              Text(
                _status == "Siap scan" 
                  ? 'Isi formulir di bawah, pastikan Bluetooth aktif.'
                  : _status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _status.contains('Gagal') ? Colors.red : 
                         _status.contains('Berhasil') ? Colors.green : Colors.blue,
                  fontWeight: _status == "Siap scan" ? FontWeight.normal : FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              
              TextField(
                controller: _ssidController,
                decoration: const InputDecoration(
                  labelText: 'Nama WiFi SSID (Misal: Greenhouse)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wifi),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password WiFi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isConnecting ? null : _startScanAndConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6E6E), // Menyesuaikan tema hijau gelap
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  _isConnecting ? 'Memproses Koneksi...' : 'Kirim WiFi & Password ke Alat', 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}