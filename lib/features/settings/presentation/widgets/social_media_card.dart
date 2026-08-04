import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaCard extends StatelessWidget {
  final String label;
  final FaIconData icon;
  final String url;
  final BoxDecoration decoration;

  const SocialMediaCard({
    super.key,
    required this.label,
    required this.icon,
    required this.url,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              final uri = Uri.parse(url);
              launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                children: [
                  FaIcon(icon, color: Colors.white, size: 26),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
