extension StringExtensions on String {
  String toPersianDigit() {
    return NumberUtility.changeDigit(this);
  }
}

class NumberUtility {
  static String changeDigit(String number) {
    var persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var enNumbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."];{
      for (var i = 0; i < 10; i++) {
        number = number
            .replaceAll(RegExp(enNumbers[i]), persianNumbers[i])
            .replaceAll(RegExp(enNumbers[i]), arabicNumbers[i]);
      }
    }
    return number;
  }
}