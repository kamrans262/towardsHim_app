import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/theme/app_typography.dart';
import 'package:towards_him_app/core/widgets/app_audio_progress_bar.dart';
import 'package:towards_him_app/core/widgets/app_back_button.dart';
import 'package:towards_him_app/features/listen/data/audio_catalog_repository.dart';
import 'package:towards_him_app/features/listen/domain/models/listen_audio_episode.dart';
import 'package:towards_him_app/features/listen/presentation/screens/audio_player_screen.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_circular_play_button.dart';
import 'package:towards_him_app/core/widgets/toward_him_logo.dart';
import 'package:towards_him_app/features/auth/presentation/screens/login_screen.dart';
import 'package:towards_him_app/features/home/data/home_demo_data.dart';
import 'package:towards_him_app/features/home/domain/models/home_models.dart';
import 'package:towards_him_app/features/home/presentation/controllers/home_navigation_controller.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/home/presentation/widgets/home_quick_access_card.dart';
import 'package:towards_him_app/features/home/presentation/widgets/home_featured_card.dart';
import 'package:towards_him_app/features/home/presentation/widgets/home_recent_activity_card.dart';

class FakeAudioCatalogRepository extends AudioCatalogRepository {
  const FakeAudioCatalogRepository(this.episodes);
  final List<ListenAudioEpisode> episodes;

  @override
  Future<List<ListenAudioEpisode>> fetchPublished() async => episodes;
}

const publishedEpisodes = [
  ListenAudioEpisode(
    id: '101',
    title: 'A Real Podcast',
    description: 'Published by the administrator',
    thumbnailAsset: 'assets/images/home/golden_hour_meditation.webp',
    contentType: 'Podcast',
    durationMinutes: 12,
    playbackProgress: 0,
    isCompleted: false,
  ),
  ListenAudioEpisode(
    id: '102',
    title: 'A Real Meditation',
    description: 'New meditation',
    thumbnailAsset: 'assets/images/home/golden_hour_meditation.webp',
    contentType: 'Meditation',
    durationMinutes: 8,
    playbackProgress: 0,
    isCompleted: false,
  ),
  ListenAudioEpisode(
    id: '103',
    title: 'A Real Prayer',
    description: 'New prayer',
    thumbnailAsset: 'assets/images/home/golden_hour_meditation.webp',
    contentType: 'Prayer',
    durationMinutes: 6,
    playbackProgress: 0,
    isCompleted: false,
  ),
];

void _doNothing() {}

