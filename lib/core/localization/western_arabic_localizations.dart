import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;
import '../utils/formatters.dart';

/// Custom MaterialLocalizations for Arabic that guarantees standard Western numerals (0, 1, 2, ..., 9)
/// across the calendar, date pickers, year pickers, and number displays instead of Eastern Arabic/Indic glyphs (٠-٩).
class WesternArabicMaterialLocalizations extends MaterialLocalizationAr {
  WesternArabicMaterialLocalizations({
    super.localeName = 'ar',
  }) : super(
          fullYearFormat: intl.DateFormat('y', 'en'),
          compactDateFormat: intl.DateFormat('yMd', 'ar'),
          shortDateFormat: intl.DateFormat('yMMMd', 'ar'),
          mediumDateFormat: intl.DateFormat('EEE, yMMMd', 'ar'),
          longDateFormat: intl.DateFormat('EEEE, yMMMMd', 'ar'),
          yearMonthFormat: intl.DateFormat('MMMM y', 'ar'),
          shortMonthDayFormat: intl.DateFormat('MMMd', 'ar'),
          decimalFormat: intl.NumberFormat.decimalPattern('en'),
          twoDigitZeroPaddedFormat: intl.NumberFormat('00', 'en'),
        );

  @override
  String formatDecimal(int number) => number.toString();

  @override
  String formatYear(DateTime date) => date.year.toString();

  @override
  String formatMediumDate(DateTime date) =>
      AppFormatters.toWesternNumerals(super.formatMediumDate(date));

  @override
  String formatShortDate(DateTime date) =>
      AppFormatters.toWesternNumerals(super.formatShortDate(date));

  @override
  String formatFullDate(DateTime date) =>
      AppFormatters.toWesternNumerals(super.formatFullDate(date));

  @override
  String formatCompactDate(DateTime date) =>
      AppFormatters.toWesternNumerals(super.formatCompactDate(date));

  @override
  String formatShortMonthDay(DateTime date) =>
      AppFormatters.toWesternNumerals(super.formatShortMonthDay(date));

  @override
  String formatMonthYear(DateTime date) =>
      AppFormatters.toWesternNumerals(super.formatMonthYear(date));
}

class WesternArabicMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const WesternArabicMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ar';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return WesternArabicMaterialLocalizations();
  }

  @override
  bool shouldReload(WesternArabicMaterialLocalizationsDelegate old) => false;
}
