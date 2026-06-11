import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_navigation_mixin.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/essay/essay_page_header.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/essay/essay_panel_widget.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/essay/essay_side_panel_widget.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_app_bar.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/discussion/discussion_button.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

import '../bloc/essay/essay_bloc.dart';
import '../bloc/essay/essay_event.dart';
import '../bloc/essay/essay_state.dart';

class EssayLessonDetailScreen extends StatefulWidget {
  final LessonEntity lesson;
  final CourseEntity course;
  final int lessonIndex;

  const EssayLessonDetailScreen({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<EssayLessonDetailScreen> createState() =>
      _EssayLessonDetailScreenState();
}

class _EssayLessonDetailScreenState extends State<EssayLessonDetailScreen>
    with LessonNavigationMixin {
  late final TextEditingController _answerController;
  late final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _answerController = TextEditingController();

    // Tembak event inisialisasi
    context.read<EssayBloc>().add(
      LoadEssay(
        lessonId: widget.lesson.id,
        courseId: widget.course.id,
        courseTitle: widget.course.title,
        lessonTitle: widget.lesson.title,
        content: widget.lesson.content,
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _backToCourse() {
    Navigator.pop(context);
    context.read<CourseBloc>().add(const RefreshCoursesEvent());
  }

  @override
  CourseEntity get currentCourse => widget.course;

  @override
  int get currentLessonIndex => widget.lessonIndex;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _backToCourse();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: LessonAppBar(
          courseTitle: widget.course.title,
          subtitle: 'ESSAY',
          action: DiscussionIconButton(
            lessonId: widget.lesson.id,
            lessonTitle: widget.lesson.title,
          ),
          onBack: _backToCourse,
          onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        drawer: _buildDrawer(),
        body: BlocConsumer<EssayBloc, EssayState>(
          listenWhen: (previous, current) {
            // Sinkronisasi controller text jika index soal berubah
            if (previous.currentQuestionIndex != current.currentQuestionIndex) {
              _answerController.text = current.currentAnswer;
            }
            return true; // selalu listen untuk event lain
          },
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              context.read<EssayBloc>().add(ClearSnackbarMessage());
            }
            if (state.snackbarMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.snackbarMessage!)));
              context.read<EssayBloc>().add(ClearSnackbarMessage());
            }
            if (state.isSuccess) {
              context.read<LessonBloc>().add(
                MarkLessonCompleteEvent(lessonId: widget.lesson.id),
              );
              context.read<CourseBloc>().add(const RefreshCoursesEvent());

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jawaban essay berhasil dikirim.'),
                ),
              );

              if (state.lastAttempt != null) {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (!context.mounted) return;
                  context.push(
                    AppRoutes.essayResultDetail,
                    extra: state.lastAttempt,
                  );
                });
                return;
              }

              if (canGoNext && nextLesson != null) {
                Navigator.pop(context);
                Future.delayed(
                  const Duration(milliseconds: 200),
                  () => navigateToLesson(nextLesson!, widget.lessonIndex + 1),
                );
              }
            }
          },
          builder: (context, state) {
            // Pastikan controller sinkron di awal render
            if (_answerController.text != state.currentAnswer &&
                _answerController.text.isEmpty) {
              _answerController.text = state.currentAnswer;
            }

            return SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.surface, AppColors.background],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    _buildBackgroundDecorations(),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final useDesktopLayout = constraints.maxWidth >= 900;
                        final sidePanel = EssaySidePanelWidget(state: state);
                        final mainPanel = EssayPanelWidget(state: state, answerController: _answerController);
                        final header = EssayPageHeader();

                        if (!useDesktopLayout) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 190),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                header,
                                const SizedBox(height: 14),
                                _buildDescriptionCard(),
                                const SizedBox(height: 14),
                                sidePanel,
                                const SizedBox(height: 14),
                                mainPanel,
                              ],
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 190),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              header,
                              const SizedBox(height: 14),
                              _buildDescriptionCard(),
                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: sidePanel),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 8, child: mainPanel),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<EssayBloc, EssayState>(
          builder: (context, state) => _buildBottomActionBar(state),
        ),
      ),
    );
  }



  Widget _buildDrawer() {
    return LessonDrawer(
      course: widget.course,
      currentLessonIndex: widget.lessonIndex,
      onSelectLesson: (lesson, index) {
        final route = LessonRouteResolver.routeForType(lesson.type);
        Navigator.pop(context);
        context.push(
          route,
          extra: {
            'lesson': lesson,
            'course': widget.course,
            'lessonIndex': index,
          },
        );
      },
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.tomato.withValues(alpha: 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -70,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.red.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    final description = widget.lesson.content.trim();

    return FadeSlideIn(
      delayMs: 50,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF9FAFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: AppColors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deskripsi Lesson',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description.isNotEmpty
                        ? description
                        : 'Tidak ada deskripsi tambahan untuk lesson ini.',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBottomActionBar(EssayState state) {
    final canGoBackAction =
        state.currentQuestionIndex > 0 || previousLesson != null;

    void handlePreviousAction() {
      if (state.currentQuestionIndex > 0) {
        context.read<EssayBloc>().add(
          ChangeQuestion(state.currentQuestionIndex - 1),
        );
      } else if (previousLesson != null) {
        Navigator.pop(context);
        Future.delayed(
          const Duration(milliseconds: 200),
          () => navigateToLesson(previousLesson!, widget.lessonIndex - 1),
        );
      }
    }

    void handleSaveAndNext() {
      context.read<EssayBloc>().add(SaveDraftClicked());
      if (state.currentQuestionIndex < state.totalQuestions - 1) {
        context.read<EssayBloc>().add(
          ChangeQuestion(state.currentQuestionIndex + 1),
        );
      }
    }

    void handleContinueAfterSubmit() {
      if (canGoNext && nextLesson != null) {
        Navigator.pop(context);
        Future.delayed(
          const Duration(milliseconds: 200),
          () => navigateToLesson(nextLesson!, widget.lessonIndex + 1),
        );
      } else {
        _backToCourse();
      }
    }

    if (state.isSubmitted) {
      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.pearl.withValues(alpha: 0.9)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, -8),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _backToCourse,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: handleContinueAfterSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(canGoNext ? 'Lanjut' : 'Selesai'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.pearl.withValues(alpha: 0.9)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 22,
              offset: const Offset(0, -8),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.pearl,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: PressScale(
                    enabled: canGoBackAction,
                    child: OutlinedButton.icon(
                      onPressed: canGoBackAction ? handlePreviousAction : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Sebelumnya'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.pearl.withValues(alpha: 0.9),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.charcoal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PressScale(
                    child: ElevatedButton.icon(
                      onPressed: handleSaveAndNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shadowColor: AppColors.red.withValues(alpha: 0.45),
                        elevation: 8,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        state.currentQuestionIndex < state.totalQuestions - 1
                            ? 'Simpan & Lanjut'
                            : 'Simpan',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: PressScale(
                enabled: !state.isSubmitting,
                child: ElevatedButton.icon(
                  onPressed: state.isSubmitting
                      ? null
                      : () =>
                            context.read<EssayBloc>().add(SubmitEssayClicked()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    shadowColor: const Color(
                      0xFF16A34A,
                    ).withValues(alpha: 0.45),
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: state.isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    state.isSubmitting ? 'Mengirim...' : 'Kirim Semua Jawaban',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  