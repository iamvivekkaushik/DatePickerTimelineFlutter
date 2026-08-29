import 'package:date_picker_timeline/gregorian_date/gregorian_date_widget.dart';
import 'package:date_picker_timeline/extra/color.dart';
import 'package:date_picker_timeline/extra/dimen.dart';
import 'package:date_picker_timeline/extra/style.dart';
import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:date_picker_timeline/persian_date/persian_date.dart';
import 'package:date_picker_timeline/persian_date/persian_date_widget.dart';
import 'package:date_picker_timeline/selection.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;

part 'date_type.dart';

class DatePicker extends StatefulWidget {
  /// Start Date in case user wants to show past dates
  /// If not provided calendar will start from the initialSelectedDate
  final DateTime startDate;

  /// Width of the selector
  final double width;

  /// Height of the selector
  final double height;

  /// DatePicker Controller
  final DatePickerController? controller;

  /// Text color for the selected Date
  final Color selectedTextColor;

  /// Background color for the selector
  final Color selectionColor;

  /// Text Color for the deactivated dates
  final Color deactivatedColor;

  /// TextStyle for Month Value
  final TextStyle monthTextStyle;

  /// TextStyle for day Value
  final TextStyle dayTextStyle;

  /// TextStyle for the date Value
  final TextStyle dateTextStyle;

  /// Current Selected Date. Only applies to [SelectionMode.single];
  /// use [selectedDates] with the other modes.
  final DateTime? /*?*/ initialSelectedDate;

  /// Contains the list of inactive dates.
  /// All the dates defined in this List will be deactivated
  final List<DateTime>? inactiveDates;

  /// Contains the list of active dates.
  /// Only the dates in this list will be activated.
  final List<DateTime>? activeDates;

  /// Callback function for when a different date is selected.
  /// Only fires in [SelectionMode.single] — use [onSelectionChange] for
  /// [SelectionMode.multiple] and [SelectionMode.range].
  final DateChangeListener? onDateChange;

  /// Max limit up to which the dates are shown.
  /// Days are counted from the startDate
  final int daysCount;

  /// Calendar type
  final CalendarType calendarType;

  /// Directionality
  final TextDirection? directionality;

  /// Locale for the calendar default: en_us
  final String locale;

  /// When true, the timeline also shows past dates: half of [daysCount]
  /// falls before [startDate], which is treated as the anchor ("today").
  /// The picker opens with the selected date (or the anchor) in the center
  /// of the viewport, and all [DatePickerController] methods scroll dates
  /// to the center instead of the leading edge.
  final bool showPastDates;

  /// How taps change the selection: exactly one date ([SelectionMode.single],
  /// the default), any number of dates ([SelectionMode.multiple] — tapping a
  /// selected date removes it), or a start/end pair ([SelectionMode.range]).
  final SelectionMode selectionMode;

  /// Seeds the selection, and adopts the list again whenever its contents
  /// change between builds (pass the value received in [onSelectionChange]
  /// back in to drive the picker as a controlled component). `null` means
  /// the picker owns its selection; pass `[]` to clear it.
  /// In [SelectionMode.range] it holds `[start]` or `[start, end]`.
  final List<DateTime>? selectedDates;

  /// Called with the whole selection after every tap, in every mode.
  /// In [SelectionMode.range] it fires with one date after the first tap
  /// (the pending start) and two after the second (`[start, end]`).
  final SelectionChangeListener? onSelectionChange;

  /// Color of the band painted behind the days between the endpoints of a
  /// range selection. The endpoints themselves keep [selectionColor].
  final Color rangeColor;

  /// Text color for the days between the endpoints of a range selection.
  /// Defaults to the normal text styles.
  final Color? rangeTextColor;

