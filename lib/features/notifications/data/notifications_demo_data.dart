import '../../home/data/home_demo_data.dart';
import '../domain/models/app_notification.dart';

/// UI-only fixture matching the approved five-notification Figma layout.
abstract final class NotificationsDemoData {
  static const title = 'Finding hope in difficult season';
  static const description =
      'A conversation about trusting god when life feels uncertain';

  static final notifications = List<AppNotification>.unmodifiable([
    for (var i = 1; i <= 5; i++)
      AppNotification(
        id: 'notification-$i',
        contentId: 'finding-hope-01',
        title: title,
        description: description,
        imageAsset: HomeDemoData.meditationAsset,
        category: 'Podcast',
        createdAt: DateTime(2026, 11, 9),
        dateLabel: 'Today',
        isRead: i > 1,
      ),
  ]);
}
