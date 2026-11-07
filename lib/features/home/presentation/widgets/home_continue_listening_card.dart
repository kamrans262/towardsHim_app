import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_audio_progress_bar.dart';
import '../../../../core/widgets/app_circular_play_button.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../domain/models/home_models.dart';

class HomeContinueListeningCard extends StatelessWidget {
  const HomeContinueListeningCard({
    required this.audio,
    required this.isPlaying,
    required this.onPlayPressed,
    super.key,
  });

  final HomeListeningProgress audio;
  final bool isPlaying;
  final VoidCallback onPlayPressed;

  @override
  Widget build(BuildContext context) {
    return AppContentCard(
      child: Row(
        children: [
          Container(
            width: AppSpacing.homeContinueThumb,
            height: AppSpacing.homeContinueThumb,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.backShadow,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(audio.imageAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audio.title,
                  style: AppTypography.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '${audio.type} · ${audio.minutesRemaining} min left',
                  style: AppTypography.homeSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                AppAudioProgressBar(progress: audio.progress),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AppCircularPlayButton(
            isPlaying: isPlaying,
            onPressed: onPlayPressed,
          ),
        ],
      ),
    );
  }
}
