/// How [DatePicker] interprets taps and holds its selection.
enum SelectionMode {
  /// Exactly one date can be selected at a time (the default, and the
  /// pre-1.4 behavior).
  single,

  /// Any number of dates can be selected; tapping a selected date
  /// removes it from the selection.
  multiple,

  /// The first tap picks a start date, the second an end date. A later
  /// tap starts a new range. Tapping an earlier date as the second tap
  /// swaps the endpoints instead of restarting.
  range,
}

/// What a single date tile should paint for the current selection.
enum TileSelection {
  /// Not part of the selection.
  none,

  /// A selected date (single/multiple mode, a pending range start, or a
  /// one-day range).
  selected,

  /// The first day of a completed range.
  rangeStart,

  /// A day strictly between the endpoints of a completed range.
  rangeMiddle,

  /// The last day of a completed range.
  rangeEnd,
}