  const DatePicker(
    this.startDate, {
    super.key,
    this.width = 60,
    this.height = 80,
    this.controller,
    this.monthTextStyle = defaultMonthTextStyle,
    this.dayTextStyle = defaultDayTextStyle,
    this.dateTextStyle = defaultDateTextStyle,
    this.selectedTextColor = Colors.white,
    this.selectionColor = AppColors.defaultSelectionColor,
    this.deactivatedColor = AppColors.defaultDeactivatedColor,
    this.initialSelectedDate,
    this.activeDates,
    this.inactiveDates,
    this.daysCount = 500,
    this.onDateChange,
    this.locale = "en_US",
    this.calendarType = CalendarType.gregorianDate,
    this.directionality,
    this.showPastDates = false,
    this.selectionMode = SelectionMode.single,
    this.selectedDates,
    this.onSelectionChange,
    this.rangeColor = AppColors.defaultRangeColor,
    this.rangeTextColor,
  })  : assert(
            activeDates == null || inactiveDates == null,
            "Can't "
            "provide both activated and deactivated dates List at the same time."),
        assert(
            selectionMode == SelectionMode.single ||
                initialSelectedDate == null,
            "initialSelectedDate only applies to SelectionMode.single. "
            "Use selectedDates with multiple/range."),
        assert(
            selectionMode != SelectionMode.single || selectedDates == null,
            "selectedDates requires SelectionMode.multiple or .range. "
            "Use initialSelectedDate in single mode."),
        assert(
            selectedDates == null ||
                selectionMode != SelectionMode.range ||
                selectedDates.length <= 2,
            "In range mode selectedDates must be [], [start] or [start, end].");

  @override
  State<StatefulWidget> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  /// The scroll anchor: the most recently tapped or programmatically set
  /// date. In [SelectionMode.single] it is also the selection itself.
  DateTime? _currentDate;

  /// The selection, as canonical UTC day keys ([_dayKey]): 0-1 entries in
  /// single mode, sorted+deduped in multiple mode, and `[]` / `[start]` /
  /// `[start, end]` in range mode.
  List<DateTime> _selection = <DateTime>[];

  /// O(1) tile lookup for [SelectionMode.multiple].
  Set<DateTime> _selectedKeys = <DateTime>{};

  /// Raw (unclamped) timeline indices of the range endpoints, so a span
  /// whose endpoint sits outside the rendered window still paints its
  /// in-window days as middles. Null when not in range mode / no range.
  int? _rangeStartIndex;
  int? _rangeEndIndex;

  // Created lazily on the first layout so the initial scroll offset can be
  // computed from the real viewport width (needed to center the anchor when
  // [DatePicker.showPastDates] is enabled).
  ScrollController? _controller;

  late TextStyle selectedDateStyle;
  late TextStyle selectedMonthStyle;
  late TextStyle selectedDayStyle;

  late TextStyle deactivatedDateStyle;
  late TextStyle deactivatedMonthStyle;
  late TextStyle deactivatedDayStyle;

  TextStyle? _rangeDateStyle;
  TextStyle? _rangeMonthStyle;
  TextStyle? _rangeDayStyle;

  late DateFormat _monthFormat;
  late DateFormat _dayFormat;

  Set<DateTime>? _inactiveDays;
  Set<DateTime>? _activeDays;

  @override
  void initState() {
    super.initState();

    // Set initial Values
    if (widget.selectedDates != null) {
      _selection = _normalise(widget.selectedDates!);
    } else if (widget.initialSelectedDate != null) {
      _currentDate = widget.initialSelectedDate;
      _selection = <DateTime>[_dayKey(widget.initialSelectedDate!)];
    }

    widget.controller?.setDatePickerState(this);

    _initLocale();
    _updateStyles();
    _updateDateSets();
    _recomputeSelectionLookups();
  }

  @override
  void didUpdateWidget(DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?.setDatePickerState(this);
    }
    if (widget.locale != oldWidget.locale) {
      _initLocale();
    }
    _updateStyles();
    _updateDateSets();

