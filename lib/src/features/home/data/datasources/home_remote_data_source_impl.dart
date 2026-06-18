import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';
import 'package:lms_mobile_app/src/core/utils/app_logger.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/features/home/data/datasources/home_remote_data_source.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> submitJoinClassToken(String token) async {
    try {
      final endpoint = ApiEndpoints.enrollByToken;
      logDebug('>>> ENROLL REQUEST URL: ${dio.options.baseUrl}$endpoint');
      final response = await dio.post(endpoint, data: {'token': token});

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final status = data['status']?.toString();
        if (status == 'success') {
          return;
        }

        final message = data['message']?.toString();
        throw Exception(
          message?.isNotEmpty == true ? message : 'Gagal mengirim token.',
        );
      }

      return;
    } on DioException catch (error) {
      throw Exception(dioErrorMessage(error, 'Gagal mengirim token.'));
    }
  }
}
