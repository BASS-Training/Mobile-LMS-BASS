import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';

/// Ambil daftar course dari cache lokal (disk) saja, tanpa menyentuh jaringan.
/// Dipakai untuk menampilkan data terakhir secara instan (cache-first) sebelum
/// refresh dari API. Mengembalikan list kosong bila belum ada cache.
class GetCachedCoursesUseCase {
  final CourseRepository repository;

  GetCachedCoursesUseCase(this.repository);

  Future<List<CourseEntity>> call() async {
    return await repository.getCachedCourses();
  }
}
