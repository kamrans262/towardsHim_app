import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_content_card.dart';
import 'package:towards_him_app/core/widgets/app_progress_bar.dart';
import 'package:towards_him_app/core/widgets/app_search_field.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/weekly_challenges/data/weekly_challenge_demo_data.dart';
import 'package:towards_him_app/features/weekly_challenges/domain/models/weekly_challenge.dart';
import 'package:towards_him_app/features/weekly_challenges/presentation/screens/weekly_challenges_screen.dart';
import 'package:towards_him_app/features/weekly_challenges/presentation/widgets/weekly_challenge_card.dart';

void main() {
  Future<void> openWeekly(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeShellScreen()));
    await tester.tap(find.byKey(const Key('nav_Towards HIM 3')));
    await tester.pumpAndSettle();
  }

  test('Figma demo data has three featured and two previous challenges', () {
    final challenges = WeeklyChallengeDemoData.challenges;
    expect(challenges.length, 5);
    expect(challenges.map((item) => item.id).toSet().length, 5);
    expect(challenges.where((item) => item.category == WeeklyChallengeCategory.featured).length, 3);
    expect(challenges.where((item) => item.category == WeeklyChallengeCategory.previous).length, 2);
    expect(challenges.first.progress, closeTo(3 / 7, 0.0001));
    expect(challenges.first.datesLabel, 'March 3 – March 10');
    expect(challenges.first.progressLabel, 'Day 3 of 7');
    expect(challenges.last.progress, 1);
  });

  testWidgets('Weekly tab reuses fixed 5-item navigation and global assets', (tester) async {
    await openWeekly(tester);
    expect(find.byType(WeeklyChallengesScreen), findsOneWidget);
    expect(find.byType(AppSearchField), findsOneWidget);
    expect(find.byType(WeeklyChallengeCard), findsNWidgets(5));
    expect(find.byType(AppProgressBar), findsNWidgets(5));
    final nav = tester.widget<AppBottomNavigation>(find.byType(AppBottomNavigation));
    expect(nav.selectedIndex, 2);
    expect(nav.items.length, 5);
    final cards = tester.widgetList<WeeklyChallengeCard>(find.byType(WeeklyChallengeCard)).toList();
    expect(cards.where((card) => card.compact).length, 2);
    expect(tester.widget<AppContentCard>(find.byType(AppContentCard).first).backgroundColor, AppColors.podcastTile);
    expect(tester.widget<AppContentCard>(find.byType(AppContentCard).first).borderColor, AppColors.weeklyCurrentBorder);
    expect(AppSpacing.weeklyProgressHeight, 8);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Search filters local challenges and shows an empty state', (tester) async {
    await openWeekly(tester);
    await tester.enterText(find.byKey(const Key('weekly_search')), 'not found anywhere');
    await tester.pumpAndSettle();
    expect(find.text('No challenges found'), findsOneWidget);
    expect(find.byType(WeeklyChallengeCard), findsNothing);
    await tester.enterText(find.byKey(const Key('weekly_search')), 'toward');
    await tester.pumpAndSettle();
    expect(find.byType(WeeklyChallengeCard), findsNWidgets(5));
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Weekly remains scrollable at size '+size.width.toString(), (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openWeekly(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomScrollView), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final nav = tester.getRect(find.byType(AppBottomNavigation));
      final scaffold = tester.getRect(find.byType(Scaffold));
      expect(nav.bottom, closeTo(scaffold.bottom, 1));
    });
  }
}
