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

/// UI-only replies for the selected community post. It uses the same
/// CommunityController that owns the feed so updates survive Back navigation.
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

  @override
  void dispose() {
    _textController.dispose();
    _replyFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitReply() {
    final body = _textController.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a reply.')),
      );
      return;
    }
    final didSubmit = widget.args.controller.submitReply(
      widget.args.postId,
      body,
    );
    if (!didSubmit) return;
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
                                onHide: (id) {
                                  widget.args.controller.hidePost(id);
                                  Navigator.of(context).maybePop();
                                },
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '$totalReplies ${totalReplies == 1 ? 'Reply' : 'Replies'}',
                                key: const Key('community_reply_heading'),
                                style: AppTypography.sectionHeading,
                              ),
                              const SizedBox(height: 15),
                              for (var i = 0; i < replies.length; i++) ...[
                                if (i != 0) const SizedBox(height: 15),
                                CommunityPostCard(
                                  key: Key('reply_card_${replies[i].id}'),
                                  post: replies[i].asPostCardData(),
                                  showRepliesIndicator: false,
                                  onHide: (id) =>
                                      widget.args.controller.hideReply(post.id, id),
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
                                onSubmitted: (_) => _submitReply(),
                                height: 58,
                                backgroundColor: AppColors.outlinedButtonBackground,
                                borderColor: AppColors.cardBorder,
                              ),
                              const SizedBox(height: 25),
                              AppButton(
                                key: const Key('community_submit_reply_button'),
                                label: 'Submit Reply',
                                onPressed: _submitReply,
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
