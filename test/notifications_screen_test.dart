import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_content_type_tag.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/listen/presentation/screens/audio_player_screen.dart';
import 'package:towards_him_app/features/notifications/data/notifications_demo_data.dart';
import 'package:towards_him_app/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:towards_him_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:towards_him_app/features/notifications/presentation/widgets/notification_card.dart';
import 'package:towards_him_app/features/notifications/presentation/widgets/notification_swipe_card.dart';

void main() {
  test('Five notification models, local deletion, open-state and read status', () {
    final controller = NotificationsController();
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
    controller.markRead('notification-1');
    expect(controller.notifications.first.isRead, isTrue);
    controller.delete('notification-2');
    expect(controller.notifications.length, 4);
    expect(
      controller.notifications.map((item) => item.id),
      isNot(contains('notification-2')),
    );
  });

  Future<void> showNotifications(WidgetTester tester, {String tab = 'Home'}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeShellScreen(),
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
      await tester.pageBack();
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
    await tester.pageBack();
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
    await tester.pageBack();
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
