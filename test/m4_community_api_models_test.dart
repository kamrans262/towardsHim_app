import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/features/community/domain/models/community_post.dart';
import 'package:towards_him_app/features/community/domain/models/community_reply.dart';
import 'package:towards_him_app/features/community/presentation/controllers/community_controller.dart';
import 'support/fake_community_repository.dart';

void main() {
  test('API post fields map to the existing card model', () {
    final post = CommunityPost.fromApi({
      'id': '81',
      'author_id': '7',
      'author_name': 'Member Name',
      'author_avatar_url': 'https://example.com/storage/avatars/7.jpg',
      'body': 'Today I am grateful.',
      'created_at': '2026-11-15T12:00:00+00:00',
      'reply_count': 4,
    });
    expect(post.id, '81');
    expect(post.authorId, '7');
    expect(post.authorName, 'Member Name');
    expect(post.replyCount, 4);
    expect(post.avatarUrl, contains('avatars/7.jpg'));
    expect(post.body, 'Today I am grateful.');
  });

  test('API reply maps to the shared post card without a reply button', () {
    final reply = CommunityReply.fromApi({
      'id': '5', 'post_id': '81', 'author_id': '9',
      'author_name': 'Claudia', 'author_avatar_url': null,
      'body': 'Amen', 'created_at': '2026-11-15T12:05:00+00:00',
    });
    final card = reply.asPostCardData();
    expect(card.id, '5');
    expect(card.body, 'Amen');
    expect(card.replyCount, 0);
    expect(card.authorName, 'Claudia');
  });

  test('My Posts filters by authenticated identity; others are locally hidden', () async {
    final repository = FakeCommunityRepository();
    final controller = CommunityController(
      repository: repository, currentUserId: 'sarah-johnson',
    );
    addTearDown(controller.dispose);
    await controller.loadPosts();
    expect(controller.visiblePosts.length, 3);
    controller.selectTab(CommunityFeedTab.myPosts);
    expect(controller.visiblePosts.length, 2);
    controller.selectTab(CommunityFeedTab.allPosts);
    await controller.hidePost('community-002');
    expect(controller.visiblePosts.length, 2);
    await controller.loadPosts();
    expect(controller.visiblePosts.length, 2);
    // Hide never asks the server to remove another person's post.
    expect((await repository.fetchPosts()).length, 3);
  });

  test('Deleting only your own reply leaves all other discussion replies', () async {
    final controller = CommunityController(
      repository: FakeCommunityRepository(),
      currentUserId: 'sarah-johnson',
    );
    addTearDown(controller.dispose);
    await controller.loadPosts();
    await controller.loadThread('community-001');
    expect(controller.totalRepliesFor('community-001'), 3);
    await controller.submitReply('community-001', 'My reply');
    expect(controller.totalRepliesFor('community-001'), 4);
    final id = controller.repliesFor('community-001').last.id;
    await controller.hideReply('community-001', id);
    expect(controller.totalRepliesFor('community-001'), 3);
    expect(controller.repliesFor('community-001').length, 3);
  });
}
