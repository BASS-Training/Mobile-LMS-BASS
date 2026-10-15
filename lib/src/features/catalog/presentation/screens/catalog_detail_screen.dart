import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/constants/app_routes.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/app_shadows.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/html_content.dart';
import '../../../courses/presentation/widgets/course_illustration_cover.dart';
import '../../../courses/presentation/bloc/course/course_bloc.dart';
import '../../../courses/presentation/bloc/course/course_event.dart';
import '../../../authentication/presentation/bloc/auth/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth/auth_event.dart';
import '../../../authentication/presentation/bloc/auth/auth_state.dart';
import '../../domain/entities/catalog_course_entity.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import '../widgets/course_sales_profile_section.dart';

class CatalogDetailScreen extends StatefulWidget {
  final String catalogId;

  const CatalogDetailScreen({super.key, required this.catalogId});

  @override
  State<CatalogDetailScreen> createState() => _CatalogDetailScreenState();
}

class _CatalogDetailScreenState extends State<CatalogDetailScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<CatalogBloc>();
    if (bloc.state.status == CatalogStatus.initial) {
      bloc.add(const LoadCatalogEvent());
    }
    // Detail selalu diambil ulang dari endpoint `/catalog/{id}`.
    bloc.add(LoadCatalogDetailEvent(widget.catalogId));
  }

  CatalogCourseEntity? _courseOf(CatalogState state) {
    final detail = state.detailCourse;
    if (detail != null && detail.id == widget.catalogId) return detail;
    return null;
  }

  Future<void> _refreshDetail() async {
    final bloc = context.read<CatalogBloc>();
    final done = bloc.stream.firstWhere(
      (state) =>
          state.detailStatus == CatalogDetailStatus.loaded ||
          state.detailStatus == CatalogDetailStatus.failure,
    );
    bloc.add(LoadCatalogDetailEvent(widget.catalogId));
    await done;
  }

  bool _isEnrolled(CatalogState state) => _courseOf(state)?.isEnrolled ?? false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _openWebsite() async {
    final uri = Uri.https('lms.basstrainingacademy.com', '/');

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showMessage('Website belum dapat dibuka.');
      }
    } catch (_) {
      if (mounted) _showMessage('Website belum dapat dibuka.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CatalogBloc, CatalogState>(
      listenWhen: (previous, current) {
        return (current.detailRequiresLogin && !previous.detailRequiresLogin) ||
            (current.errorMessage != null &&
                previous.errorMessage != current.errorMessage) ||
            (previous.enrollingId != null &&
                current.enrollingId == null &&
                !_isEnrolled(previous) &&
                _isEnrolled(current));
      },
      listener: (context, state) async {
        if (state.detailRequiresLogin) {
          final authBloc = context.read<AuthBloc>();
          final loggedOut = authBloc.stream.firstWhere(
            (authState) => authState is AuthLoggedOut,
          );
          authBloc.add(const AuthLogoutEvent());
          await loggedOut;
          if (context.mounted) context.go(AppRoutes.login);
        } else if (state.errorMessage != null) {
          _showMessage(state.errorMessage!);
        } else {
          _showMessage('Course berhasil diikuti.');
          context.read<CourseBloc>().add(const RefreshCoursesEvent());
          context.read<CatalogBloc>().add(
            LoadCatalogDetailEvent(widget.catalogId),
          );
        }
      },
      builder: (context, state) {
        final course = _courseOf(state);
        final isAuthenticated = context.select<AuthBloc, bool>(
          (bloc) => bloc.state is AuthSuccess,
        );
        final waiting =
            state.detailStatus == CatalogDetailStatus.initial ||
            state.detailStatus == CatalogDetailStatus.loading;

        if (waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            ),
          );
        }

        if (course == null) {
          return Scaffold(
            appBar: AppBar(),
            body: AppEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Course tidak ditemukan',
              message:
                  state.detailErrorMessage ??
                  'Data course ini tidak tersedia di katalog.',
              actionLabel: 'Muat Ulang',
              onAction: () => context.read<CatalogBloc>().add(
                LoadCatalogDetailEvent(widget.catalogId),
              ),
            ),
          );
        }

        return _CatalogDetailContent(
          course: course,
          isAuthenticated: isAuthenticated,
          isEnrolling: state.enrollingId == course.id,
          onEnroll: () => context.read<CatalogBloc>().add(
            EnrollCatalogCourseEvent(course.id),
          ),
          onOpenWebsite: _openWebsite,
          onLogin: () => context.go(AppRoutes.login),
          onCourseList: () => context.go(AppRoutes.courses),
          onRefresh: _refreshDetail,
        );
      },
    );
  }
}

class _CatalogDetailContent extends StatelessWidget {
  final CatalogCourseEntity course;
  final bool isAuthenticated;
  final bool isEnrolling;
  final VoidCallback onEnroll;
  final VoidCallback onOpenWebsite;
  final VoidCallback onLogin;
  final VoidCallback onCourseList;
  final Future<void> Function() onRefresh;

