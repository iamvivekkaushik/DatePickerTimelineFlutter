/// ***
/// This class consists of the DateWidget that is used in the ListView.builder
///
/// Author: Vivek Kaushik <me@vivekkasuhik.com>
/// github: https://github.com/iamvivekkaushik/
/// ***
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatelessWidget {
  final double? width;
  final DateTime date;
  final TextStyle? monthTextStyle, dayTextStyle, dateTextStyle;
  final Color selectionColor;
  final DateSelectionCallback? onDateSelected;
  final String? locale;
  final BoxShape shape;
  final List<DateTimeType> dateSequence;

  DateWidget({
    required this.date,
    required this.monthTextStyle,
    required this.dayTextStyle,
    required this.dateTextStyle,
    required this.selectionColor,
    required this.dateSequence,
    required this.shape,
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
          shape: shape,
          borderRadius: shape == BoxShape.rectangle ? BorderRadius.all(Radius.circular(8.0)) : null,
          color: selectionColor,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            /// making the column center aligned for a fewer options
            mainAxisAlignment: dateSequence.length <= 2 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(dateSequence.length, (index) => _dateTimeWidget(dateSequence[index])),
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

  /// method to get the widgets for month, date and day
  _dateTimeWidget(DateTimeType dateSequence) {
    switch (dateSequence) {
      case DateTimeType.Month:
        return Text(DateFormat("MMM", locale).format(date).toUpperCase(), // Month
            style: monthTextStyle);
      case DateTimeType.Date:
        return Text(date.day.toString(), // Date
            style: dateTextStyle);
      case DateTimeType.WeekDay:
        return Text(DateFormat("E", locale).format(date).toUpperCase(), // WeekDay
            style: dayTextStyle);
    }
  }
}
