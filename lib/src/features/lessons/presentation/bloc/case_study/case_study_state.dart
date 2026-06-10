import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';

enum CaseStudyStatus { initial, loading, loaded, error }

class CaseStudyState extends Equatable {
  final CaseStudyStatus status;
  final CaseStudyEntity? data;
  final bool submitting;
  final bool draftSaving;
  final bool downloading;
  final bool justSubmitted;
  final Uint8List? pdfBytes;
  final String? errorMessage;
  final String? infoMessage;

  const CaseStudyState({
    this.status = CaseStudyStatus.initial,
    this.data,
    this.submitting = false,
    this.draftSaving = false,
    this.downloading = false,
    this.justSubmitted = false,
    this.pdfBytes,
    this.errorMessage,
    this.infoMessage,
  });

  CaseStudyState copyWith({
    CaseStudyStatus? status,
    CaseStudyEntity? data,
    bool? submitting,
    bool? draftSaving,
    bool? downloading,
    bool? justSubmitted,
    Uint8List? pdfBytes,
    String? errorMessage,
    String? infoMessage,
    bool clearMessages = false,
    bool clearPdf = false,
  }) {
    return CaseStudyState(
      status: status ?? this.status,
      data: data ?? this.data,
      submitting: submitting ?? this.submitting,
      draftSaving: draftSaving ?? this.draftSaving,
      downloading: downloading ?? this.downloading,
      justSubmitted: justSubmitted ?? this.justSubmitted,
      pdfBytes: clearPdf ? null : (pdfBytes ?? this.pdfBytes),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearMessages ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    data,
    submitting,
    draftSaving,
    downloading,
    justSubmitted,
    pdfBytes,
    errorMessage,
    infoMessage,
  ];
}
