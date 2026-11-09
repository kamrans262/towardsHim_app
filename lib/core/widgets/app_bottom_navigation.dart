import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Standalone reusable navigation bar, independent of feature-specific routes.
class AppBottomNavigationDestination {
  const AppBottomNavigationDestination({
    required this.label,
    required this.iconAsset,
  });

  final String label;
  final String iconAsset;
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<AppBottomNavigationDestination> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SafeArea(
        top: false,
        child: Container(
          height: AppSpacing.homeNavHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: AppColors.navShadow,
                offset: Offset(0, -6),
                blurRadius: 24,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Equal-width tabs squeeze "Towards HIM 3" against Community.
              // Allocate widths by measured label text, then distribute the
              // remaining space equally so every label has breathing room.
              final fontSize = constraints.maxWidth < 360 ? 12.0 : 14.0;
              final textStyle =
                  AppTypography.navigationLabel.copyWith(fontSize: fontSize);
              final preferredWidths = <double>[
                for (final item in items)
                  math.max(
                    44,
                    _labelWidth(context, item.label, textStyle) + 16,
                  ),
              ];
              final desiredTotal = preferredWidths.fold<double>(
                0,
                (sum, width) => sum + width,
              );
              final scale = desiredTotal > constraints.maxWidth
                  ? constraints.maxWidth / desiredTotal
                  : 1.0;
              final extraPerItem = items.isEmpty
                  ? 0.0
                  : (constraints.maxWidth - desiredTotal * scale) /
                      items.length;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < items.length; i++)
                    SizedBox(
                      width: preferredWidths[i] * scale + extraPerItem,
                      child: _Destination(
                        item: items[i],
                        selected: selectedIndex == i,
                        labelFontSize: fontSize,
                        onPressed: () => onSelected(i),
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
  static double _labelWidth(
    BuildContext context,
    String label,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}

class _Destination extends StatelessWidget {
  const _Destination({
    required this.item,
    required this.selected,
    required this.labelFontSize,
    required this.onPressed,
  });

  final AppBottomNavigationDestination item;
  final bool selected;
  final double labelFontSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryOrange : AppColors.secondaryText;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: InkWell(
        key: Key('nav_${item.label}'),
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              item.iconAsset,
              width: AppSpacing.homeNavIcon,
              height: AppSpacing.homeNavIcon,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              semanticsLabel: item.label,
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  softWrap: false,
                  style: AppTypography.navigationLabel.copyWith(
                    color: color,
                    fontSize: labelFontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
