import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_audio_content_row.dart';
import '../../domain/models/listen_audio_episode.dart';

/// Transparent media row; no filled Home-card background.
class ListenAudioListItem extends StatelessWidget {
  const ListenAudioListItem({
    required this.episode,
    required this.isPlaying,
    required this.onPlayPressed,
    super.key,
  });

  final ListenAudioEpisode episode;
  final bool isPlaying;
  final VoidCallback onPlayPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: AppAudioContentRow(
        title: episode.title,
        description: episode.description,
        imageAsset: episode.thumbnailAsset,
        thumbnailSize: AppSpacing.listenThumbnailSize,
        isPlaying: isPlaying,
        onPlayPressed: onPlayPressed,
      ),
    );
  }
}
