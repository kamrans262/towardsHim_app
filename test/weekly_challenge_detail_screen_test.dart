import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/widgets/app_back_button.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/weekly_challenges/presentation/screens/weekly_challenge_detail_screen.dart';
import 'package:towards_him_app/core/navigation/app_router.dart';

void main() {
  Future<void> openDetail(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const HomeShellScreen(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.tap(find.byKey(const Key('nav_Towards HIM 3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('weekly_card_weekly-current')));
    await tester.pumpAndSettle();
  }

  testWidgets('Weekly detail opens from card and back returns to tab', (tester) async {
    await openDetail(tester);
    expect(find.byType(WeeklyChallengeDetailScreen), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Your Progress'), findsOneWidget);
    expect(find.text('Daily Activities'), findsOneWidget);
    expect(find.text('Day 3 of 7'), findsOneWidget);
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.byType(WeeklyChallengeDetailScreen), findsNothing);
  });

  testWidgets('Toggle updates local progress without backend', (tester) async {
    await openDetail(tester);
    await tester.drag(find.byKey(const Key('weekly_detail_scroll')), const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('weekly_day_toggle_3')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('weekly_detail_progress_label')), findsOneWidget);
    expect(find.text('Day 4 of 7'), findsOneWidget);
  });

  testWidgets('Navigation uses a valid SVG destination and detail scrolls', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openDetail(tester);
    expect(find.byKey(const Key('weekly_detail_hero')), findsOneWidget);
    await tester.drag(find.byKey(const Key('weekly_detail_scroll')), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
