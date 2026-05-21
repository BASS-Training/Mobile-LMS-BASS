import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';
import 'package:lms_mobile_app/src/core/utils/validators.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final String _role = 'participant';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _role,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Akun berhasil dibuat. Masuk ke aplikasi...'),
                backgroundColor: AppColors.emerald,
              ),
            );
            context.go(AppRoutes.main);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(color: AppColors.red),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: EdgeInsets.all(AppMeasures.paddingLarge),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              children: [
                                Image.asset(
                                  'assets/images/bass_logo2.png',
                                  height: 160,
                                  width: 160,
                                  fit: BoxFit.contain,
                                  semanticLabel: AppStrings.appName,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Center(
                                          child: Text(
                                            '📚',
                                            style: TextStyle(fontSize: 80),
                                          ),
                                        ),
                                      ),
                                ),
                                Text(
                                  AppStrings.appName,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Buat akun peserta sementara',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'Nama Lengkap',
                                prefixIcon: Icon(Icons.person_outlined),
                                prefixIconColor: AppColors.tomato,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama wajib diisi';
                                }
                                return null;
                              },
                              onChanged: (_) {
                                context.read<AuthBloc>().add(
                                  const AuthClearErrorEvent(),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: AppStrings.email,
                                prefixIcon: Icon(Icons.email_outlined),
                                prefixIconColor: AppColors.tomato,
                              ),
                              validator: Validators.validateEmail,
                              onChanged: (_) {
                                context.read<AuthBloc>().add(
                                  const AuthClearErrorEvent(),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: AppStrings.password,
                                prefixIcon: const Icon(Icons.lock_outlined),
                                prefixIconColor: AppColors.tomato,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  child: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.silver,
                                  ),
                                ),
                              ),
                              validator: Validators.validatePassword,
                              onChanged: (_) {
                                context.read<AuthBloc>().add(
                                  const AuthClearErrorEvent(),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.mist,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.pearl),
                              ),
                              child: const Text(
                                'Role default saat register adalah peserta. Akun instruktur akan diaktifkan manual dari dashboard Laravel.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.slate,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.red,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () => _handleRegister(context),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Register',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                context.go(AppRoutes.login);
                              },
                              child: const Text(
                                'Sudah punya akun? Login',
                                style: TextStyle(color: AppColors.tomato),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
