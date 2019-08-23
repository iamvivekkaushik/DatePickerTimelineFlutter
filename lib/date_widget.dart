import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatelessWidget {
  final DateTime date;
  final double dateSize, daySize, monthSize;
  final Color dateColor, monthColor, dayColor;
  final Color selectionColor;

  DateWidget({
      @required this.date,
      @required this.dateSize,
      @required this.daySize,
      @required this.monthSize,
      @required this.dateColor,
      @required this.monthColor,
      @required this.dayColor,
      @required this.selectionColor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 13, right: 13),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(new DateFormat("MMM").format(date), // Month
              style: TextStyle(
                color: dateColor,
                fontSize: dateSize,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              )),
          Text(date.day.toString(), // Date
              style: TextStyle(
                color: dateColor,
                fontSize: dateSize,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              )),
          Text(new DateFormat("E").format(date), // WeekDay
              style: TextStyle(
                color: dateColor,
                fontSize: dateSize,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ))
        ],
      ),
    );
  }
}
