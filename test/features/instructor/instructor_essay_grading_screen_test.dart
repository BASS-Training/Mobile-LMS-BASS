import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/instructor/data/instructor_repository.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/essay_grading_cubit.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/screens/instructor_essay_grading_screen.dart';

void main() {
  testWidgets('refresh setelah simpan tidak mengganti konten dengan spinner', (
    tester,
  ) async {
    final repository = _FakeInstructorRepository();
    EssayGradingCubit? created;
    final getIt = ServiceLocator().locator;
    getIt.registerFactoryParam<EssayGradingCubit, String, void>((
      submissionId,
      _,
    ) {
      final cubit = EssayGradingCubit(
        repository: repository,
        submissionId: submissionId,
      );
      created = cubit;
      return cubit;
    });
    addTearDown(() async {
      if (getIt.isRegistered<EssayGradingCubit>()) {
        await getIt.unregister<EssayGradingCubit>();
      }
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: InstructorEssayGradingScreen(submissionId: 'sub-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Peserta Satu'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final gate = Completer<void>();
    repository.holdNextLoad = gate;
    final refresh = created!.load();
    await tester.pump();

    expect(created!.state.status, EssayGradingStatus.loading);
    expect(find.text('Peserta Satu'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    gate.complete();
    await refresh;
    await tester.pumpAndSettle();

    expect(find.text('Peserta Satu'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

class _FakeInstructorRepository extends InstructorRepository {
  _FakeInstructorRepository() : super(dio: Dio());

  int loadCalls = 0;

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
    return EssaySubmissionDetail(
      submissionId: submissionId,
      participantName: 'Peserta Satu',
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

  @override
  Future<void> gradeEssay(
    String submissionId, {
    int? overallScore,
    String? overallFeedback,
    List<Map<String, dynamic>>? grades,
  }) async {}
}
