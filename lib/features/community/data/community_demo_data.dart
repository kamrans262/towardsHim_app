import '../domain/models/community_post.dart';

/// Approved Figma fixtures for the UI-only Community module.
abstract final class CommunityDemoData {
  static const currentUserId = 'sarah-johnson';
  static const currentUserName = 'Sarah Johnson';
  static const avatarAsset =
      'assets/images/community/community_user_avatar.jpg';
  static const description =
      'Share, encourage and grow together in faith';
  static const samplePost =
      'Today i was reminded that god’s timing are always perfect even when its hard to see. Always grateful for his kindness';

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
