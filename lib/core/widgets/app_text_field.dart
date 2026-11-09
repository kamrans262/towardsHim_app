import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Existing global input, with optional no-icon and 58px reply variations.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.keyboardType,
    required this.textInputAction,
    this.iconAsset,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.fieldKey,
    this.obscureText = false,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    super.key,
  });

  final String label;
  final String? iconAsset;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final Key? fieldKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints: height == null
          ? const BoxConstraints(minHeight: AppSpacing.fieldHeight)
          : null,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.background,
        border: Border.all(color: borderColor ?? AppColors.inputBorder),
        borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.fieldHorizontalPadding,
        vertical: height == null ? AppSpacing.fieldVerticalPadding : 0,
      ),
      child: Row(
        children: [
          if (iconAsset != null) ...[
            SvgPicture.asset(
              iconAsset!,
              width: AppSpacing.fieldIconSize,
              height: AppSpacing.fieldIconSize,
            ),
            const SizedBox(width: AppSpacing.fieldIconGap),
          ],
          Expanded(
            child: TextField(
              key: fieldKey,
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              obscureText: obscureText,
              autocorrect: !obscureText,
              enableSuggestions: !obscureText,
              autofillHints: autofillHints,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
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
