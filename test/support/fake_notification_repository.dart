import 'package:towards_him_app/features/listen/data/listen_demo_data.dart';
import 'package:towards_him_app/features/listen/domain/models/listen_audio_episode.dart';
import 'package:towards_him_app/features/notifications/data/notification_repository.dart';
import 'package:towards_him_app/features/notifications/data/notifications_demo_data.dart';
import 'package:towards_him_app/features/notifications/domain/models/app_notification.dart';

/// Deterministic fixture for tests; production always reads from Laravel.
class FakeNotificationRepository extends NotificationRepository {
  FakeNotificationRepository()
      : _notifications = List.of(NotificationsDemoData.notifications);

  final List<AppNotification> _notifications;

  @override
  Future<List<AppNotification>> fetch() async =>
      List.unmodifiable(_notifications);

  @override
  Future<void> markRead(String id) async {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> delete(String id) async {
    _notifications.removeWhere((item) => item.id == id);
  }

  @override
  Future<ListenAudioEpisode> fetchAudio(String id) async {
    return ListenDemoData.episodes.firstWhere((item) => item.id == id);
  }
}
