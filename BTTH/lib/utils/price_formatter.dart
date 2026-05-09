import 'package:intl/intl.dart';

class PriceFormatter {
  static String format(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }
}
