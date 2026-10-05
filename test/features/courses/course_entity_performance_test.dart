import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_section_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';

void main() {
  test('allLessons memakai flat list yang sudah tersedia', () {
    final lessons = [_lesson('one'), _lesson('two', completed: true)];
    final course = _course(lessons: lessons, sections: const []);

    expect(course.allLessons, same(lessons));
    expect(course.completedLessons, 1);
    expect(course.totalLessons, 2);
  });

  test(
    'allLessons tetap mendukung entity lama yang hanya memiliki sections',
    () {
      final first = _lesson('one');
      final second = _lesson('two');
      final sections = [
        _section('section-1', [first]),
        _section('section-2', [second]),
      ];
      final course = _course(lessons: const [], sections: sections);

      expect(course.allLessons, [first, second]);
    },
  );

  test('indexed unlock memeriksa urutan dan prerequisite section', () {
    final first = _lesson('one', completed: true);
    final prerequisiteLesson = _lesson('two', completed: false);
    final target = _lesson('three');
    final prerequisite = _section('required', [prerequisiteLesson]);
    final targetSection = _section('target', [
      target,
    ], prerequisiteId: prerequisite.id);
    final lessons = [first, prerequisiteLesson, target];
    final course = _course(
      lessons: lessons,
      sections: [
        _section('intro', [first]),
        prerequisite,
        targetSection,
      ],
    );

    expect(
      course.isLessonUnlockedAt(
        2,
        sectionPrerequisiteMet: course.isSectionPrerequisiteMet(targetSection),
      ),
      isFalse,
    );

    final completedPrerequisite = prerequisite.copyWith(
      lessons: [prerequisiteLesson.copyWith(isCompleted: true)],
    );
    final completedLessons = [
      first,
      completedPrerequisite.lessons.single,
      target,
    ];
    final updatedTarget = _section('target', [
      target,
    ], prerequisiteId: completedPrerequisite.id);
    final updated = _course(
      lessons: completedLessons,
      sections: [
        _section('intro', [first]),
        completedPrerequisite,
        updatedTarget,
      ],
    );

    expect(
      updated.isLessonUnlockedAt(
        2,
        sectionPrerequisiteMet: updated.isSectionPrerequisiteMet(updatedTarget),
      ),
      isTrue,
    );
  });
}

LessonEntity _lesson(String id, {bool completed = false}) {
  return LessonEntity(
    id: id,
    courseId: 'course-1',
    title: id,
    content: '',
    duration: '1 menit',
    isCompleted: completed,
  );
}

CourseSectionEntity _section(
  String id,
  List<LessonEntity> lessons, {
  String? prerequisiteId,
}) {
  return CourseSectionEntity(
    id: id,
    courseId: 'course-1',
    sectionNumber: 1,
    title: id,
    description: '',
    lessons: lessons,
    prerequisiteId: prerequisiteId,
  );
}

CourseEntity _course({
  required List<LessonEntity> lessons,
  required List<CourseSectionEntity> sections,
}) {
  return CourseEntity(
    id: 'course-1',
    title: 'Course',
    description: '',
    instructor: 'Instructor',
    color: '',
    icon: '',
    chaptersCount: sections.length,
    duration: '',
    sections: sections,
    lessons: lessons,
  );
}
