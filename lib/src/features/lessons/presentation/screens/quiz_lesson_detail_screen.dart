import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/quiz_intro_widget.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/quiz_questions_widget.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/quiz_result_widget.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Screen utama untuk Quiz Lesson
/// Bertanggung jawab untuk mengelola state dan logic quiz,
/// sementara UI dihandle oleh widget-widget terpisah
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
  // Quiz data
  late final Quiz _quiz;

  // State management
  bool _isStarted = false;
  int _currentQuestionIndex = 0;
  Map<int, int> _answers = {}; // key: questionIndex, value: selectedOptionIndex
  QuizResult? _result;
  late GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    // Inisialisasi quiz dengan data (saat ini dummy, bisa diganti dari API)
    _quiz = Quiz.getDummyQuiz();
  }

  // === State Management Methods ===

  void _startQuiz() {
    setState(() => _isStarted = true);
  }

  void _selectAnswer(int selectedOptionIndex) {
    setState(() => _answers[_currentQuestionIndex] = selectedOptionIndex);
  }

  void _goToQuestion(int questionIndex) {
    setState(() => _currentQuestionIndex = questionIndex);
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quiz.questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  void _submitQuiz() {
    int score = 0;
    for (int i = 0; i < _quiz.questions.length; i++) {
      if (_answers[i] == _quiz.questions[i].correctIndex) {
        score++;
      }
    }

    final result = QuizResult(score: score, total: _quiz.questions.length);

    setState(() {
      _result = result;
    });

    // Mark lesson as complete HANYA jika lulus
    if (result.passed) {
      context.read<LessonBloc>().add(
        MarkLessonCompleteEvent(lessonId: widget.lesson.id),
      );
      context.read<CourseBloc>().add(const RefreshCoursesEvent());
    }
  }

  void _openLesson(LessonEntity lesson, int lessonIndex) {
    final type = lesson.type.toLowerCase();
    final route = type == 'video'
        ? AppRoutes.videoLessonDetail
        : (type == 'quiz'
              ? AppRoutes.quizLessonDetail
              : AppRoutes.documentLessonDetail);

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

  // === Getters ===

  bool get canGoNext =>
      widget.lessonIndex < widget.course.allLessons.length - 1;
  bool get canGoPrevious => widget.lessonIndex > 0;

  LessonEntity? get nextLesson =>
      canGoNext ? widget.course.allLessons[widget.lessonIndex + 1] : null;
  LessonEntity? get previousLesson =>
      canGoPrevious ? widget.course.allLessons[widget.lessonIndex - 1] : null;

  @override
  Widget build(BuildContext context) {
    // Show result screen if quiz is completed
    if (_result != null) {
      return _buildResultScreen();
    }

    // Show quiz intro if not started
    if (!_isStarted) {
      return _buildIntroScreen();
    }

    // Show quiz questions
    return _buildQuizScreen();
  }

  /// Build Quiz Introduction Screen
  Widget _buildIntroScreen() {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        context.read<CourseBloc>().add(const RefreshCoursesEvent());
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
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
        drawer: LessonDrawer(
          course: widget.course,
          currentLessonIndex: widget.lessonIndex,
          onSelectLesson: (lesson, index) {
            final type = lesson.type.toLowerCase();
            final route = type == 'video'
                ? AppRoutes.videoLessonDetail
                : (type == 'quiz'
                      ? AppRoutes.quizLessonDetail
                      : AppRoutes.documentLessonDetail);
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
          quiz: _quiz,
          onStartQuiz: _startQuiz,
        ),
      ),
    );
  }

  /// Build Quiz Questions Screen
  Widget _buildQuizScreen() {
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentQuestionIndex + 1}/${_quiz.questions.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: QuizQuestionsWidget(
          quiz: _quiz,
          currentQuestionIndex: _currentQuestionIndex,
          answers: _answers,
          onSelectAnswer: _selectAnswer,
          onNextQuestion: _nextQuestion,
          onPreviousQuestion: _previousQuestion,
          onSubmitQuiz: _submitQuiz,
          onQuestionNavigate: _goToQuestion,
        ),
      ),
    );
  }

  /// Build Quiz Result Screen
  Widget _buildResultScreen() {
    final passed = _result!.passed;
    final canProceed = passed && canGoNext;

    return Scaffold(
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
      ),
      body: QuizResultWidget(
        courseTitle: widget.course.title,
        result: _result!,
        canGoNext: canProceed,
        onNextLesson: () {
          _openLesson(nextLesson!, widget.lessonIndex + 1);
        },
        onBackToCourse: () {
          Navigator.pop(context);
          context.read<CourseBloc>().add(const RefreshCoursesEvent());
        },
      ),
    );
  }
}
