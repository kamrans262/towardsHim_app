import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_auth_header.dart';
import '../../../../core/widgets/app_auth_social_section.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_inline_link.dart';
import '../../../../core/widgets/app_onboarding_layout.dart';
import '../../../../core/widgets/app_text_field.dart';

/// UI-only form. Local field state is disposed when the screen is removed.
/// Authentication will be connected only in a later development phase.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({
    this.onBack,
    this.onLogin,
    super.key,
  });

  final VoidCallback? onBack;
  final VoidCallback? onLogin;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
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

  void _goToLogin() {
    if (widget.onLogin != null) {
      widget.onLogin!();
    } else {
      _showUiOnlyNotice('Log In');
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
            'Create Your Account',
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.headingToDescription),
          const Text(
            'Join toward HIM and start your journey',
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
                children: [
                  AppTextField(
                    label: 'Full Name',
                    iconAsset: 'assets/icons/iconamoon_profile-light.svg',
                    controller: _nameController,
                    focusNode: _nameFocus,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    onSubmitted: (_) => _emailFocus.requestFocus(),
                  ),
                  const SizedBox(height: AppSpacing.fieldGap),
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
                    textInputAction: TextInputAction.next,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
                  ),
                  const SizedBox(height: AppSpacing.fieldGap),
                  AppTextField(
                    label: 'Confirm Password',
                    iconAsset: 'assets/icons/mingcute_lock-line.svg',
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    onSubmitted: (_) => _confirmPasswordFocus.unfocus(),
                  ),
                  const SizedBox(height: AppSpacing.formToDivider),
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
            key: const Key('create_account_bottom_actions'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                label: 'Create Account',
                onPressed: () => _showUiOnlyNotice('Account creation'),
              ),
              const SizedBox(height: AppSpacing.bottomSectionGap),
              AppInlineLink(
                message: 'Already have an account?',
                action: 'Log In',
                onPressed: _goToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
