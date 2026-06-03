import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';

/// Home screen hero header: brand-gradient panel with a greeting, the user's
/// first name and a profile avatar. Kept presentational — the only data it
/// reads is the authenticated user's name.
class HomeHeader extends StatelessWidget {
  final TextEditingController searchController;

  const HomeHeader({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppMeasures.paddingXLarge,
        AppMeasures.paddingLarge,
        AppMeasures.paddingXLarge,
        AppMeasures.paddingXXLarge + 4,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Soft decorative glow in the corner for subtle depth.
          Positioned(
            top: -48,
            right: -32,
            child: _glowCircle(140, 0.16),
          ),
          Positioned(
            bottom: -56,
            left: -40,
            child: _glowCircle(120, 0.10),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildTopRow(), const SizedBox(height: 18)],
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadge(),
              const SizedBox(height: 16),
              Text(
                AppStrings.helloWelcome,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 4),
              _buildUserNameDisplay(),
              const SizedBox(height: 8),
              Text(
                AppStrings.readyForLesson,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildProfileAvatar(),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.music_note_rounded, color: Colors.white, size: 13),
          SizedBox(width: 6),
          Text(
            'Bass Training LMS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserNameDisplay() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        var userName = 'User';
        if (state is AuthSuccess) {
          userName = state.user.name.split(' ').first;
        }
        return Text(
          userName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
