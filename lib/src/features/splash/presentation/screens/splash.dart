import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/bloc/session_bloc.dart';
import 'package:lms_mobile_app/src/core/bloc/session_state.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_images.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        state.mapOrNull(
          authenticated: (_) => context.go('/home'),
          unauthenticated: (_) => context.go('/login'),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImages.global.logoBass, width: 140, height: 140),
              const SizedBox(height: 20),
              Text('QuantaHRIS', style: AppTypography.displayLarge),
            ],
          ),
        ),
      ),
    );
  }
}
