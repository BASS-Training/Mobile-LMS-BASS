import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/instructor/data/instructor_repository.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';

enum EssayGradingStatus { loading, loaded, error }

class EssayGradingState extends Equatable {
  final EssayGradingStatus status;
  final EssaySubmissionDetail? detail;
  final bool submitting;
  final bool saved;
  final String? error;

  const EssayGradingState({
    this.status = EssayGradingStatus.loading,
    this.detail,
    this.submitting = false,
    this.saved = false,
    this.error,
  });

  EssayGradingState copyWith({
    EssayGradingStatus? status,
    EssaySubmissionDetail? detail,
    bool? submitting,
    bool? saved,
    String? error,
  }) => EssayGradingState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    submitting: submitting ?? this.submitting,
    saved: saved ?? this.saved,
    error: error,
  );

  @override
  List<Object?> get props => [status, detail, submitting, saved, error];
}

class EssayGradingCubit extends Cubit<EssayGradingState> {
  final InstructorRepository repository;
  final String submissionId;

  EssayGradingCubit({required this.repository, required this.submissionId})
    : super(const EssayGradingState());

  Future<void> load() async {
    emit(state.copyWith(status: EssayGradingStatus.loading, error: null));
    try {
      final detail = await repository.getEssaySubmission(submissionId);
      emit(state.copyWith(status: EssayGradingStatus.loaded, detail: detail));
    } catch (e) {
      emit(state.copyWith(status: EssayGradingStatus.error, error: _msg(e)));
    }
  }

  /// Submit a grade. Returns true on success.
  Future<bool> submitOverall({int? score, String? feedback}) async {
    return _submit(() => repository.gradeEssay(
      submissionId,
      overallScore: score,
      overallFeedback: feedback,
    ));
  }

  Future<bool> submitIndividual(List<Map<String, dynamic>> grades) async {
    return _submit(() => repository.gradeEssay(submissionId, grades: grades));
  }

  Future<bool> _submit(Future<void> Function() action) async {
    if (state.submitting) return false;
    emit(state.copyWith(submitting: true, error: null));
    try {
      await action();
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
