import 'package:date_picker_timeline/extra/extensions.dart';
import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthWidget extends StatelessWidget {
  final double? width;
  final DateTime month;
  final TextStyle? monthTextStyle, dateTextStyle;
  final Color selectionColor, iconColor;
  final DateSelectionCallback? onDateSelected;
  final String? locale;
  final bool isSelected;
  final bool showIcon;

  const MonthWidget({
    required this.month,
    required this.monthTextStyle,
    required this.dateTextStyle,
    required this.selectionColor,
    required this.isSelected,
    required this.iconColor,
    this.width,
    this.onDateSelected,
    this.locale,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: width,
        margin: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          color: selectionColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (showIcon)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Icon(
                    Icons.circle,
                    color: iconColor,
                    size: isSelected ? 12 : 8,
                  ),
                ),
              Text(
                "${DateFormat("MMM", locale).format(month).replaceAll(RegExp(r'[.]+'), '').toUpperCase()}\n${DateFormat("y", locale).format(month).toUpperCase().lastChars(2)}", // Month
                style: monthTextStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        // Check if onDateSelected is not null
        if (onDateSelected != null) {
          // Call the onDateSelected Function
          onDateSelected?.call(month);
        }
      },
    );
  }
}
