import 'dart:math';
import 'package:flutter/material.dart';
import 'package:english_buddy/data/models/word_model.dart';
import '../../common/game_difficulty.dart';
import '../models/space_models.dart';

/// Bộ máy quản lý trạng thái và tính toán vật lý của trò chơi Space Typer
class SpaceGameEngine extends ChangeNotifier {
  final Random _random = Random();

  // Kích thước vùng chơi
  double width = 480.0;
  double height = 760.0;
  double playTop = 70.0;
  double playBottom = 640.0;

  // Cấu hình gameplay & cấp độ khó
  GameDifficulty difficulty = GameDifficulty.medium;
  bool isLettersOnly = false;
  List<WordModel> wordPool = [];
  int _wordPoolIndex = 0;

  // Danh sách thực thể trong game
  final List<SpaceStar> stars = [];
  final List<AsteroidTarget> asteroids = [];
  final List<SpaceLaserBullet> bullets = [];
  final List<SpaceParticle> particles = [];
  final List<SpacePlanet> planets = [
    const SpacePlanet(
      relativeX: 0.12,
      relativeY: 0.22,
      radius: 46.0,
      primaryColor: Color(0xFF1E3A8A), // Hành tinh xanh vũ trụ
      ringColor: Color(0xFF38BDF8),
      hasRing: true,
    ),
    const SpacePlanet(
      relativeX: 0.88,
      relativeY: 0.44,
      radius: 52.0,
      primaryColor: Color(0xFF9A3412), // Hành tinh đỏ Mars
      ringColor: Color(0xFFEA580C),
      hasRing: false,
    ),
  ];

  // Trạng thái chiến cơ người chơi
  double shipX = 240.0;
  double targetShipX = 240.0;
  double shipY = 600.0;
  double shipInvulTimer = 0.0;
  double engineFlame = 20.0;

  // Chỉ số người chơi (Health, Shield, Energy)
  int health = 5;
  double shield = 100.0;
  double energy = 100.0;

  // Điểm số & độ khó
  int score = 0;
  int level = 1;
  int targetsDestroyed = 0;
  int targetsToNextLevel = 8;
  int streak = 0;
  int maxStreak = 0;
  int totalKeystrokes = 0;
  int correctKeystrokes = 0;
  int wordsDestroyedCount = 0;
  double elapsedSeconds = 0.0;

  // Banner thông báo trong game (vd: "LEVEL 2!", "EXCELLENT!")
  String? bannerText;
  double bannerTimer = 0.0;

  // Mục tiêu đang khóa để gõ
  AsteroidTarget? lockedTarget;

  // Danh sách từ bị bỏ lỡ
  final List<WordModel> missedWords = [];

  // Trạng thái vòng lặp game
  bool isStarted = false;
  bool isPaused = false;
  bool isGameOver = false;

  // Thuộc tính thử thách theo độ khó
  int get maxConcurrentTargets => switch (difficulty) {
        GameDifficulty.easy => 3,
        GameDifficulty.medium => 5,
        GameDifficulty.hard => 6,
      };

  double get speedMultiplier => switch (difficulty) {
        GameDifficulty.easy => 0.80,
        GameDifficulty.medium => 1.15,
        GameDifficulty.hard => 1.55,
      };

  double get baseSpawnInterval => switch (difficulty) {
        GameDifficulty.easy => 2.4,
        GameDifficulty.medium => 1.8,
        GameDifficulty.hard => 1.35,
      };

  // Bộ đếm thời gian sinh mục tiêu
  double _spawnTimer = 0.0;

  // Callbacks
  void Function(WordModel? word, String text)? onWordCompleted;
  void Function()? onPlayerHit;
  void Function()? onLevelUp;
  void Function()? onGameOver;

