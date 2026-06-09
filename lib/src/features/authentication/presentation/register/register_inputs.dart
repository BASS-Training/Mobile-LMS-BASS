import 'package:formz/formz.dart';
import 'package:lms_mobile_app/src/core/utils/validators.dart';

/// Formz input value-objects for the registration form. Each one owns its own
/// validation rule so the UI never has to know *how* a field is validated — it
/// just renders [FormzInput.displayError].

enum NameValidationError { empty }

class NameInput extends FormzInput<String, NameValidationError> {
  const NameInput.pure() : super.pure('');
  const NameInput.dirty([super.value = '']) : super.dirty();

  @override
  NameValidationError? validator(String value) =>
      value.trim().isEmpty ? NameValidationError.empty : null;
}

enum EmailValidationError { empty, invalid }

class EmailInput extends FormzInput<String, EmailValidationError> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty([super.value = '']) : super.dirty();

  @override
  EmailValidationError? validator(String value) {
    if (value.trim().isEmpty) return EmailValidationError.empty;
    return Validators.isValidEmail(value.trim())
        ? null
        : EmailValidationError.invalid;
  }
}

enum PasswordValidationError { empty, tooShort }

class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    return Validators.isValidPassword(value)
        ? null
        : PasswordValidationError.tooShort;
  }
}

enum ConfirmedPasswordValidationError { empty, mismatch }

class ConfirmedPasswordInput
    extends FormzInput<String, ConfirmedPasswordValidationError> {
  const ConfirmedPasswordInput.pure({this.password = ''}) : super.pure('');
  const ConfirmedPasswordInput.dirty({this.password = '', String value = ''})
      : super.dirty(value);

  /// The password this confirmation is compared against.
  final String password;

  @override
  ConfirmedPasswordValidationError? validator(String value) {
    if (value.isEmpty) return ConfirmedPasswordValidationError.empty;
    return value == password
        ? null
        : ConfirmedPasswordValidationError.mismatch;
  }
}

enum InstitutionValidationError { empty }

class InstitutionInput extends FormzInput<String, InstitutionValidationError> {
  const InstitutionInput.pure() : super.pure('');
  const InstitutionInput.dirty([super.value = '']) : super.dirty();

  @override
  InstitutionValidationError? validator(String value) =>
      value.trim().isEmpty ? InstitutionValidationError.empty : null;
}

enum SelectionValidationError { empty }

/// A required single-choice selection (stores the chosen value, `''` = none).
class SelectionInput extends FormzInput<String, SelectionValidationError> {
  const SelectionInput.pure() : super.pure('');
  const SelectionInput.dirty([super.value = '']) : super.dirty();

  @override
  SelectionValidationError? validator(String value) =>
      value.isEmpty ? SelectionValidationError.empty : null;
}

enum DateValidationError { empty }

class DateOfBirthInput extends FormzInput<DateTime?, DateValidationError> {
  const DateOfBirthInput.pure() : super.pure(null);
  const DateOfBirthInput.dirty([super.value]) : super.dirty();

  @override
  DateValidationError? validator(DateTime? value) =>
      value == null ? DateValidationError.empty : null;
}
