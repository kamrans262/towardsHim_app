import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../weekly_challenges/data/challenge_repository.dart';
import '../../../weekly_challenges/domain/models/daily_challenge.dart';
import '../../../community/data/community_repository.dart';
import '../../../community/presentation/controllers/community_controller.dart';
import '../../../community/presentation/models/community_replies_args.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_detail_page_header.dart';
import '../../domain/models/app_notification.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_swipe_card.dart';

/// Approved Notifications page, backed by server-side member notifications.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    required this.controller,
    this.challengeRepository,
    this.communityRepository,
    super.key,
  });

  final NotificationsController controller;
  final ChallengeRepository? challengeRepository;
  final CommunityRepository? communityRepository;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Set<String> _opening = <String>{};

  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _delete(String id) async {
    try {
      await widget.controller.deleteRemote(id);
      return true;
    } catch (error) {
      if (mounted) _notice('Could not delete notification: ' + error.toString());
      return false;
    }
  }

  Future<void> _openContent(AppNotification notification) async {
    if (!_opening.add(notification.id)) return;
    try {
      // A failing read-status request must never prevent opening the content.
      try {
        await widget.controller.markRead(notification.id);
      } catch (_) {
        // Server remains authoritative; keep the card unread if it fails.
      }
      if (!mounted) return;

      switch (notification.destination) {
        case 'weekly':
          final challenge = await (widget.challengeRepository ??
              ChallengeRepository.instance).detail(notification.contentId);
          if (!mounted) return;
          await Navigator.of(context).pushNamed(
            AppRoutes.weeklyChallengeDetail,
            arguments: WeeklyChallengeNavigationArgs(
              challenge: challenge,
              repository: widget.challengeRepository,
            ),
          );
        case 'daily':
          final dayNumber = notification.dayNumber;
          if (dayNumber == null || dayNumber < 1 || dayNumber > 7) {
            throw StateError('This daily challenge has no valid day.');
          }
          final challenge = await (widget.challengeRepository ??
              ChallengeRepository.instance).detail(notification.contentId);
          if (!mounted) return;
          final day = challenge.days.where((item) => item.day == dayNumber);
          if (day.isEmpty) throw StateError('This day is no longer available.');
          await Navigator.of(context).pushNamed(
            AppRoutes.dailyChallengeDetail,
            arguments: DailyChallenge(
              id: 'challenge-${challenge.id}-day-$dayNumber',
              subtitle: 'Day $dayNumber – Daily Challenge',
              title: challenge.title,
              description: day.first.text,
              initialSelectedOptionId: 'share',
              options: const [],
              media: day.first.media,
            ),
          );
        case 'community':
          final controller = CommunityController(
            repository: widget.communityRepository,
          );
          try {
            await controller.loadPosts();
            if (!mounted) return;
            if (controller.postById(notification.contentId) == null) {
              throw StateError('This discussion is no longer available.');
            }
            await Navigator.of(context).pushNamed(
              AppRoutes.communityPostReplies,
              arguments: CommunityRepliesArgs(
                postId: notification.contentId,
                controller: controller,
              ),
            );
          } finally {
            controller.dispose();
          }
        default:
          // Current backend publications are Podcasts, Meditations and Prayers;
          // fetch the exact published item, not a generic category screen.
          final episode = await widget.controller.loadAudio(
            notification.contentId,
          );
          if (!mounted) return;
          await Navigator.of(context).pushNamed(
            AppRoutes.player,
            arguments: episode,
          );
      }
    } catch (error) {
      if (mounted) _notice('Unable to open notification: $error');
    } finally {
      _opening.remove(notification.id);
    }
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
            animation: widget.controller,
            builder: (context, _) {
              final notifications = widget.controller.notifications;
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
                              if (widget.controller.loading)
                                const Center(child: CircularProgressIndicator())
                              else if (widget.controller.error != null)
                                Column(
                                  children: [
                                    Text(widget.controller.error!,
                                      style: AppTypography.homeSecondary),
                                    TextButton(onPressed: widget.controller.load,
                                      child: const Text('Retry')),
                                  ],
                                )
                              else if (notifications.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Text(
                                    'No notifications',
                                    key: Key('notifications_empty'),
                                    style: AppTypography.homeSecondary,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              if (!widget.controller.loading && widget.controller.error == null)
                              for (var i = 0; i < notifications.length; i++) ...[
                                if (i != 0) const SizedBox(height: 15),
                                NotificationSwipeCard(
                                  key: ValueKey(notifications[i].id),
                                  notificationId: notifications[i].id,
                                  isOpen: widget.controller.openId == notifications[i].id,
                                  onOpen: () => widget.controller.revealDelete(
                                    notifications[i].id,
                                  ),
                                  onClose: () => widget.controller.closeDelete(
                                    id: notifications[i].id,
                                  ),
                                  onDelete: () => widget.controller.removeLocal(
                                    notifications[i].id,
                                  ),
                                  onDeleteAsync: () => _delete(notifications[i].id),
                                  child: NotificationCard(
                                    notification: notifications[i],
                                    onTap: () => _openContent(notifications[i]),
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
