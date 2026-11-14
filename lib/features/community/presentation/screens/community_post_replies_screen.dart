import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_detail_page_header.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../models/community_replies_args.dart';
import '../widgets/community_post_card.dart';

/// The approved replies UI shows the selected server discussion.
/// Shared controller updates the feed after a successful reply.
class CommunityPostRepliesScreen extends StatefulWidget {
  const CommunityPostRepliesScreen({required this.args, super.key});

  final CommunityRepliesArgs args;

  @override
  State<CommunityPostRepliesScreen> createState() =>
      _CommunityPostRepliesScreenState();
}

class _CommunityPostRepliesScreenState extends State<CommunityPostRepliesScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _replyFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    widget.args.controller.loadThread(widget.args.postId);
  }

  Future<void> _hidePost(String id) async {
    try {
      await widget.args.controller.hidePost(id);
      if (mounted) Navigator.of(context).maybePop();
    } catch (error) {
      if (mounted) _notice('Unable to remove post: ' + error.toString());
    }
  }

  Future<void> _hideReply(String postId, String replyId) async {
    try {
      await widget.args.controller.hideReply(postId, replyId);
    } catch (error) {
      if (mounted) _notice('Unable to remove reply: ' + error.toString());
    }
  }

  void _notice(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  void dispose() {
    _textController.dispose();
    _replyFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitReply() async {
    if (_submitting) return;
    final body = _textController.text.trim();
    if (body.isEmpty) {
      _notice('Please write a reply.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final saved = await widget.args.controller.submitReply(widget.args.postId, body);
      if (!saved || !mounted) return;
      _textController.clear();
      _replyFocus.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      });
    } catch (error) {
      if (mounted) _notice('Unable to submit reply: ' + error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: const Key('community_post_replies_scaffold'),
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: widget.args.controller,
            builder: (context, _) {
              final post = widget.args.controller.postById(widget.args.postId);
              if (post == null) {
                return Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Return to Community'),
                  ),
                );
              }
              final replies = widget.args.controller.repliesFor(post.id);
              final totalReplies = widget.args.controller.totalRepliesFor(post.id);
              return CustomScrollView(
                key: const Key('community_replies_scroll'),
                controller: _scrollController,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSpacing.homeContentMaxWidth,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenHorizontal,
                            AppSpacing.screenTop,
                            AppSpacing.screenHorizontal,
                            AppSpacing.screenBottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppDetailPageHeader(
                                title: 'Post Replies',
                                onBack: () => Navigator.of(context).maybePop(),
                              ),
                              const SizedBox(height: 25),
                              CommunityPostCard(
                                key: Key('replies_original_${post.id}'),
                                post: post,
                                currentUserId: widget.args.controller.currentUserId,
                                onHide: _hidePost,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '$totalReplies ${totalReplies == 1 ? 'Reply' : 'Replies'}',
                                key: const Key('community_reply_heading'),
                                style: AppTypography.sectionHeading,
                              ),
                              const SizedBox(height: 15),
                              if (widget.args.controller.loadingThread)
                                const Center(child: CircularProgressIndicator())
                              else if (widget.args.controller.threadError != null)
                                Column(
                                  children: [
                                    Text(widget.args.controller.threadError!,
                                      style: AppTypography.homeSecondary),
                                    TextButton(
                                      onPressed: () => widget.args.controller.loadThread(post.id),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                )
                              else
                              for (var i = 0; i < replies.length; i++) ...[
                                if (i != 0) const SizedBox(height: 15),
                                CommunityPostCard(
                                  key: Key('reply_card_${replies[i].id}'),
                                  post: replies[i].asPostCardData(),
                                  showRepliesIndicator: false,
                                  currentUserId: widget.args.controller.currentUserId,
                                  onHide: (id) => _hideReply(post.id, id),
                                ),
                              ],
                              const SizedBox(height: 15),
                              AppTextField(
                                key: const Key('community_reply_input_container'),
                                fieldKey: const Key('community_reply_input'),
                                label: 'Write a reply......',
                                controller: _textController,
                                focusNode: _replyFocus,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) { _submitReply(); },
                                height: 58,
                                backgroundColor: AppColors.outlinedButtonBackground,
                                borderColor: AppColors.cardBorder,
                              ),
                              const SizedBox(height: 25),
                              AppButton(
                                key: const Key('community_submit_reply_button'),
                                label: 'Submit Reply',
                                onPressed: _submitting ? null : _submitReply,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
