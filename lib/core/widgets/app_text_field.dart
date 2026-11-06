import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.iconAsset,
    required this.controller,
    required this.focusNode,
    required this.keyboardType,
    required this.textInputAction,
    this.obscureText = false,
    this.autofillHints,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final String iconAsset;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppSpacing.fieldHeight),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.fieldHorizontalPadding,
        vertical: AppSpacing.fieldVerticalPadding,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconAsset,
            width: AppSpacing.fieldIconSize,
            height: AppSpacing.fieldIconSize,
          ),
          const SizedBox(width: AppSpacing.fieldIconGap),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              obscureText: obscureText,
              autocorrect: !obscureText,
              enableSuggestions: !obscureText,
              autofillHints: autofillHints,
              onSubmitted: onSubmitted,
              style: AppTypography.inputValue,
              cursorColor: AppColors.primaryOrange,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: label,
                hintStyle: AppTypography.inputPlaceholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
