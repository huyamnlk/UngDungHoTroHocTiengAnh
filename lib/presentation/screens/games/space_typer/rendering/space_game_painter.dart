import 'dart:math';
import 'package:flutter/material.dart';
import '../logic/space_game_engine.dart';
import '../models/space_models.dart';

/// CustomPainter vẽ toàn bộ không gian vũ trụ, hành tinh, sao, tàu chiến, đạn và hiệu ứng nổ
class SpaceGamePainter extends CustomPainter {
  final SpaceGameEngine engine;

  SpaceGamePainter({required this.engine}) : super(repaint: engine);

  @override
  void paint(Canvas canvas, Size size) {
    final clipRect = Rect.fromLTWH(0, engine.playTop, size.width, engine.playBottom - engine.playTop);
    canvas.save();
    canvas.clipRect(clipRect);

    // 1. Nền không gian tối sâu thẳm
    canvas.drawRect(
      clipRect,
      Paint()..color = const Color(0xFF0A0C20),
    );

    // 2. Vẽ các hành tinh nền (Blue planet & Red planet)
    _drawPlanets(canvas, size);

    // 3. Vẽ 3 lớp sao chuyển động (Parallax Stars)
    _drawStars(canvas);

    // 4. Vẽ phòng tuyến bảo vệ đáy (Laser defense line)
    _drawDefenseLine(canvas, size);

    // 5. Vẽ các thiên thạch / từ vựng mục tiêu
    _drawAsteroids(canvas);

    // 6. Vẽ các tia đạn laze đang bay
    _drawBullets(canvas);

    // 7. Vẽ chiến cơ người chơi (Spaceship Fighter)
    _drawPlayerShip(canvas);

    // 8. Vẽ các hạt vụ nổ (Particles)
    _drawParticles(canvas);

    // 9. Vẽ banner thông báo Level nếu có
    if (engine.bannerText != null) {
      _drawBanner(canvas, size, engine.bannerText!);
    }

    canvas.restore();
  }

