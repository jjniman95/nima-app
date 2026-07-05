import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class NimaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NimaAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBack = false,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor:
          isDark ? AppColors.darkBackground : Colors.white,
      foregroundColor:
          isDark ? Colors.white : Colors.black87,

      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: onBack ??
                  () {
                    Navigator.of(context).maybePop();
                  },
            )
          : null,

      titleSpacing: 0,

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
            ),
        ],
      ),

      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle == null ? 60 : 72);
}
