import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable 48px icon action matching the authentication input borders.
class AppSendIconButton extends StatelessWidget {
  const AppSendIconButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.sendButtonSize,
      height: AppSpacing.sendButtonSize,
      child: Material(
        color: AppColors.background,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/hugeicons_sent.svg',
              width: AppSpacing.fieldIconSize,
              height: AppSpacing.fieldIconSize,
              semanticsLabel: 'Send code',
            ),
          ),
        ),
      ),
    );
  }
}
