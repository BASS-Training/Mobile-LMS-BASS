import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';
import 'package:lms_mobile_app/src/features/discussions/domain/entities/discussion_feed_item.dart';
import 'package:lms_mobile_app/src/features/discussions/domain/entities/discussion_structure.dart';

/// Read-only access to the aggregated discussion feed (`/mobile/discussions`),
/// which spans every course the user can access. Backed by the same tables as
/// the per-lesson discussion API, so it stays in sync with web.
class DiscussionFeedRepository {
  final Dio _dio;

  DiscussionFeedRepository({required Dio dio}) : _dio = dio;

  /// [courseId] non-null → forum satu kelas (semua diskusinya). Null → feed
  /// global (dibatasi server ke 60 aktivitas terbaru).
  Future<List<DiscussionFeedItem>> getFeed({String? courseId}) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.discussionsFeed,
        queryParameters: (courseId != null && courseId.isNotEmpty)
            ? {'course': courseId}
            : null,
      );
      final data = res.data;
      final list = (data is Map && data['data'] is List)
          ? data['data'] as List
          : const [];
      return list
          .whereType<Map>()
          .map((e) => DiscussionFeedItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat diskusi'));
    }
  }

  /// Course → lesson structure (with per-lesson discussion counts) for the hub's
  /// context selector.
  Future<List<DiscussionCourseGroup>> getStructure() async {
    try {
      final res = await _dio.get(ApiEndpoints.discussionsStructure);
      final data = res.data;
      final list = (data is Map && data['data'] is List)
          ? data['data'] as List
          : const [];
      return list
          .whereType<Map>()
          .map((e) => DiscussionCourseGroup.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat daftar kelas'));
    }
  }
}
