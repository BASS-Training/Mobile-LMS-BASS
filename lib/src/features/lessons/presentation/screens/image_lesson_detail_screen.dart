import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_actions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_navigation_mixin.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/attendance/attendance_status_banner.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_app_bar.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/discussion/discussion_button.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_navigation_bar.dart';

class ImageLessonDetailScreen extends StatefulWidget {
  final LessonEntity lesson;
  final CourseEntity course;
  final int lessonIndex;

  const ImageLessonDetailScreen({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<ImageLessonDetailScreen> createState() =>
      _ImageLessonDetailScreenState();
}

class _ImageLessonDetailScreenState extends State<ImageLessonDetailScreen>
    with LessonNavigationMixin {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final PageController _pageController;
  int _currentPage = 0;

  static const _accent = AppColors.brandPrimary;
  static const _accentDark = AppColors.brandPrimaryDark;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _pageController = PageController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Mark complete immediately on open, same as document type
    WidgetsBinding.instance.addPostFrameCallback((_) => _markCompleteOnOpen());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _markCompleteOnOpen() {
    if (!widget.lesson.isCompleted) {
      context.read<LessonBloc>().add(
        MarkLessonCompleteEvent(lessonId: widget.lesson.id),
      );
      context.read<CourseBloc>().add(const RefreshCoursesEvent());
    }
  }

  Future<void> _markComplete({bool goToNext = false}) async {
    if (!widget.lesson.isCompleted) {
      context.read<LessonBloc>().add(
        MarkLessonCompleteEvent(lessonId: widget.lesson.id),
      );
      context.read<CourseBloc>().add(const RefreshCoursesEvent());
    }

    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    if (goToNext && nextLesson != null) {
      // pushReplacement (di navigateToLesson) sudah mengganti layar lesson ini.
      navigateToLesson(nextLesson!, widget.lessonIndex + 1);
      return;
    }

    popToCourse(context);
  }

  List<String> get _imageUrls {
    final urls = widget.lesson.imageUrls.where((u) => u.isNotEmpty).toList();
    // Fall back to documentUrl / content if no imageUrls array
    if (urls.isEmpty) {
      final fallback = widget.lesson.documentUrl?.trim() ?? '';
      if (fallback.isNotEmpty) return [fallback];
      final content = widget.lesson.content.trim();
      final uri = Uri.tryParse(content);
      if (uri != null && uri.hasScheme) return [content];
    }
    return urls;
  }

  @override
  CourseEntity get currentCourse => widget.course;

  @override
  int get currentLessonIndex => widget.lessonIndex;

  @override
  Widget build(BuildContext context) {
    final images = _imageUrls;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: LessonDrawer(
        course: widget.course,
        currentLessonIndex: widget.lessonIndex,
        onSelectLesson: (selectedLesson, index) {
          Navigator.pop(context); // tutup drawer
          navigateToLesson(selectedLesson, index);
        },
      ),
      appBar: LessonAppBar(
        courseTitle: widget.course.title,
        subtitle: 'IMAGE VIEWER',
        action: DiscussionIconButton(
          lessonId: widget.lesson.id,
          lessonTitle: widget.lesson.title,
        ),
        gradientColors: const [_accent, _accentDark],
        onBack: () {
          popToCourse(context);
        },
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: LessonNavigationBar(
            canGoPrevious: canGoPrevious,
            canGoNext: canGoNext,
            primaryColor: _accent,
            forwardBlocked: canGoNext && widget.lesson.attendancePending,
            blockedReason: AttendanceInfo.blockedReason(widget.lesson),
            onPrevious: canGoPrevious
                ? () => navigateToLesson(
                    previousLesson!,
                    widget.lessonIndex - 1,
                  )
                : null,
            onForward: () => _markComplete(goToNext: canGoNext),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (widget.lesson.attendanceRequired)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: AttendanceStatusBanner(lesson: widget.lesson),
              ),
            if (widget.lesson.content.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildDescriptionCard(),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: images.isEmpty
                    ? _buildEmptyState()
                    : _buildImageCarousel(images),
              ),
            ),
            if (images.length > 1) ...[
              const SizedBox(height: 12),
              _buildPageIndicator(images.length),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderDefault.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.image_rounded, color: _accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.lesson.content.trim(),
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderDefault.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) =>
                  _buildZoomableImage(images[index]),
            ),
            if (images.length > 1) ...[
              // Previous arrow
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _currentPage > 0
                      ? _buildArrowButton(
                          Icons.chevron_left_rounded,
                          () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              // Next arrow
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _currentPage < images.length - 1
                      ? _buildArrowButton(
                          Icons.chevron_right_rounded,
                          () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              // Counter badge
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentPage + 1} / ${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildZoomableImage(String url) {
    // Decode pada resolusi layar saja (bukan resolusi penuh gambar) supaya
    // decode jauh lebih cepat & hemat memori untuk gambar besar.
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final memWidth = (MediaQuery.of(context).size.width * dpr).round();

    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4.0,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        width: double.infinity,
        // Cache disk (instan saat dibuka ulang) + downscale decode.
        memCacheWidth: memWidth,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, _) => Center(
          child: CircularProgressIndicator(color: _accent, strokeWidth: 2.5),
        ),
        errorWidget: (context, _, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image_rounded,
                size: 48,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Gambar tidak dapat dimuat',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? _accent : AppColors.borderDefault,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderDefault.withValues(alpha: 0.9),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_rounded,
                size: 56,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Gambar belum tersedia',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Backend perlu mengirim URL gambar untuk lesson ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
