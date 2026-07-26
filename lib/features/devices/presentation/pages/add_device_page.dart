import 'dart:convert';
import 'dart:io';
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
    try {
      // 1. Cek izin dan perangkat keras
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      // Di Android 12+, lokasi kadang tidak wajib, tapi kita cek saja tanpa memblokir secara absolut
      if (statuses[Permission.bluetoothScan] == PermissionStatus.denied) {
        setState(() => _status = "Gagal: Izin Bluetooth ditolak!");
        return;
      }

      // Cek state dengan delay pendek agar tidak stuck
      final state = await FlutterBluePlus.adapterState.first.timeout(const Duration(seconds: 2), onTimeout: () => BluetoothAdapterState.unknown);
      if (state != BluetoothAdapterState.on && state != BluetoothAdapterState.unknown) {
        setState(() => _status = "Gagal: Tolong NYALAKAN BLUETOOTH di HP Anda!");
        return;
      }

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
            _scanResults = results.where((r) => r.advertisementData.advName.isNotEmpty || r.device.platformName.isNotEmpty).toList();
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _status = "Error: $e";
        });
      }
    }
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
      // Putuskan koneksi lama (jika ada yang nyangkut) agar bersih
      try { await device.disconnect(); } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Langsung coba koneksi dengan batas waktu (timeout) 10 detik agar tidak nyangkut
      await device.connect(autoConnect: false, license: License.nonprofit, timeout: const Duration(seconds: 15));
      
      if (Platform.isAndroid) {
        // JURUS PAMUNGKAS ANDROID: Hapus cache GATT agar HP tidak pakai memori lama
        try { await device.clearGattCache(); } catch (_) {}
      }
      
      await Future.delayed(const Duration(milliseconds: 1500)); // Beri waktu stabil yang agak lama
      
      List<BluetoothService> services = await device.discoverServices();
      bool found = false;

      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase().contains("5fafc201")) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase().contains("ceb5483e")) {
              found = true;
              setState(() => _status = "Menulis data ke ESP32...");
              
              String data = "${_ssidController.text};${_passController.text}#"; 
              
              // Potong-potong data menjadi maksimal 15 karakter per kiriman
              for (int i = 0; i < data.length; i += 15) {
                int end = (i + 15 < data.length) ? i + 15 : data.length;
                String chunk = data.substring(i, end);
                
                // Pakai withoutResponse false agar lebih aman secara default di Android
                await characteristic.write(utf8.encode(chunk), withoutResponse: false);
                await Future.delayed(const Duration(milliseconds: 300)); // Jeda lebih lama
              }
              
              setState(() => _status = "Terkirim! Alat sedang Restart.\nCek Dashboard dalam 15 detik.");
              await Future.delayed(const Duration(seconds: 2));
              await device.disconnect();
              return;
            }
          }
        }
      }
      
      if (!found) {
        setState(() => _status = "Gagal: Layanan alat ini tidak cocok.");
        await device.disconnect();
      }
    } catch (e) {
      setState(() => _status = "Gagal: $e");
      try { await device.disconnect(); } catch (_) {}
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Tambah Perangkat',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B), letterSpacing: -0.5),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Masukkan WiFi rumah, lakukan Scan, lalu tekan "Kirim" pada alat bernama HydroSense_V2.',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.blue.shade100 : Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Inputs
              Text('KONEKSI ALAT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade500)),
              const SizedBox(height: 12),
              TextField(
                controller: _ssidController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Nama WiFi SSID',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.wifi_rounded, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passController,
                obscureText: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Password WiFi',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.lock_rounded, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              
              // Tombol Scan
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    if (!_isScanning && !_isConnecting)
                      BoxShadow(color: const Color(0xFF34D399).withValues(alpha: 0.3), blurRadius: 16, spreadRadius: 2, offset: const Offset(0, 4)),
                  ],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton.icon(
                  onPressed: _isScanning || _isConnecting ? null : _startScan,
                  icon: _isScanning 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.bluetooth_searching_rounded),
                  label: Text(_isScanning ? 'MENCARI...' : 'CARI PERANGKAT BLUETOOTH', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34D399),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _status.contains('Gagal') ? const Color(0xFFF43F5E) : 
                           _status.contains('Terkirim') ? const Color(0xFF34D399) : 
                           (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              
              if (_scanResults.isNotEmpty) ...[
                Text('HASIL SCAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade500)),
                const SizedBox(height: 12),
              ],
              
              // Daftar Perangkat
              _scanResults.isEmpty 
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text("Belum ada perangkat ditemukan.", style: TextStyle(color: Colors.grey))),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final r = _scanResults[index];
                      final deviceName = r.advertisementData.advName.isNotEmpty ? r.advertisementData.advName : r.device.platformName;
                      final isTarget = deviceName == "HydroSense_V2";
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isTarget 
                              ? (isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.1) : const Color(0xFF38BDF8).withValues(alpha: 0.05)) 
                              : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isTarget ? const Color(0xFF38BDF8) : Colors.transparent,
                            width: 1.5
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isTarget ? const Color(0xFF38BDF8).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.bluetooth_rounded, color: isTarget ? const Color(0xFF38BDF8) : Colors.grey),
                            ),
                            title: Text(
                              deviceName, 
                              style: TextStyle(fontWeight: FontWeight.bold, color: isTarget ? const Color(0xFF38BDF8) : (isDark ? Colors.white : const Color(0xFF1E293B)), fontSize: 16)
                            ),
                            subtitle: Text(r.device.remoteId.toString(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            trailing: ElevatedButton(
                              onPressed: _isConnecting ? null : () => _sendData(r.device),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isTarget ? const Color(0xFF38BDF8) : (isDark ? const Color(0xFF334155) : Colors.blue.shade100), 
                                foregroundColor: isTarget ? Colors.white : (isDark ? Colors.white : Colors.blue.shade700),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(isTarget ? 'KIRIM' : 'PILIH', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}