import 'dart:typed_data';

import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';

abstract class CaseStudyRepository {
  Future<CaseStudyEntity> getByLesson(String lessonId);

  Future<CaseStudySubmissionEntity> submit(
    String lessonId,
    Map<String, dynamic> answers,
  );

  Future<void> saveDraft(String lessonId, Map<String, dynamic> answers);

  Future<Uint8List> downloadPdf(String lessonId);
}
