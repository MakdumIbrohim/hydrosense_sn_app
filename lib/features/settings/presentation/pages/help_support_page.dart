import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan & Dukungan')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.question_answer_outlined),
            title: const Text('FAQ'),
            subtitle: const Text('Pertanyaan yang sering diajukan'),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text('Hubungi Kami'),
            subtitle: const Text('WhatsApp atau Email CS'),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('Panduan Penggunaan'),
            subtitle: const Text('Cara menggunakan aplikasi & alat'),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Kebijakan Privasi'),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Syarat & Ketentuan'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}