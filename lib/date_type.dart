part of 'date_picker_widget.dart';

/// The calendar system a [DatePicker] renders.
enum CalendarType {
  /// The Persian (Jalali) calendar. Renders Jalali month, day and weekday
  /// names, right-to-left by default. Supports day granularity only.
  persianDate,

  /// The Gregorian calendar (the default).
  gregorianDate,
}
