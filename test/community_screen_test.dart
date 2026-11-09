import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_content_card.dart';
import 'package:towards_him_app/core/widgets/app_main_screen_header.dart';
import 'package:towards_him_app/features/community/data/community_demo_data.dart';
import 'package:towards_him_app/features/community/domain/models/community_post.dart';
import 'package:towards_him_app/features/community/presentation/controllers/community_controller.dart';
import 'package:towards_him_app/features/community/presentation/screens/community_screen.dart';
import 'package:towards_him_app/features/community/presentation/widgets/community_post_card.dart';
import 'package:towards_him_app/features/community/presentation/widgets/community_segmented_tabs.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';

void main() {
  test('Demo data is structured and keeps Figma author/content', () {
    expect(CommunityDemoData.posts.length, 3);
    expect(
      CommunityDemoData.posts.map((post) => post.id).toSet().length,
      3,
    );
    for (final post in CommunityDemoData.posts) {
      expect(post.authorName, 'Sarah Johnson');
      expect(post.body, CommunityDemoData.samplePost);
      expect(post.timeLabel, '2 hours ago');
      expect(post.replyCount, 3);
    }
  });

  test('All/My Posts filtering and local post creation', () {
    final controller = CommunityController();
    addTearDown(controller.dispose);
    expect(controller.visiblePosts.length, 3);
    controller.selectTab(CommunityFeedTab.myPosts);
    expect(controller.visiblePosts.length, 2);
    controller.createPost('  Sharing faith together  ');
    expect(controller.visiblePosts.length, 3);
    expect(controller.visiblePosts.first.body, 'Sharing faith together');
    expect(controller.visiblePosts.first.timeLabel, 'Just now');
    controller.hidePost(controller.visiblePosts.first.id);
    expect(controller.visiblePosts.length, 2);
    controller.selectTab(CommunityFeedTab.allPosts);
    expect(controller.visiblePosts.length, 3);
  });

  Future<void> openCommunity(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeShellScreen()),
    );
    await tester.tap(find.byKey(const Key('nav_Community')));
    await tester.pumpAndSettle();
  }

  testWidgets('Community reuses global nav/header and 3 post cards',
      (tester) async {
    await openCommunity(tester);
    expect(find.byType(CommunityScreen), findsOneWidget);
    expect(find.byType(CommunityPostCard), findsNWidgets(3));
    expect(find.byType(CommunitySegmentedTabs), findsOneWidget);
    final nav = tester.widget<AppBottomNavigation>(
      find.byType(AppBottomNavigation),
    );
    expect(nav.selectedIndex, 3);
    expect(nav.items.length, 5);
    expect(
      tester.widget<AppMainScreenHeader>(
        find.byType(AppMainScreenHeader),
      ).title,
      'Community',
    );
    expect(find.text(CommunityDemoData.description), findsOneWidget);
    final card = tester.widget<AppContentCard>(
      find.byType(AppContentCard).first,
    );
    expect(card.backgroundColor, AppColors.outlinedButtonBackground);
    expect(card.borderColor, AppColors.cardBorder);
    expect(find.byKey(const Key('community_add_post')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('All/My tabs filter and preserve their state across Home',
      (tester) async {
    await openCommunity(tester);
    await tester.tap(find.byKey(const Key('community_tab_myPosts')));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityPostCard), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('nav_Home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav_Community')));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityPostCard), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('community_tab_allPosts')));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityPostCard), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Create Post sheet adds an in-memory post to My Posts',
      (tester) async {
    await openCommunity(tester);
    await tester.tap(find.byKey(const Key('community_add_post')));
    await tester.pumpAndSettle();
    expect(find.text('Create Post'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('community_post_input')),
      'Grateful for today',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Post', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('Grateful for today'), findsOneWidget);
    expect(find.byType(CommunityPostCard), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Community layout at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openCommunity(tester);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
