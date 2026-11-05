import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/tts_service.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../../data/models/skill_exercise_model.dart';
import '../../../data/models/word_model.dart';
import '../../../providers/skills_provider.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/custom_button.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final SkillExerciseModel exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool _isPlaying = false;
  double _playbackSpeed = 1.0; // 0.75x, 1.0x, 1.25x
  bool _showTranscript = false;
  bool _showReadingTranslation = false;
  final Map<int, int> _userMcqAnswers = {}; // questionIndex -> optionIndex
  final Map<int, TextEditingController> _fillControllers = {};
  final Set<String> _savedTerms = {};
  bool _isSubmitted = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.exercise.questions.length; i++) {
      if (widget.exercise.questions[i].isFillBlank) {
        _fillControllers[i] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    TtsService().stop();
    for (final controller in _fillControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _playAudio({double? speed, bool restart = false}) async {
    final targetSpeed = speed ?? _playbackSpeed;
    if (_isPlaying && !restart && (speed == null || speed == _playbackSpeed)) {
      await TtsService().stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    setState(() {
      _isPlaying = true;
      _playbackSpeed = targetSpeed;
    });

    await TtsService().speakRate(widget.exercise.content, rateMultiplier: targetSpeed);
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  bool _isQuestionAnswered(int index, SkillQuestion q) {
    if (q.isFillBlank) {
      return (_fillControllers[index]?.text.trim().isNotEmpty ?? false);
    }
    return _userMcqAnswers.containsKey(index);
  }

  bool _isQuestionCorrect(int index, SkillQuestion q) {
    if (q.isFillBlank) {
      final userText = _fillControllers[index]?.text ?? '';
      return q.isTextAnswerCorrect(userText);
    }
    return _userMcqAnswers[index] == q.correctOptionIndex;
  }

  Future<void> _submitAnswers() async {
    for (int i = 0; i < widget.exercise.questions.length; i++) {
      if (!_isQuestionAnswered(i, widget.exercise.questions[i])) {
        UiHelpers.showSnackBar(
          context,
          message: 'Vui lòng hoàn thành câu hỏi số ${i + 1} trước khi nộp bài!',
          isError: true,
        );
        return;
      }
    }

    int correct = 0;
    for (int i = 0; i < widget.exercise.questions.length; i++) {
      if (_isQuestionCorrect(i, widget.exercise.questions[i])) {
        correct++;
      }
    }

    setState(() {
      _isSubmitted = true;
      _correctCount = correct;
      // Tự động mở khóa transcript cho bài Nghe sau khi nộp bài
      if (widget.exercise.type == SkillType.listening) {
        _showTranscript = true;
      }
    });

    final total = widget.exercise.questions.length;
    final score = total > 0 ? (correct / total) * 100 : 100.0;
    final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
    await skillsProvider.saveScore(
      skillType: widget.exercise.type.name,
      exerciseId: widget.exercise.id,
      title: widget.exercise.title,
      score: score,
    );

    if (mounted) {
      UiHelpers.showSnackBar(
        context,
        message: context.l10n.exerciseScoreResult(correct, total, score.toInt()),
      );
    }
  }

  Future<void> _saveKeyWordToStudy(LessonKeyWord kw) async {
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);
    final topicId =
        studyProvider.topics.isNotEmpty ? studyProvider.topics.first.id : 1;

    final newWord = WordModel(
      id: 0,
      topicId: topicId,
      term: kw.term,
      ipa: kw.ipa.isNotEmpty ? kw.ipa : '/.../',
      partOfSpeech: kw.partOfSpeech,
      meaning: kw.meaning,
      englishDefinition:
          'Key vocabulary from lesson: ${widget.exercise.title}',
      exampleEn: kw.example.isNotEmpty
          ? kw.example
          : 'Learned from ${widget.exercise.title}.',
      exampleVi: kw.meaning,
      level: widget.exercise.level,
      status: AppConstants.statusLearning,
      isFavorite: true,
    );

    await studyProvider.addNewWord(newWord);
    if (mounted) {
      setState(() => _savedTerms.add(kw.term));
      UiHelpers.showSnackBar(
        context,
        message: context.l10n.exerciseSaveWordSuccess(kw.term),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isListening = widget.exercise.type == SkillType.listening;
    final totalQ = widget.exercise.questions.length;
    final scorePercent = totalQ > 0 ? (_correctCount / totalQ * 100).round() : 0;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(widget.exercise.title),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thẻ cấp độ & chủ đề
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.primaryContainerCol,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'CEFR ${widget.exercise.level}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.borderCol),
                      ),
                      child: Text(
                        isListening ? context.l10n.exerciseListeningTitle : context.l10n.exerciseReadingTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ),
                    Text(
                      '• ${widget.exercise.topic}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Khung kết quả sau khi nộp bài
                if (_isSubmitted) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: scorePercent >= 70
                          ? (context.isDark
                              ? AppColors.success.withValues(alpha: 0.16)
                              : AppColors.successLight)
                          : (context.isDark
                              ? AppColors.warning.withValues(alpha: 0.16)
                              : AppColors.warningLight),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scorePercent >= 70
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          scorePercent >= 70
                              ? Icons.emoji_events_rounded
                              : Icons.lightbulb_rounded,
                          color: scorePercent >= 70
                              ? AppColors.success
                              : AppColors.warning,
                          size: 32,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.exerciseScoreResult(_correctCount, totalQ, scorePercent),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isListening
                                    ? 'Lời thoại (Transcript) và bản dịch tiếng Việt bên dưới đã được mở khóa để bạn đối chiếu và nghe lại.'
                                    : 'Xem giải thích chi tiết từng câu bên dưới và lưu lại các từ vựng trọng tâm trong bài.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Phần Audio Player nếu là Listening
                if (isListening) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: context.primaryContainerCol,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.headphones_rounded,
                                  color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.exerciseAudioPlayer,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Phát âm chuẩn tiếng Anh bản xứ qua TTS Engine',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Thanh điều khiển: Phát/Tạm dừng, Tua lại, Tốc độ
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _playAudio(),
                              icon: Icon(_isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded),
                              label: Text(_isPlaying
                                  ? 'Tạm dừng'
                                  : 'Phát âm thanh ($_playbackSpeed x)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _playAudio(restart: true),
                              icon: const Icon(Icons.replay_rounded, size: 18),
                              label: const Text('Phát lại từ đầu'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Chọn tốc độ đọc (0.75x, 1.0x, 1.25x)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tốc độ đọc: ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            ...[0.75, 1.0, 1.25].map((spd) {
                              final isSelected = (_playbackSpeed == spd);
                              return Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: ChoiceChip(
                                  label: Text('${spd}x'),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      _playAudio(speed: spd, restart: _isPlaying);
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
                                    fontSize: 11.5,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? context.primaryAccent
                                        : context.textSecondaryColor,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),

                        if (_isPlaying) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              minHeight: 4,
                              color: AppColors.primary,
                              backgroundColor: context.primaryContainerCol,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Nút ẩn / hiện transcript
                        TextButton.icon(
                          onPressed: () => setState(
                              () => _showTranscript = !_showTranscript),
                          icon: Icon(
                            _showTranscript
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 17,
                          ),
                          label: Text(_showTranscript
                              ? context.l10n.exerciseHideTranscript
                              : context.l10n.exerciseShowTranscript),
                        ),

                        if (_showTranscript) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.scaffoldBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: context.borderCol),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.subtitles_rounded,
                                        size: 16, color: AppColors.primary),
                                    SizedBox(width: 6),
                                    Text(
                                      'Transcript tiếng Anh:',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SelectableText(
                                  widget.exercise.content,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    height: 1.55,
                                    color: context.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Divider(height: 1, color: context.borderCol),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.translate_rounded,
                                        size: 16, color: context.textSecondaryColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Bản dịch tiếng Việt đối chiếu:',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: context.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                SelectableText(
                                  widget.exercise.contentVi,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: context.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  // Phần Bài đọc nếu là Reading
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.exerciseReadingPassage,
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Thời gian ước tính: ~${widget.exercise.estimatedReadMinutes} phút đọc • ${widget.exercise.wordCount} từ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              tooltip: _isPlaying ? 'Dừng đọc' : 'Nghe đọc mẫu đoạn văn',
                              icon: Icon(
                                _isPlaying
                                    ? Icons.stop_rounded
                                    : Icons.volume_up_rounded,
                                color: AppColors.primary,
                              ),
                              onPressed: () => _playAudio(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SelectableText(
                          widget.exercise.content,
                          style: TextStyle(
                            fontSize: 15.5,
                            height: 1.65,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextButton.icon(
                          onPressed: () => setState(() =>
                              _showReadingTranslation = !_showReadingTranslation),
                          icon: Icon(
                            _showReadingTranslation
                                ? Icons.translate_rounded
                                : Icons.translate_rounded,
                            size: 16,
                          ),
                          label: Text(_showReadingTranslation
                              ? 'Ẩn bản dịch tiếng Việt'
                              : 'Xem bản dịch tiếng Việt đối chiếu'),
                        ),
                        if (_showReadingTranslation) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: context.scaffoldBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.borderCol),
                            ),
                            child: SelectableText(
                              widget.exercise.contentVi,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.5,
                                color: context.textSecondaryColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Danh sách câu hỏi kiểm tra (hỗ trợ cả Trắc nghiệm & Điền từ ngắn)
                Text(
                  context.l10n.exerciseQuestionsCount(widget.exercise.questions.length),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                ...widget.exercise.questions.asMap().entries.map((entry) {
                  final qIndex = entry.key;
                  final q = entry.value;
                  final isQCorrect =
                      _isSubmitted && _isQuestionCorrect(qIndex, q);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _isSubmitted
                            ? (isQCorrect
                                ? AppColors.success
                                : AppColors.danger)
                            : context.borderCol,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              margin: const EdgeInsets.only(right: 8, top: 2),
                              decoration: BoxDecoration(
                                color: q.isFillBlank
                                    ? AppColors.accent.withValues(alpha: 0.14)
                                    : context.primaryContainerCol,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                q.isFillBlank ? 'Điền từ' : 'Trắc nghiệm',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: q.isFillBlank
                                      ? AppColors.accent
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Câu ${qIndex + 1}: ${q.questionText}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (q.isFillBlank) ...[
                          TextField(
                            controller: _fillControllers[qIndex],
                            enabled: !_isSubmitted,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              fontSize: 14.5,
                              color: context.textPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Nhập từ/cụm từ tiếng Anh còn thiếu...',
                              filled: true,
                              fillColor: context.scaffoldBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: _isSubmitted
                                  ? Icon(
                                      isQCorrect
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded,
                                      color: isQCorrect
                                          ? AppColors.success
                                          : AppColors.danger,
                                    )
                                  : null,
                            ),
                          ),
                          if (_isSubmitted && !isQCorrect) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Đáp án đúng: ${q.acceptedAnswers.isNotEmpty ? q.acceptedAnswers.join(" / ") : q.options.firstOrNull ?? ""}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ] else ...[
                          ...q.options.asMap().entries.map((optEntry) {
                            final optIndex = optEntry.key;
                            final optText = optEntry.value;
                            final isSelected =
                                _userMcqAnswers[qIndex] == optIndex;
                            final isCorrect = q.correctOptionIndex == optIndex;

                            Color tileColor = context.scaffoldBg;
                            Color borderColor = context.borderCol;
                            if (_isSubmitted) {
                              if (isCorrect) {
                                tileColor = context.isDark
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : AppColors.successLight;
                                borderColor = AppColors.success;
                              } else if (isSelected && !isCorrect) {
                                tileColor = context.isDark
                                    ? AppColors.danger.withValues(alpha: 0.2)
                                    : AppColors.dangerLight;
                                borderColor = AppColors.danger;
                              }
                            } else if (isSelected) {
                              tileColor = context.primaryContainerCol;
                              borderColor = AppColors.primary;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: tileColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: borderColor,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  optText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.textPrimaryColor,
                                  ),
                                ),
                                onTap: _isSubmitted
                                    ? null
                                    : () {
                                        setState(() {
                                          _userMcqAnswers[qIndex] = optIndex;
                                        });
                                      },
                              ),
                            );
                          }),
                        ],
                        if (_isSubmitted) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.scaffoldBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    size: 17, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Giải thích: ${q.explanation}',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),

                // Danh sách từ vựng trọng tâm trong bài (Lesson Key Vocabulary)
                if (widget.exercise.keyWords.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu_book_rounded,
                                size: 20, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.exerciseKeyWords(widget.exercise.keyWords.length),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...widget.exercise.keyWords.map((kw) {
                          final isSaved = _savedTerms.contains(kw.term);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.scaffoldBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.borderCol),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.volume_up_rounded,
                                      color: AppColors.primary, size: 20),
                                  onPressed: () => TtsService().speak(kw.term),
                                  tooltip: context.l10n.homeListenPronunciation,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 6,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            kw.term,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: context.textPrimaryColor,
                                            ),
                                          ),
                                          if (kw.ipa.isNotEmpty)
                                            Text(
                                              kw.ipa,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color:
                                                    context.textSecondaryColor,
                                              ),
                                            ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color:
                                                  context.primaryContainerCol,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              kw.partOfSpeech,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        kw.meaning,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: context.textPrimaryColor,
                                        ),
                                      ),
                                      if (kw.example.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'VD: "${kw.example}"',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: context.textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: isSaved
                                      ? null
                                      : () => _saveKeyWordToStudy(kw),
                                  icon: Icon(
                                    isSaved
                                        ? Icons.check_circle_rounded
                                        : Icons.bookmark_add_outlined,
                                    size: 16,
                                  ),
                                  label: Text(isSaved ? context.l10n.dictSaved : context.l10n.actionSave),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                if (!_isSubmitted)
                  CustomButton(
                    text: context.l10n.exerciseSubmitGrade,
                    icon: Icons.check_rounded,
                    onPressed: _submitAnswers,
                  )
                else
                  CustomButton(
                    text: context.l10n.exerciseRetake,
                    icon: Icons.refresh_rounded,
                    onPressed: () {
                      setState(() {
                        _userMcqAnswers.clear();
                        for (final c in _fillControllers.values) {
                          c.clear();
                        }
                        _isSubmitted = false;
                        _showTranscript = false;
                      });
                    },
                  ),

                const SizedBox(height: 20),
                // Metadata nguồn biên soạn & bản quyền
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Text(
                    'Nguồn học liệu: ${widget.exercise.attribution.source} • Tác giả: ${widget.exercise.attribution.author} • Giấy phép: ${widget.exercise.attribution.license}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: context.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
