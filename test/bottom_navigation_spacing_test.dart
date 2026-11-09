import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/features/home/data/home_demo_data.dart';

void main() {
  final labels = HomeDemoData.navigation.map((item) => item.label).toList();
  final items = [
    for (final item in HomeDemoData.navigation)
      AppBottomNavigationDestination(
        label: item.label,
        iconAsset: item.iconAsset,
      ),
  ];

  for (final width in <double>[320, 375, 430, 820]) {
    testWidgets('Five nav labels have balanced horizontal space at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var selected = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              items: items,
              selectedIndex: 2,
              onSelected: (index) => selected = index,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bar = find.byType(AppBottomNavigation);
      expect(bar, findsOneWidget);
      final bounds = [
        for (final label in labels) tester.getRect(find.text(label)),
      ];
      final targets = [
        for (final label in labels)
          tester.getRect(find.byKey(Key('nav_$label'))),
      ];

      expect(bounds.first.left, greaterThanOrEqualTo(10));
      expect(width - bounds.last.right, greaterThanOrEqualTo(10));
      for (var i = 0; i < labels.length - 1; i++) {
        expect(bounds[i].right, lessThan(bounds[i + 1].left));
        expect(targets[i].right, closeTo(targets[i + 1].left, 1));
      }
      // The longest label gets the space it needs, rather than having
      // the same width as Home or Store.
      expect(targets[2].width, greaterThan(targets[0].width));
      expect(targets[2].width, greaterThan(targets[4].width));

      final labelSizes = [
        for (final label in labels)
          tester.widget<Text>(find.text(label)).style!.fontSize,
      ];
      expect(labelSizes.toSet().length, 1);
      expect(labelSizes.first, width - 24 < 360 ? 12.0 : 14.0);
      expect(AppSpacing.homeNavHeight, 77);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('nav_Towards HIM 3')));
      await tester.pump();
      expect(selected, 2);
    });
  }
}
