import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class NimaAvatar extends StatelessWidget {
  const NimaAvatar({
    super.key,
    this.imageUrl,
    required this.nickname,
    this.size = 52,
    this.statusColor,
  });

  final String? imageUrl;
  final String nickname;
  final double size;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final initial =
        nickname.isNotEmpty ? nickname[0].toUpperCase() : '?';

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.royalPurple,
            boxShadow: [
              BoxShadow(
                color: AppColors.royalPurple.withOpacity(.25),
                blurRadius: 12,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: size / 2,
            backgroundColor: AppColors.accentPurple,
            backgroundImage:
                imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? Text(
                    initial,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: size * .38,
                    ),
                  )
                : null,
          ),
        ),
        if (statusColor != null)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: size * .22,
              height: size * .22,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
