/// ***
/// This class consists of the DateWidget that is used in the ListView.builder
///
/// Author: Vivek Kaushik <me@vivekkasuhik.com>
/// github: https://github.com/iamvivekkaushik/
/// ***

import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatelessWidget {
  final double width;
  final DateTime date;
  final TextStyle monthTextStyle, dayTextStyle, dateTextStyle;
  final Color selectionColor;
  final DateSelectionCallback onDateSelected;
  final String locale;
  final bool shouldShowToday;

  DateWidget({
    @required this.date,
    @required this.monthTextStyle,
    @required this.dayTextStyle,
    @required this.dateTextStyle,
    @required this.selectionColor,
    this.width,
    this.onDateSelected,
    this.shouldShowToday = false,
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
              RichText(
                text: TextSpan(
                  text: DateFormat("MMM", locale)
                      .format(date)
                      .toUpperCase(), // Month
                  style: monthTextStyle,
                ), // WeekDay
              ),
              RichText(
                text: TextSpan(
                  text: date.day.toString(), // Date
                  style: dateTextStyle,
                ), // WeekDay
              ),
              RichText(
                text: TextSpan(
                  text: shouldShowToday
                      ? 'Today'
                      : DateFormat("E", locale).format(date).toUpperCase(),
                  style: dayTextStyle,
                ), // WeekDay
              )
            ],
          ),
        ),
      ),
      onTap: () {
        // Check if onDateSelected is not null
        if (onDateSelected != null) {
          // Call the onDateSelected Function
          onDateSelected(this.date);
        }
      },
    );
  }
}
