import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../../providers/stats_provider.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stat_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatsProvider>(context, listen: false).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsProvider = Provider.of<StatsProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(context.l10n.statsTitle),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.borderCol),
        ),
      ),
      body: statsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await statsProvider.loadStats();
                await studyProvider.loadTopics();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1060),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Thẻ tiến độ tổng thể
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.28),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.insights_rounded, color: Colors.white, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l10n.statsOverallProgress,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${statsProvider.masteryRate.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      context.l10n.statsMasteredRatio(
                                        statsProvider.masteredWords,
                                        statsProvider.totalWords,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: statsProvider.totalWords == 0
                                      ? 0
                                      : statsProvider.masteredWords / statsProvider.totalWords,
                                  minHeight: 10,
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                    // Grid 4 chỉ số chính
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: context.l10n.statsTotalWords,
                            value: '${statsProvider.totalWords}',
                            icon: Icons.menu_book_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: context.l10n.statsMasteredWords,
                            value: '${statsProvider.masteredWords}',
                            icon: Icons.check_circle_rounded,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: context.l10n.statsNeedReviewWords,
                            value: '${statsProvider.learningWords}',
                            icon: Icons.replay_rounded,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: context.l10n.statsFavoriteWords,
                            value: '${statsProvider.favoriteWords}',
                            icon: Icons.favorite_rounded,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tiến độ theo từng chủ đề
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
                            context.l10n.statsTopicProgress,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...studyProvider.topics.map((t) {
                            final topicColor = UiHelpers.hexToColor(t.colorHex);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        t.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: context.textPrimaryColor,
                                        ),
                                      ),
                                      Text(
                                        context.l10n.statsTopicWordsProgress(
                                          t.masteredWords,
                                          t.totalWords,
                                          (t.progressPercentage * 100).toInt(),
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: topicColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: t.progressPercentage,
                                      minHeight: 6,
                                      backgroundColor: context.borderCol,
                                      valueColor: AlwaysStoppedAnimation<Color>(topicColor),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lịch sử làm bài thi Quiz
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.statsQuizHistory,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              if (statsProvider.quizHistories.isNotEmpty)
                                Text(
                                  context.l10n.statsAverageScore(
                                    statsProvider.averageQuizScore.toStringAsFixed(0),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (statsProvider.quizHistories.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: Text(
                                  context.l10n.statsEmptyQuiz,
                                  style: TextStyle(fontSize: 13, color: context.textMutedColor),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          else
                            ...statsProvider.quizHistories.map((h) {
                              final isGood = h.scorePercentage >= 70;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.scaffoldBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: (isGood ? AppColors.success : AppColors.warning)
                                            .withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isGood ? Icons.check_circle_rounded : Icons.history_rounded,
                                        color: isGood ? AppColors.success : AppColors.warning,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            h.topicName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: context.textPrimaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            UiHelpers.formatDateTime(h.completedAt, context: context),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: context.textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${h.scorePercentage.toInt()}%',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isGood ? AppColors.success : AppColors.warning,
                                          ),
                                        ),
                                        Text(
                                          context.l10n.statsQuizQuestionsCount(
                                            h.correctAnswers,
                                            h.totalQuestions,
                                          ),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: context.textMutedColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Nút Reset Database
                    CustomButton(
                      text: context.l10n.statsResetButton,
                      icon: Icons.restore_rounded,
                      backgroundColor: context.isDark ? AppColors.darkCard : Colors.grey.shade300,
                      textColor: context.isDark ? AppColors.darkTextPrimary : Colors.grey.shade800,
                      onPressed: () {
                        final parentContext = context;
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Text(context.l10n.statsResetTitle),
                            content: Text(context.l10n.statsResetMessage),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(context.l10n.actionCancel),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await studyProvider.resetToSeedData();
                                  await statsProvider.loadStats();
                                  if (!mounted) return;
                                  UiHelpers.showSnackBar(
                                    parentContext,
                                    message: parentContext.l10n.statsResetSuccess,
                                    isSuccess: true,
                                  );
                                },
                                child: Text(context.l10n.statsResetConfirm),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
