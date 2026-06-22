import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// A circular avatar showing the user's initials.
/// (Real photo uploads come in a later phase.)
class AvatarCircle extends StatelessWidget {
  final String initials;
  final double size;

  const AvatarCircle({super.key, required this.initials, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
