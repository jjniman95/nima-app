import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AboutPulseRequestCard extends StatelessWidget {
  const AboutPulseRequestCard({
    super.key,
    required this.requesterName,
    required this.onAccept,
    required this.onDecline,
  });

  final String requesterName;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.royalPurple.withOpacity(.25),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(.06),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.royalPurple,
              child: Icon(
                Icons.person_search_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'About Pulse',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '$requesterName wants to know more about you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.textMuted,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: const Text('Decline'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
