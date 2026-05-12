import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';

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
  State<VideoLessonDetailScreen> createState() => _VideoLessonDetailScreenState();
}

class _VideoLessonDetailScreenState extends State<VideoLessonDetailScreen> {
  late YoutubePlayerController _controller;
  final TextEditingController _commentController = TextEditingController();

  bool get canGoNext => widget.lessonIndex < widget.course.allLessons.length - 1;
  LessonEntity? get nextLesson => canGoNext ? widget.course.allLessons[widget.lessonIndex + 1] : null;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.lesson.youtubeVideoId ?? '',
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    )..addListener(_videoListener);

    context.read<VideoBloc>().add(LoadVideoContent(
      lessonId: widget.lesson.id,
      isCompleted: widget.lesson.isCompleted,
    ));
  }

  void _videoListener() {
    if (_controller.value.isReady) {
      context.read<VideoBloc>().add(UpdateVideoProgress(
            lessonId: widget.lesson.id,
            position: _controller.value.position,
            totalDuration: _controller.value.metaData.duration,
          ));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleNextLesson() {
    if (canGoNext && nextLesson != null) {
      final route = LessonRouteResolver.routeForType(nextLesson!.type);
      Navigator.pop(context); // Tutup screen saat ini
      context.push(
        route,
        extra: {
          'lesson': nextLesson,
          'course': widget.course,
          'lessonIndex': widget.lessonIndex + 1,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ini adalah materi terakhir dalam kursus ini.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoBloc, VideoState>(
      listener: (context, state) {
        if (state.isSuccessMarkComplete) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Progres video selesai, berhasil disimpan!")),
          );
          // Reset agar snackbar tidak muncul berkali-kali
          context.read<VideoBloc>().add(ResetSuccessMark()); 
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.course.title)),
          body: Column(
            children: [
              YoutubePlayerBuilder(
                player: YoutubePlayer(controller: _controller),
                builder: (context, player) {
                  return player;
                },
              ),
              Expanded(
                child: _buildDiscussionTab(state),
              ),
              _buildBottomAction(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiscussionTab(VideoState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Diskusi Materi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Tulis pertanyaan atau diskusi...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () {
                  if (_commentController.text.trim().isNotEmpty) {
                    context.read<VideoBloc>().add(SubmitComment(
                          lessonId: widget.lesson.id,
                          message: _commentController.text,
                        ));
                    _commentController.clear();
                    FocusScope.of(context).unfocus(); // Tutup keyboard
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.comments.isEmpty
                  ? const Center(child: Text("Belum ada diskusi."))
                  : ListView.builder(
                      itemCount: state.comments.length,
                      itemBuilder: (context, index) {
                        final comment = state.comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(comment.userName[0]),
                          ),
                          title: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(comment.message),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(VideoState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: ElevatedButton(
        onPressed: state.canProceed ? _handleNextLesson : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: state.canProceed ? Colors.blue : Colors.grey.shade300,
          foregroundColor: state.canProceed ? Colors.white : Colors.grey.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Lanjut ke Materi Berikutnya", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}