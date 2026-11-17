import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_auth_header.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_otp_input.dart';
import '../../data/auth_repository.dart';

/// Password-login OTP step using the same six approved boxes and bottom action.
class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({
    required this.challenge,
    this.onVerified,
    this.onBack,
    super.key,
  });

  final LoginOtpChallenge challenge;
  final VoidCallback? onVerified;
  final VoidCallback? onBack;

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();
  bool _busy = false;
  int _cooldown = 0;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_changed);
    _startCooldown(widget.challenge.resendAfterSeconds);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _startCooldown(int seconds) {
    _countdown?.cancel();
    _cooldown = seconds;
    if (seconds <= 0) return;
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _verify() async {
    if (_busy || _codeController.text.length != AppOtpInput.length) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await AuthRepository.instance.verifyLoginOtp(
        challenge: widget.challenge.challenge,
        code: _codeController.text,
      );
      if (!mounted) return;
      if (widget.onVerified != null) {
        widget.onVerified!();
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      }
    } catch (error) {
      if (mounted) {
        _codeController.clear();
        _notice(error.toString());
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_busy || _cooldown > 0) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      final delay = await AuthRepository.instance.resendLoginOtp(
        challenge: widget.challenge.challenge,
      );
      if (!mounted) return;
      _codeController.clear();
      _startCooldown(delay);
      _notice('A new verification code has been sent to your email.');
    } catch (error) {
      if (mounted) _notice(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _codeController.removeListener(_changed);
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal, AppSpacing.screenTop,
                AppSpacing.screenHorizontal, 0,
              ),
              child: AppAuthHeader(
                onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal, vertical: 24,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: AppSpacing.actionMaxWidth),
                          child: Column(
                            key: const Key('login_otp_centered_content'),
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Verify Your Account',
                                style: AppTypography.heading,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.headingToDescription),
                              Text(
                                'Enter the 6-digit code sent to\n' + widget.challenge.email,
                                style: AppTypography.description,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.verifyDescriptionToOtp),
                              AppOtpInput(
                                controller: _codeController,
                                focusNode: _codeFocus,
                                onChanged: (_) => _changed(),
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                key: const Key('login_otp_resend'),
                                onPressed: _busy || _cooldown > 0 ? null : _resend,
                                child: Text(
                                  _cooldown > 0
                                      ? 'Resend code in ' + _cooldown.toString() + 's'
                                      : 'Resend Code',
                                  style: AppTypography.description.copyWith(
                                    color: _cooldown > 0
                                        ? AppColors.secondaryText
                                        : AppColors.primaryOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal, 0,
                AppSpacing.screenHorizontal, AppSpacing.screenBottom,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.actionMaxWidth),
                child: SizedBox(
                  key: const Key('login_otp_bottom_action'),
                  width: double.infinity,
                  child: AppButton(
                    label: 'Verify',
                    onPressed: _busy ||
                        _codeController.text.length != AppOtpInput.length
                        ? null
                        : _verify,
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
