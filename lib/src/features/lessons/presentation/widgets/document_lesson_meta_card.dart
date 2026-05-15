import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class DocumentLessonMetaCard extends StatelessWidget {
  final LessonEntity lesson;

  const DocumentLessonMetaCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.white, AppColors.ghostWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pearl.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Materi Pembelajaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.aliceBlue,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'DOCUMENT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.azure,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lesson.content.isNotEmpty
                ? lesson.content
                : 'Materi ini akan diisi dari backend. Untuk sementara, ini adalah teks dummy yang menjelaskan isi pembelajaran secara rapi dan terstruktur.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.8,
              color: AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }
}
