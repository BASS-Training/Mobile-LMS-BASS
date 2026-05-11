/// String extensions untuk utility functions
extension StringExtension on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    final pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    return regex.hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    try {
      Uri.parse(this);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Remove all whitespace
  String removeWhitespace() => replaceAll(' ', '');

  /// Truncate string with ellipsis
  String truncate(int length) {
    if (this.length <= length) return this;
    return '${substring(0, length)}...';
  }

  /// Check if string is empty or null
  bool get isNullOrEmpty => trim().isEmpty;

  /// Check if string is not empty
  bool get isNotEmpty_ => trim().isNotEmpty;
}
