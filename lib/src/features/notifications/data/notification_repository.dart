import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';
import 'package:lms_mobile_app/src/features/notifications/domain/entities/app_notification.dart';

/// Data access for the unified notification feed (DB notifications + web
/// announcements). Talks to the `/mobile/notifications/*` endpoints, which share
/// read-tracking with the web so read state stays in sync.
class NotificationRepository {
  final Dio _dio;

  NotificationRepository({required Dio dio}) : _dio = dio;

  Future<List<AppNotification>> getNotifications() async {
    try {
      final res = await _dio.get(ApiEndpoints.notifications);
      final data = res.data;
      final list = (data is Map && data['data'] is List)
          ? data['data'] as List
          : const [];
      return list
          .whereType<Map>()
          .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat notifikasi'));
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get(ApiEndpoints.notificationsUnreadCount);
      final data = res.data;
      final count = (data is Map && data['data'] is Map)
          ? data['data']['unreadCount']
          : null;
      if (count is int) return count;
      if (count is num) return count.toInt();
      return int.tryParse('$count') ?? 0;
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat jumlah notifikasi'));
    }
  }

  Future<void> markRead(String source, String id) async {
    try {
      await _dio.post(
        ApiEndpoints.notificationsMarkRead,
        data: {'source': source, 'id': id},
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal menandai dibaca'));
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.post(ApiEndpoints.notificationsMarkAllRead);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal menandai semua dibaca'));
    }
  }
}
