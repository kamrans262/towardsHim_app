import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../auth/data/auth_repository.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_detail_page_header.dart';
import '../../data/delete_account_demo_data.dart';
import '../widgets/profile_bullet_list.dart';
import '../widgets/profile_menu_card.dart';

/// Approved deletion screen with authenticated server-side confirmation.
class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  Future<void> _confirmDelete(BuildContext context) async {
    if (!AuthRepository.instance.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to delete your account.')),
      );
      return;
    }
    final password = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.outlinedButtonBackground,
        title: const Text(
          DeleteAccountDemoData.confirmationTitle,
          style: AppTypography.sectionHeading,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              DeleteAccountDemoData.confirmationDescription,
              style: AppTypography.homeSecondary,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm your password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('delete_dialog_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('delete_dialog_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Confirm Delete',
              style: TextStyle(color: AppColors.warningRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await AuthRepository.instance.deleteAccount(password.text);
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (_) => false);
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        }
      }
    }
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: const Key('delete_account_scaffold'),
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) => SingleChildScrollView(
              key: const Key('delete_account_scroll'),
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
                            title: 'Delete Account',
                            onBack: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(height: 25),
                          ProfileMenuCard(
                            key: const Key('delete_warning_card'),
                            item: DeleteAccountDemoData.warningItem,
                            onPressed: null,
                            leadingIcon: Icons.fact_check_outlined,
                            backgroundColor: AppColors.warningBackground,
                            borderColor: AppColors.warningBorder,
                            iconBackgroundColor: AppColors.warningIconBackground,
                            iconColor: AppColors.warningRed,
                            titleStyle: AppTypography.cardTitle.copyWith(
                              color: AppColors.warningRed,
                              height: 1,
                            ),
                            descriptionStyle: AppTypography.playerTime.copyWith(
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Before Deleting Account',
                            style: AppTypography.sectionHeading,
                          ),
                          const SizedBox(height: 8),
                          const ProfileBulletList(
                            key: Key('delete_account_bullets'),
                            items: DeleteAccountDemoData.bullets,
                            itemGap: 5,
                          ),
                          const SizedBox(height: 20),
                          ProfileMenuCard(
                            key: const Key('delete_information_card'),
                            item: DeleteAccountDemoData.informationItem,
                            onPressed: null,
                            leadingIcon: Icons.info_outline_rounded,
                            titleStyle: AppTypography.homeSecondary,
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Preserves content on compact devices and anchors
                          // actions to the bottom when room is available.
                          const SizedBox(height: 25),
                          AppButton(
                            key: const Key('delete_account_button'),
                            label: 'Delete my account',
                            filledBackgroundColor: AppColors.warningRed,
                            onPressed: () => _confirmDelete(context),
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            key: const Key('delete_account_cancel_button'),
                            label: 'Cancel',
                            variant: AppButtonVariant.outlined,
                            outlinedBackgroundColor: Colors.transparent,
                            outlinedBorderColor: AppColors.warningRed,
                            outlinedForegroundColor: AppColors.warningRed,
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
