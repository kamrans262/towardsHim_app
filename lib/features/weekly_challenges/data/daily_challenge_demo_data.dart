import '../domain/models/daily_challenge.dart';

/// One approved Daily Challenge fixture, shared by local activity previews.
abstract final class DailyChallengeDemoData {
  static const october8 = DailyChallenge(
    id: 'daily-october-8',
    subtitle: 'October 8 – Daily Challenge',
    title: 'Taste, See or Share',
    description:
        'Take time to enjoy something you love and appreciate the simple pleasures God has placed in your life. Be mindful of the blessings you often overlook, and let each moment remind you of His goodness and generosity.',
    initialSelectedOptionId: 'share',
    options: <DailyChallengeOption>[
      DailyChallengeOption(
        id: 'taste',
        type: DailyChallengeOptionType.taste,
        title: 'Taste',
        description: 'Explore through taste',
      ),
      DailyChallengeOption(
        id: 'see',
        type: DailyChallengeOptionType.see,
        title: 'See',
        description: 'Explore through observations',
      ),
      DailyChallengeOption(
        id: 'share',
        type: DailyChallengeOptionType.share,
        title: 'Share',
        description: 'Share your experience with others on this journey',
      ),
    ],
  );

  // Only one day detail is approved so far. Each weekly demo row previews it.
  static DailyChallenge forDay(int day) {
    assert(day >= 1 && day <= 7);
    return october8;
  }
}