    // Adopt an updated selectedDates list (controlled usage), guarded so a
    // parent that rebuilds with an equal list can't revert a tap, and so
    // writing the emitted list straight back doesn't reset the anchor.
    final modeChanged = widget.selectionMode != oldWidget.selectionMode;
    final listChanged =
        !listEquals(widget.selectedDates, oldWidget.selectedDates);
    if (modeChanged || (widget.selectedDates != null && listChanged)) {
      final incoming = _normalise(widget.selectedDates ?? _emit(_selection));
      if (modeChanged || !listEquals(incoming, _selection)) {
        _selection = incoming;
        if (_currentDate != null &&
            !_selection.contains(_dayKey(_currentDate!))) {
          _currentDate = null;
        }
        if (widget.selectionMode == SelectionMode.single) {
          _currentDate = _selection.isEmpty ? null : _selection.first;
        }
      }
    }
    // The window (startDate/daysCount/showPastDates) may have shifted.
    _recomputeSelectionLookups();
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _controller?.dispose();
    super.dispose();
  }

  double get _tileExtent => widget.width + 2 * Dimen.tileMargin;

  /// Number of rendered days that fall before [DatePicker.startDate].
  int get _pastDaysCount => widget.showPastDates ? widget.daysCount ~/ 2 : 0;

  /// The first date on the timeline (index 0).
  DateTime get _rangeStartDate =>
      DateUtils.addDaysToDate(widget.startDate, -_pastDaysCount);

  /// The date the controller and the initial scroll position aim at: the
  /// most recently touched date, falling back to the first selected date
  /// after a [DatePicker.selectedDates] seed or sync.
  DateTime? get _anchorDate =>
      _currentDate ?? (_selection.isEmpty ? null : _selection.first);

  /// Canonical day key: the single normalisation choke point. UTC because
  /// it is a bijection with (y, m, d) — local midnight does not exist on
  /// spring-forward days in some time zones — and because the index math
  /// already works in UTC.
  DateTime _dayKey(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  /// Normalises caller-supplied dates for the current [SelectionMode]:
  /// day keys, deduped+sorted in multiple mode, sorted and clamped to the
  /// two endpoints in range mode, first-only in single mode. Asserts (in
  /// debug) instead of throwing in release.
  List<DateTime> _normalise(List<DateTime> dates) {
    final keys = dates.map(_dayKey).toList();
    switch (widget.selectionMode) {
      case SelectionMode.single:
        return keys.isEmpty ? keys : <DateTime>[keys.first];
      case SelectionMode.multiple:
        return keys.toSet().toList()..sort();
      case SelectionMode.range:
        assert(dates.length <= 2,
            "In range mode selectedDates must be [], [start] or [start, end].");
        keys.sort();
        return keys.length <= 2 ? keys : <DateTime>[keys.first, keys.last];
    }
  }

  /// De-normalises keys back to local-midnight dates for callbacks and the
  /// controller getter. Always a fresh growable list.
  List<DateTime> _emit(List<DateTime> keys) =>
      <DateTime>[for (final k in keys) DateTime(k.year, k.month, k.day)];

  /// Raw timeline index of [date]'s calendar day relative to index 0; may
  /// be outside the rendered window.
  int _rawIndexOf(DateTime date) {
    final start = _rangeStartDate;
    return DateTime.utc(date.year, date.month, date.day)
        .difference(DateTime.utc(start.year, start.month, start.day))
        .inDays;
  }

  /// Timeline index of [date]'s tile, or null when it is outside the
  /// rendered window.
  int? _indexOf(DateTime date) {
    final index = _rawIndexOf(date);
    if (index < 0 || index >= widget.daysCount) return null;
    return index;
  }

  void _recomputeSelectionLookups() {
    _selectedKeys = _selection.toSet();
    if (widget.selectionMode == SelectionMode.range && _selection.isNotEmpty) {
      _rangeStartIndex = _rawIndexOf(_selection.first);
      _rangeEndIndex =
          _selection.length == 2 ? _rawIndexOf(_selection.last) : null;
    } else {
      _rangeStartIndex = null;
      _rangeEndIndex = null;
    }
  }

  /// The selection produced by tapping (or programmatically selecting) the
  /// day [key], given the current mode and selection. Pure.
  List<DateTime> _nextSelection(DateTime key) {
    switch (widget.selectionMode) {
      case SelectionMode.single:
        return <DateTime>[key];
      case SelectionMode.multiple:
        final next = List<DateTime>.of(_selection);
        if (!next.remove(key)) {
          next
            ..add(key)
            ..sort();
        }
        return next;
      case SelectionMode.range:
        if (_selection.length != 1) return <DateTime>[key];
        final start = _selection.first;
        return key.isBefore(start)
            ? <DateTime>[key, start]
            : <DateTime>[start, key];
    }
  }

  /// The only selection mutator. [anchor] is the day the interaction
  /// touched; it becomes the scroll anchor when it is (still) selected.
  void _applySelection(List<DateTime> next, {DateTime? anchor}) {
    _selection = next;
    if (next.isEmpty) {
      _currentDate = null;
    } else if (anchor != null) {
      _currentDate = next.contains(anchor) ? anchor : null;
    } else if (_currentDate != null && !next.contains(_dayKey(_currentDate!))) {
      _currentDate = null;
    }
    _recomputeSelectionLookups();
  }

  /// Shared tap handler for both tile widgets. Ordering (preserved from
  /// pre-1.4 single mode): deactivated → nothing fires; [onDateChange]
  /// (single mode only, with the tile's own date); [onSelectionChange]
  /// with the new selection; then the repaint.
  void _handleTap(DateTime tappedDate, bool isDeactivated) {
    // Don't notify listener if date is deactivated
    if (isDeactivated) return;

    final key = _dayKey(tappedDate);
    final next = _nextSelection(key);

    if (widget.selectionMode == SelectionMode.single) {
      widget.onDateChange?.call(tappedDate);
    }
    widget.onSelectionChange?.call(_emit(next));

    setState(() => _applySelection(next, anchor: key));
  }

  /// Silent programmatic mutation used by [DatePickerController]; fires no
  /// callbacks, matching [DatePickerController.setDateAndAnimate]'s
  /// long-standing behavior.
  void _applyProgrammaticSelection(List<DateTime> next, {DateTime? anchor}) {
    setState(() => _applySelection(next, anchor: anchor));
  }

  /// Called by [DatePickerController.setDateAndAnimate]: the selection
  /// becomes exactly `[date]` in every mode.
  void _setSelectedDate(DateTime date) {
    _applyProgrammaticSelection(<DateTime>[_dayKey(date)],
        anchor: _dayKey(date));
  }

  /// What the tile at [index] (showing [date]) paints for the current
  /// selection. Range spans compare indices, not dates: indices are
  /// monotonic for every calendar type, whereas Jalali-valued DateTimes
  /// are not.
  TileSelection _tileSelectionAt(int index, DateTime date) {
    switch (widget.selectionMode) {
      case SelectionMode.single:
        // Check if this date is the one that is currently selected
        final isSelected = _currentDate != null
            ? DateUtils.isSameDay(date, _currentDate!)
            : false;
        return isSelected ? TileSelection.selected : TileSelection.none;
      case SelectionMode.multiple:
        return _selectedKeys.contains(_dayKey(date))
            ? TileSelection.selected
            : TileSelection.none;
      case SelectionMode.range:
        final s = _rangeStartIndex;
        if (s == null) return TileSelection.none;
        final e = _rangeEndIndex;
        if (e == null) {
          // Pending start.
          return index == s ? TileSelection.selected : TileSelection.none;
        }
        if (index < s || index > e) return TileSelection.none;
        if (s == e) return TileSelection.selected;
        if (index == s) return TileSelection.rangeStart;
        if (index == e) return TileSelection.rangeEnd;
        return TileSelection.rangeMiddle;
    }
  }

  /// The three label styles for a tile, in precedence order:
  /// deactivated > selected/endpoint > range middle (when [DatePicker
  /// .rangeTextColor] is set) > the widget's base styles.
  ({TextStyle month, TextStyle date, TextStyle day}) _stylesFor(
      bool isDeactivated, bool isSelected, TileSelection tileSelection) {
    if (isDeactivated) {
      return (
        month: deactivatedMonthStyle,
        date: deactivatedDateStyle,
        day: deactivatedDayStyle,
      );
    }
    if (isSelected) {
      return (
        month: selectedMonthStyle,
        date: selectedDateStyle,
        day: selectedDayStyle,
      );
    }
    if (tileSelection == TileSelection.rangeMiddle &&
        _rangeMonthStyle != null) {
      return (
        month: _rangeMonthStyle!,
        date: _rangeDateStyle!,
        day: _rangeDayStyle!,
      );
    }
    return (
      month: widget.monthTextStyle,
      date: widget.dateTextStyle,
      day: widget.dayTextStyle,
    );
  }

  /// Scroll offset the picker opens at: 0 normally; with
  /// [DatePicker.showPastDates] the selected date (or the anchor) centered.
  double _initialScrollOffset(double viewportWidth) {
    if (!widget.showPastDates || !viewportWidth.isFinite) return 0;
    final anchor = _anchorDate ?? widget.startDate;
    final index = DateTime.utc(anchor.year, anchor.month, anchor.day)
        .difference(DateTime.utc(
            _rangeStartDate.year, _rangeStartDate.month, _rangeStartDate.day))
        .inDays
        .clamp(0, widget.daysCount - 1);
    final centered = index * _tileExtent - (viewportWidth - _tileExtent) / 2;
    final maxOffset = widget.daysCount * _tileExtent - viewportWidth;
    if (maxOffset <= 0) return 0;
    return centered.clamp(0.0, maxOffset);
  }

  void _initLocale() {
    // Init the calendar locale
    initializeDateFormatting(widget.locale, null);
    _monthFormat = DateFormat("MMM", widget.locale);
    _dayFormat = DateFormat("E", widget.locale);
  }

  void _updateStyles() {
    selectedDateStyle =
        widget.dateTextStyle.copyWith(color: widget.selectedTextColor);
    selectedMonthStyle =
        widget.monthTextStyle.copyWith(color: widget.selectedTextColor);
    selectedDayStyle =
        widget.dayTextStyle.copyWith(color: widget.selectedTextColor);

    deactivatedDateStyle =
        widget.dateTextStyle.copyWith(color: widget.deactivatedColor);
    deactivatedMonthStyle =
        widget.monthTextStyle.copyWith(color: widget.deactivatedColor);
    deactivatedDayStyle =
        widget.dayTextStyle.copyWith(color: widget.deactivatedColor);

    final rangeText = widget.rangeTextColor;
    _rangeDateStyle = rangeText == null
        ? null
        : widget.dateTextStyle.copyWith(color: rangeText);
    _rangeMonthStyle = rangeText == null
        ? null
        : widget.monthTextStyle.copyWith(color: rangeText);
    _rangeDayStyle = rangeText == null
        ? null
        : widget.dayTextStyle.copyWith(color: rangeText);
  }

  void _updateDateSets() {
    _inactiveDays = widget.inactiveDates?.map(_dayKey).toSet();
    _activeDays = widget.activeDates?.map(_dayKey).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: (widget.directionality) ??
          ((widget.calendarType == CalendarType.persianDate)
              ? TextDirection.rtl
              : TextDirection.ltr),
      child: SizedBox(
        height: widget.height,
        child: LayoutBuilder(builder: (context, constraints) {
          _controller ??= ScrollController(
              initialScrollOffset: _initialScrollOffset(constraints.maxWidth));
          return ListView.builder(
            itemCount: widget.daysCount,
            scrollDirection: Axis.horizontal,
            controller: _controller,
            // Every tile has a fixed extent (tile width plus its margins);
            // telling the list makes layout cheaper and scroll metrics exact.
            itemExtent: _tileExtent,
            itemBuilder: (context, index) {
              // Get the date object based on the index position. Uses
              // calendar-day arithmetic (not Duration) so dates stay correct
              // across daylight-saving transitions.
              final DateTime gregorianDate =
                  DateUtils.addDaysToDate(_rangeStartDate, index);
              DateTime date;
              switch (widget.calendarType) {
                case CalendarType.persianDate:
                  date = PersianDate.toJalali(gregorianDate.year,
                      gregorianDate.month, gregorianDate.day);
                  break;
                case CalendarType.gregorianDate:
                  date = gregorianDate;
                  break;
              }
              bool isDeactivated = false;

              // check if this date needs to be deactivated for only DeactivatedDates
              if (_inactiveDays != null) {
                isDeactivated = _inactiveDays!.contains(_dayKey(date));
              }

              // check if this date needs to be deactivated for only ActivatedDates
              if (_activeDays != null) {
                isDeactivated = !_activeDays!.contains(_dayKey(date));
              }

              final tileSelection = _tileSelectionAt(index, date);
              // Endpoints and single selections keep the selection pill.
              final isSelected = tileSelection == TileSelection.selected ||
                  tileSelection == TileSelection.rangeStart ||
                  tileSelection == TileSelection.rangeEnd;

              final styles =
                  _stylesFor(isDeactivated, isSelected, tileSelection);
              final selectionColor =
                  isSelected ? widget.selectionColor : Colors.transparent;

              // Return the Date Widget
              switch (widget.calendarType) {
                case CalendarType.gregorianDate:
                  return GregorianDateWidget(
                    date: date,
                    monthFormat: _monthFormat,
                    dayFormat: _dayFormat,
                    monthTextStyle: styles.month,
                    dateTextStyle: styles.date,
                    dayTextStyle: styles.day,
                    width: widget.width,
                    locale: widget.locale,
                    selectionColor: selectionColor,
                    selection: tileSelection,
                    rangeColor: widget.rangeColor,
                    onDateSelected: (selectedDate) =>
                        _handleTap(selectedDate, isDeactivated),
                  );
                case CalendarType.persianDate:
                  return PersianDateWidget(
                    date: date,
                    monthTextStyle: styles.month,
                    dateTextStyle: styles.date,
                    dayTextStyle: styles.day,
                    width: widget.width,
                    locale: widget.locale,
                    selectionColor: selectionColor,
                    selection: tileSelection,
                    rangeColor: widget.rangeColor,
                    onDateSelected: (selectedDate) =>
                        _handleTap(selectedDate, isDeactivated),
                  );
              }
            },
          );
        }),
      ),
    );
  }
}

