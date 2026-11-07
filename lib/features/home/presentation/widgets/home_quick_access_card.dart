import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/home_models.dart';

class HomeQuickAccessCard extends StatelessWidget {
  const HomeQuickAccessCard({
    required this.item,
    required this.onPressed,
    super.key,
  });

  final HomeQuickAccess item;
  final VoidCallback onPressed;

  Color get background => switch (item.type) {
        HomeQuickType.podcast => AppColors.podcastTile,
        HomeQuickType.meditation => AppColors.meditationTile,
        HomeQuickType.prayer => AppColors.prayerTile,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.homeQuickCardHeight,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        child: InkWell(
          key: Key('quick_${item.title}'),
          borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  item.iconAsset,
                  width: 30,
                  height: 30,
                  semanticsLabel: item.title,
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.title,
                    maxLines: 1,
                    style: AppTypography.quickAccessLabel,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
