import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/core/routes/app_router.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';

/// Splash screen menampilkan loading saat app startup
/// Nantinya bisa digunakan untuk check auth status
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Delay untuk menampilkan splash
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Check auth status
    // if (user is logged in) {
    //   context.go('/home');
    // } else {
    //   context.go('/login');
    // }

    if (mounted) {
      // Untuk sementara langsung ke login
      // Nanti bisa integrate dengan AuthBloc untuk check session
      // ignore: use_build_context_synchronously
      AppRouter.goToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo atau Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.school,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Loading Indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