class DatePickerController {
  _DatePickerState? _datePickerState;

  // ignore: library_private_types_in_public_api
  void setDatePickerState(_DatePickerState state) {
    _datePickerState = state;
  }

  void _detach(_DatePickerState state) {
    if (_datePickerState == state) {
      _datePickerState = null;
    }
  }

  /// Whether this controller is attached to a mounted [DatePicker].
  ///
  /// All navigation methods are no-ops while detached (before the picker is
  /// built, or after it has been unmounted).
  bool get isAttached => _datePickerState != null;

  /// An unmodifiable snapshot of the selection, oldest-first
  /// (`[start, end]` in range mode). `[]` when detached or empty.
  List<DateTime> get selectedDates {
    final state = _datePickerState;
    if (state == null) return const <DateTime>[];
    return List<DateTime>.unmodifiable(state._emit(state._selection));
  }

  /// Adds [date] per the current [SelectionMode]: replaces the selection in
  /// single mode, appends (or keeps) it in multiple mode, and sets or
  /// completes the range in range mode. No-op when detached or [date] is
  /// outside the rendered range. Does not scroll and fires no callbacks.
  void select(DateTime date) {
    final state = _datePickerState;
    if (state == null || state._indexOf(date) == null) return;
    final key = state._dayKey(date);
    // _nextSelection toggles in multiple mode; select() must be additive.
    if (state.widget.selectionMode == SelectionMode.multiple &&
        state._selectedKeys.contains(key)) {
      return;
    }
    state._applyProgrammaticSelection(state._nextSelection(key), anchor: key);
  }

