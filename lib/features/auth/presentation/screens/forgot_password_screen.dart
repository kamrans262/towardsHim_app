import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_auth_header.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_onboarding_layout.dart';
import '../../../../core/widgets/app_otp_input.dart';
import '../../../../core/widgets/app_send_icon_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Forgot Password and Account Verification UI with no network requests.
///
/// The email and six-digit code live locally in text controllers. No code is
/// sent or verified until a later backend milestone.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    this.onBack,
    this.onBackToLogin,
    super.key,
  });

  final VoidCallback? onBack;
  final VoidCallback? onBackToLogin;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static final RegExp _emailPattern =
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailFocus = FocusNode();
  final _otpFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFormChanged);
    _otpController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFormChanged);
    _otpController.removeListener(_onFormChanged);
    _emailController.dispose();
    _otpController.dispose();
    _emailFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  bool get _canVerify =>
      _emailPattern.hasMatch(_emailController.text.trim()) &&
      _otpController.text.length == AppOtpInput.length;

  void _showUiOnlyNotice(String message) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _sendCode() {
    _showUiOnlyNotice(
      'Sending verification codes will be available after the UI phase.',
    );
  }

  void _verify() {
    _showUiOnlyNotice(
      'Code verification will be available after the UI phase.',
    );
  }

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _goBackToLogin() {
    if (widget.onBackToLogin != null) {
      widget.onBackToLogin!();
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
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
            'Forgot Password?',
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.headingToDescription),
          const Text(
            'Enter your email and we’ll send you a code',
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
                  Row(
                    key: const Key('forgot_email_row'),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Enter your E-mail',
                          iconAsset: 'assets/icons/wpf_message-outline.svg',
                          controller: _emailController,
                          focusNode: _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.email],
                          onSubmitted: (_) => _emailFocus.unfocus(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.emailToSendGap),
                      AppSendIconButton(onPressed: _sendCode),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.emailToVerifyHeading),
                  const Text(
                    'Verify Your Account',
                    style: AppTypography.heading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.headingToDescription),
                  const Text(
                    'Enter the 6-digit code sent to your email',
                    style: AppTypography.description,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.verifyDescriptionToOtp),
                  AppOtpInput(
                    controller: _otpController,
                    focusNode: _otpFocus,
                    onChanged: (_) => _onFormChanged(),
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
            key: const Key('forgot_password_bottom_actions'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                label: 'Verify',
                onPressed: _canVerify ? _verify : null,
              ),
              const SizedBox(height: AppSpacing.bottomSectionGap),
              Semantics(
                button: true,
                label: 'Back to login',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _goBackToLogin,
                  child: Text(
                    'Back to login',
                    key: const Key('back_to_login_action'),
                    style: AppTypography.description.copyWith(
                      color: AppColors.primaryOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
