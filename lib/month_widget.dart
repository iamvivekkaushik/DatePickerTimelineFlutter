import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthWidget extends StatelessWidget {
  final double width;
  final DateTime date;
  final TextStyle monthTextStyle,yearTextStyle;
  final Color selectionColor;
  final DateSelectionCallback onDateSelected;
  final String locale;

  MonthWidget(
      {@required this.date,
        @required this.monthTextStyle,
        @required this.yearTextStyle,
        @required this.selectionColor,
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
              Expanded(
                child: Text(new DateFormat("yyyy", locale).format(date).toUpperCase(), // Month
                    style: yearTextStyle),
              ),
              Text(new DateFormat("MMM", locale).format(date).toUpperCase(), // Month
                  style: monthTextStyle),
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
