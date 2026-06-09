import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/register/register_form_cubit.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/register/register_strings.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/register/steps/register_step_account.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/register/steps/register_step_occupation.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/register/steps/register_step_personal.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/register/widgets/register_step_progress.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/widgets/auth_header.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/widgets/auth_scaffold.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';

/// Multi-step registration screen. This widget only *orchestrates*: it provides
/// the [RegisterFormCubit] (form state + validation), wires the [AuthBloc]
/// (the registration use case), and arranges the header, progress, current
/// step, and navigation. All field/validation logic lives in the cubit and the
/// step widgets.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterFormCubit(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  void _onAuthState(BuildContext context, AuthState state) {
    final messenger = ScaffoldMessenger.of(context);
    if (state is AuthRegisterSuccess) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(RegisterStrings.registerSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(AppRoutes.main);
    } else if (state is AuthFailure) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.brandPrimary,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: _onAuthState,
        child: AuthScaffold(
          maxWidth: 480,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            SizedBox(height: 4),
            FadeSlideIn(
              child: AuthHeader(
                badge: RegisterStrings.badge,
                title: RegisterStrings.title,
                subtitle: RegisterStrings.subtitle,
              ),
            ),
            SizedBox(height: 22),
            FadeSlideIn(delayMs: 80, child: _Progress()),
            SizedBox(height: 20),
            FadeSlideIn(delayMs: 140, child: _FormCard()),
            SizedBox(height: 14),
            _SignInLink(),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress();

  @override
  Widget build(BuildContext context) {
    final step = context.select((RegisterFormCubit c) => c.state.step);
    return RegisterStepProgress(
      currentStep: step,
      labels: const [
        RegisterStrings.stepAccountLabel,
        RegisterStrings.stepPersonalLabel,
        RegisterStrings.stepOccupationLabel,
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard();

  Widget _stepFor(int step) {
    return switch (step) {
      1 => const RegisterStepAccount(),
      2 => const RegisterStepPersonal(),
      _ => const RegisterStepOccupation(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final step = context.select((RegisterFormCubit c) => c.state.step);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey<int>(step),
              child: _stepFor(step),
            ),
          ),
          const SizedBox(height: 24),
          const _Navigation(),
        ],
      ),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation();

  void _submit(BuildContext context) {
    final cubit = context.read<RegisterFormCubit>();
    if (!cubit.validateAll()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(RegisterStrings.incompleteForm),
          backgroundColor: AppColors.brandPrimary,
        ),
      );
      return;
    }

    final form = cubit.state;
    context.read<AuthBloc>().add(
          AuthRegisterEvent(
            name: form.name.value.trim(),
            email: form.email.value.trim(),
            password: form.password.value,
            classInterest: form.classInterest.value,
            dateOfBirth: form.dateOfBirthText,
            gender: form.gender.value,
            institutionName: form.institution.value.trim(),
            occupation: form.occupation.value,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final step = context.select((RegisterFormCubit c) => c.state.step);
    final isLoading = context.select((AuthBloc b) => b.state is AuthLoading);
    final cubit = context.read<RegisterFormCubit>();
    final isLastStep = step >= 3;

    return Row(
      children: [
        if (step > 1)
          OutlinedButton.icon(
            onPressed: isLoading ? null : cubit.previousStep,
            icon: const Icon(Icons.arrow_back_outlined),
            label: const Text(RegisterStrings.back),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.borderDefault),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
        const Spacer(),
        if (!isLastStep)
          ElevatedButton.icon(
            onPressed: isLoading ? null : cubit.nextStep,
            icon: const Icon(Icons.arrow_forward_outlined),
            label: const Text(RegisterStrings.next),
            style: _primaryButtonStyle,
          )
        else
          ElevatedButton.icon(
            onPressed: isLoading ? null : () => _submit(context),
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(
              isLoading ? RegisterStrings.submitting : RegisterStrings.submit,
            ),
            style: _primaryButtonStyle,
          ),
      ],
    );
  }

  static final ButtonStyle _primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.brandPrimary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

class _SignInLink extends StatelessWidget {
  const _SignInLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          RegisterStrings.alreadyHaveAccount,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13.5,
          ),
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.login),
          child: const Text(
            RegisterStrings.signIn,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
