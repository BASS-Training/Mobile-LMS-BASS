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
    context.read<QuizBloc>().add(FetchQuizEvent(lessonId: widget.lesson.id));
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
              backgroundColor: AppColors.background,
              appBar: AppBar(title: Text(widget.course.title), elevation: 0),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          // Show error
          if (state is QuizError) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: Text(widget.course.title),
                elevation: 0,
                leading: GestureDetector(
                  onTap: _backToCourse,
                  child: const Icon(Icons.arrow_back),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _backToCourse,
                      child: const Text('Kembali ke Kursus'),
                    ),
                  ],
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
            backgroundColor: AppColors.background,
            appBar: AppBar(title: Text(widget.course.title), elevation: 0),
            body: const Center(child: CircularProgressIndicator()),
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.course.title),
          elevation: 0,
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
        body: QuizIntroWidget(
          courseTitle: widget.course.title,
          lessonTitle: widget.lesson.title,
          lessonIndex: widget.lessonIndex,
          quiz: quizState.quiz,
          onStartQuiz: () {
            // Trigger start quiz via BLoC
            context.read<QuizBloc>().add(const StartQuizEvent());
          },
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('${widget.course.title} - Kuis'),
          elevation: 0,
          // Hapus text 1/10 dari AppBar karena sudah diganti dengan progress bar di bawah
          actions: const [],
        ),
        body: Column(
          children: [
            // === PROGRESS BAR SECTION ===
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Teks Keterangan
                  Text(
                    'Telah dijawab $answeredCount/$totalCount',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 6,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // === QUIZ QUESTIONS WIDGET ===
            Expanded(
              child: QuizQuestionsWidget(
                quiz: quizState.quiz,
                currentQuestionIndex: quizState.currentQuestionIndex,
                answers: quizState.answers,
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
                  context.read<QuizBloc>().add(const PreviousQuestionEvent());
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
          ],
        ),
      ),
    );
  }

  /// Build Quiz Result Screen
  Widget _buildResultScreen(QuizSubmitted quizState) {
    final canProceed = quizState.result.passed && canGoNext;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.course.title),
        elevation: 0,
        leading: GestureDetector(
          onTap: _backToCourse,
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: QuizResultWidget(
        courseTitle: widget.course.title,
        result: quizState.result,
        canGoNext: canProceed,
        onNextLesson: () {
          _openLesson(nextLesson!, widget.lessonIndex + 1);
        },
        onBackToCourse: _backToCourse,
      ),
    );
  }
}
