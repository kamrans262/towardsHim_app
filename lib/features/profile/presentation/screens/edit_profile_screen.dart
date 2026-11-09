import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../core/widgets/app_detail_page_header.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_user_avatar.dart';
import '../controllers/profile_controller.dart';
import '../services/profile_photo_picker.dart';

/// Edit Profile screen. Changes are stored in ProfileController for this
/// session; no network or account backend is contacted.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    required this.controller,
    this.photoPicker,
    super.key,
  });

  final ProfileController controller;
  final ProfilePhotoPicker? photoPicker;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _bio;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  Uint8List? _pendingPhoto;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    final user = widget.controller.user;
    _name = TextEditingController(text: user.fullName);
    _email = TextEditingController(text: user.email);
    _bio = TextEditingController(text: user.about ?? '');
    _bio.addListener(_onBioChanged);
  }

  void _onBioChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _bio.removeListener(_onBioChanged);
    _name.dispose();
    _email.dispose();
    _bio.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final picker = widget.photoPicker ?? GalleryProfilePhotoPicker();
      final bytes = await picker.pick();
      if (bytes != null && mounted) {
        setState(() => _pendingPhoto = bytes);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select photo: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _save() {
    final name = _name.text.trim();
    final email = _email.text.trim();
    if (name.isEmpty) {
      _notice('Please enter your name.');
      return;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _notice('Please enter a valid email address.');
      return;
    }
    widget.controller.update(
      fullName: name,
      email: email,
      bio: _bio.text,
      photoBytes: _pendingPhoto,
    );
    Navigator.of(context).pop();
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _fieldLabel(String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(value, style: AppTypography.cardTitle),
      );

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.user;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: const Key('edit_profile_scaffold'),
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) => SingleChildScrollView(
              key: const Key('edit_profile_scroll'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppDetailPageHeader(
                                title: 'Edit Profile',
                                onBack: () => Navigator.of(context).maybePop(),
                              ),
                              const SizedBox(height: 25),
                              Center(
                                child: Column(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        AppUserAvatar(
                                          key: const Key('edit_profile_avatar'),
                                          asset: user.avatarAsset,
                                          bytes: _pendingPhoto ?? user.avatarBytes,
                                          size: 100,
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: DecoratedBox(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primaryOrange,
                                            ),
                                            child: IconButton(
                                              key: const Key('edit_profile_photo_button'),
                                              tooltip: 'Change profile photo',
                                              onPressed: _isPicking ? null : _pickPhoto,
                                              icon: const Icon(
                                                Icons.camera_alt_outlined,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      key: const Key('edit_profile_change_photo'),
                                      onPressed: _isPicking ? null : _pickPhoto,
                                      child: Text(
                                        _isPicking ? 'Choosing photo…' : 'Change Photo',
                                        style: AppTypography.homeAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 25),
                              _fieldLabel('Full Name'),
                              AppTextField(
                                label: 'Enter your full name',
                                fieldKey: const Key('edit_profile_name'),
                                controller: _name,
                                focusNode: _nameFocus,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => _emailFocus.requestFocus(),
                              ),
                              const SizedBox(height: 20),
                              _fieldLabel('Email Address'),
                              AppTextField(
                                label: 'Enter your email address',
                                fieldKey: const Key('edit_profile_email'),
                                controller: _email,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 20),
                              _fieldLabel('Bio'),
                              AppContentCard(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      key: const Key('edit_profile_bio'),
                                      controller: _bio,
                                      maxLines: 5,
                                      minLines: 4,
                                      maxLength: 300,
                                      maxLengthEnforcement:
                                          MaxLengthEnforcement.enforced,
                                      buildCounter: (
                                        context, {
                                        required currentLength,
                                        required isFocused,
                                        maxLength,
                                      }) => null,
                                      style: AppTypography.inputValue.copyWith(height: 1.4),
                                      cursorColor: AppColors.primaryOrange,
                                      decoration: const InputDecoration(
                                        hintText: 'Share a little about yourself',
                                        hintStyle: AppTypography.inputPlaceholder,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '${_bio.text.length}/300',
                                        key: const Key('edit_profile_bio_counter'),
                                        style: AppTypography.playerTime,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Changes are saved locally for this app session.',
                                style: AppTypography.playerTime,
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 25),
                              AppButton(
                                key: const Key('edit_profile_save'),
                                label: 'Save Changes',
                                onPressed: _save,
                              ),
                              const SizedBox(height: 20),
                              AppButton(
                                key: const Key('edit_profile_cancel'),
                                label: 'Cancel',
                                variant: AppButtonVariant.outlined,
                                outlinedBackgroundColor: Colors.transparent,
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
        ),
      ),
    );
  }
}
