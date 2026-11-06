import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/toward_him_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    this.onCreateAccount,
    this.onLogin,
    this.onContinueAsGuest,
    super.key,
  });

  final VoidCallback? onCreateAccount;
  final VoidCallback? onLogin;
  final VoidCallback? onContinueAsGuest;

  static const description =
      'Podcasts, Meditations, Prayers, Challenges and a community to help '
      'you grow closer to HIM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minContentHeight = math.max(
              0.0,
              constraints.maxHeight -
                  AppSpacing.welcomeTop -
                  AppSpacing.welcomeBottom,
            );

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.welcomeTop,
                  AppSpacing.screenHorizontal,
                  AppSpacing.welcomeBottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minContentHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: TowardHimLogo()),
                        const SizedBox(height: AppSpacing.logoToHeading),
                        const Text(
                          'Welcome to Toward HIM',
                          style: AppTypography.heading,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: AppSpacing.headingToDescription,
                        ),
                        const Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: AppSpacing.descriptionMaxWidth,
                            ),
                            child: Text(
                              description,
                              style: AppTypography.description,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AppSpacing.actionMaxWidth,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppButton(
                                  label: 'Create Account',
                                  variant: AppButtonVariant.outlined,
                                  onPressed: onCreateAccount,
                                ),
                                const SizedBox(
                                  height: AppSpacing.buttonsGap,
                                ),
                                AppButton(
                                  label: 'Login',
                                  onPressed: onLogin,
                                ),
                                const SizedBox(
                                  height: AppSpacing.loginToGuest,
                                ),
                                _GuestAction(onPressed: onContinueAsGuest),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GuestAction extends StatelessWidget {
  const _GuestAction({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue as Guest',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          height: 44,
          child: Align(
            alignment: Alignment.topCenter,
            child: Text.rich(
              const TextSpan(
                children: [
                  TextSpan(text: 'You can either '),
                  TextSpan(
                    text: 'continue as Guest',
                    style: TextStyle(color: AppColors.primaryOrange),
                  ),
                ],
              ),
              style: AppTypography.guest,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
