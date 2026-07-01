import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_actions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_navigation_mixin.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/attendance/attendance_status_banner.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_app_bar.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/discussion/discussion_button.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_navigation_bar.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

enum _ZoomStatus { available, upcoming, active, ended }

class ZoomLessonDetailScreen extends StatefulWidget {
  final LessonEntity lesson;
  final CourseEntity course;
  final int lessonIndex;

  const ZoomLessonDetailScreen({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<ZoomLessonDetailScreen> createState() => _ZoomLessonDetailScreenState();
}

class _ZoomLessonDetailScreenState extends State<ZoomLessonDetailScreen>
    with LessonNavigationMixin {
  late final GlobalKey<ScaffoldState> _scaffoldKey;

  static const _accent = AppColors.brandPrimary;
  static const _accentDark = AppColors.brandPrimaryDark;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  CourseEntity get currentCourse => widget.course;

  @override
  int get currentLessonIndex => widget.lessonIndex;

  // ── Helpers ─────────────────────────────────────────────────────────────────

  _ZoomStatus get _scheduleStatus {
    final startStr = widget.lesson.scheduledStart;
    final endStr = widget.lesson.scheduledEnd;

    if (startStr == null || startStr.isEmpty) return _ZoomStatus.available;

    final start = DateTime.tryParse(startStr);
    if (start == null) return _ZoomStatus.available;

    final now = DateTime.now();
    if (now.isBefore(start)) return _ZoomStatus.upcoming;

    final end = endStr != null ? DateTime.tryParse(endStr) : null;
    if (end != null && now.isAfter(end)) return _ZoomStatus.ended;

    return _ZoomStatus.active;
  }

  bool get _canJoin {
    final status = _scheduleStatus;
    final hasLink = (widget.lesson.zoomLink ?? '').isNotEmpty;
    return hasLink &&
        (status == _ZoomStatus.available || status == _ZoomStatus.active);
  }

  Future<void> _joinMeeting() async {
    final link = widget.lesson.zoomLink?.trim() ?? '';
    if (link.isEmpty) return;

    final uri = Uri.tryParse(link);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link meeting tidak valid.')),
      );
      return;
    }

    // Tandai lesson selesai saat user bergabung
    if (!widget.lesson.isCompleted) {
      context.read<LessonBloc>().add(
        MarkLessonCompleteEvent(lessonId: widget.lesson.id),
      );
      context.read<CourseBloc>().add(const RefreshCoursesEvent());
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        // Fallback: salin link ke clipboard
        _copyToClipboard(link, 'Link meeting');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak bisa membuka browser. Link disalin ke clipboard.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      // Fallback: salin link ke clipboard
      _copyToClipboard(link, 'Link meeting');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak bisa membuka link. Link disalin ke clipboard.'),
        ),
      );
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label disalin ke clipboard')));
  }

  Future<void> _markComplete({bool goToNext = false}) async {
    if (!widget.lesson.isCompleted) {
      context.read<LessonBloc>().add(
        MarkLessonCompleteEvent(lessonId: widget.lesson.id),
      );
      context.read<CourseBloc>().add(const RefreshCoursesEvent());
    }

    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    if (goToNext && nextLesson != null) {
      // pushReplacement (di navigateToLesson) sudah mengganti layar lesson ini.
      navigateToLesson(nextLesson!, widget.lessonIndex + 1);
      return;
    }

    popToCourse(context);
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: LessonDrawer(
        course: widget.course,
        currentLessonIndex: widget.lessonIndex,
        onSelectLesson: (lesson, index) {
          Navigator.pop(context); // tutup drawer
          navigateToLesson(lesson, index);
        },
      ),
      appBar: LessonAppBar(
        courseTitle: widget.course.title,
        subtitle: 'ZOOM MEETING',
        action: DiscussionIconButton(
          lessonId: widget.lesson.id,
          lessonTitle: widget.lesson.title,
        ),
        gradientColors: const [_accent, _accentDark],
        onBack: () {
          popToCourse(context);
        },
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: LessonNavigationBar(
            canGoPrevious: canGoPrevious,
            canGoNext: canGoNext,
            primaryColor: _accent,
            forwardBlocked: canGoNext && widget.lesson.attendancePending,
            blockedReason: AttendanceInfo.blockedReason(widget.lesson),
            onPrevious: canGoPrevious
                ? () => navigateToLesson(
                    previousLesson!,
                    widget.lessonIndex - 1,
                  )
                : null,
            onForward: () => _markComplete(goToNext: canGoNext),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.lesson.attendanceRequired) ...[
                AttendanceStatusBanner(lesson: widget.lesson),
                const SizedBox(height: 16),
              ],
              _buildHeroCard(),
              const SizedBox(height: 16),
              if (widget.lesson.scheduledStart != null) ...[
                _buildScheduleCard(),
                const SizedBox(height: 16),
              ],
              _buildMeetingInfoCard(),
              const SizedBox(height: 20),
              _buildJoinButton(),
              const SizedBox(height: 8),
              if (widget.lesson.content.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDescriptionCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget Builders ───────────────────────────────────────────────────────────

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_accent, _accentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.videocam_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rapat Online via Zoom',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.lesson.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = _scheduleStatus;
    final Color color;
    final String label;
    final IconData icon;

    switch (status) {
      case _ZoomStatus.active:
        color = Colors.green;
        label = 'Live';
        icon = Icons.circle;
      case _ZoomStatus.upcoming:
        color = Colors.orange;
        label = 'Segera';
        icon = Icons.schedule_rounded;
      case _ZoomStatus.ended:
        color = Colors.red.shade300;
        label = 'Berakhir';
        icon = Icons.cancel_outlined;
      case _ZoomStatus.available:
        color = Colors.white.withValues(alpha: 0.85);
        label = 'Tersedia';
        icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    final status = _scheduleStatus;
    final startStr = widget.lesson.scheduledStart;
    final endStr = widget.lesson.scheduledEnd;

    final start = startStr != null ? DateTime.tryParse(startStr) : null;
    final end = endStr != null ? DateTime.tryParse(endStr) : null;

    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String title;
    String subtitle;

    switch (status) {
      case _ZoomStatus.active:
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade200;
        iconColor = Colors.green.shade700;
        icon = Icons.play_circle_filled_rounded;
        title = 'Meeting Sedang Berlangsung';
        subtitle = end != null
            ? 'Berakhir pukul ${_formatTime(end)}'
            : 'Sedang aktif';
      case _ZoomStatus.upcoming:
        bgColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade200;
        iconColor = Colors.orange.shade700;
        icon = Icons.schedule_rounded;
        title = 'Meeting Belum Dimulai';
        subtitle = start != null
            ? 'Mulai ${_formatDateTime(start)}'
            : 'Jadwal belum ditentukan';
      case _ZoomStatus.ended:
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade200;
        iconColor = Colors.red.shade700;
        icon = Icons.cancel_rounded;
        title = 'Meeting Telah Berakhir';
        subtitle = end != null
            ? 'Berakhir ${_formatDateTime(end)}'
            : 'Meeting sudah selesai';
      case _ZoomStatus.available:
        bgColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade200;
        iconColor = _accent;
        icon = Icons.check_circle_rounded;
        title = 'Meeting Tersedia';
        subtitle = 'Dapat bergabung kapan saja';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingInfoCard() {
    final meetingId = widget.lesson.zoomMeetingId ?? '';
    final password = widget.lesson.zoomPassword ?? '';
    final link = widget.lesson.zoomLink ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: _accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Detail Meeting',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (meetingId.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildInfoRow(
              icon: Icons.tag_rounded,
              label: 'Meeting ID',
              value: meetingId,
              onCopy: () => _copyToClipboard(meetingId, 'Meeting ID'),
            ),
          ],
          if (password.isNotEmpty) ...[
            const Divider(height: 20),
            _buildInfoRow(
              icon: Icons.lock_outline_rounded,
              label: 'Password',
              value: password,
              onCopy: () => _copyToClipboard(password, 'Password'),
            ),
          ],
          if (link.isNotEmpty) ...[
            const Divider(height: 20),
            _buildInfoRow(
              icon: Icons.link_rounded,
              label: 'Link Meeting',
              value: link,
              onCopy: () => _copyToClipboard(link, 'Link meeting'),
              truncate: true,
            ),
          ],
          if (meetingId.isEmpty && password.isEmpty && link.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Detail meeting belum tersedia. Silakan hubungi instruktur.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onCopy,
    bool truncate = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                truncate && value.length > 40
                    ? '${value.substring(0, 40)}...'
                    : value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onCopy,
          icon: Icon(
            Icons.copy_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Salin',
        ),
      ],
    );
  }

  Widget _buildJoinButton() {
    final canJoin = _canJoin;
    final status = _scheduleStatus;

    String label;
    IconData icon;

    if (!canJoin) {
      if (status == _ZoomStatus.ended) {
        label = 'Meeting Telah Berakhir';
        icon = Icons.cancel_rounded;
      } else if (status == _ZoomStatus.upcoming) {
        label = 'Meeting Belum Dimulai';
        icon = Icons.schedule_rounded;
      } else {
        label = 'Link Belum Tersedia';
        icon = Icons.link_off_rounded;
      }
    } else {
      label = 'Gabung Sekarang';
      icon = Icons.video_call_rounded;
    }

    return SizedBox(
      width: double.infinity,
      child: PressScale(
        enabled: canJoin,
        child: ElevatedButton.icon(
          onPressed: canJoin ? _joinMeeting : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canJoin ? _accent : Colors.grey.shade300,
            foregroundColor: canJoin ? Colors.white : Colors.grey.shade600,
            shadowColor: canJoin
                ? _accent.withValues(alpha: 0.4)
                : Colors.transparent,
            elevation: canJoin ? 10 : 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: Icon(icon, size: 22),
          label: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderDefault.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: _accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.lesson.content.trim(),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Formatting Helpers ────────────────────────────────────────────────────────

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')} WIB';
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${local.day} ${months[local.month]} ${local.year}, ${_formatTime(local)}';
  }
}
