import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Search variant of the existing global input styling.
class AppSearchField extends StatelessWidget {
  const AppSearchField({required this.controller, required this.onChanged, super.key});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.outlinedButtonBackground,
          border: Border.all(color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.fieldHorizontalPadding),
          child: Row(
            children: [
              const Icon(Icons.search, size: 24, color: AppColors.primaryOrange),
              const SizedBox(width: AppSpacing.fieldIconGap),
              Expanded(
                child: TextField(
                  key: const Key('weekly_search'),
                  controller: controller,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  maxLines: 1,
                  style: AppTypography.inputValue,
                  cursorColor: AppColors.primaryOrange,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: AppTypography.inputPlaceholder,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
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
