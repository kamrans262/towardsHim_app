import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_or_divider.dart';
import 'app_social_auth_button.dart';

/// Reused Google/Apple UI-only section for both authentication forms.
class AppAuthSocialSection extends StatelessWidget {
  const AppAuthSocialSection({
    required this.onGooglePressed,
    required this.onApplePressed,
    super.key,
  });

  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppOrDivider(),
        const SizedBox(height: AppSpacing.dividerToSocial),
        AppSocialAuthButton(
          label: 'Continue with Google',
          iconAsset: 'assets/icons/google.svg',
          onPressed: onGooglePressed,
        ),
        const SizedBox(height: AppSpacing.socialButtonsGap),
        AppSocialAuthButton(
          label: 'Continue with Apple',
          iconAsset: 'assets/icons/mdi_apple.svg',
          onPressed: onApplePressed,
        ),
      ],
    );
  }
}
