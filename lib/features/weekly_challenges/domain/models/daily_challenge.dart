import '../../../../core/models/content_media.dart';

enum DailyChallengeOptionType { taste, see, share }

class DailyChallengeOption {
  const DailyChallengeOption({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
  });

  final String id;
  final DailyChallengeOptionType type;
  final String title;
  final String description;
}

class DailyChallenge {
  const DailyChallenge({
    required this.id,
    required this.subtitle,
    required this.title,
    required this.description,
    required this.options,
    required this.initialSelectedOptionId,
    this.media = const [],
  });

  final String id;
  final String subtitle;
  final String title;
  final String description;
  final List<DailyChallengeOption> options;
  final String initialSelectedOptionId;
  final List<ContentMedia> media;
}
