import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import 'app_audio_progress_bar.dart';
import 'app_audio_thumbnail.dart';
import 'app_circular_play_button.dart';

/// Configurable media row shared by the filled Home card and transparent
/// Listen list. The caller controls its outer surface and divider style.
class AppAudioContentRow extends StatelessWidget {
  const AppAudioContentRow({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.thumbnailSize,
    required this.isPlaying,
    required this.onPlayPressed,
    this.progress,
    this.withThumbnailShadow = false,
    super.key,
  });

  final String title;
  final String description;
  final String imageAsset;
  final double thumbnailSize;
  final bool isPlaying;
  final VoidCallback onPlayPressed;
  final double? progress;
  final bool withThumbnailShadow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAudioThumbnail(
          imageAsset: imageAsset,
          size: thumbnailSize,
          withShadow: withThumbnailShadow,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTypography.cardTitle,
                maxLines: progress == null ? null : 2,
                overflow: progress == null
                    ? TextOverflow.clip
                    : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: AppTypography.homeSecondary,
                maxLines: progress == null ? null : 1,
                overflow: progress == null
                    ? TextOverflow.clip
                    : TextOverflow.ellipsis,
              ),
              if (progress != null) ...[
                const SizedBox(height: 5),
                AppAudioProgressBar(progress: progress!),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        AppCircularPlayButton(
          isPlaying: isPlaying,
          onPressed: onPlayPressed,
        ),
      ],
    );
  }
}
