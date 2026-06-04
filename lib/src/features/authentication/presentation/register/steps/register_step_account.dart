import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../register_form_cubit.dart';
import '../register_form_state.dart';
import '../register_strings.dart';
import '../widgets/register_choice_card.dart';
import '../widgets/register_info_box.dart';
import '../widgets/register_step_card.dart';
import '../widgets/register_text_field.dart';

/// Step 1 — class program selection and account credentials.
class RegisterStepAccount extends StatelessWidget {
  const RegisterStepAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
      builder: (context, state) {
        final cubit = context.read<RegisterFormCubit>();
        return RegisterStepCard(
          title: RegisterStrings.stepAccountTitle,
          subtitle: RegisterStrings.stepAccountSubtitle,
          children: [
            _ProgramSelection(state: state, cubit: cubit),
            const SizedBox(height: 18),
            const RegisterInfoBox(message: RegisterStrings.avpnInfo),
            const SizedBox(height: 18),
            RegisterTextField(
              initialValue: state.name.value,
              labelText: RegisterStrings.nameLabel,
              hintText: RegisterStrings.nameHint,
              prefixIcon: Icons.person_outline,
              errorText: state.nameError,
              onChanged: cubit.nameChanged,
            ),
            const SizedBox(height: 14),
            RegisterTextField(
              initialValue: state.email.value,
              labelText: RegisterStrings.emailLabel,
              hintText: RegisterStrings.emailHint,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              errorText: state.emailError,
              onChanged: cubit.emailChanged,
            ),
            const SizedBox(height: 14),
            RegisterTextField(
              initialValue: state.password.value,
              labelText: RegisterStrings.passwordLabel,
              hintText: RegisterStrings.passwordHint,
              prefixIcon: Icons.lock_outline,
              obscureText: state.obscurePassword,
              errorText: state.passwordError,
              onChanged: cubit.passwordChanged,
              suffixIcon: IconButton(
                onPressed: cubit.toggleObscurePassword,
                icon: Icon(
                  state.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            const SizedBox(height: 14),
            RegisterTextField(
              initialValue: state.confirmedPassword.value,
              labelText: RegisterStrings.confirmPasswordLabel,
              hintText: RegisterStrings.confirmPasswordHint,
              prefixIcon: Icons.verified_user_outlined,
              obscureText: state.obscureConfirmPassword,
              errorText: state.confirmedPasswordError,
              textInputAction: TextInputAction.done,
              onChanged: cubit.confirmedPasswordChanged,
              suffixIcon: IconButton(
                onPressed: cubit.toggleObscureConfirmPassword,
                icon: Icon(
                  state.obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProgramSelection extends StatelessWidget {
  final RegisterFormState state;
  final RegisterFormCubit cubit;

  const _ProgramSelection({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final selected = state.classInterest.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RegisterSectionLabel(RegisterStrings.programSectionLabel),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RegisterChoiceCard(
                selected: selected == RegisterStrings.classRegular,
                title: RegisterStrings.programRegularTitle,
                subtitle: RegisterStrings.programRegularSubtitle,
                icon: Icons.menu_book_outlined,
                onTap: () =>
                    cubit.classInterestSelected(RegisterStrings.classRegular),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RegisterChoiceCard(
                selected: selected == RegisterStrings.classAvpn,
                title: RegisterStrings.programAvpnTitle,
                subtitle: RegisterStrings.programAvpnSubtitle,
                icon: Icons.auto_awesome_outlined,
                onTap: () =>
                    cubit.classInterestSelected(RegisterStrings.classAvpn),
              ),
            ),
          ],
        ),
        RegisterFieldError(message: state.classInterestError),
      ],
    );
  }
}
