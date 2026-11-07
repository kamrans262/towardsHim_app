import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Shared content-type badge used for Podcast, Meditation and Prayer.
class AppContentTypeTag extends StatelessWidget {
  const AppContentTypeTag({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.playerTagHorizontal,
        vertical: AppSpacing.playerTagVertical,
      ),
      decoration: const BoxDecoration(
        color: AppColors.podcastTile,
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
      child: Text(
        label,
        style: AppTypography.playerTag,
      ),
    );
  }
}
