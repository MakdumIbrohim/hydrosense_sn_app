import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../monitoring/presentation/providers/sensor_provider.dart';
import '../../../monitoring/presentation/widgets/sensor_card_widget.dart';

class CalibratePhPage extends StatefulWidget {
  final String id;
  const CalibratePhPage({super.key, required this.id});

  @override
  State<CalibratePhPage> createState() => _CalibratePhPageState();
}

class _CalibratePhPageState extends State<CalibratePhPage> {
  final TextEditingController _phOffsetController = TextEditingController(text: "21.34");
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

  Future<void> _fetchCurrentOffset() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse("https://hydrosensesn-default-rtdb.asia-southeast1.firebasedatabase.app/devices/ESP32_01/settings.json");
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(url);
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        if (responseBody != "null") {
          final data = jsonDecode(responseBody);
          if (data['ph_calibration'] != null) {
            _phOffsetController.text = data['ph_calibration'].toString();
          }
          if (mounted) setState(() { _statusMessage = ""; _isSuccess = false; _isError = false; });
        }
      } else {
        _updateStatus("GAGAL: Gagal memuat data (Code: ${response.statusCode})");
      }
    } catch (e) {
      _updateStatus("GAGAL narik setting kalibrasi: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCalibration() async {
    final double? newPh = double.tryParse(_phOffsetController.text.replaceAll(',', '.'));
    
    if (newPh == null) {
      _updateStatus("ERROR: Angka pH tidak valid!");
      return;
    }

    setState(() => _isLoading = true);
    _updateStatus("=============================");
    _updateStatus("Menyiapkan pembaruan kalibrasi pH...");
    
    try {
      final url = Uri.parse("https://hydrosensesn-default-rtdb.asia-southeast1.firebasedatabase.app/devices/ESP32_01/settings.json");
      final httpClient = HttpClient();
      
      _updateStatus("Menulis data kalibrasi pH ke Firebase...");
      final request = await httpClient.patchUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.add(utf8.encode(jsonEncode({
        'ph_calibration': newPh,
      })));
      
      final response = await request.close();
      if (response.statusCode == 200) {
        _updateStatus("SUKSES: Kalibrasi disimpan! Angka pH akan berubah dalam beberapa detik.");
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
    _fetchCurrentOffset();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kalibrasi pH', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
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
              // REAL-TIME MONITORING CARD
              Consumer<SensorProvider>(
                builder: (context, provider, child) {
                  final phValue = provider.currentData?.ph ?? 0.0;
                  return SizedBox(
                    height: 220,
                    child: SensorCardWidget(
                      title: 'pH (Real-Time)',
                      value: phValue.toStringAsFixed(2),
                      unit: '',
                      color: const Color(0xFFA78BFA),
                      max: 14,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFA78BFA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA78BFA).withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.science_rounded, color: Color(0xFFA78BFA), size: 48),
                    SizedBox(height: 16),
                    Text('Offset Kalibrasi pH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Sesuaikan nilai offset penambah/pengurang agar hasil pembacaan akurat sesuai cairan pH buffer.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // --- FORM PH ---
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
                    Text('Offset pH Saat Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade500)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phOffsetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.water_drop_rounded, color: Colors.grey),
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
                        'Tips: Jika aplikasi menampilkan pH 6.0 tapi cairan asli adalah pH 7.0, tambahkan 1.0 ke angka di atas.',
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
                    backgroundColor: const Color(0xFFA78BFA), 
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