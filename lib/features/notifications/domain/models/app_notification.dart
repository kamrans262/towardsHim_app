class AppNotification {
  const AppNotification({
    required this.id,
    required this.contentId,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.category,
    required this.createdAt,
    required this.dateLabel,
    required this.isRead,
    this.artworkUrl,
    this.targetType,
    this.dayNumber,
  });

  final String id;
  final String contentId;
  final String title;
  final String description;
  final String imageAsset;
  final String category;
  final DateTime createdAt;
  final String dateLabel;
  final bool isRead;
  final String? artworkUrl;
  /// Optional destination metadata for non-audio notification types.
  /// Existing Laravel publications default to their category (audio).
  final String? targetType;
  final int? dayNumber;

  String get destination {
    final type = (targetType ?? category).trim().toLowerCase();
    if (type.contains('community') || type.contains('discussion') ||
        type.contains('post')) return 'community';
    if (type.contains('daily') || type.contains('day')) return 'daily';
    if (type.contains('challenge') || type.contains('weekly')) return 'weekly';
    return 'audio';
  }

  factory AppNotification.fromApi(Map<String, dynamic> json) {
    final stamp = DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal()
        ?? DateTime.now();
    final days = DateTime.now().difference(stamp).inDays;
    final label = days == 0 ? 'Today' : (days == 1 ? 'Yesterday' :
      stamp.day.toString().padLeft(2, '0') + '/' +
      stamp.month.toString().padLeft(2, '0') + '/' + stamp.year.toString());
    return AppNotification(
      id: json['id'].toString(),
      contentId: json['content_id'].toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageAsset: 'assets/images/home/golden_hour_meditation.webp',
      artworkUrl: json['artwork_url']?.toString(),
      category: json['category']?.toString() ?? 'Podcast',
      createdAt: stamp,
      dateLabel: label,
      isRead: json['is_read'] == true,
      targetType: json['target_type']?.toString() ??
          json['destination_type']?.toString(),
      dayNumber: int.tryParse(
        (json['day_number'] ?? json['day'])?.toString() ?? '',
      ),
    );
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        contentId: contentId,
        title: title,
        description: description,
        imageAsset: imageAsset,
        category: category,
        createdAt: createdAt,
        dateLabel: dateLabel,
        isRead: isRead ?? this.isRead,
        artworkUrl: artworkUrl,
        targetType: targetType,
        dayNumber: dayNumber,
      );
}
