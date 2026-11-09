import 'package:flutter/foundation.dart';

import '../../data/notifications_demo_data.dart';
import '../../domain/models/app_notification.dart';

/// Lives in the Home shell, so local changes survive returning from a tab.
class NotificationsController extends ChangeNotifier {
  NotificationsController()
      : _items = List<AppNotification>.of(NotificationsDemoData.notifications);

  final List<AppNotification> _items;
  String? _openId;

  List<AppNotification> get notifications => List<AppNotification>.unmodifiable(_items);
  String? get openId => _openId;

  void revealDelete(String id) {
    if (!_items.any((item) => item.id == id) || _openId == id) return;
    _openId = id;
    notifyListeners();
  }

  void closeDelete({String? id}) {
    if (_openId == null || (id != null && _openId != id)) return;
    _openId = null;
    notifyListeners();
  }

  void delete(String id) {
    final before = _items.length;
    _items.removeWhere((item) => item.id == id);
    if (_openId == id) _openId = null;
    if (_items.length != before) notifyListeners();
  }

  void markRead(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0 || _items[index].isRead) return;
    _items[index] = _items[index].copyWith(isRead: true);
    notifyListeners();
  }
}
