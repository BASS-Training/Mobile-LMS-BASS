import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../register_form_cubit.dart';
import '../register_form_state.dart';
import '../register_strings.dart';
import '../widgets/register_choice_card.dart';
import '../widgets/register_step_card.dart';

/// Step 3 — occupation category.
class RegisterStepOccupation extends StatelessWidget {
  const RegisterStepOccupation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
      builder: (context, state) {
        final cubit = context.read<RegisterFormCubit>();
        return RegisterStepCard(
          title: RegisterStrings.stepOccupationTitle,
          subtitle: RegisterStrings.stepOccupationSubtitle,
          children: [
            const RegisterSectionLabel(RegisterStrings.occupationSectionLabel),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: RegisterStrings.occupationOptions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                childAspectRatio: 4.8,
              ),
              itemBuilder: (context, index) {
                final occupation = RegisterStrings.occupationOptions[index];
                return RegisterChoiceCard(
                  selected: state.occupation.value == occupation,
                  title: occupation,
                  subtitle: '',
                  icon: Icons.work_outline,
                  compact: true,
                  onTap: () => cubit.occupationSelected(occupation),
                );
              },
            ),
            RegisterFieldError(message: state.occupationError),
          ],
        );
      },
    );
  }
}
