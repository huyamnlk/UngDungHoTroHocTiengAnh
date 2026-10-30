import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/topic_model.dart';
import '../../../providers/quiz_provider.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/word_card_tile.dart';
import '../flashcard/flashcard_screen.dart';
import '../quiz/quiz_play_screen.dart';
import '../review/word_detail_screen.dart';
import 'add_word_dialog.dart';

class TopicDetailScreen extends StatefulWidget {
  final TopicModel topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'mastered', 'learning', 'new'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudyProvider>(context, listen: false).loadWordsByTopic(widget.topic.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final themeColor = UiHelpers.hexToColor(widget.topic.colorHex);

    // Lọc danh sách từ
    final words = studyProvider.currentTopicWords.where((word) {
      final matchesSearch = word.term.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          word.meaning.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 'mastered') return word.status == AppConstants.statusMastered;
      if (_selectedFilter == 'learning') return word.status == AppConstants.statusLearning;
      if (_selectedFilter == 'new') return word.status == AppConstants.statusNew;

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(widget.topic.name),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AddWordDialog(
              topicId: widget.topic.id,
              topicName: widget.topic.name,
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: studyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header tóm tắt chủ đề và các nút chức năng
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    border: Border(bottom: BorderSide(color: context.borderCol)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.topic.description.isNotEmpty) ...[
                        Text(
                          widget.topic.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // 2 Nút học Flashcard & Làm Quiz
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Học thẻ (${studyProvider.currentTopicWords.length})',
                              icon: Icons.style_rounded,
                              backgroundColor: themeColor,
                              height: 44,
                              onPressed: studyProvider.currentTopicWords.isEmpty
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FlashcardScreen(
                                            title: widget.topic.name,
                                            words: studyProvider.currentTopicWords,
                                          ),
                                        ),
                                      );
                                    },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Thi Quiz',
                              icon: Icons.quiz_rounded,
                              backgroundColor: AppColors.accent,
                              height: 44,
                              onPressed: studyProvider.currentTopicWords.length < 4
                                  ? null
                                  : () async {
                                      final currentContext = context;
                                      final quizProvider = Provider.of<QuizProvider>(currentContext, listen: false);
                                      await quizProvider.startQuiz(
                                        topicId: widget.topic.id,
                                        topicName: widget.topic.name,
                                        count: 5,
                                      );
                                      if (!mounted) return;
                                      Navigator.push(
                                        currentContext,
                                        MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
                                      );
                                    },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Ô tìm kiếm
                      TextField(
                        controller: _searchController,
                        style: TextStyle(color: context.textPrimaryColor),
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Tìm từ tiếng Anh hoặc nghĩa tiếng Việt...',
                          hintStyle: TextStyle(fontSize: 14, color: context.textMutedColor),
                          prefixIcon: Icon(Icons.search_rounded, size: 20, color: context.textSecondaryColor),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded, size: 18, color: context.textSecondaryColor),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor: context.scaffoldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Bộ lọc filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Tất cả', 'all'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Đã nhớ', 'mastered'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Cần ôn', 'learning'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Mới', 'new'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Danh sách từ vựng
                Expanded(
                  child: words.isEmpty
                      ? const EmptyStateView(
                          icon: Icons.search_off_rounded,
                          title: 'Không tìm thấy từ vựng',
                          description: 'Thử tìm với từ khóa khác hoặc chuyển sang bộ lọc khác.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
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
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = value);
      },
      selectedColor: context.primaryContainerCol,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primary : context.textSecondaryColor,
      ),
      backgroundColor: Colors.transparent,
      side: BorderSide(
        color: isSelected ? AppColors.primary : context.borderCol,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
