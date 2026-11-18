import 'support/fake_challenge_repository.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:towards_him_app/core/models/content_media.dart';
import 'package:towards_him_app/core/widgets/app_audio_seek_bar.dart';
import 'package:towards_him_app/core/widgets/app_content_media_view.dart';
import 'package:towards_him_app/features/listen/presentation/screens/audio_player_screen.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/player_playback_controls.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/player_secondary_action.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/widgets/app_back_button.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/weekly_challenges/data/daily_challenge_demo_data.dart';
import 'package:towards_him_app/features/weekly_challenges/domain/models/daily_challenge.dart';
import 'package:towards_him_app/features/weekly_challenges/presentation/screens/daily_challenge_screen.dart';
import 'package:towards_him_app/features/weekly_challenges/presentation/widgets/daily_challenge_option_card.dart';

void main() {
  testWidgets('Published day video reuses compact Listen Player controls and displays activity once', (tester) async {
    const dayText = 'Spend five minutes in prayer this morning.';
    const challenge = DailyChallenge(
      id: 'weekly-4-day-2',
      subtitle: 'Day 2 – Daily Challenge',
      title: 'Faith and Patience',
      description: dayText,
      options: [],
      initialSelectedOptionId: 'share',
      media: [
        ContentMedia(
          id: 'video-1',
          type: ContentMediaType.video,
          url: 'https://example.test/day-two.mp4',
          text: 'Extra media caption that should not repeat the activity',
        ),
        ContentMedia(
          id: 'text-1',
          type: ContentMediaType.text,
          text: dayText,
        ),
      ],
    );
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
      home: DailyChallengeScreen(challenge: challenge),
    ));
    await tester.pump();
    expect(find.byType(AudioPlayerScreen), findsOneWidget);
    expect(tester.widget<AudioPlayerScreen>(find.byType(AudioPlayerScreen)).embedded, isTrue);
    expect(find.byKey(const Key('daily_challenge_embedded_player')), findsOneWidget);
    expect(find.byType(PlayerPlaybackControls), findsOneWidget);
    expect(find.byType(AppAudioSeekBar), findsOneWidget);
    expect(find.byType(VideoProgressIndicator), findsNothing);
    expect(find.byKey(const Key('player_cover_video_action')), findsNothing);
    expect(find.byType(PlayerSecondaryAction), findsNWidgets(3));
    expect(find.text(dayText), findsOneWidget);
    expect(find.text('Extra media caption that should not repeat the activity'), findsNothing);
    expect(find.text('Player'), findsNothing);
    expect(find.text('Multimedia content'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Day with playable audio shows the existing bottom controls and no duplicate text', (tester) async {
    const description = 'Listen to the prayer and reflect.';
    const challenge = DailyChallenge(
      id: 'weekly-4-day-3',
      subtitle: 'Day 3 – Daily Challenge',
      title: 'Time to Listen',
      description: description,
      options: [],
      initialSelectedOptionId: 'share',
      media: [
        ContentMedia(
          id: 'audio-1',
          type: ContentMediaType.audio,
          url: 'https://example.test/day-three.mp3',
          text: description,
        ),
        ContentMedia(
          id: 'text-1',
          type: ContentMediaType.text,
          text: description,
        ),
      ],
    );
    await tester.pumpWidget(const MaterialApp(
      home: DailyChallengeScreen(challenge: challenge),
    ));
    await tester.pump();
    expect(find.byType(AudioPlayerScreen), findsOneWidget);
    expect(find.byType(PlayerPlaybackControls), findsOneWidget);
    expect(find.byType(AppAudioSeekBar), findsOneWidget);
    expect(find.text(description), findsOneWidget);
    expect(find.byType(PlayerSecondaryAction), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Text-only day retains approved layout without adding audio controls or repeating text', (tester) async {
    const description = 'Give thanks for three blessings today.';
    const challenge = DailyChallenge(
      id: 'weekly-4-day-4',
      subtitle: 'Day 4 – Daily Challenge',
      title: 'Gratitude',
      description: description,
      options: [],
      initialSelectedOptionId: 'share',
      media: [
        ContentMedia(
          id: 'duplicate',
          type: ContentMediaType.text,
          text: description,
        ),
      ],
    );
    await tester.pumpWidget(const MaterialApp(
      home: DailyChallengeScreen(challenge: challenge),
    ));
    await tester.pumpAndSettle();
    expect(find.text(description), findsOneWidget);
    expect(find.byType(AudioPlayerScreen), findsNothing);
    expect(find.byType(AppContentMediaView), findsNothing);
    expect(find.byType(PlayerPlaybackControls), findsNothing);
    expect(tester.takeException(), isNull);
  });

  Future<void> openDaily(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomeShellScreen(challengeRepository: FakeChallengeRepository()),
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.tap(find.byKey(const Key('nav_Towards HIM 3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('weekly_card_weekly-current')));
    await tester.pumpAndSettle();
    final day = find.byKey(const Key('weekly_day_open_3'));
    await tester.ensureVisible(day);
    await tester.pumpAndSettle();
    await tester.tap(day);
    await tester.pumpAndSettle();
  }

  test('Daily Challenge local fixture matches approved content', () {
    final challenge = DailyChallengeDemoData.october8;
    expect(challenge.subtitle, 'October 8 – Daily Challenge');
    expect(challenge.title, 'Taste, See or Share');
    expect(challenge.options.map((option) => option.id).toList(),
        <String>['taste', 'see', 'share']);
    expect(challenge.initialSelectedOptionId, 'share');
  });

  testWidgets('Weekly activity opens Daily screen, back restores Weekly', (tester) async {
    await openDaily(tester);
    expect(find.byType(DailyChallengeScreen), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Day 3 – Daily Challenge'), findsOneWidget);
    expect(find.text('Toward HIM 3'), findsOneWidget);
    final rounded = tester.widget<Container>(
      find.byKey(const Key('challenge_detail_rounded_container')),
    );
    expect(rounded.padding, const EdgeInsets.only(top: 20));
    // The image/content transition is exactly 80px below the button.
    final buttonRect = tester.getRect(find.byType(AppBackButton));
    final containerRect = tester.getRect(
      find.byKey(const Key('challenge_detail_rounded_container')),
    );
    expect(
      containerRect.top - buttonRect.bottom,
      closeTo(AppSpacing.weeklyBackToContainerGap, 0.1),
    );
    final decoration = rounded.decoration! as BoxDecoration;
    expect(
      decoration.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(20)),
    );
 
    expect(find.byType(DailyChallengeOptionCard), findsNWidgets(3));
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(DailyChallengeScreen), findsNothing);
    expect(find.text('Daily Activities'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Selection is exclusive and responds to taps', (tester) async {
    await openDaily(tester);
    final cards = tester.widgetList<DailyChallengeOptionCard>(
      find.byType(DailyChallengeOptionCard),
    ).toList();
    expect(cards.map((card) => card.selected).toList(), <bool>[false, false, true]);
    await tester.tap(find.byKey(const Key('daily_option_taste')));
    await tester.pumpAndSettle();
    final updated = tester.widgetList<DailyChallengeOptionCard>(
      find.byType(DailyChallengeOptionCard),
    ).toList();
    expect(updated.map((card) => card.selected).toList(), <bool>[true, false, false]);
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Daily Challenge adapts at ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openDaily(tester);
      expect(find.byKey(const Key('daily_challenge_scroll')), findsOneWidget);
      expect(find.byType(DailyChallengeOptionCard), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  }
}
