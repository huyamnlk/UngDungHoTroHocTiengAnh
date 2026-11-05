import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/tts_service.dart';
import '../../../data/models/game_record_model.dart';
import '../../../data/models/word_model.dart';
import '../../../providers/games_provider.dart';
import '../../widgets/custom_button.dart';


class SpellingBeeScreen extends StatefulWidget {
  final List<WordModel> words;
  final String topicName;
  final int? topicId;
  final String level;

  const SpellingBeeScreen({
    super.key,
    required this.words,
    this.topicName = 'Tất cả chủ đề',
    this.topicId,
    this.level = 'All',
  });

  @override
  State<SpellingBeeScreen> createState() => _SpellingBeeScreenState();
}

class _SpellingBeeScreenState extends State<SpellingBeeScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late List<WordModel> _wordPool;
  int _currentIndex = 0;
  final int _totalRounds = 10;

  // Từ hiện tại
  late WordModel _currentWord;
  int _audioReplaysLeft = 3;
  bool _showMeaningHint = false;
  bool _showExampleHint = false;
  bool _showFirstLetterHint = false;
  bool _isPlayingAudio = false;

  // Lời giải của người chơi
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isAnswerChecked = false;
  bool _isCurrentCorrect = false;

  // Điểm số & tiến độ
  int _score = 0;
  int _streak = 0;
  int _maxStreak = 0;
  int _correctCount = 0;
  int _elapsedSeconds = 0;
  int _lastGainedScore = 0;
  bool _isGameOver = false;

  late final List<bool?> _roundResults;
  final List<Map<String, dynamic>> _detailedResults = [];

  @override
  void initState() {
    super.initState();
    _wordPool = List<WordModel>.from(widget.words)..shuffle(_random);
    _roundResults = List<bool?>.filled(_totalRounds, null);
    _startBeeRound();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    TtsService().stop();
    super.dispose();
  }

  void _startBeeRound() {
    if (_currentIndex >= _totalRounds || _currentIndex >= _wordPool.length) {
      _endGame();
      return;
    }

    _currentWord = _wordPool[_currentIndex];
    _audioReplaysLeft = 3;
    _showMeaningHint = false;
    _showExampleHint = false;
    _showFirstLetterHint = false;
    _isAnswerChecked = false;
    _isCurrentCorrect = false;
    _lastGainedScore = 0;
    _inputController.clear();

    // Tự động phát âm từ mới sau 400ms
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && !_isGameOver) {
        _playAudio();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _playAudio({bool slow = false}) async {
    if (_audioReplaysLeft > 0 || slow) {
      if (mounted) setState(() => _isPlayingAudio = true);

      await TtsService().speakRate(
        _currentWord.term,
        rateMultiplier: slow ? 0.72 : 1.0,
      );

      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
          if (!slow && _audioReplaysLeft > 0) {
            _audioReplaysLeft--;
          }
        });
      }
    } else {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn đã dùng hết 3 lượt nghe lại của từ này! Hãy nghe chậm 0.7x.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _checkSpelling() {
    if (_isAnswerChecked || _isGameOver) return;

    final userInput = _inputController.text.trim().toLowerCase();
    final target = _currentWord.term.trim().toLowerCase();

    if (userInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập từ bạn nghe được trước khi kiểm tra.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final isCorrect = userInput == target;
    setState(() {
      _isAnswerChecked = true;
      _isCurrentCorrect = isCorrect;
      if (_currentIndex < _roundResults.length) {
        _roundResults[_currentIndex] = isCorrect;
      }
    });

    if (isCorrect) {
      HapticFeedback.lightImpact();
      _correctCount++;
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;

      // Điểm: 150 điểm + thưởng streak + thưởng tiết kiệm lượt nghe
      final replayBonus = _audioReplaysLeft * 25;
      final combo = min(_streak, 4);
      final gained = (150 + replayBonus) * combo;
      _lastGainedScore = gained;
      _score += gained;
    } else {
      HapticFeedback.heavyImpact();
      _streak = 0;
      _lastGainedScore = 0;
    }

    _detailedResults.add({
      'word': _currentWord,
      'userInput': _inputController.text.trim(),
      'isCorrect': isCorrect,
    });
  }

  void _nextWord() {
    if (_currentIndex < _totalRounds - 1 && _currentIndex < _wordPool.length - 1) {
      setState(() => _currentIndex++);
      _startBeeRound();
    } else {
      _endGame();
    }
  }

  Future<void> _endGame() async {
    setState(() => _isGameOver = true);

    final total = _detailedResults.length;
    final accuracy = total > 0 ? (_correctCount / total * 100.0) : 0.0;

    final record = GameRecordModel(
      gameType: 'spelling',
      topicId: widget.topicId,
      topicName: widget.topicName,
      level: widget.level,
      score: _score,
      highStreak: _maxStreak,
      totalItems: total,
      correctItems: _correctCount,
      accuracy: accuracy,
      durationSeconds: _elapsedSeconds,
      completedAt: DateTime.now().toIso8601String(),
    );

    if (mounted) {
      await context.read<GamesProvider>().recordGameResult(record);
    }
  }

  void _restartGame() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _streak = 0;
      _maxStreak = 0;
      _correctCount = 0;
      _elapsedSeconds = 0;
      _lastGainedScore = 0;
      _isGameOver = false;
      _roundResults.fillRange(0, _roundResults.length, null);
      _detailedResults.clear();
      _wordPool.shuffle(_random);
    });
    _startBeeRound();
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emoji_nature_rounded, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Cách chơi Ong Chính Tả (Spelling Bee)'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Lắng nghe phát âm từ tiếng Anh từ loa trung tâm.'),
            SizedBox(height: 6),
            Text('• Xem số ô chữ cái tương ứng với độ dài của từ.'),
            SizedBox(height: 6),
            Text('• Gõ chính xác từng chữ cái vào ô nhập liệu.'),
            SizedBox(height: 6),
            Text('• Có 3 lượt nghe lại chuẩn và nút nghe chậm 0.7x không giới hạn.'),
            SizedBox(height: 6),
            Text('• Khi gặp từ khó, mở các gợi ý: Chữ cái đầu, Xem nghĩa, Câu ví dụ.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bắt đầu nghe!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameOver) {
      return _buildResultScreen(context);
    }

    final maskedExample = _currentWord.exampleEn.replaceAll(
      RegExp(_currentWord.term, caseSensitive: false),
      '________',
    );

    final targetTerm = _currentWord.term.trim();
    final userTyped = _inputController.text;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Ong Chính Tả (${_currentIndex + 1}/$_totalRounds)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Hướng dẫn',
            onPressed: _showTutorialDialog,
            icon: const Icon(Icons.info_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thanh điểm số & chuỗi đúng
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: AppColors.accent, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            '$_score',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          if (_lastGainedScore > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+$_lastGainedScore',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                          if (_streak > 1) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '🐝 Chuỗi x$_streak',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        'Đúng: $_correctCount/${_currentIndex + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Thanh tiến trình 10 vòng chơi (Visual Round Tracker)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_totalRounds, (idx) {
                          final result = _roundResults[idx];
                          final isCurrent = idx == _currentIndex;

                          Color bgColor;
                          Widget child;

                          if (result == true) {
                            bgColor = AppColors.accent;
                            child = const Icon(Icons.check, size: 13, color: Colors.white);
                          } else if (result == false) {
                            bgColor = AppColors.danger;
                            child = const Icon(Icons.close, size: 13, color: Colors.white);
                          } else if (isCurrent) {
                            bgColor = AppColors.primary;
                            child = Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          } else {
                            bgColor = context.borderCol;
                            child = Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                color: context.textMutedColor,
                              ),
                            );
                          }

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: isCurrent ? 28 : 22,
                            height: isCurrent ? 28 : 22,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: bgColor,
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: child,
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Thẻ trung tâm phát âm & Tổ ong
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: context.borderCol),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Nút phát âm chính với hiệu ứng sóng âm thanh
                      GestureDetector(
                        onTap: () => _playAudio(slow: false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isPlayingAudio ? 92 : 84,
                          height: _isPlayingAudio ? 92 : 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, Color(0xFFE0A800)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(
                                    alpha: _isPlayingAudio ? 0.6 : 0.35),
                                blurRadius: _isPlayingAudio ? 20 : 14,
                                spreadRadius: _isPlayingAudio ? 4 : 0,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlayingAudio
                                ? Icons.graphic_eq_rounded
                                : Icons.volume_up_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isPlayingAudio ? 'Đang phát âm...' : 'Chạm để nghe phát âm',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: _isPlayingAudio ? AppColors.accent : context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Chỉ số lượt nghe lại
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lượt nghe lại:',
                            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                          ),
                          const SizedBox(width: 6),
                          ...List.generate(3, (i) {
                            final hasReplay = i < _audioReplaysLeft;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Icon(
                                Icons.circle,
                                size: 8,
                                color: hasReplay ? AppColors.accent : context.borderCol,
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Nút nghe chậm
                      OutlinedButton.icon(
                        onPressed: () => _playAudio(slow: true),
                        icon: const Icon(Icons.slow_motion_video_rounded, size: 16),
                        label: const Text('Nghe chậm (0.7x)'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Thông tin bổ trợ (Độ dài từ, Level, Từ loại)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.primaryContainerCol,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Độ dài: ${targetTerm.length} chữ cái',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.borderCol),
                            ),
                            child: Text(
                              'Cấp độ: ${_currentWord.level}',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.borderCol),
                            ),
                            child: Text(
                              _currentWord.partOfSpeech.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Ô chữ cái động tương tác (Interactive Letter Slots)
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: List.generate(targetTerm.length, (i) {
                          String char = '';
                          if (i < userTyped.length) {
                            char = userTyped[i];
                          } else if (i == 0 && _showFirstLetterHint) {
                            char = targetTerm[0];
                          }

                          final isFilled = char.isNotEmpty;

                          return Container(
                            width: 32,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isFilled
                                  ? AppColors.accent.withValues(alpha: 0.12)
                                  : context.scaffoldBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isFilled ? AppColors.accent : context.borderCol,
                                width: isFilled ? 1.8 : 1.2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              char.toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isFilled ? AppColors.accent : context.textMutedColor,
                              ),
                            ),
                          );
                        }),
                      ),

                      // Gợi ý câu ví dụ khuyết từ
                      if (_showExampleHint) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.scaffoldBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.borderCol),
                          ),
                          child: Text(
                            '"$maskedExample"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontStyle: FontStyle.italic,
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ),
                      ],

                      // Gợi ý nghĩa tiếng Việt
                      if (_showMeaningHint) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Nghĩa: ${_currentWord.meaning}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],

                      // Các nút bật gợi ý
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          if (!_showFirstLetterHint)
                            TextButton.icon(
                              onPressed: () {
                                setState(() => _showFirstLetterHint = true);
                              },
                              icon: const Icon(Icons.looks_one_rounded, size: 16),
                              label: const Text('Chữ đầu'),
                            ),
                          if (!_showExampleHint)
                            TextButton.icon(
                              onPressed: () => setState(() => _showExampleHint = true),
                              icon: const Icon(Icons.lightbulb_outline_rounded, size: 16),
                              label: const Text('Câu ví dụ'),
                            ),
                          if (!_showMeaningHint)
                            TextButton.icon(
                              onPressed: () => setState(() => _showMeaningHint = true),
                              icon: const Icon(Icons.translate_rounded, size: 16),
                              label: const Text('Xem nghĩa'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Khung nhập từ chính tả
                TextField(
                  controller: _inputController,
                  focusNode: _focusNode,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _isAnswerChecked ? _nextWord() : _checkSpelling(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: context.textPrimaryColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Gõ từ tiếng Anh...',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                      color: context.textMutedColor,
                    ),
                    filled: true,
                    fillColor: context.cardBg,
                    suffixIcon: _inputController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _inputController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: context.borderCol, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Kết quả sau khi bấm kiểm tra
                if (_isAnswerChecked) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCurrentCorrect
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isCurrentCorrect ? AppColors.success : AppColors.danger,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isCurrentCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: _isCurrentCorrect ? AppColors.success : AppColors.danger,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isCurrentCorrect ? 'CHÍNH XÁC 100%!' : 'CHƯA CHÍNH XÁC',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: _isCurrentCorrect ? AppColors.success : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đáp án chuẩn: ${_currentWord.term} (${_currentWord.ipa})',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Text(
                          _currentWord.meaning,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        if (!_isCurrentCorrect) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Bạn đã gõ: "${_inputController.text.trim()}"',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.danger,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Nút hành động (Kiểm tra / Câu tiếp theo)
                CustomButton(
                  text: _isAnswerChecked
                      ? (_currentIndex < _totalRounds - 1
                          ? 'Từ tiếp theo'
                          : 'Xem kết quả tổng kết')
                      : 'Kiểm tra chính tả',
                  icon: _isAnswerChecked
                      ? Icons.arrow_forward_rounded
                      : Icons.spellcheck_rounded,
                  onPressed: _isAnswerChecked ? _nextWord : _checkSpelling,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context) {
    final gamesProvider = context.watch<GamesProvider>();
    final isNewRecord = _score > gamesProvider.spellingHighScore;
    final total = _detailedResults.length;
    final accuracy = total > 0 ? ((_correctCount / total) * 100).round() : 0;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Tổng kết Ong Chính Tả'),
        backgroundColor: context.surfaceBg,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_nature_rounded,
                          size: 44,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isNewRecord ? '🎉 KỶ LỤC MỚI CỦA BẠN!' : 'Hoàn thành lượt thi!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isNewRecord ? AppColors.accent : context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_score điểm',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('Số từ đúng', '$_correctCount/$_totalRounds'),
                          _buildStatColumn('Độ chính xác', '$accuracy%'),
                          _buildStatColumn('Chuỗi cao nhất', '$_maxStreak🐝'),
                          _buildStatColumn('Thời gian', '${_elapsedSeconds}s'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Chi tiết các từ đã thi
                if (_detailedResults.isNotEmpty) ...[
                  Text(
                    'Chi tiết kết quả các từ (${_detailedResults.length} từ):',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._detailedResults.map((res) {
                    final WordModel word = res['word'] as WordModel;
                    final bool ok = res['isCorrect'] as bool;
                    final String userTyped = res['userInput'] as String;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ok
                              ? AppColors.success.withValues(alpha: 0.4)
                              : AppColors.danger.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: ok ? AppColors.success : AppColors.danger,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      word.term,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: context.textPrimaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      word.ipa,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: context.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  word.meaning,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.textSecondaryColor,
                                  ),
                                ),
                                if (!ok) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Đã gõ: "$userTyped"',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, color: AppColors.accent),
                            onPressed: () => TtsService().speak(word.term),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Chơi lại',
                        icon: Icons.replay_rounded,
                        onPressed: _restartGame,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Về danh sách Game',
                        isOutlined: true,
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11.5, color: context.textSecondaryColor),
        ),
      ],
    );
  }
}