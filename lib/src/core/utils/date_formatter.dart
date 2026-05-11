import 'package:intl/intl.dart';

/// Date & time formatting utilities
class DateFormatter {
  /// Format date to readable string
  static String formatDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    try {
      return DateFormat(format).format(date);
    } catch (e) {
      return date.toString();
    }
  }

  /// Format date time to readable string
  static String formatDateTime(
    DateTime dateTime, {
    String format = 'dd MMM yyyy, HH:mm',
  }) {
    try {
      return DateFormat(format).format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }

  /// Format time only
  static String formatTime(DateTime dateTime, {String format = 'HH:mm'}) {
    try {
      return DateFormat(format).format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }

  /// Get relative time (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Parse string to DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
