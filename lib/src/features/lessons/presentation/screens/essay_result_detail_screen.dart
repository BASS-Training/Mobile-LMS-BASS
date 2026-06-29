import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';
import 'package:lms_mobile_app/src/shared/utils/app_date_formatter.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';

class EssayResultDetailScreen extends StatefulWidget {
  final LessonAttempt attempt;

  const EssayResultDetailScreen({super.key, required this.attempt});

  @override
  State<EssayResultDetailScreen> createState() =>
      _EssayResultDetailScreenState();
}

class _EssayResultDetailScreenState extends State<EssayResultDetailScreen> {
  late Future<List<LessonAttempt>> _attemptsFuture;
  late LessonAttempt _selectedAttempt;

  @override
  void initState() {
    super.initState();
    _selectedAttempt = widget.attempt;
    _attemptsFuture = GetIt.instance<LessonResultRepository>()
        .getAttemptsByLesson(
          courseId: widget.attempt.courseId,
          lessonId: widget.attempt.lessonId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Detail Hasil Essay'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<LessonAttempt>>(
          future: _attemptsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final attempts = snapshot.data ?? <LessonAttempt>[];
            if (attempts.isNotEmpty) {
              _selectedAttempt = attempts.firstWhere(
                (attempt) => attempt.id == _selectedAttempt.id,
                orElse: () => attempts.first,
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(child: _buildHeroCard(_selectedAttempt)),
                  const SizedBox(height: 16),
                  if (attempts.length > 1)
                    FadeSlideIn(
                      delayMs: 60,
                      child: _buildHistoryChips(attempts),
                    ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delayMs: 100,
                    child: _buildSummaryCards(_selectedAttempt),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delayMs: 130,
                    child: _buildOverviewBanner(_selectedAttempt),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pertanyaan dan Jawaban',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._selectedAttempt.questions.map(_buildQuestionItem),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(LessonAttempt attempt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF79E5A9), Color(0xFF8ED8F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.edit_note_rounded, color: Colors.white, size: 54),
          const SizedBox(height: 10),
          const Text(
            'Essay Telah Dikumpulkan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${attempt.lessonTitle} • ${attempt.attemptLabel}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChips(List<LessonAttempt> attempts) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attempts.length,
        separatorBuilder: (context, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final attempt = attempts[index];
          final isSelected = attempt.id == _selectedAttempt.id;
          return ChoiceChip(
            selected: isSelected,
            label: Text(attempt.attemptLabel),
            onSelected: (_) {
              setState(() {
                _selectedAttempt = attempt;
              });
            },
            selectedColor: AppColors.red.withValues(alpha: 0.16),
            labelStyle: TextStyle(
              color: isSelected ? AppColors.red : AppColors.slate,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(LessonAttempt attempt) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Status',
            attempt.graded ? 'Dinilai' : 'Menunggu',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Nomor', attempt.attemptLabel)),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Waktu',
            formatAppDateTime(attempt.submittedAt),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.slate)),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewBanner(LessonAttempt attempt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Essay ini sudah dikerjakan pada ${formatAppDateTime(attempt.submittedAt)} dan menunggu penilaian manual.',
              style: TextStyle(
                color: Colors.green[800],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(LessonAttemptQuestionSnapshot question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soal ${question.questionIndex + 1}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.red,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.questionText,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.pearl),
            ),
            child: Text(
              question.writtenAnswer?.trim().isNotEmpty == true
                  ? question.writtenAnswer!.trim()
                  : 'Belum ada jawaban tersimpan',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
