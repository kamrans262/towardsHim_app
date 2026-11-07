import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppCircularPlayButton extends StatelessWidget {
  const AppCircularPlayButton({
    required this.isPlaying,
    required this.onPressed,
    super.key,
  });

  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.homePlayDiameter,
      height: AppSpacing.homePlayDiameter,
      child: Material(
        color: AppColors.primaryOrange,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: AppColors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
