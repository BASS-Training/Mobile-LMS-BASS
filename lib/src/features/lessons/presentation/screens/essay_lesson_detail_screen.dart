import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_dummy_data.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/essay/essay_question_navigator_widget.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

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

class _EssayLessonDetailScreenState extends State<EssayLessonDetailScreen> {
  static const int _totalEssayQuestions = 5;
  static const int _minWordsPerQuestion = 10;

  late final TextEditingController _answerController;
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final List<String> _questions;
  final Map<int, String> _workingAnswers = {};
  final Map<int, String> _savedDraftAnswers = {};
  int _currentQuestionIndex = 0;
  bool _draftSaved = false;
  bool _isSubmitting = false;

  bool get canGoNext =>
      widget.lessonIndex < widget.course.allLessons.length - 1;
  bool get canGoPrevious => widget.lessonIndex > 0;

  LessonEntity? get nextLesson =>
      canGoNext ? widget.course.allLessons[widget.lessonIndex + 1] : null;
  LessonEntity? get previousLesson =>
      canGoPrevious ? widget.course.allLessons[widget.lessonIndex - 1] : null;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _answerController = TextEditingController();
    _questions = EssayDummyData.getQuestions(
      widget.lesson.id,
      widget.lesson.content,
    );

    final persistedDraft = LocalStorage.getEssayDraftAnswers(widget.lesson.id);
    _savedDraftAnswers.addAll(persistedDraft);
    _workingAnswers.addAll(persistedDraft);
    _answerController.text = _workingAnswers[_currentQuestionIndex] ?? '';
    _syncDraftBadgeState();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _openLesson(LessonEntity lesson, int lessonIndex) {
    final route = LessonRouteResolver.routeForType(lesson.type);
    context.push(
      route,
      extra: {
        'lesson': lesson,
        'course': widget.course,
        'lessonIndex': lessonIndex,
      },
    );
  }

  void _backToCourse() {
    Navigator.pop(context);
    context.read<CourseBloc>().add(const RefreshCoursesEvent());
  }

  void _saveDraft() {
    _persistCurrentAnswer();
    final answer = _workingAnswers[_currentQuestionIndex] ?? '';
    LocalStorage.saveEssayDraftAnswer(
      lessonId: widget.lesson.id,
      questionIndex: _currentQuestionIndex,
      answer: answer,
    );
    _savedDraftAnswers[_currentQuestionIndex] = answer;
    _syncDraftBadgeState();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Draft jawaban disimpan.')));
  }

  void _saveDraftAndNext() {
    _saveDraft();
    if (_currentQuestionIndex < _totalEssayQuestions - 1) {
      _goToQuestion(_currentQuestionIndex + 1);
    }
  }

  Future<void> _submitEssay() async {
    _persistCurrentAnswer();
    await LocalStorage.saveEssayDraftAnswers(
      lessonId: widget.lesson.id,
      answers: _workingAnswers,
    );
    _savedDraftAnswers
      ..clear()
      ..addAll(_workingAnswers);
    _syncDraftBadgeState();

    final validCount = _validQuestionIndexes.length;
    if (validCount < _totalEssayQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Masih ada nomor yang belum memenuhi minimal $_minWordsPerQuestion kata ($validCount/$_totalEssayQuestions).',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      context.read<LessonBloc>().add(
        MarkLessonCompleteEvent(lessonId: widget.lesson.id),
      );
      context.read<CourseBloc>().add(const RefreshCoursesEvent());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jawaban essay berhasil dikirim.')),
      );

