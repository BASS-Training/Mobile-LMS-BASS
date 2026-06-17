// Discussion module - DI untuk hub diskusi (feed agregat lintas course).
// Thread per-lesson tetap memakai DiscussionCubit dari LessonModule.
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/discussions/data/discussion_feed_repository.dart';
import 'package:lms_mobile_app/src/features/discussions/presentation/cubit/discussion_feed_cubit.dart';

class DiscussionModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<DiscussionFeedRepository>()) {
      return;
    }

    getIt.registerLazySingleton<DiscussionFeedRepository>(
      () => DiscussionFeedRepository(dio: getIt<Dio>()),
    );

    getIt.registerFactory<DiscussionFeedCubit>(
      () => DiscussionFeedCubit(repository: getIt<DiscussionFeedRepository>()),
    );
  }
}
