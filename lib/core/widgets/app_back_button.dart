import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: Container(
        width: AppSpacing.backButtonSize,
        height: AppSpacing.backButtonSize,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.backButtonRadius),
          boxShadow: const [
            BoxShadow(
              color: AppColors.backShadow,
              offset: Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.backButtonRadius),
            onTap: onPressed,
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primaryOrange,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
