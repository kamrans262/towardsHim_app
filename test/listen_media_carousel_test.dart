import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:towards_him_app/core/models/content_media.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/widgets/app_content_media_view.dart';
import 'package:towards_him_app/features/listen/domain/models/listen_audio_episode.dart';
import 'package:towards_him_app/features/listen/presentation/screens/audio_player_screen.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/listen_media_carousel.dart';

ListenAudioEpisode sample({
  String? image,
  String? video,
  String? audio,
  String? narration,
  List<ContentMedia> extra = const [],
}) => ListenAudioEpisode(
  id: '12',
  title: 'Daily Reflection',
  description: 'Full reflection text',
  thumbnailAsset: 'assets/images/home/golden_hour_meditation.webp',
  coverAsset: 'assets/images/player/golden_mountain_valleys_dusk.webp',
  contentType: 'Prayer',
  durationMinutes: 1,
  playbackProgress: 0,
  isCompleted: false,
  artworkUrl: image,
  videoUrl: video,
  audioUrl: audio,
  narrationText: narration,
  media: extra,
);

void main() {
  test('Compact day player starts on playable media instead of optional artwork', () {
    final slides = ListenMediaSlide.forEpisode(sample(
      image: 'https://example.test/day.png',
      video: 'https://example.test/day.mp4',
      audio: 'https://example.test/day.mp3',
    ));
    expect(ListenMediaCarouselState.preferredSlideIndex(slides), 1);
    expect(ListenMediaCarouselState.preferredSlideIndex(
      ListenMediaSlide.forEpisode(sample(
        image: 'https://example.test/day.png',
        audio: 'https://example.test/day.mp3',
      )),
    ), 1);
    expect(ListenMediaCarouselState.preferredSlideIndex(
      ListenMediaSlide.forEpisode(sample()),
    ), 0);
  });

  test('All three media types share a single cover in artwork-video-audio order', () {
    final slides = ListenMediaSlide.forEpisode(sample(
      image: 'https://example.test/artwork.png',
      video: 'https://example.test/video.mp4',
      audio: 'https://example.test/audio.mp3',
    ));
    expect(slides.map((slide) => slide.kind).toList(), [
      ListenMediaKind.artwork,
      ListenMediaKind.video,
      ListenMediaKind.audio,
    ]);
    expect(slides.map((slide) => slide.url).toList(), [
      'https://example.test/artwork.png',
      'https://example.test/video.mp4',
      null,
    ]);
  });

  test('Only available media is offered; legacy video is not duplicated', () {
    final videoOnly = ListenMediaSlide.forEpisode(
      sample(video: 'https://example.test/video.mp4'),
    );
    expect(videoOnly.length, 1);
    expect(videoOnly.first.kind, ListenMediaKind.video);

    final audioOnly = ListenMediaSlide.forEpisode(
      sample(audio: 'https://example.test/audio.mp3'),
    );
    expect(audioOnly.length, 1);
    expect(audioOnly.single.kind, ListenMediaKind.audio);

    final legacy = ListenMediaSlide.forEpisode(sample(
      image: 'https://example.test/artwork.png',
      video: 'https://example.test/video.mp4',
      audio: 'https://example.test/audio.mp3',
      extra: const [
        ContentMedia(
          id: '5',
          type: ContentMediaType.video,
          url: 'https://example.test/video.mp4',
        ),
        ContentMedia(
          id: '6',
          type: ContentMediaType.image,
          url: 'https://example.test/artwork.png',
        ),
      ],
    ));
    expect(legacy.length, 3);
    expect(legacy.where((slide) => slide.kind == ListenMediaKind.video).length, 1);

    // The approved cover still exists for local demo and written-only content.
    expect(ListenMediaSlide.forEpisode(sample()).single.kind,
        ListenMediaKind.artwork);
  });

  testWidgets('Swiping cover shows headphones only on the audio page',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var videoStarted = 0;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AspectRatio(
              aspectRatio: AppSpacing.playerCoverAspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.playerCoverRadius),
                child: ListenMediaCarousel(
                  episode: sample(
                    image: 'https://example.test/artwork.png',
                    video: 'https://example.test/video.mp4',
                    narration: 'Example spoken demo narration',
                  ),
                  onVideoPlay: () => videoStarted++,
                ),
              ),
            ),
          ),
        ),
      ),
    ));

    expect(find.byKey(const Key('player_media_viewport')), findsOneWidget);
    expect(find.byKey(const Key('player_media_pager')), findsOneWidget);
    expect(find.byKey(const Key('player_cover_image')), findsOneWidget);
    expect(find.byKey(const Key('player_media_page_indicator')), findsOneWidget);

    await tester.drag(find.byKey(const Key('player_media_pager')), const Offset(-355, 0));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const Key('player_media_dot_1'))).width, 24);

    // Video is deliberately not auto-played after swiping, and tests do not
    // need a native video plugin to prove the page selection.
    expect(videoStarted, 0);

    await tester.drag(find.byKey(const Key('player_media_pager')), const Offset(-355, 0));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const Key('player_media_dot_2'))).width, 24);
    expect(find.byKey(const Key('player_cover_headphones')), findsOneWidget);
    expect(find.byKey(const Key('player_cover_audio_action')), findsNothing);
    expect(find.text('Audio'), findsNothing);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('Audio-only player cover displays only a centered headphone icon',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 280,
          child: ListenMediaCarousel(
            episode: sample(audio: 'https://example.test/clip.mp3'),
            onVideoPlay: () {},
          ),
        ),
      ),
    ));
    expect(find.byKey(const Key('player_cover_headphones')), findsOneWidget);
    expect(find.text('Audio'), findsNothing);
    expect(find.byKey(const Key('player_cover_audio_action')), findsNothing);
    expect(find.byKey(const Key('player_media_pager')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Video no longer renders in an extra card below the player',
      (tester) async {
    final episode = sample(
      video: 'https://example.test/video.mp4',
      extra: const [
        ContentMedia(id: '7', type: ContentMediaType.text, text: 'Read this as well.'),
        ContentMedia(
          id: '8',
          type: ContentMediaType.video,
          url: 'https://example.test/video.mp4',
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp(
      home: AudioPlayerScreen(episode: episode),
    ));
    await tester.pump();
    expect(find.byType(ListenMediaCarousel), findsOneWidget);
    expect(find.text('Read this as well.'), findsOneWidget);
    expect(find.byType(AppContentMediaView), findsOneWidget);
    expect(ListenMediaSlide.forEpisode(episode).length, 1);
    expect(tester.takeException(), isNull);
  });
}
