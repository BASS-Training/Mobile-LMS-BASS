/// Centralised input-validation rules and messages (Indonesian).
///
/// Single source of truth for field rules so both the `TextFormField`
/// validators (`validateX`, returning a localized message) and the Formz inputs
/// (`isValidX`, returning a plain bool) stay consistent and never duplicate
/// thresholds like the minimum password length.
class Validators {
  const Validators._();

  static const int minPasswordLength = 6;
  static const int minNameLength = 2;

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // --- Boolean rules (used by Formz inputs / plain checks) -------------------

  static bool isValidEmail(String email) => _emailRegExp.hasMatch(email.trim());

  static bool isValidPassword(String password) =>
      password.length >= minPasswordLength;

  // --- Form-field validators (return a localized error message, or null) -----

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email wajib diisi';
    if (!isValidEmail(email)) return 'Format email tidak valid';
    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password wajib diisi';
    if (!isValidPassword(password)) {
      return 'Password minimal $minPasswordLength karakter';
    }
    return null;
  }

  static String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Nama wajib diisi';
    if (name.length < minNameLength) {
      return 'Nama minimal $minNameLength karakter';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }
}
