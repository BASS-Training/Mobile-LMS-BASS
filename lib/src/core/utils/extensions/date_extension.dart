/// DateTime extensions untuk formatting dan utility
extension DateTimeExtension on DateTime {
  /// Format datetime menjadi dd/MM/yyyy
  String toFormattedDate() {
    return '$day/${month.toString().padLeft(2, '0')}/$year';
  }

  /// Format datetime menjadi HH:mm
  String toFormattedTime() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Format datetime menjadi dd/MM/yyyy HH:mm
  String toFormattedDateTime() {
    return '${toFormattedDate()} ${toFormattedTime()}';
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Get difference in days from now
  int get daysFromNow {
    return difference(DateTime.now()).inDays;
  }
}
