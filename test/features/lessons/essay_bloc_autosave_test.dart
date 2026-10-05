import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/essay_question_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/essay_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/submit_essay_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/essay/essay_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/essay/essay_event.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('essay_bloc_');
    Hive.init(hiveDirectory.path);
    await Hive.openBox('mini_lms_box');
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test(
    'autosave menunggu debounce dan hanya mengirim jawaban terbaru',
    () async {
      final repository = _FakeEssayRepository();
      final bloc = _essayBloc(repository);
      await _load(bloc);

      bloc
        ..add(const AnswerChanged(0, 'jawaban pertama'))
        ..add(const AnswerChanged(0, 'jawaban kedua'))
        ..add(const AnswerChanged(0, 'jawaban terbaru'));

      await Future<void>.delayed(const Duration(milliseconds: 650));
      expect(repository.syncedAnswers, isEmpty);

      await _waitUntil(() => repository.syncedAnswers.length == 1);
      expect(repository.syncedAnswers.single[0], 'jawaban terbaru');

      await bloc.close();
      expect(repository.syncedAnswers, hasLength(1));
    },
  );

  test('autosave menserialkan request dan membuang snapshot antara', () async {
    final firstRequest = Completer<void>();
    final repository = _FakeEssayRepository(firstRequest: firstRequest);
    final bloc = _essayBloc(repository);
    await _load(bloc);

    bloc.add(const AnswerChanged(0, 'versi satu'));
    await _waitUntil(() => repository.syncCalls == 1);

    bloc
      ..add(const AnswerChanged(0, 'versi dua'))
      ..add(const AnswerChanged(0, 'versi tiga'));
    await Future<void>.delayed(const Duration(milliseconds: 750));

    expect(repository.syncCalls, 1);
    expect(repository.maxInFlight, 1);

    firstRequest.complete();
    await _waitUntil(() => repository.syncCalls == 2);

    expect(repository.syncedAnswers.last[0], 'versi tiga');
    expect(repository.maxInFlight, 1);
    await bloc.close();
  });
}

EssayBloc _essayBloc(_FakeEssayRepository repository) {
  return EssayBloc(
    repository: repository,
    submitUseCase: SubmitEssayUseCase(repository),
  );
}

Future<void> _load(EssayBloc bloc) async {
  bloc.add(
    const LoadEssay(
      lessonId: 'lesson-1',
      courseId: 'course-1',
      courseTitle: 'Course',
      lessonTitle: 'Essay',
      content: '',
    ),
  );
  await bloc.stream.firstWhere((state) => !state.isLoading);
}

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met before timeout.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _FakeEssayRepository implements EssayRepository {
  final Completer<void>? firstRequest;
  final List<Map<int, String>> syncedAnswers = [];
  int syncCalls = 0;
  int inFlight = 0;
  int maxInFlight = 0;

  _FakeEssayRepository({this.firstRequest});

  @override
  Future<List<EssayQuestionEntity>> getQuestions(
    String lessonId,
    String content,
  ) async => const [
    EssayQuestionEntity(
      id: 'question-1',
      text: 'Pertanyaan',
      order: 1,
      maxScore: 10,
    ),
  ];

  @override
  Future<Map<int, String>> getDraftAnswers(
    String lessonId,
    List<EssayQuestionEntity> questions,
  ) async => {};

  @override
  Future<void> saveDraftAnswer(
    String lessonId,
    int questionIndex,
    String answer,
  ) async {}

  @override
  Future<void> syncDraftAnswers(
    String lessonId,
    List<EssayQuestionEntity> questions,
    Map<int, String> answers,
  ) async {
    syncCalls++;
    inFlight++;
    if (inFlight > maxInFlight) maxInFlight = inFlight;
    syncedAnswers.add(Map<int, String>.from(answers));
    try {
      if (syncCalls == 1 && firstRequest != null) {
        await firstRequest!.future;
      }
    } finally {
      inFlight--;
    }
  }

  @override
  Future<void> submitEssayAnswers(
    String lessonId,
    List<EssayQuestionEntity> questions,
    Map<int, String> answers, {
    String? userEmail,
  }) async {}
}
