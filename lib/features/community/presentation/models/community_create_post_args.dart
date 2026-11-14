/// Submit through the existing Create Post screen so a failed request
/// never discards the member's typed draft.
class CommunityCreatePostArgs {
  const CommunityCreatePostArgs({required this.onPublish});

  final Future<void> Function(String body) onPublish;
}
