import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import '../../domain/entities/course_entity.dart';

/// Quick-facts shown under the course hero: instructor(s) and lesson count.
/// (Duration already lives in the header, so it isn't repeated here.)
class CourseInfoCards extends StatelessWidget {
  final CourseEntity course;

  const CourseInfoCards({super.key, required this.course});

  /// A course can be taught by more than one instructor. The backend sends them
  /// in a single string, so split on the usual separators (comma, semicolon,
  /// ampersand, slash) and drop the blanks.
  List<String> get _instructors {
    final raw = course.instructor.trim();
    if (raw.isEmpty) return const [];
    return raw
        .split(RegExp(r'\s*[,;&/]\s*'))
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InstructorCard(instructors: _instructors),
        const SizedBox(height: 12),
        _StatCard(
          icon: Icons.menu_book_rounded,
          accent: AppColors.info,
          label: 'Total Lesson',
          value: '${course.totalLessons} lesson',
        ),
      ],
    );
  }
}

/// Full-width card that lists every instructor with an avatar + full name.
/// Names wrap instead of being truncated, so they always stay readable.
class _InstructorCard extends StatelessWidget {
  final List<String> instructors;

  const _InstructorCard({required this.instructors});

  @override
  Widget build(BuildContext context) {
    final hasMany = instructors.length > 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Instruktur',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              if (hasMany) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${instructors.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (instructors.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 2),
              child: Text(
                'Belum ada instruktur',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
            )
          else
            ...instructors.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == instructors.length - 1 ? 0 : 10,
                ),
                child: _InstructorTile(name: entry.value),
              ),
            ),
        ],
      ),
    );
  }
}

/// A single instructor: initials avatar + full (wrapping) name.
class _InstructorTile extends StatelessWidget {
  final String name;

  const _InstructorTile({required this.name});

  String get _initials {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.brandPrimary,
                AppColors.brandPrimaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Text(
            _initials,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-width horizontal stat row (icon + label on the left, value on the right).
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
