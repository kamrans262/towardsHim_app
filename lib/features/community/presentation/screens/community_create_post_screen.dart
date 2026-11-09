import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_detail_page_header.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_content_card.dart';

/// Full-screen, UI-only Create a Post page. Returns its text to the
/// Community tab, which owns the local in-memory post collection.
class CommunityCreatePostScreen extends StatefulWidget {
  const CommunityCreatePostScreen({super.key});

  @override
  State<CommunityCreatePostScreen> createState() =>
      _CommunityCreatePostScreenState();
}

class _CommunityCreatePostScreenState extends State<CommunityCreatePostScreen> {
  static const int _maxCharacters = 100;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _publish() {
    final body = _textController.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a post before publishing.')),
      );
      return;
    }
    Navigator.of(context).pop(body);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: const Key('community_create_post_scaffold'),
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) => SingleChildScrollView(
              key: const Key('community_create_post_scroll'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    viewport.maxWidth > AppSpacing.homeContentMaxWidth
                        ? (viewport.maxWidth - AppSpacing.homeContentMaxWidth) / 2
                        : AppSpacing.screenHorizontal,
                    AppSpacing.screenTop,
                    viewport.maxWidth > AppSpacing.homeContentMaxWidth
                        ? (viewport.maxWidth - AppSpacing.homeContentMaxWidth) / 2
                        : AppSpacing.screenHorizontal,
                    AppSpacing.screenBottom,
                  ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppDetailPageHeader(
                                title: 'Create a Post',
                                titleKey: const Key('community_create_post_title'),
                                onBack: () => Navigator.of(context).maybePop(),
                              ),
                              const SizedBox(height: 25),
                              SizedBox(
                                key: const Key('community_post_container'),
                                height: 290,
                                child: AppContentCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          key: const Key('community_post_input'),
                                          controller: _textController,
                                          keyboardType: TextInputType.multiline,
                                          textInputAction: TextInputAction.newline,
                                          expands: true,
                                          minLines: null,
                                          maxLines: null,
                                          textAlignVertical: TextAlignVertical.top,
                                          maxLength: _maxCharacters,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.enforced,
                                          buildCounter: (
                                            context, {
                                            required currentLength,
                                            required isFocused,
                                            maxLength,
                                          }) => null,
                                          onChanged: (_) => setState(() {}),
                                          cursorColor: AppColors.primaryOrange,
                                          style: AppTypography.inputValue.copyWith(
                                            height: 1,
                                            letterSpacing: 0,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Share your thoughts , encouragement or something you are learning',
                                            hintStyle: AppTypography.inputPlaceholder,
                                            contentPadding: EdgeInsets.zero,
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          '${_textController.text.length}/$_maxCharacters',
                                          key: const Key('community_post_count'),
                                          style: AppTypography.homeSecondary.copyWith(
                                            fontWeight: FontWeight.w400,
                                            fontVariations: const [
                                              FontVariation('wght', 400),
                                            ],
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppButton(
                                key: const Key('community_publish_button'),
                                label: 'Publish Post',
                                onPressed: _publish,
                              ),
                              const SizedBox(height: 20),
                              AppButton(
                                key: const Key('community_cancel_button'),
                                label: 'Cancel',
                                variant: AppButtonVariant.outlined,
                                outlinedBackgroundColor: Colors.transparent,
                                outlinedBorderColor: AppColors.primaryOrange,
                                onPressed: () => Navigator.of(context).maybePop(),
                              ),
                            ],
                          ),
                        ],
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
