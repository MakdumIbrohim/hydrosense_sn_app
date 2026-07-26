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
    
    // Matikan loading jika alat tidak ketemu setelah 10 detik
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
      appBar: AppBar(title: const Text('Tambah Perangkat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.bluetooth_searching, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Hubungkan ke ESP32',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _status == "Siap scan" 
                ? 'Pastikan Bluetooth aktif dan perangkat dalam mode pairing.'
                : _status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _status.contains('Gagal') ? Colors.red : 
                       _status.contains('Berhasil') ? Colors.green : Colors.blue,
                fontWeight: _status == "Siap scan" ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'WiFi SSID (Greenhouse)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'WiFi Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isConnecting ? null : _startScanAndConnect,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _isConnecting ? 'Memproses...' : 'Mulai Pairing & Kirim WiFi', 
                  style: const TextStyle(fontSize: 16)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}