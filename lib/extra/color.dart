import 'package:flutter/material.dart';

/// The default colors used by [DatePicker] and its tiles.
///
/// Author: Vivek Kaushik `<me@vivekkasuhik.com>`
/// github: https://github.com/iamvivekkaushik/
class AppColors {
  AppColors._();

  /// Default text color of the day-of-month number.
  static const Color defaultDateColor = Colors.black;

  /// Default text color of the weekday label.
  static const Color defaultDayColor = Colors.black;

  /// Default text color of the month label.
  static const Color defaultMonthColor = Colors.black;

  /// Default background color of the selected tile.
  static const Color defaultSelectionColor = Color(0x30000000);

  /// Default text color for deactivated dates.
  static const Color defaultDeactivatedColor = Color(0xFF666666);

  /// Default color of the band painted between range endpoints.
  static const Color defaultRangeColor = Color(0x1F000000);
}