  void init({
    required double newWidth,
    required double newHeight,
    required double newPlayTop,
    required double newPlayBottom,
    required List<WordModel> words,
    bool lettersOnlyMode = false,
    GameDifficulty gameDifficulty = GameDifficulty.medium,
  }) {
    width = newWidth > 0 ? newWidth : 480.0;
    height = newHeight > 0 ? newHeight : 760.0;
    playTop = newPlayTop;
    playBottom = newPlayBottom;
    isLettersOnly = lettersOnlyMode;
    difficulty = gameDifficulty;

    // Lọc từ vựng theo độ dài và cấp độ thực tế của độ khó
    final filteredWords = GameDifficulty.filterWords(
      words: words,
      difficulty: difficulty,
    );
    wordPool = List<WordModel>.from(filteredWords)..shuffle(_random);
    _wordPoolIndex = 0;

    // Khởi tạo các ngôi sao
    stars.clear();
    for (int i = 0; i < 90; i++) {
      stars.add(SpaceStar(
        x: _random.nextDouble() * width,
        y: playTop + _random.nextDouble() * (playBottom - playTop),
        layer: _random.nextInt(3) + 1,
      ));
    }

    reset();
  }

  void resize(double newWidth, double newHeight, double newPlayTop, double newPlayBottom) {
    if (newWidth <= 0 || newHeight <= 0) return;
    final oldWidth = width;
    width = newWidth;
    height = newHeight;
    playTop = newPlayTop;
    playBottom = newPlayBottom;

    if (oldWidth > 0) {
      shipX = (shipX / oldWidth * width).clamp(30.0, width - 30.0);
      targetShipX = (targetShipX / oldWidth * width).clamp(30.0, width - 30.0);
    }
    shipY = playBottom - 50.0;
  }

  void reset() {
    asteroids.clear();
    bullets.clear();
    particles.clear();
    missedWords.clear();

    shipX = width * 0.5;
    targetShipX = width * 0.5;
    shipY = playBottom - 50.0;
    shipInvulTimer = 0.0;

    health = 5;
    shield = 100.0;
    energy = 100.0;

    score = 0;
    level = 1;
    targetsDestroyed = 0;
    targetsToNextLevel = 8;
    streak = 0;
    maxStreak = 0;
    totalKeystrokes = 0;
    correctKeystrokes = 0;
    wordsDestroyedCount = 0;
    elapsedSeconds = 0.0;

    bannerText = null;
    bannerTimer = 0.0;
    lockedTarget = null;

    isStarted = false;
    isPaused = false;
    isGameOver = false;

    _spawnTimer = 0.6; // Đợi một chút trước khi sinh mục tiêu đầu tiên
    notifyListeners();
  }

  void restart() {
    reset();
    isStarted = true;
    isPaused = false;
    isGameOver = false;
    _spawnInitialTargets();
    notifyListeners();
  }

  void start() {
    isStarted = true;
    isPaused = false;
    isGameOver = false;
    _spawnInitialTargets();
    notifyListeners();
  }

  void togglePause() {
    if (!isStarted || isGameOver) return;
    isPaused = !isPaused;
    notifyListeners();
  }

  void _spawnInitialTargets() {
    _spawnTarget(initialYOffset: 0.1);
    if (level > 1 || !isLettersOnly) {
      _spawnTarget(initialYOffset: 0.35);
    }
  }

