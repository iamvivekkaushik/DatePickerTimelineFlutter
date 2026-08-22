import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:date_picker_timeline/persian_date/persian_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

final DateTime _start = DateTime(2026, 8, 22);

/// Finds the tile Container that paints the selection background for [day].
Container _tileContainerFor(WidgetTester tester, String day) {
  final containers = tester.widgetList<Container>(
    find.ancestor(of: find.text(day), matching: find.byType(Container)),
  );
  return containers.firstWhere((c) => c.decoration is BoxDecoration);
}

Color _selectionColorFor(WidgetTester tester, String day) {
  final decoration =
      _tileContainerFor(tester, day).decoration! as BoxDecoration;
  return decoration.color!;
}

void main() {
  group('rendering and selection', () {
    testWidgets('highlights initialSelectedDate', (tester) async {
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        initialSelectedDate: _start,
        selectionColor: Colors.black,
      )));
      expect(_selectionColorFor(tester, '22'), Colors.black);
      expect(_selectionColorFor(tester, '23'), Colors.transparent);
    });

    testWidgets('tap selects date and fires onDateChange', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        initialSelectedDate: _start,
        selectionColor: Colors.black,
        onDateChange: (d) => changed = d,
      )));
      await tester.tap(find.text('24'));
      await tester.pump();
      expect(changed, DateTime(2026, 8, 24));
      expect(_selectionColorFor(tester, '24'), Colors.black);
      expect(_selectionColorFor(tester, '22'), Colors.transparent);
    });

    testWidgets('tapping a deactivated date is ignored', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        initialSelectedDate: _start,
        selectionColor: Colors.black,
        inactiveDates: [DateTime(2026, 8, 24)],
        onDateChange: (d) => changed = d,
      )));
      await tester.tap(find.text('24'));
      await tester.pump();
      expect(changed, isNull);
      expect(_selectionColorFor(tester, '22'), Colors.black);
    });

    testWidgets('activeDates deactivates everything else', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        activeDates: [DateTime(2026, 8, 23)],
        onDateChange: (d) => changed = d,
      )));
      await tester.tap(find.text('24'));
      await tester.pump();
      expect(changed, isNull);
      await tester.tap(find.text('23'));
      await tester.pump();
      expect(changed, DateTime(2026, 8, 23));
    });

    testWidgets('UTC dates in inactiveDates still match', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        inactiveDates: [DateTime.utc(2026, 8, 24)],
        onDateChange: (d) => changed = d,
      )));
      await tester.tap(find.text('24'));
      await tester.pump();
      expect(changed, isNull);
    });
  });

  group('lifecycle', () {
    testWidgets('unmounting the picker disposes cleanly', (tester) async {
      await tester.pumpWidget(_wrap(DatePicker(_start)));
      await tester.pumpWidget(_wrap(const SizedBox()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('rebuilding with a new selectionColor takes effect',
        (tester) async {
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        initialSelectedDate: _start,
        selectionColor: Colors.black,
        selectedTextColor: Colors.white,
      )));
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        initialSelectedDate: _start,
        selectionColor: Colors.red,
        selectedTextColor: Colors.white,
      )));
      expect(_selectionColorFor(tester, '22'), Colors.red);
    });

    testWidgets('rebuilding with a new selectedTextColor takes effect',
        (tester) async {
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        initialSelectedDate: _start,
        selectedTextColor: Colors.white,
      )));
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        initialSelectedDate: _start,
        selectedTextColor: Colors.yellow,
      )));
      final text = tester.widget<Text>(find.text('22'));
      expect(text.style!.color, Colors.yellow);
    });

    testWidgets('a controller provided on a later rebuild attaches',
        (tester) async {
      await tester
          .pumpWidget(_wrap(DatePicker(_start, initialSelectedDate: _start)));
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        initialSelectedDate: _start,
        controller: controller,
      )));
      controller.animateToSelection();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('DatePickerController', () {
    testWidgets('animateToSelection without a selection does not crash',
        (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        controller: controller,
      )));
      controller.animateToSelection();
      controller.jumpToSelection();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('setDateAndAnimate moves the highlight', (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        initialSelectedDate: _start,
        selectionColor: Colors.black,
        controller: controller,
      )));
      controller.setDateAndAnimate(DateTime(2026, 8, 24));
      await tester.pumpAndSettle();
      expect(_selectionColorFor(tester, '24'), Colors.black);
      // Scroll back so the previously selected tile is rebuilt and visible.
      controller.animateToDate(_start);
      await tester.pumpAndSettle();
      expect(_selectionColorFor(tester, '22'), Colors.transparent);
    });

    testWidgets('setDateAndAnimate ignores out-of-range dates', (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        daysCount: 10,
        initialSelectedDate: _start,
        selectionColor: Colors.black,
        controller: controller,
      )));
      // Before startDate and past the last rendered index (daysCount - 1).
      controller.setDateAndAnimate(DateTime(2026, 8, 21));
      controller.setDateAndAnimate(_start.add(const Duration(days: 10)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_selectionColorFor(tester, '22'), Colors.black);
    });

    testWidgets('animateToDate ignores out-of-range dates', (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        daysCount: 10,
        controller: controller,
      )));
      controller.animateToDate(DateTime(2020, 1, 1));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final scrollable =
          tester.widget<ListView>(find.byType(ListView)).controller!;
      expect(scrollable.offset, 0.0);
    });

    testWidgets('animateToDate scrolls to width+margin aligned offset',
        (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        width: 60,
        controller: controller,
      )));
      controller.animateToDate(_start.add(const Duration(days: 10)));
      await tester.pumpAndSettle();
      final scrollable =
          tester.widget<ListView>(find.byType(ListView)).controller!;
      // 10 tiles of (60 width + 6 margin)
      expect(scrollable.offset, 660.0);
    });
  });

  group('review regressions', () {
    testWidgets('controller methods no-op after the picker is unmounted',
        (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        initialSelectedDate: _start,
        controller: controller,
      )));
      await tester.pumpWidget(_wrap(const SizedBox()));
      expect(controller.isAttached, isFalse);
      controller.jumpToSelection();
      controller.animateToSelection();
      controller.animateToDate(DateTime(2026, 8, 24));
      controller.setDateAndAnimate(DateTime(2026, 8, 24));
      expect(tester.takeException(), isNull);
    });

    testWidgets('controller call after attach but before first layout no-ops',
        (tester) async {
      final controller = DatePickerController();
      // The Builder runs during the same build phase in which the ListView's
      // ScrollPosition attaches, before the first layout computes
      // maxScrollExtent.
      await tester.pumpWidget(_wrap(Column(children: [
        DatePicker(_start, initialSelectedDate: _start, controller: controller),
        Builder(builder: (context) {
          controller.jumpToSelection();
          return const SizedBox();
        }),
      ])));
      expect(tester.takeException(), isNull);
    });

    testWidgets('labels stay spread across the tile height', (tester) async {
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        width: 60,
        height: 120,
        initialSelectedDate: _start,
      )));
      final tile = tester.getRect(find.byType(Container).first);
      final monthRect = tester.getRect(find.text('AUG').first);
      final dayRect = tester.getRect(find.text('SAT').first);
      // month label hugs the top padding, weekday label hugs the bottom.
      expect(monthRect.top - tile.top, lessThan(15));
      expect(tile.bottom - dayRect.bottom, lessThan(15));
    });

    testWidgets('tiny height scales labels down instead of overflowing',
        (tester) async {
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        height: 45,
        initialSelectedDate: _start,
      )));
      expect(tester.takeException(), isNull);
    });
  });

  group('showPastDates', () {
    // Tile extent is width + 2*3 margin = 66. A 264px-wide viewport shows
    // exactly 4 tiles, so "centered" positions are easy to compute.
    Widget pickerBox(DatePickerController? controller,
        {DateTime? initialSelectedDate}) {
      return _wrap(Center(
        child: SizedBox(
          width: 264,
          child: DatePicker(
            _start,
            width: 60,
            daysCount: 40,
            showPastDates: true,
            controller: controller,
            initialSelectedDate: initialSelectedDate,
            selectionColor: Colors.black,
          ),
        ),
      ));
    }

    testWidgets('renders past dates left of the anchor', (tester) async {
      await tester.pumpWidget(pickerBox(null, initialSelectedDate: _start));
      // Anchor 2026-08-22 with daysCount 40 -> 20 past days, range starts
      // 2026-08-02. The anchor opens centered, so 21 (yesterday) is visible
      // on its left.
      final anchor = tester.getCenter(find.text('22'));
      final yesterday = tester.getCenter(find.text('21'));
      expect(yesterday.dx, lessThan(anchor.dx));
    });

    testWidgets('opens with the anchor centered in the viewport',
        (tester) async {
      await tester.pumpWidget(pickerBox(null, initialSelectedDate: _start));
      final box = tester.getRect(find.byType(SizedBox).first);
      final anchor = tester.getCenter(find.text('22'));
      expect(anchor.dx, moreOrLessEquals(box.center.dx, epsilon: 1.0));
    });

    testWidgets('animateToSelection centers the selected date', (tester) async {
      final controller = DatePickerController();
      await tester
          .pumpWidget(pickerBox(controller, initialSelectedDate: _start));
      // Scroll away, then return: the selection must land in the center,
      // not at the leading edge.
      controller.animateToDate(DateUtils.addDaysToDate(_start, 12));
      await tester.pumpAndSettle();
      controller.animateToSelection();
      await tester.pumpAndSettle();
      final box = tester.getRect(find.byType(SizedBox).first);
      final anchor = tester.getCenter(find.text('22'));
      expect(anchor.dx, moreOrLessEquals(box.center.dx, epsilon: 1.0));
    });

    testWidgets('setDateAndAnimate selects a past date and centers it',
        (tester) async {
      final controller = DatePickerController();
      await tester
          .pumpWidget(pickerBox(controller, initialSelectedDate: _start));
      final pastDate = DateUtils.addDaysToDate(_start, -10); // 2026-08-12
      controller.setDateAndAnimate(pastDate);
      await tester.pumpAndSettle();
      final box = tester.getRect(find.byType(SizedBox).first);
      expect(_selectionColorFor(tester, '12'), Colors.black);
      expect(tester.getCenter(find.text('12')).dx,
          moreOrLessEquals(box.center.dx, epsilon: 1.0));
    });

    testWidgets('dates before the past range are still out of range',
        (tester) async {
      final controller = DatePickerController();
      await tester
          .pumpWidget(pickerBox(controller, initialSelectedDate: _start));
      // Range starts at anchor - 20 days; 21 days back is out of range.
      controller.setDateAndAnimate(DateUtils.addDaysToDate(_start, -21));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_selectionColorFor(tester, '22'), Colors.black);
    });

    testWidgets('default (showPastDates false) keeps leading-edge behavior',
        (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        width: 60,
        controller: controller,
      )));
      final scrollable =
          tester.widget<ListView>(find.byType(ListView)).controller!;
      expect(scrollable.offset, 0.0);
      controller.animateToDate(DateUtils.addDaysToDate(_start, 10));
      await tester.pumpAndSettle();
      expect(scrollable.offset, 660.0);
    });
  });

  group('persian digits', () {
    test('toPersianDigit converts every Latin digit', () {
      expect('0123456789'.toPersianDigit(), '۰۱۲۳۴۵۶۷۸۹');
      expect('12.5'.toPersianDigit(), '۱۲.۵');
      expect('abc'.toPersianDigit(), 'abc');
    });
  });
}
