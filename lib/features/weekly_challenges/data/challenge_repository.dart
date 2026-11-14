import 'package:flutter/foundation.dart';

import '../../auth/data/auth_repository.dart';
import '../domain/models/weekly_challenge.dart';

/// The member's seven-day challenge data and personal progress.
class ChallengeRepository extends ChangeNotifier {
  ChallengeRepository();

  static final ChallengeRepository instance = ChallengeRepository();

  Future<List<WeeklyChallenge>> list() async {
    final response = await AuthRepository.instance.memberRequest(
      'GET', 'challenges',
    );
    final data = response['data'] as List;
    return data.map((item) => WeeklyChallenge.fromApi(
      Map<String, dynamic>.from(item as Map),
    )).toList(growable: false);
  }

  Future<WeeklyChallenge> detail(String id) async {
    final response = await AuthRepository.instance.memberRequest(
      'GET', 'challenges/$id',
    );
    return WeeklyChallenge.fromApi(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<void> setCompleted(
    String challengeId, int day, bool completed,
  ) async {
    await AuthRepository.instance.memberRequest(
      'PUT', 'challenges/$challengeId/days/$day',
      body: {'completed': completed},
    );
    notifyListeners(); // Refresh weekly list after saving.
  }
}
