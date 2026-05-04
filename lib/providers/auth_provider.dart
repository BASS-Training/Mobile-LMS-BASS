// import 'package:flutter/material.dart';
// import 'package:mini_lms_bass_training/data/models/user.dart';

// class AuthProvider extends ChangeNotifier {
//   User? _user;
//   bool _isLoggedIn = false;
//   String? _errorMessage;

//   User? get user => _user;
//   bool get isLoggedIn => _isLoggedIn;
//   String? get errorMessage => _errorMessage;

//   // Simple login validation
//   bool login(String email, String password) {
//     // Basic validation
//     if (email.isEmpty || password.isEmpty) {
//       _errorMessage = 'Email and password cannot be empty';
//       notifyListeners();
//       return false;
//     }

//     if (!isValidEmail(email)) {
//       _errorMessage = 'Please enter a valid email';
//       notifyListeners();
//       return false;
//     }

//     if (password.length < 6) {
//       _errorMessage = 'Password must be at least 6 characters';
//       notifyListeners();
//       return false;
//     }

//     // Simulate successful login
//     _user = User(
//       id: '${DateTime.now().millisecondsSinceEpoch}',
//       name: email.split('@')[0].replaceAll('.', ' ').toUpperCase(),
//       email: email,
//     );
//     _isLoggedIn = true;
//     _errorMessage = null;
//     notifyListeners();
//     return true;
//   }

//   void logout() {
//     _user = null;
//     _isLoggedIn = false;
//     _errorMessage = null;
//     notifyListeners();
//   }

//   bool isValidEmail(String email) {
//     final pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
//     final regex = RegExp(pattern);
//     return regex.hasMatch(email);
//   }

//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
// }
