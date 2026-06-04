import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';

import '../../bloc/discussion/discussion_cubit.dart';
import '../../bloc/discussion/discussion_state.dart';
import 'discussion_sheet.dart';

/// Uniform app-bar action that opens the discussion panel for a lesson.
///
/// Owns one [DiscussionCubit] for the lesson (loads the count on init, shown as
/// a badge) and reuses it when opening the discussion bottom sheet. Designed to
/// sit in [LessonAppBar.action] so every lesson type triggers discussion the
/// same way.
class DiscussionIconButton extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;
  final Color color;

  const DiscussionIconButton({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    this.color = Colors.white,
  });

  @override
  State<DiscussionIconButton> createState() => _DiscussionIconButtonState();
}

class _DiscussionIconButtonState extends State<DiscussionIconButton> {
  late final DiscussionCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ServiceLocator().locator<DiscussionCubit>(param1: widget.lessonId)
      ..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _openSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: DiscussionSheet(lessonTitle: widget.lessonTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscussionCubit, DiscussionState>(
      bloc: _cubit,
      builder: (context, state) {
        final count = state.count;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: 'Diskusi',
            onPressed: _openSheet,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.forum_rounded, color: widget.color),
                if (count > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFDC0000),
                        ),
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
}
