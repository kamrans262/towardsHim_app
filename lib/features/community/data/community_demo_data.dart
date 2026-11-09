import '../domain/models/community_post.dart';
import '../domain/models/community_reply.dart';

/// Approved Figma fixtures for the UI-only Community module.
abstract final class CommunityDemoData {
  static const currentUserId = 'sarah-johnson';
  static const currentUserName = 'Sarah Johnson';
  static const avatarAsset =
      'assets/images/community/community_profile_portrait.jpg';
  static const description =
      'Share, encourage and grow together in faith';
  static const samplePost =
      'Today i was reminded that god’s timing are always perfect even when its hard to see. Always grateful for his kindness';


  /// Figma shows 3 visible cards under the heading "5 Replies". The total
  /// includes two additional replies not shown in the initial mock list.
  static const int initialReplyTotal = 5;
  static const replyText =
      'This is such a great reminder. he truly knows what’s best for us';

  static final sampleReplies = List<CommunityReply>.unmodifiable([
    for (var i = 1; i <= 3; i++)
      CommunityReply(
        id: 'community-demo-reply-$i',
        postId: 'demo',
        authorId: 'claudia-johns',
        authorName: 'Claudia johns',
        avatarAsset: avatarAsset,
        body: replyText,
        createdAt: DateTime(2026, 11, 9, 12),
        timeLabel: '2 hours ago',
      ),
  ]);

  static final posts = List<CommunityPost>.unmodifiable([
    CommunityPost(
      id: 'community-001',
      authorId: currentUserId,
      authorName: currentUserName,
      avatarAsset: avatarAsset,
      body: samplePost,
      createdAt: DateTime(2026, 11, 9, 12),
      timeLabel: '2 hours ago',
      replyCount: 3,
    ),
    CommunityPost(
      id: 'community-002',
      authorId: 'sarah-johnson-2',
      authorName: currentUserName,
      avatarAsset: avatarAsset,
      body: samplePost,
      createdAt: DateTime(2026, 11, 9, 12),
      timeLabel: '2 hours ago',
      replyCount: 3,
    ),
    CommunityPost(
      id: 'community-003',
      authorId: currentUserId,
      authorName: currentUserName,
      avatarAsset: avatarAsset,
      body: samplePost,
      createdAt: DateTime(2026, 11, 9, 12),
      timeLabel: '2 hours ago',
      replyCount: 3,
    ),
  ]);
}
