import 'support/fake_notification_repository.dart';
import 'support/fake_challenge_repository.dart';
import 'support/fake_community_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_back_button.dart';
import 'package:towards_him_app/core/widgets/app_content_type_tag.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/listen/presentation/screens/audio_player_screen.dart';
import 'package:towards_him_app/features/notifications/data/notifications_demo_data.dart';
import 'package:towards_him_app/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:towards_him_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:towards_him_app/features/notifications/domain/models/app_notification.dart';
import 'package:towards_him_app/features/weekly_challenges/presentation/screens/weekly_challenge_detail_screen.dart';
import 'package:towards_him_app/features/weekly_challenges/presentation/screens/daily_challenge_screen.dart';
import 'package:towards_him_app/features/community/presentation/screens/community_post_replies_screen.dart';
import 'package:towards_him_app/features/community/data/community_demo_data.dart';
import 'package:towards_him_app/features/notifications/presentation/widgets/notification_card.dart';
import 'package:towards_him_app/features/notifications/presentation/widgets/notification_swipe_card.dart';

void main() {

  AppNotification targeted(String destination, {
    String contentId = 'weekly-current',
    int? dayNumber,
  }) => AppNotification(
    id: 'target-$destination',
    contentId: contentId,
    title: 'New activity published',
    description: 'A detailed notification description that continues for a '
        'very long time across multiple lines on a narrow phone. '
        'It should never exceed three lines, while opening the complete item.',
    imageAsset: 'assets/images/home/golden_hour_meditation.webp',
    category: destination,
    targetType: destination,
    dayNumber: dayNumber,
    createdAt: DateTime(2026, 11, 18),
    dateLabel: 'Today',
    isRead: false,
  );

  Future<void> showTargeted(WidgetTester tester, AppNotification target) async {
    await tester.pumpWidget(MaterialApp(
      home: NotificationsScreen(
        controller: NotificationsController(
          repository: FakeNotificationRepository(notifications: [target]),
        ),
        challengeRepository: FakeChallengeRepository(),
        communityRepository: FakeCommunityRepository(),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('Notification descriptions show no more than three lines',
      (tester) async {
    final target = targeted('Podcast');
    await showTargeted(tester, target);
    final description = tester.widget<Text>(find.text(target.description));
    expect(description.maxLines, 3);
    expect(description.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Narrow notification cards also clamp their description',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final target = targeted('Podcast');
    await showTargeted(tester, target);
    final description = tester.widget<Text>(find.text(target.description));
    expect(description.maxLines, 3);
    expect(description.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Weekly notification opens its exact challenge and marks read',
      (tester) async {
    await showTargeted(tester, targeted('weekly_challenge'));
    await tester.tap(find.byKey(const Key('notification_card_target-weekly_challenge')));
    await tester.pumpAndSettle();
    expect(find.byType(WeeklyChallengeDetailScreen), findsOneWidget);
    await tester.tap(find.byType(AppBackButton).last);
    await tester.pumpAndSettle();
    expect(tester.widget<NotificationCard>(find.byType(NotificationCard))
        .notification.isRead, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Daily notification opens the matching challenge day',
      (tester) async {
    await showTargeted(tester, targeted('daily_challenge', dayNumber: 3));
    await tester.tap(find.byKey(const Key('notification_card_target-daily_challenge')));
    await tester.pumpAndSettle();
    expect(find.byType(DailyChallengeScreen), findsOneWidget);
    expect(find.text('Day 3 – Daily Challenge'), findsOneWidget);
    await tester.tap(find.byType(AppBackButton).last);
    await tester.pumpAndSettle();
    expect(tester.widget<NotificationCard>(find.byType(NotificationCard))
        .notification.isRead, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Community notification opens its exact discussion',
      (tester) async {
    final post = CommunityDemoData.posts.first;
    await showTargeted(tester, targeted('community', contentId: post.id));
    await tester.tap(find.byKey(const Key('notification_card_target-community')));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityPostRepliesScreen), findsOneWidget);
    expect(find.byKey(Key('replies_original_' + post.id)), findsOneWidget);
    await tester.tap(find.byType(AppBackButton).last);
    await tester.pumpAndSettle();
    expect(tester.widget<NotificationCard>(find.byType(NotificationCard))
        .notification.isRead, isTrue);
    expect(tester.takeException(), isNull);
  });

  test('Notification parser maps existing audio and optional destinations', () {
    final audio = AppNotification.fromApi({
      'id': 3, 'content_id': 71, 'title': 'New Meditation',
      'description': 'Listen now', 'category': 'Meditation', 'is_read': false,
    });
    expect(audio.destination, 'audio');
    expect(audio.dayNumber, isNull);

    final day = AppNotification.fromApi({
      'id': 4, 'content_id': 19, 'category': 'Daily Challenge',
      'target_type': 'daily_challenge', 'day_number': 5,
    });
    expect(day.destination, 'daily');
    expect(day.dayNumber, 5);
    expect(day.copyWith(isRead: true).dayNumber, 5);
    expect(day.copyWith(isRead: true).destination, 'daily');
  });

  test('Five notifications, server-backed deletion, open-state and read status', () async {
    final controller = NotificationsController(repository: FakeNotificationRepository());
    await controller.load();
    addTearDown(controller.dispose);
    expect(controller.notifications.length, 5);
    expect(controller.notifications.map((n) => n.id).toSet().length, 5);
    expect(NotificationsDemoData.title, 'Finding hope in difficult season');
    expect(controller.notifications.first.category, 'Podcast');

    controller.revealDelete('notification-1');
    expect(controller.openId, 'notification-1');
    controller.revealDelete('notification-2');
    expect(controller.openId, 'notification-2');
    controller.closeDelete(id: 'notification-1');
    expect(controller.openId, 'notification-2');
    controller.closeDelete(id: 'notification-2');
    expect(controller.openId, isNull);

    expect(controller.notifications.first.isRead, isFalse);
    await controller.markRead('notification-1');
    expect(controller.notifications.first.isRead, isTrue);
    await controller.delete('notification-2');
    expect(controller.notifications.length, 4);
    expect(
      controller.notifications.map((item) => item.id),
      isNot(contains('notification-2')),
    );
  });

  Future<void> showNotifications(WidgetTester tester, {String tab = 'Home'}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeShellScreen(
          notificationRepository: FakeNotificationRepository(),
          challengeRepository: FakeChallengeRepository(),
          communityRepository: FakeCommunityRepository(),
        ),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    if (tab != 'Home') {
      await tester.tap(find.byKey(Key('nav_$tab')));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
  }

  testWidgets('Each existing main tab bell opens Notifications and back returns',
      (tester) async {
    for (final tab in <String>[
      'Home', 'Listen', 'Towards HIM 3', 'Community',
    ]) {
      await showNotifications(tester, tab: tab);
      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);
      expect(find.text('Notifications'), findsWidgets);
      await tester.tap(find.byType(AppBackButton).last);
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsScreen), findsNothing);
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Figma notification cards reuse image and Podcast badges',
      (tester) async {
    await showNotifications(tester);
    expect(find.byType(NotificationSwipeCard), findsNWidgets(5));
    expect(find.byType(NotificationCard), findsNWidgets(5));
    expect(find.byType(AppContentTypeTag), findsNWidgets(5));
    expect(find.text('Today'), findsNWidgets(5));
    expect(find.byKey(const Key('notification_image_notification-1')),
        findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('notification_image_notification-1'))),
      const Size(100, 100),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Left swipe reveals only one Delete action; right swipe closes',
      (tester) async {
    await showNotifications(tester);
    final first = find.byKey(const Key('notification_card_notification-1'));
    final second = find.byKey(const Key('notification_card_notification-2'));
    await tester.drag(first, const Offset(-100, 0));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NotificationSwipeCard>(
        find.byKey(const ValueKey<String>('notification-1')),
      ).isOpen,
      isTrue,
    );
    expect(find.byType(NotificationCard), findsNWidgets(5));
    await tester.drag(second, const Offset(-100, 0));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NotificationSwipeCard>(
        find.byKey(const ValueKey<String>('notification-1')),
      ).isOpen,
      isFalse,
    );
    expect(
      tester.widget<NotificationSwipeCard>(
        find.byKey(const ValueKey<String>('notification-2')),
      ).isOpen,
      isTrue,
    );
    await tester.drag(second, const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NotificationSwipeCard>(
        find.byKey(const ValueKey<String>('notification-2')),
      ).isOpen,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tap Delete removes only selected item and survives reopening',
      (tester) async {
    await showNotifications(tester);
    await tester.drag(
      find.byKey(const Key('notification_card_notification-1')),
      const Offset(-100, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('notification_delete_notification-1')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NotificationCard), findsNWidgets(4));
    expect(
      find.byKey(const Key('notification_card_notification-1')),
      findsNothing,
    );
    await tester.tap(find.byType(AppBackButton).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationCard), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Notification opens the existing podcast Player', (tester) async {
    await showNotifications(tester);
    await tester.tap(find.byKey(const Key('notification_card_notification-1')));
    await tester.pumpAndSettle();
    expect(find.byType(AudioPlayerScreen), findsOneWidget);
    await tester.tap(find.byType(AppBackButton).last);
    await tester.pumpAndSettle();
    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Notifications responsive at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await showNotifications(tester);
      expect(find.byKey(const Key('notifications_scroll')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byKey(const Key('notifications_scroll')),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
