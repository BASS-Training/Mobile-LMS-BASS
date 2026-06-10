import 'package:equatable/equatable.dart';

abstract class CaseStudyEvent extends Equatable {
  const CaseStudyEvent();

  @override
  List<Object?> get props => [];
}

class LoadCaseStudy extends CaseStudyEvent {
  final String lessonId;
  const LoadCaseStudy(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class SubmitCaseStudy extends CaseStudyEvent {
  final String lessonId;
  final Map<String, dynamic> answers;
  const SubmitCaseStudy({required this.lessonId, required this.answers});

  @override
  List<Object?> get props => [lessonId, answers];
}

class SaveDraftCaseStudy extends CaseStudyEvent {
  final String lessonId;
  final Map<String, dynamic> answers;
  const SaveDraftCaseStudy({required this.lessonId, required this.answers});

  @override
  List<Object?> get props => [lessonId, answers];
}

class DownloadCaseStudyPdf extends CaseStudyEvent {
  final String lessonId;
  const DownloadCaseStudyPdf(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class ClearCaseStudyMessage extends CaseStudyEvent {
  const ClearCaseStudyMessage();
}
