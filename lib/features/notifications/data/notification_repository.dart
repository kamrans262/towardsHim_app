import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../auth/data/auth_repository.dart';
import '../../listen/domain/models/listen_audio_episode.dart';
import '../domain/models/app_notification.dart';

/// Persisted member notifications. This is not a device-local mock collection.
class NotificationRepository {
  const NotificationRepository();

  Future<List<AppNotification>> fetch() async {
    final result = <AppNotification>[];
    var page = 1;
    var lastPage = 1;
    do {
      final payload = await AuthRepository.instance.memberRequest(
        'GET', 'notifications?page=' + page.toString() + '&per_page=50',
      );
      result.addAll((payload['data'] as List).map((item) =>
          AppNotification.fromApi(Map<String, dynamic>.from(item as Map))));
      final meta = Map<String, dynamic>.from(payload['meta'] as Map);
      lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
      page++;
    } while (page <= lastPage && page <= 50);
    return result;
  }

  Future<void> markRead(String id) async {
    await AuthRepository.instance.memberRequest('PATCH', 'notifications/$id/read');
  }

  Future<void> delete(String id) async {
    await AuthRepository.instance.memberRequest('DELETE', 'notifications/$id');
  }

  Future<ListenAudioEpisode> fetchAudio(String id) async {
    final uri = Uri.parse(AuthRepository.baseUrl + '/audio/' + Uri.encodeComponent(id));
    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw const AuthFailure('This audio is no longer available.');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ListenAudioEpisode.fromApi(
      Map<String, dynamic>.from(body['data'] as Map),
    );
  }
}
