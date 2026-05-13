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
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/quiz_intro_widget.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/quiz_questions_widget.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/quiz_result_widget.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';

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

class _QuizLessonDetailScreenState extends State<QuizLessonDetailScreen> {
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

  void _openLesson(LessonEntity lesson, int lessonIndex) {
    final route = LessonRouteResolver.routeForType(lesson.type);

    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 200), () {
      context.push(
        route,
        extra: {
          'lesson': lesson,
          'course': widget.course,
          'lessonIndex': lessonIndex,
        },
      );
    });
  }

  void _backToCourse() {
    Navigator.pop(context);
    context.read<CourseBloc>().add(const RefreshCoursesEvent());
  }

  // === Getters ===

  bool get canGoNext =>
      widget.lessonIndex < widget.course.allLessons.length - 1;

  LessonEntity? get nextLesson =>
      canGoNext ? widget.course.allLessons[widget.lessonIndex + 1] : null;

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
          // Show loading
          if (state is QuizLoading) {
            return Scaffold(
              backgroundColor: const Color(0xFFF6F8FF),
              appBar: AppBar(
                title: Text(widget.course.title),
                elevation: 0,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6D5EF7), Color(0xFF4F8CFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF8FAFF), Color(0xFFF1F4FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
            );
          }

          // Show error
          if (state is QuizError) {
            return Scaffold(
              backgroundColor: const Color(0xFFF6F8FF),
              appBar: AppBar(
                title: Text(widget.course.title),
                elevation: 0,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6D5EF7), Color(0xFF4F8CFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                leading: GestureDetector(
                  onTap: _backToCourse,
                  child: const Icon(Icons.arrow_back),
                ),
              ),
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF8FAFF), Color(0xFFF1F4FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.pearl.withOpacity(0.8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
            final canProceed = state.result.passed && canGoNext;
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
            backgroundColor: const Color(0xFFF6F8FF),
            appBar: AppBar(
              title: Text(widget.course.title),
              elevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6D5EF7), Color(0xFF4F8CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF8FAFF), Color(0xFFF1F4FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }

  /// Build Quiz Introduction Screen
  Widget _buildIntroScreen(QuizLoaded quizState) {
    return WillPopScope(
      onWillPop: () async {
        _backToCourse();
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF6F8FF),
        appBar: AppBar(
          title: Text(widget.course.title),
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6D5EF7), Color(0xFF4F8CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: GestureDetector(
            onTap: _backToCourse,
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
        drawer: LessonDrawer(
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
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8FAFF), Color(0xFFF1F4FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AnimatedSwitcher(
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

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan selesaikan atau kirim jawaban kuis'),
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FF),
        appBar: AppBar(
          title: Text('${widget.course.title} - Kuis'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6D5EF7), Color(0xFF4F8CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: const [],
        ),
        bottomNavigationBar: _buildBottomActionBar(quizState),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8FAFF), Color(0xFFF1F4FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
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
                  border: Border.all(color: AppColors.pearl.withOpacity(0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Telah dijawab $answeredCount/$totalCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 6,
                        backgroundColor: Colors.grey.withOpacity(0.18),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4F8CFF),
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
            top: BorderSide(color: AppColors.pearl.withOpacity(0.9)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
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
                  side: BorderSide(color: AppColors.pearl.withOpacity(0.9)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.charcoal,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isLastQuestion
                    ? (quizState.answers.length ==
                              quizState.quiz.questions.length
                          ? () => context.read<QuizBloc>().add(
                              const SubmitQuizEvent(),
                            )
                          : null)
                    : () {
                        context.read<QuizBloc>().add(const NextQuestionEvent());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet,
                  shadowColor: AppColors.violet.withOpacity(0.45),
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
      appBar: AppBar(
        title: Text(widget.course.title),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6D5EF7), Color(0xFF4F8CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: GestureDetector(
          onTap: _backToCourse,
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFF1F4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: QuizResultWidget(
            key: const ValueKey('quiz_result'),
            courseTitle: widget.course.title,
            result: quizState.result,
            canGoNext: canProceed,
            onNextLesson: () {
              _openLesson(nextLesson!, widget.lessonIndex + 1);
            },
            onBackToCourse: _backToCourse,
          ),
        ),
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
}
