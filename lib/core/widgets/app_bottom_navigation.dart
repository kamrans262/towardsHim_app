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
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _Destination(
                    item: items[i],
                    selected: selectedIndex == i,
                    onPressed: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final AppBottomNavigationDestination item;
  final bool selected;
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
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                style: AppTypography.navigationLabel.copyWith(color: color),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
