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
      );
}
