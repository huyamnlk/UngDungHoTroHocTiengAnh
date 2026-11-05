import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/shadowing_model.dart';
import '../../../providers/skills_provider.dart';
import '../../widgets/interactive_card.dart';
import 'shadowing_practice_screen.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';

class ShadowingHubScreen extends StatefulWidget {
  const ShadowingHubScreen({super.key});

  @override
  State<ShadowingHubScreen> createState() => _ShadowingHubScreenState();
}

class _ShadowingHubScreenState extends State<ShadowingHubScreen> {
  static const List<String> _levels = ['All', 'A1', 'A2', 'B1', 'B2', 'C1'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SkillsProvider>().loadSkillScores();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final skillsProvider = context.watch<SkillsProvider>();
    final lessons = skillsProvider.filteredShadowingLessons;
    final topics = skillsProvider.shadowingTopics;
    final shadowingHistory = skillsProvider.getScoresForSkillType('shadowing');

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(context.l10n.shadowingHubTitle),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1020),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner giới thiệu quy trình Shadowing 4 bước
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.shadowingMethodTitle,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.shadowingMethodDesc,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFE0F2FE),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Bộ lọc CEFR Level
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Trình độ CEFR:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    ..._levels.map((lvl) {
                      final isSelected = skillsProvider.selectedLevel == lvl;
                      return ChoiceChip(
                        label: Text(lvl == 'All' ? context.l10n.topicFilterAll : lvl),
                        selected: isSelected,
                        onSelected: (_) =>
                            skillsProvider.setSelectedLevel(lvl),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 12),

                // Bộ lọc Chủ đề Shadowing
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Chủ đề:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    ...topics.map((t) {
                      final isSelected =
                          skillsProvider.selectedShadowingTopic == t;
                      return ChoiceChip(
                        label: Text(t == 'All' ? context.l10n.allTopics : t),
                        selected: isSelected,
                        onSelected: (_) =>
                            skillsProvider.setSelectedShadowingTopic(t),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  context.l10n.shadowingLessonsList(lessons.length),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                if (lessons.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Center(
                      child: Text(
                        'Không có bài Shadowing nào khớp với bộ lọc hiện tại.',
                        style: TextStyle(color: context.textSecondaryColor),
                      ),
                    ),
                  )
                else
                  ...lessons.map((lesson) {
                    final bestScore = skillsProvider.getBestScore(lesson.id);
                    return _buildShadowingLessonCard(
                      context,
                      lesson: lesson,
                      bestScore: bestScore,
                    );
                  }),

                if (shadowingHistory.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Lịch sử luyện Shadowing đã đánh giá (${shadowingHistory.length} lượt)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...shadowingHistory.take(5).map((row) {
                    final title = row['title']?.toString() ?? 'Shadowing';
                    final score = (row['score'] as num?)?.round() ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.borderCol),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimaryColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.primaryContainerCol,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Tự đánh giá: $score%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShadowingLessonCard(
    BuildContext context, {
    required ShadowingLessonModel lesson,
    required double? bestScore,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InteractiveCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShadowingPracticeScreen(lesson: lesson),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.secondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        lesson.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.primaryContainerCol,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'CEFR ${lesson.level}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.scaffoldBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: context.borderCol),
                        ),
                        child: Text(
                          '${lesson.segments.length} câu • ${lesson.topic}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ),
                      if (bestScore != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? AppColors.success.withValues(alpha: 0.2)
                                : AppColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            context.l10n.skillsCompletedBadge(bestScore.round()),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lesson.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondaryColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: context.textMutedColor,
            ),
          ],
        ),
      ),
    );
  }
}