import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/tts_service.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../../providers/quiz_provider.dart';
import '../../../providers/stats_provider.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/custom_button.dart';
import 'quiz_result_screen.dart';

class QuizPlayScreen extends StatelessWidget {
  const QuizPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    if (quizProvider.isLoading) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = quizProvider.currentQuestion;

    if (question == null) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: AppBar(
          title: Text(context.l10n.quizPlayTitle),
          backgroundColor: context.cardBg,
          foregroundColor: context.textPrimaryColor,
        ),
        body: Center(
          child: Text(
            quizProvider.errorMessage ?? context.l10n.statusPending,
            style: TextStyle(color: context.textPrimaryColor),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(context.l10n.quizPlayExitTitle),
            content: Text(context.l10n.quizPlayExitMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.l10n.quizPlayContinue),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.l10n.actionExit),
              ),
            ],
          ),
        );
        if ((shouldExit ?? false) && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: AppBar(
          title: Text(quizProvider.activeTopicName),
          backgroundColor: context.cardBg,
          elevation: 0,
          foregroundColor: context.textPrimaryColor,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  context.l10n.quizPlayQuestionCounter(quizProvider.currentIndex + 1, quizProvider.questions.length),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Thanh tiến độ bài Quiz
              LinearProgressIndicator(
                value: quizProvider.progressPercentage,
                minHeight: 6,
                backgroundColor: context.borderCol,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Badge loại câu hỏi
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.primaryContainerCol,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getTypeBadge(question.type, context),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Hộp câu hỏi
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: context.borderCol),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(context.isDark ? 0.2 : 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    question.prompt,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimaryColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                                  onPressed: () {
                                    TtsService().speak(question.targetWord.term);
                                  },
                                ),
                              ],
                            ),
                            if (question.secondaryPrompt != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                question.secondaryPrompt!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.textSecondaryColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4 Đáp án lựa chọn
                      ...question.options.map((option) {
                        return _buildOptionTile(
                          context: context,
                          option: option,
                          question: question,
                          quizProvider: quizProvider,
                        );
                      }),

                      // Hộp giải thích khi đã kiểm tra đáp án
                      if (quizProvider.isAnswerChecked) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: quizProvider.selectedOption == question.correctAnswer
                                ? (context.isDark ? AppColors.success.withValues(alpha: 0.2) : AppColors.successLight)
                                : (context.isDark ? AppColors.danger.withValues(alpha: 0.2) : AppColors.dangerLight),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: quizProvider.selectedOption == question.correctAnswer
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
                                    quizProvider.selectedOption == question.correctAnswer
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color: quizProvider.selectedOption == question.correctAnswer
                                        ? AppColors.success
                                        : AppColors.danger,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    quizProvider.selectedOption == question.correctAnswer
                                        ? context.l10n.quizPlayCorrect
                                        : context.l10n.quizPlayIncorrect,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: quizProvider.selectedOption == question.correctAnswer
                                          ? AppColors.success
                                          : AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                question.explanation,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.textPrimaryColor,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  border: Border(top: BorderSide(color: context.borderCol)),
                ),
                child: CustomButton(
                  text: !quizProvider.isAnswerChecked
                      ? context.l10n.quizPlayCheck
                      : (quizProvider.currentIndex < quizProvider.questions.length - 1
                          ? context.l10n.quizPlayNext
                          : context.l10n.quizPlayViewResult),
                  icon: !quizProvider.isAnswerChecked
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  backgroundColor: !quizProvider.isAnswerChecked
                      ? AppColors.primary
                      : AppColors.accent,
                  onPressed: quizProvider.selectedOption == null
                      ? null
                      : () async {
                          if (!quizProvider.isAnswerChecked) {
                            await quizProvider.checkAnswer();
                          } else {
                            final isLast = quizProvider.currentIndex >= quizProvider.questions.length - 1;
                            await quizProvider.nextQuestion();

                            if (isLast && context.mounted) {
                              // Tải lại thống kê
                              Provider.of<StatsProvider>(context, listen: false).loadStats();
                              Provider.of<StudyProvider>(context, listen: false).loadOverallStats();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const QuizResultScreen()),
                              );
                            }
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String option,
    required QuizQuestionModel question,
    required QuizProvider quizProvider,
  }) {
    final isSelected = quizProvider.selectedOption == option;
    final isChecked = quizProvider.isAnswerChecked;
    final isCorrect = option == question.correctAnswer;

    Color bgColor = context.cardBg;
    Color borderColor = context.borderCol;
    Color textColor = context.textPrimaryColor;
    IconData? trailingIcon;
    Color? iconColor;

    if (isChecked) {
      if (isCorrect) {
        bgColor = context.isDark ? AppColors.success.withValues(alpha: 0.2) : AppColors.successLight;
        borderColor = AppColors.success;
        textColor = AppColors.success;
        trailingIcon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
      } else if (isSelected && !isCorrect) {
        bgColor = context.isDark ? AppColors.danger.withValues(alpha: 0.2) : AppColors.dangerLight;
        borderColor = AppColors.danger;
        textColor = AppColors.danger;
        trailingIcon = Icons.cancel_rounded;
        iconColor = AppColors.danger;
      }
    } else if (isSelected) {
      bgColor = context.primaryContainerCol;
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isSelected || (isChecked && isCorrect) ? 2 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            quizProvider.selectOption(option);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (trailingIcon != null)
                  Icon(trailingIcon, color: iconColor, size: 22)
                else if (isSelected)
                  const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTypeBadge(QuizQuestionType type, BuildContext context) {
    switch (type) {
      case QuizQuestionType.wordToMeaning:
        return context.l10n.quizPlayTypeSelectMeaning;
      case QuizQuestionType.meaningToWord:
        return context.l10n.quizPlayTypeSelectWord;
      case QuizQuestionType.fillBlank:
        return context.l10n.quizPlayTypeFillBlank;
    }
  }
}
