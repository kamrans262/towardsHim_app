import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/widgets/app_back_button.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_button.dart';
import 'package:towards_him_app/features/community/presentation/screens/community_create_post_screen.dart';
import 'package:towards_him_app/features/community/presentation/screens/community_screen.dart';
import 'package:towards_him_app/features/community/presentation/widgets/community_post_card.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';

void main() {
  Future<void> openCreate(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeShellScreen(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.tap(find.byKey(const Key('nav_Community')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('community_add_post')));
    await tester.pumpAndSettle();
  }

  testWidgets('Full page has 290px editor and 100-char counter',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openCreate(tester);
    expect(find.byType(CommunityCreatePostScreen), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.text('Create a Post'), findsOneWidget);
    expect(find.text('0/100'), findsOneWidget);
    final editor = tester.getSize(
      find.byKey(const Key('community_post_container')),
    );
    expect(editor.height, 290);
    expect(editor.width, closeTo(390, 0.1));
    final field = tester.widget<TextField>(
      find.byKey(const Key('community_post_input')),
    );
    expect(field.maxLength, 100);
    expect(find.text('Publish Post'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    final cancel = tester.widget<AppButton>(
      find.byKey(const Key('community_cancel_button')),
    );
    expect(cancel.variant, AppButtonVariant.outlined);
    expect(cancel.outlinedBackgroundColor, Colors.transparent);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Counter updates, empty publishing blocked, 100 limit enforced',
      (tester) async {
    await openCreate(tester);
    await tester.tap(find.text('Publish Post'));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityCreatePostScreen), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('community_post_input')),
      'Faith',
    );
    await tester.pump();
    expect(find.text('5/100'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('community_post_input')),
      'a' * 102,
    );
    await tester.pump();
    expect(find.text('100/100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cancel and back discard drafts; Publish adds a post', (tester) async {
    await openCreate(tester);
    await tester.enterText(
      find.byKey(const Key('community_post_input')), 'Unsaved message',
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityScreen), findsOneWidget);
    expect(find.text('Unsaved message'), findsNothing);
    await tester.tap(find.byKey(const Key('community_add_post')));
    await tester.pumpAndSettle();
    expect(find.text('0/100'), findsOneWidget);
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('community_add_post')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('community_post_input')), 'God is good',
    );
    await tester.tap(find.text('Publish Post'));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityCreatePostScreen), findsNothing);
    expect(find.text('God is good'), findsOneWidget);
    expect(find.byType(CommunityPostCard), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Create a Post is scrollable at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openCreate(tester);
      expect(
        find.byKey(const Key('community_create_post_scroll')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
