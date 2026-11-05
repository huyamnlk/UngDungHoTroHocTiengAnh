import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/skill_exercise_model.dart';
import '../../../providers/skills_provider.dart';
import '../../widgets/interactive_card.dart';
import '../shadowing/shadowing_hub_screen.dart';
import 'exercise_detail_screen.dart';
import 'speaking_exercise_screen.dart';
import 'writing_exercise_screen.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';

class SingleSkillScreen extends StatefulWidget {
  final SkillType skillType;

  const SingleSkillScreen({super.key, required this.skillType});

  @override
  State<SingleSkillScreen> createState() => _SingleSkillScreenState();
}

class _SingleSkillScreenState extends State<SingleSkillScreen> {
  static const List<String> _cefrLevels = ['All', 'A1', 'A2', 'B1', 'B2', 'C1'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SkillsProvider>().loadSkillScores();
      }
    });
  }

  String _getSkillTitle(BuildContext context) {
    switch (widget.skillType) {
      case SkillType.listening:
        return context.l10n.skillsListening;
      case SkillType.reading:
        return context.l10n.skillsReading;
      case SkillType.writing:
        return context.l10n.skillsWriting;
      case SkillType.speaking:
        return context.l10n.skillsSpeaking;
    }
  }

  String _getSkillSubtitle(BuildContext context) {
    switch (widget.skillType) {
      case SkillType.listening:
        return context.l10n.skillsListeningDesc;
      case SkillType.reading:
        return context.l10n.skillsReadingDesc;
      case SkillType.writing:
        return context.l10n.skillsWritingDesc;
      case SkillType.speaking:
        return context.l10n.skillsSpeakingDesc;
    }
  }

  IconData get _skillIcon {
    switch (widget.skillType) {
      case SkillType.listening:
        return Icons.headphones_rounded;
      case SkillType.reading:
        return Icons.menu_book_rounded;
      case SkillType.writing:
        return Icons.edit_note_rounded;
      case SkillType.speaking:
        return Icons.record_voice_over_rounded;
    }
  }

  Color get _skillColor {
    switch (widget.skillType) {
      case SkillType.listening:
        return AppColors.secondary;
      case SkillType.reading:
        return AppColors.accent;
      case SkillType.writing:
        return AppColors.primary;
      case SkillType.speaking:
        return AppColors.success;
    }
  }

  void _openExercise(BuildContext context, SkillExerciseModel exercise) {
    Widget destination;
    switch (exercise.type) {
      case SkillType.listening:
      case SkillType.reading:
        destination = ExerciseDetailScreen(exercise: exercise);
        break;
      case SkillType.writing:
        destination = WritingExerciseScreen(exercise: exercise);
        break;
      case SkillType.speaking:
        destination = SpeakingExerciseScreen(exercise: exercise);
        break;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    final skillsProvider = context.watch<SkillsProvider>();
    final exercises = skillsProvider.getExercisesByType(widget.skillType);
    final allForSkill = skillsProvider.getAllExercisesByType(widget.skillType);
    final recommended =
        skillsProvider.recommendedExerciseForSkill(widget.skillType);
    final history =
        skillsProvider.getScoresForSkillType(widget.skillType.name);
    final completedForSkill = allForSkill
        .where((e) => skillsProvider.isExerciseCompleted(e.id))
        .length;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(_getSkillTitle(context)),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        actions: [
          if (widget.skillType == SkillType.speaking)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ShadowingHubScreen()),
                  );
                },
                icon: const Icon(Icons.graphic_eq_rounded, size: 18),
                label: Text(
                  context.l10n.skillsOpenShadowing,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1020),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thẻ giới thiệu & Gợi ý bài tiếp theo của kỹ năng này
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: _skillColor.withValues(alpha: 0.45), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _skillColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(_skillIcon, color: _skillColor, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.skillsProgressText(completedForSkill, allForSkill.length),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: _skillColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getSkillSubtitle(context),
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: context.textSecondaryColor,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.scaffoldBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.borderCol),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded,
                                size: 20, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '[${recommended.level}] ${recommended.title}',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _openExercise(context, recommended),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _skillColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(context.l10n.skillsStartLearning),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Bộ lọc trình độ CEFR
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
                    ..._cefrLevels.map((lvl) {
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
                const SizedBox(height: 18),

                Text(
                  context.l10n.skillsLessonList(exercises.length),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                if (exercises.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Column(
                      children: [
                        Text(
                          context.l10n.skillsNoLessonLevel(skillsProvider.selectedLevel),
                          style: TextStyle(color: context.textSecondaryColor),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              skillsProvider.setSelectedLevel('All'),
                          child: Text(context.l10n.skillsAllLevels),
                        ),
                      ],
                    ),
                  )
                else
                  ...exercises.map((exercise) {
                    final bestScore = skillsProvider.getBestScore(exercise.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InteractiveCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(18),
                        hoverBorderColor: _skillColor.withValues(alpha: 0.6),
                        onTap: () => _openExercise(context, exercise),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _skillColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(_skillIcon,
                                  color: _skillColor, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        exercise.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: context.textPrimaryColor,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: context.primaryContainerCol,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'CEFR ${exercise.level}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: context.primaryAccent,
                                          ),
                                        ),
                                      ),
                                      if (exercise.type == SkillType.reading)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: context.scaffoldBg,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: context.borderCol),
                                          ),
                                          child: Text(
                                            '~${exercise.estimatedReadMinutes} phút đọc • ${exercise.wordCount} từ',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: context.textSecondaryColor,
                                            ),
                                          ),
                                        ),
                                      if (exercise.type == SkillType.listening)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: context.scaffoldBg,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: context.borderCol),
                                          ),
                                          child: Text(
                                            'Audio 0.75x–1.25x • Có Transcript',
                                            style: TextStyle(
                                              fontSize: 10,
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
                                                ? AppColors.success
                                                    .withValues(alpha: 0.2)
                                                : AppColors.successLight,
                                            borderRadius:
                                                BorderRadius.circular(6),
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
                                    '${exercise.topic} • ${exercise.contentVi}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                  }),

                if (history.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Lịch sử điểm kỹ năng này (${history.length} lượt)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...history.take(5).map((row) {
                    final title = row['title']?.toString() ?? '';
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
                          Text(
                            '$score%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _skillColor,
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
}