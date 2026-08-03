import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

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
                    'Bantuan & Dukungan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B), letterSpacing: -0.5),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  NeumorphicContainer(
                    borderRadius: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          _buildHelpTile(isDark, Icons.question_answer_rounded, const Color(0xFF38BDF8), 'FAQ', 'Pertanyaan yang sering diajukan', () {}),
                          Divider(height: 1, indent: 64, color: isDark ? Colors.grey.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2)),
                          _buildHelpTile(isDark, Icons.support_agent_rounded, const Color(0xFF34D399), 'Hubungi Kami', 'WhatsApp atau Email Developer', () => _showContactOptions(context, isDark)),
                          Divider(height: 1, indent: 64, color: isDark ? Colors.grey.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2)),
                          _buildHelpTile(isDark, Icons.menu_book_rounded, const Color(0xFFFB923C), 'Panduan Penggunaan', 'Cara menggunakan aplikasi & alat', () => context.push(AppRoutes.panduanPenggunaan)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text('LEGAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade500)),
                  const SizedBox(height: 16),
                  NeumorphicContainer(
                    borderRadius: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          _buildHelpTile(isDark, Icons.privacy_tip_rounded, const Color(0xFFA78BFA), 'Kebijakan Privasi', '', () {}),
                          Divider(height: 1, indent: 64, color: isDark ? Colors.grey.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2)),
                          _buildHelpTile(isDark, Icons.gavel_rounded, const Color(0xFFF43F5E), 'Syarat & Ketentuan', '', () {}),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
              Text('Hubungi Developer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
              const SizedBox(height: 24),
              NeumorphicContainer(
                borderRadius: 16,
                child: ListTile(
                  leading: const Icon(Icons.chat_rounded, color: Color(0xFF25D366)),
                  title: Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                  subtitle: const Text('+62 851-7744-8544'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey),
                  onTap: () async {
                    final uri = Uri.parse('https://wa.me/6285177448544?text=Halo%20Developer%20HydroSense');
                    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
              ),
              const SizedBox(height: 16),
              NeumorphicContainer(
                borderRadius: 16,
                child: ListTile(
                  leading: const Icon(Icons.email_rounded, color: Color(0xFFEA4335)),
                  title: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                  subtitle: const Text('makdumibrohim28@gmail.com'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey),
                  onTap: () async {
                    final uri = Uri.parse('mailto:makdumibrohim28@gmail.com?subject=Bantuan%20Aplikasi%20HydroSense');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  Widget _buildHelpTile(bool isDark, IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}