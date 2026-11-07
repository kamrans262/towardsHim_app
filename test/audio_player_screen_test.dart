import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/theme/app_typography.dart';
import 'package:towards_him_app/core/widgets/app_audio_progress_bar.dart';
import 'package:towards_him_app/core/widgets/app_audio_seek_bar.dart';
import 'package:towards_him_app/core/widgets/app_back_button.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_circular_play_button.dart';
import 'package:towards_him_app/core/widgets/app_content_type_tag.dart';
import 'package:towards_him_app/features/listen/data/listen_demo_data.dart';
import 'package:towards_him_app/features/listen/presentation/controllers/audio_player_ui_controller.dart';
import 'package:towards_him_app/features/listen/presentation/screens/audio_player_screen.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/player_playback_controls.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/player_secondary_action.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/player_skip_button.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/player_time_row.dart';

void main() {
  final demoEpisode = ListenDemoData.episodes.first;

  test('Player state starts paused-icon and handles bounded local seeking', () {
    final controller = AudioPlayerUiController(demoEpisode);
    addTearDown(controller.dispose);
    expect(controller.isPlaying, true);
    expect(controller.currentTime, '12:30');
    expect(controller.totalTime, '24:00');
    expect(demoEpisode.durationMinutes, 28);
    expect(controller.positionSeconds, 750);
    controller.skipSeconds(-10);
    expect(controller.currentTime, '12:20');
    controller.skipSeconds(10);
    expect(controller.currentTime, '12:30');
    controller.skipSeconds(-99999);
    expect(controller.positionSeconds, 0);
    controller.skipSeconds(99999);
    expect(controller.positionSeconds, 1440);
    controller.seekFraction(0.5);
    expect(controller.currentTime, '12:00');
    controller.togglePlayPause();
    expect(controller.isPlaying, false);
    controller.setSpeed(1.5);
    expect(controller.speed, 1.5);
  });

  testWidgets('Player header and supplied cover follow the 430px Figma',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: AudioPlayerScreen(episode: demoEpisode),
    ));
    await tester.pumpAndSettle();

    final header = tester.getRect(find.text('Player'));
    expect(header.center.dx, closeTo(215, 0.1));
    final back = tester.getRect(find.byType(AppBackButton));
    expect(back.width, 48);
    expect(back.height, 48);
    expect(back.left, closeTo(20, 0.1));
    expect(AppTypography.mainScreenTitle.fontFamily, 'DMSans');
    expect(AppTypography.mainScreenTitle.fontSize, 24);
    final cover = tester.getRect(find.byKey(const Key('player_cover_image')));
    expect(cover.width, closeTo(390, 0.1));
    expect(cover.height, closeTo(237, 0.1));
    expect(cover.left, closeTo(20, 0.1));
    expect(cover.top - back.bottom, closeTo(20, 0.1));
    final image = tester.widget<Image>(
      find.byKey(const Key('player_cover_image')),
    );
    expect((image.image as AssetImage).assetName, demoEpisode.coverAsset);
    expect(image.fit, BoxFit.cover);
    final clips = tester.widgetList<ClipRRect>(
      find.ancestor(
        of: find.byKey(const Key('player_cover_image')),
        matching: find.byType(ClipRRect),
      ),
    );
    expect(
      clips.any((clip) =>
          clip.borderRadius == BorderRadius.circular(20)),
      isTrue,
    );
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Player shows episode data, typography, tag, time and progress',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AudioPlayerScreen(episode: demoEpisode),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Finding hope in difficult seasons'), findsOneWidget);
    expect(find.text('28 min'), findsOneWidget);
    expect(find.text(demoEpisode.playerDescription!), findsOneWidget);
    expect(find.text('Podcast'), findsOneWidget);
    final tag = tester.widget<AppContentTypeTag>(
      find.byType(AppContentTypeTag),
    );
    expect(tag.label, 'Podcast');
    expect(AppTypography.playerTag.fontSize, 12);
    expect(AppTypography.playerTag.color, AppColors.primaryOrange);
    expect(AppTypography.sectionHeading.fontSize, 18);
    expect(find.byType(AppAudioProgressBar), findsOneWidget);
    final progress = tester.getRect(find.byType(AppAudioProgressBar));
    expect(progress.height, 5);
    final times = tester.widget<PlayerTimeRow>(find.byType(PlayerTimeRow));
    expect(times.current, '12:30');
    expect(times.total, '24:00');
    expect(AppTypography.playerTime.fontSize, 12);
  });

  testWidgets('Player seek, rewind, forward and play/pause stay UI-only',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: AudioPlayerScreen(episode: demoEpisode),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerSkipButton), findsNWidgets(2));
    final primary = tester.widget<AppCircularPlayButton>(
      find.byKey(const Key('player_primary_play')),
    );
    expect(primary.diameter, 70);
    expect(primary.isPlaying, true);
    await tester.tap(find.byKey(const Key('player_forward')));
    await tester.pump();
    expect(find.text('12:40'), findsOneWidget);
    await tester.tap(find.byKey(const Key('player_rewind')));
    await tester.pump();
    expect(find.text('12:30'), findsOneWidget);

    final seek = tester.getRect(find.byKey(const Key('player_seek_bar')));
    await tester.tapAt(Offset(seek.left + seek.width * 0.25, seek.center.dy));
    await tester.pump();
    expect(find.text('06:00'), findsOneWidget);
    await tester.tap(find.byKey(const Key('player_primary_play')));
    await tester.pump();
    expect(tester.widget<AppCircularPlayButton>(
      find.byKey(const Key('player_primary_play')),
    ).isPlaying, false);
  });

  testWidgets('Secondary actions use supplied icons and local bottom sheets',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AudioPlayerScreen(episode: demoEpisode),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerSecondaryAction), findsNWidgets(3));
    expect(
      tester.widgetList<PlayerSecondaryAction>(
        find.byType(PlayerSecondaryAction),
      ).map((action) => action.label),
      ['Speed', 'Download', 'More'],
    );
    await tester.ensureVisible(find.byKey(const Key('player_action_speed')));
    await tester.tap(find.byKey(const Key('player_action_speed')));
    await tester.pumpAndSettle();
    expect(find.text('Playback Speed'), findsOneWidget);
    expect(find.text('1.5×'), findsOneWidget);
    await tester.tap(find.text('1.5×'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('player_action_download')));
    await tester.pump();
    expect(
      find.text('Downloading will be available after the UI phase.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('player_action_more')));
    await tester.pumpAndSettle();
    expect(
      find.text('Additional player options will be available in a later phase.'),
      findsOneWidget,
    );
  });

  testWidgets('Selected Listen episode opens Player and back restores Listen',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.tap(find.byKey(const Key('nav_Listen')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppCircularPlayButton).first);
    await tester.pumpAndSettle();
    final player = tester.widget<AudioPlayerScreen>(
      find.byType(AudioPlayerScreen),
    );
    expect(player.episode.id, demoEpisode.id);
    expect(find.byType(AppBottomNavigation), findsNothing);
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(tester.widget<AppBottomNavigation>(
      find.byType(AppBottomNavigation),
    ).selectedIndex, 1);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Player remains responsive at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        home: AudioPlayerScreen(episode: demoEpisode),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(PlayerPlaybackControls), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('player_action_more')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AppAudioSeekBar), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);
    });
  }
}
