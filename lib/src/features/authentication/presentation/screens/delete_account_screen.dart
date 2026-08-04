import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/auth_actions/auth_action_cubit.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Hapus permanen akun peserta. Wajib untuk App Store (Guideline 5.1.1(v)):
/// aplikasi yang mengizinkan pembuatan akun harus menyediakan penghapusan akun
/// di dalam aplikasi. Butuh konfirmasi password + dialog konfirmasi akhir agar
/// tidak terpicu tidak sengaja. Pada sukses, memicu logout → router ke intro.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  static const Color _danger = AppColors.red;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _snack(BuildContext context, String message, {bool danger = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: danger ? _danger : null,
      ),
    );
  }

  /// Tekan tombol hapus → validasi password terisi → dialog konfirmasi akhir →
  /// baru memanggil cubit. Dua lapis konfirmasi mencegah penghapusan tak sengaja.
  Future<void> _onDeletePressed(BuildContext context) async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      _snack(context, 'Masukkan password untuk mengonfirmasi.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus akun permanen?'),
        content: const Text(
          'Akun dan seluruh data belajarmu akan dihapus selamanya dan tidak '
          'bisa dipulihkan. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: _danger),
            child: const Text('Ya, hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    context.read<AuthActionCubit>().deleteAccount(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Hapus Akun'),
      body: BlocConsumer<AuthActionCubit, AuthActionState>(
        listener: (context, state) {
          if (state.status == AuthActionStatus.success) {
            _snack(context, state.message ?? 'Akun kamu telah dihapus.');
            // Akun sudah tiada → logout agar router mengembalikan ke intro.
            context.read<AuthBloc>().add(const AuthLogoutEvent());
          } else if (state.status == AuthActionStatus.failure) {
            _snack(
              context,
              state.message ?? 'Gagal menghapus akun.',
              danger: true,
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WarningCard(danger: _danger),
                const SizedBox(height: 20),
                Text(
                  'Konfirmasi dengan password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Password akunmu',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    fillColor: AppColors.surface,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => _onDeletePressed(context),
                    icon: state.isLoading
                        ? const SizedBox.shrink()
                        : const Icon(Icons.delete_forever_rounded, size: 20),
                    label: state.isLoading
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
                            'Hapus Akun Saya',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _danger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sebagai alternatif, kamu bisa keluar (logout) tanpa menghapus '
                  'akun dari halaman Profil.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textTertiary,
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

class _WarningCard extends StatelessWidget {
  final Color danger;

  const _WarningCard({required this.danger});

  @override
  Widget build(BuildContext context) {
    Widget bullet(String text) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.remove_rounded, size: 16, color: danger),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: danger, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tindakan ini permanen',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Menghapus akun akan menghilangkan selamanya:',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          bullet('Progres belajar, nilai kuis & tugas'),
          bullet('Sertifikat yang sudah diraih'),
          bullet('Diskusi, agenda pribadi, & skor game'),
          bullet('Data profil & akunmu — tidak bisa dipulihkan'),
        ],
      ),
    );
  }
}
