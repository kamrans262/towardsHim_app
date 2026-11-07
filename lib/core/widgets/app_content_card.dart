import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shared surface for content cards across Home and future modules.
class AppContentCard extends StatelessWidget {
  const AppContentCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.homeCardPadding),
    this.minHeight,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: minHeight == null
          ? null
          : BoxConstraints(minHeight: minHeight!),
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.outlinedButtonBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
      ),
      child: child,
    );
  }
}
