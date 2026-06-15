// Instructor module - dependency injection untuk fitur instruktur/admin
// (peserta & progres, penilaian essay & studi kasus).
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/instructor/data/instructor_repository.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/case_study_grading_cubit.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/essay_grading_cubit.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/instructor_overview_cubit.dart';

class InstructorModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<InstructorRepository>()) {
      return;
    }

    getIt.registerLazySingleton<InstructorRepository>(
      () => InstructorRepository(dio: getIt<Dio>()),
    );

    getIt.registerFactory<InstructorDashboardCubit>(
      () => InstructorDashboardCubit(repository: getIt<InstructorRepository>()),
    );

    // Cubits — created per screen with the relevant id (courseId / submissionId).
    getIt.registerFactoryParam<ParticipantsCubit, String, void>(
      (courseId, _) => ParticipantsCubit(
        repository: getIt<InstructorRepository>(),
        courseId: courseId,
      ),
    );
    getIt.registerFactoryParam<GradingQueueCubit, String, void>(
      (courseId, _) => GradingQueueCubit(
        repository: getIt<InstructorRepository>(),
        courseId: courseId,
      ),
    );
    getIt.registerFactoryParam<EssayGradingCubit, String, void>(
      (submissionId, _) => EssayGradingCubit(
        repository: getIt<InstructorRepository>(),
        submissionId: submissionId,
      ),
    );
    getIt.registerFactoryParam<CaseStudyGradingCubit, String, void>(
      (submissionId, _) => CaseStudyGradingCubit(
        repository: getIt<InstructorRepository>(),
        submissionId: submissionId,
      ),
    );
  }
}
