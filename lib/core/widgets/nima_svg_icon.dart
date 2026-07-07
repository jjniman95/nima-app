import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';

class NimaSvgIcon extends StatelessWidget {
  const NimaSvgIcon({
    super.key,
    required this.name,
    this.size = 22,
    this.color,
  });

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        color ?? (isDark ? Colors.white : AppColors.royalPurple),
        BlendMode.srcIn,
      ),
    );
  }
}
