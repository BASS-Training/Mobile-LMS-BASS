import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/document_grading_cubit.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_submission_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/document_submission_repository.dart';

void main() {
  test('load mengisi participant dan menyetel status loaded', () async {
    final cubit = DocumentGradingCubit(
      repository: _FakeDocumentRepository(),
      contentId: 'content-1',
      submissionId: 'sub-1',
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, DocGradingStatus.loaded);
    expect(cubit.state.participant, isNotNull);
    expect(cubit.state.error, isNull);
    expect(cubit.state.submitting, isFalse);
  });

  test('load gagal menyetel status error beserta pesan', () async {
    final cubit = DocumentGradingCubit(
      repository: _FakeDocumentRepository()..failLoad = true,
      contentId: 'content-1',
      submissionId: 'sub-1',
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, DocGradingStatus.error);
    expect(cubit.state.error, 'server error');
  });

  test(
    'grade sukses mengembalikan true dan memuat ulang participant',
    () async {
      final repository = _FakeDocumentRepository();
      final cubit = DocumentGradingCubit(
        repository: repository,
        contentId: 'content-1',
        submissionId: 'sub-1',
      );
      addTearDown(cubit.close);
      await cubit.load();

      final ok = await cubit.grade(
        gradeSubmissionId: 'sub-1',
        result: 'passed',
        score: 100,
      );

      expect(ok, isTrue);
      expect(repository.gradeCalls, 1);
      expect(repository.manageCalls, 2);
      expect(cubit.state.status, DocGradingStatus.loaded);
      expect(cubit.state.participant, isNotNull);
      expect(cubit.state.submitting, isFalse);
      expect(cubit.state.error, isNull);
    },
  );

  test('grade gagal mengembalikan false beserta pesan error', () async {
    final repository = _FakeDocumentRepository()..failGrade = true;
    final cubit = DocumentGradingCubit(
      repository: repository,
      contentId: 'content-1',
      submissionId: 'sub-1',
    );
    addTearDown(cubit.close);
    await cubit.load();

    final ok = await cubit.grade(
      gradeSubmissionId: 'sub-1',
      result: 'failed',
      score: 0,
    );

    expect(ok, isFalse);
    expect(repository.gradeCalls, 1);
    expect(repository.manageCalls, 1);
    expect(cubit.state.submitting, isFalse);
    expect(cubit.state.error, 'server error');
    expect(cubit.state.status, DocGradingStatus.loaded);
  });
}

class _FakeDocumentRepository implements DocumentSubmissionRepository {
  bool failLoad = false;
  bool failGrade = false;
  int manageCalls = 0;
  int gradeCalls = 0;

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
  Future<DocumentSubmissionManage> manage(String contentId) async {
    manageCalls++;
    if (failLoad) throw Exception('server error');
    return manageData;
  }

  @override
  Future<void> grade(
    String submissionId, {
    required String result,
    int? score,
    String? feedback,
  }) async {
    gradeCalls++;
    if (failGrade) throw Exception('server error');
  }

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
