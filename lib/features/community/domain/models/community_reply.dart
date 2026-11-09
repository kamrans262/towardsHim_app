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
  });

  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String avatarAsset;
  final String body;
  final DateTime createdAt;
  final String timeLabel;

  CommunityPost asPostCardData() => CommunityPost(
        id: id,
        authorId: authorId,
        authorName: authorName,
        avatarAsset: avatarAsset,
        body: body,
        createdAt: createdAt,
        timeLabel: timeLabel,
        replyCount: 0,
      );
}
