import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/utils/validators.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/auth_actions/auth_action_cubit.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Ubah email (pola "verifikasi dulu, baru ganti"): kode konfirmasi dikirim ke
/// EMAIL BARU; email akun baru berubah setelah kode benar — aman dari salah
/// ketik / email asing.
class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool _otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendOtp(BuildContext context) {
    final email = _emailController.text.trim();
    if (Validators.validateEmail(email) != null) {
      _snack(context, 'Masukkan email baru yang valid.');
      return;
    }
    context.read<AuthActionCubit>().sendChangeEmailOtp(email);
  }

  void _change(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.length < 4) {
      _snack(context, 'Masukkan kode yang dikirim ke email baru.');
      return;
    }
    context.read<AuthActionCubit>().changeEmail(
      newEmail: _emailController.text.trim(),
      code: code,
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Ubah Email'),
      body: BlocConsumer<AuthActionCubit, AuthActionState>(
        listener: (context, state) {
          if (state.status == AuthActionStatus.success) {
            // user != null hanya saat email benar-benar berhasil diubah.
            if (state.user != null) {
              context.read<AuthBloc>().add(AuthUserUpdatedEvent(state.user!));
              _snack(context, state.message ?? 'Email berhasil diubah 🎉');
              context.pop();
            } else {
              setState(() => _otpSent = true);
              _snack(context, state.message ?? 'Kode dikirim ke email baru.');
            }
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _otpSent
                      ? 'Masukkan kode 6 digit yang kami kirim ke email baru kamu untuk mengonfirmasi.'
                      : 'Demi keamanan, kami akan mengirim kode ke email baru. Email akun kamu baru berubah setelah kode itu benar.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _emailController,
                  enabled: !_otpSent,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email baru',
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                    fillColor: AppColors.surface,
                    filled: true,
                  ),
                ),
                if (_otpSent) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Kode dari email baru',
                      prefixIcon: const Icon(Icons.pin_outlined),
                      fillColor: AppColors.surface,
                      filled: true,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () => _otpSent ? _change(context) : _sendOtp(context),
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
                          _otpSent ? 'Ubah Email Sekarang' : 'Kirim Kode',
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
                              .sendChangeEmailOtp(_emailController.text.trim()),
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
          );
        },
      ),
    );
  }
}
