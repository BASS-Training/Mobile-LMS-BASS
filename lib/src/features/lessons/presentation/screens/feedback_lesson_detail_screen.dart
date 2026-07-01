import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_actions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/feedback_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/feedback/feedback_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/feedback/feedback_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/feedback/feedback_state.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_navigation_mixin.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_app_bar.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_navigation_bar.dart';

/// Konten tipe `feedback`: form survei ala Google Form, tanpa penilaian.
class FeedbackLessonDetailScreen extends StatefulWidget {
  final LessonEntity lesson;
  final CourseEntity course;
  final int lessonIndex;

  const FeedbackLessonDetailScreen({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<FeedbackLessonDetailScreen> createState() =>
      _FeedbackLessonDetailScreenState();
}

class _FeedbackLessonDetailScreenState
    extends State<FeedbackLessonDetailScreen>
    with LessonNavigationMixin {
  static const Color _accent = Color(0xFF4AA8FF);

  @override
  CourseEntity get currentCourse => widget.course;

  @override
  int get currentLessonIndex => widget.lessonIndex;

  final Map<String, int> _ratings = {};
  final Map<String, TextEditingController> _texts = {};
  final Map<String, String?> _single = {};
  final Map<String, Set<String>> _multi = {};
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    context.read<FeedbackBloc>().add(LoadFeedback(widget.lesson.id));
  }

  @override
  void dispose() {
    for (final c in _texts.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _backToCourse() {
    popToCourse(context);
  }

  void _prefill(FeedbackEntity data) {
    if (_prefilled) return;
    _prefilled = true;
    final answers = data.submission?.answers ?? const {};
    for (final q in data.questions) {
      final a = answers[q.id];
      if (q.isRating) {
        if (a?.rating != null) _ratings[q.id] = a!.rating!;
      } else if (q.isText) {
        _texts[q.id] = TextEditingController(text: a?.text ?? '');
      } else if (q.isSingleChoice) {
        _single[q.id] = a?.choice.isNotEmpty == true ? a!.choice.first : null;
      } else if (q.isMultiChoice) {
        _multi[q.id] = {...(a?.choice ?? const [])};
      }
    }
  }

  bool _isAnswered(FeedbackQuestionEntity q) {
    if (q.isRating) return _ratings[q.id] != null;
    if (q.isText) return (_texts[q.id]?.text.trim().isNotEmpty) ?? false;
    if (q.isSingleChoice) return _single[q.id] != null;
    if (q.isMultiChoice) return (_multi[q.id]?.isNotEmpty) ?? false;
    return false;
  }

  Map<String, dynamic> _buildAnswers(FeedbackEntity data) {
    final answers = <String, dynamic>{};
    for (final q in data.questions) {
      if (q.isRating && _ratings[q.id] != null) {
        answers[q.id] = _ratings[q.id];
      } else if (q.isText) {
        final t = _texts[q.id]?.text.trim() ?? '';
        if (t.isNotEmpty) answers[q.id] = t;
      } else if (q.isSingleChoice && _single[q.id] != null) {
        answers[q.id] = _single[q.id];
      } else if (q.isMultiChoice && (_multi[q.id]?.isNotEmpty ?? false)) {
        answers[q.id] = _multi[q.id]!.toList();
      }
    }
    return answers;
  }

  void _submit(FeedbackEntity data) {
    final missing = data.questions
        .where((q) => q.isRequired && !_isAnswered(q))
        .toList();
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Masih ada ${missing.length} pertanyaan wajib yang belum diisi.',
          ),
          backgroundColor: AppColors.brandPrimary,
        ),
      );
      return;
    }
    context.read<FeedbackBloc>().add(
      SubmitFeedback(lessonId: widget.lesson.id, answers: _buildAnswers(data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LessonAppBar(
        courseTitle: widget.course.title,
        subtitle: 'FEEDBACK',
        onBack: _backToCourse,
      ),
      bottomNavigationBar: BlocBuilder<FeedbackBloc, FeedbackState>(
        builder: (context, state) {
          final submitted = state.data?.submission?.isSubmitted ?? false;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: AppShadows.sm,
                ),
                child: Row(
                  children: [
                    if (canGoPrevious) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => navigateToLesson(
                            previousLesson!,
                            widget.lessonIndex - 1,
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Sebelumnya'),
                          style: LessonNavigationBar.previousButtonStyle(),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        // Next baru aktif setelah feedback dikirim. Sebelum itu
                        // peserta hanya bisa "Sebelumnya".
                        onPressed: submitted
                            ? () {
                                if (canGoNext && nextLesson != null) {
                                  navigateToLesson(
                                    nextLesson!,
                                    widget.lessonIndex + 1,
                                  );
                                } else {
                                  _backToCourse();
                                }
                              }
                            : null,
                        icon: Icon(
                          canGoNext
                              ? Icons.arrow_forward_rounded
                              : Icons.check_rounded,
                        ),
                        label: Text(canGoNext ? 'Lanjut' : 'Selesai'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.surfaceMuted,
                          disabledForegroundColor: AppColors.textTertiary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      body: BlocConsumer<FeedbackBloc, FeedbackState>(
        listenWhen: (prev, curr) =>
            prev.data != curr.data ||
            prev.errorMessage != curr.errorMessage ||
            prev.infoMessage != curr.infoMessage,
        listener: (context, state) {
          if (state.data != null) _prefill(state.data!);
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.brandPrimary,
              ),
            );
            context.read<FeedbackBloc>().add(const ClearFeedbackMessage());
          } else if (state.infoMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.infoMessage!),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<FeedbackBloc>().add(const ClearFeedbackMessage());
          }
        },
        builder: (context, state) {
          if (state.status == FeedbackStatus.loading ||
              state.status == FeedbackStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == FeedbackStatus.error || state.data == null) {
            return _ErrorView(
              message: state.errorMessage ?? 'Gagal memuat form.',
              onRetry: () => context.read<FeedbackBloc>().add(
                LoadFeedback(widget.lesson.id),
              ),
            );
          }
          return _buildForm(state, state.data!);
        },
      ),
    );
  }

  Widget _buildForm(FeedbackState state, FeedbackEntity data) {
    final submitted = data.submission?.isSubmitted ?? false;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          if (data.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              data.description,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (data.isAnonymous) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 15,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Tanggapan anonim — instruktur hanya melihat hasil agregat.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (submitted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tanggapan Anda sudah terkirim. Anda masih bisa mengubahnya.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          for (var i = 0; i < data.questions.length; i++)
            _QuestionCard(
              index: i + 1,
              question: data.questions[i],
              accent: _accent,
              ratingValue: _ratings[data.questions[i].id],
              onRating: (v) =>
                  setState(() => _ratings[data.questions[i].id] = v),
              textController: _texts[data.questions[i].id],
              singleValue: _single[data.questions[i].id],
              onSingle: (v) =>
                  setState(() => _single[data.questions[i].id] = v),
              multiValues: _multi[data.questions[i].id] ?? <String>{},
              onMultiToggle: (id, on) => setState(() {
                final set = _multi.putIfAbsent(
                  data.questions[i].id,
                  () => <String>{},
                );
                on ? set.add(id) : set.remove(id);
              }),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.submitting ? null : () => _submit(data),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: state.submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(submitted ? 'Perbarui Tanggapan' : 'Kirim Tanggapan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final FeedbackQuestionEntity question;
  final Color accent;
  final int? ratingValue;
  final ValueChanged<int> onRating;
  final TextEditingController? textController;
  final String? singleValue;
  final ValueChanged<String?> onSingle;
  final Set<String> multiValues;
  final void Function(String id, bool on) onMultiToggle;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.accent,
    required this.ratingValue,
    required this.onRating,
    required this.textController,
    required this.singleValue,
    required this.onSingle,
    required this.multiValues,
    required this.onMultiToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              children: [
                TextSpan(text: '$index. ${question.question}'),
                if (question.isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.brandText),
                  ),
              ],
            ),
          ),
          if (question.helpText?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(
              question.helpText!,
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
          const SizedBox(height: 12),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    if (question.isRating) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 1; i <= question.ratingMax; i++)
                IconButton(
                  onPressed: () => onRating(i),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.star_rounded,
                    size: 34,
                    color: (ratingValue ?? 0) >= i
                        ? const Color(0xFFFFC23D)
                        : AppColors.borderDefault,
                  ),
                ),
              const SizedBox(width: 8),
              if (ratingValue != null)
                Text(
                  '$ratingValue / ${question.ratingMax}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          if (question.minLabel != null || question.maxLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    question.minLabel ?? '',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    question.maxLabel ?? '',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    if (question.isSingleChoice) {
      return RadioGroup<String>(
        groupValue: singleValue,
        onChanged: onSingle,
        child: Column(
          children: [
            for (final opt in question.options)
              RadioListTile<String>(
                value: opt.id,
                title: Text(opt.label, style: const TextStyle(fontSize: 13.5)),
                activeColor: accent,
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      );
    }

    if (question.isMultiChoice) {
      return Column(
        children: [
          for (final opt in question.options)
            CheckboxListTile(
              value: multiValues.contains(opt.id),
              onChanged: (on) => onMultiToggle(opt.id, on ?? false),
              title: Text(opt.label, style: const TextStyle(fontSize: 13.5)),
              activeColor: accent,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: VisualDensity.compact,
            ),
        ],
      );
    }

    // text
    return TextField(
      controller: textController,
      maxLines: 4,
      minLines: 2,
      decoration: InputDecoration(
        hintText: 'Tulis jawaban Anda...',
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}
