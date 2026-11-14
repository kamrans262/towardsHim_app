import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/widgets/app_audio_thumbnail.dart';
import 'package:towards_him_app/core/widgets/app_circular_play_button.dart';
import 'package:towards_him_app/core/widgets/app_main_screen_header.dart';
import 'package:towards_him_app/features/listen/data/audio_catalog_repository.dart';
import 'package:towards_him_app/features/listen/domain/models/listen_audio_episode.dart';
import 'package:towards_him_app/features/listen/presentation/screens/listen_screen.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/listen_audio_list_item.dart';

class SampleRepository extends AudioCatalogRepository {
  const SampleRepository(this.items);
  final List<ListenAudioEpisode> items;
  @override
  Future<List<ListenAudioEpisode>> fetchPublished() async => items;
}

const samples = <ListenAudioEpisode>[
  ListenAudioEpisode(
    id: '11', title: 'Gratitude', description: 'Weekly reflections',
    thumbnailAsset: 'assets/images/home/golden_hour_meditation.webp',
    contentType: 'Podcast', durationMinutes: 24,
    playbackProgress: 0, isCompleted: false,
  ),
  ListenAudioEpisode(
    id: '12', title: 'Peace', description: 'Guided meditation',
    thumbnailAsset: 'assets/images/home/golden_hour_meditation.webp',
    contentType: 'Meditation', durationMinutes: 12,
    playbackProgress: 0, isCompleted: false,
  ),
];

void main() {
  test('API audio maps into the existing episode model', () {
    final episode = ListenAudioEpisode.fromApi({
      'id': 55, 'category': 'podcast', 'title': 'Courage',
      'description': 'Finding courage', 'duration_seconds': 1540,
      'audio_url': 'https://example.com/storage/audio/courage.mp3',
      'artwork_url': null,
    });
    expect(episode.id, '55');
    expect(episode.contentType, 'Podcast');
    expect(episode.durationMinutes, 26);
    expect(episode.audioUrl, isNotNull);
    expect(episode.narrationText, isNull);
  });

  testWidgets('Listen retains approved headings, cards and audio row style', (tester) async {
    ListenAudioEpisode? opened;
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: ListenScreen(
        repository: const SampleRepository(samples),
        onNotice: (_) {},
        onOpenEpisode: (episode) => opened = episode,
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.byType(AppMainScreenHeader), findsOneWidget);
    expect(find.byType(ListenAudioListItem), findsNWidgets(2));
    expect(find.byType(AppAudioThumbnail), findsNWidgets(2));
    expect(
      tester.widget<AppAudioThumbnail>(find.byType(AppAudioThumbnail).first).size,
      AppSpacing.listenThumbnailSize,
    );
    expect(find.byType(AppCircularPlayButton), findsNWidgets(2));
    await tester.tap(find.byType(AppCircularPlayButton).first);
    expect(opened?.id, '11');
  });

  testWidgets('Quick access cards filter real content without redesign', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: ListenScreen(
        repository: const SampleRepository(samples),
        onNotice: (_) {},
        onOpenEpisode: (_) {},
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.byType(ListenAudioListItem), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('quick_Meditation')));
    await tester.pumpAndSettle();
    expect(find.byType(ListenAudioListItem), findsOneWidget);
    expect(find.text('Peace'), findsOneWidget);
    await tester.tap(find.byKey(const Key('quick_Meditation')));
    await tester.pumpAndSettle();
    expect(find.byType(ListenAudioListItem), findsNWidgets(2));
  });

  for (final size in [const Size(320, 568), const Size(430, 932), const Size(820, 1180)]) {
    testWidgets('Listen remains responsive at ' + size.width.toString(), (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: ListenScreen(
        repository: const SampleRepository(samples),
        onNotice: (_) {}, onOpenEpisode: (_) {},
      ))));
      await tester.pumpAndSettle();
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
