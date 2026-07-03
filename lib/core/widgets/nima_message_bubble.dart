import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class NimaMessageBubble extends StatelessWidget {
  const NimaMessageBubble({
    super.key,
    required this.text,
    required this.mine,
    required this.time,
    this.seen = false,
  });

  final String text;
  final bool mine;
  final String time;
  final bool seen;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = mine
        ? AppColors.royalPurple
        : isDark
            ? AppColors.darkSurface
            : Colors.white;

    final textColor = mine
        ? Colors.white
        : isDark
            ? Colors.white
            : AppColors.textDark;

    final metaColor = mine
        ? Colors.white70
        : isDark
            ? Colors.white54
            : AppColors.textMuted;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(mine ? 20 : 6),
            bottomRight: Radius.circular(mine ? 6 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.16 : 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 15.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: metaColor,
                    fontSize: 11,
                  ),
                ),
                if (mine && seen) ...[
                  const SizedBox(width: 6),
                  Text(
                    'Seen',
                    style: TextStyle(
                      color: metaColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
