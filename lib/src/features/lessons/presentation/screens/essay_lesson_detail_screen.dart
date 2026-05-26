import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';

import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_navigation_mixin.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/question_navigator_widget.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

import '../bloc/essay/essay_bloc.dart';
import '../bloc/essay/essay_event.dart';
import '../bloc/essay/essay_state.dart';

class EssayLessonDetailScreen extends StatefulWidget {
  final LessonEntity lesson;
  final CourseEntity course;
  final int lessonIndex;

  const EssayLessonDetailScreen({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<EssayLessonDetailScreen> createState() =>
      _EssayLessonDetailScreenState();
}

class _EssayLessonDetailScreenState extends State<EssayLessonDetailScreen>
    with LessonNavigationMixin {
  late final TextEditingController _answerController;
  late final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _answerController = TextEditingController();

    // Tembak event inisialisasi
    context.read<EssayBloc>().add(
      LoadEssay(
        lessonId: widget.lesson.id,
        courseId: widget.course.id,
        courseTitle: widget.course.title,
        lessonTitle: widget.lesson.title,
        content: widget.lesson.content,
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _backToCourse() {
    Navigator.pop(context);
    context.read<CourseBloc>().add(const RefreshCoursesEvent());
  }

  @override
  CourseEntity get currentCourse => widget.course;

  @override
  int get currentLessonIndex => widget.lessonIndex;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _backToCourse();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF6F8FF),
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        body: BlocConsumer<EssayBloc, EssayState>(
          listenWhen: (previous, current) {
            // Sinkronisasi controller text jika index soal berubah
            if (previous.currentQuestionIndex != current.currentQuestionIndex) {
              _answerController.text = current.currentAnswer;
            }
            return true; // selalu listen untuk event lain
          },
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              context.read<EssayBloc>().add(ClearSnackbarMessage());
            }
            if (state.snackbarMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.snackbarMessage!)));
              context.read<EssayBloc>().add(ClearSnackbarMessage());
            }
            if (state.isSuccess) {
              context.read<LessonBloc>().add(
                MarkLessonCompleteEvent(lessonId: widget.lesson.id),
              );
              context.read<CourseBloc>().add(const RefreshCoursesEvent());

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jawaban essay berhasil dikirim.'),
                ),
              );

              if (state.lastAttempt != null) {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 200), () {
                  context.push(
                    AppRoutes.essayResultDetail,
                    extra: state.lastAttempt,
                  );
                });
                return;
              }

              if (canGoNext && nextLesson != null) {
                Navigator.pop(context);
                Future.delayed(
                  const Duration(milliseconds: 200),
                  () => navigateToLesson(nextLesson!, widget.lessonIndex + 1),
                );
              }
            }
          },
          builder: (context, state) {
            // Pastikan controller sinkron di awal render
            if (_answerController.text != state.currentAnswer &&
                _answerController.text.isEmpty) {
              _answerController.text = state.currentAnswer;
            }

            return SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF8FAFF), Color(0xFFF1F4FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    _buildBackgroundDecorations(),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final useDesktopLayout = constraints.maxWidth >= 900;
                        final sidePanel = _buildSidePanel(state);
                        final mainPanel = _buildEssayPanel(state);
                        final header = _buildPageHeader();

                        if (!useDesktopLayout) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 190),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                header,
                                const SizedBox(height: 14),
                                _buildDescriptionCard(),
                                const SizedBox(height: 14),
                                sidePanel,
                                const SizedBox(height: 14),
                                mainPanel,
                              ],
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 190),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              header,
                              const SizedBox(height: 14),
                              _buildDescriptionCard(),
                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: sidePanel),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 8, child: mainPanel),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<EssayBloc, EssayState>(
          builder: (context, state) => _buildBottomActionBar(state),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.course.title),
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: _backToCourse,
        child: const Icon(Icons.arrow_back),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.red, AppColors.tomato],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
    );
  }

  Widget _buildDrawer() {
    return LessonDrawer(
      course: widget.course,
      currentLessonIndex: widget.lessonIndex,
      onSelectLesson: (lesson, index) {
        final route = LessonRouteResolver.routeForType(lesson.type);
        Navigator.pop(context);
        context.push(
          route,
          extra: {
            'lesson': lesson,
            'course': widget.course,
            'lessonIndex': index,
          },
        );
      },
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.tomato.withValues(alpha: 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -70,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.red.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [AppColors.red, AppColors.tomato],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Latihan Essay Interaktif',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Simpan jawaban per nomor, lanjutkan kapan saja, dan kirim kalau semua sudah siap.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    final description = widget.lesson.content.trim();

    return FadeSlideIn(
      delayMs: 50,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF9FAFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: AppColors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deskripsi Lesson',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description.isNotEmpty
                        ? description
                        : 'Tidak ada deskripsi tambahan untuk lesson ini.',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.slate,
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

  Widget _buildSidePanel(EssayState state) {
    final progress = state.totalQuestions > 0
        ? (state.savedCount / state.totalQuestions) * 100
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Essay',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              backgroundColor: AppColors.pearl.withValues(alpha: 0.7),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tomato),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.toStringAsFixed(0)}% • Soal ${state.currentQuestionIndex + 1} dari ${state.totalQuestions}',
            style: const TextStyle(fontSize: 12, color: AppColors.slate),
          ),
          const SizedBox(height: 4),
          Text(
            'Tersimpan: ${state.savedCount}/${state.totalQuestions}',
            style: const TextStyle(fontSize: 12, color: AppColors.slate),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              state.isDraftSaved
                  ? 'Draft jawaban sudah disimpan'
                  : 'Draft belum disimpan',
              style: const TextStyle(fontSize: 12, color: AppColors.slate),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Karakter: ${state.currentAnswer.length}',
            style: const TextStyle(fontSize: 12, color: AppColors.slate),
          ),
          const SizedBox(height: 4),
          Text(
            'Kata: ${state.currentWordCount}',
            style: const TextStyle(fontSize: 12, color: AppColors.slate),
          ),
        ],
      ),
    );
  }

  Widget _buildEssayPanel(EssayState state) {
    if (state.questions.isEmpty)
      return const Center(child: CircularProgressIndicator());

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFFDFDFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF2F0FF), Color(0xFFEAF1FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${state.currentQuestionIndex + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.currentQuestion,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEEF2FF), Color(0xFFF7F9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDE3FF)),
            ),
            child: Text(
              state.currentQuestion,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (state.isSubmitted) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Jawaban sudah dikumpulkan. Kamu tidak bisa mengirim ulang.',
                      style: TextStyle(fontSize: 12.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'Jawaban Anda',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: state.isCurrentQuestionValid
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: state.isCurrentQuestionValid
                    ? Colors.green.shade200
                    : Colors.orange.shade200,
              ),
            ),
            child: Text(
              state.isCurrentQuestionValid
                  ? 'Jawaban nomor ini valid (>= 10 kata).'
                  : 'Minimal 10 kata untuk menandai nomor ini selesai.',
              style: TextStyle(
                fontSize: 12,
                color: state.isCurrentQuestionValid
                    ? Colors.green.shade800
                    : Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            enabled: !state.isSubmitted,
            controller: _answerController,
            minLines: 10,
            maxLines: 14,
            onChanged: (value) =>
                context.read<EssayBloc>().add(AnswerChanged(value)),
            decoration: InputDecoration(
              hintText: 'Tulis jawaban essay Anda di sini...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.pearl),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.pearl),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.red, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${state.currentWordCount} kata (min 10) | ${state.currentAnswer.length} karakter',
                style: const TextStyle(fontSize: 11, color: AppColors.slate),
              ),
              const Spacer(),
              Text(
                state.isDraftSaved ? 'Draft tersimpan' : 'Belum disimpan',
                style: TextStyle(
                  fontSize: 11,
                  color: state.isDraftSaved
                      ? AppColors.emerald
                      : AppColors.silver,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          QuestionNavigatorWidget(
            totalQuestions: state.totalQuestions,
            currentQuestionIndex: state.currentQuestionIndex,
            completedQuestionIndexes: state.savedQuestionIndexes,
            onQuestionSelected: (index) =>
                context.read<EssayBloc>().add(ChangeQuestion(index)),
            completedLabel: 'Sudah disimpan',
            pendingLabel: 'Belum disimpan',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(EssayState state) {
    final canGoBackAction =
        state.currentQuestionIndex > 0 || previousLesson != null;

    void handlePreviousAction() {
      if (state.currentQuestionIndex > 0) {
        context.read<EssayBloc>().add(
          ChangeQuestion(state.currentQuestionIndex - 1),
        );
      } else if (previousLesson != null) {
        Navigator.pop(context);
        Future.delayed(
          const Duration(milliseconds: 200),
          () => navigateToLesson(previousLesson!, widget.lessonIndex - 1),
        );
      }
    }

    void handleSaveAndNext() {
      context.read<EssayBloc>().add(SaveDraftClicked());
      if (state.currentQuestionIndex < state.totalQuestions - 1) {
        context.read<EssayBloc>().add(
          ChangeQuestion(state.currentQuestionIndex + 1),
        );
      }
    }

    void handleContinueAfterSubmit() {
      if (canGoNext && nextLesson != null) {
        Navigator.pop(context);
        Future.delayed(
          const Duration(milliseconds: 200),
          () => navigateToLesson(nextLesson!, widget.lessonIndex + 1),
        );
      } else {
        _backToCourse();
      }
    }

    if (state.isSubmitted) {
      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.pearl.withValues(alpha: 0.9)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, -8),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _backToCourse,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: handleContinueAfterSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(canGoNext ? 'Lanjut' : 'Selesai'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.pearl.withValues(alpha: 0.9)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 22,
              offset: const Offset(0, -8),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.pearl,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: PressScale(
                    enabled: canGoBackAction,
                    child: OutlinedButton.icon(
                      onPressed: canGoBackAction ? handlePreviousAction : null,
                      icon: const Icon(Icons.arrow_back),
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
                Expanded(
                  child: PressScale(
                    child: ElevatedButton.icon(
                      onPressed: handleSaveAndNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shadowColor: AppColors.red.withValues(alpha: 0.45),
                        elevation: 8,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        state.currentQuestionIndex < state.totalQuestions - 1
                            ? 'Simpan & Lanjut'
                            : 'Simpan',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: PressScale(
                enabled: !state.isSubmitting,
                child: ElevatedButton.icon(
                  onPressed: state.isSubmitting
                      ? null
                      : () =>
                            context.read<EssayBloc>().add(SubmitEssayClicked()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    shadowColor: const Color(
                      0xFF16A34A,
                    ).withValues(alpha: 0.45),
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: state.isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    state.isSubmitting ? 'Mengirim...' : 'Kirim Semua Jawaban',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
