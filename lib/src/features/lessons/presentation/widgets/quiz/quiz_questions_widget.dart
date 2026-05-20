import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/option_card_widget.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/question_navigator_widget.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Widget untuk menampilkan halaman pertanyaan kuis dengan opsi jawaban
class QuizQuestionsWidget extends StatelessWidget {
  final Quiz quiz;
  final int currentQuestionIndex;
  final Map<int, int> answers;
  final Function(int) onSelectAnswer;
  final VoidCallback onNextQuestion;
  final VoidCallback onPreviousQuestion;
  final VoidCallback onSubmitQuiz;
  final Function(int) onQuestionNavigate;
  final bool showNavigationButtons;

  const QuizQuestionsWidget({
    super.key,
    required this.quiz,
    required this.currentQuestionIndex,
    required this.answers,
    required this.onSelectAnswer,
    required this.onNextQuestion,
    required this.onPreviousQuestion,
    required this.onSubmitQuiz,
    required this.onQuestionNavigate,
    this.showNavigationButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    final question = quiz.questions[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == quiz.questions.length - 1;
    final bool isAllAnswered = answers.length == quiz.questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(8),
          //   child: LinearProgressIndicator(
          //     value: (currentQuestionIndex + 1) / quiz.questions.length,
          //     minHeight: 8,
          //     backgroundColor: Colors.grey[300],
          //     valueColor: AlwaysStoppedAnimation<Color>(AppColors.violet),
          //   ),
          // ),
          const SizedBox(height: 24),

          // Question card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question text
                  Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  ...List.generate(
                    question.options.length,
                    (index) => OptionCardWidget(
                      index: index,
                      option: question.options[index],
                      isSelected: answers[currentQuestionIndex] == index,
                      onTap: () => onSelectAnswer(index),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Question Navigator
          QuestionNavigatorWidget(
            totalQuestions: quiz.questions.length,
            currentQuestionIndex: currentQuestionIndex,
            completedQuestionIndexes: answers.keys.toSet(),
            onQuestionSelected: onQuestionNavigate,
            completedLabel: 'Terjawab',
            pendingLabel: 'Belum',
          ),
          const SizedBox(height: 24),

          if (showNavigationButtons) ...[
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  OutlinedButton.icon(
                    onPressed: onPreviousQuestion,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Sebelumnya'),
                  )
                else
                  const SizedBox(width: 0),
                Row(
                  children: [
                    if (!isLastQuestion)
                      ElevatedButton.icon(
                        onPressed: onNextQuestion,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Selanjutnya'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violet,
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: isAllAnswered ? onSubmitQuiz : null,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Kirim Jawaban'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

