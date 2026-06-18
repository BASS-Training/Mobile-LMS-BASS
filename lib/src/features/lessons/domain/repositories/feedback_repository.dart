import 'package:lms_mobile_app/src/features/lessons/domain/entities/feedback_entity.dart';

abstract class FeedbackRepository {
  Future<FeedbackEntity> getByLesson(String lessonId);

  /// answers: questionId -> value — rating `int` / text `String` / single
  /// option id `String` / multi `List<String>`.
  Future<FeedbackSubmissionEntity> submit(
    String lessonId,
    Map<String, dynamic> answers,
  );
}
