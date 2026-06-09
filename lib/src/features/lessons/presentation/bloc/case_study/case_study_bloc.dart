import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/case_study_repository.dart';

import 'case_study_event.dart';
import 'case_study_state.dart';

class CaseStudyBloc extends Bloc<CaseStudyEvent, CaseStudyState> {
  final CaseStudyRepository repository;

  CaseStudyBloc({required this.repository}) : super(const CaseStudyState()) {
    on<LoadCaseStudy>(_onLoad);
    on<SubmitCaseStudy>(_onSubmit);
    on<SaveDraftCaseStudy>(_onSaveDraft);
    on<DownloadCaseStudyPdf>(_onDownload);
    on<ClearCaseStudyMessage>(_onClearMessage);
  }

  Future<void> _onLoad(LoadCaseStudy event, Emitter<CaseStudyState> emit) async {
    emit(state.copyWith(status: CaseStudyStatus.loading, clearMessages: true));
    try {
      final data = await repository.getByLesson(event.lessonId);
      emit(state.copyWith(status: CaseStudyStatus.loaded, data: data));
    } catch (e) {
      emit(
        state.copyWith(
          status: CaseStudyStatus.error,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onSubmit(
    SubmitCaseStudy event,
    Emitter<CaseStudyState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      final submission = await repository.submit(event.lessonId, event.answers);
      // Perbarui data dengan submission terbaru.
      final updated = state.data == null
          ? null
          : CaseStudyEntity(
              id: state.data!.id,
              title: state.data!.title,
              description: state.data!.description,
              courseId: state.data!.courseId,
              allowAnswerDownload: state.data!.allowAnswerDownload,
              scoringEnabled: state.data!.scoringEnabled,
              sections: state.data!.sections,
              submission: submission,
            );
      emit(
        state.copyWith(
          submitting: false,
          data: updated,
          justSubmitted: true,
          infoMessage: 'Jawaban berhasil dikumpulkan',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submitting: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onSaveDraft(
    SaveDraftCaseStudy event,
    Emitter<CaseStudyState> emit,
  ) async {
    emit(state.copyWith(draftSaving: true, clearMessages: true));
    try {
      await repository.saveDraft(event.lessonId, event.answers);
      emit(state.copyWith(draftSaving: false, infoMessage: 'Draft tersimpan'));
    } catch (e) {
      emit(
        state.copyWith(
          draftSaving: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onDownload(
    DownloadCaseStudyPdf event,
    Emitter<CaseStudyState> emit,
  ) async {
    emit(state.copyWith(downloading: true, clearMessages: true, clearPdf: true));
    try {
      final bytes = await repository.downloadPdf(event.lessonId);
      emit(state.copyWith(downloading: false, pdfBytes: bytes));
    } catch (e) {
      emit(
        state.copyWith(
          downloading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onClearMessage(
    ClearCaseStudyMessage event,
    Emitter<CaseStudyState> emit,
  ) {
    emit(state.copyWith(clearMessages: true, clearPdf: true));
  }
}
