import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/update_service.dart';
import '../../../../core/widgets/neumorphic_container.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String _version = 'Loading...';
  String _latestVersion = 'Loading...';
  String _releaseNotes = 'Sedang mengambil catatan rilis...';
  bool _isLoadingNotes = true;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _fetchReleaseNotes();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = 'v${packageInfo.version}';
      });
    }
  }

  Future<void> _fetchReleaseNotes() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/MakdumIbrohim/hydrosense_sn_app/releases/latest'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _latestVersion = data['tag_name'] ?? 'Unknown';
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Warna background disesuaikan (Lebih gelap / tegas)
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Efek Latar Belakang (Blur khas SN Hydro)
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF34D399).withValues(alpha: 0.15),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header (Logo & App Name)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset('assets/icons/png/icon_iot_hydrosense2.png', width: 24, height: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'SN Hydro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // Main Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Temukan versi baru\n$_latestVersion',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -1,
                      color: textColor,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Release Notes (Markdown)
                Expanded(
                  child: _isLoadingNotes 
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: MarkdownBody(
                          data: _releaseNotes,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(fontSize: 15, color: textColor, height: 1.6, fontWeight: FontWeight.w500),
                            listBullet: TextStyle(color: textColor, fontSize: 16),
                            h1: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                            h2: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                            h3: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ),
                      ),
                ),

                // Bottom Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    children: [
                      // Security Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.security_rounded, color: Color(0xFF34D399), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Keamanan terverifikasi untuk update di SN Hydro',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Primary Update Button
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

                      // Secondary "Not Now" Button
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: subTextColor,
                        ),
                        child: Text(
                          'Nanti saja',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: subTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
