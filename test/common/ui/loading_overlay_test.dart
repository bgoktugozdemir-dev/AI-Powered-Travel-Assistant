import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/ui/loading_overlay.dart';

void main() {
  const label = 'Preparing your travel plan';

  const viewports = {
    'desktop': Size(1366, 768),
    'tablet landscape': Size(1024, 768),
    'phone portrait': Size(390, 844),
    'phone landscape': Size(844, 390),
  };

  for (final MapEntry(key: name, value: size) in viewports.entries) {
    testWidgets('keeps the label on screen on a $name viewport', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: LoadingOverlay(label: label)),
      );

      expect(tester.takeException(), isNull);
      final labelRect = tester.getRect(find.text(label));
      expect(
        Offset.zero & size,
        predicate<Rect>(
          (screen) =>
              screen.contains(labelRect.topLeft) &&
              screen.contains(labelRect.bottomRight - const Offset(1, 1)),
          'contains the label $labelRect',
        ),
      );
    });
  }
}
