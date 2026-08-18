import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/services/update_service.dart';
import '../widgets/update_layout_widget.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String _currentVersion = 'Loading...';
  String _latestVersion = 'Loading...';
  String _releaseNotes = 'Sedang mengambil catatan rilis...';
  bool _isLoadingNotes = true;

  @override
  void initState() {
    super.initState();
    _fetchVersions();
  }

  Future<void> _fetchVersions() async {
    // 1. Dapatkan versi saat ini
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      _currentVersion = info.version;
    } catch (e) {
      _currentVersion = '1.0.0'; // Fallback
    }

    // 2. Dapatkan versi terbaru dari GitHub
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/MakdumIbrohim/hydrosense_sn_app/releases/latest'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String tag = data['tag_name'] ?? 'Unknown';
        tag = tag.replaceAll(RegExp(r'[^0-9.]'), '');
        
        if (mounted) {
          setState(() {
            _latestVersion = tag;
            _releaseNotes = data['body'] ?? 'Tidak ada catatan rilis.';
            _isLoadingNotes = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _releaseNotes = 'Gagal mengambil catatan rilis (Code: ${response.statusCode})';
            _isLoadingNotes = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _releaseNotes = 'Terjadi kesalahan jaringan saat mengambil catatan rilis.';
          _isLoadingNotes = false;
        });
      }
    }
    
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    // Cek apakah ada update (menggunakan fungsi public dari UpdateService)
    bool hasUpdate = false;
    if (_currentVersion != 'Loading...' && _latestVersion != 'Loading...' && _latestVersion != 'Unknown') {
      hasUpdate = UpdateService.isNewerVersion(_currentVersion, _latestVersion);
    }

    // TAMPILAN 1: SUDAH VERSI TERBARU (Tidak ada update)
    if (!hasUpdate && !_isLoadingNotes) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pembaruan Aplikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 80),
              ),
              const SizedBox(height: 24),
              Text(
                'Aplikasi Sudah Versi Terbaru',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Versi Saat Ini: $_currentVersion\nVersi Terbaru: $_latestVersion',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: subTextColor, height: 1.5),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _fetchVersions,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Periksa Ulang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  foregroundColor: textColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // TAMPILAN 2: ADA UPDATE (Atau sedang loading pertama kali)
    return Scaffold(
      body: UpdateLayoutWidget(
        version: 'v$_latestVersion',
        notes: _releaseNotes,
        isLoadingNotes: _isLoadingNotes,
        bottomActionWidget: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.security_rounded,
                  color: Color(0xFF34D399),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Keamanan terverifikasi untuk update di SN Hydro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: () {
                UpdateService.checkForUpdates(context, manualCheck: true);
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF34D399).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Update sekarang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nanti saja',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: subTextColor,
                    decoration: TextDecoration.underline,
                    decorationColor: subTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
