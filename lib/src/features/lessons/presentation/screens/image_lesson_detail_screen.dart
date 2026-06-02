import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_navigation_mixin.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

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

  static const _tealStart = Color(0xFF00ACC1);
  static const _tealEnd = Color(0xFF00796B);

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
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
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
      context.pop();
      Future.delayed(const Duration(milliseconds: 180), () {
        if (!mounted) return;
        navigateToLesson(nextLesson!, widget.lessonIndex + 1);
      });
      return;
    }

    context.pop();
  }

  List<String> get _imageUrls {
    final urls = widget.lesson.imageUrls
        .where((u) => u.isNotEmpty)
        .toList();
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
      backgroundColor: const Color(0xFFF0FAFA),
      drawer: LessonDrawer(
        course: widget.course,
        currentLessonIndex: widget.lessonIndex,
        onSelectLesson: (selectedLesson, index) {
          final route = LessonRouteResolver.routeForType(selectedLesson.type);
          context.push(route, extra: {
            'lesson': selectedLesson,
            'course': widget.course,
            'lessonIndex': index,
          });
        },
      ),
      appBar: _buildAppBar(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: _buildNavigationBar(),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.course.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'IMAGE VIEWER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_tealStart, _tealEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          context.read<CourseBloc>().add(const RefreshCoursesEvent());
        },
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: const Icon(Icons.menu_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
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
              color: _tealStart.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.image_rounded, color: _tealStart, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.lesson.content.trim(),
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.slate,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.9)),
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
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4.0,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: _tealStart,
              strokeWidth: 2.5,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_rounded,
                  size: 48, color: AppColors.slate.withValues(alpha: 0.5)),
              const SizedBox(height: 8),
              Text(
                'Gambar tidak dapat dimuat',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.slate.withValues(alpha: 0.7),
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
            color: isActive ? _tealStart : AppColors.pearl,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.9)),
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
                color: AppColors.slate.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              const Text(
                'Gambar belum tersedia',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Backend perlu mengirim URL gambar untuk lesson ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.slate.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF0FAFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canGoPrevious) ...[
            Expanded(
              child: PressScale(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 200), () {
                      navigateToLesson(previousLesson!, widget.lessonIndex - 1);
                    });
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Sebelumnya'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.pearl.withValues(alpha: 0.9),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.charcoal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: PressScale(
              child: ElevatedButton.icon(
                onPressed: () => _markComplete(goToNext: canGoNext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tealStart,
                  shadowColor: _tealStart.withValues(alpha: 0.45),
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: Icon(
                  canGoNext
                      ? Icons.arrow_forward_rounded
                      : Icons.check_rounded,
                ),
                label: Text(canGoNext ? 'Lanjut' : 'Selesai'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
