import 'package:flutter/foundation.dart';

import '../../data/community_demo_data.dart';
import '../../domain/models/community_post.dart';

/// Local in-memory Community state; no backend or persistence.
class CommunityController extends ChangeNotifier {
  CommunityController()
      : _posts = List<CommunityPost>.of(CommunityDemoData.posts);

  final List<CommunityPost> _posts;
  CommunityFeedTab _selectedTab = CommunityFeedTab.allPosts;
  int _newPostCounter = 0;

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

  void hidePost(String id) {
    final originalLength = _posts.length;
    _posts.removeWhere((post) => post.id == id);
    if (_posts.length != originalLength) notifyListeners();
  }
}
