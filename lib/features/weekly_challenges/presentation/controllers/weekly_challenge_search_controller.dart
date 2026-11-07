import 'package:flutter/foundation.dart';
import '../../domain/models/weekly_challenge.dart';

/// State controller for local challenge filtering.
class WeeklyChallengeSearchController extends ChangeNotifier {
  WeeklyChallengeSearchController(this._challenges);
  final List<WeeklyChallenge> _challenges;
  String _query = '';
  String get query => _query;

  void setQuery(String input) {
    final next = input.trim().toLowerCase();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  List<WeeklyChallenge> forCategory(WeeklyChallengeCategory category) {
    return _challenges.where((challenge) {
      if (challenge.category != category) return false;
      if (_query.isEmpty) return true;
      return challenge.title.toLowerCase().contains(_query) ||
          challenge.description.toLowerCase().contains(_query) ||
          challenge.datesLabel.toLowerCase().contains(_query) ||
          challenge.status.name.toLowerCase().contains(_query);
    }).toList(growable: false);
  }
}
