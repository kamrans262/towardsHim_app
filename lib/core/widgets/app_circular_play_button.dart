import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppCircularPlayButton extends StatelessWidget {
  const AppCircularPlayButton({
    required this.isPlaying,
    required this.onPressed,
    this.diameter = AppSpacing.homePlayDiameter,
    this.iconSize = 20,
    super.key,
  });

  final bool isPlaying;
  final VoidCallback onPressed;
  final double diameter;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: Material(
        color: AppColors.primaryOrange,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: AppColors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