void main() {
  testWidgets('Home weekly challenge description is clamped to three lines',
      (tester) async {
    const fullDescription = 'A detailed weekly challenge about prayer, '
        'gratitude, meditation, scripture, forgiveness, giving, kindness, '
        'connection, and growing closer to HIM throughout each day.';
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 390,
          child: HomeFeaturedCard(
            content: HomeFeaturedContent(
              id: 'week-1',
              category: 'Weekly Toward HIM 3',
              title: '7 Days of Growing Closer to HIM',
              description: fullDescription,
              imageAsset: 'assets/images/home/golden_hour_meditation.webp',
            ),
            onPressed: _doNothing,
          ),
        ),
      ),
    ));

    final description = tester.widget<Text>(find.text(fullDescription));
    expect(description.maxLines, 3);
    expect(description.overflow, TextOverflow.ellipsis);
    expect(find.text('7 Days of Growing Closer to HIM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Demo models and order of five tabs match Figma', () {
    expect(HomeDemoData.profile.firstName, 'Sarah');
    expect(HomeDemoData.listening.progress, closeTo(0.38, 0.001));
    expect(HomeDemoData.quickAccess.length, 3);
    expect(HomeDemoData.recentActivities.length, 2);
    expect(HomeDemoData.navigation.map((item) => item.label), [
      'Home', 'Listen', 'Towards HIM 3', 'Community', 'Store',
    ]);
    expect(HomeDemoData.merchandiseStoreUrl, isNull);
  });

  test('Navigation controller only notifies on selection changes', () {
    final controller = HomeNavigationController();
    addTearDown(controller.dispose);
    var updates = 0;
    controller.addListener(() => updates++);
    controller.select(HomeTab.listen);
    controller.select(HomeTab.listen);
    expect(controller.selected, HomeTab.listen);
    expect(updates, 1);
  });

  testWidgets('Login keeps approved UI and no longer bypasses authentication', (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    expect(find.byType(LoginScreen), findsOneWidget);
    // Navigation is performed only after the real member API succeeds.
    expect(find.byType(HomeShellScreen), findsNothing);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('430px Home hero is full bleed, card overlaps and no logo',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: HomeShellScreen(
      audioRepository: FakeAudioCatalogRepository(publishedEpisodes),
    )));
    await tester.pumpAndSettle();
    final hero = tester.getRect(find.byKey(const Key('home_hero_image')));
    expect(hero.left, 0);
    expect(hero.width, 430);
    expect(hero.height, 288);
    final card = tester.getRect(find.byKey(const Key('home_featured_card')));
    expect(card.left, closeTo(20, 1));
    expect(card.width, closeTo(390, 1));
    expect(card.top, closeTo(AppSpacing.homeHeroCardTop, 1));
    expect(card.top, lessThan(hero.bottom));
    expect(find.byType(TowardHimLogo), findsNothing);
    expect(find.text('Start Your Weekly Journey'), findsOneWidget);
  });

  testWidgets('Greeting uses demo name with separate Playfair weights',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeShellScreen(
      audioRepository: FakeAudioCatalogRepository(publishedEpisodes),
    )));
    await tester.pumpAndSettle();
    final greeting = tester.widget<Text>(
      find.byKey(const Key('home_greeting')),
    );
    final spans = (greeting.textSpan! as TextSpan).children!;
    expect((spans.first as TextSpan).text, 'Good Morning\n');
    expect((spans.last as TextSpan).text, 'Friend');
    expect((spans.first as TextSpan).style, AppTypography.homeGreeting);
    expect((spans.last as TextSpan).style, AppTypography.homeGreetingName);
    expect(find.textContaining('Psalm 46:10'), findsOneWidget);
  });

  testWidgets('Home displays real published audio and opens Player',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const HomeShellScreen(
        audioRepository: FakeAudioCatalogRepository(publishedEpisodes),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.pumpAndSettle();
    expect(find.byType(HomeQuickAccessCard), findsNWidgets(3));
    expect(find.byType(HomeRecentActivityCard), findsNWidgets(2));
    expect(find.byType(AppAudioProgressBar), findsOneWidget);
    expect(find.text('A Real Podcast'), findsOneWidget);
    expect(find.text('A Real Meditation'), findsOneWidget);
    expect(find.text('Recently Published'), findsOneWidget);
    expect(tester.widget<AppCircularPlayButton>(
      find.byType(AppCircularPlayButton),
    ).isPlaying, isFalse);
    await tester.tap(find.byType(AppCircularPlayButton));
    await tester.pumpAndSettle();
    expect(find.byType(AudioPlayerScreen), findsOneWidget);
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    final nav = find.byType(AppBottomNavigation);
    expect(tester.widget<AppBottomNavigation>(nav).items.length, 5);
    await tester.tap(find.byKey(const Key('nav_Listen')));
    await tester.pumpAndSettle();
    expect(tester.widget<AppBottomNavigation>(nav).selectedIndex, 1);
  });

  testWidgets('Home with no published audio never shows demo episodes',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HomeShellScreen(
        audioRepository: FakeAudioCatalogRepository([]),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('No audio published yet.'), findsOneWidget);
    expect(find.text('Building a grateful heart'), findsNothing);
    expect(find.text('Recently Published'), findsNothing);
  });

  testWidgets('Store opens the approved merchandise bottom sheet', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeShellScreen(
      audioRepository: FakeAudioCatalogRepository(publishedEpisodes),
    )));
    await tester.tap(find.byKey(const Key('nav_Store')));
    await tester.pumpAndSettle();
    expect(find.text('Merchandise Store'), findsOneWidget);
    expect(find.text('Visit Store'), findsOneWidget);
    expect(find.text('Explore Toward HIM merchandise in our official online store.'),
        findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Merchandise Store'), findsNothing);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Home responsive at ${size.width}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: HomeShellScreen(
      audioRepository: FakeAudioCatalogRepository(publishedEpisodes),
    )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -450),
      );
      await tester.pumpAndSettle();
      expect(find.text('Recently Published'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
