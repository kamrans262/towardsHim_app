import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_auth_header.dart';
import '../../../../core/widgets/app_onboarding_layout.dart';

/// UI-only route until the Forgot Password Figma screen is approved.
class ForgotPasswordPlaceholderScreen extends StatelessWidget {
  const ForgotPasswordPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppOnboardingLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppAuthHeader(
            onBack: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: AppSpacing.logoToHeading),
          const Text(
            'Forgot Password',
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.headingToDescription),
          const Text(
            'Password recovery UI will be added in a future module.',
            style: AppTypography.description,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      bottomActions: const SizedBox.shrink(),
    );
  }
}