  /// Removes [date] from the selection. No-op when detached, when [date]
  /// isn't selected, or in range mode (use [clearSelection] or
  /// [selectRange]). Does not scroll and fires no callbacks.
  void deselect(DateTime date) {
    final state = _datePickerState;
    if (state == null) return;
    if (state.widget.selectionMode == SelectionMode.range) return;
    final key = state._dayKey(date);
    if (!state._selection.contains(key)) return;
    final next = List<DateTime>.of(state._selection)..remove(key);
    state._applyProgrammaticSelection(next, anchor: key);
  }

  /// Empties the selection (and the scroll anchor) in every mode. No-op
  /// when detached. Fires no callbacks.
  void clearSelection() {
    _datePickerState?._applyProgrammaticSelection(const <DateTime>[]);
  }

  /// Sets both range endpoints at once, swapping them when reversed. No-op
  /// when detached, outside [SelectionMode.range], or when either date is
  /// outside the rendered range. Does not scroll and fires no callbacks.
  void selectRange(DateTime start, DateTime end) {
    final state = _datePickerState;
    if (state == null) return;
    if (state.widget.selectionMode != SelectionMode.range) return;
    if (state._indexOf(start) == null || state._indexOf(end) == null) return;
    var a = state._dayKey(start);
    var b = state._dayKey(end);
    if (b.isBefore(a)) {
      final t = a;
      a = b;
      b = t;
    }
    state._applyProgrammaticSelection(<DateTime>[a, b], anchor: b);
  }

