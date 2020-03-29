import 'package:date_picker_timeline/date_widget.dart';
import 'package:date_picker_timeline/extra/color.dart';
import 'package:date_picker_timeline/extra/style.dart';
import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

class DatePicker extends StatefulWidget {
  /// Width of the selector
  final double width;

  /// Height of the selector
  final double height;

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

  /// Start Date in case user wants to show past dates
  /// If not provided calendar will start from the initialSelectedDate
  final DateTime startDate;

  /// Max limit up to which the dates are shown
  final int daysCount;

  /// Locale for the calendar default: en_us
  final String locale;

  DatePicker(
    this.initialSelectedDate, {
    Key key,
    this.width,
    this.height = 80,
    this.monthTextStyle = defaultMonthTextStyle,
    this.dayTextStyle = defaultDayTextStyle,
    this.dateTextStyle = defaultDateTextStyle,
    this.selectedTextColor = Colors.white,
    this.selectionColor = AppColors.defaultSelectionColor,
    this.startDate,
    this.daysCount = 50000,
    this.onDateChange,
    this.locale = "en_US",
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime _currentDate;

  TextStyle selectedDateStyle;
  TextStyle selectedMonthStyle;
  TextStyle selectedDayStyle;

  @override
  void initState() {
    // Init the calendar locale
    initializeDateFormatting(widget.locale, null);
    
    // Set initial Values
    _currentDate = widget.initialSelectedDate;
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
        itemBuilder: (context, index) {
          // get the date object based on the index position
          // if widget.startDate is null then use the initialDateValue
          DateTime date;
          if (widget.startDate != null) {
            DateTime _date = widget.startDate.add(Duration(days: index));
            date = new DateTime(_date.year, _date.month, _date.day);
          } else {
            DateTime _date = widget.initialSelectedDate.add(Duration(days: index));
            date = new DateTime(_date.year, _date.month, _date.day);
          }

          // Check if this date is the one that is currently selected
          bool isSelected = compareDate(date, _currentDate);

          // Return the Date Widget
          return DateWidget(
            date: date,
            monthTextStyle: isSelected ? selectedMonthStyle : widget.monthTextStyle,
            dateTextStyle: isSelected ? selectedDateStyle : widget.dateTextStyle,
            dayTextStyle: isSelected ? selectedDayStyle : widget.dayTextStyle,
            width: widget.width,
            locale: widget.locale,
            selectionColor:
                isSelected ? widget.selectionColor : Colors.transparent,
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

  bool compareDate(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }
}
