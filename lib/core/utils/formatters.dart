import 'package:intl/intl.dart';

class AppFormatters {
  /// Converts Eastern Arabic/Persian digits (٠-٩, ۰-۹) to standard Western Arabic numerals (0-9).
  static String toWesternNumerals(String input) {
    const eastern = [
      '٠',
      '١',
      '٢',
      '٣',
      '٤',
      '٥',
      '٦',
      '٧',
      '٨',
      '٩',
      '۰',
      '۱',
      '۲',
      '۳',
      '۴',
      '۵',
      '۶',
      '۷',
      '۸',
      '۹',
    ];
    const western = [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
    ];
    for (int i = 0; i < eastern.length; i++) {
      input = input.replaceAll(eastern[i], western[i]);
    }
    return input;
  }

  static String formatCurrency(
    double amount,
    String currency, {
    int? decimals,
  }) {
    // TND (Tunisian Dinar) uses 3 decimal places (millimes) by default
    final dec = decimals ?? (currency.toUpperCase() == 'TND' ? 3 : 2);
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: dec);
    return toWesternNumerals('${formatter.format(amount)} $currency');
  }

  static String formatDate(DateTime date, {String locale = 'en'}) {
    try {
      final res = DateFormat.yMMMd(locale).format(date);
      return toWesternNumerals(res);
    } catch (_) {
      final res = DateFormat.yMMMd('en').format(date);
      return toWesternNumerals(res);
    }
  }

  static String formatFullDate(DateTime date, {String locale = 'en'}) {
    try {
      final res = DateFormat.yMMMMd(locale).format(date);
      return toWesternNumerals(res);
    } catch (_) {
      final res = DateFormat.yMMMMd('en').format(date);
      return toWesternNumerals(res);
    }
  }

  static String formatShortDate(DateTime date) {
    return toWesternNumerals(DateFormat('dd/MM/yyyy').format(date));
  }

  static String formatPercent(double percent, {int decimals = 1}) {
    return toWesternNumerals('${percent.toStringAsFixed(decimals)}%');
  }

  static String formatWeight(double kg, {String unit = 'kg'}) {
    if (kg >= 1.0) {
      return toWesternNumerals('${kg.toStringAsFixed(1)} $unit');
    } else {
      return toWesternNumerals('${(kg * 1000).toStringAsFixed(0)} g');
    }
  }
}
