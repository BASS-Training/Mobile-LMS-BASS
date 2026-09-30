import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/document_grading_cubit.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_submission_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/document_submission_repository.dart';

void main() {
  test('copyWith tanpa saved mempertahankan flag saved', () {
    const state = DocumentGradingState(saved: true, submitting: true);

    final next = state.copyWith(submitting: false, error: null);

    expect(next.saved, isTrue);
    expect(next.submitting, isFalse);
  });

  test('copyWith dapat mereset saved secara eksplisit', () {
    const state = DocumentGradingState(saved: true);

    final next = state.copyWith(saved: false);

    expect(next.saved, isFalse);
  });

  test('saved bertahan setelah load memperbarui participant', () async {
    final cubit = DocumentGradingCubit(
      repository: _FakeDocumentRepository(),
      contentId: 'content-1',
      submissionId: 'sub-1',
    );
    addTearDown(cubit.close);

    final graded = await cubit.grade(
      gradeSubmissionId: 'sub-1',
      result: 'passed',
      score: 100,
    );

    expect(graded, isTrue);
    expect(cubit.state.saved, isTrue);

    await cubit.load();

    expect(cubit.state.status, DocGradingStatus.loaded);
    expect(cubit.state.saved, isTrue);
  });
}

class _FakeDocumentRepository implements DocumentSubmissionRepository {
  static const DocumentSubmissionManage manageData = DocumentSubmissionManage(
    contentId: 'content-1',
    title: 'Tugas Dokumen',
    participants: [
      DocumentSubmissionParticipant(
        userId: 'user-1',
        name: 'Peserta Satu',
        email: 'peserta@example.com',
        attemptCount: 1,
        latestStatus: 'submitted',
        submissions: [
          DocumentSubmissionAttempt(
            submissionId: 'sub-1',
            attempt: 1,
            status: 'submitted',
          ),
        ],
      ),
    ],
  );

  @override
  Future<DocumentSubmissionManage> manage(String contentId) async => manageData;

  @override
  Future<void> grade(
    String submissionId, {
    required String result,
    int? score,
    String? feedback,
  }) async {}

  @override
  Future<DocumentSubmissionData> getByLesson(String lessonId) =>
      throw UnimplementedError();

  @override
  Future<DocumentSubmissionData> uploadFile(String lessonId, String filePath) =>
      throw UnimplementedError();

  @override
  Future<DocumentSubmissionData> removeFile(String lessonId) =>
      throw UnimplementedError();

  @override
  Future<DocumentSubmissionData> submit(String lessonId) =>
      throw UnimplementedError();
}
