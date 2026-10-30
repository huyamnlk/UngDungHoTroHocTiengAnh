import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../data/models/game_record_model.dart';
import '../../../../data/models/word_model.dart';
import '../../../../providers/games_provider.dart';
import '../../../widgets/custom_button.dart';
import '../common/game_difficulty.dart';
import 'logic/space_game_engine.dart';
import 'rendering/space_game_painter.dart';
import 'widgets/space_hud_panel.dart';

/// Màn hình trò chơi luyện gõ tốc độ vũ trụ (Space Typer)
/// Lấy cảm hứng từ cơ chế đồ họa và tàu vũ trụ trong file Python test.py
class SpaceTyperScreen extends StatefulWidget {
  final List<WordModel> words;
  final String topicName;
  final int? topicId;
  final String level;
  final bool initialLettersOnly;

  const SpaceTyperScreen({
    super.key,
    required this.words,
    this.topicName = 'Tất cả chủ đề',
    this.topicId,
    this.level = 'All',
    this.initialLettersOnly = false,
  });

  @override
  State<SpaceTyperScreen> createState() => _SpaceTyperScreenState();
}

class _SpaceTyperScreenState extends State<SpaceTyperScreen>
    with SingleTickerProviderStateMixin {
  late final SpaceGameEngine _engine;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  final FocusNode _keyboardFocusNode = FocusNode();
  final FocusNode _mobileInputFocusNode = FocusNode();
  final TextEditingController _mobileTextController = TextEditingController();
  final TtsService _ttsService = TtsService();

  GameDifficulty _difficulty = GameDifficulty.medium;
  bool _isLettersMode = false;
  final bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _isLettersMode = widget.initialLettersOnly;
    _engine = SpaceGameEngine();

    // Đăng ký callbacks
    _engine.onWordCompleted = (word, text) {
      HapticFeedback.lightImpact();
      if (_soundEnabled) {
        _ttsService.stop();
        _ttsService.speak(text);
      }
    };

    _engine.onPlayerHit = () {
      HapticFeedback.heavyImpact();
    };

    _engine.onLevelUp = () {
      HapticFeedback.mediumImpact();
    };

    _engine.onGameOver = () {
      HapticFeedback.heavyImpact();
      _saveGameRecord();
    };

    // Khởi tạo Ticker 60fps chuẩn Flutter thay thế cho vòng lặp pygame.Clock
    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      final dtSeconds = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;

      // Giới hạn dt tối đa 0.05s để chuyển động mượt mà không bị nhảy bước
      final clampedDt = dtSeconds.clamp(0.001, 0.05);
      _engine.update(clampedDt);
    });

    _ticker.start();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    _engine.dispose();
    _keyboardFocusNode.dispose();
    _mobileInputFocusNode.dispose();
    _mobileTextController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  void _saveGameRecord() {
    final provider = context.read<GamesProvider>();
    final record = GameRecordModel(
      gameType: 'space_typer',
      topicId: widget.topicId,
      topicName: widget.topicName,
      level: '${widget.level} (${_difficulty.label})',
      score: _engine.score,
      highStreak: _engine.maxStreak,
      totalItems: _engine.wordsDestroyedCount + _engine.missedWords.length,
      correctItems: _engine.wordsDestroyedCount,
      accuracy: _engine.accuracy,
      durationSeconds: _engine.elapsedSeconds.round(),
      completedAt: DateTime.now().toIso8601String(),
    );
    provider.recordGameResult(record);
  }

  void _startGame() {
    _engine.init(
      newWidth: _engine.width,
      newHeight: _engine.height,
      newPlayTop: 64.0,
      newPlayBottom: _engine.height - 114.0,
      words: widget.words,
      lettersOnlyMode: _isLettersMode,
      gameDifficulty: _difficulty,
    );
    _engine.start();
    _keyboardFocusNode.requestFocus();
  }

  void _restartGame() {
    _engine.isLettersOnly = _isLettersMode;
    _engine.difficulty = _difficulty;
    _engine.restart();
    _keyboardFocusNode.requestFocus();
  }

  /// Xử lý phím từ phần cứng (Desktop / Web / Mobile có bàn phím vật lý)
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // Phím Escape: Thoát
    if (key == LogicalKeyboardKey.escape) {
      Navigator.maybePop(context);
      return KeyEventResult.handled;
    }

    // Phím R: Chơi lại khi Game Over
    if (key == LogicalKeyboardKey.keyR && _engine.isGameOver) {
      _restartGame();
      return KeyEventResult.handled;
    }

    // Khi Game Over: chặn tất cả thao tác gameplay khác
    if (_engine.isGameOver) {
      return KeyEventResult.ignored;
    }

    if (_engine.isPaused || !_engine.isStarted) {
      return KeyEventResult.ignored;
    }

    // Nhận diện ký tự: Ưu tiên event.character, fallback sang keyLabel / space / hyphen
    String? char = event.character;
    if (char == null || char.isEmpty) {
      if (key.keyLabel.length == 1) {
        char = key.keyLabel;
      } else if (key == LogicalKeyboardKey.space) {
        char = ' ';
      } else if (key == LogicalKeyboardKey.minus) {
        char = '-';
      }
    }

    if (char != null && char.isNotEmpty) {
      final handled = _engine.handleKeyInput(char);
      return handled ? KeyEventResult.handled : KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  /// Xử lý text thay đổi từ trường nhập ảo (Mobile virtual keyboard)
  void _onMobileInputChanged(String val) {
    if (val.isEmpty || _engine.isGameOver || _engine.isPaused || !_engine.isStarted) return;
    _mobileTextController.clear();
    _engine.handleTextInput(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C20),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Focus(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (!_mobileInputFocusNode.hasFocus) {
                _mobileInputFocusNode.requestFocus();
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                const topHudH = 64.0;
                const bottomPanelH = 114.0;
                const playTop = topHudH;
                final playBottom = h - bottomPanelH;

                // Đồng bộ kích thước màn chơi vào Engine
                _engine.resize(w, h, playTop, playBottom);

                return ListenableBuilder(
                  listenable: _engine,
                  builder: (context, _) {
                    return Stack(
                      children: [
                        // 1. Tranh vẽ không gian vũ trụ CustomPainter 60fps
                        Positioned.fill(
                          child: CustomPaint(
                            painter: SpaceGamePainter(engine: _engine),
                          ),
                        ),

                        // 2. Thanh trạng thái trên cùng (Top HUD)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: topHudH,
                          child: SpaceTopHud(
                            engine: _engine,
                            onBack: () => _confirmExit(context),
                            onTogglePause: () => _engine.togglePause(),
                          ),
                        ),

                        // 3. Bảng điều khiển và Radar phía dưới (Bottom Panel)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: bottomPanelH,
                          child: SpaceBottomControlPanel(
                            engine: _engine,
                            onOpenKeyboard: () => _mobileInputFocusNode.requestFocus(),
                          ),
                        ),

                        // 4. Trường nhập vô hình hỗ trợ bàn phím ảo trên điện thoại (Mobile Soft Keyboard)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Opacity(
                            opacity: 0.0,
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: TextField(
                                controller: _mobileTextController,
                                focusNode: _mobileInputFocusNode,
                                autocorrect: false,
                                enableSuggestions: false,
                                textCapitalization: TextCapitalization.characters,
                                keyboardType: TextInputType.text,
                                onChanged: _onMobileInputChanged,
                              ),
                            ),
                          ),
                        ),

                        // 5. Nút gợi ý chạm để kích hoạt bàn phím trên thiết bị di động
                        if (_engine.isStarted && !_engine.isGameOver && !_engine.isPaused)
                          Positioned(
                            right: 12,
                            bottom: bottomPanelH + 8,
                            child: Material(
                              color: const Color(0xCC0E1630),
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => _mobileInputFocusNode.requestFocus(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF284682)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.keyboard_rounded, color: Color(0xFF38BDF8), size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'Bàn phím',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // 6. Overlay: Màn hình Bắt đầu (Start Menu)
                        if (!_engine.isStarted)
                          _buildStartOverlay(context, constraints),

                        // 7. Overlay: Tạm dừng (Paused)
                        if (_engine.isStarted && _engine.isPaused && !_engine.isGameOver)
                          _buildPauseOverlay(context),

                        // 8. Overlay: Kết thúc (Game Over)
                        if (_engine.isGameOver)
                          _buildGameOverOverlay(context, constraints),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Màn hình giới thiệu và bắt đầu trò chơi
  Widget _buildStartOverlay(BuildContext context, BoxConstraints constraints) {
    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1630),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF284682), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF38BDF8)),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF38BDF8), size: 36),
                ),
                const SizedBox(height: 12),
                const Text(
                  'CHIẾN CƠ VŨ TRỤ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFC828),
                    letterSpacing: 1.5,
                  ),
                ),
                const Text(
                  'SPACE SPEED TYPER',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF38BDF8),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF080A1C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF284682)),
                  ),
                  child: const Column(
                    children: [
                      _InstructionRow(
                        icon: Icons.track_changes_rounded,
                        text: 'Tàu tự di chuyển thẳng hàng dưới từ đang gõ.',
                      ),
                      SizedBox(height: 8),
                      _InstructionRow(
                        icon: Icons.bolt_rounded,
                        text: 'Gõ đúng ký tự sẽ bắn laze phá hủy thiên thạch.',
                      ),
                      SizedBox(height: 8),
                      _InstructionRow(
                        icon: Icons.shield_rounded,
                        text: 'Bảo vệ phòng tuyến không để thiên thạch chạm đáy!',
                      ),
                      SizedBox(height: 8),
                      _InstructionRow(
                        icon: Icons.pause_circle_outline_rounded,
                        text: 'Dùng nút tạm dừng ở góc màn hình khi cần nghỉ ngơi.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Chọn Độ khó: Dễ / Trung bình / Khó
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ĐỘ KHÓ THỬ THÁCH:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: GameDifficulty.values.map((diff) {
                    final isSel = _difficulty == diff;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _difficulty = diff),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                          decoration: BoxDecoration(
                            color: isSel ? diff.color.withValues(alpha: 0.22) : const Color(0xFF080A1C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? diff.color : const Color(0xFF284682),
                              width: isSel ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(diff.icon, color: isSel ? diff.color : const Color(0xFF64748B), size: 20),
                              const SizedBox(height: 4),
                              Text(
                                diff.label,
                                style: TextStyle(
                                  color: isSel ? diff.color : Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                diff == GameDifficulty.easy
                                    ? '3-5 chữ'
                                    : (diff == GameDifficulty.medium ? '5-8 chữ' : '>8 chữ'),
                                style: TextStyle(
                                  color: isSel ? diff.color.withValues(alpha: 0.85) : const Color(0xFF64748B),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Lựa chọn chế độ chơi: Từ vựng vs Chữ cái đơn
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Từ vựng tiếng Anh')),
                        selected: !_isLettersMode,
                        onSelected: (val) {
                          if (val) setState(() => _isLettersMode = false);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Chữ cái A-Z')),
                        selected: _isLettersMode,
                        onSelected: (val) {
                          if (val) setState(() => _isLettersMode = true);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                CustomButton(
                  text: 'BẮT ĐẦU CHIẾN ĐẤU (${_difficulty.label})',
                  icon: Icons.play_arrow_rounded,
                  backgroundColor: const Color(0xFF38BDF8),
                  textColor: const Color(0xFF0A0C20),
                  onPressed: _startGame,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Màn hình tạm dừng
  Widget _buildPauseOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1630),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF284682), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_rounded, color: Color(0xFFFFC828), size: 48),
              const SizedBox(height: 12),
              const Text(
                'PAUSED',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFC828),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chọn nút bên dưới để tiếp tục chơi',
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    label: const Text('Chơi lại (R)', style: TextStyle(color: Colors.white)),
                    onPressed: _restartGame,
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF0A0C20),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Tiếp tục'),
                    onPressed: () {
                      _engine.togglePause();
                      _keyboardFocusNode.requestFocus();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Màn hình kết thúc trò chơi (Game Over)
  Widget _buildGameOverOverlay(BuildContext context, BoxConstraints constraints) {
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1630),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 42),
                const SizedBox(height: 8),
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFEF4444),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Phòng tuyến căn cứ vũ trụ đã bị xuyên thủng!',
                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12.5),
                ),
                const SizedBox(height: 18),

                // Bảng thống kê kết quả
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF080A1C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF284682)),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow('Độ khó thử thách:', _difficulty.label, _difficulty.color),
                      const Divider(color: Color(0xFF1E293B)),
                      _buildStatRow('Điểm số đạt được:', '${_engine.score} đ', const Color(0xFFFFC828)),
                      const Divider(color: Color(0xFF1E293B)),
                      _buildStatRow('Cấp độ chinh phục:', 'Level ${_engine.level}', const Color(0xFFAA6EFF)),
                      const Divider(color: Color(0xFF1E293B)),
                      _buildStatRow('Tốc độ gõ (WPM):', '${_engine.wordsPerMinute} wpm', const Color(0xFF3CDC5A)),
                      const Divider(color: Color(0xFF1E293B)),
                      _buildStatRow('Độ chính xác:', '${_engine.accuracy.toStringAsFixed(1)}%', const Color(0xFF38BDF8)),
                      const Divider(color: Color(0xFF1E293B)),
                      _buildStatRow('Chuỗi đúng tối đa:', 'x${_engine.maxStreak}', const Color(0xFFFFC828)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Danh sách từ bị bỏ lỡ (nếu có)
                if (_engine.missedWords.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Từ vựng cần ôn lại (${_engine.missedWords.length}):',
                      style: const TextStyle(
                        color: Color(0xFFF0F0FA),
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 110),
                    decoration: BoxDecoration(
                      color: const Color(0xFF080A1C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF284682)),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _engine.missedWords.length,
                      itemBuilder: (ctx, idx) {
                        final w = _engine.missedWords[idx];
                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            w.term,
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            w.meaning,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 18),
                            onPressed: () => _ttsService.speak(w.term),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.maybePop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF284682)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Thoát'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: const Color(0xFF0A0C20),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Chơi lại (R)', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: _restartGame,
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

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5)),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    if (!_engine.isStarted || _engine.isGameOver) {
      Navigator.maybePop(context);
      return;
    }

    _engine.isPaused = true;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E1630),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF284682)),
        ),
        title: const Text('Rời khỏi trận chiến?', style: TextStyle(color: Colors.white, fontSize: 17)),
        content: const Text(
          'Tiến trình trận đấu hiện tại sẽ bị dừng lại. Bạn có chắc muốn thoát?',
          style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _engine.isPaused = false;
              _keyboardFocusNode.requestFocus();
            },
            child: const Text('Tiếp tục chơi', style: TextStyle(color: Color(0xFF38BDF8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              _saveGameRecord();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Thoát game', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF38BDF8), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12.5, height: 1.3),
          ),
        ),
      ],
    );
  }
}
