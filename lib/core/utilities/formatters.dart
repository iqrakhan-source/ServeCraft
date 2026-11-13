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

  /// Format date as Indian display format "dd/MM/yyyy" (e.g. 15/05/1998)
  static String formatIndianDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date as API standard format "yyyy-MM-dd" (e.g. 1998-05-15)
  static String formatBackendDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Formats Date of Birth into Indian display format (dd/MM/yyyy)
  static String formatDob(String? rawDob, {String fallback = 'Not set'}) {
    if (rawDob == null || rawDob.trim().isEmpty) {
      return fallback;
    }
    final trimmed = rawDob.trim();
    try {
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        return DateFormat('dd/MM/yyyy').format(parsed);
      }
      final parsedSlash = DateFormat('dd/MM/yyyy').parseStrict(trimmed);
      return DateFormat('dd/MM/yyyy').format(parsedSlash);
    } catch (_) {
      try {
        final parsedDash = DateFormat('yyyy-MM-dd').parseStrict(trimmed);
        return DateFormat('dd/MM/yyyy').format(parsedDash);
      } catch (_) {
        return trimmed;
      }
    }
  }

  /// Safely parses a date string in dd/MM/yyyy, yyyy-MM-dd, or ISO8601 into a DateTime
  static DateTime? parseDob(String? rawDob) {
    if (rawDob == null || rawDob.trim().isEmpty) return null;
    final trimmed = rawDob.trim();
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(trimmed);
    } catch (_) {
      try {
        return DateFormat('yyyy-MM-dd').parseStrict(trimmed);
      } catch (_) {
        return DateTime.tryParse(trimmed);
      }
    }
  }

  /// Format 24-hour time "14:30" into 12-hour display "02:30 PM"
  static String formatTime12Hour(String time24) {
    final parts = time24.split(':');
    if (parts.isEmpty) return time24;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final hourStr = hour12.toString().padLeft(2, '0');
    return '$hourStr:$minute $period';
  }

  /// Parse duration strings like "90 mins" or "1 hr 30 mins" into integer minutes
  static int parseDurationMinutes(String? durationStr, {int fallback = 45}) {
    if (durationStr == null || durationStr.trim().isEmpty) return fallback;
    final match = RegExp(r'\d+').firstMatch(durationStr);
    return match != null
        ? int.tryParse(match.group(0) ?? '') ?? fallback
        : fallback;
  }

  /// Format duration minutes into a human-readable string like "45 mins" or "1 hr 30 mins"
  static String formatDuration(int minutes) {
    if (minutes <= 0) return '0 mins';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      if (remainingMinutes > 0) {
        return '$hours hr $remainingMinutes mins';
      }
      return '$hours hr';
    }
    return '$minutes mins';
  }
}