  void _drawPlanets(Canvas canvas, Size size) {
    for (final planet in engine.planets) {
      final center = Offset(size.width * planet.relativeX, size.height * planet.relativeY);

      // Quầng sáng khí quyển hành tinh
      final atmospherePaint = Paint()
        ..color = planet.primaryColor.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(center, planet.radius + 12, atmospherePaint);

      // Nếu có vành đai, vẽ nửa sau vành đai trước
      if (planet.hasRing) {
        final ringRect = Rect.fromCenter(
          center: center,
          width: planet.radius * 2.8,
          height: planet.radius * 0.8,
        );
        final ringPaint = Paint()
          ..color = planet.ringColor.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0;
        canvas.drawArc(ringRect, pi, pi, false, ringPaint);
      }

      // Thân hành tinh với hiệu ứng đổ bóng cầu
      final planetPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          radius: 0.85,
          colors: [
            planet.ringColor.withValues(alpha: 0.9),
            planet.primaryColor,
            const Color(0xFF020617),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: planet.radius));

      canvas.drawCircle(center, planet.radius, planetPaint);

      // Vành đai nửa trước hành tinh
      if (planet.hasRing) {
        final ringRect = Rect.fromCenter(
          center: center,
          width: planet.radius * 2.8,
          height: planet.radius * 0.8,
        );
        final ringPaint = Paint()
          ..color = planet.ringColor.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0;
        canvas.drawArc(ringRect, 0, pi, false, ringPaint);
      }
    }
  }

  void _drawStars(Canvas canvas) {
    for (final s in engine.stars) {
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(s.x, s.y), s.radius, paint);

      // Lớp sao gần có ánh sáng nhẹ
      if (s.layer == 3) {
        final glow = Paint()
          ..color = s.color.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawCircle(Offset(s.x, s.y), s.radius * 1.8, glow);
      }
    }
  }

  void _drawDefenseLine(Canvas canvas, Size size) {
    final lineY = engine.playBottom - 26.0;
    const baseColor = Color(0xFFEF4444);

    // Ánh sáng ranh giới phòng thủ (Vạch đỏ bảo vệ căn cứ)
    final glowPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.5)
      ..strokeWidth = 5.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY), glowPaint);

    final linePaint = Paint()
      ..color = baseColor.withValues(alpha: 0.9)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY), linePaint);
  }

  void _drawAsteroids(Canvas canvas) {
    for (final ast in engine.asteroids) {
      if (ast.isDestroyed) continue;

      double drawX = ast.x;
      double drawY = ast.y;

      // Hiệu ứng rung đỏ khi gõ sai ký tự
      if (ast.errorShakeTimer > 0) {
        final shake = sin(ast.errorShakeTimer * 35) * 5.0;
        drawX += shake;
      }

      final center = Offset(drawX, drawY);

      // Vòng tròn mục tiêu / hào quang khóa ngắm
      if (ast.isLocked) {
        final lockGlow = Paint()
          ..color = const Color(0xFFFFC828).withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(center, ast.radius + 6, lockGlow);

        final lockRing = Paint()
          ..color = const Color(0xFFFFC828)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
        canvas.drawCircle(center, ast.radius + 5, lockRing);

        // Các chốt ngắm 4 góc
        _drawReticleCorners(canvas, center, ast.radius + 9);
      } else if (ast.errorShakeTimer > 0) {
        final errGlow = Paint()
          ..color = const Color(0xFFEF4444).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(center, ast.radius + 5, errGlow);
      }

      // Vẽ đa giác thiên thạch (Asteroid Rock)
      final rockPath = Path();
      for (int i = 0; i < ast.contourPoints.length; i++) {
        final pt = ast.contourPoints[i];
        final rotCos = cos(ast.angle);
        final rotSin = sin(ast.angle);
        final rx = (pt.dx * rotCos - pt.dy * rotSin) * ast.radius;
        final ry = (pt.dx * rotSin + pt.dy * rotCos) * ast.radius;
        final px = drawX + rx;
        final py = drawY + ry;

        if (i == 0) {
          rockPath.moveTo(px, py);
        } else {
          rockPath.lineTo(px, py);
        }
      }
      rockPath.close();

      // Tô màu thiên thạch xám sẫm
      final rockFill = Paint()
        ..color = const Color(0xFF5F585A)
        ..style = PaintingStyle.fill;
      canvas.drawPath(rockPath, rockFill);

      // Viền nổi thiên thạch
      final rockBorder = Paint()
        ..color = const Color(0xFF968C8C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(rockPath, rockBorder);

      // Miệng núi lửa nhỏ trên thiên thạch
      canvas.drawCircle(
        Offset(drawX - ast.radius * 0.25, drawY - ast.radius * 0.2),
        max(3.0, ast.radius * 0.22),
        Paint()..color = const Color(0xFF464042),
      );

      // Vẽ nhãn từ vựng (Word / Letter Label)
      _drawWordLabel(canvas, ast, drawX, drawY);
    }
  }

  void _drawReticleCorners(Canvas canvas, Offset center, double r) {
    final paint = Paint()
      ..color = const Color(0xFFFFC828)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    const cornerLen = 6.0;
    // Góc trên trái
    canvas.drawLine(Offset(center.dx - r, center.dy - r + cornerLen), Offset(center.dx - r, center.dy - r), paint);
    canvas.drawLine(Offset(center.dx - r, center.dy - r), Offset(center.dx - r + cornerLen, center.dy - r), paint);
    // Góc trên phải
    canvas.drawLine(Offset(center.dx + r - cornerLen, center.dy - r), Offset(center.dx + r, center.dy - r), paint);
    canvas.drawLine(Offset(center.dx + r, center.dy - r), Offset(center.dx + r, center.dy - r + cornerLen), paint);
    // Góc dưới trái
    canvas.drawLine(Offset(center.dx - r, center.dy + r - cornerLen), Offset(center.dx - r, center.dy + r), paint);
    canvas.drawLine(Offset(center.dx - r, center.dy + r), Offset(center.dx - r + cornerLen, center.dy + r), paint);
    // Góc dưới phải
    canvas.drawLine(Offset(center.dx + r - cornerLen, center.dy + r), Offset(center.dx + r, center.dy + r), paint);
    canvas.drawLine(Offset(center.dx + r, center.dy + r), Offset(center.dx + r, center.dy + r - cornerLen), paint);
  }

  void _drawWordLabel(Canvas canvas, AsteroidTarget ast, double x, double y) {
    final spans = <TextSpan>[];

    for (int i = 0; i < ast.text.length; i++) {
      final char = ast.text[i];
      if (i < ast.typedIndex) {
        // Ký tự đã gõ đúng: Màu xanh ngọc rực rỡ
        spans.add(TextSpan(
          text: char,
          style: const TextStyle(
            color: Color(0xFF3CDC5A),
            fontWeight: FontWeight.w900,
            fontSize: 16,
            shadows: [
              Shadow(color: Color(0xFF3CDC5A), blurRadius: 8),
            ],
          ),
        ));
      } else if (i == ast.typedIndex && ast.isLocked) {
        // Ký tự đang chờ gõ tiếp theo: Màu vàng gạch chân nổi bật
        spans.add(TextSpan(
          text: char,
          style: const TextStyle(
            color: Color(0xFFFFC828),
            fontWeight: FontWeight.w900,
            fontSize: 17,
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFFFFC828),
            decorationThickness: 2.5,
            shadows: [
              Shadow(color: Color(0xFFFFC828), blurRadius: 10),
            ],
          ),
        ));
      } else {
        // Ký tự chưa gõ: Màu trắng sáng
        spans.add(TextSpan(
          text: char,
          style: const TextStyle(
            color: Color(0xFFF0F0FA),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ));
      }
    }

    final wordPainter = TextPainter(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
    )..layout();

    TextPainter? meaningPainter;
    if (ast.meaning.isNotEmpty && !engine.isLettersOnly) {
      meaningPainter = TextPainter(
        text: TextSpan(
          text: ast.meaning,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: 160);
    }

    final totalTextW = max(wordPainter.width, meaningPainter?.width ?? 0);
    final boxW = totalTextW + 18.0;
    final boxH = wordPainter.height + (meaningPainter != null ? meaningPainter.height + 4 : 8);

    final boxRect = Rect.fromCenter(
      center: Offset(x, y + ast.radius + (boxH * 0.5) + 4),
      width: boxW,
      height: boxH,
    );

    // Nền hộp chữ phong cách bảng điều khiển vũ trụ
    final bgPaint = Paint()
      ..color = const Color(0xEE0E1630)
      ..style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(boxRect, const Radius.circular(8));
    canvas.drawRRect(rrect, bgPaint);

    final borderPaint = Paint()
      ..color = ast.isLocked ? const Color(0xFFFFC828) : const Color(0xFF284682)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ast.isLocked ? 1.5 : 1.0;
    canvas.drawRRect(rrect, borderPaint);

    // Vẽ chữ tiếng Anh
    wordPainter.paint(
      canvas,
      Offset(boxRect.left + (boxRect.width - wordPainter.width) * 0.5, boxRect.top + 3),
    );

    // Vẽ nghĩa tiếng Việt
    if (meaningPainter != null) {
      meaningPainter.paint(
        canvas,
        Offset(boxRect.left + (boxRect.width - meaningPainter.width) * 0.5, boxRect.top + wordPainter.height + 2),
      );
    }
  }

  void _drawBullets(Canvas canvas) {
    for (final b in engine.bullets) {
      if (b.hasHit) continue;

      // Quầng sáng đạn laze
      final glowPaint = Paint()
        ..color = const Color(0xFF4696FF).withValues(alpha: 0.6)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(Offset(b.x, b.y), Offset(b.x, b.y + 18), glowPaint);

      // Lõi laser màu trắng xanh
      final corePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(b.x, b.y), Offset(b.x, b.y + 12), corePaint);
    }
  }

  void _drawPlayerShip(Canvas canvas) {
    // Nhấp nháy tàng hình khi vừa trúng đòn
    if (engine.shipInvulTimer > 0 && ((engine.shipInvulTimer * 12).toInt() % 2 == 0)) {
      return;
    }

    final x = engine.shipX;
    final y = engine.shipY;
    final flame = engine.engineFlame;

    // 1. Luồng lửa phản lực động cơ (Thruster Flames)
    final outerFlamePaint = Paint()
      ..color = const Color(0xFF5AAAFF)
      ..style = PaintingStyle.fill;
    final outerFlamePath = Path()
      ..moveTo(x - 7, y + 20)
      ..lineTo(x + 7, y + 20)
      ..lineTo(x, y + 20 + flame)
      ..close();
    canvas.drawPath(outerFlamePath, outerFlamePaint);

    final innerFlamePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final innerFlamePath = Path()
      ..moveTo(x - 3, y + 20)
      ..lineTo(x + 3, y + 20)
      ..lineTo(x, y + 20 + flame * 0.5)
      ..close();
    canvas.drawPath(innerFlamePath, innerFlamePaint);

    // 2. Hai cánh chiến cơ màu đỏ phong cách Pygame
    final wingPaint = Paint()
      ..color = const Color(0xFFBE4646)
      ..style = PaintingStyle.fill;

    // Cánh trái
    final leftWingPath = Path()
      ..moveTo(x - 30, y + 22)
      ..lineTo(x - 10, y - 4)
      ..lineTo(x - 10, y + 20)
      ..close();
    canvas.drawPath(leftWingPath, wingPaint);

    // Cánh phải
    final rightWingPath = Path()
      ..moveTo(x + 30, y + 22)
      ..lineTo(x + 10, y - 4)
      ..lineTo(x + 10, y + 20)
      ..close();
    canvas.drawPath(rightWingPath, wingPaint);

    // 3. Thân tàu chiến (Ship Hull)
    final hullPaint = Paint()
      ..color = const Color(0xFFD7DCEB)
      ..style = PaintingStyle.fill;

    final hullPath = Path()
      ..moveTo(x, y - 32)
      ..lineTo(x + 12, y - 4)
      ..lineTo(x + 12, y + 22)
      ..lineTo(x - 12, y + 22)
      ..lineTo(x - 12, y - 4)
      ..close();
    canvas.drawPath(hullPath, hullPaint);

    // Đường viền thân tàu
    final outlinePaint = Paint()
      ..color = const Color(0xFF96A0BE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(hullPath, outlinePaint);

    // 4. Buồng lái kính phát sáng (Cockpit)
    final cockpitPaint = Paint()
      ..color = const Color(0xFF3C8CE6)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y - 6), width: 10, height: 20),
      cockpitPaint,
    );

    // Điểm phản quang kính buồng lái
    canvas.drawCircle(
      Offset(x - 1.5, y - 10),
      2.0,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  void _drawParticles(Canvas canvas) {
    for (final p in engine.particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.currentRadius, paint);
    }
  }

  void _drawBanner(Canvas canvas, Size size, String text) {
    if (size.width <= 0 || size.height <= 0) return;

    // Tính độ trong suốt mờ dần theo bannerTimer hiện có của engine (2.4s -> 0.0s)
    double opacity = 1.0;
    if (engine.bannerTimer > 2.1) {
      opacity = ((2.4 - engine.bannerTimer) / 0.3).clamp(0.0, 1.0);
    } else if (engine.bannerTimer < 0.4) {
      opacity = (engine.bannerTimer / 0.4).clamp(0.0, 1.0);
    }
    if (opacity <= 0.0) return;

    // Giới hạn chiều rộng banner phù hợp với bề ngang vùng chơi, chừa lề hai bên
    final maxBannerWidth = (size.width - 40.0).clamp(160.0, size.width);

    // Tính cỡ chữ co giãn theo bề rộng màn hình (màn hình hẹp 320-360px dùng ~20-24px, màn hình lớn tối đa 34px)
    double fontSize = (size.width * 0.08).clamp(20.0, 34.0);

    TextPainter createPainter(double fSize) {
      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fSize,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFAA6EFF).withValues(alpha: opacity),
          letterSpacing: fSize > 24 ? 2.0 : 1.2,
          shadows: [
            Shadow(
              color: const Color(0xFFAA6EFF).withValues(alpha: opacity * 0.8),
              blurRadius: 16,
            ),
            Shadow(
              color: Colors.black.withValues(alpha: opacity * 0.9),
              blurRadius: 6,
            ),
          ],
        ),
      );
      return TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: maxBannerWidth);
    }

    TextPainter tp = createPainter(fontSize);

    // Nếu thông báo ngắn bị rớt dòng không cần thiết trên màn hình hẹp, tự động giảm nhẹ cỡ chữ để hiển thị ngang đẹp
    while ((tp.didExceedMaxLines || (tp.computeLineMetrics().length > 1 && text.length <= 16)) && fontSize > 18.0) {
      fontSize -= 2.0;
      tp = createPainter(fontSize);
    }

    // Kích thước khung chứa banner
    const boxPaddingH = 18.0;
    const boxPaddingV = 10.0;
    final bannerBoxWidth = (tp.width + (boxPaddingH * 2)).clamp(120.0, size.width - 24.0);
    final bannerBoxHeight = tp.height + (boxPaddingV * 2);

    // Đảm bảo banner nằm an toàn trong vùng chơi (giữa playTop và playBottom), không đè HUD hoặc bảng điều khiển
    final desiredCenterY = (engine.playTop + engine.playBottom) * 0.5 - 20.0;
    final safeMinCenterY = engine.playTop + (bannerBoxHeight * 0.5) + 12.0;
    final safeMaxCenterY = engine.playBottom - (bannerBoxHeight * 0.5) - 40.0;
    final centerY = safeMinCenterY <= safeMaxCenterY
        ? desiredCenterY.clamp(safeMinCenterY, safeMaxCenterY)
        : desiredCenterY;

    final bannerRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, centerY),
      width: bannerBoxWidth,
      height: bannerBoxHeight,
    );

    final rrect = RRect.fromRectAndRadius(bannerRect, const Radius.circular(16));

    // Nền tối mờ bảo đảm chữ luôn dễ đọc trên nền vũ trụ / thiên thạch
    final bgPaint = Paint()
      ..color = const Color(0xDD0D1126).withValues(alpha: opacity * 0.88)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // Viền phát sáng tím neon sắc sảo
    final borderPaint = Paint()
      ..color = const Color(0xFFAA6EFF).withValues(alpha: opacity * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);

    // Vẽ chữ căn giữa hoàn hảo
    final textX = (size.width - tp.width) * 0.5;
    final textY = centerY - (tp.height * 0.5);
    tp.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(covariant SpaceGamePainter oldDelegate) => true;
}