  /// Cập nhật vật lý 60fps từ ticker
  void update(double dt) {
    if (!isStarted) return;

    // Cập nhật các vì sao dù game đang tạm dừng hay đang chơi để không gian luôn sống động
    for (final s in stars) {
      s.update(dt, width, playTop, playBottom);
    }

    if (isPaused || isGameOver) {
      notifyListeners();
      return;
    }

    elapsedSeconds += dt;

    // 1. Cập nhật chiến cơ (Tự trượt ngang theo targetShipX & hiệu ứng lửa phản lực)
    if (lockedTarget != null && !lockedTarget!.isDestroyed && !lockedTarget!.hasBreached) {
      targetShipX = lockedTarget!.x;
    }
    final diffX = targetShipX - shipX;
    shipX += diffX * min(1.0, 14.0 * dt);
    shipX = shipX.clamp(35.0, width - 35.0);
    shipY = playBottom - 50.0;

    // Ngẫu nhiên độ dài ngọn lửa phản lực phụt ra từ đuôi
    engineFlame = 15.0 + _random.nextDouble() * 12.0;

    if (shipInvulTimer > 0) {
      shipInvulTimer = max(0, shipInvulTimer - dt);
    }

    // Tự hồi phục nhẹ Khiên & Năng lượng theo thời gian
    shield = min(100.0, shield + 3.0 * dt);
    energy = min(100.0, energy + 25.0 * dt);

    // Banner hiển thị
    if (bannerTimer > 0) {
      bannerTimer = max(0, bannerTimer - dt);
      if (bannerTimer == 0) bannerText = null;
    }

    // 2. Cập nhật sinh thiên thạch / mục tiêu mới theo cấp độ khó
    _spawnTimer -= dt;
    final maxConcurrent = switch (difficulty) {
      GameDifficulty.easy => min(3, 1 + level),
      GameDifficulty.medium => min(5, 2 + level),
      GameDifficulty.hard => min(6, 3 + level),
    };
    final activeCount = asteroids.where((a) => !a.isDestroyed).length;

    if (_spawnTimer <= 0 && activeCount < maxConcurrent) {
      _spawnTarget();
      final baseInterval = switch (difficulty) {
        GameDifficulty.easy => max(2.0, 4.4 - (level * 0.3)),
        GameDifficulty.medium => max(1.3, 3.4 - (level * 0.35)),
        GameDifficulty.hard => max(0.9, 2.5 - (level * 0.4)),
      };
      _spawnTimer = baseInterval * (0.8 + _random.nextDouble() * 0.4);
    }

    // 3. Cập nhật chuyển động của các thiên thạch
    final dangerLineY = playBottom - 26.0;
    for (final ast in asteroids) {
      if (ast.isDestroyed || ast.hasBreached) continue;
      ast.update(dt, width, 30.0, width - 30.0);

      // Chạm phòng tuyến bảo vệ đáy màn hình (vạch đỏ)
      if (ast.y >= dangerLineY) {
        _handleDefenseBreached(ast);
      }
    }

    // 4. Cập nhật đạn laze
    for (final b in bullets) {
      if (b.hasHit) continue;
      b.update(dt);

      // Đạn bay trúng hoặc vượt qua mục tiêu
      if (b.y <= b.targetY || b.y <= playTop) {
        b.hasHit = true;
        _createParticles(b.x, b.y, const Color(0xFF70B4FF), count: 6);
      }
    }

    // 5. Cập nhật hạt vụ nổ
    for (final p in particles) {
      p.update(dt);
    }

    // 6. Dọn dẹp đối tượng đã hoàn thành/hết hạn
    asteroids.removeWhere((a) => (a.isDestroyed || a.hasBreached) && a.errorShakeTimer <= 0);
    bullets.removeWhere((b) => b.hasHit || b.y < playTop - 20);
    particles.removeWhere((p) => p.life <= 0);

    // Kiểm tra target đang khóa có còn tồn tại không
    if (lockedTarget != null && (lockedTarget!.isDestroyed || lockedTarget!.hasBreached)) {
      lockedTarget = null;
    }

    notifyListeners();
  }

