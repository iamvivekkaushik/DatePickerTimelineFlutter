import 'package:date_picker_timeline/gregorian_date/gregorian_date_widget.dart';
import 'package:date_picker_timeline/extra/color.dart';
import 'package:date_picker_timeline/extra/dimen.dart';
import 'package:date_picker_timeline/extra/style.dart';
import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:date_picker_timeline/granularity.dart';
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
  /// All the dates defined in this List will be deactivated.
  /// In week/month [granularity] each entry deactivates the whole unit
  /// containing it.
  final List<DateTime>? inactiveDates;

  /// Contains the list of active dates.
  /// Only the dates in this list will be activated.
  /// In week/month [granularity] each entry activates the whole unit
  /// containing it.
  final List<DateTime>? activeDates;

  /// Callback function for when a different date is selected.
  /// Only fires in [SelectionMode.single] — use [onSelectionChange] for
  /// [SelectionMode.multiple] and [SelectionMode.range].
  final DateChangeListener? onDateChange;

  /// Number of tiles rendered from [startDate], where each tile is one
  /// [granularity] unit — days by default (the historical meaning), weeks
  /// or months otherwise.
  final int daysCount;

  /// Calendar type
  final CalendarType calendarType;

  /// Directionality
  final TextDirection? directionality;

  /// Locale for the calendar default: en_us
  final String locale;

  /// When true, the timeline also shows past dates: half of [daysCount]
  /// units falls before the unit containing [startDate], which is treated
  /// as the anchor ("today").
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

  /// The calendar unit each tile represents: one day (the default), one
  /// week, or one month. Tapping a week/month tile selects and emits the
  /// unit's start date. In week/month granularity the first tile is the
  /// unit CONTAINING [startDate], so it may begin before [startDate], and
  /// [daysCount] counts tiles (weeks/months), not days.
  /// Gregorian calendar only.
  final DateGranularity granularity;

  /// First day of the week for [DateGranularity.week], as a
  /// [DateTime.monday]..[DateTime.sunday] constant. When null it is
  /// resolved from the ambient [MaterialLocalizations] (Sunday for
  /// `en_US`; note this is independent of [locale], which only formats
  /// labels). Ignored in the other granularities.
  final int? firstDayOfWeek;

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
    this.granularity = DateGranularity.day,
    this.firstDayOfWeek,
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
            "In range mode selectedDates must be [], [start] or [start, end]."),
        assert(
            firstDayOfWeek == null ||
                (firstDayOfWeek >= DateTime.monday &&
                    firstDayOfWeek <= DateTime.sunday),
            "firstDayOfWeek must be a DateTime weekday constant "
            "(DateTime.monday..DateTime.sunday)."),
        assert(
            calendarType == CalendarType.gregorianDate ||
                granularity == DateGranularity.day,
            "Week/month granularity is not supported with "
            "CalendarType.persianDate yet.");

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

  /// Effective first day of the week (DateTime.monday..sunday), resolved in
  /// [didChangeDependencies]/[didUpdateWidget] from [DatePicker
  /// .firstDayOfWeek] or the ambient [MaterialLocalizations].
  late int _firstDayOfWeek;

  /// Selection seeding is deferred to the first [didChangeDependencies]
  /// because [_unitKey] may need [MaterialLocalizations], which cannot be
  /// read in [initState]. That first call is guaranteed to run before the
  /// first build, so nothing can observe the gap.
  bool _seeded = false;

  @override
  void initState() {
    super.initState();

    widget.controller?.setDatePickerState(this);

    _initLocale();
    _updateStyles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final resolved = _resolveFirstDayOfWeek();
    if (!_seeded) {
      _firstDayOfWeek = resolved;
      // Set initial Values
      if (widget.selectedDates != null) {
        _selection = _normalise(widget.selectedDates!);
      } else if (widget.initialSelectedDate != null) {
        _currentDate = widget.initialSelectedDate;
        _selection = <DateTime>[_unitKey(widget.initialSelectedDate!)];
      }
      _updateDateSets();
      _recomputeSelectionLookups();
      _seeded = true;
    } else if (resolved != _firstDayOfWeek) {
      // The inherited localizations changed at runtime.
      _firstDayOfWeek = resolved;
      _resnapKeys();
    }
  }

  int _resolveFirstDayOfWeek() {
    final override = widget.firstDayOfWeek;
    if (override != null) return override;
    final index =
        Localizations.of<MaterialLocalizations>(context, MaterialLocalizations)
            ?.firstDayOfWeekIndex;
    // No Localizations ancestor: behave like DefaultMaterialLocalizations.
    if (index == null) return DateTime.sunday;
    // MaterialLocalizations is Sunday-based (0 = Sunday .. 6 = Saturday);
    // 1..6 already coincide with DateTime.monday..saturday.
    return index == 0 ? DateTime.sunday : index;
  }

  /// Re-normalises all stored keys after the keying function changed
  /// (granularity or effective first day of week).
  void _resnapKeys() {
    _selection = _normalise(_emit(_selection));
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

    // The keying function may have changed; re-snap stored keys first so the
    // date sets and the adopt block below all speak the new key language.
    final oldFirst = _firstDayOfWeek;
    _firstDayOfWeek = _resolveFirstDayOfWeek();
    if (widget.granularity != oldWidget.granularity ||
        _firstDayOfWeek != oldFirst) {
      _selection = _normalise(_emit(_selection));
    }
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
            !_selection.contains(_unitKey(_currentDate!))) {
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

  /// Number of rendered units before the unit containing
  /// [DatePicker.startDate].
  int get _pastUnitsCount => widget.showPastDates ? widget.daysCount ~/ 2 : 0;

  /// Unit key of index 0, snapped so that index 0 is a unit start.
  DateTime get _timelineStartKey =>
      _addUnitsToKey(_unitKey(widget.startDate), -_pastUnitsCount);

  /// The date the controller and the initial scroll position aim at: the
  /// most recently touched date, falling back to the first selected date
  /// after a [DatePicker.selectedDates] seed or sync.
  DateTime? get _anchorDate =>
      _currentDate ?? (_selection.isEmpty ? null : _selection.first);

  /// Canonical unit key: UTC midnight of the start of the unit containing
  /// [d]. The single normalisation choke point. UTC because it is a
  /// bijection with (y, m, d) — local midnight does not exist on
  /// spring-forward days in some time zones — and because the index math
  /// already works in UTC. Idempotent in every granularity.
  DateTime _unitKey(DateTime d) {
    final day = DateTime.utc(d.year, d.month, d.day);
    switch (widget.granularity) {
      case DateGranularity.day:
        return day;
      case DateGranularity.week:
        // Duration arithmetic on UTC dates is exact calendar-day math.
        return day
            .subtract(Duration(days: (day.weekday - _firstDayOfWeek + 7) % 7));
      case DateGranularity.month:
        return DateTime.utc(d.year, d.month, 1);
    }
  }

  /// [key] must be a unit key; returns the unit key [n] units later
  /// (n may be negative). Preserves the unit-key invariant.
  DateTime _addUnitsToKey(DateTime key, int n) {
    switch (widget.granularity) {
      case DateGranularity.day:
        return DateTime.utc(key.year, key.month, key.day + n);
      case DateGranularity.week:
        return key.add(Duration(days: 7 * n));
      case DateGranularity.month:
        // UTC twin of DateUtils.addMonthsToMonthDate.
        return DateTime.utc(key.year, key.month + n, 1);
    }
  }

  /// Unit key of the tile at [index].
  DateTime _keyOfIndex(int index) => _addUnitsToKey(_timelineStartKey, index);

  /// Local-midnight date handed to tiles and callbacks for the tile at
  /// [index] (the same de-normalisation as [_emit]).
  DateTime _dateOfIndex(int index) {
    final k = _keyOfIndex(index);
    return DateTime(k.year, k.month, k.day);
  }

  /// Normalises caller-supplied dates for the current [SelectionMode]:
  /// day keys, deduped+sorted in multiple mode, sorted and clamped to the
  /// two endpoints in range mode, first-only in single mode. Asserts (in
  /// debug) instead of throwing in release.
  List<DateTime> _normalise(List<DateTime> dates) {
    final keys = dates.map(_unitKey).toList();
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

  /// Raw timeline index of the unit containing [date], relative to index 0;
  /// may be outside the rendered window.
  int _rawIndexOf(DateTime date) {
    final key = _unitKey(date);
    final start = _timelineStartKey;
    switch (widget.granularity) {
      case DateGranularity.day:
        return key.difference(start).inDays;
      case DateGranularity.week:
        // Both operands are snapped week starts, so the difference is an
        // exact multiple of 7 and truncating division is exact even for
        // negative indices.
        return key.difference(start).inDays ~/ 7;
      case DateGranularity.month:
        return DateUtils.monthDelta(start, key);
    }
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
    } else if (_currentDate != null &&
        !next.contains(_unitKey(_currentDate!))) {
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

    final key = _unitKey(tappedDate);
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
    _applyProgrammaticSelection(<DateTime>[_unitKey(date)],
        anchor: _unitKey(date));
  }

  /// What the tile at [index] (showing [date]) paints for the current
  /// selection. Range spans compare indices, not dates: indices are
  /// monotonic for every calendar type, whereas Jalali-valued DateTimes
  /// are not.
  TileSelection _tileSelectionAt(int index, DateTime date) {
    switch (widget.selectionMode) {
      case SelectionMode.single:
        // Check if this date's unit is the one that is currently selected.
        // Unit-key equality (not isSameDay) so a mid-week/mid-month
        // initialSelectedDate still paints its containing tile; identical
        // truth table in day granularity.
        final isSelected =
            _currentDate != null && _unitKey(date) == _unitKey(_currentDate!);
        return isSelected ? TileSelection.selected : TileSelection.none;
      case SelectionMode.multiple:
        return _selectedKeys.contains(_unitKey(date))
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

  /// The three tile labels for week/month granularity, or null in day
  /// granularity (the tile then formats its own labels from the date,
  /// exactly as before). Slots map to the existing styles: top =
  /// monthTextStyle, middle = dateTextStyle, bottom = dayTextStyle.
  ({String top, String middle, String bottom})? _labelsFor(DateTime start) {
    switch (widget.granularity) {
      case DateGranularity.day:
        return null;
      case DateGranularity.week:
        final end = DateUtils.addDaysToDate(start, 6);
        final startMonth = _monthFormat.format(start).toUpperCase();
        final top = end.month == start.month
            ? startMonth
            : '$startMonth–${_monthFormat.format(end).toUpperCase()}';
        return (
          top: top,
          middle: '${start.day}–${end.day}',
          bottom: start.year.toString(),
        );
      case DateGranularity.month:
        return (
          top: start.year.toString(),
          middle: _monthFormat.format(start).toUpperCase(),
          // Empty keeps the three-row Column rhythm so the month label sits
          // where the day number does on day tiles.
          bottom: '',
        );
    }
  }

  /// Scroll offset the picker opens at: 0 normally; with
  /// [DatePicker.showPastDates] the selected date (or the anchor) centered.
  double _initialScrollOffset(double viewportWidth) {
    if (!widget.showPastDates || !viewportWidth.isFinite) return 0;
    final anchor = _anchorDate ?? widget.startDate;
    final index = _rawIndexOf(anchor).clamp(0, widget.daysCount - 1);
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

  /// In week/month granularity each entry applies to the whole unit
  /// containing it: one listed date deactivates (or, for activeDates,
  /// activates) its entire week or month.
  void _updateDateSets() {
    _inactiveDays = widget.inactiveDates?.map(_unitKey).toSet();
    _activeDays = widget.activeDates?.map(_unitKey).toSet();
  }

    @override
  void didUpdateWidget(covariant DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentDate = widget.initialSelectedDate;
   if (widget.controller != null) {
     widget.controller!.animateToSelection();
   }
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
              // The tile's unit-start date, derived from the index through
              // the unit funnels (calendar-safe in every granularity).
              final DateTime gregorianDate = _dateOfIndex(index);
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
                isDeactivated = _inactiveDays!.contains(_unitKey(date));
              }

              // check if this date needs to be deactivated for only ActivatedDates
              if (_activeDays != null) {
                isDeactivated = !_activeDays!.contains(_unitKey(date));
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

              final labels = _labelsFor(gregorianDate);

              // Return the Date Widget
              switch (widget.calendarType) {
                case CalendarType.gregorianDate:
                  return GregorianDateWidget(
                    date: date,
                    monthFormat: _monthFormat,
                    dayFormat: _dayFormat,
                    topLabel: labels?.top,
                    middleLabel: labels?.middle,
                    bottomLabel: labels?.bottom,
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
    final key = state._unitKey(date);
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
    final key = state._unitKey(date);
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
    var a = state._unitKey(start);
    var b = state._unitKey(end);
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
