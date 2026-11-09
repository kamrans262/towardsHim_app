import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { filled, outlined }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.outlinedBackgroundColor,
    this.outlinedBorderColor,
    this.filledBackgroundColor,
    this.filledForegroundColor,
    this.outlinedForegroundColor,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Color? outlinedBackgroundColor;
  final Color? outlinedBorderColor;
  final Color? filledBackgroundColor;
  final Color? filledForegroundColor;
  final Color? outlinedForegroundColor;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
    );

    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: switch (variant) {
        AppButtonVariant.filled => FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: filledBackgroundColor ?? AppColors.primaryOrange,
              foregroundColor: filledForegroundColor ?? AppColors.white,
              disabledBackgroundColor: AppColors.secondaryText,
              disabledForegroundColor: AppColors.white,
              textStyle: AppTypography.button,
              shape: shape,
              padding: EdgeInsets.zero,
            ),
            child: Text(label),
          ),
        AppButtonVariant.outlined => OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: outlinedBackgroundColor ?? AppColors.outlinedButtonBackground,
              foregroundColor: outlinedForegroundColor ?? AppColors.primaryOrange,
              disabledForegroundColor: outlinedForegroundColor ?? AppColors.primaryOrange,
              side: BorderSide(
                color: outlinedBorderColor ?? AppColors.primaryOrange.withValues(alpha: 0.5),
                width: 1,
              ),
              textStyle: AppTypography.button,
              shape: shape,
              padding: EdgeInsets.zero,
            ),
            child: Text(label),
          ),
      },
    );
  }
}
