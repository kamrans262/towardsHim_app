import 'package:flutter/material.dart';

import '../../data/auth_repository.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_auth_header.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_onboarding_layout.dart';
import '../../../../core/widgets/app_otp_input.dart';
import '../../../../core/widgets/app_send_icon_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Approved OTP screen connected to email recovery APIs.
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
  bool _busy = false;
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

  Future<void> _sendCode() async {
    if (_busy) return;
    if (!_emailPattern.hasMatch(_emailController.text.trim())) {
      _showUiOnlyNotice('Enter a valid email address.');
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthRepository.instance.sendRecoveryCode(_emailController.text);
      if (mounted) {
        _showUiOnlyNotice('If an account exists, a code has been sent to its email.');
      }
    } catch (error) {
      if (mounted) _showUiOnlyNotice(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_busy || !_canVerify) return;
    setState(() => _busy = true);
    try {
      final ticket = await AuthRepository.instance.verifyRecoveryCode(
        _emailController.text,
        _otpController.text,
      );
      if (!mounted) return;
      final passwords = await _newPasswordDialog();
      if (passwords == null) {
        if (mounted) _showUiOnlyNotice('Request a new code when you are ready to reset your password.');
        return;
      }
      await AuthRepository.instance.resetPassword(
        email: _emailController.text,
        ticket: ticket,
        password: passwords[0],
        confirmation: passwords[1],
      );
      if (mounted) {
        _showUiOnlyNotice('Password updated. Please log in.');
        _goBackToLogin();
      }
    } catch (error) {
      if (mounted) _showUiOnlyNotice(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<List<String>?> _newPasswordDialog() async {
    final password = TextEditingController();
    final confirm = TextEditingController();
    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.outlinedButtonBackground,
            title: const Text('Set a new password', style: AppTypography.sectionHeading),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password (8+ characters)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirm,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm Password'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (password.text.length < 8 || password.text != confirm.text) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Passwords must match and contain at least 8 characters.')),
                    );
                    return;
                  }
                  Navigator.of(dialogContext).pop([password.text, confirm.text]);
                },
                child: const Text('Reset Password', style: TextStyle(color: AppColors.primaryOrange)),
              ),
            ],
          ),
    );
    password.dispose();
    confirm.dispose();
    return result;
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
                onPressed: (_canVerify && !_busy) ? _verify : null,
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
