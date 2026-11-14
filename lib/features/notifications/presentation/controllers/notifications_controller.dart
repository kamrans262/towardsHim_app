import 'package:flutter/foundation.dart';

import '../../../listen/domain/models/listen_audio_episode.dart';
import '../../data/notification_repository.dart';
import '../../domain/models/app_notification.dart';

/// Member-specific notifications persist through Laravel after relaunch.
class NotificationsController extends ChangeNotifier {
  NotificationsController({NotificationRepository? repository})
      : _repository = repository ?? const NotificationRepository();

  final NotificationRepository _repository;
  final List<AppNotification> _items = [];
  String? _openId;
  bool _loading = false;
  String? _error;
  bool _disposed = false;

  List<AppNotification> get notifications => List.unmodifiable(_items);
  String? get openId => _openId;
  bool get loading => _loading;
  String? get error => _error;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    _notify();
    try {
      final notifications = await _repository.fetch();
      _items
        ..clear()
        ..addAll(notifications);
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      _notify();
    }
  }

  void revealDelete(String id) {
    if (!_items.any((item) => item.id == id) || _openId == id) return;
    _openId = id;
    _notify();
  }

  void closeDelete({String? id}) {
    if (_openId == null || (id != null && _openId != id)) return;
    _openId = null;
    _notify();
  }

  Future<void> deleteRemote(String id) => _repository.delete(id);

  Future<void> delete(String id) async {
    await deleteRemote(id);
    removeLocal(id);
  }

  void removeLocal(String id) {
    _items.removeWhere((item) => item.id == id);
    if (_openId == id) _openId = null;
    _notify();
  }

  Future<void> markRead(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0 || _items[index].isRead) return;
    await _repository.markRead(id);
    final freshIndex = _items.indexWhere((item) => item.id == id);
    if (freshIndex < 0) return;
    _items[freshIndex] = _items[freshIndex].copyWith(isRead: true);
    _notify();
  }

  Future<ListenAudioEpisode> loadAudio(String contentId) =>
      _repository.fetchAudio(contentId);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
