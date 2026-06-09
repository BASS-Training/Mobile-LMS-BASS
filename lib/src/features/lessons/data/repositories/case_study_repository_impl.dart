import 'dart:typed_data';

import 'package:lms_mobile_app/src/features/lessons/data/datasources/case_study_remote_datasource.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/case_study_repository.dart';

class CaseStudyRepositoryImpl implements CaseStudyRepository {
  final CaseStudyRemoteDataSource remoteDataSource;

  CaseStudyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CaseStudyEntity> getByLesson(String lessonId) {
    return remoteDataSource.getByLesson(lessonId);
  }

  @override
  Future<CaseStudySubmissionEntity> submit(
    String lessonId,
    Map<String, dynamic> answers,
  ) {
    return remoteDataSource.submit(lessonId, answers);
  }

  @override
  Future<void> saveDraft(String lessonId, Map<String, dynamic> answers) {
    return remoteDataSource.saveDraft(lessonId, answers);
  }

  @override
  Future<Uint8List> downloadPdf(String lessonId) {
    return remoteDataSource.downloadPdf(lessonId);
  }
}
