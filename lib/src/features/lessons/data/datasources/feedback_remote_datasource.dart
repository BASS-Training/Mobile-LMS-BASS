import 'package:lms_mobile_app/src/features/lessons/domain/entities/feedback_entity.dart';

abstract class FeedbackRemoteDataSource {
  Future<FeedbackEntity> getByLesson(String lessonId);

  Future<FeedbackSubmissionEntity> submit(
    String lessonId,
    Map<String, dynamic> answers,
  );
}
