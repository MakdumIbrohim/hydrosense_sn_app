import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/update_service.dart';
import '../../../../core/widgets/neumorphic_container.dart';

import '../widgets/update_layout_widget.dart';

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
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      body: UpdateLayoutWidget(
        version: _latestVersion,
        notes: _releaseNotes,
        isLoadingNotes: _isLoadingNotes,
        bottomActionWidget: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security_rounded, color: Color(0xFF34D399), size: 16),
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
