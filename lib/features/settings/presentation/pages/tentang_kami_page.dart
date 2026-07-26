import 'package:flutter/material.dart';

class TentangKamiPage extends StatelessWidget {
  const TentangKamiPage({super.key});

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
                    'Tentang Kami',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B), letterSpacing: -0.5),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // Logo Placeholder
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFF38BDF8).withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.water_drop_rounded, size: 50, color: Color(0xFF38BDF8)),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFF34D399).withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.eco_rounded, size: 50, color: Color(0xFF34D399)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'HydroSense SN',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFA78BFA).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Versi 1.0.0', style: TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(height: 40),
                    
                    // Section 1: Deskripsi
                    _buildSectionTitle('TENTANG APLIKASI', isDark),
                    _buildBodyText(
                      'HydroSense adalah sistem pemantauan IoT pintar yang terintegrasi untuk mengukur pH, EC/TDS (Kepekatan Pupuk), dan Suhu Air secara nirkabel. Aplikasi ini diciptakan khusus untuk membantu warga dan petani hidroponik dalam memantau kualitas air tandon secara real-time dari mana saja.',
                      isDark,
                    ),
                    const SizedBox(height: 32),

                    // Section 2: Tujuan
                    _buildSectionTitle('TUJUAN PENGABDIAN', isDark),
                    _buildBodyText(
                      'Meningkatkan kualitas panen dan ketahanan pangan Desa Sumber Nangka melalui penerapan dan modernisasi teknologi pertanian berbasis Internet of Things (IoT).',
                      isDark,
                    ),
                    const SizedBox(height: 32),

                    // Section 3: Tim KKN
                    _buildSectionTitle('TIM PENGEMBANG (KKN)', isDark),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTeamRow('Universitas', '[Nama Kampus Anda]', isDark),
                            _buildTeamRow('Kelompok', 'KKN Tematik Kelompok [00]', isDark),
                            _buildTeamRow('DPL', '[Nama Dosen Pembimbing]', isDark),
                            Divider(height: 32, color: isDark ? Colors.grey.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2)),
                            Text('Anggota Tim:', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                            const SizedBox(height: 12),
                            Text('1. Makdum Ibrohim (Ketua/Dev)\n2. [Nama Anggota 2]\n3. [Nama Anggota 3]\n4. [Nama Anggota 4]', 
                              style: TextStyle(height: 1.8, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Section 4: Kontak
                    _buildSectionTitle('HUBUNGI KAMI', isDark),
                    _buildBodyText('Email: kkn.sumbernangka@kampus.ac.id\nWebsite: www.kampus.ac.id', isDark),
                    const SizedBox(height: 48),
                    
                    Text(
                      '© 2026 Tim KKN Desa Sumber Nangka\nDibuat dengan ❤️ untuk Masyarakat',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, height: 1.5, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget _buildBodyText(String text, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
      ),
    );
  }

  Widget _buildTeamRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600))),
          Expanded(child: Text(value, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)))),
        ],
      ),
    );
  }
}
