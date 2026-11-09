import '../controllers/community_controller.dart';

/// Keeps the selected thread bound to the existing in-memory Community state.
class CommunityRepliesArgs {
  const CommunityRepliesArgs({
    required this.postId,
    required this.controller,
  });

  final String postId;
  final CommunityController controller;
}
