import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/features/weekly_challenges/domain/models/weekly_challenge.dart';
import 'support/fake_challenge_repository.dart';

void main() {
  test('Challenge API model retains all seven activities and member progress', () {
    final challenge = WeeklyChallenge.fromApi({
      'id': 91,
      'title': 'Seven Days of Gratitude',
      'instructions': 'Find something to be grateful for daily.',
      'start_date': '2026-11-15',
      'end_date': '2026-11-21',
      'is_current': true,
      'completed_days': 2,
      'total_days': 7,
      'days': [
        for (var day = 1; day <= 7; day++)
          {'day': day, 'text': 'Practice $day', 'completed': day == 1 || day == 3},
      ],
    });

    expect(challenge.id, '91');
    expect(challenge.category, WeeklyChallengeCategory.featured);
    expect(challenge.completedDays, 2);
    expect(challenge.days.length, 7);
    expect(challenge.completedDayNumbers, {1, 3});
    expect(challenge.progress, closeTo(2 / 7, 0.00001));
    expect(challenge.description, 'Find something to be grateful for daily.');
    expect(challenge.datesLabel, 'November 15 – November 21');
  });

  test('Challenge repository test double preserves checkbox changes', () async {
    final repository = FakeChallengeRepository();
    addTearDown(repository.dispose);
    final before = await repository.detail('weekly-current');
    expect(before.completedDayNumbers, {1, 2, 4});
    await repository.setCompleted('weekly-current', 3, true);
    final after = await repository.detail('weekly-current');
    expect(after.completedDayNumbers, {1, 2, 3, 4});
    await repository.setCompleted('weekly-current', 1, false);
    final undone = await repository.detail('weekly-current');
    expect(undone.completedDayNumbers, {2, 3, 4});
  });

  test('Older published challenges remain in previous category', () {
    final past = WeeklyChallenge.fromApi({
      'id': 32,
      'title': 'Last Week',
      'instructions': 'Read and pray.',
      'start_date': '2026-11-08',
      'end_date': '2026-11-14',
      'is_current': false,
      'completed_days': 0,
      'total_days': 7,
    });
    expect(past.category, WeeklyChallengeCategory.previous);
    expect(past.progress, 0);
    expect(past.completedDayNumbers, isEmpty);
  });
}
