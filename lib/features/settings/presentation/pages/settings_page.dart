import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          children: [
            Text(
              'Pengaturan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'TAMPILAN',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF38BDF8).withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: const Color(0xFF38BDF8)),
                ),
                title: Text('Mode Tampilan', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                subtitle: Text(themeProvider.isDarkMode ? 'Gelap' : 'Terang', style: const TextStyle(fontSize: 12)),
                activeColor: const Color(0xFF38BDF8),
                value: themeProvider.isDarkMode,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onChanged: (value) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value),
              ),
            ),
            
            const SizedBox(height: 32),
            Text(
              'INFORMASI APLIKASI',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Kami',
                    iconColor: const Color(0xFF34D399),
                    onTap: () => context.push(AppRoutes.tentangKami),
                    isDark: isDark,
                  ),
                  Divider(height: 1, indent: 64, color: isDark ? Colors.grey.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2)),
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Bantuan & Dukungan',
                    iconColor: const Color(0xFFFB923C),
                    onTap: () => context.push(AppRoutes.helpSupport),
                    isDark: isDark,
                  ),
                  Divider(height: 1, indent: 64, color: isDark ? Colors.grey.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2)),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFA78BFA).withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.verified_rounded, color: Color(0xFFA78BFA)),
                    ),
                    title: Text('Versi Aplikasi', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                    trailing: Text(_version, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDark;

  const _SettingsTile({required this.icon, required this.title, required this.iconColor, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF1E293B))),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}