import 'package:flutter/foundation.dart';

import '../../domain/models/home_models.dart';

/// Navigation selection state is local to the signed-in demo shell.
/// IndexedStack keeps the Home scroll/audio demo state alive between tabs.
class HomeNavigationController extends ChangeNotifier {
  HomeTab _selected = HomeTab.home;

  HomeTab get selected => _selected;

  void select(HomeTab tab) {
    if (tab == _selected) return;
    _selected = tab;
    notifyListeners();
  }
}
