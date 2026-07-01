import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';

/// Mixin untuk menangani logika navigasi antar lesson (Next/Previous).
/// Tambahkan mixin ini ke `State<T>` dari screen lesson Anda.
mixin LessonNavigationMixin<T extends StatefulWidget> on State<T> {
  // Memaksa screen yang menggunakan mixin ini untuk menyediakan data course dan index
  CourseEntity get currentCourse;
  int get currentLessonIndex;

  // --- Getters Navigasi ---

  bool get canGoNext =>
      currentLessonIndex < currentCourse.allLessons.length - 1;

  bool get canGoPrevious => currentLessonIndex > 0;

  LessonEntity? get nextLesson =>
      canGoNext ? currentCourse.allLessons[currentLessonIndex + 1] : null;

  LessonEntity? get previousLesson =>
      canGoPrevious ? currentCourse.allLessons[currentLessonIndex - 1] : null;

  // --- Fungsi Eksekusi Pindah Halaman ---

  /// Membuka lesson tertentu (digunakan untuk Next, Previous, atau dari Drawer).
  ///
  /// Memakai [GoRouter.pushReplacement] (bukan push) agar layar lesson tidak
  /// menumpuk di stack: hanya ada satu layar lesson di atas halaman course pada
  /// satu waktu. Dengan begitu tombol "kembali" dari lesson manapun selalu
  /// mengembalikan ke halaman course, bukan ke lesson yang dibuka sebelumnya.
  void navigateToLesson(LessonEntity lesson, int lessonIndex) {
    final route = LessonRouteResolver.routeForType(lesson.type);

    context.pushReplacement(
      route,
      extra: {
        'lesson': lesson,
        'course':
            currentCourse, // Note: Nanti di fase Arsitektur ini akan kita ubah
        'lessonIndex': lessonIndex,
      },
    );
  }
}
