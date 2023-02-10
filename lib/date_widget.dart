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
  final double? width;
  final DateTime date;
  final TextStyle monthTextStyle;
  final TextStyle dayTextStyle;
  final TextStyle dateTextStyle;
  final Color selectionColor;
  final DateSelectionCallback? onDateSelected;
  final String? locale;
  final bool showMonth;
  final Widget Function(DateTime date)? builder;

  DateWidget({
    required this.date,
    required this.monthTextStyle,
    required this.dayTextStyle,
    required this.dateTextStyle,
    required this.selectionColor,
    this.width,
    this.showMonth = false,
    this.onDateSelected,
    this.locale,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      InkWell(
        child: builder!(date),
        onTap: () {
          // Check if onDateSelected is not null
          if (onDateSelected != null) {
            // Call the onDateSelected Function
            onDateSelected!(this.date);
          }
        },
      );
    }
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
              if (showMonth)
                Text(
                  new DateFormat("MMM", locale)
                      .format(date)
                      .toUpperCase(), // Month
                  style: monthTextStyle,
                ),
              Text(
                new DateFormat("E", locale)
                    .format(date)
                    .toUpperCase(), // WeekDay
                style: dayTextStyle,
              ),
              Text(
                date.day.toString(), // Date
                style: dateTextStyle,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        // Check if onDateSelected is not null
        if (onDateSelected != null) {
          // Call the onDateSelected Function
          onDateSelected!(this.date);
        }
      },
    );
  }
}
