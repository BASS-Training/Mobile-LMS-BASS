import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/discussion_card.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Sesuaikan path import widget ini dengan lokasi foldermu
import '../widgets/comment_item_widget.dart';
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

class _VideoLessonDetailScreenState extends State<VideoLessonDetailScreen> {
  late final YoutubePlayerController _controller;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _markedCompleteTriggered = false;

  bool get canGoNext =>
      widget.lessonIndex < widget.course.allLessons.length - 1;
  bool get canGoPrevious => widget.lessonIndex > 0;

  LessonEntity? get nextLesson =>
      canGoNext ? widget.course.allLessons[widget.lessonIndex + 1] : null;
  LessonEntity? get previousLesson =>
      canGoPrevious ? widget.course.allLessons[widget.lessonIndex - 1] : null;

  late GlobalKey<ScaffoldState> _scaffoldKey;

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

    final videoId = widget.lesson.youtubeVideoId ?? '';
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
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openLesson(LessonEntity lesson, int lessonIndex) {
    final route = LessonRouteResolver.routeForType(lesson.type);
    context.push(
      route,
      extra: {
        'lesson': lesson,
        'course': widget.course,
        'lessonIndex': lessonIndex,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoId = widget.lesson.youtubeVideoId;

    if (videoId == null || videoId.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F8FF),
        appBar: AppBar(
          title: const Text('Video Lesson'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6D5EF7), Color(0xFF4F8CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8FAFF), Color(0xFFF1F4FF)],
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
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.ondemand_video_outlined,
                    size: 64,
                    color: AppColors.violet,
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
        progressIndicatorColor: AppColors.violet,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.violet,
          handleColor: AppColors.violet,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: LessonDrawer(
            course: widget.course,
            currentLessonIndex: widget.lessonIndex,
            onSelectLesson: (lesson, index) {
              final route = LessonRouteResolver.routeForType(lesson.type);
              context.push(
                route,
                extra: {
                  'lesson': lesson,
                  'course': widget.course,
                  'lessonIndex': index,
                },
              );
            },
          ),
          backgroundColor: const Color(0xFFF6F8FF),
          appBar: AppBar(
            title: Text(widget.course.title),
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6D5EF7), Color(0xFF4F8CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: const Icon(Icons.list_alt, size: 24),
                  ),
                ),
              ),
            ],
          ),
          body: BlocBuilder<VideoBloc, VideoState>(
            builder: (context, state) {
              return SafeArea(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF8FAFF), Color(0xFFF1F4FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildHeroSummary(),
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
                              _buildInfoCard(widget.lesson.title),
                              const SizedBox(height: 16),
                              DiscussionCard(
                                onSend: (komentarTeks) {
                                  // Eksekusi BLoC spesifik untuk Video Lesson di sini
                                  context.read<VideoBloc>().add(
                                    SubmitDiscussionComment(
                                      widget.lesson.id,
                                      komentarTeks,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Komentar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // IMPLEMENTASI WIDGET KOMENTAR DI SINI
                              ...state.comments.map(
                                (comment) =>
                                    CommentItemWidget(comment: comment),
                              ),

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
          colors: [Color(0xFF6D5EF7), Color(0xFF4F8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5EF7).withValues(alpha: 0.18),
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
    return Row(
      children: [
        if (canGoPrevious)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 200), () {
                  _openLesson(previousLesson!, widget.lessonIndex - 1);
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            ),
          ),
        if (canGoPrevious && canGoNext) const SizedBox(width: 12),
        if (canGoNext)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: (!state.canProceed && !widget.lesson.isCompleted)
                  ? null
                  : () {
                      if (!widget.lesson.isCompleted) {
                        context.read<LessonBloc>().add(
                          MarkLessonCompleteEvent(lessonId: widget.lesson.id),
                        );
                        context.read<CourseBloc>().add(
                          const RefreshCoursesEvent(),
                        );
                      }
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 200), () {
                        _openLesson(nextLesson!, widget.lessonIndex + 1);
                      });
                    },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
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
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lessonTitle,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.slate,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.timer, size: 16, color: AppColors.slate),
              const SizedBox(width: 6),
              Text(
                lessonTitle,
                style: const TextStyle(fontSize: 12, color: AppColors.slate),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'VIDEO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
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
