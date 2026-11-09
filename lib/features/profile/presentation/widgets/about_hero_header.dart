import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/toward_him_logo.dart';

/// Full-bleed mountain hero with the existing official logo and back button.
/// The rounded cream surface overlaps the background exactly as in the design.
class AboutHeroHeader extends StatelessWidget {
  const AboutHeroHeader({
    required this.child,
    required this.onBack,
    super.key,
  });

  final Widget child;
  final VoidCallback onBack;

  static const double backToContainerGap = 50;
  static const double containerTopRadius = 20;
  static const double contentTopInset = 20;

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.paddingOf(context).top +
        AppSpacing.screenTop +
        AppSpacing.backButtonSize +
        backToContainerGap;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerHeight + containerTopRadius,
          child: Image.asset(
            'assets/images/home/misty_sunrise_mountain_lake.webp',
            key: const Key('about_hero_image'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Column(
          children: [
            SizedBox(
              height: headerHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + AppSpacing.screenTop,
                    left: AppSpacing.screenHorizontal,
                    child: AppBackButton(onPressed: onBack),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + AppSpacing.screenTop,
                    left: 0,
                    right: 0,
                    child: const IgnorePointer(
                      child: Center(
                        child: TowardHimLogo(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              key: const Key('about_rounded_container'),
              width: double.infinity,
              padding: const EdgeInsets.only(top: contentTopInset),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(containerTopRadius),
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
