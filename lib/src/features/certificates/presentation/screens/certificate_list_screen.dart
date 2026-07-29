import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/certificates/data/certificate_repository.dart';
import 'package:lms_mobile_app/src/features/certificates/domain/entities/certificate_entity.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/cubit/certificate_cubit.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/widgets/certificate_list_tile.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

/// Layar Sertifikat peserta. Sekarang cermin dari dashboard peserta web:
/// aturan kelayakan sama persis (kursus punya template + progress 100% + item
/// bernilai sudah dinilai + profil lengkap), sertifikat yang diterbitkan nyata
/// (kode CERT + PDF), dan menampilkan dua bagian: siap diterbitkan & sudah
/// diterbitkan.
class CertificateListScreen extends StatelessWidget {
  const CertificateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator().locator<CertificateCubit>()..load(),
      child: const _CertificateListView(),
    );
  }
}

class _CertificateListView extends StatelessWidget {
  const _CertificateListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Sertifikat Saya'),
      body: BlocBuilder<CertificateCubit, CertificateState>(
        builder: (context, state) {
          final overview = state.overview;

          if (state.status == CertificateStatus.loading && overview.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          }

          if (state.status == CertificateStatus.error && overview.isEmpty) {
            return _ErrorView(
              message: state.error ?? 'Gagal memuat sertifikat.',
              onRetry: () => context.read<CertificateCubit>().load(),
            );
          }

          if (overview.isEmpty) {
            return RefreshIndicator(
              color: AppColors.brandPrimary,
              onRefresh: () => context.read<CertificateCubit>().load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                  AppEmptyState(
                    illustration:
                        'assets/illustrations/onboard_certificate.svg',
                    title: 'Belum ada sertifikat',
                    message:
                        'Selesaikan sebuah kursus hingga 100% dan pastikan semua '
                        'tugas telah dinilai untuk membuka sertifikat resmimu.',
                    actionLabel: 'Mulai Belajar',
                    onAction: () => context.push(AppRoutes.courses),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.brandPrimary,
            onRefresh: () => context.read<CertificateCubit>().load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                // Banner profil belum lengkap — muncul hanya bila ada kursus
                // yang siap tapi profil belum lengkap (sesuai gerbang web).
                if (!overview.profileComplete && overview.eligible.isNotEmpty)
                  FadeSlideIn(
                    child: _ProfileNoticeBanner(
                      missing: overview.missingProfileFields,
                    ),
                  ),

                if (overview.eligible.isNotEmpty) ...[
                  const FadeSlideIn(
                    child: _SectionHeader(
                      icon: Icons.workspace_premium_rounded,
                      color: AppColors.warning,
                      title: 'Siap Diterbitkan',
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < overview.eligible.length; i++) ...[
                    FadeSlideIn(
                      delayMs: i * 40,
                      child: _EligibleTile(
                        course: overview.eligible[i],
                        isGenerating:
                            state.generatingCourseId ==
                            overview.eligible[i].courseId,
                        onGenerate: () =>
                            _generate(context, overview.eligible[i]),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 10),
                ],

                if (overview.issued.isNotEmpty) ...[
                  FadeSlideIn(
                    child: _SectionHeader(
                      icon: Icons.verified_rounded,
                      color: AppColors.success,
                      title: 'Sudah Diterbitkan',
                      trailing: '${overview.issued.length}',
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < overview.issued.length; i++) ...[
                    FadeSlideIn(
                      delayMs: i * 40,
                      child: CertificateListTile(
                        certificate: overview.issued[i],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _generate(
    BuildContext context,
    EligibleCourseEntity course,
  ) async {
    final cubit = context.read<CertificateCubit>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final cert = await cubit.generate(course.courseId);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Sertifikat "${course.courseTitle}" berhasil diterbitkan!'),
        ),
      );
      context.push(AppRoutes.certificateDetail, extra: cert);
    } on CertificateException catch (e) {
      if (!context.mounted) return;
      if (e.code == 'profile_incomplete') {
        _showProfileDialog(context, e.missingProfileFields);
      } else {
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: AppColors.brandPrimary,
            content: Text(e.message),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.brandPrimary,
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  void _showProfileDialog(BuildContext context, List<String> missing) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Lengkapi Profil'),
        content: Text(
          missing.isEmpty
              ? 'Lengkapi data profil Anda terlebih dahulu untuk menerbitkan sertifikat.'
              : 'Untuk menerbitkan sertifikat, lengkapi data berikut di profil Anda:\n\n• ${missing.join('\n• ')}',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Nanti',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.push(AppRoutes.editProfile);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Lengkapi Profil'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? trailing;

  const _SectionHeader({
    required this.icon,
    required this.color,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              trailing!,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Banner peringatan bila data profil belum lengkap (gerbang sama seperti web).
class _ProfileNoticeBanner extends StatelessWidget {
  final List<String> missing;

  const _ProfileNoticeBanner({required this.missing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lengkapi profil untuk menerbitkan sertifikat',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  missing.isEmpty
                      ? 'Beberapa data profil masih kosong.'
                      : 'Belum lengkap: ${missing.join(', ')}.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.editProfile),
                  child: Text(
                    'Buka Profil →',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu kursus yang siap diterbitkan sertifikatnya, dengan tombol "Terbitkan".
class _EligibleTile extends StatelessWidget {
  final EligibleCourseEntity course;
  final bool isGenerating;
  final VoidCallback onGenerate;

  const _EligibleTile({
    required this.course,
    required this.isGenerating,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.45)),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.warning,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.courseTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kursus selesai · siap diterbitkan',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: PressScale(
                    child: ElevatedButton.icon(
                      onPressed: isGenerating ? null : onGenerate,
                      icon: isGenerating
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.verified_rounded, size: 18),
                      label: Text(isGenerating ? 'Menerbitkan…' : 'Terbitkan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
