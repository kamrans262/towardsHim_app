import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_audio_seek_bar.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_content_type_tag.dart';
import '../../domain/models/listen_audio_episode.dart';
import '../controllers/audio_player_ui_controller.dart';
import '../widgets/player_playback_controls.dart';
import '../widgets/player_secondary_action.dart';
import '../widgets/player_time_row.dart';

/// Full-screen, UI-only player for the audio episode selected on Listen.
class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({
    required this.episode,
    super.key,
  });

  final ListenAudioEpisode episode;

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late final AudioPlayerUiController _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayerUiController(widget.episode);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSpeedPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.screenBottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Playback Speed',
                  style: AppTypography.sectionHeading,
                ),
                const SizedBox(height: 15),
                for (final speed in const [0.75, 1.0, 1.25, 1.5, 2.0])
                  ListTile(
                    title: Text(
                      '$speed×',
                      style: AppTypography.quickAccessLabel,
                    ),
                    trailing: speed == _player.speed
                        ? const Icon(
                            Icons.check,
                            color: AppColors.primaryOrange,
                          )
                        : null,
                    onTap: () {
                      _player.setSpeed(speed);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('More', style: AppTypography.sectionHeading),
                const SizedBox(height: 20),
                const Text(
                  'Additional player options will be available in a later phase.',
                  textAlign: TextAlign.center,
                  style: AppTypography.homeSecondary,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final episode = widget.episode;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          key: const Key('player_scroll'),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.screenTop,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.homeContentMaxWidth -
                    2 * AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: AppSpacing.backButtonSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            'Player',
                            style: AppTypography.mainScreenTitle,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppBackButton(
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.playerHeaderToCover),
                  AspectRatio(
                    aspectRatio: AppSpacing.playerCoverAspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.playerCoverRadius,
                      ),
                      child: Image.asset(
                        episode.coverAsset ?? episode.thumbnailAsset,
                        key: const Key('player_cover_image'),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.playerCoverToTag),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppContentTypeTag(label: episode.contentType),
                  ),
                  const SizedBox(height: AppSpacing.playerTagToTitle),
                  Text(
                    episode.playerTitle ?? episode.title,
                    style: AppTypography.sectionHeading,
                  ),
                  const SizedBox(height: AppSpacing.playerTitleToDuration),
                  Text(
                    '${episode.durationMinutes} min',
                    style: AppTypography.homeSecondary,
                  ),
                  const SizedBox(height: AppSpacing.playerDurationToDescription),
                  Text(
                    episode.playerDescription ?? episode.description,
                    style: AppTypography.homeSecondary,
                  ),
                  const SizedBox(height: AppSpacing.playerDescriptionToProgress),
                  AnimatedBuilder(
                    animation: _player,
                    builder: (context, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppAudioSeekBar(
                            progress: _player.progress,
                            onChanged: _player.seekFraction,
                          ),
                          const SizedBox(height: AppSpacing.playerProgressToTimes),
                          PlayerTimeRow(
                            current: _player.currentTime,
                            total: _player.totalTime,
                          ),
                          const SizedBox(height: AppSpacing.playerTimesToControls),
                          PlayerPlaybackControls(
                            isPlaying: _player.isPlaying,
                            onToggle: _player.togglePlayPause,
                            onRewind: () => _player.skipSeconds(-10),
                            onForward: () => _player.skipSeconds(10),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.playerControlsToActions),
                  Row(
                    children: [
                      Expanded(
                        child: PlayerSecondaryAction(
                          label: 'Speed',
                          pngAsset: 'assets/icons/player/playback_speed.png',
                          onPressed: _showSpeedPicker,
                        ),
                      ),
                      Expanded(
                        child: PlayerSecondaryAction(
                          label: 'Download',
                          svgAsset: 'assets/icons/player/download.svg',
                          onPressed: () => _showNotice(
                            'Downloading will be available after the UI phase.',
                          ),
                        ),
                      ),
                      Expanded(
                        child: PlayerSecondaryAction(
                          label: 'More',
                          svgAsset: 'assets/icons/player/more.svg',
                          onPressed: _showMoreOptions,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
