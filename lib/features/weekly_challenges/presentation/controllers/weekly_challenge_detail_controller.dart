import 'package:flutter/foundation.dart';

/// In-memory UI state only; persistence belongs to a later backend phase.
class WeeklyChallengeDetailController extends ChangeNotifier {
  WeeklyChallengeDetailController({
    required this.totalDays,
    required Set<int> initiallyCompleted,
  }) : _completedDays = Set<int>.of(initiallyCompleted);

  final int totalDays;
  final Set<int> _completedDays;

  int get completedDays => _completedDays.length;
  double get progress =>
      (completedDays / totalDays).clamp(0.0, 1.0).toDouble();
  String get progressLabel => 'Day $completedDays of $totalDays';

  bool isCompleted(int day) => _completedDays.contains(day);

  void toggle(int day) {
    if (day < 1 || day > totalDays) return;
    if (!_completedDays.add(day)) _completedDays.remove(day);
    notifyListeners();
  }
}
