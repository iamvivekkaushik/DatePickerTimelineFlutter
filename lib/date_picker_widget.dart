import 'package:date_picker_timeline/gregorian_date/gregorian_date_widget.dart';
import 'package:date_picker_timeline/extra/color.dart';
import 'package:date_picker_timeline/extra/dimen.dart';
import 'package:date_picker_timeline/extra/style.dart';
import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:date_picker_timeline/persian_date/persian_date.dart';
import 'package:date_picker_timeline/persian_date/persian_date_widget.dart';
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

  /// Current Selected Date
  final DateTime? /*?*/ initialSelectedDate;

  /// Contains the list of inactive dates.
  /// All the dates defined in this List will be deactivated
  final List<DateTime>? inactiveDates;

  /// Contains the list of active dates.
  /// Only the dates in this list will be activated.
  final List<DateTime>? activeDates;

  /// Callback function for when a different date is selected
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
  }) : assert(
            activeDates == null || inactiveDates == null,
            "Can't "
            "provide both activated and deactivated dates List at the same time.");

  @override
  State<StatefulWidget> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? _currentDate;

  final ScrollController _controller = ScrollController();

  late TextStyle selectedDateStyle;
  late TextStyle selectedMonthStyle;
  late TextStyle selectedDayStyle;

  late TextStyle deactivatedDateStyle;
  late TextStyle deactivatedMonthStyle;
  late TextStyle deactivatedDayStyle;

  late DateFormat _monthFormat;
  late DateFormat _dayFormat;

  Set<DateTime>? _inactiveDays;
  Set<DateTime>? _activeDays;

  @override
  void initState() {
    super.initState();

    // Set initial Values
    _currentDate = widget.initialSelectedDate;

    widget.controller?.setDatePickerState(this);

    _initLocale();
    _updateStyles();
    _updateDateSets();
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
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _controller.dispose();
    super.dispose();
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
  }

  void _updateDateSets() {
    _inactiveDays = widget.inactiveDates?.map(DateUtils.dateOnly).toSet();
    _activeDays = widget.activeDates?.map(DateUtils.dateOnly).toSet();
  }

  /// Called by [DatePickerController] so the selection change repaints.
  void _setSelectedDate(DateTime date) {
    setState(() {
      _currentDate = date;
    });
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
        child: ListView.builder(
          itemCount: widget.daysCount,
          scrollDirection: Axis.horizontal,
          controller: _controller,
          // Every tile has a fixed extent (tile width plus its margins);
          // telling the list makes layout cheaper and scroll metrics exact.
          itemExtent: widget.width + 2 * Dimen.tileMargin,
          itemBuilder: (context, index) {
            // Get the date object based on the index position. Uses
            // calendar-day arithmetic (not Duration) so dates stay correct
            // across daylight-saving transitions.
            final DateTime gregorianDate =
                DateUtils.addDaysToDate(widget.startDate, index);
            DateTime date;
            switch (widget.calendarType) {
              case CalendarType.persianDate:
                date = PersianDate.toJalali(
                    gregorianDate.year, gregorianDate.month, gregorianDate.day);
                break;
              case CalendarType.gregorianDate:
                date = gregorianDate;
                break;
            }
            bool isDeactivated = false;

            // check if this date needs to be deactivated for only DeactivatedDates
            if (_inactiveDays != null) {
              isDeactivated = _inactiveDays!.contains(DateUtils.dateOnly(date));
            }

            // check if this date needs to be deactivated for only ActivatedDates
            if (_activeDays != null) {
              isDeactivated = !_activeDays!.contains(DateUtils.dateOnly(date));
            }

            // Check if this date is the one that is currently selected
            bool isSelected = _currentDate != null
                ? DateUtils.isSameDay(date, _currentDate!)
                : false;
            // Return the Date Widget
            switch (widget.calendarType) {
              case CalendarType.gregorianDate:
                return GregorianDateWidget(
                  date: date,
                  monthFormat: _monthFormat,
                  dayFormat: _dayFormat,
                  monthTextStyle: isDeactivated
                      ? deactivatedMonthStyle
                      : isSelected
                          ? selectedMonthStyle
                          : widget.monthTextStyle,
                  dateTextStyle: isDeactivated
                      ? deactivatedDateStyle
                      : isSelected
                          ? selectedDateStyle
                          : widget.dateTextStyle,
                  dayTextStyle: isDeactivated
                      ? deactivatedDayStyle
                      : isSelected
                          ? selectedDayStyle
                          : widget.dayTextStyle,
                  width: widget.width,
                  locale: widget.locale,
                  selectionColor:
                      isSelected ? widget.selectionColor : Colors.transparent,
                  onDateSelected: (selectedDate) {
                    // Don't notify listener if date is deactivated
                    if (isDeactivated) return;

                    // A date is selected
                    widget.onDateChange?.call(selectedDate);

                    setState(() {
                      _currentDate = selectedDate;
                    });
                  },
                );
              case CalendarType.persianDate:
                return PersianDateWidget(
                  date: date,
                  monthTextStyle: isDeactivated
                      ? deactivatedMonthStyle
                      : isSelected
                          ? selectedMonthStyle
                          : widget.monthTextStyle,
                  dateTextStyle: isDeactivated
                      ? deactivatedDateStyle
                      : isSelected
                          ? selectedDateStyle
                          : widget.dateTextStyle,
                  dayTextStyle: isDeactivated
                      ? deactivatedDayStyle
                      : isSelected
                          ? selectedDayStyle
                          : widget.dayTextStyle,
                  width: widget.width,
                  locale: widget.locale,
                  selectionColor:
                      isSelected ? widget.selectionColor : Colors.transparent,
                  onDateSelected: (selectedDate) {
                    // Don't notify listener if date is deactivated
                    if (isDeactivated) return;

                    // A date is selected
                    widget.onDateChange?.call(selectedDate);

                    setState(() {
                      _currentDate = selectedDate;
                    });
                  },
                );
            }
          },
        ),
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

  /// Jumps to the currently selected date.
  /// Does nothing if no date is selected or the picker isn't laid out yet.
  void jumpToSelection() {
    final state = _datePickerState;
    final selected = state?._currentDate;
    if (state == null || selected == null) return;

    final offset = _offsetForDate(selected);
    if (offset == null ||
        !state._controller.hasClients ||
        !state._controller.position.hasContentDimensions) {
      return;
    }

    // jump to the current Date
    state._controller
        .jumpTo(offset.clamp(0.0, state._controller.position.maxScrollExtent));
  }

  /// This function will animate the Timeline to the currently selected Date
  /// Does nothing if no date is selected or the picker isn't laid out yet.
  void animateToSelection(
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.linear}) {
    final selected = _datePickerState?._currentDate;
    if (selected == null) return;

    // animate to the current date
    _animateToOffset(_offsetForDate(selected), duration, curve);
  }

  /// This function will animate to any date that is passed as an argument
  /// In case a date is out of range nothing will happen
  void animateToDate(DateTime date,
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.linear}) {
    _animateToOffset(_offsetForDate(date), duration, curve);
  }

  /// This function will animate to any date that is passed as an argument
  /// this will also set that date as the current selected date
  /// In case a date is out of range nothing will happen
  void setDateAndAnimate(DateTime date,
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.linear}) {
    final state = _datePickerState;
    if (state == null) return;

    final offset = _offsetForDate(date);
    if (offset == null) return; // date is out of range

    state._setSelectedDate(date);
    _animateToOffset(offset, duration, curve);
  }

  void _animateToOffset(double? offset, Duration duration, Curve curve) {
    final state = _datePickerState;
    if (state == null ||
        offset == null ||
        !state._controller.hasClients ||
        !state._controller.position.hasContentDimensions) {
      return;
    }
    state._controller.animateTo(
        offset.clamp(0.0, state._controller.position.maxScrollExtent),
        duration: duration,
        curve: curve);
  }

  /// Number of pixels to scroll so [date]'s tile is at the leading edge,
  /// or null when the date is outside the rendered range or the controller
  /// is detached.
  /// Day arithmetic is done in UTC so daylight-saving transitions between
  /// the start date and [date] can't skew the day count.
  double? _offsetForDate(DateTime date) {
    final state = _datePickerState;
    if (state == null) return null;
    final start = state.widget.startDate;
    final offset = DateTime.utc(date.year, date.month, date.day)
        .difference(DateTime.utc(start.year, start.month, start.day))
        .inDays;
    if (offset < 0 || offset >= state.widget.daysCount) return null;

    return offset * (state.widget.width + 2 * Dimen.tileMargin);
  }
}
