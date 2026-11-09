import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../data/weekly_challenge_detail_demo_data.dart';

/// Shared hero and rounded content surface for Weekly and Daily details.
///
/// The image remains visible behind both 20px top corner cutouts. The
/// first content label starts exactly 20px below the container's top.
class WeeklyChallengeHero extends StatelessWidget {
  const WeeklyChallengeHero({
    required this.onBack,
    required this.child,
    this.centeredHeaderOverlay,
    super.key,
  });

  final VoidCallback onBack;
  final Widget child;
  final Widget? centeredHeaderOverlay;

  @override
  Widget build(BuildContext context) {
    // Exactly 80px from the back button's lower edge to the card top.
    final headerHeight = MediaQuery.paddingOf(context).top +
        AppSpacing.screenTop +
        AppSpacing.backButtonSize +
        AppSpacing.weeklyBackToContainerGap;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerHeight + 20,
          child: Image.asset(
            WeeklyChallengeDetailDemoData.heroAsset,
            key: const Key('weekly_detail_hero'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: headerHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.paddingOf(context).top +
                        AppSpacing.screenTop,
                    left: AppSpacing.screenHorizontal,
                    child: AppBackButton(onPressed: onBack),
                  ),
                  if (centeredHeaderOverlay != null)
                    Positioned(
                      top: MediaQuery.paddingOf(context).top +
                          AppSpacing.screenTop,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Center(child: centeredHeaderOverlay!),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              key: const Key('challenge_detail_rounded_container'),
              width: double.infinity,
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: child,
            ),
          ],
        ),
      ],
    );
  }
}
