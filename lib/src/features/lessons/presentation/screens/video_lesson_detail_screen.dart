import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_actions.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_navigation_mixin.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/discussion/discussion_button.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_app_bar.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../bloc/video/video_bloc.dart';
import '../bloc/video/video_event.dart';
import '../bloc/video/video_state.dart';

class VideoLessonDetailScreen extends StatefulWidget {
  final LessonEntity lesson;
  final CourseEntity course;
  final int lessonIndex;

  const VideoLessonDetailScreen({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<VideoLessonDetailScreen> createState() =>
      _VideoLessonDetailScreenState();
}

class _VideoLessonDetailScreenState extends State<VideoLessonDetailScreen>
    with LessonNavigationMixin {
  late final YoutubePlayerController _controller;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _markedCompleteTriggered = false;

  String? _resolveYoutubeVideoId(String? source) {
    final value = source?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return YoutubePlayer.convertUrlToId(value) ?? value;
  }

  late GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  CourseEntity get currentCourse => widget.course;

  @override
  int get currentLessonIndex => widget.lessonIndex;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Inisiasi data ke BLoC
    context.read<VideoBloc>().add(
      InitVideoLesson(widget.lesson.id, widget.lesson.isCompleted),
    );

    final videoId = _resolveYoutubeVideoId(widget.lesson.youtubeVideoId) ?? '';
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        forceHD: true,
        controlsVisibleAtStart: true,
        disableDragSeek: false,
      ),
    );
    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    final value = _controller.value;
    final duration = value.metaData.duration;
    final position = value.position;

    if (duration.inSeconds > 0) {
      // Delegasikan perhitungan 10 detik ke BLoC
      context.read<VideoBloc>().add(
        VideoProgressUpdated(position.inSeconds, duration.inSeconds),
      );
    }

    // Eksekusi MarkComplete dibiarkan di sini karena bergantung pada LessonBloc global
    if (!_markedCompleteTriggered && value.playerState == PlayerState.ended) {
      _markedCompleteTriggered = true;
      if (!widget.lesson.isCompleted) {
        context.read<LessonBloc>().add(
          MarkLessonCompleteEvent(lessonId: widget.lesson.id),
        );
        context.read<CourseBloc>().add(const RefreshCoursesEvent());
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoId = widget.lesson.youtubeVideoId;

    if (videoId == null || videoId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: LessonAppBar(
          courseTitle: widget.course.title,
          subtitle: 'VIDEO PLAYER',
          onBack: () => popToCourse(context),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.pearl.withValues(alpha: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.ondemand_video_outlined,
                    size: 64,
                    color: AppColors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Video belum diatur untuk lesson ini',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.red,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.red,
          handleColor: AppColors.red,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: LessonDrawer(
            course: widget.course,
            currentLessonIndex: widget.lessonIndex,
            onSelectLesson: (lesson, index) {
              Navigator.pop(context); // tutup drawer
              navigateToLesson(lesson, index);
            },
          ),
          backgroundColor: AppColors.background,
          appBar: LessonAppBar(
            courseTitle: widget.course.title,
            subtitle: 'VIDEO PLAYER',
            onBack: () => popToCourse(context),
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            action: DiscussionIconButton(
              lessonId: widget.lesson.id,
              lessonTitle: widget.lesson.title,
            ),
          ),
          body: BlocBuilder<VideoBloc, VideoState>(
            builder: (context, state) {
              return SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.surface, AppColors.background],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FadeSlideIn(child: _buildHeroSummary()),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: player,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeSlideIn(
                                delayMs: 40,
                                child: _buildInfoCard(widget.lesson.title),
                              ),
                              const SizedBox(height: 16),
                              const SizedBox(height: 24),
                              _buildBottomButtons(state),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeroSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.crimson, AppColors.tomato],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.crimson.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lesson Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.lesson.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.lesson.isCompleted ? 'Completed' : 'In Progress',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(VideoState state) {
    final canProceed = state.canProceed || widget.lesson.isCompleted;

    void markAndNavigate({required bool goNext}) {
      if (!widget.lesson.isCompleted) {
        context.read<LessonBloc>().add(
          MarkLessonCompleteEvent(lessonId: widget.lesson.id),
        );
        context.read<CourseBloc>().add(const RefreshCoursesEvent());
      }
      // pushReplacement (di navigateToLesson) sudah mengganti layar ini.
      if (goNext && nextLesson != null) {
        navigateToLesson(nextLesson!, widget.lessonIndex + 1);
      } else {
        popToCourse(context);
      }
    }

    return Row(
      children: [
        if (canGoPrevious) ...[
          Expanded(
            child: PressScale(
              child: OutlinedButton.icon(
                onPressed: () =>
                    navigateToLesson(previousLesson!, widget.lessonIndex - 1),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Sebelumnya'),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: PressScale(
            child: ElevatedButton.icon(
              onPressed: canProceed
                  ? () => markAndNavigate(goNext: canGoNext)
                  : null,
              icon: Icon(
                canGoNext ? Icons.arrow_forward_rounded : Icons.check_rounded,
              ),
              label: Text(canGoNext ? 'Lanjut' : 'Selesai'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String lessonTitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lessonTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lessonTitle,
            style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.slate),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: AppColors.slate),
              const SizedBox(width: 6),
              Text(
                lessonTitle,
                style: TextStyle(fontSize: 12, color: AppColors.slate),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'VIDEO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
