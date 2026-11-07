enum HomeTab { home, listen, towardHimThree, community, store }

enum HomeQuickType { podcast, meditation, prayer }

class HomeUserProfile {
  const HomeUserProfile({
    required this.firstName,
    required this.scripture,
    required this.scriptureReference,
    required this.greeting,
  });

  final String firstName;
  final String greeting;
  final String scripture;
  final String scriptureReference;
}

class HomeFeaturedContent {
  const HomeFeaturedContent({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.imageAsset,
  });

  final String id;
  final String category;
  final String title;
  final String description;
  final String imageAsset;
}

class HomeListeningProgress {
  const HomeListeningProgress({
    required this.id,
    required this.title,
    required this.type,
    required this.minutesRemaining,
    required this.progress,
    required this.imageAsset,
  });

  final String id;
  final String title;
  final String type;
  final int minutesRemaining;
  final double progress;
  final String imageAsset;
}

class HomeQuickAccess {
  const HomeQuickAccess({
    required this.type,
    required this.title,
    required this.iconAsset,
  });

  final HomeQuickType type;
  final String title;
  final String iconAsset;
}

class HomeRecentActivity {
  const HomeRecentActivity({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.imageAsset,
    required this.showCompletedIcon,
  });

  final String id;
  final String title;
  final String type;
  final String status;
  final String imageAsset;
  final bool showCompletedIcon;
}

class HomeNavigationItem {
  const HomeNavigationItem({
    required this.tab,
    required this.label,
    required this.iconAsset,
  });

  final HomeTab tab;
  final String label;
  final String iconAsset;
}
