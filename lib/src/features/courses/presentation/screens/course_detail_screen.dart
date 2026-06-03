import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_detail_header.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_info_cards.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_section_accordion.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/widgets/progress_indicator.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course/course_bloc.dart';
import '../bloc/course/course_event.dart';
import '../bloc/course/course_state.dart';

const _kPollingInterval = Duration(seconds: 30);

class CourseDetailScreen extends StatefulWidget {
  final CourseEntity course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with WidgetsBindingObserver {
  Timer? _pollingTimer;

  /// Melacak apakah sedang ada proses refresh agar bisa
  /// menampilkan LinearProgressIndicator di bagian atas.
  bool _isRefreshing = false;

  /// Digunakan oleh RefreshIndicator agar tahu kapan refresh selesai.
  Completer<void>? _refreshCompleter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LocalStorage.recordRecentCourse(widget.course.id);

    // Fetch data segar langsung saat screen pertama kali dibuat.
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerRefresh());

    // Polling ringan setiap 30 detik selama screen ini aktif.
    _pollingTimer = Timer.periodic(_kPollingInterval, (_) => _triggerRefresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    _refreshCompleter?.complete(); // pastikan tidak ada completer yang tergantung
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _triggerRefresh();
    }
  }

  /// Dispatch refresh event dan tandai sedang loading.
  void _triggerRefresh() {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    context.read<CourseBloc>().add(const RefreshCoursesEvent());
  }

  /// Callback untuk RefreshIndicator (pull-to-refresh).
  /// Mengembalikan Future yang selesai saat BLoC emit CourseLoaded/Failure.
  Future<void> _onPullRefresh() {
    _refreshCompleter?.complete();
    _refreshCompleter = Completer<void>();
    _triggerRefresh();
    return _refreshCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        // Selesaikan paksa jika timeout, agar RefreshIndicator tidak tergantung.
      },
    );
  }

  /// Dipanggil oleh BlocConsumer listener saat BLoC selesai memproses refresh.
  void _onRefreshComplete() {
    if (!mounted) return;
    setState(() => _isRefreshing = false);
    _refreshCompleter?.complete();
    _refreshCompleter = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourseBloc, CourseState>(
      // Hanya update UI saat state berubah secara signifikan
      buildWhen: (prev, curr) =>
          curr is CourseLoaded ||
          curr is CourseLoading ||
          curr is CourseFailure,
      listenWhen: (prev, curr) =>
          curr is CourseLoaded || curr is CourseFailure,
      listener: (context, state) {
        // Refresh selesai — sembunyikan loading indicator.
        _onRefreshComplete();
      },
      builder: (context, state) {
        // Gunakan data terbaru dari BLoC; fallback ke widget.course
        // jika BLoC belum punya data atau course tidak ditemukan.
        CourseEntity currentCourse = widget.course;
        if (state is CourseLoaded) {
          currentCourse = state.courses.firstWhere(
            (c) => c.id == widget.course.id,
            orElse: () => widget.course,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // ── Indikator loading tipis di bagian paling atas ────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: _isRefreshing ? 3.0 : 0.0,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.brandPrimary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.brandPrimary,
                  ),
                  minHeight: 3,
                ),
              ),

              // ── Konten utama dengan pull-to-refresh ──────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onPullRefresh,
                  color: AppColors.brandPrimary,
                  backgroundColor: Colors.white,
                  strokeWidth: 2.5,
                  child: SingleChildScrollView(
                    // physics wajib agar RefreshIndicator bisa trigger
                    // meski konten pendek
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CourseDetailHeader(course: currentCourse),

                        Padding(
                          padding:
                              const EdgeInsets.all(AppMeasures.paddingLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CourseInfoCards(course: currentCourse),
                              const SizedBox(height: 24),

                              const Text(
                                'Tentang Kursus',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentCourse.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 24),

                              CourseProgressIndicator(
                                progress: currentCourse.progressPercentage,
                                label: 'Your Progress',
                                showPercentage: true,
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton.icon(
                                  onPressed: () => context.push(
                                    AppRoutes.courseResults,
                                    extra: currentCourse,
                                  ),
                                  icon: const Icon(Icons.assessment_rounded),
                                  label: const Text('Nilai & Hasil'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brandPrimary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Materi Kursus',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandPrimary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${currentCourse.completedLessons}/${currentCourse.totalLessons}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.brandPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              ...currentCourse.sections.map((section) {
                                return CourseSectionAccordion(
                                  section: section,
                                  course: currentCourse,
                                );
                              }),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
