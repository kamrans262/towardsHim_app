import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/models/content_media.dart';
import 'package:towards_him_app/features/listen/data/listen_demo_data.dart';
import 'package:towards_him_app/features/listen/domain/models/listen_audio_episode.dart';
import 'package:towards_him_app/features/listen/domain/models/listen_share_content.dart';
import 'package:towards_him_app/features/listen/presentation/screens/audio_player_screen.dart';
import 'package:towards_him_app/features/listen/presentation/services/narration_engine.dart';

class SilentNarration implements NarrationEngine {
  @override
  Future<void> start(String text, {
    required void Function(double) onProgress,
    required void Function() onComplete,
    required void Function(String) onError,
  }) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> seek(double fraction) async {}
  @override
  Future<void> setSpeed(double speed) async {}
  @override
  Future<void> stop() async {}
}

void main() {
  test('Share includes actual media URL only when one exists', () {
    final serverItem = ListenAudioEpisode.fromApi({
      'id': 19,
      'title': 'New Podcast',
      'description': 'A conversation about prayer.',
      'category': 'podcast',
      'audio_url': 'https://example.test/audio.mp3',
      'video_url': 'https://example.test/video.mp4',
      'media': const [],
    });
    final serverShare = ListenShareContent.forEpisode(serverItem);
    expect(serverShare.mediaUrl, 'https://example.test/video.mp4');
    expect(serverShare.message, contains('New Podcast'));
    expect(serverShare.message, contains('https://example.test/video.mp4'));
    expect(serverShare.message, endsWith('Toward HIM'));

    final demoShare = ListenShareContent.forEpisode(ListenDemoData.episodes.first);
    expect(demoShare.mediaUrl, isNull);
    expect(demoShare.message, contains('Toward HIM'));
    expect(demoShare.message, isNot(contains('example.test')));
  });

  test('Legacy media links are never mistaken for a fake episode permalink', () {
    final item = ListenAudioEpisode.fromApi({
      'id': 24,
      'title': 'Reflection',
      'description': 'Learn more.',
      'category': 'prayer',
      'audio_url': 'javascript:alert(1)',
      'media': [
        {'id': 1, 'type': 'text', 'text': 'Daily prayer'},
        {'id': 2, 'type': 'video', 'url': 'https://example.test/prayer.mp4'},
      ],
    });
    final share = ListenShareContent.forEpisode(item);
    expect(share.mediaUrl, 'https://example.test/prayer.mp4');
    expect(share.message, contains(share.mediaUrl!));
    expect(share.message, isNot(contains('javascript:')));
  });

  testWidgets('More Share invokes a native-share callback with a valid anchor', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? sharedText;
    Rect? shareOrigin;
    await tester.pumpWidget(MaterialApp(
      home: AudioPlayerScreen(
        episode: ListenDemoData.episodes.first,
        narrationEngine: SilentNarration(),
        shareAction: (text, origin) async {
          sharedText = text;
          shareOrigin = origin;
        },
      ),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('player_action_more')));
    await tester.tap(find.byKey(const Key('player_action_more')));
    await tester.pumpAndSettle();
    expect(find.text('More'), findsWidgets);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Copy Details'), findsOneWidget);
    await tester.tap(find.byKey(const Key('player_more_share')));
    await tester.pumpAndSettle();
    expect(sharedText, isNotNull);
    expect(sharedText, contains('Toward HIM'));
    expect(sharedText, contains(ListenDemoData.episodes.first.playerTitle));
    expect(shareOrigin, isNotNull);
    expect(shareOrigin!.width, greaterThan(0));
    expect(shareOrigin!.height, greaterThan(0));
    expect(find.text('Share'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('More copies actual episode details without a media URL', (tester) async {
    String? copied;
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text']?.toString();
      }
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await tester.pumpWidget(MaterialApp(
      home: AudioPlayerScreen(
        episode: ListenDemoData.episodes.first,
        narrationEngine: SilentNarration(),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('player_action_more')));
    await tester.tap(find.byKey(const Key('player_action_more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('player_more_copy')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(copied, contains(ListenDemoData.episodes.first.playerTitle));
    expect(copied, contains('Toward HIM'));
    expect(tester.takeException(), isNull);
  });
  testWidgets('Text-only Listen items expose Share without audio controls',
      (tester) async {
    final episode = ListenAudioEpisode.fromApi({
      'id': 7,
      'category': 'meditation',
      'title': 'Reading Reflection',
      'description': 'Be mindful and pray.',
      'media': const [
        {'id': 20, 'type': 'text', 'text': 'A quiet moment'},
      ],
    });
    String? shared;
    await tester.pumpWidget(MaterialApp(
      home: AudioPlayerScreen(
        episode: episode,
        shareAction: (text, position) async {
          shared = text;
        },
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('player_action_more')), findsOneWidget);
    expect(find.byKey(const Key('player_primary_play')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('player_action_more')));
    await tester.tap(find.byKey(const Key('player_action_more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('player_more_share')));
    await tester.pumpAndSettle();
    expect(shared, contains('Reading Reflection'));
    expect(shared, contains('Be mindful and pray.'));
    expect(tester.takeException(), isNull);
  });

}
