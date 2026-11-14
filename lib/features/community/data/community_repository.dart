import '../../auth/data/auth_repository.dart';
import '../domain/models/community_post.dart';
import '../domain/models/community_reply.dart';

class CommunityThread {
  const CommunityThread({
    required this.post,
    required this.replies,
    required this.totalReplies,
  });
  final CommunityPost post;
  final List<CommunityReply> replies;
  final int totalReplies;
}

/// Authenticated API gateway; widgets never create or delete records locally.
class CommunityRepository {
  const CommunityRepository();

  Future<List<CommunityPost>> fetchPosts() async {
    final result = <CommunityPost>[];
    var page = 1;
    var lastPage = 1;
    do {
      final response = await AuthRepository.instance.memberRequest(
        'GET', 'community/posts?page=' + page.toString() + '&per_page=50',
      );
      final data = response['data'] as List;
      result.addAll(data.map((item) =>
          CommunityPost.fromApi(Map<String, dynamic>.from(item as Map))));
      final meta = Map<String, dynamic>.from(response['meta'] as Map);
      lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
      page++;
    } while (page <= lastPage && page <= 50);
    return result;
  }

  Future<CommunityPost> createPost(String body) async {
    final response = await AuthRepository.instance.memberRequest(
      'POST', 'community/posts', body: {'body': body.trim()},
    );
    return CommunityPost.fromApi(Map<String, dynamic>.from(response['data'] as Map));
  }

  Future<CommunityThread> fetchThread(String postId) async {
    var page = 1;
    var lastPage = 1;
    CommunityPost? post;
    var total = 0;
    final replies = <CommunityReply>[];
    do {
      final response = await AuthRepository.instance.memberRequest(
        'GET', 'community/posts/' + Uri.encodeComponent(postId) +
            '?page=' + page.toString() + '&per_page=100',
      );
      final data = Map<String, dynamic>.from(response['data'] as Map);
      post = CommunityPost.fromApi(Map<String, dynamic>.from(data['post'] as Map));
      replies.addAll((data['replies'] as List).map((reply) =>
          CommunityReply.fromApi(Map<String, dynamic>.from(reply as Map))));
      final meta = Map<String, dynamic>.from(response['meta'] as Map);
      total = (meta['total'] as num?)?.toInt() ?? replies.length;
      lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
      page++;
    } while (page <= lastPage && page <= 50);
    if (post == null) throw const AuthFailure('This discussion is unavailable.');
    return CommunityThread(post: post, replies: replies, totalReplies: total);
  }

  Future<CommunityReply> createReply(String postId, String body) async {
    final response = await AuthRepository.instance.memberRequest(
      'POST', 'community/posts/' + Uri.encodeComponent(postId) + '/replies',
      body: {'body': body.trim()},
    );
    return CommunityReply.fromApi(Map<String, dynamic>.from(response['data'] as Map));
  }

  Future<void> removePost(String postId) async {
    await AuthRepository.instance.memberRequest(
      'DELETE', 'community/posts/' + Uri.encodeComponent(postId),
    );
  }

  Future<void> removeReply(String postId, String replyId) async {
    await AuthRepository.instance.memberRequest(
      'DELETE', 'community/posts/' + Uri.encodeComponent(postId) +
          '/replies/' + Uri.encodeComponent(replyId),
    );
  }
}
