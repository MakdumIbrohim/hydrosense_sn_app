import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
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
      
      String expectedAbi = 'universal';
      if (Platform.isAndroid) {
        try {
          final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          if (androidInfo.supportedAbis.isNotEmpty) {
            expectedAbi = androidInfo.supportedAbis.first.toLowerCase(); 
          }
        } catch (_) {}
      }

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
        String universalUrl = '';
        
        if (data['assets'] != null && data['assets'].length > 0) {
          for (var asset in data['assets']) {
            String assetName = asset['name'].toString().toLowerCase();
            
            if (assetName.contains('universal.apk')) {
              universalUrl = asset['browser_download_url'];
            }
            
            if (assetName.contains(expectedAbi) && assetName.endsWith('.apk')) {
              apkUrl = asset['browser_download_url'];
              break; 
            }
          }
          
          if (apkUrl == updateUrl && universalUrl.isNotEmpty) {
            apkUrl = universalUrl;
          } else if (apkUrl == updateUrl) {
             for (var asset in data['assets']) {
                if (asset['name'].toString().endsWith('.apk')) {
                  apkUrl = asset['browser_download_url'];
                  break;
                }
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
  String downloadStats = "Menyiapkan...";
  String downloadSpeed = "0.0 MB/s";
  int _lastReceived = 0;
  DateTime? _lastTime;
  CancelToken? _cancelToken;

  Future<void> _startDownload() async {
    // Meminta izin storage khusus Android lama, Android baru pakai folder app khusus tidak perlu,
    // tapi open_filex butuh REQUEST_INSTALL_PACKAGES (sudah ditambah di Manifest)
    setState(() {
      isDownloading = true;
      progress = 0.0;
      progressString = "0%";
      downloadStats = "Menyiapkan...";
      downloadSpeed = "0.0 MB/s";
      _lastReceived = 0;
      _lastTime = DateTime.now();
      _cancelToken = CancelToken();
    });

    try {
      Directory? tempDir = await getExternalStorageDirectory();
      String savePath = "${tempDir!.path}/update_v${widget.version}.apk";

      Dio dio = Dio();
      await dio.download(
        widget.downloadUrl,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            DateTime now = DateTime.now();
            int timeDiff = now.difference(_lastTime!).inMilliseconds;
            
            if (timeDiff > 500) {
              int bytesDiff = received - _lastReceived;
              double speedMbps = (bytesDiff / 1024 / 1024) / (timeDiff / 1000);
              downloadSpeed = "${speedMbps.toStringAsFixed(1)} MB/s";
              _lastTime = now;
              _lastReceived = received;
            }

            setState(() {
              progress = received / total;
              progressString = "${(progress * 100).toStringAsFixed(0)}%";
              downloadStats = "${(received / 1024 / 1024).toStringAsFixed(2)} MB / ${(total / 1024 / 1024).toStringAsFixed(2)} MB";
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
      if (e is DioException && e.type == DioExceptionType.cancel) {
        debugPrint("Download dibatalkan oleh pengguna");
        return;
      }
      
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendownload: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Dialog.fullscreen(
      backgroundColor: bgColor,
      child: Stack(
        children: [
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Temukan versi baru\n${widget.version}',
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

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: MarkdownBody(
                      data: widget.notes,
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: isDownloading ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Mengunduh Pembaruan...', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(downloadStats, style: TextStyle(color: subTextColor, fontSize: 13)),
                          Text(progressString, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(downloadSpeed, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF34D399), fontSize: 13)),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            _cancelToken?.cancel("Dibatalkan pengguna");
                            setState(() { isDownloading = false; });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Batal Mengunduh', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ) : Column(
                    children: [
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

                      InkWell(
                        onTap: _startDownload,
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

                      TextButton(
                        onPressed: () => Navigator.pop(context),
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
