import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/constants/team_data.dart';
import '../widgets/modern_division_card.dart';
import '../widgets/social_media_card.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../../../../core/constants/app_colors.dart';

class TentangKamiPage extends StatelessWidget {
  const TentangKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? AppColors.neumoBgDark : AppColors.neumoBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tentang Kami',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
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
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
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
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icons/png/icon_iot_hydrosense2.png',
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
              'SN Hydro',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.hasData
                    ? snapshot.data!.version
                    : '...';
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Versi $version',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                );
              },
            ),

            // CONTENT PADDING
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Section 1: Deskripsi Luaran KKN
                  _buildSectionTitle('HASIL LUARAN KKN', isDark),
                  _buildHighlightCard(
                    icon: Icons.emoji_events_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Inovasi Berbasis Pengabdian',
                    description:
                        'SN Hydro lahir dari program Kuliah Kerja Nyata (KKN) Universitas Islam Madura Posko 1 di Desa Sumber Nangka — sebuah karya nyata mahasiswa untuk masyarakat.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildHighlightCard(
                    icon: Icons.sensors_rounded,
                    iconColor: const Color(0xFF38BDF8),
                    title: 'Sistem IoT Pertanian Hidroponik',
                    description:
                        'Dirancang khusus untuk memajukan sektor pertanian hidroponik lokal menggunakan teknologi pemantauan pintar berbasis Internet of Things (IoT).',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),

                  // Section 2: Tujuan
                  _buildSectionTitle('FUNGSI & TUJUAN', isDark),
                  _buildGoalList(isDark),
                  const SizedBox(height: 32),

                  // Card Informasi Umum Spesial
                  NeumorphicContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTeamRow(
                          'Instansi',
                          'Ponpes Miftahul Hidayah',
                          isDark,
                        ),
                        _buildTeamRow(
                          'Alamat',
                          'Dusun Kopao Sumber Nangka, Duko Timur, Larangan, Kab. Pamekasan, Jawa Timur',
                          isDark,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  final uri = Uri.parse(
                                    'https://maps.app.goo.gl/drPZEu7djCg8TYxJA',
                                  );
                                  launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Buka di Google Maps',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
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

                  ModernDivisionCard(
                    title: '1. DPL',
                    isDark: isDark,
                    cardColor: cardColor,
                    icon: Icons.school_rounded,
                    iconColor: const Color(0xFFA78BFA),
                    members: TeamData.dpl,
                  ),
                  const SizedBox(height: 12),
                  ModernDivisionCard(
                    title: '2. BPH TEAM',
                    isDark: isDark,
                    cardColor: cardColor,
                    icon: Icons.manage_accounts_rounded,
                    iconColor: const Color(0xFFF43F5E),
                    members: TeamData.bph,
                  ),
                  const SizedBox(height: 12),
                  ModernDivisionCard(
                    title: '3. HUMAS TEAM',
                    isDark: isDark,
                    cardColor: cardColor,
                    icon: Icons.campaign_rounded,
                    iconColor: const Color(0xFFFB923C),
                    members: TeamData.humas,
                  ),
                  const SizedBox(height: 12),
                  ModernDivisionCard(
                    title: '4. GREEN HOUSE TEAM',
                    isDark: isDark,
                    cardColor: cardColor,
                    icon: Icons.eco_rounded,
                    iconColor: const Color(0xFF34D399),
                    members: TeamData.greenHouse,
                  ),
                  const SizedBox(height: 12),
                  ModernDivisionCard(
                    title: '5. IMT TEAM',
                    isDark: isDark,
                    cardColor: cardColor,
                    icon: Icons.biotech_rounded,
                    iconColor: const Color(0xFF38BDF8),
                    members: TeamData.imt,
                  ),
                  const SizedBox(height: 12),
                  ModernDivisionCard(
                    title: '6. IOT TEAM',
                    isDark: isDark,
                    cardColor: cardColor,
                    icon: Icons.memory_rounded,
                    iconColor: const Color(0xFFEAB308),
                    members: TeamData.iot,
                  ),
                  const SizedBox(height: 32),

                  // SOSMED BUTTONS
                  _buildSectionTitle('IKUTI PERJALANAN KAMI', isDark),
                  Row(
                    children: [
                      SocialMediaCard(
                        label: 'Instagram',
                        icon: FontAwesomeIcons.instagram,
                        url:
                            'https://www.instagram.com/kknposko1_sumbernangka?igsh=ZmsyZHphdzN1ejk2',
                        brandColor: const Color(0xFFE1306C),
                      ),
                      const SizedBox(width: 16),
                      SocialMediaCard(
                        label: 'TikTok',
                        icon: FontAwesomeIcons.tiktok,
                        url:
                            'https://www.tiktok.com/@kknposko1sumbernangka?_r=1&_t=ZS-98ZS4ddoX2K',
                        brandColor: isDark ? Colors.white : Colors.black,
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),
                  Text(
                    '© 2026 Tim KKN Desa Sumber Nangka\n Untuk SMP & SMK Sumber Nangka',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
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
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return NeumorphicContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeumorphicContainer(
            borderRadius: 12,
            padding: const EdgeInsets.all(10),
            isPressed: true,
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalList(bool isDark) {
    final goals = [
      (
        Icons.science_rounded,
        const Color(0xFF38BDF8),
        'Pemantauan pH Air',
        'Memastikan tingkat keasaman air selalu ideal untuk pertumbuhan tanaman.',
      ),
      (
        Icons.water_rounded,
        const Color(0xFF34D399),
        'Pemantauan EC & TDS',
        'Mengukur kepekatan pupuk agar nutrisi tanaman selalu tercukupi secara optimal.',
      ),
      (
        Icons.thermostat_rounded,
        const Color(0xFFFB923C),
        'Pemantauan Suhu Air',
        'Memantau temperatur air untuk menjaga kondisi tumbuh yang stabil.',
      ),
      (
        Icons.phone_android_rounded,
        const Color(0xFFA78BFA),
        'Real-Time dari Mana Saja',
        'Warga Sumber Nangka bisa mengontrol hasil panen kapan saja lewat smartphone.',
      ),
    ];

    return NeumorphicContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: goals.map((g) {
          final isLast = g == goals.last;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeumorphicContainer(
                    borderRadius: 8,
                    padding: const EdgeInsets.all(6),
                    isPressed: true,
                    child: Icon(g.$1, color: g.$2, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.$3,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          g.$4,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 6),
                Divider(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.06),
                  thickness: 1,
                ),
                const SizedBox(height: 6),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTeamRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
