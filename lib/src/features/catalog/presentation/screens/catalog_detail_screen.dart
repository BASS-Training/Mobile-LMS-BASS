import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/flavor_config.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/app_shadows.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/html_content.dart';
import '../../../courses/presentation/widgets/course_illustration_cover.dart';
import '../../domain/entities/catalog_course_entity.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';

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
    return state.courseById(widget.catalogId);
  }

  bool _isEnrolled(CatalogState state) => _courseOf(state)?.isEnrolled ?? false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  /// Validasi ketat untuk URL dari data remote/dummy: hanya https dengan host.
  static Uri? _validWebsiteUri(String? value) {
    final uri = value == null ? null : Uri.tryParse(value.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    return uri;
  }

  /// URL website course. API tidak mengirim field ini, jadi bila `externalUrl`
  /// kosong (semua data API live) pakai domain situs dari config yang sudah
  /// disesuaikan flavor (mis. `https://lms.basstrainingacademy.com`).
  static Uri? _websiteUri(String? externalUrl) {
    final raw = externalUrl?.trim() ?? '';
    if (raw.isNotEmpty) return _validWebsiteUri(raw);
    if (!FlavorConfig.isInitialized) return null;

    final api = Uri.tryParse(FlavorConfig.instance.apiBaseUrl);
    if (api == null || api.host.isEmpty) return null;
    final root = api.replace(path: '', query: null, fragment: null);
    final isHttp = root.scheme == 'http' || root.scheme == 'https';
    return isHttp ? root : null;
  }

  Future<void> _openWebsite(String? externalUrl) async {
    final uri = _websiteUri(externalUrl);
    if (uri == null) {
      _showMessage('Tautan website tidak tersedia.');
      return;
    }

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
        return (current.errorMessage != null &&
                previous.errorMessage != current.errorMessage) ||
            (!_isEnrolled(previous) && _isEnrolled(current));
      },
      listener: (context, state) {
        if (state.errorMessage != null) {
          _showMessage(state.errorMessage!);
        } else {
          _showMessage('Course berhasil diikuti.');
        }
      },
      builder: (context, state) {
        final course = _courseOf(state);
        final waiting =
            state.detailStatus == CatalogDetailStatus.initial ||
            state.detailStatus == CatalogDetailStatus.loading;

        if (course == null && waiting) {
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
          isEnrolling: state.enrollingId == course.id,
          onEnroll: () => context.read<CatalogBloc>().add(
            EnrollCatalogCourseEvent(course.id),
          ),
          onOpenWebsite: () => _openWebsite(course.externalUrl),
        );
      },
    );
  }
}

class _CatalogDetailContent extends StatelessWidget {
  final CatalogCourseEntity course;
  final bool isEnrolling;
  final VoidCallback onEnroll;
  final VoidCallback onOpenWebsite;

  const _CatalogDetailContent({
    required this.course,
    required this.isEnrolling,
    required this.onEnroll,
    required this.onOpenWebsite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _CatalogActionBar(
        course: course,
        isEnrolling: isEnrolling,
        onEnroll: onEnroll,
        onOpenWebsite: onOpenWebsite,
      ),
      body: CustomScrollView(
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusBadge(
                    enrolled: course.isEnrolled,
                    highlight: course.isFree,
                    label: course.isEnrolled
                        ? 'Sudah diikuti'
                        : course.priceLabel,
                  ),
                ),
                const SizedBox(height: 12),
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
                        course.instructor,
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
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.play_lesson_outlined,
                        value: '${course.lessonCount}',
                        label: 'Materi',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.payments_outlined,
                        value: course.priceLabel,
                        label: 'Harga',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
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
    return Image.network(
      thumbnail,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : CourseIllustrationCover(seed: course.id),
      errorBuilder: (_, _, _) => CourseIllustrationCover(seed: course.id),
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
  final bool isEnrolling;
  final VoidCallback onEnroll;
  final VoidCallback onOpenWebsite;

  const _CatalogActionBar({
    required this.course,
    required this.isEnrolling,
    required this.onEnroll,
    required this.onOpenWebsite,
  });

  @override
  Widget build(BuildContext context) {
    final free = course.isFree;
    final isEnrolled = free && course.isEnrolled;
    final isProcessing = free && isEnrolling;

    final VoidCallback? onPressed;
    final IconData icon;
    final String label;

    if (free) {
      final canEnroll = !isProcessing && !isEnrolled;
      onPressed = canEnroll ? onEnroll : null;
      icon = isEnrolled
          ? Icons.check_circle_rounded
          : Icons.add_circle_outline_rounded;
      label = isProcessing
          ? 'Memproses...'
          : isEnrolled
          ? 'Sudah Diikuti'
          : 'Ikuti Gratis';
    } else {
      // Course berbayar tidak dapat diikuti dari aplikasi (lihat
      // API_CATALOG.md), jadi aksinya adalah membuka website course.
      onPressed = onOpenWebsite;
      icon = Icons.open_in_new_rounded;
      label = 'Lihat di Website';
    }

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
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(icon),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.successSurface,
              disabledForegroundColor: AppColors.successText,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
