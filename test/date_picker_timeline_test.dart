import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:date_picker_timeline/extra/range_band.dart';
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

/// The [TileSelection] the tile showing [day] paints.
TileSelection _kindFor(WidgetTester tester, String day) {
  return tester
      .widget<RangeBand>(
          find.ancestor(of: find.text(day), matching: find.byType(RangeBand)))
      .selection;
}

/// The rect of the range band painted by [day]'s tile.
Rect _bandRectFor(WidgetTester tester, String day) {
  return tester.getRect(find.descendant(
    of: find.ancestor(of: find.text(day), matching: find.byType(RangeBand)),
    matching: find.byType(ColoredBox),
  ));
}

Color _labelColorFor(WidgetTester tester, String day) =>
    tester.widget<Text>(find.text(day)).style!.color!;

/// Finds every range band actually painted by a tile.
final Finder _anyBand = find.descendant(
    of: find.byType(RangeBand), matching: find.byType(ColoredBox));

DateTime _day(int d) => DateTime(2026, 8, d);

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

  group('multiple selection', () {
    testWidgets('keeps every tapped date selected', (tester) async {
      final emissions = <List<DateTime>>[];
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectionColor: Colors.black,
        onSelectionChange: emissions.add,
      )));
      await tester.tap(find.text('23'));
      await tester.pump();
      await tester.tap(find.text('25'));
      await tester.pump();
      expect(_selectionColorFor(tester, '23'), Colors.black);
      expect(_selectionColorFor(tester, '25'), Colors.black);
      expect(_selectionColorFor(tester, '24'), Colors.transparent);
      expect(emissions.last, [_day(23), _day(25)]);
    });

    testWidgets('tapping a selected date removes it', (tester) async {
      final emissions = <List<DateTime>>[];
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectedDates: [_day(22), _day(23)],
        selectionColor: Colors.black,
        onSelectionChange: emissions.add,
      )));
      await tester.tap(find.text('22'));
      await tester.pump();
      expect(_selectionColorFor(tester, '22'), Colors.transparent);
      expect(_selectionColorFor(tester, '23'), Colors.black);
      expect(emissions.single, [_day(23)]);
    });

    testWidgets('does not fire onDateChange', (tester) async {
      var dateChanges = 0;
      var selectionChanges = 0;
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        onDateChange: (_) => dateChanges++,
        onSelectionChange: (_) => selectionChanges++,
      )));
      await tester.tap(find.text('23'));
      await tester.pump();
      expect(dateChanges, 0);
      expect(selectionChanges, 1);
    });

    testWidgets('deactivated dates cannot be added', (tester) async {
      final emissions = <List<DateTime>>[];
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        inactiveDates: [_day(24)],
        onSelectionChange: emissions.add,
      )));
      await tester.tap(find.text('24'));
      await tester.pump();
      expect(emissions, isEmpty);
      expect(_selectionColorFor(tester, '24'), Colors.transparent);
    });

    testWidgets('emits the selection sorted', (tester) async {
      final emissions = <List<DateTime>>[];
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        onSelectionChange: emissions.add,
      )));
      await tester.tap(find.text('27'));
      await tester.pump();
      await tester.tap(find.text('23'));
      await tester.pump();
      expect(emissions.last, [_day(23), _day(27)]);
    });

    testWidgets('removing the last date leaves an empty selection',
        (tester) async {
      final controller = DatePickerController();
      final emissions = <List<DateTime>>[];
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectedDates: [_day(22)],
        controller: controller,
        onSelectionChange: emissions.add,
      )));
      await tester.tap(find.text('22'));
      await tester.pump();
      expect(emissions.single, isEmpty);
      controller.animateToSelection();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('paints no range band', (tester) async {
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectedDates: [_day(23), _day(25)],
      )));
      expect(_kindFor(tester, '23'), TileSelection.selected);
      expect(_kindFor(tester, '24'), TileSelection.none);
      expect(_anyBand, findsNothing);
    });
  });

  group('range selection', () {
    Widget rangePicker({
      DatePickerController? controller,
      List<DateTime>? selectedDates,
      List<DateTime>? inactiveDates,
      SelectionChangeListener? onSelectionChange,
      Color rangeColor = const Color(0xFF00FF00),
      Color? rangeTextColor,
      int daysCount = 500,
    }) {
      return _wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.range,
        selectionColor: Colors.black,
        selectedTextColor: Colors.white,
        rangeColor: rangeColor,
        rangeTextColor: rangeTextColor,
        controller: controller,
        selectedDates: selectedDates,
        inactiveDates: inactiveDates,
        daysCount: daysCount,
        onSelectionChange: onSelectionChange,
      ));
    }

    testWidgets('first tap paints only a pending start', (tester) async {
      final emissions = <List<DateTime>>[];
      await tester.pumpWidget(rangePicker(onSelectionChange: emissions.add));
      await tester.tap(find.text('23'));
      await tester.pump();
      expect(_kindFor(tester, '23'), TileSelection.selected);
      expect(_kindFor(tester, '24'), TileSelection.none);
      expect(emissions.single, [_day(23)]);
    });

    testWidgets('second tap paints start, middles and end', (tester) async {
      final emissions = <List<DateTime>>[];
      await tester.pumpWidget(rangePicker(onSelectionChange: emissions.add));
      await tester.tap(find.text('23'));
      await tester.pump();
      await tester.tap(find.text('26'));
      await tester.pump();
      expect(_kindFor(tester, '23'), TileSelection.rangeStart);
      expect(_kindFor(tester, '24'), TileSelection.rangeMiddle);
      expect(_kindFor(tester, '25'), TileSelection.rangeMiddle);
      expect(_kindFor(tester, '26'), TileSelection.rangeEnd);
      expect(_selectionColorFor(tester, '23'), Colors.black);
      expect(_selectionColorFor(tester, '26'), Colors.black);
      expect(_selectionColorFor(tester, '24'), Colors.transparent);
      expect(emissions.last, [_day(23), _day(26)]);
    });

    testWidgets('a reversed second tap swaps the endpoints', (tester) async {
      final emissions = <List<DateTime>>[];
      await tester.pumpWidget(rangePicker(onSelectionChange: emissions.add));
      await tester.tap(find.text('26'));
      await tester.pump();
      await tester.tap(find.text('23'));
      await tester.pump();
      expect(_kindFor(tester, '23'), TileSelection.rangeStart);
      expect(_kindFor(tester, '26'), TileSelection.rangeEnd);
      expect(emissions.last, [_day(23), _day(26)]);
    });

    testWidgets('tapping the start again yields a one-day range',
        (tester) async {
      final emissions = <List<DateTime>>[];
      await tester.pumpWidget(rangePicker(onSelectionChange: emissions.add));
      await tester.tap(find.text('23'));
      await tester.pump();
      await tester.tap(find.text('23'));
      await tester.pump();
      expect(_kindFor(tester, '23'), TileSelection.selected);
      expect(emissions.last, [_day(23), _day(23)]);
      expect(_anyBand, findsNothing);
    });

    testWidgets('a third tap starts a new range', (tester) async {
      final emissions = <List<DateTime>>[];
      await tester.pumpWidget(rangePicker(onSelectionChange: emissions.add));
      await tester.tap(find.text('23'));
      await tester.pump();
      await tester.tap(find.text('26'));
      await tester.pump();
      await tester.tap(find.text('28'));
      await tester.pump();
      expect(emissions.last, [_day(28)]);
      expect(_kindFor(tester, '24'), TileSelection.none);
      expect(_kindFor(tester, '28'), TileSelection.selected);
    });

    testWidgets('spans deactivated dates without selecting them',
        (tester) async {
      final emissions = <List<DateTime>>[];
      await tester.pumpWidget(rangePicker(
        inactiveDates: [_day(25)],
        onSelectionChange: emissions.add,
      ));
      await tester.tap(find.text('23'));
      await tester.pump();
      await tester.tap(find.text('27'));
      await tester.pump();
      expect(_kindFor(tester, '25'), TileSelection.rangeMiddle);
      expect(emissions.last, [_day(23), _day(27)]);
      // Deactivated text styling wins over the range middle.
      expect(_labelColorFor(tester, '25'), const Color(0xFF666666));
    });

    testWidgets('a deactivated date cannot start a range', (tester) async {
      final emissions = <List<DateTime>>[];
      await tester.pumpWidget(rangePicker(
        inactiveDates: [_day(23)],
        onSelectionChange: emissions.add,
      ));
      await tester.tap(find.text('23'));
      await tester.pump();
      expect(emissions, isEmpty);
      expect(_kindFor(tester, '23'), TileSelection.none);
    });

    testWidgets('middles keep normal text styles unless rangeTextColor is set',
        (tester) async {
      await tester.pumpWidget(rangePicker(
        selectedDates: [_day(23), _day(26)],
      ));
      expect(_labelColorFor(tester, '24'), Colors.black);
      expect(_labelColorFor(tester, '23'), Colors.white);

      await tester.pumpWidget(rangePicker(
        selectedDates: [_day(23), _day(26)],
        rangeTextColor: Colors.orange,
      ));
      expect(_labelColorFor(tester, '24'), Colors.orange);
      expect(_labelColorFor(tester, '23'), Colors.white);
    });

    testWidgets('bands are continuous across the tile gutter', (tester) async {
      await tester.pumpWidget(rangePicker(
        selectedDates: [_day(23), _day(26)],
      ));
      final startBand = _bandRectFor(tester, '23');
      final middleBand = _bandRectFor(tester, '24');
      final endBand = _bandRectFor(tester, '26');
      // width 60 + 2*3 margin = 66 per tile; endpoints paint a margin-wide
      // connector strip, middles the full tile.
      expect(middleBand.width, 66.0);
      expect(startBand.width, 3.0);
      expect(endBand.width, 3.0);
      expect(startBand.right, middleBand.left);
      expect(_bandRectFor(tester, '25').right, endBand.left);
      // Band matches the painted pill vertically: the tile box is 80 tall
      // and the pill is inset by the 3px margin on top and bottom.
      final tile = tester.getRect(find
          .ancestor(of: find.text('24'), matching: find.byType(Container))
          .first);
      expect(middleBand.top, tile.top + 3.0);
      expect(middleBand.bottom, tile.bottom - 3.0);
    });

    testWidgets('an endpoint outside the window paints as a middle',
        (tester) async {
      await tester.pumpWidget(rangePicker(
        daysCount: 10,
        selectedDates: [_day(24), DateTime(2026, 9, 5)],
      ));
      expect(_kindFor(tester, '24'), TileSelection.rangeStart);
      expect(_kindFor(tester, '31'), TileSelection.rangeMiddle);
    });
  });

  group('selectedDates sync', () {
    testWidgets('seeds the picker on first build', (tester) async {
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectedDates: [_day(24)],
        selectionColor: Colors.black,
      )));
      expect(_selectionColorFor(tester, '24'), Colors.black);
    });

    testWidgets('a changed list is adopted', (tester) async {
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectedDates: [_day(22)],
        selectionColor: Colors.black,
      )));
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectedDates: [_day(24)],
        selectionColor: Colors.black,
      )));
      expect(_selectionColorFor(tester, '24'), Colors.black);
      expect(_selectionColorFor(tester, '22'), Colors.transparent);
    });

    testWidgets('an unchanged list does not clobber a tap', (tester) async {
      Widget picker() => _wrap(DatePicker(
            _start,
            selectionMode: SelectionMode.multiple,
            selectedDates: [_day(22)],
            selectionColor: Colors.black,
          ));
      await tester.pumpWidget(picker());
      await tester.tap(find.text('24'));
      await tester.pump();
      // Parent rebuild with an equal (but not identical) list literal.
      await tester.pumpWidget(picker());
      expect(_selectionColorFor(tester, '24'), Colors.black);
      expect(_selectionColorFor(tester, '22'), Colors.black);
    });

    testWidgets('writing the emitted list back does not reset the anchor',
        (tester) async {
      final controller = DatePickerController();
      List<DateTime> picked = [_day(22)];
      late StateSetter rebuild;
      await tester.pumpWidget(_wrap(StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return DatePicker(
            _start,
            selectionMode: SelectionMode.multiple,
            selectedDates: picked,
            controller: controller,
            selectionColor: Colors.black,
            onSelectionChange: (dates) => picked = dates,
          );
        },
      )));
      await tester.tap(find.text('25'));
      await tester.pump();
      rebuild(() {});
      await tester.pump();
      controller.animateToSelection();
      await tester.pumpAndSettle();
      // Anchor is the 25th (last tapped), which is at offset 3 * 66 = 198.
      final scrollable =
          tester.widget<ListView>(find.byType(ListView)).controller!;
      expect(scrollable.offset, 198.0);
    });

    testWidgets('adoption never fires onSelectionChange', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectedDates: [_day(22)],
        onSelectionChange: (_) => calls++,
      )));
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectedDates: [_day(24), _day(25)],
        onSelectionChange: (_) => calls++,
      )));
      expect(calls, 0);
    });

    testWidgets('switching selectionMode from range to single keeps the start',
        (tester) async {
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.range,
        selectedDates: [_day(23), _day(26)],
        selectionColor: Colors.black,
      )));
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.single,
        selectionColor: Colors.black,
      )));
      expect(_selectionColorFor(tester, '23'), Colors.black);
      expect(_kindFor(tester, '24'), TileSelection.none);
      expect(_kindFor(tester, '26'), TileSelection.none);
    });

    testWidgets('illegal parameter combinations assert', (tester) async {
      expect(
        () => DatePicker(
          _start,
          selectionMode: SelectionMode.multiple,
          initialSelectedDate: _start,
        ),
        throwsAssertionError,
      );
      expect(
        () => DatePicker(_start, selectedDates: [_start]),
        throwsAssertionError,
      );
      expect(
        () => DatePicker(
          _start,
          selectionMode: SelectionMode.range,
          selectedDates: [_day(23), _day(24), _day(25)],
        ),
        throwsAssertionError,
      );
    });
  });

  group('DatePickerController multi/range', () {
    testWidgets('selectedDates reflects taps and is unmodifiable',
        (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        controller: controller,
      )));
      await tester.tap(find.text('25'));
      await tester.pump();
      await tester.tap(find.text('23'));
      await tester.pump();
      expect(controller.selectedDates, [_day(23), _day(25)]);
      expect(
          () => controller.selectedDates.add(_day(28)), throwsUnsupportedError);
    });

    testWidgets('select adds silently and ignores out-of-range dates',
        (tester) async {
      final controller = DatePickerController();
      var calls = 0;
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        daysCount: 10,
        selectionMode: SelectionMode.multiple,
        controller: controller,
        selectionColor: Colors.black,
        onSelectionChange: (_) => calls++,
      )));
      controller.select(_day(24));
      controller.select(_day(21)); // before startDate
      controller.select(DateTime(2026, 9, 5)); // past the window
      await tester.pump();
      expect(_selectionColorFor(tester, '24'), Colors.black);
      expect(controller.selectedDates, [_day(24)]);
      expect(calls, 0);
    });

    testWidgets('select is additive, not a toggle', (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectedDates: [_day(24)],
        controller: controller,
      )));
      controller.select(_day(24));
      await tester.pump();
      expect(controller.selectedDates, [_day(24)]);
    });

    testWidgets('deselect removes in multiple mode, no-ops in range mode',
        (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectedDates: [_day(23), _day(24)],
        controller: controller,
      )));
      controller.deselect(_day(23));
      await tester.pump();
      expect(controller.selectedDates, [_day(24)]);

      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.range,
        selectedDates: [_day(23), _day(26)],
        controller: controller,
      )));
      controller.deselect(_day(23));
      await tester.pump();
      expect(controller.selectedDates, [_day(23), _day(26)]);
    });

    testWidgets('clearSelection empties every mode', (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.range,
        selectedDates: [_day(23), _day(26)],
        controller: controller,
      )));
      controller.clearSelection();
      await tester.pump();
      expect(controller.selectedDates, isEmpty);
      expect(_kindFor(tester, '24'), TileSelection.none);
      controller.jumpToSelection();
      controller.animateToSelection();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('selectRange sets both endpoints and swaps reversed args',
        (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.range,
        controller: controller,
      )));
      controller.selectRange(_day(26), _day(23));
      await tester.pump();
      expect(controller.selectedDates, [_day(23), _day(26)]);
      expect(_kindFor(tester, '23'), TileSelection.rangeStart);
      expect(_kindFor(tester, '24'), TileSelection.rangeMiddle);
      expect(_kindFor(tester, '26'), TileSelection.rangeEnd);
    });

    testWidgets('selectRange no-ops outside range mode', (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        controller: controller,
      )));
      controller.selectRange(_day(23), _day(26));
      await tester.pump();
      expect(controller.selectedDates, isEmpty);
    });

    testWidgets('setDateAndAnimate replaces the whole selection',
        (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectedDates: [_day(22), _day(23)],
        controller: controller,
        selectionColor: Colors.black,
      )));
      controller.setDateAndAnimate(_day(24));
      await tester.pumpAndSettle();
      expect(controller.selectedDates, [_day(24)]);
      expect(_selectionColorFor(tester, '24'), Colors.black);
      // Scroll back so the previously selected tile is rebuilt and visible.
      controller.animateToDate(_start);
      await tester.pumpAndSettle();
      expect(_selectionColorFor(tester, '22'), Colors.transparent);
    });

    testWidgets('all selection methods no-op after unmount', (tester) async {
      final controller = DatePickerController();
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        selectionMode: SelectionMode.multiple,
        selectedDates: [_day(22)],
        controller: controller,
      )));
      await tester.pumpWidget(_wrap(const SizedBox()));
      controller.select(_day(24));
      controller.deselect(_day(22));
      controller.clearSelection();
      controller.selectRange(_day(23), _day(26));
      expect(controller.selectedDates, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('single mode also reports through onSelectionChange',
        (tester) async {
      final emissions = <List<DateTime>>[];
      DateTime? changed;
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        initialSelectedDate: _start,
        onDateChange: (d) => changed = d,
        onSelectionChange: emissions.add,
      )));
      await tester.tap(find.text('24'));
      await tester.pump();
      expect(changed, _day(24));
      expect(emissions.single, [_day(24)]);
    });

    testWidgets('a default picker renders no band widgets', (tester) async {
      await tester.pumpWidget(_wrap(DatePicker(
        _start,
        initialSelectedDate: _start,
      )));
      expect(_anyBand, findsNothing);
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
