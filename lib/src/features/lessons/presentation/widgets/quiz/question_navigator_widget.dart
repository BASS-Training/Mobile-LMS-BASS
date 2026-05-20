import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Widget untuk navigasi nomor soal
/// Menampilkan carousel horizontal nomor soal yang sinkron dengan soal aktif.
class QuestionNavigatorWidget extends StatefulWidget {
  final int totalQuestions;
  final int currentQuestionIndex;
  final Set<int> completedQuestionIndexes; // index soal yang sudah terjawab
  final Function(int) onQuestionSelected;
  final String completedLabel;
  final String pendingLabel;

  const QuestionNavigatorWidget({
    super.key,
    required this.totalQuestions,
    required this.currentQuestionIndex,
    required this.completedQuestionIndexes,
    required this.onQuestionSelected,
    this.completedLabel = 'Terjawab',
    this.pendingLabel = 'Belum',
  });

  @override
  State<QuestionNavigatorWidget> createState() => _QuestionNavigatorState();
}

class _QuestionNavigatorState extends State<QuestionNavigatorWidget> {
  static const double _itemSize = 38;
  static const double _itemSpacing = 8;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentQuestion(animated: false);
    });
  }

  @override
  void didUpdateWidget(QuestionNavigatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentQuestionIndex != widget.currentQuestionIndex ||
        oldWidget.totalQuestions != widget.totalQuestions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentQuestion();
      });
    }
  }

  void _scrollToCurrentQuestion({bool animated = true}) {
    if (!_scrollController.hasClients || widget.totalQuestions <= 0) {
      return;
    }

    final viewport = _scrollController.position.viewportDimension;
    final itemExtent = _itemSize + _itemSpacing;
    final target =
        (widget.currentQuestionIndex * itemExtent) -
        ((viewport - _itemSize) / 2);
    final minScroll = _scrollController.position.minScrollExtent;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final offset = target.clamp(minScroll, maxScroll).toDouble();

    if (animated) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(offset);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildLegend(),
        const SizedBox(height: 8),
        SizedBox(
          height: _itemSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            padding: EdgeInsets.zero,
            itemCount: widget.totalQuestions,
            separatorBuilder: (_, __) => const SizedBox(width: _itemSpacing),
            itemBuilder: (context, index) {
              final isCurrentQuestion = index == widget.currentQuestionIndex;
              final isAnswered = widget.completedQuestionIndexes.contains(
                index,
              );

              return Semantics(
                label: 'Soal ${index + 1}',
                selected: isCurrentQuestion,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => widget.onQuestionSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _itemSize,
                    height: _itemSize,
                    decoration: BoxDecoration(
                      color: isCurrentQuestion
                          ? AppColors.red
                          : (isAnswered
                                ? Colors.green.shade100
                                : AppColors.mist),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCurrentQuestion
                            ? AppColors.red
                            : (isAnswered
                                  ? Colors.green.shade300
                                  : AppColors.pearl),
                        width: isCurrentQuestion ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isCurrentQuestion
                              ? Colors.white
                              : (isAnswered
                                    ? Colors.green.shade800
                                    : AppColors.slate),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Legend untuk penjelasan warna
  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem(color: AppColors.red, label: 'Aktif'),
        const SizedBox(width: 16),
        _buildLegendItem(
          color: Colors.green[100]!,
          label: widget.completedLabel,
        ),
        const SizedBox(width: 16),
        _buildLegendItem(color: AppColors.mist, label: widget.pendingLabel),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.slate),
        ),
      ],
    );
  }
}
