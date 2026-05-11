import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/widgets/certificate_list_tile.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class CertificateListScreen extends StatelessWidget {
  const CertificateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Daftar Sertifikat')),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CourseLoaded) {
            final completedCourses = state.courses
                .where((c) => c.progressPercentage == 100)
                .toList();

            if (completedCourses.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada sertifkat. \nSelesaikan course hingga 100%',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: completedCourses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = completedCourses[index];
                return CertificateListTile(course: course);
              },
            );
          }

          if (state is CourseFailure) {
            return Center(child: Text(state.message));
          }
          // Build your UI based on the course state
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
