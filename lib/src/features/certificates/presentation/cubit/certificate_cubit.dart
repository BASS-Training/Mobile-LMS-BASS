import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/certificates/data/certificate_repository.dart';
import 'package:lms_mobile_app/src/features/certificates/domain/entities/certificate_entity.dart';

enum CertificateStatus { initial, loading, loaded, error }

String _msg(Object e) {
  final t = e.toString().replaceFirst('Exception: ', '');
  return t.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : t;
}

class CertificateState extends Equatable {
  final CertificateStatus status;
  final CertificateOverview overview;
  final String? error;

  /// courseId yang sertifikatnya sedang diterbitkan (untuk spinner di tombol).
  final String? generatingCourseId;

  const CertificateState({
    this.status = CertificateStatus.initial,
    this.overview = const CertificateOverview.empty(),
    this.error,
    this.generatingCourseId,
  });

  CertificateState copyWith({
    CertificateStatus? status,
    CertificateOverview? overview,
    String? error,
    String? generatingCourseId,
    bool clearGenerating = false,
  }) => CertificateState(
    status: status ?? this.status,
    overview: overview ?? this.overview,
    error: error,
    generatingCourseId: clearGenerating
        ? null
        : (generatingCourseId ?? this.generatingCourseId),
  );

  @override
  List<Object?> get props => [status, overview, error, generatingCourseId];
}

/// Sumber kebenaran layar Sertifikat: memuat ringkasan (terbit + siap terbit)
/// dan menerbitkan sertifikat lewat aturan yang sama dengan web.
class CertificateCubit extends Cubit<CertificateState> {
  final CertificateRepository repository;
  int _overviewRequestId = 0;

  CertificateCubit({required this.repository})
    : super(const CertificateState());

  Future<void> load() async {
    final requestId = ++_overviewRequestId;
    emit(state.copyWith(status: CertificateStatus.loading, error: null));
    try {
      final overview = await repository.getOverview();
      if (isClosed || requestId != _overviewRequestId) return;
      emit(
        state.copyWith(status: CertificateStatus.loaded, overview: overview),
      );
    } catch (e) {
      if (isClosed || requestId != _overviewRequestId) return;
      emit(state.copyWith(status: CertificateStatus.error, error: _msg(e)));
    }
  }

  /// Terbitkan sertifikat, lalu segarkan daftar. Mengembalikan sertifikat yang
  /// baru terbit; melempar [CertificateException] agar layar bisa menampilkan
  /// aksi khusus (mis. arahkan lengkapi profil).
  Future<CertificateEntity> generate(String courseId) async {
    emit(state.copyWith(generatingCourseId: courseId, error: null));
    try {
      final cert = await repository.generate(courseId);
      final requestId = ++_overviewRequestId;
      final overview = await repository.getOverview();
      if (isClosed) return cert;
      if (requestId != _overviewRequestId) {
        if (state.generatingCourseId == courseId) {
          emit(state.copyWith(clearGenerating: true));
        }
        return cert;
      }
      emit(
        state.copyWith(
          status: CertificateStatus.loaded,
          overview: overview,
          clearGenerating: true,
        ),
      );
      return cert;
    } catch (e) {
      if (!isClosed && state.generatingCourseId == courseId) {
        emit(state.copyWith(clearGenerating: true));
      }
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _overviewRequestId++;
    return super.close();
  }
}
