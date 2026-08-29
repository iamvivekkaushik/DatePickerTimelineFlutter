/// The calendar unit each tile on the timeline represents.
enum DateGranularity {
  /// One tile per day (the default, and the pre-1.5 behavior).
  day,

  /// One tile per week. Tapping a tile selects and emits the week's first
  /// day, which is determined by [DatePicker.firstDayOfWeek] or, when that
  /// is null, the ambient [MaterialLocalizations] (Sunday for `en_US`).
  week,

  /// One tile per calendar month. Tapping a tile selects and emits the
  /// first day of the month.
  month,
}
