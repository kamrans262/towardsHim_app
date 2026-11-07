import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../data/weekly_challenge_detail_demo_data.dart';

/// Shared full-bleed sunrise hero; back button honors the device safe area.
class WeeklyChallengeHero extends StatelessWidget {
  const WeeklyChallengeHero({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: WeeklyChallengeDetailDemoData.heroVisibleHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: WeeklyChallengeDetailDemoData.heroImageHeight,
            child: Image.asset(
              WeeklyChallengeDetailDemoData.heroAsset,
              key: const Key('weekly_detail_hero'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + AppSpacing.screenTop,
            left: AppSpacing.screenHorizontal,
            child: AppBackButton(onPressed: onBack),
          ),
        ],
      ),
    );
  }
}
