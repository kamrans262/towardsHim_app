import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../domain/models/home_models.dart';

class HomeRecentActivityCard extends StatelessWidget {
  const HomeRecentActivityCard({
    required this.activity,
    required this.onPressed,
    super.key,
  });

  final HomeRecentActivity activity;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('activity_${activity.id}'),
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
      child: AppContentCard(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                activity.imageAsset,
                width: AppSpacing.homeActivityThumb,
                height: AppSpacing.homeActivityThumb,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: AppTypography.cardTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${activity.type} · ${activity.status}',
                    style: AppTypography.homeSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (activity.showCompletedIcon)
              const CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryOrange,
                child: Icon(Icons.check_rounded, size: 17, color: AppColors.white),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: AppColors.secondaryText,
              ),
          ],
        ),
      ),
    );
  }
}
