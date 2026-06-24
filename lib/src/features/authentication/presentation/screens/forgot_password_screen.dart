import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/utils/validators.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/auth_actions/auth_action_cubit.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/widgets/auth_header.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/widgets/auth_scaffold.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';

/// Lupa password (publik, tanpa login): kirim OTP ke email lalu reset password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _otpSent = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _sendOtp(BuildContext context) {
    final email = _emailController.text.trim();
    if (Validators.validateEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan email yang valid.')),
      );
      return;
    }
    context.read<AuthActionCubit>().sendPasswordOtp(email);
  }

  void _reset(BuildContext context) {
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kode dari email.')),
      );
      return;
    }
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 8 karakter.')),
      );
      return;
    }
    context.read<AuthActionCubit>().resetPassword(
      email: _emailController.text.trim(),
      code: code,
      password: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthActionCubit, AuthActionState>(
        listener: (context, state) {
          if (state.status == AuthActionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Terjadi kesalahan.'),
                backgroundColor: AppColors.brandPrimaryDark,
              ),
            );
          } else if (state.status == AuthActionStatus.success) {
            // Sukses reset password -> kembali ke login. Sukses kirim OTP ->
            // tampilkan field kode + password baru.
            final resetDone = _otpSent;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Berhasil.')),
            );
            if (resetDone) {
              context.go(AppRoutes.login);
            } else {
              setState(() => _otpSent = true);
            }
          }
        },
        builder: (context, state) {
          return AuthScaffold(
            children: [
              const SizedBox(height: 12),
              const FadeSlideIn(
                child: AuthHeader(
                  badge: 'LUPA PASSWORD',
                  title: 'Reset Password 🔑',
                  subtitle:
                      'Kami akan kirim kode ke email kamu untuk membuat password baru.',
                  glow: true,
                ),
              ),
              const SizedBox(height: 22),
              FadeSlideIn(
                delayMs: 120,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: AppShadows.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _emailController,
                        enabled: !_otpSent,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Icon(Icons.mail_outline_rounded),
                          fillColor: AppColors.surfaceMuted,
                        ),
                      ),
                      if (_otpSent) ...[
                        const SizedBox(height: 14),
                        TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Kode dari email',
                            prefixIcon: const Icon(Icons.pin_outlined),
                            fillColor: AppColors.surfaceMuted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: 'Password baru (min. 8 karakter)',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            fillColor: AppColors.surfaceMuted,
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () =>
                                  _otpSent ? _reset(context) : _sendOtp(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _otpSent ? 'Reset Password' : 'Kirim Kode',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                      if (_otpSent)
                        TextButton(
                          onPressed: state.isLoading
                              ? null
                              : () => context
                                    .read<AuthActionCubit>()
                                    .sendPasswordOtp(
                                      _emailController.text.trim(),
                                    ),
                          child: Text(
                            'Kirim ulang kode',
                            style: TextStyle(
                              color: AppColors.brandText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: Text(
                  'Kembali ke Masuk',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
