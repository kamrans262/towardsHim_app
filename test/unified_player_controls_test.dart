import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';

import 'package:towards_him_app/core/widgets/app_audio_seek_bar.dart';
import 'package:towards_him_app/core/widgets/app_circular_play_button.dart';
import 'package:towards_him_app/features/listen/domain/models/listen_audio_episode.dart';
import 'package:towards_him_app/features/listen/presentation/models/video_playback_snapshot.dart';
import 'package:towards_him_app/features/listen/presentation/screens/audio_player_screen.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/listen_media_carousel.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/player_playback_controls.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/player_secondary_action.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/player_time_row.dart';

const videoOnly = ListenAudioEpisode(
  id: 'new-video',
  title: 'Prayer Video',
  description: 'Watch the morning prayer.',
  thumbnailAsset: 'assets/images/home/golden_hour_meditation.webp',
  contentType: 'Prayer',
  durationMinutes: 0,
  playbackProgress: 0,
  isCompleted: false,
  videoUrl: 'https://example.test/morning-prayer.mp4',
);

void main() {
  test('Video progress/time/seek use the same 5px bar semantics as audio', () {
    const state = VideoPlaybackSnapshot(
      position: Duration(seconds: 75),
      duration: Duration(seconds: 150),
      isPlaying: true,
      isReady: true,
    );
    expect(state.progress, 0.5);
    expect(state.currentTime, '01:15');
    expect(state.totalTime, '02:30');
    expect(state.seekToFraction(0.2), const Duration(seconds: 30));
    expect(state.seekToFraction(2), const Duration(seconds: 150));
    expect(state.skipSeconds(-10), const Duration(seconds: 65));
    expect(state.skipSeconds(10), const Duration(seconds: 85));
    expect(state.skipSeconds(-1000), Duration.zero);
    expect(state.skipSeconds(1000), const Duration(seconds: 150));
  });

  test('Video UI state is comparable and handles unknown duration', () {
    const a = VideoPlaybackSnapshot();
    const b = VideoPlaybackSnapshot();
    expect(a, b);
    expect(a.progress, 0);
    expect(a.currentTime, '00:00');
    expect(a.totalTime, '00:00');
    expect(a.skipSeconds(10), Duration.zero);
    expect(a.seekToFraction(0.7), Duration.zero);
  });

  testWidgets('Video-only Player uses the existing bottom progress and buttons',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AudioPlayerScreen(episode: videoOnly),
    ));
    await tester.pump();

    expect(find.byType(ListenMediaCarousel), findsOneWidget);
    expect(find.byType(PlayerPlaybackControls), findsOneWidget);
    expect(find.byType(AppAudioSeekBar), findsOneWidget);
    expect(find.byType(PlayerTimeRow), findsOneWidget);
    expect(find.byType(VideoProgressIndicator), findsNothing);
    expect(find.byKey(const Key('player_cover_video_action')), findsNothing);
    expect(find.byKey(const Key('player_primary_play')), findsOneWidget);
    expect(find.byType(AppCircularPlayButton), findsOneWidget);
    expect(tester.widget<AppCircularPlayButton>(
      find.byKey(const Key('player_primary_play')),
    ).isPlaying, false);
    expect(find.byKey(const Key('player_action_more')), findsOneWidget);
    expect(find.byType(PlayerSecondaryAction), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unavailable video keeps shared controls and shows feedback',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AudioPlayerScreen(episode: videoOnly),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.ensureVisible(find.byKey(const Key('player_primary_play')));
    await tester.tap(find.byKey(const Key('player_primary_play')));
    await tester.pump();
    expect(find.byType(PlayerPlaybackControls), findsOneWidget);
    expect(find.textContaining('Video'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
