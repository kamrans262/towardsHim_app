enum ContentMediaType { text, image, audio, video }

/// A published, ordered content block shared by Listen and weekly challenges.
class ContentMedia {
  const ContentMedia({
    required this.id,
    required this.type,
    this.text,
    this.url,
  });

  final String id;
  final ContentMediaType type;
  final String? text;
  final String? url;

  factory ContentMedia.fromApi(Map<String, dynamic> json) {
    final name = json['type']?.toString() ?? '';
    final type = ContentMediaType.values.firstWhere(
      (value) => value.name == name,
      orElse: () => ContentMediaType.text,
    );
    final rawUrl = json['url']?.toString();
    final parsed = rawUrl == null ? null : Uri.tryParse(rawUrl);
    return ContentMedia(
      id: json['id']?.toString() ?? '',
      type: type,
      text: json['text']?.toString(),
      url: parsed != null && (parsed.scheme == 'https' || parsed.scheme == 'http')
          ? rawUrl
          : null,
    );
  }

  static List<ContentMedia> parseList(dynamic source) {
    if (source is! List) return const [];
    return source.whereType<Map>().map((item) =>
        ContentMedia.fromApi(Map<String, dynamic>.from(item)),
    ).toList(growable: false);
  }

  bool get hasPlayableFile => url != null && url!.isNotEmpty;
}
