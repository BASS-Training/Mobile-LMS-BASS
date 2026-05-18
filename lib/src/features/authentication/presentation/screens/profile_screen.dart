import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          final user = state.user;
          return Scaffold(
            backgroundColor: AppColors.mist,
            appBar: AppBar(title: const Text('Profile'), elevation: 0),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.violet, AppColors.azure],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('👤', style: TextStyle(fontSize: 64)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.slate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.pearl),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.violet),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account Status',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slate,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.emerald,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.pearl),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.star_outline,
                                color: AppColors.apricot,
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Member Since',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slate,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Today',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.charcoal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthLogoutEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.crimson,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: Text('No user logged in')));
      },
    );
  }
}
