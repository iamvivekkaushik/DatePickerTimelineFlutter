import 'package:date_picker_timeline/extra/color.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_timeline/extra/dimen.dart';

/// Default [TextStyle] for the month label on a tile.
const TextStyle defaultMonthTextStyle = TextStyle(
  color: AppColors.defaultMonthColor,
  fontSize: Dimen.monthTextSize,
  fontWeight: FontWeight.w500,
);

/// Default [TextStyle] for the day-of-month number on a tile.
const TextStyle defaultDateTextStyle = TextStyle(
  color: AppColors.defaultDateColor,
  fontSize: Dimen.dateTextSize,
  fontWeight: FontWeight.w500,
);

/// Default [TextStyle] for the weekday label on a tile.
const TextStyle defaultDayTextStyle = TextStyle(
  color: AppColors.defaultDayColor,
  fontSize: Dimen.dayTextSize,
  fontWeight: FontWeight.w500,
);
