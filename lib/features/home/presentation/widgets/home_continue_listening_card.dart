import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_audio_content_row.dart';
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
      child: AppAudioContentRow(
        title: audio.title,
        description: '${audio.type} · ${audio.minutesRemaining} min left',
        imageAsset: audio.imageAsset,
        thumbnailSize: AppSpacing.homeContinueThumb,
        isPlaying: isPlaying,
        onPlayPressed: onPlayPressed,
        progress: audio.progress,
        withThumbnailShadow: true,
      ),
    );
  }
}
