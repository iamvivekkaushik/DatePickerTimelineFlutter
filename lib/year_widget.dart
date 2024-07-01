import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearWidget extends StatelessWidget {
  final double? width;
  final DateTime month;
  final TextStyle? yearTextStyle;
  final Color selectionColor, iconColor;
  final DateSelectionCallback? onDateSelected;
  final String? locale;
  final bool isSelected;
  final bool showIcon;

  const YearWidget({
    required this.month,
    required this.yearTextStyle,
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
                "${DateFormat("y", locale).format(month).toUpperCase()}", // Month
                style: yearTextStyle,
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
