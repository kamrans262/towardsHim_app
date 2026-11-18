import 'package:flutter/material.dart';

import 'player_secondary_action.dart';

/// One approved Speed / Download / More row, shared by Listen and Daily Challenge.
class PlayerSecondaryActions extends StatelessWidget {
  const PlayerSecondaryActions({
    required this.onSpeed,
    required this.onDownload,
    required this.onMore,
    super.key,
  });

  final VoidCallback onSpeed;
  final VoidCallback onDownload;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('player_secondary_actions'),
      children: [
        Expanded(
          child: PlayerSecondaryAction(
            label: 'Speed',
            pngAsset: 'assets/icons/player/playback_speed.png',
            onPressed: onSpeed,
          ),
        ),
        Expanded(
          child: PlayerSecondaryAction(
            label: 'Download',
            svgAsset: 'assets/icons/player/download.svg',
            onPressed: onDownload,
          ),
        ),
        Expanded(
          child: PlayerSecondaryAction(
            label: 'More',
            svgAsset: 'assets/icons/player/more.svg',
            onPressed: onMore,
          ),
        ),
      ],
    );
  }
}
