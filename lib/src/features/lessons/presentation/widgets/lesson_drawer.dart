import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_section_entity.dart'; // Pastikan import ini ditambahkan
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class LessonDrawer extends StatelessWidget {
  final CourseEntity course;
  final int currentLessonIndex;
  final void Function(LessonEntity lesson, int index) onSelectLesson;

  const LessonDrawer({
    super.key,
    required this.course,
    required this.currentLessonIndex,
    required this.onSelectLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            // Header Drawer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Lessons',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${course.allLessons.length} lessons',
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Body: List of Sections
            Expanded(
              child: ListView.builder(
                itemCount: course.sections.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, sectionIndex) {
                  final section = course.sections[sectionIndex];
                  
                  // Menghitung progress per section
                  int completedCount = section.lessons.where((l) => l.isCompleted).length;
                  int totalCount = section.lessons.length;
                  double progressPercent = totalCount > 0 ? completedCount / totalCount : 0.0;

                  // Mengecek apakah lesson saat ini ada di dalam section ini
                  // Jika iya, maka section ini akan otomatis terbuka (expanded)
                  bool isSectionActive = section.lessons.any(
                      (l) => course.allLessons.indexOf(l) == currentLessonIndex);

                  return Theme(
                    // Menghilangkan garis border default bawaan ExpansionTile
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: isSectionActive,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Row(
                        children: [
                          // Ikon Angka Section (Kotak Rounded)
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${section.sectionNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Judul Section & Progress Bar
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  section.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progressPercent,
                                          minHeight: 4,
                                          backgroundColor: AppColors.border,
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$completedCount/$totalCount',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Looping untuk merender Lesson di dalam Section
                      children: section.lessons.map((lesson) {
                        // Kita butuh index global untuk menandai current state
                        final globalIndex = course.allLessons.indexOf(lesson);
                        return _buildLessonItem(context, lesson, globalIndex);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dipisah menjadi widget tersendiri agar kode lebih rapi
  Widget _buildLessonItem(BuildContext context, LessonEntity lesson, int globalIndex) {
    final isCurrent = globalIndex == currentLessonIndex;
    final isUnlocked = _isLessonUnlocked(lesson, course);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        // Jika terpilih, beri background transparan warna ungu (menyesuaikan gambar UI)
        color: isCurrent ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? AppColors.primary : AppColors.border,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCurrent || !isUnlocked
              ? null
              : () {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    onSelectLesson(lesson, globalIndex);
                  });
                },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Ikon Status Lesson (Check/Lock/Angka)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Warna icon logic seperti di gambar referensi
                    color: lesson.isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : isCurrent
                            ? AppColors.primary
                            : AppColors.background,
                    border: !lesson.isCompleted && !isCurrent
                        ? Border.all(color: AppColors.border)
                        : null,
                  ),
                  child: Center(
                    child: lesson.isCompleted
                        ? const Icon(Icons.check, color: Colors.green, size: 16)
                        : isUnlocked
                            ? Text(
                                '${globalIndex + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? Colors.white : AppColors.textLight,
                                  fontSize: 12,
                                ),
                              )
                            : const Icon(Icons.lock, color: Colors.grey, size: 14),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Info Lesson (Tipe, Judul)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isCurrent
                              ? AppColors.primary
                              : isUnlocked
                                  ? AppColors.text
                                  : Colors.grey,
                          decoration: lesson.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            lesson.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? AppColors.textLight : Colors.grey.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  ${lesson.duration}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isUnlocked ? AppColors.textLight : Colors.grey.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Badge "Now" jika sedang dibuka
                if (isCurrent)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Now',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isLessonUnlocked(LessonEntity lesson, CourseEntity course) {
    final lessonIndex = course.allLessons.indexOf(lesson);

    // Lesson pertama selalu bisa dibuka
    if (lessonIndex == 0) return true;

    // Cek apakah lesson sebelumnya sudah selesai
    final previousLesson = course.allLessons[lessonIndex - 1];
    return previousLesson.isCompleted;
  }
}