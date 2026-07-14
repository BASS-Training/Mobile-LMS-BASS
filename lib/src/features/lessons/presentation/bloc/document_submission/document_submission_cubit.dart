import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_submission_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/document_submission_repository.dart';

enum DocSubStatus { loading, loaded, error }

class DocumentSubmissionState extends Equatable {
  final DocSubStatus status;
  final DocumentSubmissionData? data;
  final bool busy; // saat upload/hapus/kumpulkan berjalan
  final String? error;
  final String? message; // teks sukses untuk snackbar (sekali pakai)
  final bool submitted; // true tepat setelah "Kumpulkan" sukses

  const DocumentSubmissionState({
    this.status = DocSubStatus.loading,
    this.data,
    this.busy = false,
    this.error,
    this.message,
    this.submitted = false,
  });

  DocumentSubmissionState copyWith({
    DocSubStatus? status,
    DocumentSubmissionData? data,
    bool? busy,
    String? error,
    String? message,
    bool? submitted,
  }) {
    return DocumentSubmissionState(
      status: status ?? this.status,
      data: data ?? this.data,
      busy: busy ?? this.busy,
      error: error,
      message: message,
      submitted: submitted ?? false,
    );
  }

  @override
  List<Object?> get props => [status, data, busy, error, message, submitted];
}

class DocumentSubmissionCubit extends Cubit<DocumentSubmissionState> {
  final DocumentSubmissionRepository repository;
  final String lessonId;

  DocumentSubmissionCubit({required this.repository, required this.lessonId})
    : super(const DocumentSubmissionState());

  Future<void> load() async {
    emit(state.copyWith(status: DocSubStatus.loading, error: null));
    try {
      final data = await repository.getByLesson(lessonId);
      emit(state.copyWith(status: DocSubStatus.loaded, data: data));
    } catch (e) {
      emit(state.copyWith(status: DocSubStatus.error, error: _msg(e)));
    }
  }

  Future<void> upload(String filePath) async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, error: null));
    try {
      final data = await repository.uploadFile(lessonId, filePath);
      emit(
        state.copyWith(
          busy: false,
          data: data,
          message: 'File berhasil diunggah.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(busy: false, error: _msg(e)));
    }
  }

  Future<void> removeFile() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, error: null));
    try {
      final data = await repository.removeFile(lessonId);
      emit(state.copyWith(busy: false, data: data, message: 'File dihapus.'));
    } catch (e) {
      emit(state.copyWith(busy: false, error: _msg(e)));
    }
  }

  Future<void> submit() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, error: null));
    try {
      final data = await repository.submit(lessonId);
      emit(
        state.copyWith(
          busy: false,
          data: data,
          message: 'Tugas berhasil dikumpulkan. Menunggu penilaian.',
          submitted: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(busy: false, error: _msg(e)));
    }
  }

  String _msg(Object e) {
    final t = e.toString().replaceFirst('Exception: ', '');
    return t.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : t;
  }
}
