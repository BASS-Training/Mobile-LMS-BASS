import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Widget untuk navigasi nomor soal
/// Menampilkan grid/list nomor soal yang bisa diklik untuk jump ke soal tertentu
class QuestionNavigatorWidget extends StatefulWidget {
  final int totalQuestions;
  final int currentQuestionIndex;
  final Map<int, int?> answers; // index -> selectedOptionIndex
  final Function(int) onQuestionSelected;

  const QuestionNavigatorWidget({
    super.key,
    required this.totalQuestions,
    required this.currentQuestionIndex,
    required this.answers,
    required this.onQuestionSelected,
  });

  @override
  State<QuestionNavigatorWidget> createState() => _QuestionNavigatorState();
}

class _QuestionNavigatorState extends State<QuestionNavigatorWidget> {
  late ScrollController _scrollController;
  late Map<int, GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _itemKeys = {
      for (int i = 0; i < widget.totalQuestions; i++) i: GlobalKey(),
    };
  }

  @override
  void didUpdateWidget(QuestionNavigatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Jika totalQuestions berubah, update _itemKeys
    if (oldWidget.totalQuestions != widget.totalQuestions) {
      _itemKeys = {
        for (int i = 0; i < widget.totalQuestions; i++) i: GlobalKey(),
      };
    }

    // Jika currentQuestionIndex berubah, scroll ke item aktif
    if (oldWidget.currentQuestionIndex != widget.currentQuestionIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentQuestion();
      });
    }
  }

  void _scrollToCurrentQuestion() {
    final currentKey = _itemKeys[widget.currentQuestionIndex];
    if (currentKey?.currentContext != null) {
      Scrollable.ensureVisible(
        currentKey!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5, // center the item in viewport
      );
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
        const SizedBox(height: 12),
        // Legend di atas untuk visibility lebih baik
        _buildLegend(),
        const SizedBox(height: 8),
        // Grid vertical with 5 columns. Show up to 6 rows height and allow internal vertical scroll.
        SizedBox(
          height: (46 * 6) + (8 * 5), // 6 rows of 46px height + spacing
          child: GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: widget.totalQuestions,
            itemBuilder: (context, index) {
              final isCurrentQuestion = index == widget.currentQuestionIndex;
              final isAnswered = widget.answers[index] != null;

              return Material(
                key: _itemKeys[index],
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => widget.onQuestionSelected(index),
                  child: Semantics(
                    label: 'Soal ${index + 1}',
                    selected: isCurrentQuestion,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        color: isCurrentQuestion
                            ? AppColors.violet
                            : (isAnswered
                                  ? Colors.green.shade100
                                  : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrentQuestion
                              ? AppColors.violet
                              : (isAnswered
                                    ? Colors.green.shade200
                                    : Colors.transparent),
                          width: isCurrentQuestion || isAnswered ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCurrentQuestion
                                ? Colors.white
                                : (isAnswered
                                      ? Colors.green.shade800
                                      : AppColors.charcoal),
                          ),
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
        _buildLegendItem(color: AppColors.violet, label: 'Aktif'),
        const SizedBox(width: 16),
        _buildLegendItem(color: Colors.green[100]!, label: 'Terjawab'),
        const SizedBox(width: 16),
        _buildLegendItem(color: Colors.grey[200]!, label: 'Belum'),
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

