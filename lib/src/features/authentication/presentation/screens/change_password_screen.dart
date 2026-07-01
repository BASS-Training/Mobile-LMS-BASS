import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/auth_actions/auth_action_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Ganti password saat sudah login (butuh password lama).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty) {
      _snack(context, 'Masukkan password lama.');
      return;
    }
    if (newPass.length < 8) {
      _snack(context, 'Password baru minimal 8 karakter.');
      return;
    }
    if (newPass != confirm) {
      _snack(context, 'Konfirmasi password tidak cocok.');
      return;
    }
    context.read<AuthActionCubit>().changePassword(
      currentPassword: current,
      newPassword: newPass,
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
      appBar: const BrandAppBar(title: 'Ganti Password'),
      body: BlocConsumer<AuthActionCubit, AuthActionState>(
        listener: (context, state) {
          if (state.status == AuthActionStatus.success) {
            _snack(context, state.message ?? 'Password berhasil diubah.');
            context.pop();
          } else if (state.status == AuthActionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Gagal mengubah password.'),
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
                _field(
                  controller: _currentController,
                  hint: 'Password lama',
                  obscure: _obscure,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _newController,
                  hint: 'Password baru (min. 8 karakter)',
                  obscure: _obscure,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _confirmController,
                  hint: 'Ulangi password baru',
                  obscure: _obscure,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    child: Text(
                      _obscure ? 'Tampilkan password' : 'Sembunyikan password',
                      style: TextStyle(color: AppColors.brandText),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: state.isLoading ? null : () => _submit(context),
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
                          'Simpan Password Baru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        fillColor: AppColors.surface,
        filled: true,
      ),
    );
  }
}
