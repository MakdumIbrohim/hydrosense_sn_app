import 'package:flutter/material.dart';

class PanduanPenggunaanPage extends StatelessWidget {
  const PanduanPenggunaanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panduan Penggunaan')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildGuideCard(
            context,
            icon: Icons.wifi,
            title: '1. Menyambungkan Alat ke Internet (WiFi)',
            content: 'Agar alat ESP32 bisa mengirim data, Anda harus menghubungkannya ke WiFi rumah/Greenhouse.\n\n'
                'Langkah-langkah:\n'
                '• Buka menu "Tambah Perangkat" di aplikasi.\n'
                '• Masukkan nama WiFi (SSID) dan Password WiFi rumah Anda.\n'
                '• Pastikan Bluetooth dan GPS/Lokasi HP Anda menyala.\n'
                '• Tekan "Cari Perangkat Bluetooth".\n'
                '• Pilih alat yang bernama "HydroSense_Setup" lalu klik "Kirim".\n'
                '• Alat akan otomatis tersambung dan mulai mengirim data sensor.',
          ),
          const SizedBox(height: 12),
          _buildGuideCard(
            context,
            icon: Icons.dashboard,
            title: '2. Membaca Data Sensor (Dashboard)',
            content: 'Di layar utama (Dashboard), Anda dapat melihat kondisi air tandon secara Real-time:\n\n'
                '• pH Air: Idealnya antara 5.5 - 6.5 untuk tanaman hidroponik.\n'
                '• EC Pupuk: Kepekatan nutrisi. Pastikan sesuai dengan umur tanaman.\n'
                '• TDS: Estimasi berat pupuk yang larut (ppm).\n'
                '• Suhu Air: Idealnya tidak melebihi 28°C agar akar tidak busuk.',
          ),
          const SizedBox(height: 12),
          _buildGuideCard(
            context,
            icon: Icons.settings_input_component,
            title: '3. Mengkalibrasi Sensor',
            content: 'Seiring berjalannya waktu, sensor pH atau TDS mungkin akan kurang akurat.\n\n'
                'Langkah-langkah:\n'
                '• Masuk ke menu "Perangkat Saya" (ikon tangki di bawah).\n'
                '• Klik ikon "Pengaturan/Kalibrasi" di sebelah nama ESP32.\n'
                '• Ikuti instruksi pencelupan sensor ke air kalibrasi baku (misal pH 4.0 atau 6.86).\n'
                '• Simpan nilai kalibrasi yang baru.',
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, {required IconData icon, required String title, required String content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF0D6E6E), size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                content,
                style: const TextStyle(height: 1.5, fontSize: 14),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
