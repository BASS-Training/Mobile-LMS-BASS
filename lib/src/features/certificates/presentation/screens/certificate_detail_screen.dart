import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';

/// Certificate detail / verification screen. Renders a real, elegant
/// certificate of completion plus its verification metadata.
class CertificateDetailScreen extends StatelessWidget {
  final CourseEntity course;

  const CertificateDetailScreen({super.key, required this.course});

  String get _issueDate => '6 Mei 2026';
  String get _expiryDate => '6 Mei 2031';

  /// Stable, human-readable certificate id derived from the course id.
  String get _certificateId {
    final raw = course.id.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
    final tail = raw.length > 6
        ? raw.substring(raw.length - 6)
        : raw.padLeft(6, '0');
    return 'BTL-${tail.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final holderName = context.select<AuthBloc, String>((bloc) {
      final state = bloc.state;
      if (state is AuthSuccess) return state.user.name;
      return 'User';
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sertifikat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.brandGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              child: _CertificateCard(
                holderName: holderName,
                courseTitle: course.title,
                issueDate: _issueDate,
                certificateId: _certificateId,
              ),
            ),
            const SizedBox(height: 16),
            FadeSlideIn(delayMs: 80, child: const _ActionButtons()),
            const SizedBox(height: 20),
            FadeSlideIn(
              delayMs: 140,
              child: _DetailCard(
                rows: [
                  _Detail('Pemegang Sertifikat', holderName, Icons.person_rounded),
                  _Detail('Kursus', course.title, Icons.menu_book_rounded),
                  _Detail('Instruktur', course.instructor, Icons.school_rounded),
                  _Detail('Tanggal Terbit', _issueDate, Icons.event_rounded),
                  _Detail('Berlaku Hingga', _expiryDate, Icons.event_busy_rounded),
                  _Detail('ID Sertifikat', _certificateId, Icons.tag_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final String holderName;
  final String courseTitle;
  final String issueDate;
  final String certificateId;

  const _CertificateCard({
    required this.holderName,
    required this.courseTitle,
    required this.issueDate,
    required this.certificateId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.md,
        border: Border.all(color: const Color(0xFFF1D9A0), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative corner glows
            Positioned(
              top: -40,
              right: -40,
              child: _glow(120, AppColors.warning.withValues(alpha: 0.10)),
            ),
            Positioned(
              bottom: -50,
              left: -40,
              child: _glow(120, AppColors.brandPrimary.withValues(alpha: 0.07)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
              child: Column(
                children: [
                  _seal(),
                  const SizedBox(height: 16),
                  const Text(
                    'SERTIFIKAT KELULUSAN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 54,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFC53D), Color(0xFFF59E0B)],
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Dengan bangga diberikan kepada',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    holderName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'atas keberhasilan menyelesaikan kursus',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    courseTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.borderSubtle, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _footerBlock('Tanggal Terbit', issueDate),
                      _footerBlock('Penerbit', 'Bass Training LMS'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No. $certificateId',
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _seal() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC53D), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.brand(AppColors.warning, opacity: 0.35),
      ),
      child: const Icon(
        Icons.workspace_premium_rounded,
        color: Colors.white,
        size: 36,
      ),
    );
  }

  Widget _footerBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _toast(context, 'Fitur download akan segera hadir!'),
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text('Unduh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _toast(context, 'Fitur share akan segera hadir!'),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Bagikan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandPrimary,
                side: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Detail {
  final String label;
  final String value;
  final IconData icon;

  const _Detail(this.label, this.value, this.icon);
}

class _DetailCard extends StatelessWidget {
  final List<_Detail> rows;

  const _DetailCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.verified_user_rounded, color: AppColors.success, size: 20),
              SizedBox(width: 8),
              Text(
                'Sertifikat Terverifikasi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 22,
                thickness: 1,
                color: AppColors.borderSubtle,
              ),
            _DetailRow(detail: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final _Detail detail;

  const _DetailRow({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.brandPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(detail.icon, size: 17, color: AppColors.brandPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail.value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
