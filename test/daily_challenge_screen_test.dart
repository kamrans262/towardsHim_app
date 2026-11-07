import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/widgets/app_back_button.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/weekly_challenges/data/daily_challenge_demo_data.dart';
import 'package:towards_him_app/features/weekly_challenges/presentation/screens/daily_challenge_screen.dart';
import 'package:towards_him_app/features/weekly_challenges/presentation/widgets/daily_challenge_option_card.dart';

void main() {
  Future<void> openDaily(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const HomeShellScreen(),
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
    expect(find.text('October 8 – Daily Challenge'), findsOneWidget);
    expect(find.text('Taste, See or Share'), findsOneWidget);
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
