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

  List<String> _logs = [];
  final ScrollController _logScrollController = ScrollController();

  void _addLog(String msg) {
    if (mounted) {
      setState(() {
        final time = "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}";
        _logs.add("[$time] $msg");
      });
      // Auto-scroll ke bawah
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_logScrollController.hasClients) {
          _logScrollController.animateTo(
            _logScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _addLog("Sistem siap. Silakan isi SSID dan Sandi lalu klik Cari.");
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
      _addLog("Memeriksa izin Bluetooth & Lokasi...");
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      if (statuses[Permission.bluetoothScan] == PermissionStatus.denied) {
        _addLog("ERROR: Izin Bluetooth ditolak!");
        return;
      }

      final state = await FlutterBluePlus.adapterState.first.timeout(const Duration(seconds: 2), onTimeout: () => BluetoothAdapterState.unknown);
      if (state != BluetoothAdapterState.on && state != BluetoothAdapterState.unknown) {
        _addLog("ERROR: Tolong NYALAKAN BLUETOOTH di HP Anda!");
        return;
      }

      setState(() {
        _isScanning = true;
        _scanResults = [];
      });
      _addLog("Memulai pencarian perangkat ESP32...");
      
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      
      FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            _scanResults = results.where((r) => r.advertisementData.advName.isNotEmpty || r.device.platformName.isNotEmpty).toList();
          });
        }
      });

      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _isScanning = false;
            if (_scanResults.isEmpty) {
              _addLog("Scan selesai: Tidak ada perangkat ditemukan.");
            } else {
              _addLog("Scan selesai: Ditemukan ${_scanResults.length} perangkat. Pilih perangkat di daftar.");
            }
          });
        }
      });
    } catch (e) {
      _addLog("ERROR Scan: $e");
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _sendData(BluetoothDevice device) async {
    if (_ssidController.text.isEmpty || _passController.text.isEmpty) {
      _addLog("GAGAL: Harap isi SSID dan Password WiFi dulu!");
      return;
    }

    setState(() => _isConnecting = true);
    _addLog("Menyiapkan koneksi ke ${device.platformName}...");

    try {
      try { await device.disconnect(); } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 1000));
      
      _addLog("Mencoba menghubungkan (timeout 15 detik)...");
      await device.connect(autoConnect: false, license: License.nonprofit, timeout: const Duration(seconds: 15));
      _addLog("Sukses terhubung ke ESP32 secara fisik.");
      
      if (Platform.isAndroid) {
        _addLog("Membersihkan cache GATT...");
        try { await device.clearGattCache(); } catch (_) {}
      }
      
      await Future.delayed(const Duration(milliseconds: 1500));
      
      _addLog("Mencari layanan komunikasi data (Services)...");
      List<BluetoothService> services = await device.discoverServices();
      bool found = false;

      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase().contains("5fafc201")) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase().contains("ceb5483e")) {
              found = true;
              _addLog("Jalur komunikasi terbuka. Mulai mengirim data...");
              
              String data = "${_ssidController.text};${_passController.text}#"; 
              
              for (int i = 0; i < data.length; i += 15) {
                int end = (i + 15 < data.length) ? i + 15 : data.length;
                String chunk = data.substring(i, end);
                
                await characteristic.write(utf8.encode(chunk), withoutResponse: false);
                _addLog(">> Mengirim byte: $chunk");
                await Future.delayed(const Duration(milliseconds: 300));
              }
              
              _addLog("SUKSES: Kredensial WiFi berhasil dikirim!");
              _addLog("INFO: ESP32 sedang melakukan RESTART...");
              
              await Future.delayed(const Duration(seconds: 2));
              try { await device.disconnect(); } catch (_) {}
              
              _addLog("ESP32 memulai ulang. Menghubungkan WiFi...");
              for (int j = 1; j <= 10; j++) {
                await Future.delayed(const Duration(seconds: 1));
                _addLog("Menunggu IP Address (Detik $j/10) " + ("." * (j % 4)));
              }
              
              _addLog("SUKSES: Selesai! ESP32 seharusnya sudah mendapat IP.");
              _addLog("Silakan kembali ke halaman Dashboard untuk melihat status Online.");
              
              if (mounted) setState(() => _isConnecting = false);
              return;
            }
          }
        }
      }
      
      if (!found) {
        _addLog("GAGAL: Karakteristik BLE tidak cocok dengan alat.");
        await device.disconnect();
      }
    } catch (e) {
      _addLog("GAGAL/TERPUTUS: $e");
      try { await device.disconnect(); } catch (_) {}
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  void _confirmResetWiFi(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset WiFi?'),
        content: const Text('Tindakan ini akan menghapus koneksi WiFi pada ESP32. Alat akan mati lalu menyala dalam Mode Setup Bluetooth.\n\nLanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF43F5E), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              _addLog("=============================");
              _addLog("Menyiapkan perintah RESET WiFi jarak jauh...");
              
              try {
                final url = Uri.parse("https://hydrosensesn-default-rtdb.asia-southeast1.firebasedatabase.app/devices/ESP32_01/commands.json");
                final httpClient = HttpClient();
                
                _addLog("Mengirim sinyal (reset_wifi: true) ke Firebase...");
                final request = await httpClient.putUrl(url);
                request.headers.set('Content-Type', 'application/json');
                request.add(utf8.encode('{"reset_wifi": true}'));
                
                final response = await request.close();
                if (response.statusCode == 200) {
                  _addLog("SUKSES: Sinyal reset diterima server!");
                  _addLog("INFO: Menunggu alat merespons perintah...");
                  _addLog("INFO: ESP32 menghapus memori WiFi dan RESTART.");
                  _addLog("Silakan tunggu lampu indikator biru berkedip di alat.");
                } else {
                  _addLog("GAGAL: Respons server salah (Code: ${response.statusCode})");
                }
              } catch (e) {
                _addLog("GAGAL mengirim perintah: $e");
              }
            },
            child: const Text('RESET ALAT'),
          ),
        ],
      ),
    );
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
              const SizedBox(height: 16),
              // Peringatan Wajib Reset
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFF43F5E)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PENTING: Jika ingin mengganti WiFi dari alat yang sudah terhubung, Anda WAJIB mereset alat terlebih dahulu melalui tombol di bawah ini.',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.red.shade200 : Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _confirmResetWiFi(context),
                icon: const Icon(Icons.wifi_off_rounded),
                label: const Text('RESET WIFI', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43F5E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              
              // TERMINAL LOGS
              Container(
                height: 180,
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                ),
                child: ListView.builder(
                  controller: _logScrollController,
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    Color textColor = Colors.greenAccent;
                    if (log.contains("ERROR") || log.contains("GAGAL")) textColor = Colors.redAccent;
                    else if (log.contains("SUKSES")) textColor = Colors.cyanAccent;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "> $log",
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: textColor,
                        ),
                      ),
                    );
                  },
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