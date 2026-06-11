import 'package:lms_mobile_app/src/features/lessons/data/datasources/feedback_remote_datasource.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/feedback_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;

  FeedbackRepositoryImpl({required this.remoteDataSource});

  @override
  Future<FeedbackEntity> getByLesson(String lessonId) {
    return remoteDataSource.getByLesson(lessonId);
  }

  @override
  Future<FeedbackSubmissionEntity> submit(
    String lessonId,
    Map<String, dynamic> answers,
  ) {
    return remoteDataSource.submit(lessonId, answers);
  }
}
