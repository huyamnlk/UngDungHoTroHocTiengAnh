import 'package:flutter/material.dart';
import '../logic/space_game_engine.dart';
import 'space_radar_widget.dart';

/// Thanh trạng thái phía trên (Top HUD)
class SpaceTopHud extends StatelessWidget {
  final SpaceGameEngine engine;
  final VoidCallback onBack;
  final VoidCallback onTogglePause;

  const SpaceTopHud({
    super.key,
    required this.engine,
    required this.onBack,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF080A1C),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF284682), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nút thoát / Quay lại
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            tooltip: 'Thoát trò chơi',
            onPressed: onBack,
          ),
          const SizedBox(width: 4),

          // Điểm số (SCORE)
          _buildInfoBox(
            label: 'SCORE',
            value: '${engine.score}',
            color: const Color(0xFFFFC828),
          ),
          const SizedBox(width: 8),

          // Máu & Khiên (HP / SHIELD)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1630),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF284682), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Lượt tim HP
                  Row(
                    children: List.generate(5, (index) {
                      final hasHeart = index < engine.health;
                      return Icon(
                        hasHeart ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: hasHeart ? const Color(0xFFEF4444) : const Color(0xFF475569),
                        size: 15,
                      );
                    }),
                  ),
                  const SizedBox(width: 6),
                  // Thanh khiên %
                  Row(
                    children: [
                      const Text(
                        'SHD',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 42,
                        height: 7,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (engine.shield / 100.0).clamp(0.0, 1.0),
                            backgroundColor: const Color(0xFF1E293B),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Cấp độ khó (ĐỘ KHÓ)
          _buildInfoBox(
            label: 'ĐỘ KHÓ',
            value: engine.difficulty.label,
            color: engine.difficulty.color,
          ),
          const SizedBox(width: 8),

          // Cấp độ (LEVEL)
          _buildInfoBox(
            label: 'LEVEL',
            value: '${engine.level}',
            color: const Color(0xFFAA6EFF),
          ),
          const SizedBox(width: 8),

          // Nút Tạm dừng
          IconButton(
            icon: Icon(
              engine.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: const Color(0xFFFFC828),
              size: 24,
            ),
            tooltip: engine.isPaused ? 'Tiếp tục' : 'Tạm dừng',
            onPressed: onTogglePause,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1630),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF284682), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bảng điều khiển, trạng thái tàu chiến và Radar phía dưới (Bottom Panel)
class SpaceBottomControlPanel extends StatelessWidget {
  final SpaceGameEngine engine;
  final VoidCallback? onOpenKeyboard;

  const SpaceBottomControlPanel({
    super.key,
    required this.engine,
    this.onOpenKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 114,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF080A1C),
        border: Border(
          top: BorderSide(color: Color(0xFF284682), width: 1.2),
        ),
      ),
      child: Row(
        children: [
          // Khung 1: NHIỆM VỤ / THỐNG KÊ (MISSIONS)
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1630),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF284682), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'MISSIONS',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Lv.${engine.level}',
                        style: const TextStyle(
                          color: Color(0xFFAA6EFF),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _buildMissionLine(
                    'Phá hủy mục tiêu',
                    '${engine.targetsDestroyed}/${engine.targetsToNextLevel}',
                    isComplete: engine.targetsDestroyed >= engine.targetsToNextLevel,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WPM: ${engine.wordsPerMinute}',
                        style: const TextStyle(color: Color(0xFF3CDC5A), fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Chuỗi: x${engine.streak}',
                        style: const TextStyle(color: Color(0xFFFFC828), fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Khung 2: HỆ THỐNG TÀU (STATUS BARS)
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1630),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF284682), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'STATUS',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  _buildStatusBar('HP', engine.health / 5.0, const Color(0xFFEF4444)),
                  _buildStatusBar('SHD', (engine.shield / 100.0).clamp(0.0, 1.0), const Color(0xFF38BDF8)),
                  _buildStatusBar('NRG', (engine.energy / 100.0).clamp(0.0, 1.0), const Color(0xFFFFC828)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Khung 3: RADAR MINI-MAP
          Container(
            width: 84,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1630),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF284682), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'RADAR',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                SpaceRadarWidget(engine: engine, size: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionLine(String title, String progress, {bool isComplete = false}) {
    return Row(
      children: [
        Icon(
          isComplete ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: isComplete ? const Color(0xFF3CDC5A) : const Color(0xFF94A3B8),
          size: 13,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Color(0xFFF0F0FA), fontSize: 10.5),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          progress,
          style: TextStyle(
            color: isComplete ? const Color(0xFF3CDC5A) : const Color(0xFFFFC828),
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar(String label, double ratio, Color barColor) {
    return Row(
      children: [
        SizedBox(
          width: 26,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
