import 'package:date_picker_timeline/extra/color.dart';
import 'package:date_picker_timeline/extra/style.dart';
import 'package:date_picker_timeline/year_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'gestures/tap.dart';

class YearPickerTimeline extends StatefulWidget {
  /// Height of the selector
  final double height;
  final double width;
  final DateTime startDate;
  final DateTime? initialSelectedDate;

  final int yearCount;
  final String locale;
  final TextStyle? yearTextStyle;
  final YearPickerTimelineController? controller;
  final DateChangeListener? onDateChange;

  final Color selectedTextColor;
  final Color selectionColor;
  final Color iconColor;

  const YearPickerTimeline(
      {Key? key,
      required this.startDate,
      this.initialSelectedDate,
      this.width = 60,
      this.yearCount = 12,
      this.height = 80,
      this.locale = "pt_BR",
      this.yearTextStyle = defaultYearTextStyle,
      this.controller,
      this.onDateChange,
      this.selectedTextColor = Colors.white,
      this.iconColor = Colors.white,
      this.selectionColor = AppColors.defaultSelectionColor})
      : super(key: key);

  @override
  State<YearPickerTimeline> createState() => _YearPickerTimelineState();
}

class _YearPickerTimelineState extends State<YearPickerTimeline> {
  DateTime? _currentDate;

  final ScrollController _controller = ScrollController();

  final yearTimelineController = YearPickerTimelineController();

  late final TextStyle selectedYearStyle;

  @override
  void initState() {
    initializeDateFormatting(widget.locale, null);

    _currentDate = widget.initialSelectedDate;

    selectedYearStyle = widget.yearTextStyle!
        .copyWith(color: widget.selectedTextColor, fontWeight: FontWeight.bold);
    print(selectedYearStyle);

    if (widget.controller != null) {
      widget.controller!.setMonthTimelineState(this);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width * widget.yearCount,
      child: ListView.builder(
        itemCount: widget.yearCount,
        scrollDirection: Axis.horizontal,
        controller: _controller,
        reverse: true,
        itemBuilder: (context, index) {
          DateTime date =
              widget.startDate.subtract(Duration(days: index * 365));
          date = _firstDayOfMonth(date);

          // Check if this date is the one that is currently selected
          bool isSelected = _currentDate != null
              ? DateUtils.isSameMonth(date, _currentDate!)
              : false;

          return YearWidget(
            width: widget.width,
            locale: widget.locale,
            month: date,
            isSelected: isSelected,
            yearTextStyle:
                isSelected ? selectedYearStyle : widget.yearTextStyle,
            selectionColor:
                isSelected ? widget.selectionColor : Colors.transparent,
            iconColor: isSelected ? widget.iconColor : widget.selectionColor,
            onDateSelected: (selectedDate) {
              // A date is selected
              if (widget.onDateChange != null) {
                widget.onDateChange!(selectedDate);
              }
              setState(() {
                _currentDate = selectedDate;
              });
            },
          );
        },
      ),
    );
  }

  // function to convert month to last day of month
  DateTime _lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // function to convert month to fist day of month
  DateTime _firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  bool _compareDate(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }
}

class YearPickerTimelineController {
  _YearPickerTimelineState? _monthTimelineState;

  void setMonthTimelineState(_YearPickerTimelineState state) {
    _monthTimelineState = state;
  }

  void jumpToSelection() {
    assert(_monthTimelineState != null,
        'DatePickerController is not attached to any DatePicker View.');

    // jump to the current Date
    _monthTimelineState!._controller
        .jumpTo(_calculateDateOffset(_monthTimelineState!._currentDate!));
  }

  /// This function will animate the Timeline to the currently selected Date
  void animateToSelection(
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_monthTimelineState != null,
        'DatePickerController is not attached to any DatePicker View.');

    // animate to the current date
    _monthTimelineState!._controller.animateTo(
        _calculateDateOffset(_monthTimelineState!._currentDate!),
        duration: duration,
        curve: curve);
  }

  /// This function will animate to any date that is passed as an argument
  /// In case a date is out of range nothing will happen
  void animateToDate(DateTime date,
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_monthTimelineState != null,
        'MonthTimelineController is not attached to any DatePicker View.');

    _monthTimelineState!._controller.animateTo(_calculateDateOffset(date),
        duration: duration, curve: curve);
  }

  /// This function will animate to any date that is passed as an argument
  /// this will also set that date as the current selected date
  void setDateAndAnimate(DateTime date,
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_monthTimelineState != null,
        'DatePickerController is not attached to any DatePicker View.');

    _monthTimelineState!._controller.animateTo(_calculateDateOffset(date),
        duration: duration, curve: curve);

    if (date.compareTo(_monthTimelineState!.widget.startDate) >= 0 &&
        date.compareTo(_monthTimelineState!.widget.startDate
                .add(Duration(days: _monthTimelineState!.widget.yearCount))) <=
            0) {
      // date is in the range
      _monthTimelineState!._currentDate = date;
    }
  }

  /// Calculate the number of pixels that needs to be scrolled to go to the
  /// date provided in the argument
  double _calculateDateOffset(DateTime date) {
    final startDate = DateTime(
        _monthTimelineState!.widget.startDate.year,
        _monthTimelineState!.widget.startDate.month,
        _monthTimelineState!.widget.startDate.day);

    int offset = date.difference(startDate).inDays;
    return (offset * _monthTimelineState!.widget.width) + (offset * 6);
  }
}
