import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shared thumbnail: 70px on Home, 100px on the Listen list.
class AppAudioThumbnail extends StatelessWidget {
  const AppAudioThumbnail({
    required this.imageAsset,
    required this.size,
    this.withShadow = false,
    super.key,
  });

  final String imageAsset;
  final double size;
  final bool withShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
        boxShadow: withShadow
            ? const [
                BoxShadow(
                  color: AppColors.backShadow,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
        child: Image.asset(
          imageAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
