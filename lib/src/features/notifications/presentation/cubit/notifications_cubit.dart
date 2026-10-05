import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/notifications/data/notification_repository.dart';
import 'package:lms_mobile_app/src/features/notifications/domain/entities/app_notification.dart';

enum NotificationsStatus { initial, loading, loaded, error }

String _msg(Object e) {
  final t = e.toString().replaceFirst('Exception: ', '');
  return t.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : t;
}

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<AppNotification> items;
  final int unreadCount;
  final String? error;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const [],
    this.unreadCount = 0,
    this.error,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? items,
    int? unreadCount,
    String? error,
  }) => NotificationsState(
    status: status ?? this.status,
    items: items ?? this.items,
    unreadCount: unreadCount ?? this.unreadCount,
    error: error,
  );

  @override
  List<Object?> get props => [status, items, unreadCount, error];
}

/// Single source of truth for both the notification screen and the bell badge.
/// Registered as a lazy singleton so the badge updates when items are read.
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository repository;
  int _loadRequestId = 0;
  int _unreadRequestId = 0;
  CancelToken? _loadCancelToken;
  CancelToken? _unreadCancelToken;

  NotificationsCubit({required this.repository})
    : super(const NotificationsState());

  /// Full list load (used by the notification screen).
  Future<void> load() async {
    final requestId = ++_loadRequestId;
    _loadCancelToken?.cancel('Replaced by a newer notification load.');
    final cancelToken = CancelToken();
    _loadCancelToken = cancelToken;
    emit(state.copyWith(status: NotificationsStatus.loading, error: null));
    try {
      final items = await repository.getNotifications(cancelToken: cancelToken);
      if (isClosed || requestId != _loadRequestId) return;
      emit(
        state.copyWith(
          status: NotificationsStatus.loaded,
          items: items,
          unreadCount: items.where((i) => !i.isRead).length,
        ),
      );
    } catch (e) {
      if (isClosed || requestId != _loadRequestId || cancelToken.isCancelled) {
        return;
      }
      emit(state.copyWith(status: NotificationsStatus.error, error: _msg(e)));
    } finally {
      if (identical(_loadCancelToken, cancelToken)) _loadCancelToken = null;
    }
  }

  /// Lightweight count refresh (used by the bell on home/dashboard).
  Future<void> refreshUnreadCount() async {
    final requestId = ++_unreadRequestId;
    _unreadCancelToken?.cancel('Replaced by a newer unread-count request.');
    final cancelToken = CancelToken();
    _unreadCancelToken = cancelToken;
    try {
      final count = await repository.getUnreadCount(cancelToken: cancelToken);
      if (isClosed || requestId != _unreadRequestId) return;
      emit(state.copyWith(unreadCount: count));
    } catch (_) {
      // Silent — the badge simply keeps its previous value.
    } finally {
      if (identical(_unreadCancelToken, cancelToken)) {
        _unreadCancelToken = null;
      }
    }
  }

  Future<void> markRead(AppNotification n) async {
    if (n.isRead) return;
    // Optimistic update.
    final items = state.items
        .map(
          (i) => i.id == n.id && i.source == n.source
              ? i.copyWith(isRead: true)
              : i,
        )
        .toList();
    emit(
      state.copyWith(
        items: items,
        unreadCount: (state.unreadCount - 1).clamp(0, 9999),
      ),
    );
    try {
      await repository.markRead(n.source, n.id);
    } catch (_) {
      // Re-sync on failure.
      await load();
    }
  }

  Future<void> markAllRead() async {
    if (state.unreadCount == 0) return;
    final items = state.items.map((i) => i.copyWith(isRead: true)).toList();
    emit(state.copyWith(items: items, unreadCount: 0));
    try {
      await repository.markAllRead();
    } catch (_) {
      await load();
    }
  }

  @override
  Future<void> close() {
    _loadRequestId++;
    _unreadRequestId++;
    _loadCancelToken?.cancel('Notifications cubit closed.');
    _unreadCancelToken?.cancel('Notifications cubit closed.');
    return super.close();
  }
}
