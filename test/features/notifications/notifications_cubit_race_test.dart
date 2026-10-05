import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/notifications/data/notification_repository.dart';
import 'package:lms_mobile_app/src/features/notifications/domain/entities/app_notification.dart';
import 'package:lms_mobile_app/src/features/notifications/presentation/cubit/notifications_cubit.dart';

void main() {
  test('load terbaru membatalkan dan mengalahkan respons lama', () async {
    final repository = _ControlledNotificationRepository();
    final cubit = NotificationsCubit(repository: repository);
    addTearDown(cubit.close);

    final firstLoad = cubit.load();
    await _waitUntil(() => repository.requests.length == 1);
    final secondLoad = cubit.load();
    await _waitUntil(() => repository.requests.length == 2);

    expect(repository.tokens.first.isCancelled, isTrue);

    repository.requests[1].complete([_notification('new')]);
    await secondLoad;
    repository.requests[0].complete([_notification('old')]);
    await firstLoad;

    expect(cubit.state.items.single.id, 'new');
    expect(cubit.state.status, NotificationsStatus.loaded);
  });
}

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met before timeout.');
    }
    await Future<void>.delayed(Duration.zero);
  }
}

AppNotification _notification(String id) => AppNotification(
  id: id,
  source: 'notification',
  category: 'info',
  title: id,
  message: '',
);

class _ControlledNotificationRepository extends NotificationRepository {
  final List<Completer<List<AppNotification>>> requests = [];
  final List<CancelToken> tokens = [];

  _ControlledNotificationRepository() : super(dio: Dio());

  @override
  Future<List<AppNotification>> getNotifications({CancelToken? cancelToken}) {
    final request = Completer<List<AppNotification>>();
    requests.add(request);
    tokens.add(cancelToken!);
    return request.future;
  }
}
