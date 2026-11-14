import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../auth/data/auth_repository.dart';
import '../domain/models/listen_audio_episode.dart';

/// Published audio is public to guests and signed-in members.
class AudioCatalogRepository {
  const AudioCatalogRepository();

  Future<List<ListenAudioEpisode>> fetchPublished() async {
    final episodes = <ListenAudioEpisode>[];
    var page = 1;
    var lastPage = 1;

    do {
      final uri = Uri.parse(AuthRepository.baseUrl + '/audio').replace(
        queryParameters: {'page': page.toString(), 'per_page': '50'},
      );
      final http.Response response;
      try {
        response = await http
            .get(uri, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 20));
      } catch (_) {
        throw const AudioCatalogException('Cannot load audio right now. Check your connection.');
      }
      if (response.statusCode != 200) {
        throw const AudioCatalogException('Audio is temporarily unavailable.');
      }

      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final items = (json['data'] as List).cast<Map<String, dynamic>>();
        episodes.addAll(items.map(ListenAudioEpisode.fromApi));
        final meta = (json['meta'] as Map<String, dynamic>?) ?? {};
        lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
        page++;
      } catch (_) {
        throw const AudioCatalogException('Invalid audio catalogue response.');
      }
    } while (page <= lastPage && page <= 20);

    return episodes;
  }
}

class AudioCatalogException implements Exception {
  const AudioCatalogException(this.message);
  final String message;
  @override
  String toString() => message;
}