  /// Jumps to the most recently selected date.
  /// Does nothing if no date is selected or the picker isn't laid out yet.
  void jumpToSelection() {
    final selected = _datePickerState?._anchorDate;
    if (selected == null) return;

    final target = _targetOffsetForDate(selected);
    if (target == null) return;

    // jump to the current Date
    _datePickerState!._controller!.jumpTo(target);
  }

  /// This function will animate the Timeline to the most recently selected
  /// date. Does nothing if no date is selected or the picker isn't laid
  /// out yet.
  void animateToSelection(
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.linear}) {
    final selected = _datePickerState?._anchorDate;
    if (selected == null) return;

    // animate to the current date
    _animateToOffset(_targetOffsetForDate(selected), duration, curve);
  }

  /// This function will animate to any date that is passed as an argument
  /// In case a date is out of range nothing will happen
  void animateToDate(DateTime date,
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.linear}) {
    _animateToOffset(_targetOffsetForDate(date), duration, curve);
  }

  /// This function will animate to any date that is passed as an argument.
  /// The selection becomes exactly `[date]` in every mode.
  /// In case a date is out of range nothing will happen
  void setDateAndAnimate(DateTime date,
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.linear}) {
    final state = _datePickerState;
    if (state == null) return;

    if (_indexOfDate(date) == null) return; // date is out of range

    state._setSelectedDate(date);
    // May be null when the picker isn't laid out yet — select without
    // scrolling in that case.
    _animateToOffset(_targetOffsetForDate(date), duration, curve);
  }

  void _animateToOffset(double? offset, Duration duration, Curve curve) {
    if (offset == null) return;
    _datePickerState!._controller!
        .animateTo(offset, duration: duration, curve: curve);
  }

  /// Timeline index of [date]'s tile, or null when [date] is outside the
  /// rendered range or the controller is detached.
  int? _indexOfDate(DateTime date) => _datePickerState?._indexOf(date);

  /// Ready-to-use scroll offset for [date]: leading-edge aligned normally,
  /// centered in the viewport when [DatePicker.showPastDates] is enabled,
  /// clamped to the scrollable range. Null when [date] is out of range or
  /// the picker isn't laid out yet.
  double? _targetOffsetForDate(DateTime date) {
    final index = _indexOfDate(date);
    final state = _datePickerState;
    if (index == null || state == null) return null;

    final scroll = state._controller;
    if (scroll == null ||
        !scroll.hasClients ||
        !scroll.position.hasContentDimensions) {
      return null;
    }

    var target = index * state._tileExtent;
    if (state.widget.showPastDates) {
      target -= (scroll.position.viewportDimension - state._tileExtent) / 2;
    }
    return target.clamp(0.0, scroll.position.maxScrollExtent);
  }
}