  const _CatalogDetailContent({
    required this.course,
    required this.isAuthenticated,
    required this.isEnrolling,
    required this.onEnroll,
    required this.onOpenWebsite,
    required this.onLogin,
    required this.onCourseList,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _CatalogActionBar(
        course: course,
        isAuthenticated: isAuthenticated,
        isEnrolling: isEnrolling,
        onEnroll: onEnroll,
        onOpenWebsite: onOpenWebsite,
        onLogin: onLogin,
        onCourseList: onCourseList,
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 292,
              pinned: true,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              flexibleSpace: FlexibleSpaceBar(
                background: _CatalogHero(course: course),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (course.isEnrolled) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: _StatusBadge(
                        enrolled: true,
                        highlight: true,
                        label: 'Sudah diikuti',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    course.title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 25,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  if ((course.salesProfile?.headline?.trim().isNotEmpty ??
                          false) ||
                      course.shortDescription.trim().isNotEmpty) ...[
                    Text(
                      (course.salesProfile?.headline?.trim().isNotEmpty ??
                              false)
                          ? course.salesProfile!.headline!.trim()
                          : course.shortDescription.trim(),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: AppColors.brandText,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          course.instructors.isNotEmpty
                              ? course.instructors
                                    .map((item) => item.name)
                                    .join(', ')
                              : course.instructor,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _InfoTile(
                    icon: Icons.play_lesson_outlined,
                    value: '${course.lessonCount}',
                    label: 'Materi',
                  ),
                  if (course.showPrice && course.isPaid) ...[
                    const SizedBox(height: 10),
                    _InfoTile(
                      icon: Icons.payments_outlined,
                      value: course.priceLabel,
                      label: 'Harga',
                    ),
                  ],
                  const SizedBox(height: 28),
                  CourseSalesProfileSection(profile: course.salesProfile),
                  _SectionTitle(title: 'Tentang course'),
                  const SizedBox(height: 10),
                  if (course.description.trim().isEmpty)
                    Text(
                      'Belum ada deskripsi untuk course ini.',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                        height: 1.65,
                      ),
                    )
                  else
                    HtmlContent(html: course.description),
                  if (course.instructors.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'Pengajar'),
                    const SizedBox(height: 12),
                    for (final instructor in course.instructors)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    foregroundImage:
                                        instructor.avatarUrl == null
                                        ? null
                                        : NetworkImage(instructor.avatarUrl!),
                                    child: const Icon(Icons.person_outline),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      instructor.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (instructor.bioHtml?.trim().isNotEmpty ??
                                  false) ...[
                                const SizedBox(height: 10),
                                HtmlContent(html: instructor.bioHtml!),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                  if (course.sections.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionTitle(title: 'Yang akan dipelajari'),
                    const SizedBox(height: 12),
                    ...course.sections.asMap().entries.map(
                      (entry) => _SyllabusTile(
                        number: entry.key + 1,
                        section: entry.value,
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogHero extends StatelessWidget {
  final CatalogCourseEntity course;

  const _CatalogHero({required this.course});

  @override
  Widget build(BuildContext context) {
    final thumbnail = course.thumbnailUrl;
    if (thumbnail == null || thumbnail.isEmpty) {
      return CourseIllustrationCover(
        seed: course.id,
        padding: const EdgeInsets.fromLTRB(74, 72, 74, 30),
      );
    }
    return CachedNetworkImage(
      imageUrl: thumbnail,
      fit: BoxFit.cover,
      memCacheWidth: 1200,
      memCacheHeight: 900,
      placeholder: (_, _) => CourseIllustrationCover(seed: course.id),
      errorWidget: (_, _, _) => CourseIllustrationCover(seed: course.id),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InfoTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.xs,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandSurface,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: AppColors.brandText),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10.5,
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SyllabusTile extends StatelessWidget {
  final int number;
  final CatalogSectionEntity section;

  const _SyllabusTile({required this.number, required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: AppColors.brandText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${section.lessonCount} materi',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool enrolled;
  final bool highlight;
  final String label;

  const _StatusBadge({
    required this.enrolled,
    required this.highlight,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final positive = enrolled || highlight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: enrolled
            ? AppColors.successSurface
            : positive
            ? AppColors.brandSurface
            : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: enrolled
              ? AppColors.successText
              : positive
              ? AppColors.brandText
              : AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CatalogActionBar extends StatelessWidget {
  final CatalogCourseEntity course;
  final bool isAuthenticated;
  final bool isEnrolling;
  final VoidCallback onEnroll;
  final VoidCallback onOpenWebsite;
  final VoidCallback onLogin;
  final VoidCallback onCourseList;

  const _CatalogActionBar({
    required this.course,
    required this.isAuthenticated,
    required this.isEnrolling,
    required this.onEnroll,
    required this.onOpenWebsite,
    required this.onLogin,
    required this.onCourseList,
  });

  @override
  Widget build(BuildContext context) {
    final isEnrolled = course.isEnrolled;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: SizedBox(
          height: 52,
          child: isEnrolled
              ? ElevatedButton.icon(
                  onPressed: onCourseList,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Lanjutkan Belajar'),
                )
              : course.isPaid
              ? _websiteButton()
              : !isAuthenticated
              ? ElevatedButton.icon(
                  onPressed: onLogin,
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Masuk untuk Mengikuti'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(child: _websiteButton(outlined: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _enrollButton(isEnrolled)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _websiteButton({bool outlined = false}) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    const textStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w800);

    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onOpenWebsite,
        icon: const Icon(Icons.open_in_new_rounded),
        label: const Text('Website'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandText,
          side: BorderSide(color: AppColors.brandPrimary),
          shape: shape,
          textStyle: textStyle,
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onOpenWebsite,
      icon: const Icon(Icons.open_in_new_rounded),
      label: const Text('Website'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: shape,
        textStyle: textStyle,
      ),
    );
  }

  Widget _enrollButton(bool isEnrolled) {
    final canEnroll = !isEnrolling && !isEnrolled;
    return ElevatedButton.icon(
      onPressed: canEnroll ? onEnroll : null,
      icon: isEnrolling
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(
              isEnrolled
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
            ),
      label: Text(
        isEnrolling
            ? 'Memproses...'
            : isEnrolled
            ? 'Sudah Diikuti'
            : 'Ikuti Gratis',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.successSurface,
        disabledForegroundColor: AppColors.successText,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }
}
