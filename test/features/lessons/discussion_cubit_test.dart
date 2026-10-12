import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/discussion_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/discussion_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/create_discussion_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/create_reply_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/get_discussion_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/discussion/discussion_cubit.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/discussion/discussion_state.dart';

void main() {
  test('load sukses memperbarui state ke loaded', () async {
    final repo = _FakeDiscussionRepository();
    final cubit = _cubit(repo);
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, DiscussionStatus.loaded);
    expect(cubit.state.discussions, hasLength(1));
  });

  test('load tidak melempar StateError saat cubit ditutup di tengah request',
      () async {
    final repo = _FakeDiscussionRepository();
    final pending = Completer<List<DiscussionEntity>>();
    repo.onGet = (_) => pending.future;
    final cubit = _cubit(repo);

    final future = cubit.load();
    await cubit.close();
    pending.complete([_topic]);

    await future;
  });

  test(
      'load tidak melempar StateError saat request gagal setelah cubit ditutup',
      () async {
    final repo = _FakeDiscussionRepository();
    final pending = Completer<List<DiscussionEntity>>();
    repo.onGet = (_) => pending.future;
    final cubit = _cubit(repo);

    final future = cubit.load();
    await cubit.close();
    pending.completeError(Exception('network down'));

    await future;
  });

  test('postTopic tidak melempar StateError saat cubit ditutup di tengah request',
      () async {
    final repo = _FakeDiscussionRepository();
    final pending = Completer<DiscussionEntity>();
    repo.onCreate = (_, {required title, required body}) => pending.future;
    final cubit = _cubit(repo);

    final future = cubit.postTopic(title: 'Judul', body: 'Isi');
    await cubit.close();
    pending.complete(_topic);

    expect(await future, isFalse);
  });

  test('postReply tidak melempar StateError saat cubit ditutup di tengah request',
      () async {
    final repo = _FakeDiscussionRepository();
    final pending = Completer<DiscussionReplyEntity>();
    repo.onReply = (_, {required body}) => pending.future;
    final cubit = _cubit(repo);

    final future = cubit.postReply('discussion-1', 'balasan');
    await cubit.close();
    pending.complete(_reply);

    expect(await future, isFalse);
  });

  test('pemanggilan setelah cubit ditutup tidak melempar StateError', () async {
    final repo = _FakeDiscussionRepository();
    final cubit = _cubit(repo);
    await cubit.close();

    await cubit.load();
    expect(await cubit.postTopic(title: 'Judul', body: 'Isi'), isFalse);
    expect(await cubit.postReply('discussion-1', 'balasan'), isFalse);
  });

  test('postTopic sukses menambahkan topik ke daftar', () async {
    final repo = _FakeDiscussionRepository();
    final cubit = _cubit(repo);
    addTearDown(cubit.close);

    final ok = await cubit.postTopic(title: 'Judul', body: 'Isi');

    expect(ok, isTrue);
    expect(cubit.state.discussions.first.id, 'topic-1');
    expect(cubit.state.submitting, isFalse);
  });
}

DiscussionCubit _cubit(DiscussionRepository repo) {
  return DiscussionCubit(
    getDiscussions: GetDiscussionUseCase(repo),
    createDiscussion: CreateDiscussionUseCase(repo),
    createReply: CreateReplyUseCase(repo),
    lessonId: 'lesson-1',
  );
}

const _topic = DiscussionEntity(
  id: 'topic-1',
  title: 'Judul',
  body: 'Isi',
  authorId: 'user-1',
  authorName: 'Penulis',
  createdAtLabel: 'baru saja',
);

const _reply = DiscussionReplyEntity(
  id: 'reply-1',
  body: 'balasan',
  authorId: 'user-1',
  authorName: 'Penulis',
  createdAtLabel: 'baru saja',
);

class _FakeDiscussionRepository implements DiscussionRepository {
  Future<List<DiscussionEntity>> Function(String lessonId)? onGet;
  Future<DiscussionEntity> Function(
    String lessonId, {
    required String title,
    required String body,
  })? onCreate;
  Future<DiscussionReplyEntity> Function(
    String discussionId, {
    required String body,
  })? onReply;

  @override
  Future<List<DiscussionEntity>> getDiscussions(String lessonId) =>
      onGet?.call(lessonId) ?? Future.value([_topic]);

  @override
  Future<DiscussionEntity> createDiscussion(
    String lessonId, {
    required String title,
    required String body,
  }) =>
      onCreate?.call(lessonId, title: title, body: body) ??
      Future.value(_topic);

  @override
  Future<DiscussionReplyEntity> createReply(
    String discussionId, {
    required String body,
  }) =>
      onReply?.call(discussionId, body: body) ?? Future.value(_reply);
}
