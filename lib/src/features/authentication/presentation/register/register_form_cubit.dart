import 'package:flutter_bloc/flutter_bloc.dart';

import 'register_form_state.dart';
import 'register_inputs.dart';

/// Owns all registration form state and validation, keeping the widgets dumb.
///
/// This is intentionally separate from `AuthBloc`: the cubit only manages the
/// *draft* form (input values, per-step validity, wizard position), while
/// `AuthBloc` performs the actual registration use case once the form is valid.
class RegisterFormCubit extends Cubit<RegisterFormState> {
  RegisterFormCubit() : super(const RegisterFormState());

  static const int _firstStep = 1;
  static const int _lastStep = 3;

  // --- Field changes ---------------------------------------------------------

  void nameChanged(String value) =>
      emit(state.copyWith(name: NameInput.dirty(value)));

  void emailChanged(String value) =>
      emit(state.copyWith(email: EmailInput.dirty(value)));

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: PasswordInput.dirty(value),
        // Re-validate the confirmation against the new password.
        confirmedPassword: ConfirmedPasswordInput.dirty(
          password: value,
          value: state.confirmedPassword.value,
        ),
      ),
    );
  }

  void confirmedPasswordChanged(String value) {
    emit(
      state.copyWith(
        confirmedPassword: ConfirmedPasswordInput.dirty(
          password: state.password.value,
          value: value,
        ),
      ),
    );
  }

  void institutionChanged(String value) =>
      emit(state.copyWith(institution: InstitutionInput.dirty(value)));

  void classInterestSelected(String value) =>
      emit(state.copyWith(classInterest: SelectionInput.dirty(value)));

  void genderSelected(String value) =>
      emit(state.copyWith(gender: SelectionInput.dirty(value)));

  void dateOfBirthSelected(DateTime value) =>
      emit(state.copyWith(dateOfBirth: DateOfBirthInput.dirty(value)));

  void occupationSelected(String value) =>
      emit(state.copyWith(occupation: SelectionInput.dirty(value)));

  void toggleObscurePassword() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleObscureConfirmPassword() => emit(
        state.copyWith(
          obscureConfirmPassword: !state.obscureConfirmPassword,
        ),
      );

  // --- Wizard navigation -----------------------------------------------------

  /// Validates the current step (forcing any pending errors to show) and, when
  /// valid, advances to the next one. Returns whether navigation happened.
  bool nextStep() {
    _touchCurrentStep();
    if (!_isCurrentStepValid()) return false;
    if (state.step >= _lastStep) return false;
    emit(state.copyWith(step: state.step + 1));
    return true;
  }

  void previousStep() {
    if (state.step <= _firstStep) return;
    emit(state.copyWith(step: state.step - 1));
  }

  /// Touches every field so all validation errors become visible. Returns
  /// whether the whole form is valid and ready to submit.
  bool validateAll() {
    _touchAllSteps();
    return state.isFormValid;
  }

  // --- Internals -------------------------------------------------------------

  bool _isCurrentStepValid() {
    return switch (state.step) {
      1 => state.isStepAccountValid,
      2 => state.isStepPersonalValid,
      _ => state.isStepOccupationValid,
    };
  }

  void _touchCurrentStep() {
    switch (state.step) {
      case 1:
        _touchAccount();
      case 2:
        _touchPersonal();
      default:
        _touchOccupation();
    }
  }

  void _touchAllSteps() {
    _touchAccount();
    _touchPersonal();
    _touchOccupation();
  }

  void _touchAccount() {
    emit(
      state.copyWith(
        name: NameInput.dirty(state.name.value),
        email: EmailInput.dirty(state.email.value),
        password: PasswordInput.dirty(state.password.value),
        confirmedPassword: ConfirmedPasswordInput.dirty(
          password: state.password.value,
          value: state.confirmedPassword.value,
        ),
        classInterest: SelectionInput.dirty(state.classInterest.value),
      ),
    );
  }

  void _touchPersonal() {
    emit(
      state.copyWith(
        gender: SelectionInput.dirty(state.gender.value),
        dateOfBirth: DateOfBirthInput.dirty(state.dateOfBirth.value),
        institution: InstitutionInput.dirty(state.institution.value),
      ),
    );
  }

  void _touchOccupation() {
    emit(
      state.copyWith(
        occupation: SelectionInput.dirty(state.occupation.value),
      ),
    );
  }
}
