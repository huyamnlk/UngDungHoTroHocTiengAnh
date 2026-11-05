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
import 'space_typer_screen.dart';


enum TyperSpeedMode {
  slow,
  normal,
  fast;

  String get label {
    switch (this) {
      case TyperSpeedMode.slow:
        return 'Dễ';
      case TyperSpeedMode.normal:
        return 'Bình thường';
      case TyperSpeedMode.fast:
        return 'Khó / Pro';
    }
  }

  String get description {
    switch (this) {
      case TyperSpeedMode.slow:
        return 'Tốc độ rơi chậm, từ vựng A1–A2 ngắn (3–6 ký tự), phù hợp người mới bắt đầu';
      case TyperSpeedMode.normal:
        return 'Tốc độ cân bằng, từ vựng thông dụng A1–B2, thích hợp luyện tập hàng ngày';
      case TyperSpeedMode.fast:
        return 'Tốc độ cao, xuất hiện từ vựng phong phú A1–C1, thử thách phản xạ chuyên nghiệp';
    }
  }

  Color get color {
    switch (this) {
      case TyperSpeedMode.slow:
        return const Color(0xFF10B981); // Emerald
      case TyperSpeedMode.normal:
        return AppColors.primary; // Blue
      case TyperSpeedMode.fast:
        return const Color(0xFFF59E0B); // Amber / Orange
    }
  }

  IconData get icon {
    switch (this) {
      case TyperSpeedMode.slow:
        return Icons.spa_rounded;
      case TyperSpeedMode.normal:
        return Icons.fitness_center_rounded;
      case TyperSpeedMode.fast:
        return Icons.bolt_rounded;
    }
  }

  double get baseSpeed {
    switch (this) {
      case TyperSpeedMode.slow:
        return 0.0013; // ~22s để từ rơi chạm đáy
      case TyperSpeedMode.normal:
        return 0.0020; // ~15s để từ rơi chạm đáy
      case TyperSpeedMode.fast:
        return 0.0030; // ~10s để từ rơi chạm đáy
    }
  }

  double get accelerationPerWord {
    switch (this) {
      case TyperSpeedMode.slow:
        return 0.000015; // Tăng rất êm dịu
      case TyperSpeedMode.normal:
        return 0.000035; // Tăng từ tốn
      case TyperSpeedMode.fast:
        return 0.000055; // Tăng nhanh hơn nhưng hợp lý
    }
  }

  int get spawnIntervalMs {
    switch (this) {
      case TyperSpeedMode.slow:
        return 3500;
      case TyperSpeedMode.normal:
        return 2700;
      case TyperSpeedMode.fast:
        return 1900;
    }
  }

  int get maxConcurrentWords {
    switch (this) {
      case TyperSpeedMode.slow:
        return 3;
      case TyperSpeedMode.normal:
        return 4;
      case TyperSpeedMode.fast:
        return 5;
    }
  }
}

class FallingWordItem {
  final WordModel word;
  double y; // 0.0 (top) to 1.0 (bottom danger line)
  final double x; // 0.05 to 0.70 horizontal position
  final double speed;
  bool isDestroyed;
  bool isTargeted;

  FallingWordItem({
    required this.word,
    this.y = 0.0,
    required this.x,
    required this.speed,
    this.isDestroyed = false,
    this.isTargeted = false,
  });
}

class EnergyBeamProjectile {
  final String text;
  final String wordTerm;
  final Offset start;
  final Offset target;
  double progress; // 0.0 to 1.0
  final Color color;

  EnergyBeamProjectile({
    required this.text,
    required this.wordTerm,
    required this.start,
    required this.target,
    this.progress = 0.0,
    required this.color,
  });
}

class ParticleDot {
  double dx;
  double dy;
  double vx;
  double vy;
  double radius;
  Color color;

  ParticleDot({
    required this.dx,
    required this.dy,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });
}

class ParticleExplosion {
  final Offset origin;
  final String scoreText;
  final List<ParticleDot> particles;
  int frame;
  final int maxFrames;

  ParticleExplosion({
    required this.origin,
    required this.scoreText,
    required this.particles,
    this.frame = 0,
    this.maxFrames = 18,
  });
}

