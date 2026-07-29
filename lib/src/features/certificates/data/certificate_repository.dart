import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';
import 'package:lms_mobile_app/src/features/certificates/domain/entities/certificate_entity.dart';

/// Error terstruktur saat menerbitkan sertifikat, membawa `code` dari backend
/// sehingga UI bisa membedakan kasus (mis. `profile_incomplete` → arahkan
/// peserta melengkapi profil, bukan sekadar pesan error generik).
class CertificateException implements Exception {
  /// not_eligible | profile_incomplete | generation_failed | unknown
  final String code;
  final String message;
  final List<String> missingProfileFields;

  CertificateException(
    this.code,
    this.message, [
    this.missingProfileFields = const [],
  ]);

  factory CertificateException.fromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final code = '${data['code'] ?? 'unknown'}';
      final message = '${data['message'] ?? ''}'.trim();
      final missing = (data['missingProfileFields'] is List)
          ? List<String>.from(
              (data['missingProfileFields'] as List).map((x) => '$x'),
            )
          : <String>[];
      return CertificateException(
        code,
        message.isNotEmpty ? message : 'Gagal membuat sertifikat',
        missing,
      );
    }
    return CertificateException(
      'unknown',
      dioErrorMessage(e, 'Gagal membuat sertifikat'),
    );
  }

  @override
  String toString() => message;
}

/// Akses data sertifikat peserta. Bicara ke `/mobile/certificates*` yang
/// memakai aturan kelayakan yang SAMA dengan web dan menghasilkan record + PDF
/// nyata (tabel `certificates` yang dibagi dengan web).
class CertificateRepository {
  final Dio _dio;

  CertificateRepository({required Dio dio}) : _dio = dio;

  Future<CertificateOverview> getOverview() async {
    try {
      final res = await _dio.get(ApiEndpoints.certificates);
      final data = res.data;
      final map = (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : <String, dynamic>{};
      return CertificateOverview.fromJson(map);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat sertifikat'));
    }
  }

  /// Terbitkan sertifikat untuk [courseId]. Melempar [CertificateException] bila
  /// backend menolak (belum layak / profil belum lengkap / gagal generate).
  Future<CertificateEntity> generate(String courseId) async {
    try {
      final path = ApiEndpoints.generateCertificate.replaceFirst(
        '{course}',
        courseId,
      );
      final res = await _dio.post(path);
      final data = res.data;
      final map = (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : <String, dynamic>{};
      return CertificateEntity.fromJson(map);
    } on DioException catch (e) {
      throw CertificateException.fromDio(e);
    }
  }
}
