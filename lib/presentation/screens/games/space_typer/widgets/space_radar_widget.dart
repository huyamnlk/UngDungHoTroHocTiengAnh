import 'dart:math';
import 'package:flutter/material.dart';
import '../logic/space_game_engine.dart';

/// Radar Mini-Map hiển thị vị trí tương quan của chiến cơ và các thiên thạch
class SpaceRadarWidget extends StatelessWidget {
  final SpaceGameEngine engine;
  final double size;

  const SpaceRadarWidget({
    super.key,
    required this.engine,
    this.size = 84.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarPainter(engine: engine),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final SpaceGameEngine engine;

  _RadarPainter({required this.engine}) : super(repaint: engine);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final center = Offset(cx, cy);
    final r = (min(size.width, size.height) * 0.5) - 3.0;

    // Nền radar xanh thẳm
    final bgPaint = Paint()
      ..color = const Color(0xFF0A1E32)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r, bgPaint);

    // Vòng tròn viền và vòng đo cự ly bên trong
    final edgePaint = Paint()
      ..color = const Color(0xFF284682)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, r, edgePaint);
    canvas.drawCircle(center, r * 0.5, edgePaint);

    // Đường chữ thập ngắm
    canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), edgePaint);
    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), edgePaint);

    final playW = engine.width > 0 ? engine.width : 480.0;
    final playH = max(100.0, engine.playBottom - engine.playTop);

    // Chấm các thiên thạch mục tiêu
    for (final ast in engine.asteroids) {
      if (ast.isDestroyed) continue;

      final relX = ((ast.x - engine.shipX) / playW) * (r * 1.8);
      final relY = ((ast.y - engine.shipY) / playH) * (r * 1.8);

      final dotPos = Offset(cx + relX, cy + relY);
      if ((dotPos - center).distance <= r - 2.0) {
        final dotPaint = Paint()
          ..color = ast.isLocked ? const Color(0xFFFFC828) : const Color(0xFF38BDF8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(dotPos, 2.4, dotPaint);
      }
    }

    // Chấm xanh lá đại diện cho chiến cơ người chơi ở tâm/đáy
    final shipDotPaint = Paint()
      ..color = const Color(0xFF3CDC5A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.2, shipDotPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => true;
}
