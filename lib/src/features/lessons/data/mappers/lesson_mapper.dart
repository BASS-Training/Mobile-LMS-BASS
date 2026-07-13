import '../../domain/entities/lesson_entity.dart';
import '../models/lesson.dart';

class LessonMapper {
  static LessonEntity toDomain(Lesson model) {
    return LessonEntity(
      id: model.id,
      courseId: model.courseId,
      title: model.title,
      content: model.content,
      duration: model.duration,
      type: model.type,
      isCompleted: model.isCompleted,
      youtubeVideoId: model.youtubeVideoId,
      documentUrl: model.documentUrl,
      imageUrls: model.imageUrls,
      zoomLink: model.zoomLink,
      zoomMeetingId: model.zoomMeetingId,
      zoomPassword: model.zoomPassword,
      scheduledStart: model.scheduledStart,
      scheduledEnd: model.scheduledEnd,
      attendanceRequired: model.attendanceRequired,
      minAttendanceMinutes: model.minAttendanceMinutes,
      attendanceNotes: model.attendanceNotes,
      attendanceStatus: model.attendanceStatus,
      collectSubmission: model.collectSubmission,
      requireSubmissionPass: model.requireSubmissionPass,
      submissionStatus: model.submissionStatus,
    );
  }

  static Lesson fromDomain(LessonEntity entity) {
    return Lesson(
      id: entity.id,
      courseId: entity.courseId,
      title: entity.title,
      content: entity.content,
      duration: entity.duration,
      type: entity.type,
      isCompleted: entity.isCompleted,
      youtubeVideoId: entity.youtubeVideoId,
      documentUrl: entity.documentUrl,
      imageUrls: entity.imageUrls,
      zoomLink: entity.zoomLink,
      zoomMeetingId: entity.zoomMeetingId,
      zoomPassword: entity.zoomPassword,
      scheduledStart: entity.scheduledStart,
      scheduledEnd: entity.scheduledEnd,
      attendanceRequired: entity.attendanceRequired,
      minAttendanceMinutes: entity.minAttendanceMinutes,
      attendanceNotes: entity.attendanceNotes,
      attendanceStatus: entity.attendanceStatus,
      collectSubmission: entity.collectSubmission,
      requireSubmissionPass: entity.requireSubmissionPass,
      submissionStatus: entity.submissionStatus,
    );
  }
}
