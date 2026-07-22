import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_accent.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

import '../../domain/entities/catalog_course_entity.dart';
import '../cubit/catalog_detail_cubit.dart';

/// Halaman preview kursus etalase: ringkasan + outline kurikulum yang digembok.
///
/// Aturan yang dipegang halaman ini: untuk kursus BERBAYAR tidak ada tombol,
/// link, atau kalimat apa pun yang mengarahkan pengguna membeli — baik di dalam
/// aplikasi maupun di luar. Yang ditawarkan hanyalah jalur kode akses.
class CatalogCourseDetailScreen extends StatelessWidget {
  /// Kursus dari kartu yang diketuk, dipakai menggambar header seketika
  /// sementara outline kurikulum masih dimuat.
  final CatalogCourseEntity? seed;

  final String courseId;

  const CatalogCourseDetailScreen({
    super.key,
    required this.courseId,
    this.seed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CatalogDetailCubit>(
      create: (_) =>
          ServiceLocator().locator<CatalogDetailCubit>()
            ..load(courseId, seed: seed),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Detail Kursus'),
      body: BlocConsumer<CatalogDetailCubit, CatalogDetailState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        builder: (context, state) {
          final course = state.course;

          if (course == null) {
            if (state.status == CatalogDetailStatus.failure) {
              return _CenteredMessage(
                icon: Icons.cloud_off_rounded,
                title: 'Gagal memuat kursus',
                message: state.errorMessage,
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppMeasures.paddingLarge,
                    AppMeasures.paddingLarge,
                    AppMeasures.paddingLarge,
                    24,
                  ),
                  children: [
                    _Header(course: course),
                    const SizedBox(height: 18),
                    _Stats(course: course),
                    if (course.description.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionTitle('Tentang Kursus'),
                      const SizedBox(height: 8),
                      Text(
                        course.description,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (course.sections.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _SectionTitle('Kurikulum'),
                      const SizedBox(height: 10),
                      ...course.sections.map(
                        (section) => _SectionTile(
                          section: section,
                          locked: !course.isEnrolled,
                        ),
                      ),
                    ] else if (state.status == CatalogDetailStatus.loading) ...[
                      const SizedBox(height: 22),
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _BottomAction(course: course, isEnrolling: state.isEnrolling),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final CatalogCourseEntity course;

  const _Header({required this.course});

  @override
  Widget build(BuildContext context) {
    final accent = CourseAccent.of(course.id);
    final thumbnail = course.thumbnailUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 168,
            width: double.infinity,
            child: thumbnail != null && thumbnail.isNotEmpty
                ? Image.network(
                    thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _GradientCover(accent: accent),
                  )
                : _GradientCover(accent: accent),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          course.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.25,
            color: AppColors.textPrimary,
          ),
        ),
        if (course.shortDescription.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            course.shortDescription,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        if (course.instructor.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                size: 15,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  course.instructor,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _GradientCover extends StatelessWidget {
  final CourseAccent accent;

  const _GradientCover({required this.accent});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: accent.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(child: Text('📚', style: TextStyle(fontSize: 52))),
    );
  }
}

class _Stats extends StatelessWidget {
  final CatalogCourseEntity course;

  const _Stats({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.xs,
      ),
      child: Row(
        children: [
          _stat(Icons.menu_book_rounded, '${course.lessonsCount}', 'Bab'),
          _divider(),
          _stat(Icons.play_lesson_rounded, '${course.totalContents}', 'Materi'),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.brandText),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: AppColors.borderSubtle);
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

/// Satu bab kurikulum. Saat [locked], judul materi tetap terlihat (supaya calon
/// peserta tahu isinya) tapi diberi ikon gembok — isinya memang tidak pernah
/// dikirim server sebelum terdaftar.
class _SectionTile extends StatelessWidget {
  final CatalogSectionEntity section;
  final bool locked;

  const _SectionTile({required this.section, required this.locked});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // ExpansionTile menggambar garis pemisah default yang bentrok dengan
        // border kartu.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          title: Text(
            'Bab ${section.sectionNumber} · ${section.title}',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${section.lessons.length} materi',
            style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
          ),
          children: section.lessons
              .map(
                (lesson) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Icon(
                        locked
                            ? Icons.lock_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 15,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// Aksi utama di bawah layar.
///
/// Tiga kemungkinan, dan tidak ada yang keempat:
///  * sudah diikuti  → buka di tab Kursus
///  * gratis         → Daftar Gratis
///  * berbayar       → arahkan ke "Gabung Kelas" (kode akses), TANPA menyebut
///                     pembelian di mana pun
class _BottomAction extends StatelessWidget {
  final CatalogCourseEntity course;
  final bool isEnrolling;

  const _BottomAction({required this.course, required this.isEnrolling});

  @override
  Widget build(BuildContext context) {
    final accent = CourseAccent.of(course.id);

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppMeasures.paddingLarge,
        12,
        AppMeasures.paddingLarge,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: _buildAction(context, accent),
    );
  }

  Widget _buildAction(BuildContext context, CourseAccent accent) {
    if (course.isEnrolled) {
      return Row(
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kursus ini sudah ada di daftar kursusmu.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            // Antar langsung ke tab Kursus, bukan Home — itu yang dicari user
            // setelah tahu kursusnya sudah dimiliki.
            onPressed: () => context.go(AppRoutes.main, extra: 1),
            child: const Text('Buka'),
          ),
        ],
      );
    }

    if (course.isFree) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: isEnrolling ? null : () => _enroll(context),
          style: FilledButton.styleFrom(
            backgroundColor: accent.solid,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isEnrolling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Daftar Gratis',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Kursus ini dibuka dengan kode akses dari penyelenggara.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.joinClass),
          icon: const Icon(Icons.vpn_key_rounded, size: 18),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.brandText,
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(color: AppColors.brandPrimary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          label: const Text(
            'Punya Kode Akses?',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _enroll(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final courseBloc = context.read<CourseBloc>();

    final success = await context.read<CatalogDetailCubit>().enrollFree();
    if (!success) return;

    courseBloc.add(const RefreshCoursesEvent());

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Berhasil bergabung. Cek tab Kursus untuk mulai belajar.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  const _CenteredMessage({
    required this.icon,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
