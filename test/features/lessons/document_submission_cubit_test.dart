import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_submission_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/document_submission_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/document_submission/document_submission_cubit.dart';

void main() {
  test('copyWith tanpa submitted mempertahankan flag submitted', () {
    const state = DocumentSubmissionState(submitted: true, busy: true);

    final next = state.copyWith(busy: false, message: 'ok');

    expect(next.submitted, isTrue);
    expect(next.busy, isFalse);
    expect(next.message, 'ok');
  });

  test('copyWith dapat mereset submitted secara eksplisit', () {
    const state = DocumentSubmissionState(submitted: true);

    final next = state.copyWith(submitted: false);

    expect(next.submitted, isFalse);
  });

  test('aksi setelah submit tidak menghapus flag submitted', () async {
    final cubit = _cubit();

    await cubit.submit();
    expect(cubit.state.submitted, isTrue);

    await cubit.upload('/tmp/tugas.pdf');

    expect(cubit.state.submitted, isTrue);
    expect(cubit.state.busy, isFalse);
    await cubit.close();
  });

  test('submit berikutnya menghasilkan tepi false lalu true kembali', () async {
    final cubit = _cubit();

    await cubit.submit();
    expect(cubit.state.submitted, isTrue);

    final emitted = <DocumentSubmissionState>[];
    final subscription = cubit.stream.listen(emitted.add);
    await cubit.submit();
    await Future<void>.delayed(Duration.zero);

    expect(emitted.any((state) => state.busy && !state.submitted), isTrue);
    expect(emitted.last.submitted, isTrue);

    await subscription.cancel();
    await cubit.close();
  });
}

DocumentSubmissionCubit _cubit() {
  return DocumentSubmissionCubit(
    repository: _FakeDocumentRepository(),
    lessonId: 'lesson-1',
  );
}

class _FakeDocumentRepository implements DocumentSubmissionRepository {
  final DocumentSubmissionData data = const DocumentSubmissionData(
    lessonId: 'lesson-1',
    title: 'Tugas Dokumen',
  );

  @override
  Future<DocumentSubmissionData> getByLesson(String lessonId) async => data;

  @override
  Future<DocumentSubmissionData> uploadFile(
    String lessonId,
    String filePath,
  ) async => data;

  @override
  Future<DocumentSubmissionData> removeFile(String lessonId) async => data;

  @override
  Future<DocumentSubmissionData> submit(String lessonId) async => data;

  @override
  Future<DocumentSubmissionManage> manage(String contentId) =>
      throw UnimplementedError();

  @override
  Future<void> grade(
    String submissionId, {
    required String result,
    int? score,
    String? feedback,
  }) => throw UnimplementedError();
}