  void _spawnTarget({double initialYOffset = 0.0}) {
    String text;
    String meaning = '';
    WordModel? word;

    if (isLettersOnly) {
      // Chế độ luyện gõ phím cơ bản: Chữ cái đơn A-Z hoặc cụm 2 chữ
      const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      if (level <= 2) {
        text = alphabet[_random.nextInt(alphabet.length)];
      } else {
        // Cấp độ cao hơn: từ 2-3 ký tự
        final len = _random.nextBool() ? 2 : 1;
        final buffer = StringBuffer();
        for (int i = 0; i < len; i++) {
          buffer.write(alphabet[_random.nextInt(alphabet.length)]);
        }
        text = buffer.toString();
      }
    } else {
      // Chế độ từ vựng tiếng Anh
      if (wordPool.isNotEmpty) {
        word = wordPool[_wordPoolIndex % wordPool.length];
        _wordPoolIndex++;
        text = word.term.trim().toUpperCase();
        meaning = word.meaning.trim();
      } else {
        const fallbacks = ['STAR', 'SPACE', 'GALAXY', 'PLANET', 'ROCKET', 'COMET', 'MOON'];
        text = fallbacks[_random.nextInt(fallbacks.length)];
        meaning = 'Không gian';
      }
    }

    final spawnX = 50.0 + _random.nextDouble() * max(50.0, width - 100.0);
    final spawnY = playTop - 10.0 + (initialYOffset * (playBottom - playTop) * 0.4);

    final speedMultiplier = switch (difficulty) {
      GameDifficulty.easy => 0.8,
      GameDifficulty.medium => 1.15,
      GameDifficulty.hard => 1.55,
    };

    final asteroid = AsteroidTarget.create(
      id: '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}',
      text: text,
      meaning: meaning,
      wordModel: word,
      x: spawnX,
      y: spawnY,
      levelSpeedBonus: (level - 1) * 1.5,
      speedMultiplier: speedMultiplier,
      random: _random,
    );

    asteroids.add(asteroid);
  }

  /// Xử lý khi thiên thạch đâm xuyên phòng tuyến đáy (vạch đỏ)
  void _handleDefenseBreached(AsteroidTarget target) {
    target.hasBreached = true;
    target.isDestroyed = true;

    if (target.wordModel != null &&
        !missedWords.any((w) => w.id == target.wordModel!.id)) {
      missedWords.add(target.wordModel!);
    }

    _createParticles(target.x, target.y, const Color(0xFFEF4444), count: 24, maxRadius: 5.0);

    // Trừ chính xác 1 HP khi mục tiêu lọt đáy vạch đỏ
    shipInvulTimer = 1.2;
    health = max(0, health - 1);
    shield = max(0.0, shield - 25.0);

    streak = 0;
    if (lockedTarget == target) {
      lockedTarget = null;
    }

    onPlayerHit?.call();

    if (health <= 0) {
      health = 0;
      isGameOver = true;
      onGameOver?.call();
    }
  }

  /// Nhận phím gõ từ bàn phím người chơi (Web / Desktop / Mobile)
  bool handleKeyInput(String inputChar) {
    if (!isStarted || isPaused || isGameOver) return false;
    if (inputChar.isEmpty) return false;

    final char = inputChar.toUpperCase();
    totalKeystrokes++;

    final dangerLineY = playBottom - 26.0;

    // TRƯỜNG HỢP 1: Đang khóa một từ mục tiêu
    if (lockedTarget != null) {
      final target = lockedTarget!;
      if (target.isDestroyed || target.hasBreached) {
        lockedTarget = null;
      } else {
        final expected = target.nextChar?.toUpperCase();

        if (char == expected) {
          // Gõ đúng ký tự tiếp theo
          correctKeystrokes++;
          streak++;
          if (streak > maxStreak) maxStreak = streak;

          target.typedIndex++;
          // Tàu tự động căn ngang thẳng hàng dưới từ đang gõ
          targetShipX = target.x;

          // Bắn đạn laze lên mục tiêu
          _fireLaser(target);

          // Nếu đã gõ xong toàn bộ từ -> Thiên thạch nổ tung!
          if (target.typedIndex >= target.text.length) {
            _destroyAsteroid(target);
          }
          notifyListeners();
          return true;
        } else {
          // Gõ sai ký tự
          streak = 0;
          target.errorShakeTimer = 0.28;
          notifyListeners();
          return false;
        }
      }
    }

    // TRƯỜNG HỢP 2: Chưa khóa mục tiêu nào -> Tìm mục tiêu có chữ cái đầu khớp
    final candidates = asteroids.where((a) {
      if (a.isDestroyed || a.hasBreached || a.y >= dangerLineY) return false;
      return a.text.isNotEmpty && a.text[0].toUpperCase() == char;
    }).toList();

    if (candidates.isNotEmpty) {
      // Ưu tiên thiên thạch rơi gần đáy nhất (mối nguy hiểm lớn nhất)
      candidates.sort((a, b) => b.y.compareTo(a.y));
      final chosen = candidates.first;

      lockedTarget = chosen;
      chosen.isLocked = true;
      chosen.typedIndex = 1;

      correctKeystrokes++;
      streak++;
      if (streak > maxStreak) maxStreak = streak;

      targetShipX = chosen.x;
      _fireLaser(chosen);

      if (chosen.typedIndex >= chosen.text.length) {
        _destroyAsteroid(chosen);
      }
      notifyListeners();
      return true;
    } else {
      // Không có mục tiêu nào trên màn hình bắt đầu bằng ký tự này
      streak = 0;
      notifyListeners();
      return false;
    }
  }

