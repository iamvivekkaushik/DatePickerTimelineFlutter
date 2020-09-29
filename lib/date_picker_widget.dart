import 'package:date_picker_timeline_trendway/date_widget.dart';
import 'package:date_picker_timeline_trendway/extra/color.dart';
import 'package:date_picker_timeline_trendway/extra/style.dart';
import 'package:date_picker_timeline_trendway/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

class DatePicker extends StatefulWidget {
  /// Start Date in case user wants to show past dates
  /// If not provided calendar will start from the initialSelectedDate
  final DateTime startDate;

  /// Width of the selector
  final double width;

  /// Height of the selector
  final double height;

  /// DatePicker Controller
  final DatePickerController controller;

  /// Text color for the selected Date
  final Color selectedTextColor;

  /// Background color for the selector
  final Color selectionColor;

  /// TextStyle for Month Value
  final TextStyle monthTextStyle;

  /// TextStyle for day Value
  final TextStyle dayTextStyle;

  /// TextStyle for the date Value
  final TextStyle dateTextStyle;

  /// Current Selected Date
  final DateTime initialSelectedDate;

  /// Callback function for when a different date is selected
  final DateChangeListener onDateChange;

  /// Max limit up to which the dates are shown.
  /// Days are counted from the startDate
  final int daysCount;

  /// Locale for the calendar default: en_us
  final String locale;

  /// Enable only dates of this list.
  final List<DateTime> enabledDates;

  DatePicker(
    this.startDate, {
    Key key,
    this.width = 60,
    this.height = 80,
    this.controller,
    this.monthTextStyle = defaultMonthTextStyle,
    this.dayTextStyle = defaultDayTextStyle,
    this.dateTextStyle = defaultDateTextStyle,
    this.selectedTextColor = Colors.white,
    this.selectionColor = AppColors.defaultSelectionColor,
    this.initialSelectedDate,
    this.daysCount = 500,
    this.onDateChange,
    this.locale = "en_US",
    this.enabledDates,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime _currentDate;

  ScrollController _controller = ScrollController();

  TextStyle selectedDateStyle;
  TextStyle selectedMonthStyle;
  TextStyle selectedDayStyle;

  @override
  void initState() {
    // Init the calendar locale
    initializeDateFormatting(widget.locale, null);
    // Set initial Values
    _currentDate = widget.initialSelectedDate;

    if (widget.controller != null) {
      widget.controller.setDatePickerState(this);
    }

    this.selectedDateStyle = createTextStyle(widget.dateTextStyle);
    this.selectedMonthStyle = createTextStyle(widget.monthTextStyle);
    this.selectedDayStyle = createTextStyle(widget.dayTextStyle);

    super.initState();
  }

  /// This will return a text style for the Selected date Text Values
  /// the only change will be the color provided
  TextStyle createTextStyle(TextStyle style) {
    if (widget.selectedTextColor != null) {
      return TextStyle(
        color: widget.selectedTextColor,
        fontSize: style.fontSize,
        fontWeight: style.fontWeight,
        fontFamily: style.fontFamily,
        letterSpacing: style.letterSpacing,
      );
    } else {
      return style;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: ListView.builder(
        itemCount: widget.daysCount,
        scrollDirection: Axis.horizontal,
        controller: _controller,
        itemBuilder: (context, index) {
          // get the date object based on the index position
          // if widget.startDate is null then use the initialDateValue
          DateTime date;
          DateTime _date = widget.startDate.add(Duration(days: index));
          date = new DateTime(_date.year, _date.month, _date.day);

          // Check if this date is the one that is currently selected
          bool isSelected =
              _currentDate != null ? _compareDate(date, _currentDate) : false;

          // Return the Date Widget
          return DateWidget(
            date: date,
            monthTextStyle:
                isSelected ? selectedMonthStyle : widget.monthTextStyle,
            dateTextStyle:
                isSelected ? selectedDateStyle : widget.dateTextStyle,
            dayTextStyle: isSelected ? selectedDayStyle : widget.dayTextStyle,
            width: widget.width,
            locale: widget.locale,
            selectionColor:
                isSelected ? widget.selectionColor : Colors.transparent,
            isEnabled: _checkIsEnabled(date),
            onDateSelected: (selectedDate) {
              // A date is selected
              if (widget.onDateChange != null) {
                widget.onDateChange(selectedDate);
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

  /// Helper function to compare two dates
  /// Returns True if both dates are the same
  bool _compareDate(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }

  /// Check if date is in enabledDates list
  bool _checkIsEnabled(DateTime date) {
    if (widget.enabledDates == null) return true;

    return widget.enabledDates.any((element) => _compareDate(element, date));
  }
}

class DatePickerController {
  _DatePickerState _datePickerState;

  void setDatePickerState(_DatePickerState state) {
    _datePickerState = state;
  }

  void jumpToSelection() {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    // jump to the current Date
    _datePickerState._controller
        .jumpTo(_calculateDateOffset(_datePickerState._currentDate));
  }

  /// This function will animate the Timeline to the currently selected Date
  void animateToSelection(
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    // animate to the current date
    _datePickerState._controller.animateTo(
        _calculateDateOffset(_datePickerState._currentDate),
        duration: duration,
        curve: curve);
  }

  /// This function will animate to any date that is passed as a parameter
  /// In case a date is out of range nothing will happen
  void animateToDate(DateTime date,
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    _datePickerState._controller.animateTo(_calculateDateOffset(date),
        duration: duration, curve: curve);
  }

  /// Calculate the number of pixels that needs to be scrolled to go to the
  /// date provided in the argument
  double _calculateDateOffset(DateTime date) {
    int offset = date.difference(_datePickerState.widget.startDate).inDays + 1;
    return (offset * _datePickerState.widget.width) + (offset * 6);
  }
}
