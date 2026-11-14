import 'community_post.dart';

/// A reply belongs to one Community post, but shares the same author UI.
class CommunityReply {
  const CommunityReply({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.avatarAsset,
    required this.body,
    required this.createdAt,
    required this.timeLabel,
    this.avatarUrl,
  });

  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String avatarAsset;
  final String body;
  final DateTime createdAt;
  final String timeLabel;
  final String? avatarUrl;

  factory CommunityReply.fromApi(Map<String, dynamic> json) {
    final stamp = DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal()
        ?? DateTime.now();
    return CommunityReply(
      id: json['id'].toString(),
      postId: json['post_id'].toString(),
      authorId: json['author_id'].toString(),
      authorName: json['author_name']?.toString() ?? 'Member',
      avatarAsset: 'assets/images/community/community_profile_portrait.jpg',
      avatarUrl: json['author_avatar_url']?.toString(),
      body: json['body']?.toString() ?? '',
      createdAt: stamp,
      timeLabel: CommunityTimeLabel.fromDate(stamp),
    );
  }

  CommunityPost asPostCardData() => CommunityPost(
        id: id,
        authorId: authorId,
        authorName: authorName,
        avatarAsset: avatarAsset,
        body: body,
        createdAt: createdAt,
        timeLabel: timeLabel,
        replyCount: 0,
        avatarUrl: avatarUrl,
      );
}
