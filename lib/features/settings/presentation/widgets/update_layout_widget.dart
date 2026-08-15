import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class UpdateLayoutWidget extends StatelessWidget {
  final String version;
  final String notes;
  final bool isLoadingNotes;
  final Widget bottomActionWidget;

  const UpdateLayoutWidget({
    super.key,
    required this.version,
    required this.notes,
    this.isLoadingNotes = false,
    required this.bottomActionWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Warna background disesuaikan (Lebih gelap / tegas)
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      color: bgColor,
      child: Stack(
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
                    'Temukan versi baru\n$version',
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
                  child: isLoadingNotes 
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: MarkdownBody(
                          data: notes,
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

                // Bottom Section (Dinamis untuk masing-masing halaman)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: bottomActionWidget,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