class WordTyperScreen extends StatefulWidget {
  final List<WordModel> words;
  final String topicName;
  final int? topicId;
  final String level;

  const WordTyperScreen({
    super.key,
    required this.words,
    this.topicName = 'Tất cả chủ đề',
    this.topicId,
    this.level = 'All',
  });

  @override
  State<WordTyperScreen> createState() => _WordTyperScreenState();
}

class _WordTyperScreenState extends State<WordTyperScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late List<WordModel> _wordPool;
  int _wordPoolIndex = 0;

  // Ghi nhớ lựa chọn mức độ gần nhất
  static TyperSpeedMode _savedSpeedMode = TyperSpeedMode.normal;

  // Lựa chọn tốc độ và trạng thái bắt đầu chơi
  late TyperSpeedMode _speedMode;
  bool _hasGameStarted = false;

  // Danh sách từ đang rơi trên màn hình
  final List<FallingWordItem> _activeWords = [];
  Timer? _gameLoopTimer;
  Timer? _spawnTimer;

  // Hiệu ứng đạn pháo / tia năng lượng và nổ hạt
  final List<EnergyBeamProjectile> _activeProjectiles = [];
  final List<ParticleExplosion> _activeExplosions = [];

  // Thống kê người chơi
  int _score = 0;
  int _streak = 0;
  int _maxStreak = 0;
  int _lives = 3;
  int _wordsTypedCount = 0;
  int _totalKeystrokes = 0;
  int _correctKeystrokes = 0;
  int _elapsedSeconds = 0;
  Timer? _elapsedTimer;

  bool _isGameOver = false;
  bool _isPaused = false;
  bool _lostLifeFlash = false;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<WordModel> _missedWords = [];

  // Tốc độ hiện tại
  double _currentBaseSpeed = 0.0020;

  // Tọa độ vùng chơi LayoutBuilder để tính toán đạn bắn chuẩn xác
  double _currentAreaWidth = 400.0;
  double _currentAreaHeight = 600.0;

  @override
  void initState() {
    super.initState();
    _speedMode = _savedSpeedMode;
    // Game không tự chạy ngay; hiển thị màn hình chọn mức trước
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    _elapsedTimer?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    TtsService().stop();
    super.dispose();
  }

  void _prepareFilteredWordPool() {
    List<WordModel> pool;
    if (_speedMode == TyperSpeedMode.slow) {
      // Mức Dễ: ưu tiên từ ngắn (<= 6 ký tự) và cấp độ cơ bản A1, A2
      pool = widget.words.where((w) {
        final len = w.term.trim().length;
        return len <= 6 && (w.level == 'A1' || w.level == 'A2' || w.level == 'B1');
      }).toList();
      if (pool.length < 15) {
        pool = widget.words.where((w) => w.term.trim().length <= 7).toList();
      }
    } else if (_speedMode == TyperSpeedMode.normal) {
      // Mức Bình thường: từ phổ biến độ dài vừa phải
      pool = widget.words.where((w) {
        final len = w.term.trim().length;
        return len <= 9 && w.level != 'C1';
      }).toList();
      if (pool.length < 15) {
        pool = widget.words;
      }
    } else {
      // Mức Khó/Pro: đầy đủ cấp độ bao gồm cả từ dài và C1
      pool = widget.words;
    }

    if (pool.isEmpty) {
      pool = widget.words;
    }
    _wordPool = List<WordModel>.from(pool)..shuffle(_random);
  }

  void _startGameSession() {
    _savedSpeedMode = _speedMode;
    _prepareFilteredWordPool();

    _activeWords.clear();
    _activeProjectiles.clear();
    _activeExplosions.clear();
    _score = 0;
    _streak = 0;
    _maxStreak = 0;
    _lives = 3;
    _wordsTypedCount = 0;
    _totalKeystrokes = 0;
    _correctKeystrokes = 0;
    _elapsedSeconds = 0;
    _currentBaseSpeed = _speedMode.baseSpeed;
    _isGameOver = false;
    _isPaused = false;
    _lostLifeFlash = false;
    _missedWords.clear();
    _wordPoolIndex = 0;
    _hasGameStarted = true;

    _spawnInitialWords();

    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted || _isPaused || _isGameOver) return;
      _updatePhysics();
    });

    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(
        Duration(milliseconds: _speedMode.spawnIntervalMs), (_) {
      if (!mounted || _isPaused || _isGameOver) return;
      _spawnWord();
    });

    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isPaused || _isGameOver) return;
      setState(() => _elapsedSeconds++);
    });

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _spawnInitialWords() {
    _spawnWord(initialY: 0.04);
    if (_speedMode != TyperSpeedMode.slow) {
      _spawnWord(initialY: 0.22);
    }
  }

  void _spawnWord({double initialY = 0.0}) {
    if (_activeWords.where((w) => !w.isDestroyed).length >=
        _speedMode.maxConcurrentWords) {
      return;
    }
    if (_wordPool.isEmpty) return;

    final word = _wordPool[_wordPoolIndex % _wordPool.length];
    _wordPoolIndex++;

    // Phân bố ngang an toàn tránh chạm viền
    final posX = 0.06 + (_random.nextDouble() * 0.54);
    final speed = _currentBaseSpeed + (_random.nextDouble() * 0.0006);

    setState(() {
      _activeWords.add(FallingWordItem(
        word: word,
        y: initialY,
        x: posX,
        speed: speed,
      ));
    });
  }

  void _updatePhysics() {
    bool stateChanged = false;

    // 1. Cập nhật các từ đang rơi
    for (final item in _activeWords) {
      if (item.isDestroyed) continue;
      item.y += item.speed;

      // Chạm vạch bảo vệ căn cứ ở đáy (y >= 0.88)
      if (item.y >= 0.88) {
        item.isDestroyed = true;
        stateChanged = true;
        _lives--;
        _streak = 0;
        HapticFeedback.heavyImpact();

        // Flash cảnh báo mất lượt
        _lostLifeFlash = true;
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) setState(() => _lostLifeFlash = false);
        });

        if (!_missedWords.any((w) => w.id == item.word.id)) {
          _missedWords.add(item.word);
        }

        if (_lives <= 0) {
          _endGame();
          return;
        }
      }
    }

    _activeWords.removeWhere((item) => item.isDestroyed && !item.isTargeted);

    // 2. Cập nhật các tia đạn năng lượng
    for (int i = _activeProjectiles.length - 1; i >= 0; i--) {
      final p = _activeProjectiles[i];
      p.progress += 0.14; // bay trong khoảng ~7 frames (210ms) mượt mà
      stateChanged = true;

      if (p.progress >= 1.0) {
        // Đạn chạm mục tiêu -> kích hoạt nổ hạt và popup điểm số
        _spawnExplosion(p.target, p.text);
        _activeProjectiles.removeAt(i);
      }
    }

    // 3. Cập nhật các vụ nổ hạt
    for (int i = _activeExplosions.length - 1; i >= 0; i--) {
      final exp = _activeExplosions[i];
      exp.frame++;
      stateChanged = true;

      for (final dot in exp.particles) {
        dot.dx += dot.vx;
        dot.dy += dot.vy;
        dot.vy += 0.35; // trọng lực nhẹ
        dot.radius = max(0.5, dot.radius * 0.92);
      }

      if (exp.frame >= exp.maxFrames) {
        _activeExplosions.removeAt(i);
      }
    }

    if (stateChanged || _activeWords.isNotEmpty) {
      setState(() {});
    }
  }

  void _spawnExplosion(Offset target, String text) {
    final List<ParticleDot> dots = [];
    final colors = [
      AppColors.accent,
      AppColors.primary,
      const Color(0xFF4CC9F0),
      const Color(0xFFFFD166),
      Colors.white,
    ];

    for (int i = 0; i < 14; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 2.0 + _random.nextDouble() * 5.0;
      dots.add(ParticleDot(
        dx: target.dx,
        dy: target.dy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 1.5,
        radius: 3.0 + _random.nextDouble() * 3.5,
        color: colors[_random.nextInt(colors.length)],
      ));
    }

    _activeExplosions.add(ParticleExplosion(
      origin: target,
      scoreText: text,
      particles: dots,
    ));
  }

  void _onTextChanged(String text) {
    if (_isGameOver || _isPaused || !_hasGameStarted) return;
    final input = text.trim().toLowerCase();
    _totalKeystrokes++;

    // Tìm từ rơi đang trùng khớp chính xác toàn bộ
    FallingWordItem? matchedItem;
    for (final item in _activeWords) {
      if (!item.isDestroyed && item.word.term.trim().toLowerCase() == input) {
        matchedItem = item;
        break;
      }
    }

    if (matchedItem != null) {
      // Gõ chính xác từ hoàn chỉnh!
      HapticFeedback.lightImpact();
      matchedItem.isDestroyed = true;
      matchedItem.isTargeted = true;
      _wordsTypedCount++;
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;
      _correctKeystrokes += matchedItem.word.term.length;

      // Điểm: Bắn hạ khi từ càng ở trên cao thì điểm thưởng càng lớn
      final altitudeBonus = ((1.0 - matchedItem.y) * 120).round();
      final comboMultiplier = min(_streak, 4);
      final gained = (100 + altitudeBonus) * comboMultiplier;
      _score += gained;

      // Tăng tốc độ rơi từ từ theo mức độ đã chọn
      _currentBaseSpeed = (_currentBaseSpeed + _speedMode.accelerationPerWord)
          .clamp(_speedMode.baseSpeed, 0.0065);

      // Kích hoạt hiệu ứng bắn luồng đạn từ máy bay cố định ở giữa
      _triggerShootingEffect(matchedItem, gained, comboMultiplier);

      _textController.clear();
      setState(() {});
    }
  }

  void _triggerShootingEffect(
      FallingWordItem item, int gained, int comboMultiplier) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    // Tọa độ mục tiêu của từ vựng đang rơi
    final targetX = (item.x * _currentAreaWidth + 70.0)
        .clamp(40.0, max(40.0, _currentAreaWidth - 40.0))
        .toDouble();
    final targetY = (item.y * (_currentAreaHeight - 60.0) + 26.0)
        .clamp(20.0, max(20.0, _currentAreaHeight - 40.0))
        .toDouble();
    final targetOffset = Offset(targetX, targetY);

    // Máy bay LUÔN NẰM CHÍNH GIỮA THEO CHIỀU NGANG VÀ GẦN ĐÁY
    final startOffset = Offset(_currentAreaWidth * 0.5, _currentAreaHeight - 42.0);

    final scoreLabel =
        comboMultiplier > 1 ? '+$gained 🔥x$comboMultiplier' : '+$gained';

    if (disableAnimations) {
      // Tôn trọng cài đặt giảm chuyển động
      _spawnExplosion(targetOffset, scoreLabel);
      return;
    }

    _activeProjectiles.add(EnergyBeamProjectile(
      text: scoreLabel,
      wordTerm: item.word.term,
      start: startOffset,
      target: targetOffset,
      color: comboMultiplier > 1 ? AppColors.accent : AppColors.primary,
    ));
  }

  Future<void> _endGame() async {
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    _elapsedTimer?.cancel();
    setState(() => _isGameOver = true);

    final accuracy = _totalKeystrokes > 0
        ? (_correctKeystrokes / _totalKeystrokes * 100).clamp(0.0, 100.0)
        : 0.0;

    final record = GameRecordModel(
      gameType: 'typer',
      topicId: widget.topicId,
      topicName: widget.topicName,
      level: widget.level,
      score: _score,
      highStreak: _maxStreak,
      totalItems: _wordsTypedCount + _missedWords.length,
      correctItems: _wordsTypedCount,
      accuracy: accuracy,
      durationSeconds: _elapsedSeconds,
      completedAt: DateTime.now().toIso8601String(),
    );

    if (mounted) {
      await context.read<GamesProvider>().recordGameResult(record);
    }
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (!_isPaused) {
      _focusNode.requestFocus();
    }
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.rocket_launch_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Cách chơi Gõ Từ Siêu Tốc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '🎯 **Mục tiêu**: Bắn hạ các từ vựng đang rơi bằng cách gõ chính xác từ tiếng Anh trước khi từ chạm vạch đáy đỏ.'),
            SizedBox(height: 10),
            Text(
                '✈️ **Vị trí máy bay**: Máy bay chiến đấu luôn cố định chính giữa theo chiều ngang ở đáy màn hình. Khi gõ đúng từ, luồng đạn năng lượng sẽ bay từ nòng súng máy bay thẳng đến mục tiêu!'),
            SizedBox(height: 10),
            Text('🎚️ **Ba mức độ thử thách**:'),
            Text(
                '  • **Dễ**: Rơi chậm, từ ngắn A1–A2, tốc độ tăng rất êm cho người mới.'),
            Text(
                '  • **Bình thường**: Tốc độ cân bằng cho rèn luyện phản xạ hằng ngày.'),
            Text(
                '  • **Khó / Pro**: Tốc độ cao, xuất hiện từ vựng A1–C1 phong phú.'),
            SizedBox(height: 10),
            Text(
                '⚡ **Điểm thưởng độ cao & Combo**: Bắn hạ từ khi còn ở trên cao nhận thêm điểm thưởng. Gõ đúng liên tiếp kích hoạt Combo lên đến x4!'),
            SizedBox(height: 10),
            Text(
                '❤️ **Lượt chơi**: Bạn có 3 tim. Để từ chạm vạch nguy hiểm ở đáy sẽ mất 1 tim.'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đã hiểu!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasGameStarted) {
      return _buildPreGameModeSelector(context);
    }

    if (_isGameOver) {
      return _buildResultScreen(context);
    }

    final currentInput = _textController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Gõ Từ Siêu Tốc (Speed Typer)'),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        actions: [
          // Hiển thị huy hiệu mức độ hiện tại trên AppBar (đã khóa cố định trong trận)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _speedMode.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _speedMode.color, width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_speedMode.icon, size: 14, color: _speedMode.color),
                  const SizedBox(width: 4),
                  Text(
                    _speedMode.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _speedMode.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Hướng dẫn',
            onPressed: _showTutorialDialog,
            icon: const Icon(Icons.info_outline_rounded),
          ),
          IconButton(
            tooltip: _isPaused ? 'Tiếp tục' : 'Tạm dừng',
            onPressed: _togglePause,
            icon: Icon(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Thanh trạng thái điểm & lượt chơi & combo (HUD)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  border: Border(bottom: BorderSide(color: context.borderCol)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Điểm số & Combo
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded,
                            color: AppColors.accent, size: 24),
                        const SizedBox(width: 6),
                        Text(
                          '$_score',
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w900),
                        ),
                        if (_streak > 1) ...[
                          const SizedBox(width: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.25),
                                  Colors.deepOrange.withValues(alpha: 0.25),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.accent, width: 1.2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥',
                                    style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 3),
                                Text(
                                  'x${min(_streak, 4)} ($_streak)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Số từ đã gõ & thời gian
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            size: 16, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          '$_wordsTypedCount từ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.timer_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${_elapsedSeconds}s',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),

                    // Tim (Lượt sống)
                    Row(
                      children: List.generate(3, (i) {
                        final isAlive = i < _lives;
                        return Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Icon(
                            isAlive
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 22,
                            color: isAlive
                                ? AppColors.danger
                                : context.textMutedColor,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Vùng chơi Game tương tác rơi từ (Falling & Combat Area)
              Expanded(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    _currentAreaWidth = constraints.maxWidth;
                    _currentAreaHeight = constraints.maxHeight;

                    final areaWidth = _currentAreaWidth;
                    final areaHeight = _currentAreaHeight;
                    final jetCenterPos = Offset(areaWidth * 0.5, areaHeight - 26);

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Nền bầu trời lưới tọa độ nhẹ nhàng
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  context.scaffoldBg,
                                  context.cardBg.withValues(alpha: 0.5),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Vạch báo động đỏ ở đáy
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: areaHeight * 0.12,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.danger.withValues(alpha: 0.0),
                                  AppColors.danger.withValues(alpha: 0.16),
                                ],
                              ),
                              border: Border(
                                top: BorderSide(
                                  color:
                                      AppColors.danger.withValues(alpha: 0.55),
                                  width: 2,
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    size: 16, color: AppColors.danger),
                                const SizedBox(width: 6),
                                Text(
                                  'VẠCH BẢO VỆ CĂN CỨ — HÃY BẮN HẠ TỪ TRƯỚC KHI CHẠM ĐÁY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        AppColors.danger.withValues(alpha: 0.9),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Vẽ hiệu ứng đạn pháo / tia sáng năng lượng và máy bay LUÔN NẰM CHÍNH GIỮA
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _CombatEffectsPainter(
                              projectiles: _activeProjectiles,
                              explosions: _activeExplosions,
                              jetCenter: jetCenterPos,
                              jetColor: _speedMode.color,
                              comboActive: _streak > 1,
                            ),
                          ),
                        ),

                        // Các từ vựng đang rơi
                        ..._activeWords.map((item) {
                          if (item.isDestroyed) return const SizedBox.shrink();

                          final topPos = item.y * (areaHeight - 56.0);
                          final leftPos = item.x * areaWidth;
                          final term = item.word.term;
                          final termLower = term.toLowerCase();

                          // Kiểm tra tiền tố đang gõ
                          final bool isPrefixMatch = currentInput.isNotEmpty &&
                              termLower.startsWith(currentInput);
                          final bool isNearDanger = item.y > 0.68;

                          return Positioned(
                            top: topPos,
                            left: leftPos.clamp(
                                12.0, max(12.0, areaWidth - 220.0)),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isPrefixMatch
                                    ? AppColors.primary
                                    : (isNearDanger
                                        ? AppColors.danger
                                            .withValues(alpha: 0.14)
                                        : context.cardBg),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isPrefixMatch
                                      ? Colors.white
                                      : (isNearDanger
                                          ? AppColors.danger
                                          : context.borderCol),
                                  width: isPrefixMatch
                                      ? 2.5
                                      : (isNearDanger ? 2.0 : 1.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isPrefixMatch
                                        ? AppColors.primary
                                            .withValues(alpha: 0.45)
                                        : (isNearDanger
                                            ? AppColors.danger
                                                .withValues(alpha: 0.25)
                                            : Colors.black
                                                .withValues(alpha: 0.08)),
                                    blurRadius: isPrefixMatch ? 12 : 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isNearDanger && !isPrefixMatch) ...[
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          size: 14,
                                          color: AppColors.danger,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            if (isPrefixMatch) ...[
                                              TextSpan(
                                                text: term.substring(
                                                    0, currentInput.length),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                              TextSpan(
                                                text: term.substring(
                                                    currentInput.length),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                ),
                                              ),
                                            ] else ...[
                                              TextSpan(
                                                text: term,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: isNearDanger
                                                      ? AppColors.danger
                                                      : context.textPrimaryColor,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.word.meaning,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: isPrefixMatch
                                          ? Colors.white.withValues(alpha: 0.9)
                                          : context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),

              // Khung nhập liệu bàn phím
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  border: Border(top: BorderSide(color: context.borderCol)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onChanged: _onTextChanged,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: context.textPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập từ tiếng Anh đang rơi để máy bay bắn...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          letterSpacing: 0.5,
                          color: context.textMutedColor,
                        ),
                        filled: true,
                        fillColor: context.scaffoldBg,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        suffixIcon: _textController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _textController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: context.borderCol),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: context.borderCol),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Viền nháy đỏ khi mất lượt
          if (_lostLifeFlash)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.danger, width: 6),
                  ),
                ),
              ),
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
                      const Icon(Icons.pause_circle_rounded,
                          size: 54, color: AppColors.primary),
                      const SizedBox(height: 12),
                      const Text(
                        'Trò chơi đang tạm dừng',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _speedMode.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Mức độ: ${_speedMode.label}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _speedMode.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
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
    );
  }

  /// Màn hình chọn trước mức độ (Dễ, Bình thường, Khó/Pro) trước khi bắt đầu
  Widget _buildPreGameModeSelector(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Gõ Từ Siêu Tốc (Speed Typer)'),
        backgroundColor: context.surfaceBg,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Chọn mức độ thử thách',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Chọn mức độ phù hợp với khả năng gõ phím của bạn trước khi xuất trận.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3 Thẻ lựa chọn mức độ
                ...TyperSpeedMode.values.map((mode) {
                  final isSelected = _speedMode == mode;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => setState(() => _speedMode = mode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? mode.color.withValues(alpha: 0.14)
                              : context.cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? mode.color : context.borderCol,
                            width: isSelected ? 2.2 : 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: mode.color.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: mode.color.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(mode.icon,
                                  color: mode.color, size: 26),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        mode.label,
                                        style: TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w900,
                                          color: isSelected
                                              ? mode.color
                                              : context.textPrimaryColor,
                                        ),
                                      ),
                                      if (mode == TyperSpeedMode.normal) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Khuyên dùng',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mode.description,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      height: 1.35,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Radio<TyperSpeedMode>(
                              value: mode,
                              groupValue: _speedMode,
                              activeColor: mode.color,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _speedMode = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Nút Bắt đầu chơi
                CustomButton(
                  text: 'Bắt đầu chơi (${_speedMode.label})',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _startGameSession,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SpaceTyperScreen(
                            words: widget.words,
                            topicName: widget.topicName,
                            topicId: widget.topicId,
                            level: widget.level,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF38BDF8),
                      side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                    label: const Text(
                      '🚀 Trải nghiệm Chiến cơ Vũ trụ (Space Typer)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
    final isNewRecord = _score > gamesProvider.typerHighScore;
    final wpm = _elapsedSeconds > 0
        ? ((_wordsTypedCount / _elapsedSeconds) * 60).round()
        : 0;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Kết quả Gõ Từ Siêu Tốc'),
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
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          size: 44,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isNewRecord
                            ? '🎉 PHÁ KỶ LỤC TỐC ĐỘ GÕ!'
                            : 'Kết thúc màn luyện gõ!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isNewRecord
                              ? AppColors.accent
                              : context.textPrimaryColor,
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
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _speedMode.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Mức độ: ${_speedMode.label}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: _speedMode.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(
                              'Số từ gõ đúng', '$_wordsTypedCount từ'),
                          _buildStatColumn('Tốc độ', '$wpm WPM'),
                          _buildStatColumn('Chuỗi đúng', '$_maxStreak từ'),
                          _buildStatColumn('Thời gian', '${_elapsedSeconds}s'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_missedWords.isNotEmpty) ...[
                  Text(
                    'Các từ bạn đã bỏ lỡ (${_missedWords.length} từ):',
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
                              icon: const Icon(Icons.volume_up_rounded,
                                  color: AppColors.primary),
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
                      child: CustomButton(
                        text: 'Chơi lại',
                        icon: Icons.replay_rounded,
                        onPressed: _startGameSession,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Đổi mức độ',
                        isOutlined: true,
                        icon: Icons.tune_rounded,
                        onPressed: () {
                          setState(() {
                            _hasGameStarted = false;
                            _isGameOver = false;
                          });
                        },
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

/// CustomPainter vẽ máy bay chiến đấu cố định chính giữa ở đáy, tia đạn mang chữ và nổ hạt
class _CombatEffectsPainter extends CustomPainter {
  final List<EnergyBeamProjectile> projectiles;
  final List<ParticleExplosion> explosions;
  final Offset jetCenter;
  final Color jetColor;
  final bool comboActive;

  _CombatEffectsPainter({
    required this.projectiles,
    required this.explosions,
    required this.jetCenter,
    required this.jetColor,
    required this.comboActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Vẽ máy bay chiến đấu (Spaceship Fighter) LUÔN CỐ ĐỊNH CHÍNH GIỮA THEO CHIỀU NGANG Ở ĐÁY
    final fixedJetCenter = Offset(size.width * 0.5, size.height - 24);

    final jetPaint = Paint()
      ..color = jetColor
      ..style = PaintingStyle.fill;

    final jetGlowPaint = Paint()
      ..color =
          (comboActive ? AppColors.accent : jetColor).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Vầng hào quang động cơ
    canvas.drawCircle(fixedJetCenter + const Offset(0, 8), 18, jetGlowPaint);

    // Thân máy bay hình phi thuyền chiến đấu
    final jetPath = Path();
    jetPath.moveTo(fixedJetCenter.dx, fixedJetCenter.dy - 18); // Mũi máy bay
    jetPath.lineTo(fixedJetCenter.dx + 16, fixedJetCenter.dy + 12); // Cánh phải
    jetPath.lineTo(fixedJetCenter.dx + 4, fixedJetCenter.dy + 7); // Đuôi phải
    jetPath.lineTo(fixedJetCenter.dx, fixedJetCenter.dy + 11); // Đuôi giữa
    jetPath.lineTo(fixedJetCenter.dx - 4, fixedJetCenter.dy + 7); // Đuôi trái
    jetPath.lineTo(fixedJetCenter.dx - 16, fixedJetCenter.dy + 12); // Cánh trái
    jetPath.close();

    canvas.drawPath(jetPath, jetPaint);

    // Kính buồng lái máy bay (Cockpit)
    final cockpitPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
          center: fixedJetCenter + const Offset(0, -3), width: 6, height: 10),
      cockpitPaint,
    );

    // Luồng lửa phản lực phụt ra từ đuôi
    final thrusterPaint = Paint()
      ..color =
          (comboActive ? const Color(0xFFFF9F1C) : const Color(0xFF4CC9F0))
      ..style = PaintingStyle.fill;
    final thrusterPath = Path();
    thrusterPath.moveTo(fixedJetCenter.dx - 4, fixedJetCenter.dy + 11);
    thrusterPath.lineTo(
        fixedJetCenter.dx, fixedJetCenter.dy + 21 + (comboActive ? 5 : 0));
    thrusterPath.lineTo(fixedJetCenter.dx + 4, fixedJetCenter.dy + 11);
    thrusterPath.close();
    canvas.drawPath(thrusterPath, thrusterPaint);

    // 2. Vẽ các tia đạn năng lượng mang chữ đang bay từ máy bay cố định đến từ mục tiêu
    for (final p in projectiles) {
      final currentPos =
          Offset.lerp(p.start, p.target, p.progress.clamp(0.0, 1.0))!;
      final tailPos =
          Offset.lerp(p.start, p.target, max(0.0, p.progress - 0.22))!;

      // Quầng sáng đạn
      final beamGlowPaint = Paint()
        ..color = p.color.withValues(alpha: 0.6)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawLine(tailPos, currentPos, beamGlowPaint);

      // Lõi tia laser
      final beamCorePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(tailPos, currentPos, beamCorePaint);

      // Đầu đạn quả cầu phát sáng mang luồng chữ
      canvas.drawCircle(currentPos, 4, Paint()..color = p.color);
      canvas.drawCircle(currentPos, 2, Paint()..color = Colors.white);

      // Hiệu ứng chữ đang bay tới mục tiêu
      if (p.wordTerm.isNotEmpty && p.progress > 0.15 && p.progress < 0.90) {
        final textSpan = TextSpan(
          text: p.wordTerm,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: p.color,
                blurRadius: 6,
              ),
            ],
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        final textOffset = Offset(
          currentPos.dx - (textPainter.width * 0.5),
          currentPos.dy - 16,
        );
        textPainter.paint(canvas, textOffset);
      }
    }

    // 3. Vẽ vụ nổ hạt và popup điểm số
    for (final exp in explosions) {
      final progress = exp.frame / exp.maxFrames;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      // Các hạt ánh sáng văng ra
      for (final dot in exp.particles) {
        final dotPaint = Paint()
          ..color = dot.color.withValues(alpha: opacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(dot.dx, dot.dy), dot.radius, dotPaint);
      }

      // Nhãn điểm số nổi bay lên (+150, Combo)
      final textSpan = TextSpan(
        text: exp.scoreText,
        style: TextStyle(
          color: (comboActive ? AppColors.accent : Colors.white)
              .withValues(alpha: opacity),
          fontSize: 15 + (comboActive ? 2 : 0),
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              blurRadius: 8,
              color: Colors.black.withValues(alpha: 0.8 * opacity),
            ),
          ],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final floatOffset = Offset(
        exp.origin.dx - textPainter.width * 0.5,
        exp.origin.dy - 20 - (progress * 26),
      );
      textPainter.paint(canvas, floatOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _CombatEffectsPainter oldDelegate) => true;
}