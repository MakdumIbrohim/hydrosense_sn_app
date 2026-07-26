import 'package:flutter/material.dart';

class TentangKamiPage extends StatelessWidget {
  const TentangKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Kami')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Logo Placeholder
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.water_drop, size: 60, color: Colors.blue.shade700),
                const SizedBox(width: 24),
                const Icon(Icons.school, size: 60, color: Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'HydroSense SN',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Versi 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Section 1: Deskripsi
            _buildSectionTitle('Tentang Aplikasi'),
            _buildBodyText(
              'HydroSense adalah sistem pemantauan IoT pintar yang terintegrasi untuk mengukur pH, EC/TDS (Kepekatan Pupuk), dan Suhu Air secara nirkabel. Aplikasi ini diciptakan khusus untuk membantu warga dan petani hidroponik dalam memantau kualitas air tandon secara real-time dari mana saja.'
            ),
            const SizedBox(height: 24),

            // Section 2: Tujuan
            _buildSectionTitle('Tujuan Pengabdian'),
            _buildBodyText(
              'Meningkatkan kualitas panen dan ketahanan pangan Desa Sumber Nangka melalui penerapan dan modernisasi teknologi pertanian berbasis Internet of Things (IoT).'
            ),
            const SizedBox(height: 24),

            // Section 3: Tim KKN
            _buildSectionTitle('Tim Pengembang (KKN)'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTeamRow('Universitas:', '[Nama Kampus Anda]'),
                    _buildTeamRow('Kelompok:', 'KKN Tematik Kelompok [00]'),
                    _buildTeamRow('DPL:', '[Nama Dosen Pembimbing]'),
                    const Divider(height: 24),
                    const Text('Anggota Tim:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('1. Makdum Ibrohim (Ketua/Developer)\n2. [Nama Anggota 2]\n3. [Nama Anggota 3]\n4. [Nama Anggota 4]', style: TextStyle(height: 1.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 4: Kontak
            _buildSectionTitle('Hubungi Kami'),
            _buildBodyText('Email: kkn.sumbernangka@kampus.ac.id\nWebsite: www.kampus.ac.id'),
            const SizedBox(height: 40),
            
            const Text(
              '© 2026 Tim KKN Desa Sumber Nangka\nDibuat dengan ❤️ untuk Masyarakat',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D6E6E)),
        ),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildTeamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
