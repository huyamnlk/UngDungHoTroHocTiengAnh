import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/skill_exercise_model.dart';
import '../../../providers/skills_provider.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/interactive_card.dart';
import '../dictionary/dictionary_screen.dart';
import '../exam/exam_hub_screen.dart';
import '../flashcard/flashcard_screen.dart';
import '../quiz/quiz_setup_screen.dart';
import '../review/review_screen.dart';
import 'exercise_detail_screen.dart';
import 'matching_game_screen.dart';
import 'speaking_exercise_screen.dart';
import 'writing_exercise_screen.dart';

class SkillsHubScreen extends StatefulWidget {
  final int initialTabIndex;

  const SkillsHubScreen({super.key, this.initialTabIndex = 0});

  @override
  State<SkillsHubScreen> createState() => _SkillsHubScreenState();
}

class _SkillsHubScreenState extends State<SkillsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _cefrLevels = ['All', 'A1', 'A2', 'B1', 'B2', 'C1'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 4),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SkillsProvider>().loadSkillScores();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final studyProvider = context.watch<StudyProvider>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Luyện tập 4 kỹ năng & Từ vựng'),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExamHubScreen()),
                );
              },
              icon: const Icon(Icons.workspace_premium_rounded,
                  size: 18, color: AppColors.primary),
              label: const Text(
                'Luyện thi IELTS/TOEIC',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(106),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh chọn trình độ CEFR (A1 - C1)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      'Trình độ CEFR:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ..._cefrLevels.map((lvl) {
                      final isSelected = skillsProvider.selectedLevel == lvl;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          visualDensity: VisualDensity.compact,
                          label: Text(lvl == 'All' ? 'Tất cả' : lvl),
                          selected: isSelected,
                          onSelected: (_) =>
                              skillsProvider.setSelectedLevel(lvl),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: context.primaryAccent,
                unselectedLabelColor: context.textSecondaryColor,
                indicatorColor: context.primaryAccent,
                indicatorWeight: 3,
                isScrollable: true,
                tabs: const [
                  Tab(
                    text: 'Nghe (Listening)',
                    icon: Icon(Icons.headphones_rounded, size: 19),
                  ),
                  Tab(
                    text: 'Nói (Speaking)',
                    icon: Icon(Icons.record_voice_over_rounded, size: 19),
                  ),
                  Tab(
                    text: 'Đọc (Reading)',
                    icon: Icon(Icons.menu_book_rounded, size: 19),
                  ),
                  Tab(
                    text: 'Viết (Writing)',
                    icon: Icon(Icons.edit_note_rounded, size: 19),
                  ),
                  Tab(
                    text: 'Từ vựng & Luyện thi',
                    icon: Icon(Icons.style_rounded, size: 19),
                  ),
                ],
              ),
              Divider(height: 1, color: context.borderCol),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Nghe hiểu
          _buildExerciseList(
            context,
            skillsProvider: skillsProvider,
            list: skillsProvider.listeningExercises,
            emptyHint: 'Không có bài Nghe nào ở trình độ này.',
          ),

          // Tab 2: Nói & Phát âm
          _buildExerciseList(
            context,
            skillsProvider: skillsProvider,
            list: skillsProvider.speakingExercises,
            emptyHint: 'Không có bài Nói nào ở trình độ này.',
          ),

          // Tab 3: Đọc hiểu
          _buildExerciseList(
            context,
            skillsProvider: skillsProvider,
            list: skillsProvider.readingExercises,
            emptyHint: 'Không có bài Đọc nào ở trình độ này.',
          ),

          // Tab 4: Viết & Rubric
          _buildExerciseList(
            context,
            skillsProvider: skillsProvider,
            list: skillsProvider.writingExercises,
            emptyHint: 'Không có bài Viết nào ở trình độ này.',
          ),

          // Tab 5: Từ vựng, Luyện thi & Lịch sử kết quả
          _buildVocabAndExamTab(context, studyProvider, skillsProvider),
        ],
      ),
    );
  }

  Widget _buildRecommendedBanner(
      BuildContext context, SkillsProvider skillsProvider) {
    final rec = skillsProvider.recommendedNextExercise;
    final completedCount = skillsProvider.completedExercisesCount;
    final totalCount = skillsProvider.allExercises.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.primaryContainerCol,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đề xuất học tiếp • Tiến độ kỹ năng: $completedCount/$totalCount bài đã hoàn thành',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '[${rec.level}] ${rec.title}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _openExercise(context, rec),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Học ngay'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(
    BuildContext context, {
    required SkillsProvider skillsProvider,
    required List<SkillExerciseModel> list,
    required String emptyHint,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1020),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRecommendedBanner(context, skillsProvider),
              if (list.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Column(
                    children: [
                      Text(
                        emptyHint,
                        style: TextStyle(color: context.textSecondaryColor),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () =>
                            skillsProvider.setSelectedLevel('All'),
                        child: const Text('Hiển thị tất cả trình độ (A1–C1)'),
                      ),
                    ],
                  ),
                )
              else
                ...list.map((exercise) {
                  final bestScore = skillsProvider.getBestScore(exercise.id);
                  IconData icon;
                  Color color;
                  switch (exercise.type) {
                    case SkillType.listening:
                      icon = Icons.headphones_rounded;
                      color = AppColors.secondary;
                      break;
                    case SkillType.reading:
                      icon = Icons.menu_book_rounded;
                      color = AppColors.accent;
                      break;
                    case SkillType.writing:
                      icon = Icons.edit_note_rounded;
                      color = AppColors.primary;
                      break;
                    case SkillType.speaking:
                      icon = Icons.record_voice_over_rounded;
                      color = AppColors.success;
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: _buildSkillCard(
                      context,
                      title: exercise.title,
                      subtitle:
                          '${exercise.topic} • ${exercise.contentVi}',
                      icon: icon,
                      color: color,
                      level: 'CEFR ${exercise.level}',
                      bestScore: bestScore,
                      onTap: () => _openExercise(context, exercise),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVocabAndExamTab(
    BuildContext context,
    StudyProvider studyProvider,
    SkillsProvider skillsProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1020),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lối tắt nổi bật đến Phòng Luyện Thi IELTS / TOEIC / CEFR
              _buildSkillCard(
                context,
                title: 'Phòng Luyện Thi IELTS • TOEIC • CEFR (Có bấm giờ)',
                subtitle:
                    'Làm đề đọc hiểu, nghe hiểu và mini-test theo thời gian thực kèm giải thích chi tiết từng câu.',
                icon: Icons.workspace_premium_rounded,
                color: const Color(0xFFE11D48),
                level: 'IELTS / TOEIC / CEFR',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExamHubScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),
              _buildSkillCard(
                context,
                title: 'Thẻ ghi nhớ Flashcard 3D',
                subtitle:
                    'Lật thẻ kiểm tra phản xạ từ vựng với hiệu ứng 3D, phát âm IPA và đánh dấu mức độ thuộc từ.',
                icon: Icons.flip_to_front_rounded,
                color: AppColors.primary,
                level: 'A1 - C1',
                onTap: () {
                  if (studyProvider.currentTopicWords.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FlashcardScreen(
                          title: 'Ôn tập thẻ từ vựng',
                          words: studyProvider.currentTopicWords,
                        ),
                      ),
                    );
                  } else {
                    studyProvider.loadWordsByTopic(1).then((_) {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FlashcardScreen(
                              title: 'Ôn tập thẻ từ vựng',
                              words: studyProvider.currentTopicWords,
                            ),
                          ),
                        );
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              _buildSkillCard(
                context,
                title: 'Thử thách Quiz trắc nghiệm từ vựng',
                subtitle:
                    '3 dạng câu hỏi phản xạ: Chọn nghĩa tiếng Việt, chọn từ tiếng Anh và điền từ khuyết.',
                icon: Icons.quiz_rounded,
                color: AppColors.warning,
                level: 'A1 - C1',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizSetupScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),
              _buildSkillCard(
                context,
                title: 'Trò chơi Ghép từ & Nghĩa (Matching Pairs)',
                subtitle:
                    'Lật thẻ và nối nhanh các cặp từ tiếng Anh tương ứng với nghĩa tiếng Việt.',
                icon: Icons.extension_rounded,
                color: AppColors.accent,
                level: 'Mọi cấp độ',
                onTap: () {
                  if (studyProvider.currentTopicWords.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchingGameScreen(
                            words: studyProvider.currentTopicWords),
                      ),
                    );
                  } else {
                    studyProvider.loadWordsByTopic(1).then((_) {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MatchingGameScreen(
                                words: studyProvider.currentTopicWords),
                          ),
                        );
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildSkillCard(
                      context,
                      title: 'Tra từ điển Offline & Online',
                      subtitle:
                          '520+ từ vựng CEFR có sẵn & tra cứu mở rộng có bộ nhớ đệm.',
                      icon: Icons.search_rounded,
                      color: AppColors.secondary,
                      level: 'Từ điển',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DictionaryScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSkillCard(
                context,
                title:
                    'Ôn tập lặp lại ngắt quãng SRS & Từ yêu thích (${studyProvider.dueSrsWords.length} từ cần ôn)',
                subtitle:
                    'Ôn lại các từ mới đã lưu từ bài đọc/nghe và danh sách từ vựng yêu thích của bạn.',
                icon: Icons.bookmark_added_rounded,
                color: AppColors.success,
                level: 'SRS Review',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReviewScreen()),
                  );
                },
              ),

              if (skillsProvider.skillScores.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Lịch sử luyện tập kỹ năng gần đây (${skillsProvider.skillScores.length} lượt)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                ...skillsProvider.skillScores.take(5).map((row) {
                  final title = row['title']?.toString() ?? 'Bài tập kỹ năng';
                  final skill = row['skill_type']?.toString().toUpperCase() ?? '';
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
                            '[$skill] $title',
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
                            '$score%',
                            style: const TextStyle(
                              fontSize: 12.5,
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
    );
  }

  Widget _buildSkillCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String level,
    double? bestScore,
    required VoidCallback onTap,
  }) {
    return InteractiveCard(
      onTap: onTap,
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      hoverBorderColor: color.withValues(alpha: 0.6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
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
                      title,
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
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        level,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.primaryAccent,
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
                          'Đã hoàn thành • ${bestScore.round()}%',
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
                  subtitle,
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
    );
  }
}
