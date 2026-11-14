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
      );
}
