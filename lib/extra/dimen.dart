/// ***
/// This class consists of fontSize and margin used in this package
///
/// Author: Vivek Kaushik `<me@vivekkasuhik.com>`
/// github: https://github.com/iamvivekkaushik/
/// ***
library;

class Dimen {
  Dimen._();

  static const double dateTextSize = 24;
  static const double dayTextSize = 11;
  static const double monthTextSize = 11;

  /// Margin around each date tile. One tile's horizontal extent is
  /// `width + 2 * tileMargin`; the scroll-offset math in
  /// `DatePickerController` relies on this value.
  static const double tileMargin = 3.0;
}
