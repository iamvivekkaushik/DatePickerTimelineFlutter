/// Digit-conversion helpers for rendering Persian tiles.
extension StringExtensions on String {
  /// Returns this string with every Latin digit replaced by its Persian
  /// equivalent.
  String toPersianDigit() {
    return NumberUtility.changeDigit(this);
  }
}

/// Converts Latin digits to Persian (Extended Arabic-Indic) digits.
class NumberUtility {
  static const int _latinZero = 0x30; // '0'
  static const int _latinNine = 0x39; // '9'
  static const int _persianZero = 0x6F0; // '۰' (U+06F0..U+06F9 is contiguous)

  /// Replaces every Latin digit in [number] with its Persian equivalent.
  static String changeDigit(String number) {
    final units = number.codeUnits;
    final out = StringBuffer();
    for (final c in units) {
      out.writeCharCode(c >= _latinZero && c <= _latinNine
          ? _persianZero + (c - _latinZero)
          : c);
    }
    return out.toString();
  }
}
