import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
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
        return _DownloadDialogWidget(
          version: version,
          notes: notes,
          downloadUrl: downloadUrl,
        );
      }
    );
  }
}

class _DownloadDialogWidget extends StatefulWidget {
  final String version;
  final String notes;
  final String downloadUrl;

  const _DownloadDialogWidget({
    required this.version,
    required this.notes,
    required this.downloadUrl,
  });

  @override
  State<_DownloadDialogWidget> createState() => _DownloadDialogWidgetState();
}

class _DownloadDialogWidgetState extends State<_DownloadDialogWidget> {
  bool isDownloading = false;
  double progress = 0.0;
  String progressString = "0%";

  Future<void> _startDownload() async {
    // Meminta izin storage khusus Android lama, Android baru pakai folder app khusus tidak perlu,
    // tapi open_filex butuh REQUEST_INSTALL_PACKAGES (sudah ditambah di Manifest)
    setState(() {
      isDownloading = true;
      progress = 0.0;
      progressString = "0%";
    });

    try {
      Directory? tempDir = await getExternalStorageDirectory();
      String savePath = "${tempDir!.path}/update_v${widget.version}.apk";

      Dio dio = Dio();
      await dio.download(
        widget.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress = received / total;
              progressString = "${(progress * 100).toStringAsFixed(0)}%";
            });
          }
        },
      );

      setState(() {
        isDownloading = false;
      });

      // Buka dan install APK
      OpenFilex.open(savePath);
      
      if (mounted) {
        Navigator.pop(context); // Tutup dialog setelah berhasil
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendownload: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isDownloading ? Icons.cloud_download_rounded : Icons.system_update_rounded, size: 48, color: const Color(0xFF38BDF8)),
            const SizedBox(height: 16),
            Text(
              'Versi ${widget.version} Tersedia!',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B)
              ),
            ),
            const SizedBox(height: 16),
            
            if (!isDownloading) ...[
              Container(
                height: 120,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: MarkdownBody(
                    data: widget.notes,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                      listBullet: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                    ),
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
                        onTap: _startDownload,
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
            ] else ...[
              const SizedBox(height: 8),
              Text('Mengunduh Pembaruan...', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: isDark ? Colors.black26 : Colors.black12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                ),
              ),
              const SizedBox(height: 8),
              Text(progressString, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
            ]
          ],
        ),
      ),
    );
  }
}
