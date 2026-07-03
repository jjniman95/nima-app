import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

enum PulseStatus {
  merged,
  endingSoon,
  expired,
  nearby,
}

class PulseStatusChip extends StatelessWidget {
  const PulseStatusChip({
    super.key,
    required this.status,
  });

  final PulseStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String text;
    late final IconData icon;

    switch (status) {
      case PulseStatus.merged:
        color = Colors.green;
        text = 'Pulses Merged';
        icon = Icons.favorite_rounded;
        break;

      case PulseStatus.endingSoon:
        color = Colors.orange;
        text = 'Merge Ending Soon';
        icon = Icons.timer_rounded;
        break;

      case PulseStatus.expired:
        color = Colors.red;
        text = 'Merge Expired';
        icon = Icons.link_off_rounded;
        break;

      case PulseStatus.nearby:
        color = AppColors.royalPurple;
        text = 'Nearby Pulse';
        icon = Icons.radar_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
