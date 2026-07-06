import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class SystemMessageCard extends StatelessWidget {
  const SystemMessageCard({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.royalPurple.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.royalPurple.withOpacity(0.22),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
