import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/theme/app_typography.dart';
import 'package:towards_him_app/core/widgets/app_audio_progress_bar.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_circular_play_button.dart';
import 'package:towards_him_app/core/widgets/toward_him_logo.dart';
import 'package:towards_him_app/features/auth/presentation/screens/login_screen.dart';
import 'package:towards_him_app/features/home/data/home_demo_data.dart';
import 'package:towards_him_app/features/home/domain/models/home_models.dart';
import 'package:towards_him_app/features/home/presentation/controllers/home_navigation_controller.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/home/presentation/widgets/home_quick_access_card.dart';
import 'package:towards_him_app/features/home/presentation/widgets/home_recent_activity_card.dart';

void main() {
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

  testWidgets('Login demo opens Home without authentication', (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeShellScreen), findsOneWidget);
    expect(find.text('Continue Where You Left Off'), findsOneWidget);
  });

  testWidgets('430px Home hero is full bleed, card overlaps and no logo',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: HomeShellScreen()));
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
    expect(find.text('Finding Peace in His Presence'), findsOneWidget);
  });

  testWidgets('Greeting uses demo name with separate Playfair weights',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeShellScreen()));
    await tester.pumpAndSettle();
    final greeting = tester.widget<Text>(
      find.byKey(const Key('home_greeting')),
    );
    final spans = (greeting.textSpan! as TextSpan).children!;
    expect((spans.first as TextSpan).text, 'Good Morning\n');
    expect((spans.last as TextSpan).text, 'Sarah');
    expect((spans.first as TextSpan).style, AppTypography.homeGreeting);
    expect((spans.last as TextSpan).style, AppTypography.homeGreetingName);
    expect(find.textContaining('Psalm 46:10'), findsOneWidget);
  });

  testWidgets('Cards, local play state and fixed five-tab bar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeShellScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(HomeQuickAccessCard), findsNWidgets(3));
    expect(find.byType(HomeRecentActivityCard), findsNWidgets(2));
    expect(find.byType(AppAudioProgressBar), findsOneWidget);
    expect(find.text('Building a grateful heart'), findsOneWidget);
    expect(tester.widget<AppCircularPlayButton>(
      find.byType(AppCircularPlayButton),
    ).isPlaying, isFalse);
    await tester.tap(find.byType(AppCircularPlayButton));
    await tester.pump();
    expect(tester.widget<AppCircularPlayButton>(
      find.byType(AppCircularPlayButton),
    ).isPlaying, isTrue);
    final nav = find.byType(AppBottomNavigation);
    expect(tester.widget<AppBottomNavigation>(nav).items.length, 5);
    expect(tester.widget<AppBottomNavigation>(nav).selectedIndex, 0);
    await tester.tap(find.byKey(const Key('nav_Listen')));
    await tester.pumpAndSettle();
    expect(tester.widget<AppBottomNavigation>(nav).selectedIndex, 1);
    await tester.tap(find.byKey(const Key('nav_Home')));
    await tester.pumpAndSettle();
    expect(tester.widget<AppCircularPlayButton>(
      find.byType(AppCircularPlayButton),
    ).isPlaying, isTrue);
  });

  testWidgets('Store shows local placeholder without URL', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeShellScreen()));
    await tester.tap(find.byKey(const Key('nav_Store')));
    await tester.pumpAndSettle();
    expect(find.text('Merchandise Store URL has not been configured.'),
        findsOneWidget);
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
      await tester.pumpWidget(const MaterialApp(home: HomeShellScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -450),
      );
      await tester.pumpAndSettle();
      expect(find.text('Recent Activity'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
