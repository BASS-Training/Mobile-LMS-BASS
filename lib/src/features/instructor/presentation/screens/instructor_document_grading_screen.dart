import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/document_grading_cubit.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_submission_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/document_submission_repository.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Layar penilaian pengumpulan dokumen (instruktur/admin). Menampilkan riwayat
/// attempt peserta + form Lulus/Belum lulus (+ nilai & feedback).
class InstructorDocumentGradingScreen extends StatelessWidget {
  final String submissionId;
  final String contentId;
  final String contentTitle;
  final String participantName;

  const InstructorDocumentGradingScreen({
    super.key,
    required this.submissionId,
    required this.contentId,
    this.contentTitle = 'Pengumpulan Dokumen',
    this.participantName = 'Peserta',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DocumentGradingCubit(
        repository: GetIt.instance<DocumentSubmissionRepository>(),
        contentId: contentId,
        submissionId: submissionId,
      )..load(),
      child: _GradingView(
        contentTitle: contentTitle,
        fallbackName: participantName,
      ),
    );
  }
}

class _GradingView extends StatefulWidget {
  final String contentTitle;
  final String fallbackName;
  const _GradingView({required this.contentTitle, required this.fallbackName});

  @override
  State<_GradingView> createState() => _GradingViewState();
}

class _GradingViewState extends State<_GradingView> {
  final _score = TextEditingController();
  final _feedback = TextEditingController();
  String? _result; // 'passed' | 'failed'
  String? _prefillFor; // submissionId yang sudah diprefill

  @override
  void dispose() {
    _score.dispose();
    _feedback.dispose();
    super.dispose();
  }

  void _prefill(DocumentSubmissionAttempt gradable) {
    if (_prefillFor == gradable.submissionId) return;
    _prefillFor = gradable.submissionId;
    _result = gradable.isPassed
        ? 'passed'
        : (gradable.isFailed ? 'failed' : null);
    _score.text = gradable.score?.toString() ?? '';
    _feedback.text = gradable.feedback ?? '';
  }

  Future<void> _openFile(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _save(DocumentSubmissionAttempt gradable) async {
    if (_result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih Lulus atau Belum lulus dulu.')),
      );
      return;
    }
    final cubit = context.read<DocumentGradingCubit>();
    final scoreText = _score.text.trim();
    final ok = await cubit.grade(
      gradeSubmissionId: gradable.submissionId,
      result: _result!,
      score: scoreText.isEmpty ? null : int.tryParse(scoreText),
      feedback: _feedback.text.trim().isEmpty ? null : _feedback.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      _prefillFor = null; // izinkan prefill ulang dari data terbaru
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _result == 'passed'
                ? 'Peserta dinilai LULUS.'
                : 'Peserta dinilai belum lulus.',
          ),
          backgroundColor: AppColors.jade,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.charcoal,
        title: const Text('Nilai Pengumpulan'),
      ),
      body: BlocConsumer<DocumentGradingCubit, DocumentGradingState>(
        listenWhen: (p, c) => p.error != c.error && c.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.error!)));
        },
        builder: (context, state) {
          if (state.status == DocGradingStatus.loading &&
              state.participant == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.red),
            );
          }
          if (state.status == DocGradingStatus.error &&
              state.participant == null) {
            return _errorState(context, state.error);
          }
          final participant = state.participant;
          if (participant == null) return const SizedBox.shrink();

          final gradable = participant.gradable;
          if (gradable != null) _prefill(gradable);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _participantHeader(participant),
              const SizedBox(height: 16),
              Text(
                'Riwayat Pengumpulan',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 8),
              ...participant.submissions.map(
                (s) => _attemptCard(s, state.scoringEnabled),
              ),
              const SizedBox(height: 8),
              if (gradable != null)
                _gradeForm(context, state, gradable)
              else
                _softNote(
                  'Peserta belum mengumpulkan tugas apa pun untuk dinilai.',
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _participantHeader(DocumentSubmissionParticipant p) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.red.withValues(alpha: 0.12),
          child: Text(
            (p.name.isNotEmpty ? p.name[0] : '?').toUpperCase(),
            style: const TextStyle(
              color: AppColors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.charcoal,
                ),
              ),
              Text(
                '${widget.contentTitle} • ${p.attemptCount} percobaan',
                style: TextStyle(fontSize: 12, color: AppColors.slate),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _attemptCard(DocumentSubmissionAttempt s, bool scoringEnabled) {
    final (label, bg, fg) = switch (s.status) {
      'passed' => ('Lulus', AppColors.successSurface, AppColors.successText),
      'failed' => (
        'Belum lulus',
        AppColors.warningSurface,
        AppColors.warningText,
      ),
      'submitted' => (
        'Menunggu',
        AppColors.warningSurface,
        AppColors.warningText,
      ),
      _ => ('Draft', AppColors.surfaceMuted, AppColors.slate),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${s.attempt}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.originalName ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: AppColors.charcoal),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  scoringEnabled && s.score != null
                      ? '$label · ${s.score}'
                      : label,
                  style: TextStyle(
                    fontSize: 11,
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if ((s.feedback ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Feedback: ${s.feedback}',
                style: TextStyle(fontSize: 12, color: AppColors.slate),
              ),
            ),
          if (s.hasFile)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openFile(s.fileUrl),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Unduh dokumen'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandText,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _gradeForm(
    BuildContext context,
    DocumentGradingState state,
    DocumentSubmissionAttempt gradable,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penilaian — percobaan #${gradable.attempt}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _resultChoice(
                  value: 'passed',
                  emoji: '✅',
                  label: 'Lulus',
                  selected: _result == 'passed',
                  selColor: AppColors.jade,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _resultChoice(
                  value: 'failed',
                  emoji: '🔁',
                  label: 'Belum lulus',
                  selected: _result == 'failed',
                  selColor: AppColors.tomato,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Bila "Belum lulus", peserta otomatis dapat mengunggah percobaan berikutnya.',
            style: TextStyle(fontSize: 11.5, color: AppColors.slate),
          ),
          if (state.scoringEnabled) ...[
            const SizedBox(height: 14),
            Text(
              'Nilai (opsional, 0–100)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _score,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration('mis. 85'),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Feedback / Catatan Revisi',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _feedback,
            maxLines: 3,
            decoration: _inputDecoration('Catatan untuk peserta...'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.submitting ? null : () => _save(gradable),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan Penilaian'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultChoice({
    required String value,
    required String emoji,
    required String label,
    required bool selected,
    required Color selColor,
  }) {
    return InkWell(
      onTap: () => setState(() => _result = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? selColor.withValues(alpha: 0.10) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? selColor : AppColors.borderSubtle,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );

  Widget _softNote(String text) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text, style: TextStyle(color: AppColors.slate)),
  );

  Widget _errorState(BuildContext context, String? error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: AppColors.slate),
          const SizedBox(height: 12),
          Text(
            error ?? 'Gagal memuat.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.slate),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.read<DocumentGradingCubit>().load(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    ),
  );
}
