import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shared safe-area layout for onboarding and forms.
///
/// Top content scrolls independently when the screen is compact or the
/// keyboard opens. Actions remain consistently aligned above the bottom
/// device safe area on both Welcome and Create Account.
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
        child: Column(
          children: [
            Expanded(
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                AppSpacing.screenBottom,
              ),
              child: SizedBox(
                width: double.infinity,
                child: bottomActions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
