import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/routes/app_router.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_section_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class DocumentLessonDetailScreen extends StatefulWidget {
  final LessonEntity lesson;
  final CourseEntity course;
  final int lessonIndex;

  const DocumentLessonDetailScreen({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<DocumentLessonDetailScreen> createState() =>
      _DocumentLessonDetailScreenState();
}

class _DocumentLessonDetailScreenState
    extends State<DocumentLessonDetailScreen> {
  late GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  bool get canGoNext =>
      widget.lessonIndex < widget.course.allLessons.length - 1;
  bool get canGoPrevious => widget.lessonIndex > 0;

  LessonEntity? get nextLesson =>
      canGoNext ? widget.course.allLessons[widget.lessonIndex + 1] : null;
  LessonEntity? get previousLesson =>
      canGoPrevious ? widget.course.allLessons[widget.lessonIndex - 1] : null;

  void _openLesson(LessonEntity lesson, int lessonIndex) {
    AppRouter.openLesson(
      context,
      lesson: lesson,
      course: widget.course,
      lessonIndex: lessonIndex,
    );
  }

  void _markComplete() {
    context.read<LessonBloc>().add(
      MarkLessonCompleteEvent(lessonId: widget.lesson.id),
    );
    context.read<CourseBloc>().add(const RefreshCoursesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    final List<DocumentSectionEntity> sections = _buildDummySections(
      lesson.content,
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: LessonDrawer(
        course: widget.course,
        currentLessonIndex: widget.lessonIndex,
        onSelectLesson: (selectedLesson, index) {
          AppRouter.openLesson(
            context,
            lesson: selectedLesson,
            course: widget.course,
            lessonIndex: index,
          );
        },
      ),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.course.title),
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            context.read<CourseBloc>().add(const RefreshCoursesEvent());
          },
          child: const Icon(Icons.arrow_back),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: const Icon(Icons.list_alt, size: 24),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(lesson),
              const SizedBox(height: 16),
              _buildMetaCard(lesson),
              const SizedBox(height: 16),
              ...sections.map(_buildSectionCard),
              const SizedBox(height: 16),

              Row(
                children: [
                  if (canGoPrevious)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (!context.mounted) return;
                            _openLesson(
                              previousLesson!,
                              widget.lessonIndex - 1,
                            );
                          });
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                      ),
                    ),
                  if (canGoPrevious && canGoNext) const SizedBox(width: 12),
                  if (canGoNext)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          _markComplete();
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (!context.mounted) return;
                            _openLesson(nextLesson!, widget.lessonIndex + 1);
                          });
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LessonEntity lesson) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lesson ${widget.lessonIndex + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.description, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                lesson.duration,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'DOCUMENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(LessonEntity lesson) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Materi Pembelajaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.content.isNotEmpty
                ? lesson.content
                : 'Materi ini akan diisi dari backend. Untuk sementara, ini adalah teks dummy yang menjelaskan isi pembelajaran secara rapi dan terstruktur.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.8,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(DocumentSectionEntity section) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          ...section.paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                paragraph,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.8,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
          if (section.bullets.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...section.bullets.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<DocumentSectionEntity> _buildDummySections(String content) {
    return [
      DocumentSectionEntity(
        title: 'Ringkasan Materi',
        paragraphs: [
          content.isNotEmpty
              ? content
              : 'Materi utama akan diambil dari backend. Untuk saat ini, ini adalah dummy content sebagai contoh tampilan teks yang rapi.',
          'Bagian ini menjelaskan konsep inti pembelajaran secara singkat agar mudah dipahami sebelum masuk ke poin yang lebih detail.',
        ],
        bullets: const [],
      ),
      DocumentSectionEntity(
        title: 'Poin Penting',
        paragraphs: const [],
        bullets: const [
          'Pahami definisi dasar dan tujuan materi.',
          'Perhatikan alur penjelasan dari awal sampai akhir.',
          'Catat istilah penting yang muncul di dalam materi.',
        ],
      ),
      DocumentSectionEntity(
        title: 'Kesimpulan',
        paragraphs: const [
          'Setelah membaca materi ini, diharapkan Anda sudah memahami inti pembahasan dan siap lanjut ke lesson berikutnya.',
          'Jika ada yang belum jelas, gunakan ruang diskusi pada lesson video atau diskusi terpisah di backend nanti.',
        ],
        bullets: const [],
      ),
    ];
  }
}
