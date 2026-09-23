import 'package:intl/intl.dart';

abstract class AppFormatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _currencyDecimalFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format as Indian Rupee (e.g., ₹499 or ₹1,250)
  static String formatCurrency(num amount, {bool showDecimals = false}) {
    return showDecimals
        ? _currencyDecimalFormatter.format(amount)
        : _currencyFormatter.format(amount);
  }

  /// Format date as "24 Sep 2026"
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format date with day of week as "Thu, 24 Sep"
  static String formatShortDateWithDay(DateTime date) {
    return DateFormat('EEE, dd MMM').format(date);
  }

  /// Format date as "Thursday, 24 September 2026"
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy').format(date);
  }

  /// Format time as "10:30 AM"
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  /// Format 10-digit phone number as "+91 98765 43210"
  static String formatPhone(String phone, {String countryCode = '+91'}) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length == 10) {
      return '$countryCode ${cleanPhone.substring(0, 5)} ${cleanPhone.substring(5)}';
    }
    return phone;
  }
}
