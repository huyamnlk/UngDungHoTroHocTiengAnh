import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../../data/models/word_model.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/word_card_tile.dart';
import '../flashcard/flashcard_screen.dart';
import '../stats/stats_screen.dart';
import 'word_detail_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.reviewTitle),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart_rounded, color: context.primaryAccent),
            tooltip: l10n.reviewViewStats,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: context.primaryAccent,
                unselectedLabelColor: context.textSecondaryColor,
                indicatorColor: context.primaryAccent,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    text: l10n.reviewTabNeedReview(studyProvider.reviewWords.length),
                    icon: const Icon(Icons.replay_rounded, size: 20),
                  ),
                  Tab(
                    text: l10n.reviewTabFavorites(studyProvider.favoriteWords.length),
                    icon: const Icon(Icons.favorite_rounded, size: 20),
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
          // Tab 1: Danh sách từ cần ôn
          _buildWordList(
            words: studyProvider.reviewWords,
            emptyTitle: l10n.reviewEmptyNeedReview,
            emptyDesc: l10n.reviewEmptyNeedReviewDesc,
            buttonTitle: l10n.reviewLearnFlashcardsNeed,
            screenTitle: l10n.reviewTabNeedReview(studyProvider.reviewWords.length),
            isReviewTab: true,
          ),

          // Tab 2: Danh sách từ yêu thích
          _buildWordList(
            words: studyProvider.favoriteWords,
            emptyTitle: l10n.reviewEmptyFavorites,
            emptyDesc: l10n.reviewEmptyFavoritesDesc,
            buttonTitle: l10n.reviewLearnFlashcardsFav,
            screenTitle: l10n.reviewTabFavorites(studyProvider.favoriteWords.length),
            isReviewTab: false,
          ),
        ],
      ),
    );
  }

  Widget _buildWordList({
    required List<WordModel> words,
    required String emptyTitle,
    required String emptyDesc,
    required String buttonTitle,
    required String screenTitle,
    required bool isReviewTab,
  }) {
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);

    if (words.isEmpty) {
      return EmptyStateView(
        icon: isReviewTab ? Icons.check_circle_outline_rounded : Icons.favorite_border_rounded,
        title: emptyTitle,
        description: emptyDesc,
      );
    }

    return Column(
      children: [
        // Thanh công cụ hành động phía trên
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: context.surfaceBg,
            border: Border(bottom: BorderSide(color: context.borderCol)),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1060),
              child: Row(
                children: [
                  Text(
                    context.l10n.reviewTotalWords(words.length),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const Spacer(),
                  CustomButton(
                    text: 'Học thẻ ngay',
                    icon: Icons.style_rounded,
                    height: 38,
                    backgroundColor: isReviewTab ? AppColors.warning : AppColors.danger,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlashcardScreen(
                            title: screenTitle,
                            words: words,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Danh sách từ
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1060),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: words.length,
                itemBuilder: (context, index) {
                  final word = words[index];
                  return WordCardTile(
                    word: word,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WordDetailScreen(word: word),
                        ),
                      );
                    },
                    onFavoriteToggle: () {
                      studyProvider.toggleFavorite(word);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
