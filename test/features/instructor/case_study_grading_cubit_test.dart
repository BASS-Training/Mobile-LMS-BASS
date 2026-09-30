import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/instructor/data/instructor_repository.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/case_study_grading_cubit.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';

void main() {
  test('load mengisi review dan menyetel status loaded', () async {
    final cubit = CaseStudyGradingCubit(
      repository: _FakeInstructorRepository(),
      submissionId: 'sub-1',
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, CaseGradingStatus.loaded);
    expect(cubit.state.review, isNotNull);
    expect(cubit.state.error, isNull);
    expect(cubit.state.submitting, isFalse);
  });

  test('load gagal menyetel status error beserta pesan', () async {
    final cubit = CaseStudyGradingCubit(
      repository: _FakeInstructorRepository()..failLoad = true,
      submissionId: 'sub-1',
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, CaseGradingStatus.error);
    expect(cubit.state.error, 'server error');
  });

  test('submit sukses mengembalikan true dan menyegarkan review', () async {
    final repository = _FakeInstructorRepository();
    final cubit = CaseStudyGradingCubit(
      repository: repository,
      submissionId: 'sub-1',
    );
    addTearDown(cubit.close);
    await cubit.load();

    final ok = await cubit.submit(score: 90, feedback: 'Tepat');

    expect(ok, isTrue);
    expect(repository.gradeCalls, 1);
    expect(repository.loadCalls, 2);
    expect(cubit.state.status, CaseGradingStatus.loaded);
    expect(cubit.state.review, isNotNull);
    expect(cubit.state.submitting, isFalse);
    expect(cubit.state.error, isNull);
  });

  test('submit gagal mengembalikan false beserta pesan error', () async {
    final repository = _FakeInstructorRepository()..failGrade = true;
    final cubit = CaseStudyGradingCubit(
      repository: repository,
      submissionId: 'sub-1',
    );
    addTearDown(cubit.close);
    await cubit.load();

    final ok = await cubit.submit(score: 10);

    expect(ok, isFalse);
    expect(repository.gradeCalls, 1);
    expect(repository.loadCalls, 1);
    expect(cubit.state.submitting, isFalse);
    expect(cubit.state.error, 'server error');
    expect(cubit.state.status, CaseGradingStatus.loaded);
  });

  test(
    'refresh setelah simpan tetap menyimpan konten selama status loading',
    () async {
      final repository = _FakeInstructorRepository();
      final cubit = CaseStudyGradingCubit(
        repository: repository,
        submissionId: 'sub-1',
      );
      addTearDown(cubit.close);
      await cubit.load();

      final gate = Completer<void>();
      repository.holdNextLoad = gate;
      final refresh = cubit.load();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, CaseGradingStatus.loading);
      expect(cubit.state.review, isNotNull);

      gate.complete();
      await refresh;

      expect(cubit.state.status, CaseGradingStatus.loaded);
      expect(cubit.state.review, isNotNull);
    },
  );
}

CaseStudyReview _review() => const CaseStudyReview(
  participantName: 'Peserta Satu',
  scoringEnabled: true,
  caseStudy: CaseStudyEntity(id: 'cs-1', title: 'Studi Kasus Tone'),
);

class _FakeInstructorRepository extends InstructorRepository {
  _FakeInstructorRepository() : super(dio: Dio());

  bool failLoad = false;
  bool failGrade = false;
  int loadCalls = 0;
  int gradeCalls = 0;

  /// Jika diisi, panggilan `getCaseStudySubmission` berikutnya menunggu
  /// future ini.
  Completer<void>? holdNextLoad;

  @override
  Future<CaseStudyReview> getCaseStudySubmission(String submissionId) async {
    loadCalls++;
    final gate = holdNextLoad;
    if (gate != null) {
      holdNextLoad = null;
      await gate.future;
    }
    if (failLoad) throw Exception('server error');
    return _review();
  }

  @override
  Future<void> gradeCaseStudy(
    String submissionId, {
    int? score,
    String? feedback,
  }) async {
    gradeCalls++;
    if (failGrade) throw Exception('server error');
  }
}
