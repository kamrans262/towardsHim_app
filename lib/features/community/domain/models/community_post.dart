enum CommunityFeedTab { allPosts, myPosts }

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.avatarAsset,
    required this.body,
    required this.createdAt,
    required this.timeLabel,
    required this.replyCount,
    this.avatarUrl,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String avatarAsset;
  final String body;
  final DateTime createdAt;
  final String timeLabel;
  final int replyCount;
  final String? avatarUrl;

  factory CommunityPost.fromApi(Map<String, dynamic> json) {
    final stamp = DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal()
        ?? DateTime.now();
    return CommunityPost(
      id: json['id'].toString(),
      authorId: json['author_id'].toString(),
      authorName: json['author_name']?.toString() ?? 'Member',
      avatarAsset: 'assets/images/community/community_profile_portrait.jpg',
      avatarUrl: json['author_avatar_url']?.toString(),
      body: json['body']?.toString() ?? '',
      createdAt: stamp,
      timeLabel: CommunityTimeLabel.fromDate(stamp),
      replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
    );
  }

  CommunityPost copyWith({int? replyCount}) => CommunityPost(
        id: id,
        authorId: authorId,
        authorName: authorName,
        avatarAsset: avatarAsset,
        body: body,
        createdAt: createdAt,
        timeLabel: timeLabel,
        replyCount: replyCount ?? this.replyCount,
        avatarUrl: avatarUrl,
      );
}


/// Human-readable relative times without changing the approved card typography.
abstract final class CommunityTimeLabel {
  static String fromDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.isNegative || difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) {
      final n = difference.inMinutes;
      return n.toString() + (n == 1 ? ' minute ago' : ' minutes ago');
    }
    if (difference.inHours < 24) {
      final n = difference.inHours;
      return n.toString() + (n == 1 ? ' hour ago' : ' hours ago');
    }
    if (difference.inDays < 7) {
      final n = difference.inDays;
      return n.toString() + (n == 1 ? ' day ago' : ' days ago');
    }
    return date.day.toString().padLeft(2, '0') + '/' +
        date.month.toString().padLeft(2, '0') + '/' +
        date.year.toString();
  }
}
