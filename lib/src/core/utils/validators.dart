/// Validators untuk berbagai input forms
class AppValidators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validate name field
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Check if email is valid
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Check if password is strong enough
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }
}
