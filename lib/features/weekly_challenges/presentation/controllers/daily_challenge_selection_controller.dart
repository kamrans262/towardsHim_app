import 'package:flutter/foundation.dart';

/// Local-only selection state; no persistence or backend interactions.
class DailyChallengeSelectionController extends ChangeNotifier {
  DailyChallengeSelectionController(this._selectedOptionId);

  String _selectedOptionId;
  String get selectedOptionId => _selectedOptionId;

  bool isSelected(String id) => _selectedOptionId == id;

  void select(String id) {
    if (_selectedOptionId == id) return;
    _selectedOptionId = id;
    notifyListeners();
  }
}
