import 'dart:math';
import 'package:flutter/material.dart';
import 'package:english_buddy/data/models/word_model.dart';

/// Ngôi sao trong không gian vũ trụ với 3 lớp chiều sâu (Parallax Stars)
class SpaceStar {
  double x;
  double y;
  final int layer; // 1: xa/nhỏ/chậm, 2: trung bình, 3: gần/lớn/nhanh
  final double speed;

  SpaceStar({
    required this.x,
    required this.y,
    required this.layer,
  }) : speed = layer * 35.0;

  void update(double dt, double width, double top, double bottom) {
    final playH = bottom - top;
    if (playH <= 0) return;
    y += speed * dt;
    if (y > bottom) {
      y = top + (y - bottom);
      x = Random().nextDouble() * width;
    }
  }

  Color get color {
    final c = (70 + layer * 55).clamp(0, 255);
    final b = (c + 25).clamp(0, 255);
    return Color.fromARGB(255, c, c, b);
  }

  double get radius => layer * 0.75 + 0.5;
}

/// Hành tinh trang trí nền vũ trụ (Hành tinh xanh & Hành tinh đỏ như bản Pygame)
class SpacePlanet {
  final double relativeX; // 0.0 to 1.0
  final double relativeY; // 0.0 to 1.0
  final double radius;
  final Color primaryColor;
  final Color ringColor;
  final bool hasRing;

  const SpacePlanet({
    required this.relativeX,
    required this.relativeY,
    required this.radius,
    required this.primaryColor,
    required this.ringColor,
    this.hasRing = false,
  });
}

/// Thiên thạch / Mục tiêu mang từ hoặc chữ cái rơi từ trên xuống
class AsteroidTarget {
  final String id;
  final String text; // Từ tiếng Anh (viết hoa hoặc thường theo cài đặt)
  final String meaning; // Nghĩa tiếng Việt
  final WordModel? wordModel;

  double x;
  double y;
  final double radius;
  double vx;
  double vy;
  double angle; // góc xoay hiện tại (radian)
  final double spin; // tốc độ xoay (rad/s)
  final List<Offset> contourPoints; // Đỉnh đa giác thiên thạch gồ ghề

  int typedIndex = 0; // Số ký tự đã gõ đúng
  bool isLocked = false; // Đang được người chơi nhắm bắn
  bool isDestroyed = false; // Đã bị bắn hạ thành công
  bool hasBreached = false; // Đã lọt qua vạch đỏ đáy
  double errorShakeTimer = 0.0; // Rung đỏ khi gõ sai

  AsteroidTarget({
    required this.id,
    required this.text,
    this.meaning = '',
    this.wordModel,
    required this.x,
    required this.y,
    required this.radius,
    required this.vx,
    required this.vy,
    required this.spin,
    this.angle = 0.0,
    required this.contourPoints,
    this.isDestroyed = false,
    this.hasBreached = false,
  });

  /// Tạo thiên thạch với đường viền đa giác ngẫu nhiên lấy cảm hứng từ test.py
  factory AsteroidTarget.create({
    required String id,
    required String text,
    String meaning = '',
    WordModel? wordModel,
    required double x,
    required double y,
    double levelSpeedBonus = 0.0,
    double speedMultiplier = 1.0,
    Random? random,
  }) {
    final rng = random ?? Random();
    // Bán kính phụ thuộc độ dài từ để chứa vừa chữ
    final baseRadius = (text.length > 5 ? 32.0 : 26.0) + (rng.nextDouble() * 8.0);
    final n = 9 + rng.nextInt(4); // 9-12 đỉnh
    final contour = <Offset>[];

    for (int i = 0; i < n; i++) {
      final angleFraction = 2 * pi * i / n;
      final k = 0.78 + (rng.nextDouble() * 0.38); // biến thiên độ dài đỉnh
      contour.add(Offset(cos(angleFraction) * k, sin(angleFraction) * k));
    }

    final vx = (rng.nextDouble() * 40.0 - 20.0);
    final baseVy = 40.0 + (levelSpeedBonus * 10.0) + (rng.nextDouble() * 20.0);
    final vy = baseVy * speedMultiplier;
    final spin = (rng.nextDouble() * 1.6 - 0.8);

    return AsteroidTarget(
      id: id,
      text: text,
      meaning: meaning,
      wordModel: wordModel,
      x: x,
      y: y,
      radius: baseRadius,
      vx: vx,
      vy: vy,
      spin: spin,
      contourPoints: contour,
    );
  }

  void update(double dt, double width, double leftBound, double rightBound) {
    x += vx * dt;
    y += vy * dt;
    angle += spin * dt;

    if (errorShakeTimer > 0) {
      errorShakeTimer = max(0, errorShakeTimer - dt);
    }

    // Bật lại khi chạm viền hai bên
    if (x - radius < leftBound) {
      x = leftBound + radius;
      vx = vx.abs();
    } else if (x + radius > rightBound) {
      x = rightBound - radius;
      vx = -vx.abs();
    }
  }

  /// Ký tự tiếp theo cần gõ
  String? get nextChar {
    if (typedIndex < text.length) {
      return text[typedIndex];
    }
    return null;
  }
}

/// Tia đạn Laze phóng ra từ chiến cơ hướng lên mục tiêu
class SpaceLaserBullet {
  double x;
  double y;
  final double startX;
  final double startY;
  final double targetX;
  final double targetY;
  final String targetId;
  double vy;
  bool hasHit = false;

  SpaceLaserBullet({
    required this.x,
    required this.y,
    required this.startX,
    required this.startY,
    required this.targetX,
    required this.targetY,
    required this.targetId,
    this.vy = -750.0,
  });

  void update(double dt) {
    y += vy * dt;
    // Dần hướng nhẹ theo phương x tới mục tiêu
    final dx = targetX - x;
    x += dx * 6.0 * dt;
  }
}

/// Hạt vụ nổ / mảnh vỡ thiên thạch (Particles)
class SpaceParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final double maxLife;
  final Color color;
  final double initialRadius;

  SpaceParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    this.initialRadius = 3.5,
  }) : maxLife = life;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;
  }

  double get currentRadius => max(0.5, initialRadius * (life / maxLife));
  double get opacity => (life / maxLife).clamp(0.0, 1.0);
}
