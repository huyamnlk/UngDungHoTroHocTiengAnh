import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../../providers/quiz_provider.dart';
import '../../widgets/custom_button.dart';
import 'quiz_play_screen.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final l10n = context.l10n;
    final score = quizProvider.scorePercentage;
    final total = quizProvider.questions.length;
    final correct = quizProvider.correctCount;

    String feedbackTitle;
    String feedbackMessage;
    Color scoreColor;
    IconData feedbackIcon;

    if (score >= 80) {
      feedbackTitle = l10n.quizResultExcellent;
      feedbackMessage = l10n.quizResultDescExcellent;
      scoreColor = AppColors.success;
      feedbackIcon = Icons.emoji_events_rounded;
    } else if (score >= 50) {
      feedbackTitle = l10n.quizResultGood;
      feedbackMessage = l10n.quizResultDescGood;
      scoreColor = AppColors.warning;
      feedbackIcon = Icons.thumb_up_rounded;
    } else {
      feedbackTitle = l10n.quizResultNeedsWork;
      feedbackMessage = l10n.quizResultDescNeedsWork;
      scoreColor = AppColors.danger;
      feedbackIcon = Icons.fitness_center_rounded;
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.quizResultTitle),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thẻ tổng kết điểm
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.borderCol),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(context.isDark ? 0.2 : 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(feedbackIcon, size: 48, color: scoreColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      feedbackTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${score.toInt()}%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.quizResultScore(correct, total),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      feedbackMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondaryColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Xem lại từng câu hỏi
              Text(
                l10n.quizResultDetails,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),

              ...quizProvider.userAnswers.asMap().entries.map((entry) {
                final index = entry.key;
                final answer = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: answer.isCorrect
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.danger.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            answer.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: answer.isCorrect ? AppColors.success : AppColors.danger,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Câu ${index + 1}: ${answer.question.targetWord.term}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.quizResultUserSelected(answer.selectedOption),
                        style: TextStyle(
                          fontSize: 13,
                          color: answer.isCorrect ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!answer.isCorrect) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.quizResultCorrectIs(answer.question.correctAnswer),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        answer.question.explanation,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondaryColor,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Nút hành động
              CustomButton(
                text: l10n.quizResultRetake,
                icon: Icons.refresh_rounded,
                onPressed: () async {
                  await quizProvider.startQuiz(
                    topicId: quizProvider.questions.firstOrNull?.targetWord.topicId,
                    topicName: quizProvider.activeTopicName,
                    count: quizProvider.questions.length,
                  );
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: l10n.quizResultHome,
                isOutlined: true,
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
