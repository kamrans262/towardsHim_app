import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:towards_him_app/core/models/content_media.dart';
import 'package:towards_him_app/features/listen/domain/models/listen_audio_episode.dart';
import 'package:towards_him_app/features/listen/presentation/screens/audio_player_screen.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/listen_audio_list_item.dart';

const longDescription =
    'This podcast description contains many paragraphs of useful reflection '
    'and is deliberately long enough to occupy significantly more than three '
    'lines on a narrow phone display. The user should see a short preview on '
    'Listen, while the original complete description remains available on '
    'the player screen for the selected episode.';

void _noop() {}

void main() {
  testWidgets('Listen cards clamp only the description to three lines', (tester) async {
    const episode = ListenAudioEpisode(
      id: '1',
      title: 'What is Lorem Ipsum?',
      description: longDescription,
      thumbnailAsset: 'assets/images/home/golden_hour_meditation.webp',
      contentType: 'Podcast',
      durationMinutes: 0,
      playbackProgress: 0,
      isCompleted: false,
    );
    await tester.pumpWidget(MaterialApp(
      home: const Scaffold(
        body: ListenAudioListItem(
          episode: episode,
          isPlaying: false,
          onPlayPressed: _noop,
        ),
      ),
    ));
    final description = tester.widget<Text>(find.text(longDescription));
    expect(description.maxLines, 3);
    expect(description.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Detail screen keeps the full description', (tester) async {
    const episode = ListenAudioEpisode(
      id: '2',
      title: 'Reflection',
      description: longDescription,
      thumbnailAsset: 'assets/images/home/golden_hour_meditation.webp',
      contentType: 'Meditation',
      durationMinutes: 0,
      playbackProgress: 0,
      isCompleted: false,
    );
    await tester.pumpWidget(const MaterialApp(
      home: AudioPlayerScreen(episode: episode),
    ));
    final detail = tester.widget<Text>(find.text(longDescription));
    expect(detail.maxLines, isNull);
    expect(tester.takeException(), isNull);
  });

  test('Dedicated video URL joins existing player media without duplication', () {
    final episode = ListenAudioEpisode.fromApi({
      'id': 72,
      'category': 'prayer',
      'title': 'Morning Prayer',
      'description': 'Pray with us.',
      'audio_url': 'https://example.test/recording.mp3',
      'video_url': 'https://example.test/recording.mp4',
      'media': [],
    });
    expect(episode.audioUrl, 'https://example.test/recording.mp3');
    expect(episode.videoUrl, 'https://example.test/recording.mp4');
    expect(episode.media.length, 1);
    expect(episode.media.single.type, ContentMediaType.video);
    expect(episode.media.single.url, episode.videoUrl);

    final legacy = ListenAudioEpisode.fromApi({
      'id': 73,
      'category': 'podcast',
      'title': 'Legacy',
      'description': 'Older item',
      'video_url': 'https://example.test/recording.mp4',
      'media': [
        {'id': 10, 'type': 'video', 'url': 'https://example.test/recording.mp4'},
        {'id': 11, 'type': 'text', 'text': 'Legacy text'},
      ],
    });
    expect(legacy.media.length, 2);
    expect(legacy.media.where((item) => item.type == ContentMediaType.video).length, 1);
  });
}
