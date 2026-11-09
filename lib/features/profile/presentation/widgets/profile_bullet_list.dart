import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Shared indented bullet list with independent text wrapping and spacing.
class ProfileBulletList extends StatelessWidget {
  const ProfileBulletList({
    required this.items,
    this.itemGap = 5,
    super.key,
  });

  final List<String> items;
  final double itemGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) SizedBox(height: itemGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•',
                style: AppTypography.homeSecondary.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  items[index],
                  style: AppTypography.homeSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
