import '../../home/data/home_demo_data.dart';
import '../domain/models/weekly_challenge.dart';

/// Static Figma-matching data, intentionally independent of the current date.
abstract final class WeeklyChallengeDemoData {
  static const description =
      'Take a new step each week to grow in faith, to grow the connection that is need to be fixed, to build healthy habits and move closer to him';

  static final challenges = List<WeeklyChallenge>.unmodifiable([
    WeeklyChallenge(
      id: 'weekly-current',
      title: 'Toward HIM 3',
      description: 'Deepen your faith through daily intentional steps',
      imageAsset: HomeDemoData.meditationAsset,
      startDate: DateTime(2026, 3, 3),
      endDate: DateTime(2026, 3, 10),
      status: WeeklyChallengeStatus.current,
      completedDays: 3,
      totalDays: 7,
      category: WeeklyChallengeCategory.featured,
    ),
    for (var i = 1; i <= 2; i++)
      WeeklyChallenge(
        id: 'weekly-completed-$i',
        title: 'Toward HIM 3',
        description: 'Deepen your faith through daily intentional steps',
        imageAsset: HomeDemoData.meditationAsset,
        startDate: DateTime(2026, 3, 3),
        endDate: DateTime(2026, 3, 10),
        status: WeeklyChallengeStatus.completed,
        completedDays: 7,
        totalDays: 7,
        category: WeeklyChallengeCategory.featured,
      ),
    for (var i = 1; i <= 2; i++)
      WeeklyChallenge(
        id: 'weekly-previous-$i',
        title: 'Toward HIM 3',
        description: 'Deepen your faith through daily intentional steps',
        imageAsset: HomeDemoData.meditationAsset,
        startDate: DateTime(2026, 3, 3),
        endDate: DateTime(2026, 3, 10),
        status: WeeklyChallengeStatus.completed,
        completedDays: 7,
        totalDays: 7,
        category: WeeklyChallengeCategory.previous,
      ),
  ]);
}