      if (canGoNext && nextLesson != null) {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          _openLesson(nextLesson!, widget.lessonIndex + 1);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAnswer = _workingAnswers[_currentQuestionIndex] ?? '';
    final answeredChars = currentAnswer.trim().length;
    final currentWordCount = _countWords(currentAnswer);
    final savedCount = _savedQuestionIndexes.length;

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
          leading: GestureDetector(
            onTap: _backToCourse,
            child: const Icon(Icons.arrow_back),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6D5EF7), Color(0xFF4F8CFF)],
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
        body: SafeArea(
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
                          const Color(0xFF6D5EF7).withOpacity(0.16),
                          const Color(0xFF6D5EF7).withOpacity(0.0),
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
                          const Color(0xFF4F8CFF).withOpacity(0.12),
                          const Color(0xFF4F8CFF).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final useDesktopLayout = constraints.maxWidth >= 900;
                    final sidePanel = _buildSidePanel(
                      savedCount,
                      answeredChars,
                      currentWordCount,
                    );
                    final mainPanel = _buildEssayPanel(
                      savedCount,
                      answeredChars,
                      currentWordCount,
                    );

                    final header = _buildPageHeader();

                    if (!useDesktopLayout) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 190),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            header,
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
        ),
        bottomNavigationBar: _buildBottomActionBar(),
      ),
    );
  }

  Set<int> get _savedQuestionIndexes => _savedDraftAnswers.entries
      .where((entry) => entry.value.trim().isNotEmpty)
      .map((entry) => entry.key)
      .toSet();

  Set<int> get _validQuestionIndexes => _workingAnswers.entries
      .where((entry) => _countWords(entry.value) >= _minWordsPerQuestion)
      .map((entry) => entry.key)
      .toSet();

  bool get _isCurrentQuestionValid {
    final answer = _workingAnswers[_currentQuestionIndex] ?? '';
    return _countWords(answer) >= _minWordsPerQuestion;
  }

  int _countWords(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return 0;
    return normalized.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).length;
  }

  void _syncDraftBadgeState() {
    final working = (_workingAnswers[_currentQuestionIndex] ?? '').trim();
    final saved = (_savedDraftAnswers[_currentQuestionIndex] ?? '').trim();
    setState(() {
      _draftSaved = working == saved;
    });
  }

  void _persistCurrentAnswer() {
    _workingAnswers[_currentQuestionIndex] = _answerController.text;
  }

  void _goToQuestion(int index) {
    _persistCurrentAnswer();
    setState(() {
      _currentQuestionIndex = index;
      _answerController.text = _workingAnswers[_currentQuestionIndex] ?? '';
      _answerController.selection = TextSelection.fromPosition(
        TextPosition(offset: _answerController.text.length),
      );
    });
    _syncDraftBadgeState();
  }

  void _handlePreviousAction() {
    if (_currentQuestionIndex > 0) {
      _goToQuestion(_currentQuestionIndex - 1);
      return;
    }

    if (previousLesson == null) return;
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 200), () {
      _openLesson(previousLesson!, widget.lessonIndex - 1);
    });
  }

  Widget _buildBottomActionBar() {
    final canGoBackAction = _currentQuestionIndex > 0 || previousLesson != null;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border.withOpacity(0.9)),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: canGoBackAction ? _handlePreviousAction : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Sebelumnya'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.border.withOpacity(0.9),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentQuestionIndex < _totalEssayQuestions - 1
                        ? _saveDraftAndNext
                        : _saveDraft,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shadowColor: AppColors.primary.withOpacity(0.45),
                      elevation: 8,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      _currentQuestionIndex < _totalEssayQuestions - 1
                          ? 'Simpan & Lanjut'
                          : 'Simpan',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitEssay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  shadowColor: const Color(0xFF16A34A).withOpacity(0.45),
                  elevation: 10,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isSubmitting
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
                  _isSubmitting ? 'Mengirim...' : 'Kirim Semua Jawaban',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF6D5EF7), Color(0xFF4F8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5EF7).withOpacity(0.22),
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
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
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
                    color: Colors.white.withOpacity(0.92),
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

  Widget _buildSidePanel(
    int savedCount,
    int answeredChars,
    int currentWordCount,
  ) {
    final progress = _totalEssayQuestions > 0
        ? (savedCount / _totalEssayQuestions) * 100
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
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              backgroundColor: AppColors.border.withOpacity(0.7),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4F8CFF),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.toStringAsFixed(0)}% • Soal ${_currentQuestionIndex + 1} dari $_totalEssayQuestions',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
          const SizedBox(height: 4),
          Text(
            'Tersimpan: $savedCount/$_totalEssayQuestions',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
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
              _draftSaved
                  ? 'Draft jawaban sudah disimpan'
                  : 'Draft belum disimpan',
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Karakter: $answeredChars',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
          const SizedBox(height: 4),
          Text(
            'Kata: $currentWordCount',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildEssayPanel(
    int savedCount,
    int answeredChars,
    int currentWordCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFFDFDFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${_currentQuestionIndex + 1}',
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
                    'Pertanyaan ${_currentQuestionIndex + 1} dari $_totalEssayQuestions',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
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
              _questions[_currentQuestionIndex],
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Jawaban Anda',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _isCurrentQuestionValid
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isCurrentQuestionValid
                    ? Colors.green.shade200
                    : Colors.orange.shade200,
              ),
            ),
            child: Text(
              _isCurrentQuestionValid
                  ? 'Jawaban nomor ini valid (>= $_minWordsPerQuestion kata).'
                  : 'Minimal $_minWordsPerQuestion kata untuk menandai nomor ini selesai.',
              style: TextStyle(
                fontSize: 12,
                color: _isCurrentQuestionValid
                    ? Colors.green.shade800
                    : Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _answerController,
            minLines: 10,
            maxLines: 14,
            onChanged: (value) {
              _workingAnswers[_currentQuestionIndex] = value;
              setState(() {
                _draftSaved =
                    value.trim() ==
                    (_savedDraftAnswers[_currentQuestionIndex] ?? '').trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Tulis jawaban essay Anda di sini...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$currentWordCount kata (min $_minWordsPerQuestion) | $answeredChars karakter',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
              const Spacer(),
              Text(
                _draftSaved ? 'Draft tersimpan' : 'Belum disimpan',
                style: TextStyle(
                  fontSize: 11,
                  color: _draftSaved
                      ? AppColors.success
                      : AppColors.textLighter,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EssayQuestionNavigatorWidget(
            totalQuestions: _totalEssayQuestions,
            currentQuestionIndex: _currentQuestionIndex,
            completedQuestionIndexes: _savedQuestionIndexes,
            onQuestionSelected: _goToQuestion,
          ),
          const SizedBox(height: 8),
          Text(
            'Nomor tersimpan: $savedCount/$_totalEssayQuestions',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
