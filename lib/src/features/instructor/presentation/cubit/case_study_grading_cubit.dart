import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/instructor/data/instructor_repository.dart';

enum CaseGradingStatus { loading, loaded, error }

class CaseStudyGradingState extends Equatable {
  final CaseGradingStatus status;
  final CaseStudyReview? review;
  final bool submitting;
  final bool saved;
  final String? error;

  const CaseStudyGradingState({
    this.status = CaseGradingStatus.loading,
    this.review,
    this.submitting = false,
    this.saved = false,
    this.error,
  });

  CaseStudyGradingState copyWith({
    CaseGradingStatus? status,
    CaseStudyReview? review,
    bool? submitting,
    bool? saved,
    String? error,
  }) => CaseStudyGradingState(
    status: status ?? this.status,
    review: review ?? this.review,
    submitting: submitting ?? this.submitting,
    saved: saved ?? this.saved,
    error: error,
  );

  @override
  List<Object?> get props => [status, review, submitting, saved, error];
}

class CaseStudyGradingCubit extends Cubit<CaseStudyGradingState> {
  final InstructorRepository repository;
  final String submissionId;

  CaseStudyGradingCubit({required this.repository, required this.submissionId})
    : super(const CaseStudyGradingState());

  Future<void> load() async {
    emit(state.copyWith(status: CaseGradingStatus.loading, error: null));
    try {
      final review = await repository.getCaseStudySubmission(submissionId);
      emit(state.copyWith(status: CaseGradingStatus.loaded, review: review));
    } catch (e) {
      emit(state.copyWith(status: CaseGradingStatus.error, error: _msg(e)));
    }
  }

  /// Returns true on success.
  Future<bool> submit({int? score, String? feedback}) async {
    if (state.submitting) return false;
    emit(state.copyWith(submitting: true, error: null));
    try {
      await repository.gradeCaseStudy(
        submissionId,
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
