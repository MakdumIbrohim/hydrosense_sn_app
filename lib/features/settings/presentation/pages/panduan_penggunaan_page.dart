import 'package:flutter/material.dart';
import '../../../../core/widgets/neumorphic_container.dart';

class PanduanPenggunaanPage extends StatelessWidget {
  const PanduanPenggunaanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                children: [
                  NeumorphicContainer(
                    borderRadius: 12,
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
                    iconColor: const Color(0xFFF43F5E),
                    icon: Icons.wifi_off_rounded,
                    title: '2. Mereset WiFi Mikro Kontroler (Penting)',
                    content: 'Jika Anda ingin mengganti WiFi rumah/hotspot atau memindahkan alat, Anda WAJIB menghapus memori WiFi lama pada mikro kontroler.\n\n'
                        'Ada 2 cara melakukan Reset:\n'
                        '• Cara Jarak Jauh: Masuk ke tab "Menu" (Ikon 4 Kotak) -> Pilih "Konfigurasi WiFi" -> Gulir ke paling bawah di bagian "Pengaturan Lanjutan" -> Klik "Reset WiFi Mikro Kontroler".\n'
                        '• Cara Fisik: Tekan dan tahan tombol "BOOT" pada mesin mikro kontroler selama 3 detik.\n\n'
                        'Setelah direset, mikro kontroler akan merestart dan bersiap mencari jaringan baru.',
                  ),
                  const SizedBox(height: 16),
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    iconColor: const Color(0xFF38BDF8),
                    icon: Icons.grid_view_rounded,
                    title: '3. Menyambungkan ke Jaringan Baru',
                    content: 'Setelah mikro kontroler berhasil direset (langkah 2), ikuti langkah ini:\n\n'
                        '• Masuk ke tab "Menu" (Ikon 4 Kotak) -> "Konfigurasi WiFi".\n'
                        '• Masukkan PIN Admin (Bawaan: 123456).\n'
                        '• Masukkan nama WiFi atau Hotspot dari HP (Paket Internet) beserta sandinya. Pastikan sinyal Anda 2.4GHz!\n'
                        '• Pastikan GPS/Lokasi HP menyala, lalu klik "Cari Perangkat Bluetooth".\n'
                        '• Mikro kontroler akan terdeteksi (Warna Biru), lalu klik "Kirim".\n'
                        '• Sistem akan otomatis mengecek 15 detik apakah koneksi berhasil.',
                  ),
                  const SizedBox(height: 16),
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    iconColor: const Color(0xFF8B5CF6),
                    icon: Icons.memory_rounded,
                    title: '4. Memantau Status Perangkat',
                    content: 'Untuk melihat mikro kontroler apa saja yang terdaftar di sistem, masuk ke tab "Daftar Perangkat" (Ikon Chip/Memori di bawah).\n\n'
                        'Di sini Anda bisa memantau apakah mikro kontroler (contoh: HydroSense Node 1) sedang aktif mengirim data (Online/Hijau) atau mati (Offline/Abu-abu).',
                  ),
                  const SizedBox(height: 16),
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    iconColor: const Color(0xFFFB923C),
                    icon: Icons.settings_input_component_rounded,
                    title: '5. Mengkalibrasi Sensor',
                    content: 'Seiring berjalannya waktu, sensor pH atau TDS mungkin akan kurang akurat.\n\n'
                        'Langkah-langkah:\n'
                        '• Masuk ke tab "Menu" (Ikon 4 Kotak).\n'
                        '• Klik tombol "Kalibrasi TDS" atau "Kalibrasi pH".\n'
                        '• Masukkan nilai koreksi (K-Value) yang tepat sesuai kondisi kepekatan air.\n'
                        '• Simpan nilai kalibrasi yang baru ke server.',
                  ),
                  const SizedBox(height: 16),
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    iconColor: const Color(0xFFF59E0B),
                    icon: Icons.swipe_rounded,
                    title: '6. Mengatur Posisi Panel Navigasi',
                    content: 'Kini panel menu navigasi di bagian bawah aplikasi dapat Anda pindahkan sesuai kenyamanan jari.\n\n'
                        'Caranya:\n'
                        'Sentuh pada bagian panel navigasi, lalu ayunkan/lempar (swipe) ke arah kiri, kanan, atau atas layar. Panel akan otomatis menempel di sisi layar tersebut.',
                  ),
                  const SizedBox(height: 16),
                  _buildGuideCard(
                    context: context,
                    isDark: isDark,
                    iconColor: const Color(0xFF10B981),
                    icon: Icons.system_update_rounded,
                    title: '7. Memperbarui Aplikasi (Update)',
                    content: 'Anda tidak perlu repot mencari file aplikasi versi terbaru jika ada perbaikan fitur.\n\n'
                        'Langkah-langkah:\n'
                        '• Masuk ke tab "Pengaturan" (Ikon Roda Gigi dipaling kanan panel navigasi).\n'
                        '• Pilih menu "Pembaruan Aplikasi".\n'
                        '• Sistem akan otomatis mengecek rilis terbaru. Jika ada pembaruan, klik tombol unduh yang tersedia.',
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
    required Color iconColor,
    required IconData icon, 
    required String title, 
    required String content
  }) {
    return NeumorphicContainer(
      borderRadius: 20,
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
