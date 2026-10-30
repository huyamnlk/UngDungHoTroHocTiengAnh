import 'dart:async';
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
import 'common/game_difficulty.dart';

class VocabularyArenaScreen extends StatefulWidget {
  final List<WordModel> words;
  final String topicName;
  final int? topicId;
  final String level;

  const VocabularyArenaScreen({
    super.key,
    required this.words,
    this.topicName = 'Tất cả chủ đề',
    this.topicId,
    this.level = 'All',
  });

  @override
  State<VocabularyArenaScreen> createState() => _VocabularyArenaScreenState();
}

class _VocabularyArenaScreenState extends State<VocabularyArenaScreen>
    with SingleTickerProviderStateMixin {
  late List<WordModel> _gamePool;
  final Random _random = Random();

  // Trạng thái màn chơi & Cấp độ khó
  GameDifficulty _difficulty = GameDifficulty.medium;
  bool _isStarted = false;

  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _maxStreak = 0;
  int _lives = 3;
  int _correctCount = 0;
  final int _totalQuestions = 15;
  int _elapsedSeconds = 0;
  int _lastGainedScore = 0;

  // Lịch sử kết quả từng câu: true = đúng, false = sai, null = chưa đến
  late final List<bool?> _questionResults;

  // Câu hỏi hiện tại
  late WordModel _currentWord;
  late List<String> _currentOptions;
  late int _correctOptionIndex;
  late String _questionType; // 'en_to_vi', 'vi_to_en', 'def_to_en'

  // Thời gian phản xạ động theo độ khó: Dễ 15s, Vừa 10s, Khó 7s
  int get _turnTimeLimit {
    switch (_difficulty) {
      case GameDifficulty.easy:
        return 15;
      case GameDifficulty.medium:
        return 10;
      case GameDifficulty.hard:
        return 7;
    }
  }

  int _remainingSeconds = 10;
  Timer? _turnTimer;
  Timer? _gameDurationTimer;
  Timer? _advanceTimer;

  // Lựa chọn của người chơi
  int? _selectedOption;
  bool _isAnswerChecked = false;
  bool? _isLastAnswerCorrect;
  bool _isGameOver = false;
  bool _isPaused = false;

  // Danh sách các từ làm sai để xem lại
  final List<WordModel> _missedWords = [];

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _gamePool = [];
    _questionResults = List<bool?>.filled(_totalQuestions, null);
  }

  void _startMatch() {
    // Lọc từ vựng theo độ khó thực tế
    final filtered = GameDifficulty.filterWords(
      words: widget.words,
      difficulty: _difficulty,
    );
    _gamePool = List<WordModel>.from(filtered)..shuffle(_random);
    _currentIndex = 0;
    _score = 0;
    _streak = 0;
    _maxStreak = 0;
    _lives = 3;
    _correctCount = 0;
    _elapsedSeconds = 0;
    _lastGainedScore = 0;
    _isGameOver = false;
    _isPaused = false;
    _isAnswerChecked = false;
    _isLastAnswerCorrect = null;
    _selectedOption = null;
    _questionResults.fillRange(0, _questionResults.length, null);
    _missedWords.clear();

    setState(() {
      _isStarted = true;
      _remainingSeconds = _turnTimeLimit;
    });

    _startOverallTimer();
    _loadNextQuestion();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _turnTimer?.cancel();
    _gameDurationTimer?.cancel();
    _focusNode.dispose();
    TtsService().stop();
    super.dispose();
  }

  void _startOverallTimer() {
    _gameDurationTimer?.cancel();
    _gameDurationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isPaused || _isGameOver) return;
      setState(() => _elapsedSeconds++);
    });
  }

  void _startTurnTimer() {
    _turnTimer?.cancel();
    _remainingSeconds = _turnTimeLimit;
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isPaused || _isGameOver) return;
      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _onTimeOut();
      }
    });
  }

  void _loadNextQuestion() {
    if (_currentIndex >= _totalQuestions ||
        _currentIndex >= _gamePool.length ||
        _lives <= 0) {
      _endGame();
      return;
    }

    _isAnswerChecked = false;
    _isLastAnswerCorrect = null;
    _selectedOption = null;
    _lastGainedScore = 0;
    _currentWord = _gamePool[_currentIndex];

    // Quyết định dạng câu hỏi
    final typeRoll = _random.nextInt(3);
    if (typeRoll == 0) {
      _questionType = 'en_to_vi';
    } else if (typeRoll == 1) {
      _questionType = 'vi_to_en';
    } else {
      _questionType = _currentWord.englishDefinition.isNotEmpty
          ? 'def_to_en'
          : 'en_to_vi';
    }

    // Tạo các phương án gây nhiễu từ kho từ vựng
    final distractors = <String>{};
    final otherWords = widget.words.where((w) => w.id != _currentWord.id).toList()
      ..shuffle(_random);

    for (final other in otherWords) {
      if (distractors.length >= 3) break;
      final val = _questionType == 'en_to_vi' ? other.meaning : other.term;
      if (val.trim().isNotEmpty &&
          val.trim() !=
              (_questionType == 'en_to_vi'
                  ? _currentWord.meaning
                  : _currentWord.term)) {
        distractors.add(val);
      }
    }

    // Dự phòng nếu kho từ quá nhỏ
    while (distractors.length < 3) {
      distractors.add('Từ vựng ngẫu nhiên ${distractors.length + 1}');
    }

    final correctAns = _questionType == 'en_to_vi'
        ? _currentWord.meaning
        : _currentWord.term;
    final optionsList = [correctAns, ...distractors]..shuffle(_random);

    setState(() {
      _currentOptions = optionsList;
      _correctOptionIndex = optionsList.indexOf(correctAns);
    });

    _startTurnTimer();
    _focusNode.requestFocus();
  }

  void _selectAnswer(int optionIndex) {
    if (_isAnswerChecked || _isGameOver || _isPaused) return;

    _turnTimer?.cancel();
    final isCorrect = optionIndex == _correctOptionIndex;

    setState(() {
      _selectedOption = optionIndex;
      _isAnswerChecked = true;
      _isLastAnswerCorrect = isCorrect;
      if (_currentIndex < _questionResults.length) {
        _questionResults[_currentIndex] = isCorrect;
      }
    });

    if (isCorrect) {
      HapticFeedback.lightImpact();
      _correctCount++;
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;

      // Tính điểm: 100 điểm cơ bản + điểm tốc độ + thưởng combo streak
      final speedBonus = (_remainingSeconds * 12);
      final comboMultiplier = min(_streak, 5);
      final gained = (100 + speedBonus) * comboMultiplier;
      _lastGainedScore = gained;
      _score += gained;
    } else {
      HapticFeedback.heavyImpact();
      _streak = 0;
      _lives--;
      _lastGainedScore = 0;
      if (!_missedWords.any((w) => w.id == _currentWord.id)) {
        _missedWords.add(_currentWord);
      }
    }

    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 1500), () {
      _advanceToNext();
    });
  }

  void _onTimeOut() {
    if (_isAnswerChecked || _isGameOver || _isPaused) return;

    HapticFeedback.vibrate();
    setState(() {
      _isAnswerChecked = true;
      _isLastAnswerCorrect = false;
      _selectedOption = -1; // Hết giờ không chọn
      _streak = 0;
      _lives--;
      _lastGainedScore = 0;
      if (_currentIndex < _questionResults.length) {
        _questionResults[_currentIndex] = false;
      }
      if (!_missedWords.any((w) => w.id == _currentWord.id)) {
        _missedWords.add(_currentWord);
      }
    });

    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 1600), () {
      _advanceToNext();
    });
  }

  void _advanceToNext() {
    if (!mounted) return;
    _advanceTimer?.cancel();
    if (_lives <= 0 || _currentIndex >= _totalQuestions - 1) {
      _endGame();
    } else {
      setState(() => _currentIndex++);
      _loadNextQuestion();
    }
  }

  Future<void> _endGame() async {
    _advanceTimer?.cancel();
    _turnTimer?.cancel();
    _gameDurationTimer?.cancel();
    setState(() => _isGameOver = true);

    final totalAttempted = _currentIndex + 1;
    final accuracy = totalAttempted > 0
        ? (_correctCount / totalAttempted) * 100.0
        : 0.0;

    final record = GameRecordModel(
      gameType: 'arena',
      topicId: widget.topicId,
      topicName: widget.topicName,
      level: '${widget.level} (${_difficulty.label})',
      score: _score,
      highStreak: _maxStreak,
      totalItems: totalAttempted,
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
    _startMatch();
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.sports_kabaddi_rounded, color: AppColors.primary, size: 26),
            SizedBox(width: 10),
            Text('Cách chơi Đấu trường Từ vựng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Mỗi câu hỏi có thời gian phản xạ đếm ngược (7s–15s tùy độ khó).'),
            SizedBox(height: 8),
            Text('• Trả lời đúng liên tiếp kích hoạt Combo 🔥 x2, x3... x5 nhân vọt điểm số!'),
            SizedBox(height: 8),
            Text('• Trả lời sai hoặc hết giờ bị trừ 1 tim (❤️). Có tối đa 3 tim.'),
            SizedBox(height: 8),
            Text('• Thao tác nhanh: bấm phím số 1, 2, 3, 4 trên bàn phím máy tính.'),
            SizedBox(height: 8),
            Text('• Bảng giải thích chi tiết (IPA, ví dụ, âm thanh) xuất hiện ngay sau khi chọn.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đã hiểu!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isStarted) {
      return _buildStartScreen(context);
    }

    if (_isGameOver) {
      return _buildResultScreen(context);
    }

    final isLowTime = _remainingSeconds <= 3;
    final timerFraction = (_remainingSeconds / _turnTimeLimit).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Đấu trường từ vựng (${_currentIndex + 1}/$_totalQuestions)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _difficulty.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _difficulty.color),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_difficulty.icon, color: _difficulty.color, size: 14),
                const SizedBox(width: 5),
                Text(
                  '${_difficulty.label} (${_turnTimeLimit}s)',
                  style: TextStyle(
                    color: _difficulty.color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Hướng dẫn chơi',
            onPressed: _showTutorialDialog,
            icon: const Icon(Icons.info_outline_rounded),
          ),
          IconButton(
            tooltip: _isPaused ? 'Tiếp tục' : 'Tạm dừng',
            onPressed: _togglePause,
            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent && !_isAnswerChecked && !_isPaused) {
            if (event.logicalKey == LogicalKeyboardKey.digit1 ||
                event.logicalKey == LogicalKeyboardKey.numpad1) {
              if (_currentOptions.isNotEmpty) _selectAnswer(0);
            } else if (event.logicalKey == LogicalKeyboardKey.digit2 ||
                event.logicalKey == LogicalKeyboardKey.numpad2) {
              if (_currentOptions.length > 1) _selectAnswer(1);
            } else if (event.logicalKey == LogicalKeyboardKey.digit3 ||
                event.logicalKey == LogicalKeyboardKey.numpad3) {
              if (_currentOptions.length > 2) _selectAnswer(2);
            } else if (event.logicalKey == LogicalKeyboardKey.digit4 ||
                event.logicalKey == LogicalKeyboardKey.numpad4) {
              if (_currentOptions.length > 3) _selectAnswer(3);
            }
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                // Thanh đếm ngược thời gian với màu chuyển động
                LinearProgressIndicator(
                  value: timerFraction,
                  minHeight: 6,
                  backgroundColor: context.borderCol,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLowTime
                        ? AppColors.danger
                        : (_remainingSeconds <= (_turnTimeLimit / 2)
                            ? AppColors.warning
                            : AppColors.primary),
                  ),
                ),

                // Bảng trạng thái HUD: Điểm, Combo, Thời gian, Mạng
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    border: Border(bottom: BorderSide(color: context.borderCol)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Điểm số & Điểm cộng tức thì
                      Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: AppColors.accent, size: 24),
                          const SizedBox(width: 6),
                          Text(
                            '$_score',
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                          ),
                          if (_lastGainedScore > 0) ...[
                            const SizedBox(width: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.success),
                              ),
                              child: Text(
                                '+$_lastGainedScore',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                          if (_streak > 1) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF5722).withValues(alpha: 0.2),
                                    const Color(0xFFFF9800).withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFF7043), width: 1.2),
                              ),
                              child: Text(
                                '🔥 Combo x$_streak',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFF7043),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Đồng hồ đếm ngược số to rõ
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLowTime
                              ? AppColors.danger.withValues(alpha: 0.16)
                              : context.scaffoldBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isLowTime ? AppColors.danger : context.borderCol,
                            width: isLowTime ? 1.8 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              size: 16,
                              color: isLowTime ? AppColors.danger : context.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_remainingSeconds s',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: isLowTime ? AppColors.danger : context.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Trái tim sinh mệnh
                      Row(
                        children: List.generate(3, (i) {
                          final isAlive = i < _lives;
                          return Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Icon(
                              isAlive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 22,
                              color: isAlive ? AppColors.danger : context.textMutedColor,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // Thanh tiến độ 15 câu hỏi (Visual Question Track)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.scaffoldBg,
                    border: Border(bottom: BorderSide(color: context.borderCol)),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_totalQuestions, (idx) {
                          final result = _questionResults[idx];
                          final isCurrent = idx == _currentIndex;

                          Color bgColor;
                          Widget child;

                          if (result == true) {
                            bgColor = AppColors.success;
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
                            width: isCurrent ? 26 : 22,
                            height: isCurrent ? 26 : 22,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
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

                // Nội dung câu hỏi và 4 lựa chọn
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Banner phản hồi trực quan khi trả lời đúng / sai
                            if (_isAnswerChecked)
                              AnimatedOpacity(
                                opacity: 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _isLastAnswerCorrect == true
                                        ? AppColors.success.withValues(alpha: 0.16)
                                        : AppColors.danger.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _isLastAnswerCorrect == true
                                          ? AppColors.success
                                          : AppColors.danger,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isLastAnswerCorrect == true
                                            ? Icons.check_circle_rounded
                                            : Icons.cancel_rounded,
                                        color: _isLastAnswerCorrect == true
                                            ? AppColors.success
                                            : AppColors.danger,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isLastAnswerCorrect == true
                                            ? 'CHÍNH XÁC! +$_lastGainedScore ĐIỂM'
                                            : (_selectedOption == -1
                                                ? 'HẾT GIỜ! HÃY GHI NHỚ ĐÁP ÁN ĐÚNG'
                                                : 'CHƯA ĐÚNG! HÃY XEM ĐÁP ÁN MÀU XANH'),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: _isLastAnswerCorrect == true
                                              ? AppColors.success
                                              : AppColors.danger,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Thẻ câu hỏi
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: context.cardBg,
                                borderRadius: BorderRadius.circular(22),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: context.primaryContainerCol,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _currentWord.level,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: context.cardBg,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: context.borderCol),
                                        ),
                                        child: Text(
                                          _currentWord.partOfSpeech.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: context.textSecondaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _questionPromptLabel(),
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: context.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Chữ câu hỏi
                                  Text(
                                    _questionPromptContent(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),

                                  if (_currentWord.ipa.isNotEmpty && _questionType == 'en_to_vi') ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _currentWord.ipa,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: context.textSecondaryColor,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        IconButton(
                                          iconSize: 20,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                                          onPressed: () => TtsService().speak(_currentWord.term),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Danh sách 4 lựa chọn có keycap phím tắt [1], [2], [3], [4]
                            ..._currentOptions.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final optionText = entry.value;

                              Color tileBg = context.cardBg;
                              Color borderCol = context.borderCol;
                              Color textCol = context.textPrimaryColor;
                              Color keyCapBg = context.scaffoldBg;
                              Color keyCapText = context.textSecondaryColor;

                              if (_isAnswerChecked) {
                                if (idx == _correctOptionIndex) {
                                  tileBg = AppColors.success.withValues(alpha: 0.16);
                                  borderCol = AppColors.success;
                                  textCol = AppColors.success;
                                  keyCapBg = AppColors.success;
                                  keyCapText = Colors.white;
                                } else if (idx == _selectedOption) {
                                  tileBg = AppColors.danger.withValues(alpha: 0.16);
                                  borderCol = AppColors.danger;
                                  textCol = AppColors.danger;
                                  keyCapBg = AppColors.danger;
                                  keyCapText = Colors.white;
                                }
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _selectAnswer(idx),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: tileBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: borderCol,
                                        width: (_isAnswerChecked && (idx == _correctOptionIndex || idx == _selectedOption))
                                            ? 2.2
                                            : 1.5,
                                      ),
                                      boxShadow: _isAnswerChecked && idx == _correctOptionIndex
                                          ? [
                                              BoxShadow(
                                                color: AppColors.success.withValues(alpha: 0.25),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        // Phím tắt Keycap [1], [2], [3], [4]
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: keyCapBg,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: borderCol),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${idx + 1}',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                              color: keyCapText,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            optionText,
                                            style: TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w700,
                                              color: textCol,
                                            ),
                                          ),
                                        ),
                                        if (_isAnswerChecked && idx == _correctOptionIndex)
                                          const Icon(Icons.check_circle_rounded,
                                              color: AppColors.success, size: 24),
                                        if (_isAnswerChecked &&
                                            idx == _selectedOption &&
                                            idx != _correctOptionIndex)
                                          const Icon(Icons.cancel_rounded,
                                              color: AppColors.danger, size: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),

                            // Thẻ giải thích chi tiết xuất hiện sau khi trả lời
                            if (_isAnswerChecked) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: (_selectedOption == _correctOptionIndex)
                                      ? AppColors.success.withValues(alpha: 0.10)
                                      : AppColors.warning.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: (_selectedOption == _correctOptionIndex)
                                        ? AppColors.success.withValues(alpha: 0.3)
                                        : AppColors.warning.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          (_selectedOption == _correctOptionIndex)
                                              ? Icons.lightbulb_rounded
                                              : Icons.info_outline_rounded,
                                          size: 18,
                                          color: (_selectedOption == _correctOptionIndex)
                                              ? AppColors.success
                                              : AppColors.warning,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          (_selectedOption == _correctOptionIndex)
                                              ? 'Chính xác! Ghi nhớ từ vựng:'
                                              : 'Đáp án chuẩn cần nhớ:',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: (_selectedOption == _correctOptionIndex)
                                                ? AppColors.success
                                                : AppColors.warning,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          iconSize: 18,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                                          onPressed: () => TtsService().speak(_currentWord.term),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${_currentWord.term} ${_currentWord.ipa} [${_currentWord.partOfSpeech}]: ${_currentWord.meaning}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: context.textPrimaryColor,
                                      ),
                                    ),
                                    if (_currentWord.exampleEn.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ví dụ: "${_currentWord.exampleEn}"',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontStyle: FontStyle.italic,
                                          color: context.textSecondaryColor,
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
                  ),
                ),
              ],
            ),

            // Lớp phủ tạm dừng
            if (_isPaused)
              Container(
                color: Colors.black.withValues(alpha: 0.65),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pause_circle_rounded, size: 54, color: AppColors.primary),
                        const SizedBox(height: 12),
                        const Text(
                          'Trò chơi đang tạm dừng',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _togglePause,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Tiếp tục chơi'),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Thoát về danh sách game'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _questionPromptLabel() {
    switch (_questionType) {
      case 'en_to_vi':
        return 'Chọn nghĩa tiếng Việt:';
      case 'vi_to_en':
        return 'Chọn từ tiếng Anh:';
      case 'def_to_en':
        return 'Định nghĩa của từ:';
      default:
        return 'Chọn đáp án chính xác:';
    }
  }

  String _questionPromptContent() {
    switch (_questionType) {
      case 'en_to_vi':
        return _currentWord.term;
      case 'vi_to_en':
        return _currentWord.meaning;
      case 'def_to_en':
        return _currentWord.englishDefinition;
      default:
        return _currentWord.term;
    }
  }

  Widget _buildResultScreen(BuildContext context) {
    final gamesProvider = context.watch<GamesProvider>();
    final isNewRecord = _score > gamesProvider.arenaHighScore;
    final accuracy = _currentIndex > 0
        ? ((_correctCount / (_currentIndex + 1)) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Tổng kết Đấu trường'),
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
                // Thẻ điểm
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: context.borderCol),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                          Icons.emoji_events_rounded,
                          size: 44,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isNewRecord ? '🎉 KỶ LỤC MỚI CỦA BẠN!' : 'Hoàn thành lượt đấu!',
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
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('Cấp độ', _difficulty.label),
                          _buildStatColumn('Số câu đúng', '$_correctCount/${_currentIndex + 1}'),
                          _buildStatColumn('Độ chính xác', '$accuracy%'),
                          _buildStatColumn('Combo cao nhất', '$_maxStreak🔥'),
                          _buildStatColumn('Thời gian', '${_elapsedSeconds}s'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Xem lại từ cần lưu ý
                if (_missedWords.isNotEmpty) ...[
                  Text(
                    'Các từ vựng bạn cần ôn lại (${_missedWords.length} từ):',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._missedWords.map((word) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.borderCol),
                        ),
                        child: Row(
                          children: [
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
                                  const SizedBox(height: 4),
                                  Text(
                                    word.meaning,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                              onPressed: () => TtsService().speak(word.term),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 20),
                ],

                // Nút điều hướng
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Về Games Hub'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _restartGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Đấu lại ngay'),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  /// Màn hình chọn cấp độ khó và giới thiệu trước khi vào trận
  Widget _buildStartScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Đấu Trường Từ Vựng'),
        backgroundColor: context.surfaceBg,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.borderCol),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_kabaddi_rounded,
                      color: AppColors.primary,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'ĐẤU TRƯỜNG TỪ VỰNG',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: context.textPrimaryColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Thử thách trắc nghiệm phản xạ 15 câu tốc độ cao',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Khung tóm tắt luật chơi
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.scaffoldBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Column(
                      children: [
                        _buildRuleRow(Icons.timer_outlined, 'Thời gian đếm ngược theo câu tùy cấp độ (7s - 15s).'),
                        const SizedBox(height: 8),
                        _buildRuleRow(Icons.local_fire_department_outlined, 'Trả lời đúng liên tiếp nhân đôi, nhân ba điểm số.'),
                        const SizedBox(height: 8),
                        _buildRuleRow(Icons.favorite_rounded, 'Có 3 lượt tim (❤️). Sai hoặc hết giờ bị trừ 1 tim.'),
                        const SizedBox(height: 8),
                        _buildRuleRow(Icons.keyboard_rounded, 'Thao tác cực nhanh bằng phím số 1, 2, 3, 4 trên máy tính.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Lựa chọn độ khó
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'CHỌN CẤP ĐỘ KHÓ:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: context.textSecondaryColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...GameDifficulty.values.map((diff) {
                    final isSel = _difficulty == diff;
                    final timeText = diff == GameDifficulty.easy
                        ? '15s/câu'
                        : (diff == GameDifficulty.medium ? '10s/câu' : '7s/câu');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => _difficulty = diff),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSel
                                ? diff.color.withValues(alpha: 0.12)
                                : context.scaffoldBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel ? diff.color : context.borderCol,
                              width: isSel ? 2.0 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: diff.color.withValues(alpha: 0.16),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(diff.icon, color: diff.color, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        Text(
                                          diff.label,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isSel ? diff.color : context.textPrimaryColor,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: diff.color.withValues(alpha: 0.16),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            timeText,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: diff.color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      diff.subLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSel)
                                Icon(Icons.check_circle_rounded, color: diff.color, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  CustomButton(
                    text: 'VÀO ĐẤU TRƯỜNG (${_difficulty.label.toUpperCase()})',
                    icon: Icons.play_arrow_rounded,
                    onPressed: _startMatch,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuleRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, height: 1.3),
          ),
        ),
      ],
    );
  }
}
