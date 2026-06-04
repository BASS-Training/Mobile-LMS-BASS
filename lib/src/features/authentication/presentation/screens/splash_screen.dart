import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Animated splash / session-gate. Plays a short brand animation while the
/// app restores the user's session in the background, then hands off to the
/// router (which sends authenticated users to the dashboard and everyone else
/// to onboarding).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _loopController;

  static const Duration _minSplash = Duration(milliseconds: 2300);

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    _goNext();
  }

  Future<void> _goNext() async {
    final authBloc = context.read<AuthBloc>();
    await Future<void>.delayed(_minSplash);

    // Give a still-pending session check a brief grace window so authenticated
    // users skip the onboarding flash.
    if (authBloc.state is AuthInitial) {
      await authBloc.stream
          .firstWhere((s) => s is! AuthInitial)
          .timeout(const Duration(seconds: 2), onTimeout: () => authBloc.state);
    }

    if (!mounted) return;
    // Let the router's redirect decide the real destination from auth state.
    context.go(AppRoutes.main);
  }

  @override
  void dispose() {
    _introController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    final scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    final taglineFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Soft brand glow behind the logo.
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandPrimary.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: fade,
                  child: ScaleTransition(
                    scale: scale,
                    child: Image.asset(
                      'assets/images/bass_logo.png',
                      width: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.school_rounded,
                        size: 96,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: taglineFade,
                  child: const Text(
                    'Belajar di Bass Lebih Terarah',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Animated loader near the bottom.
          Positioned(
            left: 0,
            right: 0,
            bottom: 56,
            child: FadeTransition(
              opacity: taglineFade,
              child: _PulsingDots(controller: _loopController),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three brand-colored dots that pulse in a wave.
class _PulsingDots extends StatelessWidget {
  final AnimationController controller;

  const _PulsingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final phase = (controller.value + i * 0.2) % 1.0;
            final t = (1 - (phase * 2 - 1).abs()).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPrimary.withValues(alpha: 0.3 + t * 0.7),
              ),
            );
          },
        );
      }),
    );
  }
}
