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


class DropletItem {
  final WordModel word;
  final bool isTarget;
  double y; // 0.0 to 1.0
  final double x; // 0.05 to 0.75
  final double speed;
  bool isPopped;

  DropletItem({
    required this.word,
    required this.isTarget,
    this.y = 0.0,
    required this.x,
    required this.speed,
    this.isPopped = false,
  });
}

class SplashParticle {
  final Offset position;
  final Color color;
  final double maxRadius;
  double progress; // 0.0 to 1.0
  final String? scoreText;

  SplashParticle({
    required this.position,
    required this.color,
    required this.maxRadius,
    this.progress = 0.0,
    this.scoreText,
  });
}

class WordRainScreen extends StatefulWidget {
  final List<WordModel> words;
  final String topicName;
  final int? topicId;
  final String level;

  const WordRainScreen({
    super.key,
    required this.words,
    this.topicName = 'Tất cả chủ đề',
    this.topicId,
    this.level = 'All',
  });

  @override
  State<WordRainScreen> createState() => _WordRainScreenState();
}

class _WordRainScreenState extends State<WordRainScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late List<WordModel> _wordPool;

  // Mục tiêu hiện tại
  late WordModel _currentTargetWord;
  final Set<int> _recentlyUsedTargetIds = {};

  // Cấp độ khó: Dễ / Trung bình / Khó
  GameDifficulty _difficulty = GameDifficulty.medium;
  bool _isStarted = false;

  double get _baseSpeed => switch (_difficulty) {
    GameDifficulty.easy => 0.0014,
    GameDifficulty.medium => 0.0024,
    GameDifficulty.hard => 0.0038,
  };

  int get _spawnMs => switch (_difficulty) {
    GameDifficulty.easy => 2600,
    GameDifficulty.medium => 1800,
    GameDifficulty.hard => 1300,
  };

  // Các giọt mưa đang rơi
  final List<DropletItem> _activeDroplets = [];
  final List<SplashParticle> _splashParticles = [];

  Timer? _physicsTimer;
  Timer? _spawnTimer;
  Timer? _elapsedTimer;

  // Điểm số và trạng thái
  int _score = 0;
  int _streak = 0;
  int _maxStreak = 0;
  int _lives = 3;
  int _correctHits = 0;
  int _elapsedSeconds = 0;
  int _lastGainedScore = 0;

  bool _isGameOver = false;
  bool _isPaused = false;
  double _currentSpeedMultiplier = 1.0;

  final List<WordModel> _missedWords = [];
  final FocusNode _keyboardFocusNode = FocusNode();

  // Đồ họa mưa trang trí từ tham khảo Python (test (1).py)
  late final AnimationController _ambientRainController;
  final List<_AmbientRainDrop> _ambientRainDrops = [];

  @override
  void initState() {
    super.initState();
    _wordPool = [];
    _ambientRainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  void _syncAmbientRainDrops(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final targetCount = (size.width / 4.0).clamp(90, 160).toInt();
    if (_ambientRainDrops.isEmpty) {
      for (int i = 0; i < targetCount; i++) {
        _ambientRainDrops.add(_AmbientRainDrop.random(size, random: _random));
      }
    } else if (_ambientRainDrops.length < targetCount) {
      final diff = targetCount - _ambientRainDrops.length;
      for (int i = 0; i < diff; i++) {
        _ambientRainDrops.add(_AmbientRainDrop.random(size, yStart: -20, random: _random));
      }
    }
  }

  void _startRainSession() {
    final filtered = GameDifficulty.filterWords(
      words: widget.words,
      difficulty: _difficulty,
    );
    _wordPool = List<WordModel>.from(filtered)..shuffle(_random);
    setState(() => _isStarted = true);
    _startRainGame();
  }

  @override
  void dispose() {
    _physicsTimer?.cancel();
    _spawnTimer?.cancel();
    _elapsedTimer?.cancel();
    _ambientRainController.dispose();
    _keyboardFocusNode.dispose();
    TtsService().stop();
    super.dispose();
  }

  void _startRainGame() {
    if (!_ambientRainController.isAnimating) {
      _ambientRainController.repeat();
    }
    _activeDroplets.clear();
    _splashParticles.clear();
    _score = 0;
    _streak = 0;
    _maxStreak = 0;
    _lives = 3;
    _correctHits = 0;
    _elapsedSeconds = 0;
    _lastGainedScore = 0;
    _currentSpeedMultiplier = 1.0;
    _isGameOver = false;
    _isPaused = false;
    _missedWords.clear();
    _recentlyUsedTargetIds.clear();
    _wordPool.shuffle(_random);

    _pickNextTarget();

    _physicsTimer?.cancel();
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 32), (_) {
      if (!mounted || _isPaused || _isGameOver) return;
      _updateDropletPhysics();
    });

    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(Duration(milliseconds: _spawnMs), (_) {
      if (!mounted || _isPaused || _isGameOver) return;
      _spawnDropletWave();
    });

    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isPaused || _isGameOver) return;
      setState(() => _elapsedSeconds++);
    });

    _keyboardFocusNode.requestFocus();
  }

  void _pickNextTarget() {
    if (_wordPool.isEmpty) return;

    final available =
        _wordPool.where((w) => !_recentlyUsedTargetIds.contains(w.id)).toList();
    if (available.isNotEmpty) {
      _currentTargetWord = available[_random.nextInt(available.length)];
    } else {
      _recentlyUsedTargetIds.clear();
      _currentTargetWord = _wordPool[_random.nextInt(_wordPool.length)];
    }

    _recentlyUsedTargetIds.add(_currentTargetWord.id);
    if (_recentlyUsedTargetIds.length > 15) {
      _recentlyUsedTargetIds.remove(_recentlyUsedTargetIds.first);
    }

    // Đảm bảo tạo ngay 1 giọt mưa target rơi
    _activeDroplets.removeWhere((d) => d.isTarget);
    _spawnSingleDroplet(_currentTargetWord, isTarget: true, initialY: 0.02);
    _spawnDistractorDroplets();
  }

  void _spawnDropletWave() {
    if (_activeDroplets.where((d) => !d.isPopped).length >= 5) return;

    final hasTarget = _activeDroplets.any((d) => d.isTarget && !d.isPopped);
    if (!hasTarget) {
      _spawnSingleDroplet(_currentTargetWord, isTarget: true);
    } else {
      _spawnDistractorDroplets();
    }
  }

  void _spawnDistractorDroplets() {
    final distractors = _wordPool
        .where((w) => w.id != _currentTargetWord.id)
        .toList()
      ..shuffle(_random);
    if (distractors.isNotEmpty) {
      _spawnSingleDroplet(distractors.first, isTarget: false);
    }
  }

  void _spawnSingleDroplet(WordModel word,
      {required bool isTarget, double initialY = 0.0}) {
    final posX = 0.06 + (_random.nextDouble() * 0.64);
    final effectiveBase = _baseSpeed * _currentSpeedMultiplier;
    final speed = effectiveBase + (_random.nextDouble() * 0.0006);

    setState(() {
      _activeDroplets.add(DropletItem(
        word: word,
        isTarget: isTarget,
        y: initialY,
        x: posX,
        speed: speed,
      ));
    });
  }

  void _updateDropletPhysics() {
    bool hasChanges = false;

    // Cập nhật các hạt gợn sóng nước (splashes)
    for (int i = _splashParticles.length - 1; i >= 0; i--) {
      final p = _splashParticles[i];
      p.progress += 0.05;
      if (p.progress >= 1.0) {
        _splashParticles.removeAt(i);
      }
      hasChanges = true;
    }

    // Cập nhật tọa độ rơi của giọt mưa
    for (final drop in _activeDroplets) {
      if (drop.isPopped) continue;
      drop.y += drop.speed;

      // Giọt mưa rơi xuống hồ nước ở đáy (y >= 0.86)
      if (drop.y >= 0.86) {
        drop.isPopped = true;
        hasChanges = true;

        if (drop.isTarget) {
          // Bỏ lỡ giọt mục tiêu!
          HapticFeedback.heavyImpact();
          _lives--;
          _streak = 0;
          _lastGainedScore = 0;
          if (!_missedWords.any((w) => w.id == drop.word.id)) {
            _missedWords.add(drop.word);
          }

          if (_lives <= 0) {
            _endGame();
            return;
          } else {
            _pickNextTarget();
          }
        }
      }
    }

    _activeDroplets.removeWhere((d) => d.isPopped);
    if (hasChanges || _activeDroplets.isNotEmpty) {
      setState(() {});
    }
  }

  void _onDropletTapped(DropletItem drop, Offset renderBoxPos) {
    if (_isGameOver || _isPaused || drop.isPopped) return;

    if (drop.isTarget) {
      // Chạm chính xác giọt mưa mục tiêu!
      HapticFeedback.lightImpact();
      drop.isPopped = true;
      _correctHits++;
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;

      // Điểm: Bắt càng sớm khi còn ở trên cao càng nhiều điểm
      final altitudeBonus = ((1.0 - drop.y) * 120).round();
      final combo = min(_streak, 5);
      final gained = (120 + altitudeBonus) * combo;
      _lastGainedScore = gained;
      _score += gained;

      _currentSpeedMultiplier =
          (_currentSpeedMultiplier + 0.02).clamp(1.0, 1.6);

      // Thêm hiệu ứng sóng nước bọt sóng bung nở
      _splashParticles.add(SplashParticle(
        position: renderBoxPos,
        color: const Color(0xFF38BDF8),
        maxRadius: 46,
        scoreText: '+$gained',
      ));

      // Phát âm từ vừa bắt trúng
      TtsService().speak(drop.word.term);

      // Chuyển ngay sang mục tiêu tiếp theo
      _pickNextTarget();
    } else {
      // Chạm nhầm giọt không đúng nghĩa
      HapticFeedback.heavyImpact();
      drop.isPopped = true;
      _lives--;
      _streak = 0;
      _lastGainedScore = 0;

      _splashParticles.add(SplashParticle(
        position: renderBoxPos,
        color: AppColors.danger,
        maxRadius: 36,
        scoreText: '-1 ❤️',
      ));

      if (!_missedWords.any((w) => w.id == _currentTargetWord.id)) {
        _missedWords.add(_currentTargetWord);
      }

      if (_lives <= 0) {
        _endGame();
      } else {
        setState(() {});
      }
    }
  }

  void _handleKeyInput(String inputKey) {
    final lowerKey = inputKey.toLowerCase().trim();
    if (lowerKey.isEmpty) return;

    // Tìm giọt mục tiêu trước
    final targetDrop = _activeDroplets.where((d) => d.isTarget && !d.isPopped).firstOrNull;
    if (targetDrop != null) {
      final targetTerm = targetDrop.word.term.toLowerCase().trim();
      if (targetTerm.startsWith(lowerKey) || targetTerm == lowerKey) {
        _onDropletTapped(targetDrop, const Offset(200, 300));
        return;
      }
    }

    // Hoặc kiểm tra các giọt khác
    for (final drop in _activeDroplets.where((d) => !d.isPopped)) {
      final term = drop.word.term.toLowerCase().trim();
      if (term.startsWith(lowerKey) || term == lowerKey) {
        _onDropletTapped(drop, const Offset(200, 300));
        return;
      }
    }
  }

  Future<void> _endGame() async {
    _physicsTimer?.cancel();
    _spawnTimer?.cancel();
    _elapsedTimer?.cancel();
    _ambientRainController.stop();
    setState(() => _isGameOver = true);

    final totalAttempted = _correctHits + _missedWords.length;
    final accuracy = totalAttempted > 0
        ? (_correctHits / totalAttempted * 100.0).clamp(0.0, 100.0)
        : 0.0;

    final record = GameRecordModel(
      gameType: 'rain',
      topicId: widget.topicId,
      topicName: widget.topicName,
      level: '${widget.level} (${_difficulty.label})',
      score: _score,
      highStreak: _maxStreak,
      totalItems: totalAttempted,
      correctItems: _correctHits,
      accuracy: accuracy,
      durationSeconds: _elapsedSeconds,
      completedAt: DateTime.now().toIso8601String(),
    );

    if (mounted) {
      await context.read<GamesProvider>().recordGameResult(record);
    }
  }

  void _restartGame() {
    _startRainSession();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _ambientRainController.stop();
      } else {
        _ambientRainController.repeat();
      }
    });
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.water_drop_rounded, color: Color(0xFF38BDF8), size: 26),
            SizedBox(width: 10),
            Text('Cách chơi Mưa Từ Vựng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Xem nghĩa tiếng Việt mục tiêu ở khung phía trên màn hình.'),
            SizedBox(height: 8),
            Text('• Chạm/Click vào giọt mưa tiếng Anh khớp với nghĩa đó, hoặc gõ phím chữ cái đầu.'),
            SizedBox(height: 8),
            Text('• Chạm nhầm hoặc để giọt mục tiêu chìm xuống hồ nước sẽ mất 1 tim (❤️).'),
            SizedBox(height: 8),
            Text('• Bắt giọt mưa càng ở trên cao, điểm thưởng phản xạ càng lớn!'),
            SizedBox(height: 8),
            Text('• Phát âm chuẩn ngữ điệu tự động vang lên mỗi khi bắt trúng giọt mưa.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: const Color(0xFF0F172A),
            ),
            child: const Text('Bắt đầu chơi!'),
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

    return Scaffold(
      backgroundColor: const Color(0xFF1E2846),
      appBar: AppBar(
        title: const Text(
          'Mưa Từ Vựng (Vocabulary Rain)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E2846),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _difficulty.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _difficulty.color),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_difficulty.icon, color: _difficulty.color, size: 14),
                const SizedBox(width: 5),
                Text(
                  _difficulty.label,
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
            tooltip: 'Hướng dẫn',
            onPressed: _showTutorialDialog,
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
          ),
          IconButton(
            tooltip: _isPaused ? 'Tiếp tục' : 'Tạm dừng',
            onPressed: _togglePause,
            icon: Icon(
              _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent && !_isPaused && !_isGameOver) {
            String? char = event.character;
            if (char == null || char.isEmpty) {
              if (event.logicalKey.keyLabel.length == 1) {
                char = event.logicalKey.keyLabel;
              }
            }
            if (char != null && char.isNotEmpty) {
              _handleKeyInput(char);
            }
          }
        },
        child: Stack(
          children: [
            // Nền đồ họa mưa chuyển từ file Python tham khảo: gradient xanh dịu, mây mờ và vệt mưa mảnh chéo
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _ambientRainController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _VocabRainBackdropPainter(
                        raindrops: _ambientRainDrops,
                        isPaused: _isPaused,
                        onEnsureDrops: _syncAmbientRainDrops,
                      ),
                    );
                  },
                ),
              ),
            ),

            Column(
              children: [
                // Thanh trạng thái HUD: Điểm, Combo, Bắt trúng, Mạng
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1730).withValues(alpha: 0.9),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFF1E293B)),
                    ),
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          if (_lastGainedScore > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF38BDF8)),
                              ),
                              child: Text(
                                '+$_lastGainedScore',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF38BDF8),
                                ),
                              ),
                            ),
                          ],
                          if (_streak > 1) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF06B6D4).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF06B6D4)),
                              ),
                              child: Text(
                                '💧 Combo x$_streak',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF38BDF8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        'Bắt trúng: $_correctHits từ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      Row(
                        children: List.generate(3, (i) {
                          final isAlive = i < _lives;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              isAlive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 20,
                              color: isAlive ? const Color(0xFFEF4444) : const Color(0xFF475569),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // Khung mục tiêu cần tìm (Target Banner) cố định rõ ràng, không che khuất vùng rơi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0E223D).withValues(alpha: 0.95),
                        const Color(0xFF132F52).withValues(alpha: 0.95),
                      ],
                    ),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF38BDF8)),
                                ),
                                child: Text(
                                  _currentTargetWord.level,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _currentTargetWord.partOfSpeech.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'HÃY CHẠM VÀO GIỌT MƯA CÓ NGHĨA:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _currentTargetWord.meaning,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Không gian mưa rơi (Raindrop Canvas)
                Expanded(
                  child: LayoutBuilder(
                    builder: (ctx, constraints) {
                      final areaWidth = constraints.maxWidth;
                      final areaHeight = constraints.maxHeight;

                      return Stack(
                        children: [
                          // Hồ nước ở đáy
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: max(56.0, areaHeight * 0.13),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF0369A1).withValues(alpha: 0.35),
                                    const Color(0xFF0C4A6E).withValues(alpha: 0.85),
                                  ],
                                ),
                                border: const Border(
                                  top: BorderSide(
                                    color: Color(0xFF38BDF8),
                                    width: 2,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '🌊 Hồ nước từ vựng — Cứu giọt mục tiêu trước khi chìm!',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFBAE6FD),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),

                          // Các giọt mưa rơi
                          ..._activeDroplets.map((drop) {
                            final topPos = drop.y * areaHeight;
                            final leftPos = drop.x * areaWidth;
                            final isDanger = drop.y >= 0.65 && drop.isTarget;

                            return Positioned(
                              top: topPos,
                              left: leftPos.clamp(12.0, max(12.0, areaWidth - 210.0)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTapDown: (details) {
                                  _onDropletTapped(drop, Offset(leftPos + 60, topPos + 20));
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isDanger
                                          ? [
                                              const Color(0xFF7F1D1D).withValues(alpha: 0.95),
                                              const Color(0xFF991B1B).withValues(alpha: 0.95),
                                            ]
                                          : [
                                              const Color(0xFF0F2B48).withValues(alpha: 0.92),
                                              const Color(0xFF133E68).withValues(alpha: 0.92),
                                            ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(22),
                                      topRight: Radius.circular(22),
                                      bottomLeft: Radius.circular(22),
                                      bottomRight: Radius.circular(6),
                                    ),
                                    border: Border.all(
                                      color: isDanger
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF38BDF8),
                                      width: isDanger ? 2.4 : 1.8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDanger
                                            ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                                            : const Color(0xFF38BDF8).withValues(alpha: 0.3),
                                        blurRadius: isDanger ? 14 : 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isDanger ? Icons.warning_amber_rounded : Icons.water_drop_rounded,
                                        size: 16,
                                        color: isDanger ? const Color(0xFFFCA5A5) : const Color(0xFF38BDF8),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        drop.word.term,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.8),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Lớp vẽ Splash Particles (Hiệu ứng tóe nước khi bắt trúng)
                          if (_splashParticles.isNotEmpty)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: _SplashPainter(particles: _splashParticles),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),

            // Lớp phủ tạm dừng
            if (_isPaused)
              Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pause_circle_rounded, size: 54, color: Color(0xFF38BDF8)),
                        const SizedBox(height: 12),
                        const Text(
                          'Trò chơi đang tạm dừng',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _togglePause,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Tiếp tục chơi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38BDF8),
                            foregroundColor: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Thoát về danh sách game', style: TextStyle(color: Color(0xFF94A3B8))),
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

  Widget _buildResultScreen(BuildContext context) {
    final gamesProvider = context.watch<GamesProvider>();
    final isNewRecord = _score > gamesProvider.rainHighScore;
    final total = _correctHits + _missedWords.length;
    final accuracy = total > 0 ? ((_correctHits / total) * 100).round() : 0;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Tổng kết Mưa Từ Vựng'),
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
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.water_drop_rounded,
                          size: 44,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isNewRecord ? '🎉 KỶ LỤC MỚI CỦA BẠN!' : 'Hoàn thành lượt chơi!',
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
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('Cấp độ', _difficulty.label),
                          _buildStatColumn('Số từ bắt trúng', '$_correctHits'),
                          _buildStatColumn('Độ chính xác', '$accuracy%'),
                          _buildStatColumn('Combo cao nhất', '$_maxStreak💧'),
                          _buildStatColumn('Thời gian', '${_elapsedSeconds}s'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_missedWords.isNotEmpty) ...[
                  Text(
                    'Các từ vựng bạn đã bỏ lỡ (${_missedWords.length} từ):',
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
                              icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8)),
                              onPressed: () => TtsService().speak(word.term),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 20),
                ],

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
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Hứng mưa tiếp', style: TextStyle(fontWeight: FontWeight.bold)),
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
            color: Color(0xFF38BDF8),
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

  /// Màn hình chọn cấp độ khó và giới thiệu trước khi bắt đầu bắt mưa
  Widget _buildStartScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Mưa Từ Vựng'),
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
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
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
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Color(0xFF38BDF8),
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'MƯA TỪ VỰNG',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: context.textPrimaryColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phản xạ nhanh bắt các giọt mưa tiếng Anh đang rơi',
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
                        _buildRuleRow(Icons.visibility_rounded, 'Quan sát nghĩa tiếng Việt ở khung trung tâm.'),
                        const SizedBox(height: 8),
                        _buildRuleRow(Icons.touch_app_rounded, 'Chạm/click vào giọt mưa khớp với nghĩa mục tiêu.'),
                        const SizedBox(height: 8),
                        _buildRuleRow(Icons.water_rounded, 'Đừng để giọt mục tiêu chìm xuống hồ nước ở đáy!'),
                        const SizedBox(height: 8),
                        _buildRuleRow(Icons.volume_up_rounded, 'Phát âm bản ngữ chuẩn vang lên khi bắt trúng giọt mưa.'),
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
                    final speedDesc = diff == GameDifficulty.easy
                        ? 'Rơi thong thả'
                        : (diff == GameDifficulty.medium ? 'Tốc độ chuẩn' : 'Rơi dồn dập');

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
                                            speedDesc,
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
                    text: 'BẮT ĐẦU BẮT MƯA (${_difficulty.label.toUpperCase()})',
                    icon: Icons.water_drop_rounded,
                    backgroundColor: const Color(0xFF38BDF8),
                    textColor: const Color(0xFF0F172A),
                    onPressed: _startRainSession,
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
        Icon(icon, size: 17, color: const Color(0xFF38BDF8)),
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

/// Lớp vẽ hiệu ứng tóe nước khi bắt trúng giọt mưa
class _SplashPainter extends CustomPainter {
  final List<SplashParticle> particles;

  _SplashPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final alpha = (1.0 - p.progress).clamp(0.0, 1.0);
      final radius = p.maxRadius * p.progress;

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * (1.0 - p.progress);

      canvas.drawCircle(p.position, radius, paint);

      // Điểm số bay lên
      if (p.scoreText != null) {
        final tp = TextPainter(
          text: TextSpan(
            text: p.scoreText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: p.color.withValues(alpha: alpha),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
          canvas,
          Offset(
            p.position.dx - (tp.width / 2),
            p.position.dy - 20 - (p.progress * 30),
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SplashPainter oldDelegate) => true;
}

/// Mô hình hạt mưa trang trí nền (chuyển thể từ RainDrop trong test (1).py)
class _AmbientRainDrop {
  double x;
  double y;
  double len;
  double speed;
  double alpha;
  static const double angle = 0.15; // Góc nghiêng của vệt mưa

  _AmbientRainDrop({
    required this.x,
    required this.y,
    required this.len,
    required this.speed,
    required this.alpha,
  });

  factory _AmbientRainDrop.random(Size size, {double? yStart, Random? random}) {
    final r = random ?? Random();
    final w = size.width > 0 ? size.width : 480.0;
    final h = size.height > 0 ? size.height : 760.0;
    return _AmbientRainDrop(
      x: -50.0 + r.nextDouble() * (w + 100.0),
      y: yStart ?? (r.nextDouble() * h),
      len: 8.0 + r.nextDouble() * 10.0, // random.uniform(8, 18)
      speed: 5.0 + r.nextDouble() * 6.0, // random.uniform(5, 11)
      alpha: (60.0 + r.nextDouble() * 90.0) / 255.0, // random.randint(60, 150) / 255
    );
  }

  void reset(Size size, Random random) {
    final w = size.width > 0 ? size.width : 480.0;
    y = -20.0;
    x = -50.0 + random.nextDouble() * (w + 100.0);
    len = 8.0 + random.nextDouble() * 10.0;
    speed = 5.0 + random.nextDouble() * 6.0;
    alpha = (60.0 + random.nextDouble() * 90.0) / 255.0;
  }

  void update(Size size, Random random) {
    y += speed;
    x += speed * angle;
    if (y > size.height + 20.0) {
      reset(size, random);
    }
  }
}

/// Cấu hình vùng mây mờ mềm mại (make_soft_disc / make_background từ test (1).py)
class _CloudDiscSpec {
  final double rx;
  final double ry;
  final double radiusRatio;
  final Color color;

  const _CloudDiscSpec({
    required this.rx,
    required this.ry,
    required this.radiusRatio,
    required this.color,
  });
}

/// Lớp vẽ nền đồ họa Mưa Từ Vựng chuyển thể trực tiếp từ file tham khảo test (1).py:
/// 1. Nền gradient dịu nhẹ: BG_TOP (30, 40, 70) -> BG_BOT (58, 74, 112)
/// 2. Các vùng sáng mờ tạo cảm giác mây (make_soft_disc)
/// 3. Các vệt mưa mảnh chéo chuyển động (RainDrop)
class _VocabRainBackdropPainter extends CustomPainter {
  final List<_AmbientRainDrop> raindrops;
  final bool isPaused;
  final void Function(Size size) onEnsureDrops;
  final Random _random = Random();

  // Bảng màu mây mờ mềm mại từ palette tham khảo Python
  static const List<_CloudDiscSpec> _cloudDiscs = [
    _CloudDiscSpec(rx: 0.18, ry: 0.12, radiusRatio: 0.40, color: Color(0xFF5A78B4)), // (90, 120, 180)
    _CloudDiscSpec(rx: 0.80, ry: 0.16, radiusRatio: 0.45, color: Color(0xFF8296C8)), // (130, 150, 200)
    _CloudDiscSpec(rx: 0.46, ry: 0.32, radiusRatio: 0.38, color: Color(0xFF5064A0)), // (80, 100, 160)
    _CloudDiscSpec(rx: 0.90, ry: 0.48, radiusRatio: 0.42, color: Color(0xFF9682C8)), // (150, 130, 200)
    _CloudDiscSpec(rx: 0.06, ry: 0.54, radiusRatio: 0.37, color: Color(0xFF8296C8)),
    _CloudDiscSpec(rx: 0.52, ry: 0.65, radiusRatio: 0.46, color: Color(0xFF5A78B4)),
    _CloudDiscSpec(rx: 0.22, ry: 0.82, radiusRatio: 0.39, color: Color(0xFF9682C8)),
    _CloudDiscSpec(rx: 0.84, ry: 0.86, radiusRatio: 0.41, color: Color(0xFF5064A0)),
    _CloudDiscSpec(rx: -0.05, ry: 0.28, radiusRatio: 0.34, color: Color(0xFF5A78B4)),
    _CloudDiscSpec(rx: 1.05, ry: 0.36, radiusRatio: 0.35, color: Color(0xFF8296C8)),
  ];

  _VocabRainBackdropPainter({
    required this.raindrops,
    required this.isPaused,
    required this.onEnsureDrops,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    onEnsureDrops(size);

    // 1. Nền gradient xanh dịu: BG_TOP (30, 40, 70) -> BG_BOT (58, 74, 112)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E2846), // BG_TOP: (30, 40, 70)
          Color(0xFF3A4A70), // BG_BOT: (58, 74, 112)
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Các vùng sáng mờ tạo cảm giác mây (make_soft_disc với max_alpha ~22/255 và suy giảm lũy thừa)
    final baseRadiusDim = max(size.width, size.height * 0.7);
    for (final disc in _cloudDiscs) {
      final cx = disc.rx * size.width;
      final cy = disc.ry * size.height;
      final radius = baseRadiusDim * disc.radiusRatio;

      final cloudPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            disc.color.withValues(alpha: 0.086), // tương đương max_alpha=22 / 255
            disc.color.withValues(alpha: 0.052),
            disc.color.withValues(alpha: 0.016),
            disc.color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.42, 0.76, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

      canvas.drawCircle(Offset(cx, cy), radius, cloudPaint);
    }

    // 3. Các vệt mưa mảnh chéo chuyển động (RainDrop: len 8-18, speed 5-11, alpha 60-150, angle 0.15)
    final rainPaint = Paint()
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const rainBaseColor = Color(0xFFAAC3EB); // RAIN_COLOR: (170, 195, 235)

    for (final drop in raindrops) {
      if (!isPaused) {
        drop.update(size, _random);
      }

      final x2 = drop.x - (drop.len * _AmbientRainDrop.angle);
      final y2 = drop.y - drop.len;

      rainPaint.color = rainBaseColor.withValues(alpha: drop.alpha.clamp(0.0, 1.0));
      canvas.drawLine(Offset(drop.x, drop.y), Offset(x2, y2), rainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VocabRainBackdropPainter oldDelegate) => true;
}