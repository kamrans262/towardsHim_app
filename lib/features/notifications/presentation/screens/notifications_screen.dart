import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_detail_page_header.dart';
import '../../../listen/data/listen_demo_data.dart';
import '../../../listen/domain/models/listen_audio_episode.dart';
import '../../domain/models/app_notification.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_swipe_card.dart';

/// UI-only Notifications page; the shell owns this local controller.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({required this.controller, super.key});

  final NotificationsController controller;

  void _openContent(BuildContext context, AppNotification notification) {
    controller.markRead(notification.id);
    ListenAudioEpisode? episode;
    for (final item in ListenDemoData.episodes) {
      if (item.id == notification.contentId) {
        episode = item;
        break;
      }
    }
    if (episode == null) return; // Never invent a destination.
    Navigator.of(context).pushNamed(AppRoutes.player, arguments: episode);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: const Key('notifications_scaffold'),
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final notifications = controller.notifications;
              return CustomScrollView(
                key: const Key('notifications_scroll'),
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
                                title: 'Notifications',
                                onBack: () => Navigator.of(context).maybePop(),
                              ),
                              const SizedBox(height: 25),
                              if (notifications.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Text(
                                    'No notifications',
                                    key: Key('notifications_empty'),
                                    style: AppTypography.homeSecondary,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              for (var i = 0; i < notifications.length; i++) ...[
                                if (i != 0) const SizedBox(height: 15),
                                NotificationSwipeCard(
                                  key: ValueKey(notifications[i].id),
                                  notificationId: notifications[i].id,
                                  isOpen: controller.openId == notifications[i].id,
                                  onOpen: () => controller.revealDelete(
                                    notifications[i].id,
                                  ),
                                  onClose: () => controller.closeDelete(
                                    id: notifications[i].id,
                                  ),
                                  onDelete: () => controller.delete(
                                    notifications[i].id,
                                  ),
                                  child: NotificationCard(
                                    notification: notifications[i],
                                    onTap: () => _openContent(
                                      context,
                                      notifications[i],
                                    ),
                                  ),
                                ),
                              ],
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
