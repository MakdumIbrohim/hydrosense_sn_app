import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class WifiSetupScreen extends StatefulWidget {
  const WifiSetupScreen({super.key});

  @override
  State<WifiSetupScreen> createState() => _WifiSetupScreenState();
}

class _WifiSetupScreenState extends State<WifiSetupScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  BluetoothDevice? _targetDevice;
  bool _isConnecting = false;
  String _status = "Siap scan...";

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
    setState(() => _status = "Mencari HydroSense_Setup...");
    
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.platformName == "HydroSense_Setup") {
          FlutterBluePlus.stopScan();
          setState(() {
            _targetDevice = r.device;
            _status = "Alat ditemukan! Isi password & kirim.";
          });
          break;
        }
      }
    });
  }

  Future<void> _sendData() async {
    if (_targetDevice == null) return;
    setState(() {
      _isConnecting = true;
      _status = "Menghubungkan & Mengirim...";
    });

    try {
      await _targetDevice!.connect(license: License.nonprofit);
      
      List<BluetoothService> services = await _targetDevice!.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == "4fafc201-1fb5-459e-8fcc-c5c9c331914b") {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
              
              String data = "${_ssidController.text};${_passController.text}";
              await characteristic.write(utf8.encode(data));
              
              setState(() => _status = "Berhasil! ESP32 sedang restart.");
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
      setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup WiFi Alat")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Status: $_status", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startScan,
              child: const Text("1. Cari Alat (Scan)"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(labelText: "Nama WiFi Rumah (SSID)"),
            ),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: "Password WiFi"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (_targetDevice != null && !_isConnecting) ? _sendData : null,
              child: const Text("2. Kirim & Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}