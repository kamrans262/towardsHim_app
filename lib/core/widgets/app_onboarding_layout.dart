import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shared safe-area layout: top content stays near the header while actions
/// fill remaining space and sit 25 logical pixels above the bottom safe area.
/// When content or keyboard leaves less room, both sections scroll naturally.
class AppOnboardingLayout extends StatelessWidget {
  const AppOnboardingLayout({
    required this.content,
    required this.bottomActions,
    this.minimumSectionGap = 24,
    super.key,
  });

  final Widget content;
  final Widget bottomActions;
  final double minimumSectionGap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.screenTop,
                AppSpacing.screenHorizontal,
                minimumSectionGap,
              ),
              sliver: SliverToBoxAdapter(child: content),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  0,
                  AppSpacing.screenHorizontal,
                  AppSpacing.screenBottom,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: bottomActions,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
