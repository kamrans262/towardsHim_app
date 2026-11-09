import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

/// Returns a new post body to the screen, without backend or persistence.
class CommunityCreatePostSheet extends StatefulWidget {
  const CommunityCreatePostSheet({super.key});

  @override
  State<CommunityCreatePostSheet> createState() =>
      _CommunityCreatePostSheetState();
}

class _CommunityCreatePostSheetState extends State<CommunityCreatePostSheet> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          25,
          AppSpacing.screenHorizontal,
          MediaQuery.viewInsetsOf(context).bottom + 25,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create Post', style: AppTypography.sectionHeading),
              const SizedBox(height: 20),
              TextField(
                key: const Key('community_post_input'),
                controller: _textController,
                autofocus: false,
                maxLines: 5,
                minLines: 3,
                maxLength: 2000,
                cursorColor: AppColors.primaryOrange,
                style: AppTypography.inputValue.copyWith(height: 1.3),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Share an encouraging thought...',
                  hintStyle: AppTypography.inputPlaceholder,
                  filled: true,
                  fillColor: AppColors.outlinedButtonBackground,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primaryOrange),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              AppButton(
                label: 'Post',
                onPressed: _textController.text.trim().isEmpty
                    ? null
                    : () => Navigator.of(context).pop(_textController.text.trim()),
              ),
              const SizedBox(height: 15),
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.outlined,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
