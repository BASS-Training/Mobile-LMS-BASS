import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/auth_actions/auth_action_cubit.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/widgets/auth_header.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/widgets/auth_scaffold.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';

/// Layar verifikasi email berbasis OTP. Dipakai:
///  - akun BARU (diarahkan otomatis dari login bila must_verify_email), dan
///  - akun LAMA secara sukarela dari Profil.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String get _email {
    final state = context.read<AuthBloc>().state;
    return state is AuthSuccess ? state.user.email : '';
  }

  /// true = akun baru yang DIPAKSA verifikasi (tak ada halaman sebelumnya, jadi
  /// keluar = logout). false = verifikasi sukarela dari Profil (cukup kembali).
  bool get _mustVerify {
    final state = context.read<AuthBloc>().state;
    return state is AuthSuccess ? state.user.mustVerifyEmail : false;
  }

  void _verify(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kode yang dikirim ke email.')),
      );
      return;
    }
    context.read<AuthActionCubit>().verifyEmailOtp(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthActionCubit, AuthActionState>(
        listener: (context, state) {
          if (state.status == AuthActionStatus.success && state.user != null) {
            // Verifikasi sukses -> perbarui user global lalu masuk app.
            context.read<AuthBloc>().add(AuthUserUpdatedEvent(state.user!));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email berhasil diverifikasi 🎉')),
            );
            context.go(AppRoutes.main);
          } else if (state.status == AuthActionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Kode dikirim.')),
            );
          } else if (state.status == AuthActionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Terjadi kesalahan.'),
                backgroundColor: AppColors.brandPrimaryDark,
              ),
            );
          }
        },
        builder: (context, state) {
          return AuthScaffold(
            children: [
              const SizedBox(height: 12),
              const FadeSlideIn(
                child: AuthHeader(
                  badge: 'KEAMANAN AKUN',
                  title: 'Verifikasi Email ✉️',
                  subtitle:
                      'Masukkan kode 6 digit yang kami kirim ke email kamu untuk mengaktifkan akun.',
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
                      Text(
                        'Kode dikirim ke',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _email,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '______',
                          fillColor: AppColors.surfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: state.isLoading ? null : () => _verify(context),
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
                            : const Text(
                                'Verifikasi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: state.isLoading
                            ? null
                            : () =>
                                  context.read<AuthActionCubit>().sendEmailOtp(),
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
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => context.push(AppRoutes.changeEmail),
                child: Text(
                  'Salah memasukkan email? Ubah email',
                  style: TextStyle(
                    color: AppColors.brandText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (_mustVerify)
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutEvent());
                    context.go(AppRoutes.login);
                  },
                  child: Text(
                    'Keluar',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                TextButton(
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.main),
                  child: Text(
                    'Kembali',
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