  /// Hỗ trợ chuỗi nhập từ bàn phím ảo di động / IME
  void handleTextInput(String text) {
    if (!isStarted || isPaused || isGameOver || text.isEmpty) return;
    for (int i = 0; i < text.length; i++) {
      handleKeyInput(text[i]);
    }
  }

  void _fireLaser(AsteroidTarget target) {
    energy = max(0.0, energy - 5.0);
    bullets.add(SpaceLaserBullet(
      x: shipX,
      y: shipY - 26.0,
      startX: shipX,
      startY: shipY - 26.0,
      targetX: target.x,
      targetY: target.y,
      targetId: target.id,
      vy: -800.0,
    ));
    _createParticles(shipX, shipY - 26.0, const Color(0xFF70B4FF), count: 3, maxRadius: 2.0);
  }

  void _destroyAsteroid(AsteroidTarget target) {
    if (target.hasBreached) return;
    target.isDestroyed = true;
    wordsDestroyedCount++;
    targetsDestroyed++;

    // Thưởng điểm theo độ cao và combo
    final heightBonus = ((playBottom - target.y) / 8.0).toInt().clamp(10, 60);
    final comboBonus = min(100, streak * 5);
    final gainedScore = 50 + (level * 15) + heightBonus + comboBonus;
    score += gainedScore;

    // Hiệu ứng nổ hạt hoành tráng phong cách Pygame
    _createParticles(target.x, target.y, const Color(0xFFA8A29E), count: 18);
    _createParticles(target.x, target.y, const Color(0xFFFFC828), count: 10, maxRadius: 4.5);
    _createParticles(target.x, target.y, const Color(0xFF38BDF8), count: 8, maxRadius: 3.5);

    onWordCompleted?.call(target.wordModel, target.text);

    // Kiểm tra lên cấp độ
    if (targetsDestroyed >= targetsToNextLevel) {
      _levelUp();
    }

    if (lockedTarget == target) {
      lockedTarget = null;
    }
  }

  void _levelUp() {
    level++;
    targetsDestroyed = 0;
    targetsToNextLevel = 8 + level * 4;
    score += 500;
    shield = 100.0;
    health = min(5, health + 1);

    bannerText = 'LEVEL $level!';
    bannerTimer = 2.4;

    _createParticles(width * 0.5, playTop + 150.0, const Color(0xFFAA6EFF), count: 40, maxRadius: 5.5);
    onLevelUp?.call();
  }

  void _createParticles(double x, double y, Color color, {int count = 15, double maxRadius = 3.5}) {
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 40.0 + _random.nextDouble() * 160.0;
      final life = 0.3 + _random.nextDouble() * 0.5;

      particles.add(SpaceParticle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        life: life,
        color: color,
        initialRadius: maxRadius,
      ));
    }
  }

  /// Tính WPM (Words Per Minute)
  int get wordsPerMinute {
    if (elapsedSeconds <= 0) return 0;
    final minutes = max(1.0, elapsedSeconds) / 60.0;
    return ((correctKeystrokes / 5.0) / minutes).round();
  }

  /// Tính độ chính xác (%)
  double get accuracy {
    if (totalKeystrokes == 0) return 100.0;
    return (correctKeystrokes / totalKeystrokes * 100.0).clamp(0.0, 100.0);
  }
}
