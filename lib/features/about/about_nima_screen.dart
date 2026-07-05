import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AboutNimaScreen extends StatelessWidget {
  const AboutNimaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About NIMA'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.royalPurple.withOpacity(0.16),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.royalPurple,
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'NIMA',
                style: TextStyle(
                  color: textColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Meet nearby. Say Hi. Merge. Leave no history.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _AboutCard(
                color: cardColor,
                icon: Icons.radar_rounded,
                title: 'Nearby First',
                body:
                    'NIMA is designed for people who are physically nearby. Discovery, Hi requests, and merges are built around real nearby presence.',
              ),
              _AboutCard(
                color: cardColor,
                icon: Icons.waving_hand_rounded,
                title: 'Consent Always',
                body:
                    'No one can message you directly. A Hi must be sent and accepted before a merge can begin.',
              ),
              _AboutCard(
                color: cardColor,
                icon: Icons.timer_rounded,
                title: 'Temporary by Design',
                body:
                    'Merges are not permanent chats. When a merge expires or is disconnected, its messages and temporary data are removed.',
              ),
              _AboutCard(
                color: cardColor,
                icon: Icons.visibility_off_rounded,
                title: 'Ghost Mode',
                body:
                    'Ghost Mode lets you hide yourself from Nearby. You decide when you want to be discoverable.',
              ),
              _AboutCard(
                color: cardColor,
                icon: Icons.lock_rounded,
                title: 'Privacy Focused',
                body:
                    'NIMA does not use email, phone numbers, passwords, logout, public profiles, or permanent contacts.',
              ),
              const SizedBox(height: 10),
              Text(
                'Version 0.1',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black12,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.royalPurple.withOpacity(0.14),
            child: Icon(
              icon,
              color: AppColors.royalPurple,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: TextStyle(
                    color: mutedColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
