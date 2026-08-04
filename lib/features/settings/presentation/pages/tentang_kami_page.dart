import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/constants/team_data.dart';
import '../widgets/modern_division_card.dart';
import '../widgets/social_media_card.dart';

class TentangKamiPage extends StatelessWidget {
  const TentangKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tentang Kami',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 4)]),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // HEADER BANNER OVERLAPPING
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF34D399)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 170),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ]
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icons/png/icon_iot_hydrosense.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // APP INFO
            Text(
              'HydroSense SN',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B), letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.hasData ? snapshot.data!.version : '...';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15), 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: Text('Versi $version', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
                );
              }
            ),
            
            // CONTENT PADDING
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Section 1: Deskripsi Luaran KKN
                  _buildSectionTitle('HASIL LUARAN KKN', isDark),
                  _buildBodyText(
                    'HydroSense SN adalah produk inovasi luaran (output) dari program Kuliah Kerja Nyata (KKN) Universitas Islam Madura Posko 1 yang dilaksanakan di Desa Sumber Nangka. Sistem IoT pintar ini dirancang khusus sebagai pengabdian mahasiswa untuk memajukan sektor pertanian hidroponik lokal melalui teknologi cerdas.',
                    isDark,
                  ),
                  const SizedBox(height: 32),

                  // Section 2: Tujuan
                  _buildSectionTitle('FUNGSI & TUJUAN', isDark),
                  _buildBodyText(
                    'Sistem ini mengintegrasikan alat pemantau pH, EC/TDS (Kepekatan Pupuk), dan Suhu Air secara nirkabel. Tujuannya adalah mendigitalisasi pemantauan kualitas air, sehingga warga Desa Sumber Nangka dapat mengontrol hasil panen dengan lebih presisi, efisien, dan terpantau secara real-time dari mana saja.',
                    isDark,
                  ),
                  const SizedBox(height: 32),

                  // Card Informasi Umum Spesial
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark 
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] 
                          : [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTeamRow('Instansi', 'Ponpes Miftahul Hidayah', isDark),
                        _buildTeamRow('Alamat', 'Dusun Kopao Sumber Nangka, Duko Timur, Larangan, Kab. Pamekasan, Jawa Timur', isDark),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  final uri = Uri.parse('https://maps.app.goo.gl/drPZEu7djCg8TYxJA');
                                  launchUrl(uri, mode: LaunchMode.externalApplication);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text('Buka di Google Maps', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('TIM KAMI', isDark),
                  
                  ModernDivisionCard(title: '1. DPL', isDark: isDark, cardColor: cardColor, icon: Icons.school_rounded, iconColor: const Color(0xFFA78BFA), members: TeamData.dpl),
                  const SizedBox(height: 12),
                  ModernDivisionCard(title: '2. BPH TEAM', isDark: isDark, cardColor: cardColor, icon: Icons.manage_accounts_rounded, iconColor: const Color(0xFFF43F5E), members: TeamData.bph),
                  const SizedBox(height: 12),
                  ModernDivisionCard(title: '3. HUMAS TEAM', isDark: isDark, cardColor: cardColor, icon: Icons.campaign_rounded, iconColor: const Color(0xFFFB923C), members: TeamData.humas),
                  const SizedBox(height: 12),
                  ModernDivisionCard(title: '4. GREEN HOUSE TEAM', isDark: isDark, cardColor: cardColor, icon: Icons.eco_rounded, iconColor: const Color(0xFF34D399), members: TeamData.greenHouse),
                  const SizedBox(height: 12),
                  ModernDivisionCard(title: '5. IMT TEAM', isDark: isDark, cardColor: cardColor, icon: Icons.biotech_rounded, iconColor: const Color(0xFF38BDF8), members: TeamData.imt),
                  const SizedBox(height: 12),
                  ModernDivisionCard(title: '6. IOT TEAM', isDark: isDark, cardColor: cardColor, icon: Icons.memory_rounded, iconColor: const Color(0xFFEAB308), members: TeamData.iot),
                  const SizedBox(height: 32),
                  
                  // SOSMED BUTTONS
                  _buildSectionTitle('IKUTI PERJALANAN KAMI', isDark),
                  Row(
                    children: [
                      SocialMediaCard(
                        label: 'Instagram',
                        icon: FontAwesomeIcons.instagram,
                        url: 'https://www.instagram.com/kknposko1_sumbernangka?igsh=ZmsyZHphdzN1ejk2',
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFf09433), Color(0xFFe6683c), Color(0xFFdc2743), Color(0xFFcc2366), Color(0xFFbc1888)],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: const Color(0xFFdc2743).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SocialMediaCard(
                        label: 'TikTok',
                        icon: FontAwesomeIcons.tiktok,
                        url: 'https://www.tiktok.com/@kknposko1sumbernangka?_r=1&_t=ZS-98ZS4ddoX2K',
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  Text(
                    '© 2026 Tim KKN Desa Sumber Nangka\nDibuat dengan ❤️ untuk Masyarakat',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 40),
                ],
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
