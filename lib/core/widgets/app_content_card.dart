import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shared surface for content cards across Home and future modules.
class AppContentCard extends StatelessWidget {
  const AppContentCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.homeCardPadding),
    this.minHeight,
    this.backgroundColor = AppColors.outlinedButtonBackground,
    this.borderColor = AppColors.cardBorder,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? minHeight;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: minHeight == null
          ? null
          : BoxConstraints(minHeight: minHeight!),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
      ),
      child: child,
    );
  }
}
