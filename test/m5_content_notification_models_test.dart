import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/features/notifications/domain/models/app_notification.dart';
import 'package:towards_him_app/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:towards_him_app/features/profile/data/platform_content_store.dart';
import 'support/fake_notification_repository.dart';

void main() {
  test('The approved welcome and about copy is used before admin updates', () {
    expect(PlatformContent.defaults.welcomeHeading, 'Welcome to Toward HIM');
    expect(PlatformContent.defaults.aboutInformation, contains('heart feels heavy'));
  });

  test('The public content API maps admin changes without new screens', () {
    final content = PlatformContent.fromApi({
      'welcome_heading': 'Welcome Home',
      'introduction_text': 'A new introduction',
      'about_information': 'A renewed message',
    });
    expect(content.welcomeHeading, 'Welcome Home');
    expect(content.introductionText, 'A new introduction');
    expect(content.aboutInformation, 'A renewed message');
  });

  test('Notification API model carries published audio, read state and artwork', () {
    final item = AppNotification.fromApi({
      'id': '17',
      'content_id': '12',
      'title': 'A prayer for today',
      'description': 'Find a moment of quiet.',
      'category': 'Prayer',
      'artwork_url': 'https://example.com/storage/artwork/12.jpg',
      'is_read': false,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    expect(item.contentId, '12');
    expect(item.category, 'Prayer');
    expect(item.dateLabel, 'Today');
    expect(item.artworkUrl, contains('artwork/12.jpg'));
    expect(item.isRead, isFalse);
  });

  test('Member read and delete remain after reloading the notification feed', () async {
    final repository = FakeNotificationRepository();
    final controller = NotificationsController(repository: repository);
    addTearDown(controller.dispose);
    await controller.load();
    expect(controller.notifications.length, 5);
    await controller.markRead('notification-1');
    await controller.delete('notification-2');
    await controller.load();
    expect(controller.notifications.first.isRead, isTrue);
    expect(controller.notifications.length, 4);
    expect(controller.notifications.any((item) => item.id == 'notification-2'), isFalse);
  });
}
