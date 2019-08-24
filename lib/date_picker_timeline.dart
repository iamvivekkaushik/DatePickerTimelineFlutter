library date_picker_timeline;

import 'package:date_picker_timeline/date_widget.dart';
import 'package:date_picker_timeline/extra/color.dart';
import 'package:date_picker_timeline/extra/dimen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerTimeline extends StatefulWidget {
  double dateSize, daySize, monthSize;
  Color dateColor, monthColor, dayColor;
  Color selectionColor;
  DateTime currentDate;

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
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DatePickerState();
}

class _DatePickerState extends State<DatePickerTimeline> {
  @override
  void initState() {
    widget.currentDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.red,
      child: ListView.builder(
        itemCount: 50000,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          // Return the Date Widget
          DateTime date = DateTime.now().add(Duration(days: index));
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
              print(selectedDate.day.toString());
              setState(() {
                widget.currentDate = date;
              });
            },
          );
        },
      ),
    );
  }

  bool compareDate(DateTime date1, DateTime date2) {
    String date1String =
        date1.day.toString() + date1.month.toString() + date1.year.toString();
    String date2String =
        date2.day.toString() + date2.month.toString() + date2.year.toString();

    return date1String == date2String;
  }
}
