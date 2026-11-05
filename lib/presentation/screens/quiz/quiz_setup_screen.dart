import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../../providers/quiz_provider.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/custom_button.dart';
import 'quiz_play_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int? _selectedTopicId;
  String? _selectedTopicName;
  int _questionCount = 5;

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.quizSetupTitle),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner giới thiệu
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4361EE), Color(0xFF7209B7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.psychology_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    l10n.quizSetupHeader,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.quizSetupSubtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Chọn chủ đề
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.borderCol),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quizSetupSelectTopic,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Option: Tổng hợp
                  _buildTopicOption(
                    id: null,
                    name: l10n.quizSetupAllTopics,
                    subtitle: l10n.quizSetupAllTopicsDesc,
                    icon: Icons.auto_awesome_rounded,
                  ),
                  Divider(height: 20, color: context.borderCol),

                  // Các chủ đề cụ thể
                  ...studyProvider.topics.map((t) {
                    return _buildTopicOption(
                      id: t.id,
                      name: t.name,
                      subtitle: l10n.topicsCountWords(t.totalWords),
                      icon: Icons.folder_outlined,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Chọn số lượng câu hỏi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.borderCol),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quizSetupQuestionCount,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCountOption(
                          count: 5,
                          label: l10n.quizSetupCountFast,
                          isSelected: _questionCount == 5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCountOption(
                          count: 10,
                          label: l10n.quizSetupCountStandard,
                          isSelected: _questionCount == 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Nút Bắt đầu
            CustomButton(
              text: l10n.quizSetupStart,
              icon: Icons.play_arrow_rounded,
              height: 52,
              onPressed: () async {
                final quizProvider = Provider.of<QuizProvider>(context, listen: false);
                await quizProvider.startQuiz(
                  topicId: _selectedTopicId,
                  topicName: _selectedTopicId == null
                      ? l10n.quizSetupAllTopics
                      : (_selectedTopicName ?? l10n.quizSetupAllTopics),
                  count: _questionCount,
                );

                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicOption({
    required int? id,
    required String name,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedTopicId == id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTopicId = id;
          _selectedTopicName = name;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : context.textMutedColor,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountOption({
    required int count,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _questionCount = count),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryContainerCol : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.borderCol,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : context.textSecondaryColor,
          ),
        ),
      ),
    );
  }
}
