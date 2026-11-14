import 'package:towards_him_app/features/weekly_challenges/data/challenge_repository.dart';
import 'package:towards_him_app/features/weekly_challenges/data/weekly_challenge_demo_data.dart';
import 'package:towards_him_app/features/weekly_challenges/data/weekly_challenge_detail_demo_data.dart';
import 'package:towards_him_app/features/weekly_challenges/domain/models/weekly_challenge.dart';

/// Local, deterministic API substitute for widget tests only.
class FakeChallengeRepository extends ChallengeRepository {
  final Set<int> _completed = {1, 2, 4};

  WeeklyChallenge _withDailyActivities(WeeklyChallenge source) {
    final days = WeeklyChallengeDetailDemoData.activities.map((activity) =>
        WeeklyChallengeDay(
          day: activity.day,
          text: activity.text,
          completed: source.id == 'weekly-current'
              ? _completed.contains(activity.day)
              : true,
        )).toList(growable: false);
    final count = days.where((day) => day.completed).length;
    return WeeklyChallenge(
      id: source.id,
      title: source.title,
      description: source.description,
      imageAsset: source.imageAsset,
      startDate: source.startDate,
      endDate: source.endDate,
      status: count == 7 ? WeeklyChallengeStatus.completed : WeeklyChallengeStatus.current,
      completedDays: count,
      totalDays: 7,
      category: source.category,
      days: days,
    );
  }

  @override
  Future<List<WeeklyChallenge>> list() async =>
      WeeklyChallengeDemoData.challenges
          .map(_withDailyActivities).toList(growable: false);

  @override
  Future<WeeklyChallenge> detail(String id) async =>
      _withDailyActivities(
        WeeklyChallengeDemoData.challenges.firstWhere(
          (item) => item.id == id,
        ),
      );

  @override
  Future<void> setCompleted(String challengeId, int day, bool completed) async {
    if (challengeId == 'weekly-current') {
      if (completed) {
        _completed.add(day);
      } else {
        _completed.remove(day);
      }
    }
    notifyListeners();
  }
}
