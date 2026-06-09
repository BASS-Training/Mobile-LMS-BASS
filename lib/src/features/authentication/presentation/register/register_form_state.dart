import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import 'register_inputs.dart';
import 'register_strings.dart';

/// Immutable snapshot of the registration form. Holds every input as a Formz
/// value-object plus the wizard's transient UI state (current step, obscure
/// toggles). Validation lives entirely here / in the cubit — never in widgets.
class RegisterFormState extends Equatable {
  final int step;

  final NameInput name;
  final EmailInput email;
  final PasswordInput password;
  final ConfirmedPasswordInput confirmedPassword;
  final SelectionInput classInterest;

  final SelectionInput gender;
  final DateOfBirthInput dateOfBirth;
  final InstitutionInput institution;

  final SelectionInput occupation;

  final bool obscurePassword;
  final bool obscureConfirmPassword;

  const RegisterFormState({
    this.step = 1,
    this.name = const NameInput.pure(),
    this.email = const EmailInput.pure(),
    this.password = const PasswordInput.pure(),
    this.confirmedPassword = const ConfirmedPasswordInput.pure(),
    this.classInterest = const SelectionInput.pure(),
    this.gender = const SelectionInput.pure(),
    this.dateOfBirth = const DateOfBirthInput.pure(),
    this.institution = const InstitutionInput.pure(),
    this.occupation = const SelectionInput.pure(),
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
  });

  // --- Per-step validity -----------------------------------------------------

  bool get isStepAccountValid =>
      Formz.validate([name, email, password, confirmedPassword]) &&
      classInterest.isValid;

  bool get isStepPersonalValid =>
      gender.isValid && dateOfBirth.isValid && institution.isValid;

  bool get isStepOccupationValid => occupation.isValid;

  bool get isFormValid =>
      isStepAccountValid && isStepPersonalValid && isStepOccupationValid;

  // --- Error text (only surfaced once an input is dirty) ---------------------

  String? get nameError =>
      name.displayError == null ? null : RegisterStrings.nameRequired;

  String? get emailError => switch (email.displayError) {
        EmailValidationError.empty => RegisterStrings.emailRequired,
        EmailValidationError.invalid => RegisterStrings.emailInvalid,
        null => null,
      };

  String? get passwordError => switch (password.displayError) {
        PasswordValidationError.empty => RegisterStrings.passwordRequired,
        PasswordValidationError.tooShort => RegisterStrings.passwordTooShort,
        null => null,
      };

  String? get confirmedPasswordError =>
      switch (confirmedPassword.displayError) {
        ConfirmedPasswordValidationError.empty =>
          RegisterStrings.confirmPasswordRequired,
        ConfirmedPasswordValidationError.mismatch =>
          RegisterStrings.confirmPasswordMismatch,
        null => null,
      };

  String? get classInterestError => classInterest.displayError == null
      ? null
      : RegisterStrings.classInterestRequired;

  String? get genderError =>
      gender.displayError == null ? null : RegisterStrings.genderRequired;

  String? get dateOfBirthError => dateOfBirth.displayError == null
      ? null
      : RegisterStrings.dateOfBirthRequired;

  String? get institutionError => institution.displayError == null
      ? null
      : RegisterStrings.institutionRequired;

  String? get occupationError => occupation.displayError == null
      ? null
      : RegisterStrings.occupationRequired;

  /// `yyyy-MM-dd` representation expected by the API (empty when unset).
  String get dateOfBirthText {
    final value = dateOfBirth.value;
    if (value == null) return '';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  RegisterFormState copyWith({
    int? step,
    NameInput? name,
    EmailInput? email,
    PasswordInput? password,
    ConfirmedPasswordInput? confirmedPassword,
    SelectionInput? classInterest,
    SelectionInput? gender,
    DateOfBirthInput? dateOfBirth,
    InstitutionInput? institution,
    SelectionInput? occupation,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
  }) {
    return RegisterFormState(
      step: step ?? this.step,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      classInterest: classInterest ?? this.classInterest,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      institution: institution ?? this.institution,
      occupation: occupation ?? this.occupation,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
    );
  }

  @override
  List<Object?> get props => [
        step,
        name,
        email,
        password,
        confirmedPassword,
        classInterest,
        gender,
        dateOfBirth,
        institution,
        occupation,
        obscurePassword,
        obscureConfirmPassword,
      ];
}
