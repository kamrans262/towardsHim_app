import 'package:towards_him_app/features/community/data/community_demo_data.dart';
import 'package:towards_him_app/features/community/data/community_repository.dart';
import 'package:towards_him_app/features/community/domain/models/community_post.dart';
import 'package:towards_him_app/features/community/domain/models/community_reply.dart';

/// Deterministic API substitute for M4 widget tests; never used in production.
class FakeCommunityRepository extends CommunityRepository {
  FakeCommunityRepository() : _posts = List.of(CommunityDemoData.posts);

  final List<CommunityPost> _posts;
  final Map<String, List<CommunityReply>> _threads = {};
  int _postCounter = 0;
  int _replyCounter = 0;

  @override
  Future<List<CommunityPost>> fetchPosts() async =>
      List.unmodifiable(_posts);

  @override
  Future<CommunityPost> createPost(String body) async {
    _postCounter++;
    final post = CommunityPost(
      id: 'new-post-' + _postCounter.toString(),
      authorId: CommunityDemoData.currentUserId,
      authorName: CommunityDemoData.currentUserName,
      avatarAsset: CommunityDemoData.avatarAsset,
      body: body.trim(),
      createdAt: DateTime.now(),
      timeLabel: 'Just now',
      replyCount: 0,
    );
    _posts.insert(0, post);
    return post;
  }

  List<CommunityReply> _thread(String postId) =>
      _threads.putIfAbsent(postId, () =>
          CommunityDemoData.posts.any((post) => post.id == postId)
              ? [
                  for (final reply in CommunityDemoData.sampleReplies)
                    CommunityReply(
                      id: postId + '-' + reply.id,
                      postId: postId,
                      authorId: reply.authorId,
                      authorName: reply.authorName,
                      avatarAsset: reply.avatarAsset,
                      body: reply.body,
                      createdAt: reply.createdAt,
                      timeLabel: reply.timeLabel,
                    ),
                ]
              : []);

  @override
  Future<CommunityThread> fetchThread(String postId) async {
    final post = _posts.firstWhere((item) => item.id == postId);
    final replies = _thread(postId);
    return CommunityThread(
      post: post.copyWith(replyCount: replies.length),
      replies: List.unmodifiable(replies),
      totalReplies: replies.length,
    );
  }

  @override
  Future<CommunityReply> createReply(String postId, String body) async {
    _replyCounter++;
    final reply = CommunityReply(
      id: 'new-reply-' + _replyCounter.toString(),
      postId: postId,
      authorId: CommunityDemoData.currentUserId,
      authorName: CommunityDemoData.currentUserName,
      avatarAsset: CommunityDemoData.avatarAsset,
      body: body.trim(),
      createdAt: DateTime.now(),
      timeLabel: 'Just now',
    );
    _thread(postId).add(reply);
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index >= 0) {
      _posts[index] = _posts[index].copyWith(replyCount: _thread(postId).length);
    }
    return reply;
  }

  @override
  Future<void> removePost(String id) async {
    _posts.removeWhere((post) => post.id == id);
    _threads.remove(id);
  }

  @override
  Future<void> removeReply(String postId, String replyId) async {
    _thread(postId).removeWhere((reply) => reply.id == replyId);
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index >= 0) {
      _posts[index] = _posts[index].copyWith(replyCount: _thread(postId).length);
    }
  }
}
