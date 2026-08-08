import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/neumorphic_container.dart';

class SocialMediaCard extends StatelessWidget {
  final String label;
  final FaIconData icon;
  final String url;
  final Color brandColor;

  const SocialMediaCard({
    super.key,
    required this.label,
    required this.icon,
    required this.url,
    required this.brandColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NeumorphicContainer(
        borderRadius: 16,
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
                  FaIcon(icon, color: brandColor, size: 26),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: brandColor,
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
