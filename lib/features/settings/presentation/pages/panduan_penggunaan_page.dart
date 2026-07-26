import 'package:flutter/material.dart';

class PanduanPenggunaanPage extends StatelessWidget {
  const PanduanPenggunaanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Panduan Penggunaan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B), letterSpacing: -0.5),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    cardColor: cardColor,
                    iconColor: const Color(0xFF38BDF8),
                    icon: Icons.wifi_rounded,
                    title: '1. Menyambungkan Alat (WiFi)',
                    content: 'Agar alat ESP32 bisa mengirim data, Anda harus menghubungkannya ke WiFi rumah/Greenhouse.\n\n'
                        'Langkah-langkah:\n'
                        '• Buka menu "Tambah Perangkat" di aplikasi.\n'
                        '• Masukkan nama WiFi (SSID) dan Password WiFi rumah Anda.\n'
                        '• Pastikan Bluetooth dan GPS/Lokasi HP Anda menyala.\n'
                        '• Tekan "Cari Perangkat Bluetooth".\n'
                        '• Pilih alat yang bernama "HydroSense_V2" lalu klik "Kirim".\n'
                        '• Alat akan otomatis tersambung dan mulai mengirim data sensor.',
                  ),
                  const SizedBox(height: 16),
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    cardColor: cardColor,
                    iconColor: const Color(0xFF34D399),
                    icon: Icons.dashboard_rounded,
                    title: '2. Membaca Data (Dashboard)',
                    content: 'Di layar utama (Dashboard), Anda dapat melihat kondisi air tandon secara Real-time:\n\n'
                        '• pH Air: Idealnya antara 5.5 - 6.5 untuk tanaman hidroponik.\n'
                        '• EC Pupuk: Kepekatan nutrisi. Pastikan sesuai dengan umur tanaman.\n'
                        '• TDS: Estimasi berat pupuk yang larut (ppm).\n'
                        '• Suhu Air: Idealnya tidak melebihi 28°C agar akar tidak busuk.',
                  ),
                  const SizedBox(height: 16),
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    cardColor: cardColor,
                    iconColor: const Color(0xFFFB923C),
                    icon: Icons.settings_input_component_rounded,
                    title: '3. Mengkalibrasi Sensor',
                    content: 'Seiring berjalannya waktu, sensor pH atau TDS mungkin akan kurang akurat.\n\n'
                        'Langkah-langkah:\n'
                        '• Masuk ke menu "Perangkat Saya" (ikon tangki di bawah).\n'
                        '• Klik ikon "Pengaturan/Kalibrasi" di sebelah nama ESP32.\n'
                        '• Ikuti instruksi pencelupan sensor ke air kalibrasi baku (misal pH 4.0 atau 6.86).\n'
                        '• Simpan nilai kalibrasi yang baru.',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required BuildContext context, 
    required bool isDark, 
    required Color cardColor,
    required Color iconColor,
    required IconData icon, 
    required String title, 
    required String content
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: iconColor,
          collapsedIconColor: Colors.grey,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1E293B))),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content,
                  style: TextStyle(height: 1.6, fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
