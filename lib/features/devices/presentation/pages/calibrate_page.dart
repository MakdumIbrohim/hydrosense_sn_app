import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CalibratePage extends StatefulWidget {
  final String id;
  const CalibratePage({super.key, required this.id});

  @override
  State<CalibratePage> createState() => _CalibratePageState();
}

class _CalibratePageState extends State<CalibratePage> {
  final TextEditingController _tdsKController = TextEditingController(text: "1.30");
  bool _isLoading = false;

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

  Future<void> _fetchCurrentKValue() async {
    setState(() => _isLoading = true);
    _updateStatus("Mengambil data K-Value dari Firebase...");
    try {
      final url = Uri.parse("https://hydrosensesn-default-rtdb.asia-southeast1.firebasedatabase.app/devices/ESP32_01/settings.json");
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(url);
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        if (responseBody != "null") {
          final data = jsonDecode(responseBody);
          if (data['tds_k_value'] != null) {
            _tdsKController.text = data['tds_k_value'].toString();
            _updateStatus("SUKSES: K-Value saat ini adalah ${_tdsKController.text}");
          } else {
            _updateStatus("INFO: K-Value belum diset sebelumnya.");
          }
        }
      } else {
        _updateStatus("GAGAL: Respons server salah (Code: ${response.statusCode})");
      }
    } catch (e) {
      _updateStatus("GAGAL narik setting kalibrasi: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCalibration() async {
    final double? newValue = double.tryParse(_tdsKController.text.replaceAll(',', '.'));
    if (newValue == null || newValue <= 0) {
      _updateStatus("ERROR: Angka K-Value tidak valid!");
      return;
    }

    setState(() => _isLoading = true);
    _updateStatus("=============================");
    _updateStatus("Menyiapkan pembaruan kalibrasi TDS...");
    
    try {
      final url = Uri.parse("https://hydrosensesn-default-rtdb.asia-southeast1.firebasedatabase.app/devices/ESP32_01/settings.json");
      final httpClient = HttpClient();
      
      _updateStatus("Menulis data (tds_k_value: $newValue) ke Firebase...");
      final request = await httpClient.patchUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.add(utf8.encode(jsonEncode({'tds_k_value': newValue})));
      
      final response = await request.close();
      if (response.statusCode == 200) {
        _updateStatus("SUKSES: Kalibrasi berhasil disimpan di server!");
        _updateStatus("INFO: ESP32 akan menarik nilai ini pada sinkronisasi berikutnya.");
        _updateStatus("Silakan tunggu beberapa detik hingga grafik TDS berubah.");
      } else {
        _updateStatus("GAGAL: Respons server salah (Code: ${response.statusCode})");
      }
    } catch (e) {
      _updateStatus("GAGAL menyimpan kalibrasi: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentKValue();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Kalibrasi Alat', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.tune_rounded, color: AppColors.primary, size: 48),
                    SizedBox(height: 16),
                    Text('Faktor Kalibrasi TDS (K-Value)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Sesuaikan nilai pengali jika hasil pembacaan sensor TDS tidak sesuai dengan TDS meter pabrikan.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('K-Value Saat Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade500)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tdsKController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.calculate_rounded, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFB923C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFB923C), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tips: Jika TDS di aplikasi terbaca 500 tapi TDS Meter asli 600, maka naikkan K-Value. (Standar pabrik biasanya 1.0 - 1.5).',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.orange.shade200 : Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCalibration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, 
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SIMPAN KALIBRASI', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              
              // STATUS BOX
              if (_statusMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 24.0, bottom: 24.0),
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
                      if (!_isError && !_isSuccess && _isLoading)
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
            ],
          ),
        ),
      ),
    );
  }
}