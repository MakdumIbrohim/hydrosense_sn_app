import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/neumorphic_container.dart';

class UpdateService {
  static const String _githubRepo = 'MakdumIbrohim/hydrosense_sn_app';

  static Future<void> checkForUpdates(BuildContext context, {bool manualCheck = false}) async {
    if (manualCheck) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memeriksa pembaruan...')),
      );
    }

    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      final String currentVersion = info.version; 

      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$_githubRepo/releases/latest'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String latestVersion = data['tag_name'] ?? '';
        latestVersion = latestVersion.replaceAll(RegExp(r'[^0-9.]'), '');
        
        final String releaseNotes = data['body'] ?? 'Pembaruan bug dan performa.';
        final String updateUrl = data['html_url'];
        
        String apkUrl = updateUrl;
        if (data['assets'] != null && data['assets'].length > 0) {
          for (var asset in data['assets']) {
            if (asset['name'].toString().endsWith('.apk')) {
              apkUrl = asset['browser_download_url'];
              break;
            }
          }
        }

        if (context.mounted) {
          if (_isNewerVersion(currentVersion, latestVersion)) {
            _showUpdateDialog(context, latestVersion, releaseNotes, apkUrl);
          } else if (manualCheck) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Aplikasi Anda sudah di versi terbaru!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else if (manualCheck && context.mounted) {
         ScaffoldMessenger.of(context).hideCurrentSnackBar();
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Gagal mengecek pembaruan dari server.'), backgroundColor: Colors.red),
         );
      }
    } catch (e) {
      debugPrint("Gagal cek update: $e");
      if (manualCheck && context.mounted) {
         ScaffoldMessenger.of(context).hideCurrentSnackBar();
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Koneksi error saat mengecek pembaruan.'), backgroundColor: Colors.red),
         );
      }
    }
  }

  static bool _isNewerVersion(String current, String latest) {
    try {
      List<int> c = current.split('.').map(int.parse).toList();
      List<int> l = latest.split('.').map(int.parse).toList();
      
      for (int i = 0; i < 3; i++) {
        int cVal = i < c.length ? c[i] : 0;
        int lVal = i < l.length ? l[i] : 0;
        if (lVal > cVal) return true;
        if (lVal < cVal) return false;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  static void _showUpdateDialog(BuildContext context, String version, String notes, String downloadUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: NeumorphicContainer(
            borderRadius: 24,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.system_update_rounded, size: 48, color: Color(0xFF38BDF8)),
                const SizedBox(height: 16),
                Text(
                  'Versi $version Tersedia!',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B)
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      notes,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Nanti', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeumorphicContainer(
                        borderRadius: 12,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final uri = Uri.parse(downloadUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'Download',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF34D399),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
