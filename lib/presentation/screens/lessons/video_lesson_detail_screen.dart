import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lms_mobile_app/config/theme.dart';
import 'package:lms_mobile_app/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/utils/constants.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_event.dart';

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
  bool _canProceed = false;
  bool get canGoNext =>
      widget.lessonIndex < widget.course.allLessons.length - 1;
  bool get canGoPrevious => widget.lessonIndex > 0;

  LessonEntity? get nextLesson =>
      canGoNext ? widget.course.allLessons[widget.lessonIndex + 1] : null;
  LessonEntity? get previousLesson =>
      canGoPrevious ? widget.course.allLessons[widget.lessonIndex - 1] : null;

  late GlobalKey<ScaffoldState> _scaffoldKey;

  final List<_DiscussionComment> _comments = [
    _DiscussionComment(
      userName: 'Andi',
      message: 'Materinya jelas dan mudah dipahami.',
      timeLabel: '2 menit lalu',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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
    _canProceed = widget.lesson.isCompleted;
  }

  void _videoListener() {
    final value = _controller.value;

    // update progress threshold (safe-guard kalau duration belum tersedia)
    final duration = value.metaData.duration;
    final position = value.position;

    if (duration != null && duration.inSeconds > 0) {
      final remaining = duration - position;
      final reachedThreshold =
          remaining.inSeconds <= 10 ||
          position.inSeconds >= (duration.inSeconds - 10);

      if (reachedThreshold && !_canProceed) {
        setState(() => _canProceed = true);
      }
    }

    // jika video berakhir, tandai complete (existing)
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

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(
        0,
        _DiscussionComment(
          userName: 'Anda',
          message: text,
          timeLabel: 'Baru saja',
        ),
      );
    });
    _commentController.clear();
  }

  void _openLesson(LessonEntity lesson, int lessonIndex) {
    final route = lesson.type.toLowerCase() == 'video'
        ? AppConstants.routeLessonVideoDetail
        : AppConstants.routeLessonDocumentDetail;

    Navigator.pushNamed(
      context,
      route,
      arguments: {
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
      print('Video Id : $videoId');
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Video Lesson')),
        body: const Center(child: Text('Video belum diatur untuk lesson ini')),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primary,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: LessonDrawer(
            course: widget.course,
            currentLessonIndex: widget.lessonIndex,
            onSelectLesson: (lesson, index) {
              final route = lesson.type.toLowerCase() == 'video'
                  ? AppConstants.routeLessonVideoDetail
                  : AppConstants.routeLessonDetail;
              Navigator.pop(
                context,
              ); // close drawer (LessonDrawer already closes, but safe)
              Navigator.pushNamed(
                context,
                route,
                arguments: {
                  'lesson': lesson,
                  'course': widget.course,
                  'lessonIndex': index,
                },
              );
            },
          ),
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.course.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                            Text(
                              widget.lesson.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.list_alt),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRect(
                    // borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(aspectRatio: 16 / 9, child: player),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(widget.lesson.title),
                        const SizedBox(height: 16),
                        _buildDiscussionCard(),
                        const SizedBox(height: 16),
                        const Text(
                          'Komentar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._comments.map(_buildCommentItem),
                        const SizedBox(height: 24),
                        //Navigation buttons
                        Row(
                          children: [
                            if (canGoPrevious)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Future.delayed(
                                      const Duration(milliseconds: 200),
                                      () {
                                        _openLesson(
                                          previousLesson!,
                                          widget.lessonIndex - 1,
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('previous'),
                                ),
                              ),
                            if (canGoPrevious && canGoNext)
                              const SizedBox(width: 12),
                            if (canGoNext)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      (!_canProceed &&
                                          !widget.lesson.isCompleted)
                                      ? null
                                      : () {
                                          // jika belum complete, tandai dulu
                                          if (!widget.lesson.isCompleted) {
                                            context.read<LessonBloc>().add(
                                              MarkLessonCompleteEvent(
                                                lessonId: widget.lesson.id,
                                              ),
                                            );
                                            context.read<CourseBloc>().add(
                                              const RefreshCoursesEvent(),
                                            );
                                          }
                                          Navigator.pop(context);
                                          Future.delayed(
                                            const Duration(milliseconds: 200),
                                            () {
                                              _openLesson(
                                                nextLesson!,
                                                widget.lessonIndex + 1,
                                              );
                                            },
                                          );
                                        },
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Next'),
                                ),
                              ),
                            // if (!_canProceed && !widget.lesson.isCompleted)
                            //   Padding(
                            //     padding: const EdgeInsets.only(top: 8.0),
                            //     child: Text(
                            //       'Tonton sampai 10 detik terakhir untuk melanjutkan',
                            //       style: TextStyle(
                            //         fontSize: 12,
                            //         color: AppColors.textLight,
                            //       ),
                            //     ),
                            //   ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String lessonTitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lessonTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lessonTitle,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.timer, size: 16, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(
                lessonTitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
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

  Widget _buildDiscussionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diskusi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tulis komentar Anda di sini...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Kirim Komentar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(_DiscussionComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              comment.userName.characters.first.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscussionComment {
  final String userName;
  final String message;
  final String timeLabel;

  _DiscussionComment({
    required this.userName,
    required this.message,
    required this.timeLabel,
  });
}
