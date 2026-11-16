import '../../../../core/models/content_media.dart';

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
    this.days = const [],
    this.media = const [],
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
  final List<WeeklyChallengeDay> days;
  final List<ContentMedia> media;

  Set<int> get completedDayNumbers => days
      .where((day) => day.completed)
      .map((day) => day.day)
      .toSet();

  factory WeeklyChallenge.fromApi(Map<String, dynamic> json) {
    final completed = (json['completed_days'] as num?)?.toInt() ?? 0;
    final total = (json['total_days'] as num?)?.toInt() ?? 7;
    final rawDays = json['days'];
    final days = rawDays is List
        ? rawDays.map((item) => WeeklyChallengeDay.fromApi(
            Map<String, dynamic>.from(item as Map),
          )).toList(growable: false)
        : <WeeklyChallengeDay>[];
    final isCurrent = json['is_current'] == true;
    final start = DateTime.tryParse(json['start_date']?.toString() ?? '');
    final end = DateTime.tryParse(json['end_date']?.toString() ?? '');

    return WeeklyChallenge(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      description: json['instructions']?.toString() ?? '',
      imageAsset: 'assets/images/home/golden_hour_meditation.webp',
      startDate: start ?? DateTime(2000),
      endDate: end ?? start?.add(const Duration(days: 6)) ?? DateTime(2000),
      status: completed == total
          ? WeeklyChallengeStatus.completed
          : WeeklyChallengeStatus.current,
      completedDays: completed,
      totalDays: total,
      category: isCurrent
          ? WeeklyChallengeCategory.featured
          : WeeklyChallengeCategory.previous,
      days: days,
      media: ContentMedia.parseList(json['media']),
    );
  }

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

class WeeklyChallengeDay {
  const WeeklyChallengeDay({
    required this.day,
    required this.text,
    required this.completed,
    this.media = const [],
  });

  final int day;
  final String text;
  final bool completed;
  final List<ContentMedia> media;

  factory WeeklyChallengeDay.fromApi(Map<String, dynamic> json) =>
      WeeklyChallengeDay(
        day: (json['day'] as num).toInt(),
        text: json['text']?.toString() ?? '',
        completed: json['completed'] == true,
        media: ContentMedia.parseList(json['media']),
      );
}
