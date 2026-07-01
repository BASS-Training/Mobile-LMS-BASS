import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';

import '../models/discussion_model.dart';
import 'discussion_remote_datasource.dart';

class DiscussionRemoteDataSourceImpl implements DiscussionRemoteDataSource {
  final Dio _dio;

  DiscussionRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<DiscussionModel>> getByLesson(String lessonId) async {
    final path = ApiEndpoints.getDiscussions.replaceAll(
      '{contentId}',
      lessonId,
    );
    final response = await _dio.get(path);
    final data = _dataList(response.data);
    return data
        .whereType<Map<String, dynamic>>()
        .map(DiscussionModel.fromJson)
        .toList();
  }

  @override
  Future<DiscussionModel> create(
    String lessonId, {
    required String title,
    required String body,
  }) async {
    final path = ApiEndpoints.createDiscussion.replaceAll(
      '{contentId}',
      lessonId,
    );
    final response = await _dio.post(
      path,
      data: {'title': title, 'body': body},
    );
    return DiscussionModel.fromJson(_dataMap(response.data));
  }

  @override
  Future<DiscussionReplyModel> reply(
    String discussionId, {
    required String body,
  }) async {
    final path = ApiEndpoints.createReply.replaceAll(
      '{discussionId}',
      discussionId,
    );
    final response = await _dio.post(path, data: {'body': body});
    return DiscussionReplyModel.fromJson(_dataMap(response.data));
  }

  List<dynamic> _dataList(dynamic body) {
    if (body is Map && body['data'] is List) {
      return body['data'] as List<dynamic>;
    }
    if (body is List) return body;
    return const [];
  }

  Map<String, dynamic> _dataMap(dynamic body) {
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    if (body is Map<String, dynamic>) return body;
    return <String, dynamic>{};
  }
}
