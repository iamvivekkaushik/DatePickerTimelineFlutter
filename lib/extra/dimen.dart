/// ***
/// This class consists of fontSize and margin used in this package
///
/// Author: Vivek Kaushik `<me@vivekkasuhik.com>`
/// github: https://github.com/iamvivekkaushik/
/// ***
library;

class Dimen {
  Dimen._();

  /// Default font size of the day-of-month number.
  static const double dateTextSize = 24;

  /// Default font size of the weekday label.
  static const double dayTextSize = 11;

  /// Default font size of the month label.
  static const double monthTextSize = 11;

  /// Margin around each date tile. One tile's horizontal extent is
  /// `width + 2 * tileMargin`; the scroll-offset math in
  /// `DatePickerController` relies on this value.
  static const double tileMargin = 3.0;

  /// Vertical gap reserved below the tiles for the scrollbar thumb when
  /// `DatePicker.showScrollbar` is enabled. The picker's total height is
  /// then `height + scrollbarGutter`.
  static const double scrollbarGutter = 12.0;
}
