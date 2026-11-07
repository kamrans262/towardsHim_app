import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../domain/models/weekly_challenge.dart';

/// One reusable card for current, completed and previous challenges.
class WeeklyChallengeCard extends StatelessWidget {
  const WeeklyChallengeCard({
    required this.challenge,
    this.compact = false,
    this.onPressed,
    super.key,
  });

  final WeeklyChallenge challenge;
  final bool compact;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isCurrent = challenge.status == WeeklyChallengeStatus.current;
    return Semantics(
      button: onPressed != null,
      label: challenge.title + ', ' + challenge.progressLabel,
      child: InkWell(
        key: Key('weekly_card_' + challenge.id),
        borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
        onTap: onPressed,
        child: AppContentCard(
          padding: const EdgeInsets.all(AppSpacing.weeklyCardPadding),
          backgroundColor: !compact && isCurrent
              ? AppColors.podcastTile
              : AppColors.outlinedButtonBackground,
          borderColor: !compact && isCurrent
              ? AppColors.weeklyCurrentBorder
              : AppColors.cardBorder,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
                child: Image.asset(
                  challenge.imageAsset,
                  key: Key('weekly_image_' + challenge.id),
                  width: compact
                      ? AppSpacing.weeklyCompactThumbnail
                      : AppSpacing.weeklyThumbnail,
                  height: compact
                      ? AppSpacing.weeklyCompactThumbnail
                      : AppSpacing.weeklyThumbnail,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppSpacing.weeklyImageGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!compact) ...[
                      Text(
                        isCurrent ? 'Current' : 'Completed',
                        style: AppTypography.playerTag.copyWith(
                          color: isCurrent
                              ? AppColors.primaryOrange
                              : AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(challenge.title, style: AppTypography.cardTitle),
                    const SizedBox(height: 8),
                    Text(
                      challenge.datesLabel,
                      style: AppTypography.homeSecondary.copyWith(height: 1),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      Text(
                        challenge.description,
                        style: AppTypography.homeSecondary,
                      ),
                    ],
                    const SizedBox(height: 8),
                    AppProgressBar(
                      progress: challenge.progress,
                      height: AppSpacing.weeklyProgressHeight,
                      semanticsLabel: challenge.title + ' challenge progress',
                    ),
                    const SizedBox(height: AppSpacing.weeklyProgressLabelGap),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        challenge.progressLabel,
                        textAlign: TextAlign.right,
                        style: AppTypography.playerTime.copyWith(
                          fontWeight: FontWeight.w400,
                          fontVariations: const [FontVariation('wght', 400)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
