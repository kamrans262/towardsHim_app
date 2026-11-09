import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Swiping reveals (never performs) the Delete action on the right.
/// A parent controller enforces only one open card at a time.
class NotificationSwipeCard extends StatefulWidget {
  const NotificationSwipeCard({
    required this.notificationId,
    required this.isOpen,
    required this.onOpen,
    required this.onClose,
    required this.onDelete,
    required this.child,
    super.key,
  });

  final String notificationId;
  final bool isOpen;
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  final Widget child;

  @override
  State<NotificationSwipeCard> createState() => _NotificationSwipeCardState();
}

class _NotificationSwipeCardState extends State<NotificationSwipeCard> {
  static const double _actionWidth = 72;
  static const Duration _duration = Duration(milliseconds: 220);
  double? _dragOffset;
  bool _deleting = false;

  void _start(DragStartDetails details) {
    setState(() => _dragOffset = widget.isOpen ? -_actionWidth : 0);
  }

  void _update(DragUpdateDetails details) {
    setState(() {
      _dragOffset = ((_dragOffset ?? 0) + details.delta.dx)
          .clamp(-_actionWidth, 0.0)
          .toDouble();
    });
  }

  void _finish(DragEndDetails details) {
    final dx = _dragOffset ?? (widget.isOpen ? -_actionWidth : 0);
    final velocity = details.primaryVelocity ?? 0;
    final shouldOpen = velocity < -200
        ? true
        : velocity > 200
            ? false
            : dx <= -_actionWidth / 2;
    setState(() => _dragOffset = null);
    if (shouldOpen) {
      widget.onOpen();
    } else {
      widget.onClose();
    }
  }

  void _delete() {
    if (_deleting) return;
    setState(() => _deleting = true);
    // Keep the row in the list long enough to animate away.
    Future<void>.delayed(_duration, () {
      if (mounted) widget.onDelete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final offset = _dragOffset ?? (widget.isOpen ? -_actionWidth : 0.0);
    return AnimatedSize(
      key: Key('notification_swipe_${widget.notificationId}'),
      duration: _duration,
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: _deleting
          ? const SizedBox(width: double.infinity)
          : AnimatedOpacity(
              opacity: _deleting ? 0 : 1,
              duration: _duration,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: _actionWidth,
                          height: double.infinity,
                          child: Material(
                            color: AppColors.primaryOrange,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(AppSpacing.homeCardRadius),
                            ),
                            child: ExcludeSemantics(
                              excluding: !widget.isOpen,
                              child: IconButton(
                                key: Key('notification_delete_${widget.notificationId}'),
                                tooltip: 'Delete notification',
                                onPressed: _delete,
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Semantics(
                      customSemanticsActions: {
                        const CustomSemanticsAction(
                          label: 'Show delete action',
                        ): widget.onOpen,
                        const CustomSemanticsAction(
                          label: 'Hide delete action',
                        ): widget.onClose,
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragStart: _start,
                        onHorizontalDragUpdate: _update,
                        onHorizontalDragEnd: _finish,
                        onHorizontalDragCancel: () =>
                            setState(() => _dragOffset = null),
                        child: AnimatedContainer(
                          duration: _dragOffset == null ? _duration : Duration.zero,
                          curve: Curves.easeOutCubic,
                          transform: Matrix4.translationValues(offset, 0, 0),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
