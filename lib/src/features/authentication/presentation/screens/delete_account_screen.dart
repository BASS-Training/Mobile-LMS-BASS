import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/authentication/data/support_api.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _password = TextEditingController();
  bool _confirmed = false;
  bool _busy = false;
  String? _passwordError;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_busy || !_confirmed) return;
    if (_password.text.isEmpty) {
      setState(() => _passwordError = 'Masukkan kata sandi saat ini.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _passwordError = null;
    });
    try {
      await SupportApi(
        ServiceLocator().locator<Dio>(),
      ).deleteAccount(_password.text);
      if (!mounted) return;
      final bloc = context.read<AuthBloc>();
      final loggedOut = bloc.stream.firstWhere(
        (state) => state is AuthLoggedOut,
      );
      bloc.add(const AuthAccountDeletedEvent());
      await loggedOut;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun Anda berhasil dihapus.')),
      );
      context.go(AppRoutes.login);
    } on DeleteAccountException catch (error) {
      if (mounted) {
        setState(() {
          if (error.passwordError) {
            _passwordError = error.message;
          } else {
            _error = error.message;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Data lokal belum dapat dibersihkan. Tutup aplikasi dan coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('Hapus Akun')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(
            Icons.delete_forever_outlined,
            size: 56,
            color: Colors.red,
          ),
          const SizedBox(height: 18),
          Text(
            'Hapus akun secara permanen',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'Akun, akses belajar, progres, jawaban, dan data yang terkait akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _password,
            obscureText: true,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: 'Kata sandi saat ini',
              errorText: _passwordError,
            ),
            onChanged: (_) {
              if (_passwordError != null) setState(() => _passwordError = null);
            },
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _confirmed,
            onChanged: _busy
                ? null
                : (value) => setState(() => _confirmed = value ?? false),
            title: const Text(
              'Saya memahami bahwa akun dan datanya akan dihapus permanen.',
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          FilledButton(
            onPressed: _busy || !_confirmed ? null : _delete,
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Hapus akun saya'),
          ),
        ],
      ),
    ),
  );
}
