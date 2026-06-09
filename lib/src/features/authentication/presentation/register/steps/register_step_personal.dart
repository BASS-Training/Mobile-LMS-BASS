import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

import '../register_form_cubit.dart';
import '../register_form_state.dart';
import '../register_strings.dart';
import '../widgets/register_choice_card.dart';
import '../widgets/register_step_card.dart';
import '../widgets/register_text_field.dart';

/// Step 2 — gender, date of birth, and institution.
class RegisterStepPersonal extends StatelessWidget {
  const RegisterStepPersonal({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
      builder: (context, state) {
        final cubit = context.read<RegisterFormCubit>();
        return RegisterStepCard(
          title: RegisterStrings.stepPersonalTitle,
          subtitle: RegisterStrings.stepPersonalSubtitle,
          children: [
            _GenderSelection(state: state, cubit: cubit),
            const SizedBox(height: 18),
            _DateOfBirthField(state: state, cubit: cubit),
            const SizedBox(height: 14),
            RegisterTextField(
              initialValue: state.institution.value,
              labelText: RegisterStrings.institutionLabel,
              hintText: RegisterStrings.institutionHint,
              prefixIcon: Icons.apartment_outlined,
              errorText: state.institutionError,
              onChanged: cubit.institutionChanged,
            ),
          ],
        );
      },
    );
  }
}

class _GenderSelection extends StatelessWidget {
  final RegisterFormState state;
  final RegisterFormCubit cubit;

  const _GenderSelection({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final selected = state.gender.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RegisterSectionLabel(RegisterStrings.genderSectionLabel),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RegisterChoiceCard(
                selected: selected == RegisterStrings.genderMale,
                title: RegisterStrings.genderMaleTitle,
                subtitle: RegisterStrings.genderMaleSubtitle,
                icon: Icons.male_outlined,
                onTap: () => cubit.genderSelected(RegisterStrings.genderMale),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RegisterChoiceCard(
                selected: selected == RegisterStrings.genderFemale,
                title: RegisterStrings.genderFemaleTitle,
                subtitle: RegisterStrings.genderFemaleSubtitle,
                icon: Icons.female_outlined,
                onTap: () => cubit.genderSelected(RegisterStrings.genderFemale),
              ),
            ),
          ],
        ),
        RegisterFieldError(message: state.genderError),
      ],
    );
  }
}

class _DateOfBirthField extends StatelessWidget {
  final RegisterFormState state;
  final RegisterFormCubit cubit;

  const _DateOfBirthField({required this.state, required this.cubit});

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate =
        state.dateOfBirth.value ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: RegisterStrings.datePickerHelp,
      cancelText: RegisterStrings.datePickerCancel,
      confirmText: RegisterStrings.datePickerConfirm,
    );
    if (picked != null) cubit.dateOfBirthSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final text = state.dateOfBirthText;
    final isEmpty = text.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RegisterSectionLabel(RegisterStrings.dateOfBirthLabel),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_month_outlined),
              suffixIcon: const Icon(Icons.edit_calendar_outlined),
              errorText: state.dateOfBirthError,
            ),
            child: Text(
              isEmpty ? RegisterStrings.dateOfBirthHint : text,
              style: TextStyle(
                color: isEmpty ? AppColors.textTertiary : AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
