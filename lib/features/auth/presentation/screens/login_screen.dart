import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_auth_header.dart';
import '../../../../core/widgets/app_auth_social_section.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_inline_link.dart';
import '../../../../core/widgets/app_onboarding_layout.dart';
import '../../../../core/widgets/app_text_field.dart';

/// UI-only login screen. Controllers and focus nodes are local to this route.
/// Authentication and account recovery are intentionally not integrated.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    this.onBack,
    this.onCreateAccount,
    this.onForgotPassword,
    super.key,
  });

  final VoidCallback? onBack;
  final VoidCallback? onCreateAccount;
  final VoidCallback? onForgotPassword;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _showUiOnlyNotice(String action) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action will be connected after the UI phase.')),
    );
  }

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _goToCreateAccount() {
    if (widget.onCreateAccount != null) {
      widget.onCreateAccount!();
    } else {
      _showUiOnlyNotice('Create Account');
    }
  }

  void _goToForgotPassword() {
    if (widget.onForgotPassword != null) {
      widget.onForgotPassword!();
    } else {
      _showUiOnlyNotice('Forgot Password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppOnboardingLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppAuthHeader(onBack: _goBack),
          const SizedBox(height: AppSpacing.logoToHeading),
          const Text(
            'WELCOME BACK',
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.headingToDescription),
          const Text(
            'Sign in to continue your journey',
            style: AppTypography.description,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.descriptionToForm),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.actionMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: 'E-mail',
                    iconAsset: 'assets/icons/wpf_message-outline.svg',
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  const SizedBox(height: AppSpacing.fieldGap),
                  AppTextField(
                    label: 'Password',
                    iconAsset: 'assets/icons/mingcute_lock-line.svg',
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _passwordFocus.unfocus(),
                  ),
                  const SizedBox(height: AppSpacing.passwordToForgot),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Semantics(
                      button: true,
                      label: 'Forgot Password ?',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _goToForgotPassword,
                        child: Text(
                          'Forgot Password ?',
                          key: const Key('login_forgot_password'),
                          style: AppTypography.forgotPassword,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.forgotToDivider),
                  AppAuthSocialSection(
                    onGooglePressed: () =>
                        _showUiOnlyNotice('Google sign-in'),
                    onApplePressed: () =>
                        _showUiOnlyNotice('Apple sign-in'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomActions: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.actionMaxWidth,
          ),
          child: Column(
            key: const Key('login_bottom_actions'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                label: 'Login',
                onPressed: () => _showUiOnlyNotice('Login'),
              ),
              const SizedBox(height: AppSpacing.bottomSectionGap),
              AppInlineLink(
                message: 'Don’t have an account?',
                action: 'Create Account',
                actionKey: const Key('inline_create_account_action'),
                onPressed: _goToCreateAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
