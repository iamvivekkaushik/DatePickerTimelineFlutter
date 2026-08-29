import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  String dayLabel(int daysFromToday) => DateUtils.addDaysToDate(
        DateTime.now(),
        daysFromToday,
      ).day.toString();

  testWidgets('showcase renders and reacts to taps on a real iOS device',
      (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    // Every design card built without exceptions.
    expect(find.text('Classic'), findsOneWidget);
    expect(find.text('Past & future'), findsOneWidget);

    // Today's selection is reflected in the Classic card's pill.
    final today = DateTime.now();
    final iso = today.toIso8601String().split('T').first;
    expect(find.textContaining(iso), findsWidgets);

    // Tap a future date in the first (Classic) picker.
    final target = dayLabel(2);
    await tester.tap(find.text(target).first);
    await tester.pumpAndSettle();

    final expectedIso = DateUtils.addDaysToDate(today, 2)
        .toIso8601String()
        .split('T')
        .first;
    expect(find.textContaining(expectedIso), findsWidgets);
  });

  testWidgets('deactivated dates ignore taps on a real iOS device',
      (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    // Scroll the Booking card (weekends disabled) into view.
    await tester.scrollUntilVisible(find.text('Booking'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    // Find the next Saturday, which the Booking demo deactivates.
    var saturday = DateTime.now();
    while (saturday.weekday != DateTime.saturday) {
      saturday = DateUtils.addDaysToDate(saturday, 1);
    }
    expect(find.text('Booking'), findsOneWidget);
    expect(find.textContaining('Weekends closed'), findsOneWidget);

    // The card starts with nothing selected; tapping a weekend must not change that.
    expect(find.text('Nothing selected yet'), findsOneWidget);
    final satTiles = find.text(saturday.day.toString());
    if (satTiles.evaluate().isNotEmpty) {
      await tester.tap(satTiles.last, warnIfMissed: false);
      await tester.pumpAndSettle();
    }
    expect(find.text('Nothing selected yet'), findsOneWidget);
  });
}
