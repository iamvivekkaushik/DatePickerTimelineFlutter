library date_picker_timeline;

import 'package:date_picker_timeline/date_widget.dart';
import 'package:date_picker_timeline/extra/color.dart';
import 'package:date_picker_timeline/extra/dimen.dart';
import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';

class DatePickerTimeline extends StatefulWidget {
  double dateSize, daySize, monthSize;
  Color dateColor, monthColor, dayColor;
  Color selectionColor;
  DateTime currentDate;
  DateChangeListener onDateChange;

  // Creates the DatePickerTimeline Widget
  DatePickerTimeline(
    this.currentDate, {
    Key key,
    this.dateSize = Dimen.dateTextSize,
    this.daySize = Dimen.dayTextSize,
    this.monthSize = Dimen.monthTextSize,
    this.dateColor = AppColors.defaultDateColor,
    this.monthColor = AppColors.defaultMonthColor,
    this.dayColor = AppColors.defaultDayColor,
    this.selectionColor = AppColors.defaultSelectionColor,
    this.onDateChange,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DatePickerState();
}

class _DatePickerState extends State<DatePickerTimeline> {
  @override
  void initState() {
    DateTime _date = DateTime.now();
    widget.currentDate = new DateTime(_date.year, _date.month, _date.day);;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.builder(
        itemCount: 50000,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          // Return the Date Widget
          DateTime _date = DateTime.now().add(Duration(days: index));
          DateTime date = new DateTime(_date.year, _date.month, _date.day);
          bool isSelected = compareDate(date, widget.currentDate);

          return DateWidget(
            date: date,
            dateColor: widget.dateColor,
            dateSize: widget.dateSize,
            dayColor: widget.dayColor,
            daySize: widget.daySize,
            monthColor: widget.monthColor,
            monthSize: widget.monthSize,
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
    return date1.day == date2.day  &&  date1.month == date2.month && date1.year == date2.year;
  }
}
