import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../core/widgets/app_audio_thumbnail.dart';
import '../../../../core/widgets/app_content_type_tag.dart';
import '../../domain/models/app_notification.dart';

/// Assembles existing content surface, thumbnail and Player category badge.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    this.onTap,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('notification_card_${notification.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
      child: AppContentCard(
        padding: const EdgeInsets.all(AppSpacing.homeCardPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Keep the 100px image on small phones without squeezing the title.
            if (constraints.maxWidth < 300) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _thumbnail(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: AppContentTypeTag(label: notification.category),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notification.title,
                              style: AppTypography.cardTitle.copyWith(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.description,
                    style: AppTypography.homeSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(notification.dateLabel, style: AppTypography.homeSecondary),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _thumbnail(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTypography.cardTitle.copyWith(height: 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppContentTypeTag(label: notification.category),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.description,
                        style: AppTypography.homeSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(notification.dateLabel, style: AppTypography.homeSecondary),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _thumbnail() => AppAudioThumbnail(
        key: Key('notification_image_${notification.id}'),
        imageAsset: notification.imageAsset,
        size: 100,
      );
}
