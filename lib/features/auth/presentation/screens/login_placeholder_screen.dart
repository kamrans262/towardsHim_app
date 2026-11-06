import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_onboarding_layout.dart';
import '../../../../core/widgets/toward_him_logo.dart';

/// A navigable UI-only destination until the approved Login design arrives.
class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppOnboardingLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: AppSpacing.logoHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(child: TowardHimLogo()),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.logoToHeading),
          const Text(
            'Log In',
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.headingToDescription),
          const Text(
            'Login screen UI will be added in the next module.',
            style: AppTypography.description,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      bottomActions: const SizedBox.shrink(),
    );
  }
}
