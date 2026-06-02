import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/quiz/quiz_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_navigation_mixin.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/quiz_intro_widget.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/quiz_questions_widget.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/quiz_result_widget.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_app_bar.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

/// Screen utama untuk Quiz Lesson - Dengan BLoC State Management
/// Bertanggung jawab untuk mengelola routing dan side effects,
/// sementara state management dihandle oleh QuizBloc
class QuizLessonDetailScreen extends StatefulWidget {
  final LessonEntity lesson;
  final CourseEntity course;
  final int lessonIndex;

  const QuizLessonDetailScreen({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<QuizLessonDetailScreen> createState() => _QuizLessonDetailScreenState();
}

class _QuizLessonDetailScreenState extends State<QuizLessonDetailScreen> with LessonNavigationMixin {
  late GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    // Trigger fetch quiz data via BLoC
    context.read<QuizBloc>().add(
      FetchQuizEvent(
        lessonId: widget.lesson.id,
        courseId: widget.course.id,
        courseTitle: widget.course.title,
        lessonTitle: widget.lesson.title,
      ),
    );
  }

  // === Helper Methods ===
  @override
  CourseEntity get currentCourse => widget.course;

  @override
  int get currentLessonIndex => widget.lessonIndex;


  void _backToCourse() {
    Navigator.pop(context);
    context.read<CourseBloc>().add(const RefreshCoursesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizBloc, QuizState>(
      listener: (context, state) {
        // Handle side effects - mark lesson complete jika lulus
        if (state is QuizSubmitted && state.result.passed) {
          context.read<LessonBloc>().add(
            MarkLessonCompleteEvent(lessonId: widget.lesson.id),
          );
          context.read<CourseBloc>().add(const RefreshCoursesEvent());
        }
      },
      child: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          final appBar = LessonAppBar(
            courseTitle: widget.course.title,
            subtitle: 'QUIZ',
            onBack: _backToCourse,
          );
          final quizBackground = _buildQuizBackground();

          // Show loading
          if (state is QuizLoading) {
            return Scaffold(
              backgroundColor: AppColors.quizBackgroundStart,
              appBar: appBar,
              body: Container(
                decoration: quizBackground,
                child: const Center(child: CircularProgressIndicator()),
              ),
            );
          }

          // Show error
          if (state is QuizError) {
            return Scaffold(
              backgroundColor: AppColors.quizBackgroundStart,
              appBar: LessonAppBar(
                courseTitle: widget.course.title,
                subtitle: 'QUIZ',
                onBack: _backToCourse,
              ),
              body: Container(
                decoration: quizBackground,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.pearl.withValues(alpha: 0.8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Kuis belum bisa dimuat',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.slate,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _backToCourse,
                            child: const Text('Kembali ke Kursus'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // Show result screen
          if (state is QuizSubmitted) {
            // final canProceed = state.result.passed && canGoNext;
            return _buildResultScreen(state);
          }

          // Show quiz (intro or questions)
          if (state is QuizLoaded) {
            if (!state.isStarted) {
              return _buildIntroScreen(state);
            } else {
              return _buildQuizScreen(state);
            }
          }

          // Initial state
          return Scaffold(
            backgroundColor: AppColors.quizBackgroundStart,
            appBar: appBar,
            body: Container(
              decoration: quizBackground,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }

  /// Build Quiz Introduction Screen
  Widget _buildIntroScreen(QuizLoaded quizState) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _backToCourse();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.quizBackgroundStart,
        appBar: LessonAppBar(
          courseTitle: widget.course.title,
          subtitle: 'QUIZ',
          onBack: _backToCourse,
          onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        drawer: LessonDrawer(
          course: widget.course,
          currentLessonIndex: widget.lessonIndex,
          onSelectLesson: (lesson, index) {
            Navigator.pop(context);
            navigateToLesson(lesson, index);
          },
        ),
        body: Stack(
          children: [
            _buildBackgroundDecorations(),
            Container(decoration: _buildQuizBackground()),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: QuizIntroWidget(
                key: const ValueKey('quiz_intro'),
                courseTitle: widget.course.title,
                lessonTitle: widget.lesson.title,
                lessonIndex: widget.lessonIndex,
                quiz: quizState.quiz,
                onStartQuiz: () {
                  context.read<QuizBloc>().add(const StartQuizEvent());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Quiz Questions Screen
  /// Build Quiz Questions Screen
  Widget _buildQuizScreen(QuizLoaded quizState) {
    // 1. Hitung jumlah soal yang sudah dijawab
    final int answeredCount = quizState.answers.length;
    final int totalCount = quizState.quiz.totalQuestions;
    final double progressPercent = totalCount > 0
        ? (answeredCount / totalCount)
        : 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Silakan selesaikan atau kirim jawaban kuis'),
            ),
          );
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.quizBackgroundStart,
        appBar: LessonAppBar(
          courseTitle: widget.course.title,
          subtitle: 'QUIZ',
          onBack: _backToCourse,
          onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        drawer: LessonDrawer(
          course: widget.course,
          currentLessonIndex: widget.lessonIndex,
          onSelectLesson: (lesson, index) {
            Navigator.pop(context);
            navigateToLesson(lesson, index);
          },
        ),
        bottomNavigationBar: _buildBottomActionBar(quizState),
        body: Stack(
          children: [
            _buildBackgroundDecorations(),
            Container(decoration: _buildQuizBackground()),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.red.withValues(alpha: 0.92),
                        AppColors.tomato.withValues(alpha: 0.92),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.red.withValues(alpha: 0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.quiz_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.lesson.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF8FAFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.pearl.withValues(alpha: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Timer display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Telah dijawab $answeredCount/$totalCount',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          _buildTimerDisplay(quizState.remainingSeconds),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 6,
                          backgroundColor: Colors.grey.withValues(alpha: 0.18),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.tomato,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: QuizQuestionsWidget(
                      key: ValueKey(
                        '${quizState.currentQuestionIndex}-${quizState.answers.length}',
                      ),
                      quiz: quizState.quiz,
                      currentQuestionIndex: quizState.currentQuestionIndex,
                      answers: quizState.answers,
                      showNavigationButtons: false,
                      onSelectAnswer: (selectedOptionIndex) {
                        context.read<QuizBloc>().add(
                          SelectAnswerEvent(
                            questionIndex: quizState.currentQuestionIndex,
                            selectedOptionIndex: selectedOptionIndex,
                          ),
                        );
                      },
                      onNextQuestion: () {
                        context.read<QuizBloc>().add(const NextQuestionEvent());
                      },
                      onPreviousQuestion: () {
                        context.read<QuizBloc>().add(
                          const PreviousQuestionEvent(),
                        );
                      },
                      onSubmitQuiz: () {
                        context.read<QuizBloc>().add(const SubmitQuizEvent());
                      },
                      onQuestionNavigate: (questionIndex) {
                        context.read<QuizBloc>().add(
                          GoToQuestionEvent(questionIndex: questionIndex),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(QuizLoaded quizState) {
    final isLastQuestion =
        quizState.currentQuestionIndex == quizState.quiz.questions.length - 1;

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
              child: PressScale(
                enabled: quizState.currentQuestionIndex > 0,
                child: OutlinedButton.icon(
                  onPressed: quizState.currentQuestionIndex > 0
                      ? () {
                          context.read<QuizBloc>().add(
                            const PreviousQuestionEvent(),
                          );
                        }
                      : null,
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
                enabled: isLastQuestion
                    ? (quizState.answers.length ==
                          quizState.quiz.questions.length)
                    : true,
                child: ElevatedButton.icon(
                  onPressed: isLastQuestion
                      ? (quizState.answers.length ==
                                quizState.quiz.questions.length
                            ? () => context.read<QuizBloc>().add(
                                const SubmitQuizEvent(),
                              )
                            : null)
                      : () {
                          context.read<QuizBloc>().add(
                            const NextQuestionEvent(),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    shadowColor: AppColors.red.withValues(alpha: 0.45),
                    elevation: 8,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: Icon(
                    isLastQuestion
                        ? Icons.check_circle_outline
                        : Icons.arrow_forward,
                  ),
                  label: Text(isLastQuestion ? 'Kirim Jawaban' : 'Selanjutnya'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Quiz Result Screen
  Widget _buildResultScreen(QuizSubmitted quizState) {
    final canProceed = quizState.result.passed && canGoNext;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: LessonAppBar(
        courseTitle: widget.course.title,
        subtitle: 'HASIL QUIZ',
        onBack: _backToCourse,
      ),
      body: Stack(
        children: [
          _buildBackgroundDecorations(),
          Container(decoration: _buildQuizBackground()),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: QuizResultWidget(
              key: const ValueKey('quiz_result'),
              courseTitle: widget.course.title,
              result: quizState.result,
              canGoNext: canProceed,
              onNextLesson: () {
                navigateToLesson(nextLesson!, widget.lessonIndex + 1);
              },
              onBackToCourse: _backToCourse,
            ),
          ),
        ],
      ),
      floatingActionButton: quizState.attempt != null
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push(
                  AppRoutes.quizResultDetail,
                  extra: quizState.attempt,
                );
              },
              icon: const Icon(Icons.remove_red_eye),
              label: const Text('Lihat Hasil'),
            )
          : null,
    );
  }

  /// Build timer display widget
  /// Shows time remaining in MM:SS format with color warnings
  Widget _buildTimerDisplay(int remainingSeconds) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString = '$minutes:${seconds.toString().padLeft(2, '0')}';

    // Determine color based on remaining time
    Color timerColor = Colors.green; // Normal
    if (remainingSeconds < 300) {
      // Less than 5 minutes
      timerColor = Colors.orange;
    }
    if (remainingSeconds < 60) {
      // Less than 1 minute
      timerColor = Colors.red;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: 14, color: timerColor),
        const SizedBox(width: 6),
        Text(
          timeString,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: timerColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -70,
          right: -55,
          child: Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.tomato.withValues(alpha: 0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -60,
          child: Container(
            width: 185,
            height: 185,
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

  BoxDecoration _buildQuizBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.quizBackgroundStart, AppColors.quizBackgroundEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }
}
