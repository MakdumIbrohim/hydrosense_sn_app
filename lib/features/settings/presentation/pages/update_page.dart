import 'dart:convert';
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.neumoBgDark : AppColors.neumoBg,
      appBar: AppBar(
        title: Text('Pembaruan Aplikasi', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
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
              // Logo / Icon Section
              Center(
                child: NeumorphicContainer(
                  borderRadius: 100,
                  padding: const EdgeInsets.all(24),
                  child: const Icon(Icons.system_update_rounded, size: 64, color: Color(0xFFA78BFA)),
                ),
              ),
              const SizedBox(height: 24),
              
              // Version Info
              Text(
                'HydroSense SN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Versi Anda: $_version\nVersi Terbaru: $_latestVersion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                  height: 1.5,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 32),

              // Release Notes Box
              NeumorphicContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.new_releases_rounded, color: Color(0xFF38BDF8), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Catatan Rilis (GitHub)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _isLoadingNotes 
                      ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                      : MarkdownBody(
                          data: _releaseNotes,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, height: 1.5),
                            listBullet: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                            h1: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                            h2: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                            h3: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Check Update Button
              NeumorphicContainer(
                borderRadius: 16,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    UpdateService.checkForUpdates(context, manualCheck: true);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, color: Color(0xFFA78BFA)),
                        SizedBox(width: 8),
                        Text(
                          'PERIKSA PEMBARUAN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Color(0xFFA78BFA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
