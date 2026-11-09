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
  });

  final String id;
  final String authorId;
  final String authorName;
  final String avatarAsset;
  final String body;
  final DateTime createdAt;
  final String timeLabel;
  final int replyCount;
}
