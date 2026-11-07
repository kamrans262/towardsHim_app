enum WeeklyChallengeStatus { current, completed }
enum WeeklyChallengeCategory { featured, previous }

class WeeklyChallenge {
  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.completedDays,
    required this.totalDays,
    required this.category,
  }) : assert(totalDays > 0),
       assert(completedDays >= 0),
       assert(completedDays <= totalDays);

  final String id;
  final String title;
  final String description;
  final String imageAsset;
  final DateTime startDate;
  final DateTime endDate;
  final WeeklyChallengeStatus status;
  final int completedDays;
  final int totalDays;
  final WeeklyChallengeCategory category;

  double get progress => (completedDays / totalDays).clamp(0.0, 1.0).toDouble();
  String get progressLabel => 'Day $completedDays of $totalDays';

  String get datesLabel {
    const months = <String>[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final start = months[startDate.month - 1] + ' ' + startDate.day.toString();
    final end = months[endDate.month - 1] + ' ' + endDate.day.toString();
    return start + ' – ' + end;
  }
}
