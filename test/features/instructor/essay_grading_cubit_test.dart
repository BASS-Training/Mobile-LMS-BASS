import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/instructor/data/instructor_repository.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/essay_grading_cubit.dart';

void main() {
  test('load mengisi detail dan menyetel status loaded', () async {
    final cubit = EssayGradingCubit(
      repository: _FakeInstructorRepository(),
      submissionId: 'sub-1',
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, EssayGradingStatus.loaded);
    expect(cubit.state.detail, isNotNull);
    expect(cubit.state.error, isNull);
    expect(cubit.state.submitting, isFalse);
  });

  test('load gagal menyetel status error beserta pesan', () async {
    final cubit = EssayGradingCubit(
      repository: _FakeInstructorRepository()..failLoad = true,
      submissionId: 'sub-1',
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, EssayGradingStatus.error);
    expect(cubit.state.error, 'server error');
  });

  test('submit sukses mengembalikan true dan menyegarkan detail', () async {
    final repository = _FakeInstructorRepository();
    final cubit = EssayGradingCubit(
      repository: repository,
      submissionId: 'sub-1',
    );
    addTearDown(cubit.close);
    await cubit.load();

    final ok = await cubit.submitOverall(score: 90, feedback: 'Bagus');

    expect(ok, isTrue);
    expect(repository.gradeCalls, 1);
    expect(repository.loadCalls, 2);
    expect(cubit.state.status, EssayGradingStatus.loaded);
    expect(cubit.state.detail, isNotNull);
    expect(cubit.state.submitting, isFalse);
    expect(cubit.state.error, isNull);
  });

  test('submit gagal mengembalikan false beserta pesan error', () async {
    final repository = _FakeInstructorRepository()..failGrade = true;
    final cubit = EssayGradingCubit(
      repository: repository,
      submissionId: 'sub-1',
    );
    addTearDown(cubit.close);
    await cubit.load();

    final ok = await cubit.submitOverall(score: 90);

    expect(ok, isFalse);
    expect(repository.gradeCalls, 1);
    expect(repository.loadCalls, 1);
    expect(cubit.state.submitting, isFalse);
    expect(cubit.state.error, 'server error');
    expect(cubit.state.status, EssayGradingStatus.loaded);
  });

  test(
    'refresh setelah simpan tetap menyimpan konten selama status loading',
    () async {
      final repository = _FakeInstructorRepository();
      final cubit = EssayGradingCubit(
        repository: repository,
        submissionId: 'sub-1',
      );
      addTearDown(cubit.close);
      await cubit.load();

      final gate = Completer<void>();
      repository.holdNextLoad = gate;
      final refresh = cubit.load();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, EssayGradingStatus.loading);
      expect(cubit.state.detail, isNotNull);

      gate.complete();
      await refresh;

      expect(cubit.state.status, EssayGradingStatus.loaded);
      expect(cubit.state.detail, isNotNull);
    },
  );
}

EssaySubmissionDetail _detail({String participantName = 'Peserta Satu'}) {
  return EssaySubmissionDetail(
    submissionId: 'sub-1',
    participantName: participantName,
    contentTitle: 'Esai Tone Bass',
    scoringEnabled: true,
    gradingMode: 'overall',
    requiresReview: false,
    status: 'submitted',
    isFullyGraded: false,
    totalScore: 80,
    maxTotalScore: 100,
    answers: const [
      EssayAnswerItem(
        answerId: 'a-1',
        questionId: 'q-1',
        question: 'Jelaskan teknik fingerstyle.',
        maxScore: 100,
        answer: 'Jawaban peserta.',
      ),
    ],
  );
}

class _FakeInstructorRepository extends InstructorRepository {
  _FakeInstructorRepository() : super(dio: Dio());

  bool failLoad = false;
  bool failGrade = false;
  int loadCalls = 0;
  int gradeCalls = 0;

  /// Jika diisi, panggilan `getEssaySubmission` berikutnya menunggu future ini.
  Completer<void>? holdNextLoad;

  @override
  Future<EssaySubmissionDetail> getEssaySubmission(String submissionId) async {
    loadCalls++;
    final gate = holdNextLoad;
    if (gate != null) {
      holdNextLoad = null;
      await gate.future;
    }
    if (failLoad) throw Exception('server error');
    return _detail();
  }

  @override
  Future<void> gradeEssay(
    String submissionId, {
    int? overallScore,
    String? overallFeedback,
    List<Map<String, dynamic>>? grades,
  }) async {
    gradeCalls++;
    if (failGrade) throw Exception('server error');
  }
}
