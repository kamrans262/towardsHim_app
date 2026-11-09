import 'package:flutter/foundation.dart';

import '../../data/community_demo_data.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_reply.dart';

/// Local in-memory Community state; no backend or persistence.
class CommunityController extends ChangeNotifier {
  CommunityController()
      : _posts = List<CommunityPost>.of(CommunityDemoData.posts);

  final List<CommunityPost> _posts;
  CommunityFeedTab _selectedTab = CommunityFeedTab.allPosts;
  int _newPostCounter = 0;
  int _newReplyCounter = 0;
  final Map<String, List<CommunityReply>> _repliesByPost = {};
  final Map<String, int> _totalReplies = {};

  CommunityFeedTab get selectedTab => _selectedTab;

  List<CommunityPost> get visiblePosts => List<CommunityPost>.unmodifiable(
        _posts.where(
          (post) =>
              _selectedTab == CommunityFeedTab.allPosts ||
              post.authorId == CommunityDemoData.currentUserId,
        ),
      );

  void selectTab(CommunityFeedTab tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  void createPost(String rawText) {
    final body = rawText.trim();
    if (body.isEmpty) return;
    _newPostCounter++;
    _posts.insert(
      0,
      CommunityPost(
        id: 'community-local-$_newPostCounter',
        authorId: CommunityDemoData.currentUserId,
        authorName: CommunityDemoData.currentUserName,
        avatarAsset: CommunityDemoData.avatarAsset,
        body: body,
        createdAt: DateTime.now(),
        timeLabel: 'Just now',
        replyCount: 0,
      ),
    );
    _selectedTab = CommunityFeedTab.myPosts;
    notifyListeners();
  }


  CommunityPost? postById(String postId) {
    for (final post in _posts) {
      if (post.id == postId) return post;
    }
    return null;
  }

  void _ensureThread(String postId) {
    if (_repliesByPost.containsKey(postId)) return;
    final seeded = CommunityDemoData.posts.any((post) => post.id == postId);
    _repliesByPost[postId] = seeded
        ? [
            for (final reply in CommunityDemoData.sampleReplies)
              CommunityReply(
                id: '$postId-${reply.id}',
                postId: postId,
                authorId: reply.authorId,
                authorName: reply.authorName,
                avatarAsset: reply.avatarAsset,
                body: reply.body,
                createdAt: reply.createdAt,
                timeLabel: reply.timeLabel,
              ),
          ]
        : <CommunityReply>[];
    _totalReplies[postId] = seeded ? CommunityDemoData.initialReplyTotal : 0;
  }

  List<CommunityReply> repliesFor(String postId) {
    _ensureThread(postId);
    return List<CommunityReply>.unmodifiable(_repliesByPost[postId]!);
  }

  int totalRepliesFor(String postId) {
    _ensureThread(postId);
    return _totalReplies[postId]!;
  }

  bool submitReply(String postId, String rawText) {
    final body = rawText.trim();
    if (body.isEmpty) return false;
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex < 0) return false;
    _ensureThread(postId);
    _newReplyCounter++;
    _repliesByPost[postId]!.add(
      CommunityReply(
        id: '$postId-local-reply-$_newReplyCounter',
        postId: postId,
        authorId: CommunityDemoData.currentUserId,
        authorName: CommunityDemoData.currentUserName,
        avatarAsset: CommunityDemoData.avatarAsset,
        body: body,
        createdAt: DateTime.now(),
        timeLabel: 'Just now',
      ),
    );
    _totalReplies[postId] = _totalReplies[postId]! + 1;
    _posts[postIndex] = _posts[postIndex].copyWith(
      replyCount: _posts[postIndex].replyCount + 1,
    );
    notifyListeners();
    return true;
  }

  void hideReply(String postId, String replyId) {
    _ensureThread(postId);
    final thread = _repliesByPost[postId]!;
    final previous = thread.length;
    thread.removeWhere((reply) => reply.id == replyId);
    if (thread.length == previous) return;
    _totalReplies[postId] = (_totalReplies[postId]! - 1).clamp(0, 1000000).toInt();
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index >= 0) {
      _posts[index] = _posts[index].copyWith(
        replyCount: (_posts[index].replyCount - 1).clamp(0, 1000000).toInt(),
      );
    }
    notifyListeners();
  }

  void hidePost(String id) {
    final originalLength = _posts.length;
    _posts.removeWhere((post) => post.id == id);
    _repliesByPost.remove(id);
    _totalReplies.remove(id);
    if (_posts.length != originalLength) notifyListeners();
  }
}
