import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/skill_exercise_model.dart';
import '../../../providers/skills_provider.dart';
import '../../widgets/custom_button.dart';

class WritingExerciseScreen extends StatefulWidget {
  final SkillExerciseModel exercise;

  const WritingExerciseScreen({super.key, required this.exercise});

  @override
  State<WritingExerciseScreen> createState() => _WritingExerciseScreenState();
}

class _WritingExerciseScreenState extends State<WritingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // State cho Tab 1: Sắp xếp câu
  int _currentSentenceIndex = 0;
  final List<String> _selectedWords = [];
  late List<String> _availableWords;
  bool _isAnswerChecked = false;
  bool? _isCorrect;
  int _score = 0;

  // State cho Tab 2: Viết đoạn văn / Bài luận theo Rubric
  final TextEditingController _essayController = TextEditingController();
  final Set<int> _checkedRubricIndices = {0, 1};
  bool _isEssaySaved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.exercise.writingPromptTask != null ? 2 : 1,
      vsync: this,
    );
    _loadSentence();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _essayController.dispose();
    TtsService().stop();
    super.dispose();
  }

  void _loadSentence() {
    if (widget.exercise.writingSentences.isEmpty) {
      _availableWords = [];
      return;
    }
    final current = widget.exercise.writingSentences[_currentSentenceIndex];
    _availableWords = List<String>.from(current.scrambledWords);
    _selectedWords.clear();
    _isAnswerChecked = false;
    _isCorrect = null;
  }

  void _selectWord(int index) {
    if (_isAnswerChecked) return;
    setState(() {
      _selectedWords.add(_availableWords.removeAt(index));
    });
  }

  void _unselectWord(int index) {
    if (_isAnswerChecked) return;
    setState(() {
      _availableWords.add(_selectedWords.removeAt(index));
    });
  }

  void _checkAnswer() {
    final current = widget.exercise.writingSentences[_currentSentenceIndex];
    final userSentence = _selectedWords.join(' ').trim().toLowerCase();
    final targetSentence = current.englishSentence.trim().toLowerCase();

    final cleanUser = userSentence.replaceAll(RegExp(r'[^\w\s]'), '');
    final cleanTarget = targetSentence.replaceAll(RegExp(r'[^\w\s]'), '');

    final correct = cleanUser == cleanTarget;

    setState(() {
      _isAnswerChecked = true;
      _isCorrect = correct;
      if (correct) _score++;
    });

    if (correct) {
      TtsService().speak(current.englishSentence);
    }
  }

  Future<void> _nextSentence() async {
    if (_currentSentenceIndex < widget.exercise.writingSentences.length - 1) {
      setState(() {
        _currentSentenceIndex++;
        _loadSentence();
      });
    } else {
      final skillsProvider =
          Provider.of<SkillsProvider>(context, listen: false);
      final finalScore =
          (_score / widget.exercise.writingSentences.length) * 100;
      await skillsProvider.saveScore(
        skillType: widget.exercise.type.name,
        exerciseId: widget.exercise.id,
        title: '${widget.exercise.title} (Sắp xếp câu)',
        score: finalScore,
      );
      if (mounted) _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final hasPrompt = widget.exercise.writingPromptTask != null;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hoàn thành phần Cấu trúc câu!'),
        content: Text(
          'Bạn đã ghép chính xác $_score/${widget.exercise.writingSentences.length} câu.\n'
          '${hasPrompt ? "Bạn có muốn chuyển sang phần Viết đoạn văn theo Rubric để luyện diễn đạt tự do không?" : ""}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Quay lại danh sách'),
          ),
          if (hasPrompt)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _tabController.animateTo(1);
              },
              child: const Text('Viết đoạn văn'),
            ),
        ],
      ),
    );
  }

  int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  List<String> _usedTargetKeywords(WritingPromptTask task, String text) {
    final lower = text.toLowerCase();
    return task.targetKeywords
        .where((kw) => lower.contains(kw.toLowerCase()))
        .toList();
  }

  Future<void> _saveEssaySubmission(WritingPromptTask task) async {
    final text = _essayController.text.trim();
    final wordCount = _countWords(text);
    if (wordCount < 10) {
      UiHelpers.showSnackBar(
        context,
        message: 'Vui lòng viết ít nhất 10 từ trước khi lưu bài làm!',
        isError: true,
      );
      return;
    }

    final usedKeywords = _usedTargetKeywords(task, text);
    final lengthRatio = (wordCount / task.minWords).clamp(0.0, 1.0);
    final keywordRatio = task.targetKeywords.isEmpty
        ? 1.0
        : (usedKeywords.length / task.targetKeywords.length).clamp(0.0, 1.0);
    final rubricRatio = task.rubricCriteria.isEmpty
        ? 1.0
        : (_checkedRubricIndices.length / task.rubricCriteria.length)
            .clamp(0.0, 1.0);

    // Điểm hoàn thành dựa trên quy tắc minh bạch (40% độ dài, 30% từ khóa, 30% tự rà soát Rubric)
    final rubricCompletionScore =
        ((lengthRatio * 40) + (keywordRatio * 30) + (rubricRatio * 30))
            .clamp(0.0, 100.0);

    final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
    await skillsProvider.saveScore(
      skillType: widget.exercise.type.name,
      exerciseId: widget.exercise.id,
      title: '${widget.exercise.title} (Bài viết)',
      score: rubricCompletionScore,
      userSubmission: text,
      detailsJson:
          'words:$wordCount,keywords:${usedKeywords.length}/${task.targetKeywords.length},rubric:${_checkedRubricIndices.length}/${task.rubricCriteria.length}',
    );

    if (mounted) {
      setState(() => _isEssaySaved = true);
      UiHelpers.showSnackBar(
        context,
        message:
            'Đã lưu bài viết vào SQLite và mở khóa Bài mẫu tham khảo!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPrompt = widget.exercise.writingPromptTask != null;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(widget.exercise.title),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        bottom: hasPrompt
            ? TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: context.textSecondaryColor,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.sort_by_alpha_rounded, size: 18),
                    text: '1. Cấu trúc & Sắp xếp câu',
                  ),
                  Tab(
                    icon: Icon(Icons.edit_document, size: 18),
                    text: '2. Viết đoạn văn & Rubric',
                  ),
                ],
              )
            : null,
      ),
      body: hasPrompt
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildSentenceScrambleTab(context),
                _buildGuidedWritingTab(
                    context, widget.exercise.writingPromptTask!),
              ],
            )
          : _buildSentenceScrambleTab(context),
    );
  }

  Widget _buildSentenceScrambleTab(BuildContext context) {
    final sentence = widget.exercise.writingSentences[_currentSentenceIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.primaryContainerCol,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'CEFR ${widget.exercise.level} • ${widget.exercise.topic}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    'Câu ${_currentSentenceIndex + 1}/${widget.exercise.writingSentences.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Đề bài: Nghĩa tiếng Việt
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
                      'Sắp xếp các từ để tạo thành câu tiếng Anh có nghĩa:',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sentence.vietnameseMeaning,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    if (sentence.hint.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              size: 16, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Gợi ý: ${sentence.hint}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.textSecondaryColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Vùng sắp xếp câu
              Container(
                constraints: const BoxConstraints(minHeight: 110),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _isCorrect == null
                        ? AppColors.primary
                        : (_isCorrect! ? AppColors.success : AppColors.danger),
                    width: 2,
                  ),
                ),
                child: _selectedWords.isEmpty
                    ? Center(
                        child: Text(
                          'Chạm vào các từ bên dưới để ghép câu...',
                          style: TextStyle(
                            color: context.textMutedColor,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedWords.asMap().entries.map((entry) {
                          return ActionChip(
                            label: Text(
                              entry.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            backgroundColor: context.primaryContainerCol,
                            side: const BorderSide(color: AppColors.primary),
                            onPressed: () => _unselectWord(entry.key),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 20),

              // Kho từ vựng có sẵn
              Text(
                'Các từ có sẵn:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableWords.asMap().entries.map((entry) {
                  return ActionChip(
                    label: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    backgroundColor: context.cardBg,
                    side: BorderSide(color: context.borderCol),
                    onPressed: () => _selectWord(entry.key),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Thông báo kết quả
              if (_isAnswerChecked) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isCorrect!
                        ? (context.isDark
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.successLight)
                        : (context.isDark
                            ? AppColors.danger.withValues(alpha: 0.2)
                            : AppColors.dangerLight),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isCorrect! ? Icons.check_circle : Icons.cancel,
                            color: _isCorrect!
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isCorrect! ? 'Chính xác!' : 'Chưa chính xác!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isCorrect!
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                      if (!_isCorrect!) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Đáp án đúng: ${sentence.englishSentence}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Nút hành động
              if (!_isAnswerChecked)
                CustomButton(
                  text: 'Kiểm tra câu',
                  onPressed: _selectedWords.isEmpty ? null : _checkAnswer,
                )
              else
                CustomButton(
                  text: _currentSentenceIndex <
                          widget.exercise.writingSentences.length - 1
                      ? 'Câu tiếp theo'
                      : 'Hoàn thành phần Sắp xếp câu',
                  onPressed: _nextSentence,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidedWritingTab(BuildContext context, WritingPromptTask task) {
    final text = _essayController.text;
    final wordCount = _countWords(text);
    final usedKeywords = _usedTargetKeywords(task, text);
    final hasGoodPunctuation =
        text.trim().isNotEmpty && RegExp(r'[.!?]$').hasMatch(text.trim());
    final savedList =
        context.watch<SkillsProvider>().getSavedSubmissions(widget.exercise.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Đề bài viết đoạn văn / bài luận
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
                      children: [
                        const Icon(Icons.assignment_outlined,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.promptTitle,
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      task.promptDescription,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Từ khóa gợi ý nên đưa vào bài viết (${usedKeywords.length}/${task.targetKeywords.length} đã dùng):',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: task.targetKeywords.map((kw) {
                        final isUsed = usedKeywords.contains(kw);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isUsed
                                ? (context.isDark
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : AppColors.successLight)
                                : context.scaffoldBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isUsed
                                  ? AppColors.success
                                  : context.borderCol,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUsed
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 15,
                                color: isUsed
                                    ? AppColors.success
                                    : context.textMutedColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                kw,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isUsed
                                      ? AppColors.success
                                      : context.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Ô soạn thảo văn bản
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bài viết của bạn',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: wordCount >= task.minWords
                                ? (context.isDark
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : AppColors.successLight)
                                : context.primaryContainerCol,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Số từ: $wordCount / tối thiểu ${task.minWords} từ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: wordCount >= task.minWords
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _essayController,
                      maxLines: 7,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: context.textPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Nhập đoạn văn tiếng Anh của bạn tại đây...',
                        filled: true,
                        fillColor: context.scaffoldBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Phản hồi quy tắc tự động (Không giả lập AI)
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _buildRuleBadge(
                          context,
                          label: wordCount >= task.minWords
                              ? 'Đạt độ dài yêu cầu ($wordCount từ)'
                              : 'Cần thêm ${task.minWords - wordCount} từ nữa',
                          passed: wordCount >= task.minWords,
                        ),
                        _buildRuleBadge(
                          context,
                          label:
                              'Từ khóa mục tiêu: ${usedKeywords.length}/${task.targetKeywords.length}',
                          passed: usedKeywords.length >=
                              (task.targetKeywords.length / 2).ceil(),
                        ),
                        _buildRuleBadge(
                          context,
                          label: hasGoodPunctuation
                              ? 'Kết thúc câu đúng dấu câu'
                              : 'Chú ý dấu chấm kết câu (. ! ?)',
                          passed: hasGoodPunctuation,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Rubric tự rà soát (Self-Evaluation Rubric)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bảng kiểm tự đánh giá bài viết (Writing Rubric)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hãy tự kiểm tra bài viết theo 4 tiêu chí chuẩn trước khi lưu. Ứng dụng kiểm tra quy tắc thực tế (số từ, từ khóa, dấu câu) và không sinh điểm chấm AI giả.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...task.rubricCriteria.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final criterion = entry.value;
                      final isChecked = _checkedRubricIndices.contains(idx);
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: isChecked,
                        activeColor: AppColors.primary,
                        title: Text(
                          criterion,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _checkedRubricIndices.add(idx);
                            } else {
                              _checkedRubricIndices.remove(idx);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              CustomButton(
                text: 'Lưu bài viết & Mở khóa Bài mẫu tham khảo',
                icon: Icons.save_rounded,
                onPressed: () => _saveEssaySubmission(task),
              ),

              // Bài mẫu tham khảo (Mở khóa sau khi lưu hoặc đã có bài lưu)
              if (_isEssaySaved || savedList.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bài viết mẫu tham khảo (Model Answer)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Nghe bài mẫu',
                            icon: const Icon(Icons.volume_up_rounded,
                                color: AppColors.primary),
                            onPressed: () =>
                                TtsService().speak(task.sampleAnswer),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        task.sampleAnswer,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.55,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Lịch sử bài viết đã lưu trong SQLite
              if (savedList.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Bài viết đã lưu của bạn (${savedList.length} bản lưu)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                ...savedList.take(3).map((item) {
                  final submission = item['user_submission']?.toString() ?? '';
                  final score = (item['score'] as num?)?.toInt() ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mức độ hoàn thành Rubric: $score%',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _essayController.text = submission;
                                });
                              },
                              child: const Text('Tải lại vào khung soạn'),
                            ),
                          ],
                        ),
                        Text(
                          submission,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: context.textSecondaryColor,
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

  Widget _buildRuleBadge(BuildContext context,
      {required String label, required bool passed}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          passed ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          size: 15,
          color: passed ? AppColors.success : AppColors.warning,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: passed ? AppColors.success : context.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
