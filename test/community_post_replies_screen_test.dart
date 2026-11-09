import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_detail_page_header.dart';
import 'package:towards_him_app/core/widgets/app_text_field.dart';
import 'package:towards_him_app/features/community/presentation/controllers/community_controller.dart';
import 'package:towards_him_app/features/community/presentation/screens/community_post_replies_screen.dart';
import 'package:towards_him_app/features/community/presentation/widgets/community_post_card.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';

void main() {
  test('Model-backed 5-reply heading seeds 3 visible replies', () {
    final controller = CommunityController();
    addTearDown(controller.dispose);
    const postId = 'community-001';
    expect(controller.postById(postId)!.replyCount, 3);
    expect(controller.totalRepliesFor(postId), 5);
    expect(controller.repliesFor(postId).length, 3);
    expect(controller.repliesFor(postId).first.authorName, 'Claudia johns');
    expect(
      controller.repliesFor(postId).first.body,
      'This is such a great reminder. he truly knows what’s best for us',
    );
    expect(controller.submitReply(postId, '     '), isFalse);
    expect(controller.totalRepliesFor(postId), 5);
    expect(controller.submitReply(postId, '  Amen and thank you  '), isTrue);
    expect(controller.totalRepliesFor(postId), 6);
    expect(controller.repliesFor(postId).length, 4);
    expect(controller.repliesFor(postId).last.body, 'Amen and thank you');
    expect(controller.postById(postId)!.replyCount, 4);
    controller.hideReply(postId, controller.repliesFor(postId).last.id);
    expect(controller.totalRepliesFor(postId), 5);
    expect(controller.postById(postId)!.replyCount, 3);
  });

  Future<void> openReplies(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const HomeShellScreen(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.tap(find.byKey(const Key('nav_Community')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('community_replies_community-001')));
    await tester.pumpAndSettle();
  }

  testWidgets('Community indicator opens Post Replies without bottom navigation',
      (tester) async {
    await openReplies(tester);
    expect(find.byType(CommunityPostRepliesScreen), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.byType(AppDetailPageHeader), findsOneWidget);
    expect(
      tester.widget<AppDetailPageHeader>(find.byType(AppDetailPageHeader)).title,
      'Post Replies',
    );
    expect(find.text('5 Replies'), findsOneWidget);
    expect(find.byType(CommunityPostCard), findsNWidgets(4));
    final cards = tester.widgetList<CommunityPostCard>(
      find.byType(CommunityPostCard),
    ).toList();
    expect(cards.first.showRepliesIndicator, isTrue);
    expect(cards.skip(1).every((card) => !card.showRepliesIndicator), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('58px iconless reply input matches shared design',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openReplies(tester);
    final input = find.byKey(const Key('community_reply_input_container'));
    await tester.ensureVisible(input);
    await tester.pumpAndSettle();
    expect(tester.getSize(input).height, 58);
    final widget = tester.widget<AppTextField>(input);
    expect(widget.iconAsset, isNull);
    expect(widget.borderColor, AppColors.cardBorder);
    expect(widget.backgroundColor, AppColors.outlinedButtonBackground);
    expect(find.text('Submit Reply'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Submit validates and updates thread/feed, then back returns',
      (tester) async {
    await openReplies(tester);
    final input = find.byKey(const Key('community_reply_input'));
    await tester.ensureVisible(input);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('community_submit_reply_button')));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityPostRepliesScreen), findsOneWidget);
    await tester.enterText(input, '  Thank you for sharing  ');
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const Key('community_submit_reply_button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('community_submit_reply_button')));
    await tester.pumpAndSettle();
    expect(find.text('6 Replies'), findsOneWidget);
    expect(find.text('Thank you for sharing'), findsOneWidget);
    expect(tester.widget<TextField>(input).controller!.text, isEmpty);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(CommunityPostRepliesScreen), findsNothing);
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.text('4 replies'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Post Replies scrolls at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openReplies(tester);
      expect(find.byKey(const Key('community_replies_scroll')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byKey(const Key('community_replies_scroll')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
