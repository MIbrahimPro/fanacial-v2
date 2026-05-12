import 'package:intl/intl.dart';

class DateHelpers {
  static String formatDate(DateTime dt) => DateFormat('d MMM yyyy').format(dt);

  static String formatMonth(DateTime dt) => DateFormat('MMMM yyyy').format(dt);

  static String formatShortDate(DateTime dt) => DateFormat('dd/MM/yy').format(dt);

  static DateTime previousMonth(DateTime dt) =>
      DateTime(dt.year, dt.month - 1, 1);

  static DateTime nextMonth(DateTime dt) =>
      DateTime(dt.year, dt.month + 1, 1);

  static DateTime startOfMonth(DateTime dt) =>
      DateTime(dt.year, dt.month, 1);

  static DateTime endOfMonth(DateTime dt) =>
      DateTime(dt.year, dt.month + 1, 0, 23, 59, 59, 999);

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  static String monthName(int month) => DateFormat('MMMM').format(DateTime(2000, month));

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static List<DateTime> getLastNMonths(int n) {
    final now = DateTime.now();
    return List.generate(n,
        (i) => DateTime(now.year, now.month - i, 1));
  }
}
