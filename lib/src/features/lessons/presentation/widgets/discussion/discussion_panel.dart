import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

import '../../../domain/entities/discussion_entity.dart';
import '../../bloc/discussion/discussion_cubit.dart';
import '../../bloc/discussion/discussion_state.dart';

/// The reusable body of the discussion feature: the list of topics + replies
/// and the "start a new topic" composer at the bottom. Used both by the lesson
/// bottom-sheet ([DiscussionSheet]) and the full-page thread screen.
///
/// Expects a [DiscussionCubit] provided above it.
class DiscussionPanel extends StatelessWidget {
  /// Provided by a DraggableScrollableSheet when hosted in a bottom sheet.
  final ScrollController? scrollController;

  /// When set, this discussion is visually highlighted (e.g. opened from a
  /// notification deep-link).
  final String? highlightDiscussionId;

  const DiscussionPanel({
    super.key,
    this.scrollController,
    this.highlightDiscussionId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildBody(context)),
        Divider(height: 1, color: AppColors.borderSubtle),
        const _NewTopicComposer(),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<DiscussionCubit, DiscussionState>(
      builder: (context, state) {
        switch (state.status) {
          case DiscussionStatus.loading:
          case DiscussionStatus.initial:
            return const Center(child: CircularProgressIndicator());
          case DiscussionStatus.error:
            return _ErrorView(
              message: state.error ?? 'Gagal memuat diskusi.',
              onRetry: () => context.read<DiscussionCubit>().load(),
            );
          case DiscussionStatus.loaded:
            if (state.discussions.isEmpty) {
              return const _EmptyView();
            }
            return ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: state.discussions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final d = state.discussions[index];
                return _ThreadTile(
                  discussion: d,
                  highlighted: d.id == highlightDiscussionId,
                );
              },
            );
        }
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 56,
            color: AppColors.textTertiary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada diskusi',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jadilah yang pertama memulai diskusi.',
            style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single discussion topic with its replies and an inline reply composer.
class _ThreadTile extends StatefulWidget {
  final DiscussionEntity discussion;
  final bool highlighted;

  const _ThreadTile({required this.discussion, this.highlighted = false});

  @override
  State<_ThreadTile> createState() => _ThreadTileState();
}

class _ThreadTileState extends State<_ThreadTile> {
  final TextEditingController _replyController = TextEditingController();
  bool _replyOpen = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    final ok = await context.read<DiscussionCubit>().postReply(
      widget.discussion.id,
      text,
    );
    if (!mounted) return;
    if (ok) {
      _replyController.clear();
      setState(() => _replyOpen = false);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengirim balasan.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.discussion;
    final isReplying = context.select(
      (DiscussionCubit c) => c.state.replyingIds.contains(d.id),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.highlighted
            ? AppColors.brandPrimary.withValues(alpha: 0.06)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.highlighted
              ? AppColors.brandPrimary.withValues(alpha: 0.4)
              : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuthorRow(name: d.authorName, timeLabel: d.createdAtLabel),
          const SizedBox(height: 8),
          Text(
            d.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            d.body,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          if (d.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: Border(
                left: BorderSide(color: AppColors.borderDefault, width: 2),
              ).toDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final r in d.replies) _ReplyTile(reply: r)],
              ),
            ),
          ],
          const SizedBox(height: 6),
          if (!_replyOpen)
            TextButton.icon(
              onPressed: () => setState(() => _replyOpen = true),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppColors.brandPrimary,
              ),
              icon: const Icon(Icons.reply_rounded, size: 18),
              label: Text(
                'Balas${d.repliesCount > 0 ? ' (${d.repliesCount})' : ''}',
              ),
            )
          else
            _InlineComposer(
              controller: _replyController,
              hint: 'Tulis balasan...',
              submitting: isReplying,
              onSend: _sendReply,
              onCancel: () => setState(() => _replyOpen = false),
            ),
        ],
      ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  final DiscussionReplyEntity reply;

  const _ReplyTile({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuthorRow(
            name: reply.authorName,
            timeLabel: reply.createdAtLabel,
            small: true,
          ),
          const SizedBox(height: 2),
          Text(
            reply.body,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  final String name;
  final String timeLabel;
  final bool small;

  const _AuthorRow({
    required this.name,
    required this.timeLabel,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = small ? 24.0 : 30.0;
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.brandSurface,
            shape: BoxShape.circle,
          ),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: small ? 11 : 13,
              fontWeight: FontWeight.w800,
              color: AppColors.brandText,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: small ? 12.5 : 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (timeLabel.isNotEmpty)
          Text(
            timeLabel,
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
      ],
    );
  }
}

/// Inline single-line composer used for replies.
class _InlineComposer extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool submitting;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const _InlineComposer({
    required this.controller,
    required this.hint,
    required this.submitting,
    required this.onSend,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceMuted,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: submitting ? null : onCancel,
          icon: const Icon(Icons.close_rounded, size: 20),
          color: AppColors.textTertiary,
        ),
        submitting
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded, size: 20),
                color: AppColors.brandText,
              ),
      ],
    );
  }
}

/// Bottom composer to start a brand-new discussion topic (title + body).
class _NewTopicComposer extends StatefulWidget {
  const _NewTopicComposer();

  @override
  State<_NewTopicComposer> createState() => _NewTopicComposerState();
}

class _NewTopicComposerState extends State<_NewTopicComposer> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan isi diskusi wajib diisi.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final ok = await context.read<DiscussionCubit>().postTopic(
      title: title,
      body: body,
    );
    if (!mounted) return;
    if (ok) {
      _titleController.clear();
      _bodyController.clear();
      setState(() => _expanded = false);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memulai diskusi.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.select(
      (DiscussionCubit c) => c.state.submitting,
    );

    if (!_expanded) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _expanded = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_comment_rounded, size: 20),
              label: const Text('Mulai Diskusi'),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Judul diskusi',
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis pertanyaan atau topik diskusi...',
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () => setState(() => _expanded = false),
                  child: const Text('Batal'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: submitting ? null : _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Kirim'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension BorderToDecoration on Border {
  BoxDecoration toDecoration() => BoxDecoration(border: this);
}
