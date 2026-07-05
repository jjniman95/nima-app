import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class NimaAvatar extends StatelessWidget {
  const NimaAvatar({
    super.key,
    this.imageUrl,
    this.imageBase64,
    required this.nickname,
    this.size = 52,
    this.statusColor,
  });

  final String? imageUrl;
  final String? imageBase64;
  final String nickname;
  final double size;
  final Color? statusColor;

  ImageProvider? _imageProvider() {
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(imageBase64!);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final initial = nickname.isNotEmpty ? nickname[0].toUpperCase() : '?';
    final image = _imageProvider();

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.royalPurple,
          ),
          child: CircleAvatar(
            radius: size / 2,
            backgroundColor: AppColors.accentPurple,
            backgroundImage: image,
            child: image == null
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
