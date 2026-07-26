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
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 120.0),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    cardColor: cardColor,
                    iconColor: const Color(0xFF34D399),
                    icon: Icons.speed_rounded,
                    title: '1. Membaca Data (Dashboard)',
                    content: 'Di tab "Dashboard", Anda dapat melihat kondisi air tandon secara Real-time:\n\n'
                        '• Di paling atas, terdapat status Online/Offline beserta nama WiFi yang sedang digunakan.\n'
                        '• pH Air: Idealnya antara 5.5 - 6.5 untuk tanaman hidroponik.\n'
                        '• EC & TDS: Kepekatan nutrisi. Pastikan sesuai dengan umur tanaman.\n'
                        '• Suhu Air: Idealnya tidak melebihi 28°C agar akar tidak busuk.\n'
                        '• Grafik Tren: Menampilkan riwayat perubahan nutrisi dari waktu ke waktu.',
                  ),
                  const SizedBox(height: 16),
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    cardColor: cardColor,
                    iconColor: const Color(0xFFF43F5E),
                    icon: Icons.wifi_off_rounded,
                    title: '2. Mereset WiFi ESP32 (Penting)',
                    content: 'Jika Anda ingin mengganti WiFi rumah atau memindahkan alat, Anda WAJIB menghapus memori WiFi lama pada ESP32 terlebih dahulu.\n\n'
                        'Ada 2 cara melakukan Reset:\n'
                        '• Cara Jarak Jauh: Masuk ke tab "Pengaturan" -> Klik "Reset WiFi Alat (ESP32)".\n'
                        '• Cara Fisik: Tekan dan tahan tombol "BOOT" pada mesin ESP32 selama 3 detik.\n\n'
                        'Setelah direset, alat akan mati sebentar lalu menyala dalam Mode Bluetooth (memancarkan sinyal Bluetooth).',
                  ),
                  const SizedBox(height: 16),
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    cardColor: cardColor,
                    iconColor: const Color(0xFF38BDF8),
                    icon: Icons.grid_view_rounded,
                    title: '3. Menyambungkan ke WiFi Baru',
                    content: 'Setelah alat berhasil direset (langkah 2), ikuti langkah ini:\n\n'
                        '• Masuk ke tab "Menu" (Ikon 4 Kotak) di pojok kiri bawah.\n'
                        '• Klik "Konfigurasi WiFi" lalu masukkan PIN Admin (Default: 123456).\n'
                        '• Masukkan nama WiFi (SSID) dan Sandi yang baru.\n'
                        '• Klik "Cari Perangkat Bluetooth" (Pastikan GPS/Lokasi HP menyala).\n'
                        '• Pilih alat "HydroSense_V2" lalu klik "Kirim".\n'
                        '• Alat akan otomatis tersambung ke WiFi baru.',
                  ),
                  const SizedBox(height: 16),
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    cardColor: cardColor,
                    iconColor: const Color(0xFF8B5CF6),
                    icon: Icons.memory_rounded,
                    title: '4. Memantau Status Perangkat',
                    content: 'Untuk melihat alat apa saja yang terdaftar di sistem, masuk ke tab "Perangkat" (Ikon Chip/Memori).\n\n'
                        'Di sini Anda bisa memantau apakah alat (contoh: HydroSense Node 1) sedang aktif mengirim data (Online) atau mati (Offline).',
                  ),
                  const SizedBox(height: 16),
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    cardColor: cardColor,
                    iconColor: const Color(0xFFFB923C),
                    icon: Icons.settings_input_component_rounded,
                    title: '5. Mengkalibrasi Sensor',
                    content: 'Seiring berjalannya waktu, sensor pH atau TDS mungkin akan kurang akurat.\n\n'
                        'Langkah-langkah:\n'
                        '• Masuk ke tab "Perangkat".\n'
                        '• Klik ikon "Pengaturan/Kalibrasi" di sebelah nama alat.\n'
                        '• Ikuti instruksi pencelupan sensor ke air kalibrasi baku.\n'
                        '• Simpan nilai kalibrasi yang baru (Fitur dalam pengembangan).',
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
