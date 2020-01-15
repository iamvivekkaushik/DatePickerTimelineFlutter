library date_picker_timeline;

import 'package:date_picker_timeline/date_widget.dart';
import 'package:date_picker_timeline/extra/color.dart';
import 'package:date_picker_timeline/extra/style.dart';
import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'extra/color.dart';
import 'extra/color.dart';
import 'extra/color.dart';

class DatePickerTimeline extends StatefulWidget {
  double width;
  double height;

  TextStyle monthTextStyle, dayTextStyle, dateTextStyle;
  Color selectionColor, inactiveTextColor;
  DateTime currentDate;
  DateChangeListener onDateChange;
  int daysCount;
  String locale;

  // Creates the DatePickerTimeline Widget
  DatePickerTimeline(
    this.currentDate, {
    Key key,
    this.width,
    this.height = 80,
    this.monthTextStyle = defaultMonthTextStyle,
    this.dayTextStyle = defaultDayTextStyle,
    this.dateTextStyle = defaultDateTextStyle,
    this.selectionColor = AppColors.defaultSelectionColor,
    this.inactiveTextColor = AppColors.defaultInactiveColor,
    this.daysCount = 50000,
    this.onDateChange,
    this.locale = "en_US",
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DatePickerState();
}

class _DatePickerState extends State<DatePickerTimeline> {

  @override void initState() {
    super.initState();

    initializeDateFormatting(widget.locale, null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: InfiniteListView.builder(
        itemCount: widget.daysCount,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          // Return the Date Widget
          DateTime _date = DateTime.now().add(Duration(days: index));
          DateTime date = new DateTime(_date.year, _date.month, _date.day);
          bool isSelected = compareDate(date, widget.currentDate);

          return DateWidget(
            date: date,
            monthTextStyle: widget.monthTextStyle.copyWith(color: isSelected ? AppColors.defaultMonthColor : widget.inactiveTextColor),
            dateTextStyle: widget.dateTextStyle.copyWith(color: isSelected ? AppColors.defaultDateColor : widget.inactiveTextColor),
            dayTextStyle: widget.dayTextStyle.copyWith(color: isSelected ? AppColors.defaultDayColor : widget.inactiveTextColor),
            locale: widget.locale,
            selectionColor:
                isSelected ? widget.selectionColor : Colors.transparent,
            onDateSelected: (selectedDate) {
              // A date is selected
              if (widget.onDateChange != null) {
                widget.onDateChange(selectedDate);
              }
              setState(() {
                widget.currentDate = selectedDate;
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
