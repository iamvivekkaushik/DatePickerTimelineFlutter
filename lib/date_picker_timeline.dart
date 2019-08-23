library date_picker_timeline;

import 'package:date_picker_timeline/date_widget.dart';
import 'package:date_picker_timeline/extra/color.dart';
import 'package:date_picker_timeline/extra/dimen.dart';
import 'package:flutter/material.dart';

class DatePickerTimeline extends StatefulWidget {
  double dateSize, daySize, monthSize;
  Color dateColor, monthColor, dayColor;
  Color selectionColor;
  DateTime currentDate;

  // Creates
  DatePickerTimeline(
      {Key key,
      this.dateSize = Dimen.dateTextSize,
      this.daySize = Dimen.dayTextSize,
      this.monthSize = Dimen.monthTextSize,
      this.dateColor = AppColors.defaultDateColor,
      this.monthColor = AppColors.defaultMonthColor,
      this.dayColor = AppColors.defaultDayColor,
      this.selectionColor = AppColors.defaultSelectionColor,
      this.currentDate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DatePickerState();
}

class _DatePickerState extends State<DatePickerTimeline> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: ListView.builder(
        itemCount: 13,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          // Return the Date Widget
          DateTime date = DateTime.now().add(Duration(days: index));
          return DateWidget(
            date: date,
            dateColor: widget.dateColor,
            dateSize: widget.dateSize,
            dayColor: widget.dayColor,
            daySize: widget.daySize,
            monthColor: widget.monthColor,
            monthSize: widget.monthSize,
            selectionColor: widget.selectionColor,
          );
        },
      ),
    );
  }
}
