import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/dictionary_api_service.dart';
import '../../../core/services/tts_service.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../../data/models/online_dictionary_result.dart';
import '../../../data/models/word_model.dart';
import '../../../providers/dictionary_provider.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/interactive_card.dart';
import '../review/word_detail_screen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _savedOnlineWords = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    Provider.of<DictionaryProvider>(context, listen: false).search(query);
  }

  Future<void> _saveOnlineWordToLocal(
    OnlineDictionaryResult result,
    StudyProvider studyProvider,
  ) async {
    final firstDef = result.definitions.isNotEmpty
        ? result.definitions.first
        : const OnlineDefinition(
            partOfSpeech: 'noun',
            definition: 'Equivalent term from online dictionary',
          );

    final topicId =
        studyProvider.topics.isNotEmpty ? studyProvider.topics.first.id : 1;

    // Luôn lưu từ tiếng Anh vào term và nghĩa tiếng Việt vào meaning
    final term = result.word.trim();
    final meaning = (result.vietnameseTranslation != null &&
            result.vietnameseTranslation!.trim().isNotEmpty)
        ? result.vietnameseTranslation!.trim()
        : (result.definitions.isNotEmpty
            ? result.definitions.first.definition
            : term);

    final pos = firstDef.partOfSpeech.isNotEmpty
        ? firstDef.partOfSpeech
        : (result.isVietnameseToEnglish ? 'noun' : 'n/v');

    final englishDef = firstDef.definition.isNotEmpty
        ? firstDef.definition
        : 'English term for "${result.originalQuery ?? term}".';

    final exampleEn = (firstDef.example != null && firstDef.example!.isNotEmpty)
        ? firstDef.example!
        : 'Example sentence with the word $term.';

    final exampleVi = result.isVietnameseToEnglish
        ? 'Bản dịch tiếng Việt: $meaning'
        : 'Nguồn: ${result.sourceName} (${result.license})';

    final newWord = WordModel(
      id: 0,
      topicId: topicId,
      term: term,
      ipa: result.phonetic ?? '/.../',
      partOfSpeech: pos,
      meaning: meaning,
      englishDefinition: englishDef,
      exampleEn: exampleEn,
      exampleVi: exampleVi,
      level: 'B1',
      status: AppConstants.statusLearning,
      isFavorite: true,
    );

    await studyProvider.addNewWord(newWord);
    if (mounted) {
      setState(() => _savedOnlineWords.add(term.toLowerCase()));
      UiHelpers.showSnackBar(
        context,
        message: context.l10n.dictSavedSuccess(term),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dictProvider = Provider.of<DictionaryProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(context.l10n.dictTitleFull),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.borderCol),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh tìm kiếm & Bộ lọc CEFR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.surfaceBg,
                border: Border(bottom: BorderSide(color: context.borderCol)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1060),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _searchController,
                        style: TextStyle(color: context.textPrimaryColor),
                        onChanged: _onSearch,
                        decoration: InputDecoration(
                          hintText: context.l10n.dictSearchPlaceholder,
                          hintStyle: TextStyle(color: context.textMutedColor),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: context.primaryAccent),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                    color: context.textSecondaryColor,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearch('');
                                    setState(() {});
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: context.scaffoldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: context.borderCol),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: context.borderCol),
                          ),
                        ),
                      ),
                      if (_searchController.text.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.primaryContainerCol,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: context.primaryAccent
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 16,
                                    color: context.primaryAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.l10n.dictSearchDirection(
                                      dictProvider.directionFlag,
                                      dictProvider.directionLabel,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: context.primaryAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dictProvider.isVietnameseQuery
                                    ? context.l10n.dictViDetected
                                    : context.l10n.dictEnDetected,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Bộ lọc CEFR Level & Nút đặt lại
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (dictProvider.hasActiveFilters)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ActionChip(
                                  avatar: const Icon(Icons.filter_alt_off_rounded, size: 14),
                                  label: Text(context.l10n.actionResetFilter),
                                  backgroundColor: context.scaffoldBg,
                                  side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                                  labelStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.danger,
                                  ),
                                  onPressed: () => dictProvider.resetFilters(),
                                ),
                              ),
                            ...['all', 'A1', 'A2', 'B1', 'B2', 'C1'].map((level) {
                              final isSelected = dictProvider.selectedLevel == level;
                              final label = level == 'all'
                                  ? context.l10n.dictAllLevels
                                  : 'CEFR $level';
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(label),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      dictProvider.setLevelFilter(level);
                                    }
                                  },
                                  selectedColor: context.activeNavBg,
                                  backgroundColor: context.scaffoldBg,
                                  side: BorderSide(
                                    color: isSelected
                                        ? context.primaryAccent
                                        : context.borderCol,
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? context.primaryAccent
                                        : context.textSecondaryColor,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Bộ lọc Chủ đề (Topic Filter)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(context.l10n.dictAllTopics),
                                selected: dictProvider.selectedTopicId == 0,
                                onSelected: (selected) {
                                  if (selected) dictProvider.setTopicFilter(0);
                                },
                                selectedColor: context.activeNavBg,
                                backgroundColor: context.scaffoldBg,
                                side: BorderSide(
                                  color: dictProvider.selectedTopicId == 0
                                      ? context.primaryAccent
                                      : context.borderCol,
                                ),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: dictProvider.selectedTopicId == 0
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: dictProvider.selectedTopicId == 0
                                      ? context.primaryAccent
                                      : context.textSecondaryColor,
                                ),
                              ),
                            ),
                            ...studyProvider.topics.map((topic) {
                              final isSelected =
                                  dictProvider.selectedTopicId == topic.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(topic.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      dictProvider.setTopicFilter(topic.id);
                                    }
                                  },
                                  selectedColor: context.activeNavBg,
                                  backgroundColor: context.scaffoldBg,
                                  side: BorderSide(
                                    color: isSelected
                                        ? context.primaryAccent
                                        : context.borderCol,
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? context.primaryAccent
                                        : context.textSecondaryColor,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Bộ lọc Từ loại (Part of Speech Filter)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ('all', context.l10n.dictAllPos),
                            ('noun', context.l10n.dictNoun),
                            ('verb', context.l10n.dictVerb),
                            ('adjective', context.l10n.dictAdj),
                            ('adverb', context.l10n.dictAdv),
                            ('phrase', context.l10n.dictPhrase),
                          ].map((pos) {
                            final isSelected = dictProvider.selectedPos == pos.$1;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(pos.$2),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    dictProvider.setPosFilter(pos.$1);
                                  }
                                },
                                selectedColor: context.activeNavBg,
                                backgroundColor: context.scaffoldBg,
                                side: BorderSide(
                                  color: isSelected
                                      ? context.primaryAccent
                                      : context.borderCol,
                                ),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? context.primaryAccent
                                      : context.textSecondaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Lịch sử tra cứu gần đây (khi ô tìm kiếm trống)
            if (_searchController.text.trim().isEmpty &&
                studyProvider.searchHistory.isNotEmpty)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: context.surfaceBg,
                  border: Border(bottom: BorderSide(color: context.borderCol)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1060),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.dictRecentSearches,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: context.textSecondaryColor,
                              ),
                            ),
                            InkWell(
                              onTap: () => studyProvider.clearSearchHistory(),
                              child: Text(
                                context.l10n.dictClearHistory,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: studyProvider.searchHistory.map((query) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ActionChip(
                                  avatar: Icon(
                                    Icons.history_rounded,
                                    size: 14,
                                    color: context.textMutedColor,
                                  ),
                                  label: Text(
                                    query,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                  backgroundColor: context.scaffoldBg,
                                  side: BorderSide(color: context.borderCol),
                                  onPressed: () {
                                    _searchController.text = query;
                                    _onSearch(query);
                                    setState(() {});
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Kết quả tìm kiếm
            Expanded(
              child: dictProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSearchResults(dictProvider, studyProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    DictionaryProvider dictProvider,
    StudyProvider studyProvider,
  ) {
    if (_searchController.text.trim().isEmpty &&
        !dictProvider.hasActiveFilters) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              constraints.maxHeight < 380 || constraints.maxWidth < 420;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 16.0 : 28.0,
              vertical: isCompact ? 14.0 : 24.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isCompact ? 14 : 18),
                      decoration: BoxDecoration(
                        color: context.primaryContainerCol,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        size: isCompact ? 36 : 46,
                        color: context.primaryAccent,
                      ),
                    ),
                    SizedBox(height: isCompact ? 12 : 16),
                    Text(
                      context.l10n.dictTitleFull,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isCompact ? 16.5 : 18.5,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: isCompact ? 6 : 8),
                    Text(
                      context.l10n.dictIntroDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isCompact ? 12.5 : 13.5,
                        color: context.textSecondaryColor,
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    if (dictProvider.localResults.isEmpty) {
      return _buildNoLocalResult(dictProvider, studyProvider);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1060),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ...dictProvider.localResults
                .map((word) => _buildWordResultCard(word, studyProvider)),
            if (dictProvider.currentQuery.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: OutlinedButton.icon(
                  onPressed: dictProvider.isSearchingOnline
                      ? null
                      : () => dictProvider.searchOnline(),
                  icon: dictProvider.isSearchingOnline
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.travel_explore_rounded, size: 18),
                  label: Text(
                    dictProvider.isVietnameseQuery
                        ? context.l10n.dictOnlineViEnQuery(dictProvider.currentQuery)
                        : context.l10n.dictOnlineEnViQuery(dictProvider.currentQuery),
                  ),
                ),
              ),
              if (dictProvider.onlineResult != null) ...[
                const SizedBox(height: 16),
                _buildOnlineResultCard(
                    dictProvider.onlineResult!, studyProvider),
              ],
              if (dictProvider.onlineErrorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.danger, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          dictProvider.onlineErrorMessage!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.danger),
                        ),
                      ),
                      if (dictProvider.onlineSearchStatus ==
                          DictionarySearchStatus.networkError) ...[
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => dictProvider.retrySearchOnline(),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: Text(context.l10n.dictRetry),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWordResultCard(WordModel word, StudyProvider studyProvider) {
    String? topicName;
    try {
      topicName = studyProvider.topics
          .firstWhere((t) => t.id == word.topicId)
          .name;
    } catch (_) {}

    final isInReview = word.status == AppConstants.statusLearning;

    return InteractiveCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WordDetailScreen(word: word)),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton.filled(
            onPressed: () => TtsService().speak(word.term),
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: context.l10n.dictTtsTooltip,
            style: IconButton.styleFrom(
              backgroundColor: context.primaryContainerCol,
              foregroundColor: context.primaryAccent,
            ),
          ),
          const SizedBox(width: 14),
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
                      word.term,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.primaryContainerCol,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        word.level,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: context.primaryAccent,
                        ),
                      ),
                    ),
                    if (word.partOfSpeech.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.scaffoldBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: context.borderCol),
                        ),
                        child: Text(
                          word.partOfSpeech,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ),
                    if (topicName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.scaffoldBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: context.borderCol),
                        ),
                        child: Text(
                          topicName,
                          style: TextStyle(
                            fontSize: 10,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
                if (word.ipa.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    word.ipa,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  word.meaning,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
                if (word.englishDefinition.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    word.englishDefinition,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5, color: context.textSecondaryColor),
                  ),
                ],
                if (word.exampleEn.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.scaffoldBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: context.borderCol.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.exampleEn,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        if (word.exampleVi.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            word.exampleVi,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () async {
                        if (isInReview) {
                          await studyProvider.markAsNew(word);
                        } else {
                          await studyProvider.markAsLearning(word);
                        }
                        if (context.mounted) {
                          UiHelpers.showSnackBar(
                            context,
                            message: isInReview
                                ? context.l10n.dictMovedToNew(word.term)
                                : context.l10n.dictAddedToReview(word.term),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isInReview
                              ? context.activeNavBg
                              : context.scaffoldBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isInReview
                                ? context.primaryAccent
                                : context.borderCol,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isInReview
                                  ? Icons.check_circle_rounded
                                  : Icons.playlist_add_rounded,
                              size: 13,
                              color: isInReview
                                  ? context.primaryAccent
                                  : context.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isInReview
                                  ? context.l10n.dictInReview
                                  : context.l10n.dictAddToReview,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isInReview
                                    ? context.primaryAccent
                                    : context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: word.isFavorite
                ? context.l10n.dictFavoriteRemove
                : context.l10n.dictFavoriteAdd,
            icon: Icon(
              word.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color:
                  word.isFavorite ? AppColors.danger : context.textMutedColor,
            ),
            onPressed: () => studyProvider.toggleFavorite(word),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLocalResult(
    DictionaryProvider dictProvider,
    StudyProvider studyProvider,
  ) {
    final isVi = dictProvider.isVietnameseQuery;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 54, color: context.textMutedColor),
              const SizedBox(height: 14),
              Text(
                context.l10n.dictNotFoundInternal(dictProvider.currentQuery),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isVi
                    ? context.l10n.dictViEnOnlinePrompt
                    : context.l10n.dictEnViOnlinePrompt,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 13, color: context.textSecondaryColor),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: dictProvider.isSearchingOnline
                    ? null
                    : () => dictProvider.searchOnline(),
                icon: dictProvider.isSearchingOnline
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.travel_explore_rounded),
                label: Text(
                  isVi
                      ? context.l10n.dictOnlineViEn
                      : context.l10n.dictOnlineEnVi,
                ),
              ),
              if (dictProvider.onlineResult != null) ...[
                const SizedBox(height: 24),
                _buildOnlineResultCard(
                    dictProvider.onlineResult!, studyProvider),
              ],
              if (dictProvider.onlineErrorMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dictProvider.onlineErrorMessage!,
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      if (dictProvider.onlineSearchStatus ==
                          DictionarySearchStatus.networkError) ...[
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () => dictProvider.retrySearchOnline(),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: Text(context.l10n.dictRetryConnection),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineResultCard(
    OnlineDictionaryResult result,
    StudyProvider studyProvider,
  ) {
    final isSaved = _savedOnlineWords.contains(result.word.toLowerCase());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Chiều tra cứu, trạng thái cache và các nút hành động
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.primaryContainerCol,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: context.primaryAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      result.isVietnameseToEnglish
                          ? '🇻🇳 Việt ➔ 🇬🇧 Anh'
                          : '🇬🇧 Anh ➔ 🇻🇳 Việt',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: context.primaryAccent,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: result.isFromCache
                          ? context.primaryContainerCol
                          : (context.isDark
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.successLight),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      result.isFromCache
                          ? context.l10n.dictCachedBadge
                          : context.l10n.dictLiveApi,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: result.isFromCache
                            ? AppColors.primary
                            : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: context.l10n.dictListenWord,
                    icon: Icon(Icons.volume_up_rounded,
                        color: context.primaryAccent),
                    onPressed: () => TtsService().speak(result.word),
                  ),
                  TextButton.icon(
                    onPressed: isSaved
                        ? null
                        : () => _saveOnlineWordToLocal(result, studyProvider),
                    icon: Icon(
                      isSaved
                          ? Icons.check_circle_rounded
                          : Icons.bookmark_add_outlined,
                      size: 17,
                    ),
                    label:
                        Text(isSaved ? context.l10n.dictSaved : context.l10n.dictSaveToReview),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Hiển thị theo chiều tra cứu Việt-Anh hoặc Anh-Việt
          if (result.isVietnameseToEnglish) ...[
            Text(
              context.l10n.dictViKeyword(result.displayQuery),
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  result.word,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.primaryAccent,
                  ),
                ),
                if (result.phonetic != null && result.phonetic!.isNotEmpty)
                  Text(
                    result.phonetic!,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            if (result.alternativeTranslations.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    context.l10n.dictEquivalentEnWords,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  ...result.alternativeTranslations.map((alt) {
                    return ActionChip(
                      label: Text(alt),
                      padding: EdgeInsets.zero,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.textPrimaryColor,
                      ),
                      backgroundColor: context.scaffoldBg,
                      side: BorderSide(color: context.borderCol),
                      onPressed: () => TtsService().speak(alt),
                      tooltip: context.l10n.dictListenTooltip(alt),
                    );
                  }),
                ],
              ),
            ],
            if (result.vietnameseTranslation != null &&
                result.vietnameseTranslation!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.scaffoldBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.borderCol),
                ),
                child: Text(
                  context.l10n.dictViRefMeaning(result.vietnameseTranslation!),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ] else ...[
            Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  result.word,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                if (result.phonetic != null && result.phonetic!.isNotEmpty)
                  Text(
                    result.phonetic!,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            if (result.vietnameseTranslation != null &&
                result.vietnameseTranslation!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.primaryContainerCol,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.dictViTranslation,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: context.primaryAccent,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      result.vietnameseTranslation!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (result.alternativeTranslations.length > 1) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    context.l10n.dictOtherMeanings,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  ...result.alternativeTranslations.skip(1).map((alt) {
                    return Chip(
                      label: Text(alt),
                      padding: EdgeInsets.zero,
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        color: context.textPrimaryColor,
                      ),
                      backgroundColor: context.scaffoldBg,
                      side: BorderSide(color: context.borderCol),
                    );
                  }),
                ],
              ),
            ],
          ],

          // Định nghĩa từ điển tiếng Anh & ví dụ minh họa
          if (result.definitions.isNotEmpty) ...[
            Divider(height: 24, color: context.borderCol),
            Text(
              context.l10n.dictEnglishDefinitions,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            ...result.definitions.take(4).map((def) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• (${def.partOfSpeech}) ${def.definition}',
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    if (def.example != null && def.example!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 3),
                        child: Text(
                          context.l10n.dictExamplePrefix(def.example!),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ),
                    if (def.synonyms.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 3),
                        child: Text(
                          context.l10n.dictSynonymsList(def.synonyms.join(", ")),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.scaffoldBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: context.textMutedColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.l10n.dictSourceInfo(result.sourceName, result.license, result.sourceUrl),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
