import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

const merchandiseStoreUrl = 'https://towardhim.promostore.com/';

/// Reuses the approved brand colors, bottom-sheet radius and primary button.
Future<void> showMerchandiseStoreSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal, 25,
          AppSpacing.screenHorizontal, AppSpacing.screenBottom,
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.actionMaxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Merchandise Store',
                  style: AppTypography.sectionHeading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Explore Toward HIM merchandise in our official online store.',
                  style: AppTypography.description,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                AppButton(
                  label: 'Visit Store',
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    bool opened = false;
                    try {
                      opened = await launchUrl(
                        Uri.parse(merchandiseStoreUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (_) {
                      opened = false;
                    }
                    if (!opened && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Unable to open the store.')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(
                    'Cancel',
                    style: AppTypography.description.copyWith(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
