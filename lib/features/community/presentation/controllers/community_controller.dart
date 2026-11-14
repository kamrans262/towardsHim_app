import 'package:flutter/foundation.dart';

import '../../../auth/data/auth_repository.dart';
import '../../data/community_repository.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_reply.dart';

/// Community state backed by Laravel; local "Hide" affects only this session.
class CommunityController extends ChangeNotifier {
  CommunityController({
    CommunityRepository? repository,
    String? currentUserId,
  })  : _repository = repository ?? const CommunityRepository(),
        _currentUserId = currentUserId ??
            AuthRepository.instance.user?['id']?.toString() ?? '';

  final CommunityRepository _repository;
  final String _currentUserId;
  final List<CommunityPost> _posts = [];
  final Map<String, List<CommunityReply>> _repliesByPost = {};
  final Map<String, int> _totalReplies = {};
  final Set<String> _hiddenPosts = {};
  final Map<String, Set<String>> _hiddenReplies = {};
  CommunityFeedTab _selectedTab = CommunityFeedTab.allPosts;
  bool _loadingPosts = false;
  bool _loadingThread = false;
  bool _disposed = false;
  String? _feedError;
  String? _threadError;

  String get currentUserId => _currentUserId;
  CommunityFeedTab get selectedTab => _selectedTab;
  bool get loadingPosts => _loadingPosts;
  bool get loadingThread => _loadingThread;
  String? get feedError => _feedError;
  String? get threadError => _threadError;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  List<CommunityPost> get visiblePosts => List<CommunityPost>.unmodifiable(
        _posts.where((post) =>
            !_hiddenPosts.contains(post.id) &&
            (_selectedTab == CommunityFeedTab.allPosts ||
                post.authorId == _currentUserId)),
      );

  void selectTab(CommunityFeedTab tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    _notify();
  }

  Future<void> loadPosts() async {
    if (_loadingPosts) return;
    _loadingPosts = true;
    _feedError = null;
    _notify();
    try {
      final posts = await _repository.fetchPosts();
      _posts
        ..clear()
        ..addAll(posts);
    } catch (error) {
      _feedError = error.toString();
    } finally {
      _loadingPosts = false;
      _notify();
    }
  }

  Future<bool> createPost(String rawText) async {
    final body = rawText.trim();
    if (body.isEmpty) return false;
    final post = await _repository.createPost(body);
    _posts.insert(0, post);
    _selectedTab = CommunityFeedTab.myPosts;
    _notify();
    return true;
  }

  CommunityPost? postById(String postId) {
    for (final post in _posts) {
      if (post.id == postId && !_hiddenPosts.contains(post.id)) return post;
    }
    return null;
  }

  List<CommunityReply> repliesFor(String postId) =>
      List<CommunityReply>.unmodifiable(
        (_repliesByPost[postId] ?? const <CommunityReply>[])
            .where((reply) => !(_hiddenReplies[postId]?.contains(reply.id) ?? false)),
      );

  int totalRepliesFor(String postId) =>
      _totalReplies[postId] ?? postById(postId)?.replyCount ?? 0;

  Future<void> loadThread(String postId) async {
    if (_loadingThread) return;
    _loadingThread = true;
    _threadError = null;
    _notify();
    try {
      final thread = await _repository.fetchThread(postId);
      _repliesByPost[postId] = List<CommunityReply>.of(thread.replies);
      _totalReplies[postId] = thread.totalReplies;
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index >= 0) {
        _posts[index] = thread.post;
      }
    } catch (error) {
      _threadError = error.toString();
    } finally {
      _loadingThread = false;
      _notify();
    }
  }

  Future<bool> submitReply(String postId, String rawText) async {
    final body = rawText.trim();
    if (body.isEmpty || postById(postId) == null) return false;
    final reply = await _repository.createReply(postId, body);
    _repliesByPost.putIfAbsent(postId, () => []).add(reply);
    _totalReplies[postId] = totalRepliesFor(postId) + 1;
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index >= 0) {
      _posts[index] =
          _posts[index].copyWith(replyCount: _totalReplies[postId]);
    }
    _notify();
    return true;
  }

  Future<void> hidePost(String postId) async {
    final post = postById(postId);
    if (post == null) return;
    if (_currentUserId.isNotEmpty && post.authorId == _currentUserId) {
      await _repository.removePost(postId);
    }
    _hiddenPosts.add(postId);
    _posts.removeWhere((item) => item.id == postId);
    _repliesByPost.remove(postId);
    _totalReplies.remove(postId);
    _notify();
  }

  Future<void> hideReply(String postId, String replyId) async {
    final thread = _repliesByPost[postId];
    if (thread == null) return;
    CommunityReply? reply;
    for (final item in thread) {
      if (item.id == replyId) {
        reply = item;
        break;
      }
    }
    if (reply == null) return;
    final own = _currentUserId.isNotEmpty && reply.authorId == _currentUserId;
    if (own) {
      await _repository.removeReply(postId, replyId);
      thread.removeWhere((item) => item.id == replyId);
      final current = totalRepliesFor(postId);
      _totalReplies[postId] = current > 0 ? current - 1 : 0;
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index >= 0) {
        _posts[index] = _posts[index].copyWith(replyCount: _totalReplies[postId]);
      }
    } else {
      _hiddenReplies.putIfAbsent(postId, () => {}).add(replyId);
    }
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
