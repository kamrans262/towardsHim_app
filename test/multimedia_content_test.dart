import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:towards_him_app/core/models/content_media.dart';
import 'package:towards_him_app/core/widgets/app_content_media_view.dart';
import 'package:towards_him_app/features/listen/domain/models/listen_audio_episode.dart';
import 'package:towards_him_app/features/listen/presentation/screens/audio_player_screen.dart';
import 'package:towards_him_app/features/weekly_challenges/domain/models/weekly_challenge.dart';

void main() {
  test('Listen media parser accepts mixed blocks and preserves playback links', () {
    final episode = ListenAudioEpisode.fromApi({
      'id': 17,
      'category': 'prayer',
      'title': 'A Multimedia Prayer',
      'description': 'Reflect and pray.',
      'duration_seconds': null,
      'audio_url': null,
      'artwork_url': null,
      'media': [
        {'id': 1, 'type': 'text', 'text': 'Read this reflection.', 'url': null},
        {'id': 2, 'type': 'image', 'text': 'Cover', 'url': 'https://example.test/image.png'},
        {'id': 3, 'type': 'audio', 'text': 'Listen', 'url': 'https://example.test/audio.mp3'},
        {'id': 4, 'type': 'video', 'text': 'Watch', 'url': 'https://example.test/video.mp4'},
      ],
    });
    expect(episode.media.length, 4);
    expect(episode.media.map((m) => m.type), [
      ContentMediaType.text,
      ContentMediaType.image,
      ContentMediaType.audio,
      ContentMediaType.video,
    ]);
    expect(episode.audioUrl, 'https://example.test/audio.mp3');
    expect(episode.artworkUrl, 'https://example.test/image.png');
    expect(episode.media[0].text, 'Read this reflection.');
  });

  test('Weekly challenge parses media on both introduction and daily tasks', () {
    final challenge = WeeklyChallenge.fromApi({
      'id': 18,
      'title': 'Weekly',
      'instructions': 'Seven days',
      'is_current': true,
      'completed_days': 1,
      'total_days': 7,
      'start_date': '2026-11-16',
      'end_date': '2026-11-22',
      'media': [
        {'id': 10, 'type': 'video', 'text': 'Intro', 'url': 'https://example.test/intro.mp4'},
      ],
      'days': [
        {'day': 1, 'text': 'Reflect', 'completed': true, 'media': [
          {'id': 11, 'type': 'audio', 'text': 'Listen', 'url': 'https://example.test/a.mp3'}
        ]},
        for (var i = 2; i <= 7; i++)
          {'day': i, 'text': 'Task $i', 'completed': false, 'media': []},
      ],
    });
    expect(challenge.media.single.type, ContentMediaType.video);
    expect(challenge.days.first.media.single.type, ContentMediaType.audio);
    expect(challenge.completedDayNumbers, {1});
  });

  testWidgets('Text-only Listen content opens without imaginary audio controls', (tester) async {
    final episode = ListenAudioEpisode.fromApi({
      'id': 5,
      'category': 'meditation',
      'title': 'Written Meditation',
      'description': 'A thoughtful reflection.',
      'media': [
        {'id': 42, 'type': 'text', 'text': 'Breathe gently and reflect.', 'url': null},
      ],
    });

    await tester.pumpWidget(MaterialApp(home: AudioPlayerScreen(episode: episode)));
    await tester.pumpAndSettle();
    expect(find.text('Breathe gently and reflect.'), findsOneWidget);
    expect(find.byType(AppContentMediaView), findsOneWidget);
    expect(find.text('Multimedia content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
