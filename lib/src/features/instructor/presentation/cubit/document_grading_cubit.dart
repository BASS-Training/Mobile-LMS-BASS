import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_submission_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/document_submission_repository.dart';

enum DocGradingStatus { loading, loaded, error }

class DocumentGradingState extends Equatable {
  final DocGradingStatus status;
  final bool scoringEnabled;
  final DocumentSubmissionParticipant? participant;
  final bool submitting;
  final bool saved;
  final String? error;

  const DocumentGradingState({
    this.status = DocGradingStatus.loading,
    this.scoringEnabled = true,
    this.participant,
    this.submitting = false,
    this.saved = false,
    this.error,
  });

  DocumentGradingState copyWith({
    DocGradingStatus? status,
    bool? scoringEnabled,
    DocumentSubmissionParticipant? participant,
    bool? submitting,
    bool? saved,
    String? error,
  }) {
    return DocumentGradingState(
      status: status ?? this.status,
      scoringEnabled: scoringEnabled ?? this.scoringEnabled,
      participant: participant ?? this.participant,
      submitting: submitting ?? this.submitting,
      saved: saved ?? false,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    scoringEnabled,
    participant,
    submitting,
    saved,
    error,
  ];
}

/// Penilaian satu pengumpulan dokumen peserta (untuk instruktur/admin).
/// Memuat daftar pengumpulan konten via [DocumentSubmissionRepository.manage]
/// lalu memilih peserta pemilik [submissionId].
class DocumentGradingCubit extends Cubit<DocumentGradingState> {
  final DocumentSubmissionRepository repository;
  final String contentId;
  final String submissionId;

  DocumentGradingCubit({
    required this.repository,
    required this.contentId,
    required this.submissionId,
  }) : super(const DocumentGradingState());

  Future<void> load() async {
    emit(state.copyWith(status: DocGradingStatus.loading, error: null));
    try {
      final manage = await repository.manage(contentId);
      DocumentSubmissionParticipant? participant;
      for (final p in manage.participants) {
        if (p.submissions.any((s) => s.submissionId == submissionId)) {
          participant = p;
          break;
        }
      }
      participant ??= manage.participants.isNotEmpty
          ? manage.participants.first
          : null;

      if (participant == null) {
        emit(
          state.copyWith(
            status: DocGradingStatus.error,
            error: 'Pengumpulan tidak ditemukan.',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: DocGradingStatus.loaded,
          scoringEnabled: manage.scoringEnabled,
          participant: participant,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: DocGradingStatus.error, error: _msg(e)));
    }
  }

  /// Nilai attempt [gradeSubmissionId]. Returns true on success.
  Future<bool> grade({
    required String gradeSubmissionId,
    required String result, // 'passed' | 'failed'
    int? score,
    String? feedback,
  }) async {
    if (state.submitting) return false;
    emit(state.copyWith(submitting: true, error: null));
    try {
      await repository.grade(
        gradeSubmissionId,
        result: result,
        score: score,
        feedback: feedback,
      );
      emit(state.copyWith(submitting: false, saved: true));
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(submitting: false, error: _msg(e)));
      return false;
    }
  }

  String _msg(Object e) {
    final t = e.toString().replaceFirst('Exception: ', '');
    return t.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : t;
  }
}
