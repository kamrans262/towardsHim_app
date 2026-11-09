import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_back_button.dart';

/// Shared centered detail-page heading (Create Post, Post Replies).
class AppDetailPageHeader extends StatelessWidget {
  const AppDetailPageHeader({
    required this.title,
    required this.onBack,
    this.titleKey,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final Key? titleKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.backButtonSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppBackButton(onPressed: onBack),
          ),
          IgnorePointer(
            child: Text(
              title,
              key: titleKey,
              style: AppTypography.mainScreenTitle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
