import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_circular_play_button.dart';
import 'player_skip_button.dart';

class PlayerPlaybackControls extends StatelessWidget {
  const PlayerPlaybackControls({
    required this.isPlaying,
    required this.onToggle,
    required this.onRewind,
    required this.onForward,
    super.key,
  });

  final bool isPlaying;
  final VoidCallback onToggle;
  final VoidCallback onRewind;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PlayerSkipButton(
          direction: PlayerSkipDirection.backward,
          onPressed: onRewind,
        ),
        const SizedBox(width: AppSpacing.playerControlGap),
        AppCircularPlayButton(
          key: const Key('player_primary_play'),
          isPlaying: isPlaying,
          onPressed: onToggle,
          diameter: AppSpacing.playerMainPlayDiameter,
          iconSize: AppSpacing.playerMainPlayIcon,
        ),
        const SizedBox(width: AppSpacing.playerControlGap),
        PlayerSkipButton(
          direction: PlayerSkipDirection.forward,
          onPressed: onForward,
        ),
      ],
    );
  }
}
