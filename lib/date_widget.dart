/// ***
/// This class consists of the DateWidget that is used in the ListView.builder
///
/// Author: Vivek Kaushik <me@vivekkasuhik.com>
/// github: https://github.com/iamvivekkaushik/
/// ***

import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'extra/style.dart';

class DateWidget extends StatelessWidget {
  final double width;
  final DateTime date;
  final TextStyle monthTextStyle, dayTextStyle, dateTextStyle;
  final Color selectionColor;
  final DateSelectionCallback onDateSelected;
  final String locale;
  final bool isEnabled;

  DateWidget({
    @required this.date,
    @required this.monthTextStyle,
    @required this.dayTextStyle,
    @required this.dateTextStyle,
    @required this.selectionColor,
    @required this.isEnabled,
    this.width,
    this.onDateSelected,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: width,
        margin: EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          color: selectionColor,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                  new DateFormat("MMM", locale)
                      .format(date)
                      .toUpperCase(), // Month
                  style: isEnabled ? monthTextStyle : disabledMonthTextStyle),
              Text(date.day.toString(), // Date
                  style: isEnabled ? dateTextStyle : disabledDateTextStyle),
              Text(
                  new DateFormat("E", locale)
                      .format(date)
                      .toUpperCase(), // WeekDay
                  style: isEnabled ? dayTextStyle : disabledDayTextStyle)
            ],
          ),
        ),
      ),
      onTap: () {
        // Check if a enabled date
        if (!isEnabled) return;

        // Check if onDateSelected is not null
        if (onDateSelected != null) {
          // Call the onDateSelected Function
          onDateSelected(this.date);
        }
      },
    );
  }
}
