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
  bool _isObscure = true;

  String _statusMessage = "";
  bool _isSuccess = false;
  bool _isError = false;

  void _updateStatus(String msg) {
    if (mounted) {
      setState(() {
        _statusMessage = msg;
        if (msg.contains("ERROR") || msg.contains("GAGAL")) {
          _isError = true;
          _isSuccess = false;
        } else if (msg.contains("SUKSES")) {
          _isSuccess = true;
          _isError = false;
        } else {
          _isError = false;
          _isSuccess = false;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _updateStatus("Sistem siap. Silakan isi SSID dan Sandi lalu klik Cari.");
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
      _updateStatus("Memeriksa izin Bluetooth & Lokasi...");
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      if (statuses[Permission.bluetoothScan] == PermissionStatus.denied) {
        _updateStatus("ERROR: Izin Bluetooth ditolak!");
        return;
      }

      bool isLocationOn = await Permission.location.serviceStatus.isEnabled;
      if (!isLocationOn) {
        _updateStatus("ERROR: Tolong NYALAKAN LOKASI (GPS) di HP Anda untuk melakukan Scan Bluetooth!");
        return;
      }

      final state = await FlutterBluePlus.adapterState.first.timeout(const Duration(seconds: 2), onTimeout: () => BluetoothAdapterState.unknown);
      if (state != BluetoothAdapterState.on && state != BluetoothAdapterState.unknown) {
        _updateStatus("ERROR: Tolong NYALAKAN BLUETOOTH di HP Anda!");
        return;
      }

      setState(() {
        _isScanning = true;
        _scanResults = [];
      });
      _updateStatus("Memulai pencarian perangkat ESP32...");
      
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      
      FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            _scanResults = results.where((r) => r.advertisementData.advName.isNotEmpty || r.device.platformName.isNotEmpty).toList();
            
            // Menggunakan identifikasi dinamis UUID ESP32
            bool isFound = _scanResults.any((r) {
              return r.advertisementData.serviceUuids.any(
                (uuid) => uuid.toString().toLowerCase().contains("5fafc201")
              );
            });

            if (isFound && _isScanning) {
              FlutterBluePlus.stopScan();
              _isScanning = false;
              _updateStatus("Mikro Kontroler ditemukan! Silakan tekan tombol KIRIM.");
            }
          });
        }
      });

      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isScanning) {
          setState(() {
            _isScanning = false;
            if (_scanResults.isEmpty) {
              _updateStatus("Scan selesai: Tidak ada perangkat ditemukan.");
            } else {
              _updateStatus("Scan selesai: Ditemukan ${_scanResults.length} perangkat. Pilih perangkat di daftar.");
            }
          });
        }
      });
    } catch (e) {
      _updateStatus("ERROR Scan: $e");
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _sendData(BluetoothDevice device) async {
    if (_ssidController.text.isEmpty || _passController.text.isEmpty) {
      _updateStatus("GAGAL: Harap isi SSID dan Password WiFi dulu!");
      return;
    }

    setState(() => _isConnecting = true);
    _updateStatus("Menyiapkan koneksi ke ${device.platformName}...");

    try {
      try { await device.disconnect(); } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 1000));
      
      _updateStatus("Mencoba menghubungkan (timeout 15 detik)...");
      await device.connect(autoConnect: false, license: License.nonprofit, timeout: const Duration(seconds: 15));
      _updateStatus("Sukses terhubung ke ESP32 secara fisik.");
      
      if (Platform.isAndroid) {
        _updateStatus("Membersihkan cache GATT...");
        try { await device.clearGattCache(); } catch (_) {}
      }
      
      await Future.delayed(const Duration(milliseconds: 1500));
      
      _updateStatus("Mencari layanan komunikasi data (Services)...");
      List<BluetoothService> services = await device.discoverServices();
      bool found = false;

      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase().contains("5fafc201")) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase().contains("ceb5483e")) {
              found = true;
              _updateStatus("Jalur komunikasi terbuka. Mulai mengirim data...");
              
              String data = "${_ssidController.text};${_passController.text}#"; 
              
              for (int i = 0; i < data.length; i += 15) {
                int end = (i + 15 < data.length) ? i + 15 : data.length;
                String chunk = data.substring(i, end);
                
                await characteristic.write(utf8.encode(chunk), withoutResponse: false);
                _updateStatus(">> Mengirim byte: $chunk");
                await Future.delayed(const Duration(milliseconds: 300));
              }
              
              _updateStatus("SUKSES: Kredensial WiFi berhasil dikirim!");
              _updateStatus("INFO: ESP32 sedang melakukan RESTART...");
              
              await Future.delayed(const Duration(seconds: 2));
              try { await device.disconnect(); } catch (_) {}
              
              _updateStatus("Mikro kontroler memulai ulang. Menghubungkan WiFi...");
              bool isOnline = false;
              String targetSsid = _ssidController.text;
              
              for (int j = 1; j <= 15; j++) {
                await Future.delayed(const Duration(seconds: 1));
                _updateStatus("Mengecek status jaringan (Detik $j/15) " + ("." * (j % 4)));
                
                // Mulai mengecek Firebase setelah detik ke-5
                if (j >= 5) {
                   try {
                     final url = Uri.parse("https://hydrosensesn-default-rtdb.asia-southeast1.firebasedatabase.app/devices/ESP32_01/current.json?_=${DateTime.now().millisecondsSinceEpoch}");
                     final request = await HttpClient().getUrl(url);
                     final response = await request.close();
                     if (response.statusCode == 200) {
                        final body = await response.transform(utf8.decoder).join();
                        if (body != "null" && body.isNotEmpty) {
                          final data = jsonDecode(body);
                          // Jika status wifi sudah sama dengan yang diinput
                          if (data['wifi_ssid'] == targetSsid) {
                             isOnline = true;
                             break;
                          }
                        }
                     }
                   } catch (_) {} // abaikan error fetch
                }
              }
              
              if (isOnline) {
                _updateStatus("SUKSES: Mikro kontroler berhasil terhubung ke jaringan '$targetSsid'!");
              } else {
                _updateStatus("GAGAL: Mikro kontroler tidak merespons di jaringan '$targetSsid'. Pastikan Sandi/SSID benar atau alat menyala.");
              }
              
              if (mounted) setState(() => _isConnecting = false);
              return;
            }
          }
        }
      }
      
      if (!found) {
        _updateStatus("GAGAL: Karakteristik BLE tidak cocok dengan mikro kontroler.");
        await device.disconnect();
      }
    } catch (e) {
      _updateStatus("GAGAL/TERPUTUS: $e");
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
        content: const Text('Tindakan ini akan menghapus koneksi WiFi pada ESP32. Mikro Kontroler akan mati lalu menyala dalam Mode Setup Bluetooth.\n\nLanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF43F5E), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              _updateStatus("=============================");
              _updateStatus("Menyiapkan perintah RESET WiFi jarak jauh...");
              
              try {
                final url = Uri.parse("https://hydrosensesn-default-rtdb.asia-southeast1.firebasedatabase.app/devices/ESP32_01/commands.json");
                final httpClient = HttpClient();
                
                _updateStatus("Mengirim perintah RESET ke server...");
                final request = await httpClient.putUrl(url);
                request.headers.set('Content-Type', 'application/json');
                request.add(utf8.encode('{"reset_wifi": true}'));
                
                final response = await request.close();
                if (response.statusCode == 200) {
                  _updateStatus("Menunggu respons dari mikro kontroler...");
                  
                  bool espResponded = false;
                  for (int j = 1; j <= 15; j++) {
                     await Future.delayed(const Duration(seconds: 1));
                     _updateStatus("Menunggu respons mikro kontroler (Detik $j/15) " + ("." * (j % 4)));
                     
                     try {
                       final checkUrl = Uri.parse("https://hydrosensesn-default-rtdb.asia-southeast1.firebasedatabase.app/devices/ESP32_01/commands/reset_wifi.json?_=${DateTime.now().millisecondsSinceEpoch}");
                       final checkReq = await HttpClient().getUrl(checkUrl);
                       final checkRes = await checkReq.close();
                       if (checkRes.statusCode == 200) {
                          final body = await checkRes.transform(utf8.decoder).join();
                          // Arduino akan mengubahnya jadi false saat selesai mereset
                          if (body == "false" || body == "null") {
                             espResponded = true;
                             break;
                          }
                       }
                     } catch (_) {}
                  }
                  
                  if (espResponded) {
                     _updateStatus("SUKSES: Mikro kontroler berhasil direset!");
                  } else {
                     _updateStatus("GAGAL: Mikro kontroler tidak merespons perintah. Pastikan alat sedang menyala dan terhubung jaringan.");
                  }
                } else {
                  _updateStatus("GAGAL: Respons server salah (Code: ${response.statusCode})");
                }
              } catch (e) {
                _updateStatus("GAGAL mengirim perintah: $e");
              }
            },
            child: const Text('RESET MIKRO KONTROLER'),
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
                        'Masukkan nama jaringan (WiFi Rumah atau Hotspot HP), lakukan Scan, lalu tekan "Kirim" pada mikro kontroler.',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.blue.shade100 : Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Inputs WiFi
              Text('KONEKSI MIKRO KONTROLER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade500)),
              const SizedBox(height: 12),
              TextField(
                controller: _ssidController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Nama WiFi / Hotspot (SSID)',
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
                obscureText: _isObscure,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Password WiFi / Hotspot',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.lock_rounded, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
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
              
              if (_statusMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isError 
                        ? const Color(0xFFF43F5E).withValues(alpha: 0.1) 
                        : _isSuccess 
                            ? const Color(0xFF34D399).withValues(alpha: 0.1)
                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isError 
                          ? const Color(0xFFF43F5E).withValues(alpha: 0.3)
                          : _isSuccess
                              ? const Color(0xFF34D399).withValues(alpha: 0.3)
                              : Colors.transparent,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      if (!_isError && !_isSuccess && (_isScanning || _isConnecting || _statusMessage.contains("Menunggu") || _statusMessage.contains("menghubungkan")))
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2)
                          ),
                        )
                      else if (_isError)
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.error_outline_rounded, color: Color(0xFFF43F5E)),
                        )
                      else if (_isSuccess)
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.check_circle_outline_rounded, color: Color(0xFF34D399)),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.info_outline_rounded, color: Colors.blue),
                        ),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isError ? const Color(0xFFF43F5E) : _isSuccess ? const Color(0xFF34D399) : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ],
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
                      
                      // Cek secara dinamis berdasarkan UUID uniknya
                      final isTarget = r.advertisementData.serviceUuids.any((uuid) => uuid.toString().toLowerCase().contains("5fafc201"));
                      
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
                  
              const SizedBox(height: 48),
              Text('PENGATURAN LANJUTAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade500)),
              const SizedBox(height: 12),
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
                        'PENTING: Jika ingin memindahkan mikro kontroler ke WiFi lain, Anda WAJIB mereset mikro kontroler terlebih dahulu melalui tombol di bawah ini.',
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
                label: const Text('RESET WIFI MIKRO KONTROLER', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43F5E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}