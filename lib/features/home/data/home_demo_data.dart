import '../domain/models/home_models.dart';

/// Replace with repository / API data only in a future backend milestone.
abstract final class HomeDemoData {
  static const heroAsset =
      'assets/images/home/misty_sunrise_mountain_lake.webp';
  static const meditationAsset =
      'assets/images/home/golden_hour_meditation.webp';

  static const profile = HomeUserProfile(
    firstName: 'Sarah',
    greeting: 'Good Morning',
    scripture: '“Be still, and know that I am God”',
    scriptureReference: 'Psalm 46:10',
  );

  static const featured = HomeFeaturedContent(
    id: 'weekly-peace-01',
    category: 'Moving Toward HIM Mondays',
    title: 'Finding Peace in His Presence',
    description:
        'Take a few minutes today to be still, and remember that god is with you',
    imageAsset: heroAsset,
  );

  static const listening = HomeListeningProgress(
    id: 'audio-grateful-heart',
    title: 'Building a grateful heart',
    type: 'Audio',
    minutesRemaining: 18,
    progress: 0.38,
    imageAsset: meditationAsset,
  );

  static const quickAccess = <HomeQuickAccess>[
    HomeQuickAccess(
      type: HomeQuickType.podcast,
      title: 'Podcast',
      iconAsset: 'assets/icons/home/podcast.svg',
    ),
    HomeQuickAccess(
      type: HomeQuickType.meditation,
      title: 'Meditation',
      iconAsset: 'assets/icons/home/meditation.svg',
    ),
    HomeQuickAccess(
      type: HomeQuickType.prayer,
      title: 'Prayer',
      iconAsset: 'assets/icons/home/prayer.svg',
    ),
  ];

  static const recentActivities = <HomeRecentActivity>[
    HomeRecentActivity(
      id: 'recent-faith-01',
      title: 'Faith in difficult seasons',
      type: 'Podcast',
      status: 'Completed',
      imageAsset: meditationAsset,
      showCompletedIcon: true,
    ),
    HomeRecentActivity(
      id: 'recent-faith-02',
      title: 'Faith in difficult seasons',
      type: 'Podcast',
      status: 'Completed',
      imageAsset: meditationAsset,
      showCompletedIcon: false,
    ),
  ];

  static const navigation = <HomeNavigationItem>[
    HomeNavigationItem(
      tab: HomeTab.home,
      label: 'Home',
      iconAsset: 'assets/icons/navigation/home.svg',
    ),
    HomeNavigationItem(
      tab: HomeTab.listen,
      label: 'Listen',
      iconAsset: 'assets/icons/navigation/listen.svg',
    ),
    HomeNavigationItem(
      tab: HomeTab.towardHimThree,
      label: 'Towards HIM 3',
      iconAsset: 'assets/icons/navigation/toward_him_three.svg',
    ),
    HomeNavigationItem(
      tab: HomeTab.community,
      label: 'Community',
      iconAsset: 'assets/icons/navigation/community.svg',
    ),
    HomeNavigationItem(
      tab: HomeTab.store,
      label: 'Store',
      iconAsset: 'assets/icons/navigation/store.svg',
    ),
  ];

  // No external merchandise URL has been provided yet.
  static const String? merchandiseStoreUrl = null;
}
