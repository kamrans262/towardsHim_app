class WeeklyDailyActivity {
  const WeeklyDailyActivity({required this.day, required this.text});

  final int day;
  final String text;
}

/// UI-only Figma detail fixture; dates are deliberately the reference dates.
abstract final class WeeklyChallengeDetailDemoData {
  static const heroAsset =
      'assets/images/weekly/weekly_detail_hero.webp';
  static const dates = 'Mar 10 – Mar 17';
  static const description =
      'Deepen your faith through daily intentional steps. This week, focus on spending time with god with his presence, feel him, living with purpose, and showing his love to others';

  static const initiallyCompletedDays = <int>{1, 2, 4};

  static const activities = <WeeklyDailyActivity>[
    WeeklyDailyActivity(
      day: 1,
      text: 'Read a short passage from scripture & reflect it on what means to you',
    ),
    WeeklyDailyActivity(
      day: 2,
      text: 'Spend 5 minutes in quite prayer',
    ),
    WeeklyDailyActivity(
      day: 3,
      text: 'Write down 3 things you are happy for today',
    ),
    WeeklyDailyActivity(
      day: 4,
      text: 'Share an encouragement with someone',
    ),
    WeeklyDailyActivity(
      day: 5,
      text: 'Read a short passage from scripture and reflect on it',
    ),
    WeeklyDailyActivity(
      day: 6,
      text: 'Spend intentional time encouraging a friend',
    ),
    WeeklyDailyActivity(
      day: 7,
      text: 'Reflect on the week and offer a prayer of gratitude',
    ),
  ];
}
