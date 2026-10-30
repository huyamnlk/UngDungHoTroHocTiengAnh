import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../data/models/word_model.dart';

/// Bộ cấp độ khó chuẩn hóa áp dụng cho tất cả trò chơi trong English Buddy:
/// - Dễ (Easy)
/// - Trung bình (Medium)
/// - Khó (Hard)
enum GameDifficulty {
  easy(
    label: 'Dễ',
    code: 'Easy',
    subLabel: 'Từ vựng ngắn, quen thuộc, tốc độ thong thả',
    color: Color(0xFF10B981), // Emerald
    icon: Icons.sentiment_satisfied_alt_rounded,
  ),
  medium(
    label: 'Trung bình',
    code: 'Medium',
    subLabel: 'Độ dài từ cân bằng, tốc độ phản xạ chuẩn',
    color: Color(0xFFF59E0B), // Amber
    icon: Icons.speed_rounded,
  ),
  hard(
    label: 'Khó',
    code: 'Hard',
    subLabel: 'Từ vựng dài & nâng cao, tốc độ dồn dập',
    color: Color(0xFFEF4444), // Red
    icon: Icons.local_fire_department_rounded,
  );

  final String label;
  final String code;
  final String subLabel;
  final Color color;
  final IconData icon;

  const GameDifficulty({
    required this.label,
    required this.code,
    required this.subLabel,
    required this.color,
    required this.icon,
  });

  /// Lọc và sắp xếp từ vựng thực tế theo độ khó:
  /// - Dễ: Ưu tiên từ ngắn 2-5 ký tự, cấp độ A1, A2
  /// - Trung bình: Ưu tiên từ 5-8 ký tự, cấp độ B1, B2
  /// - Khó: Ưu tiên từ >8 ký tự hoặc từ cấp độ B2, C1
  /// Có cơ chế fallback tự động để tránh danh sách rỗng hoặc lặp từ liên tục.
  static List<WordModel> filterWords({
    required List<WordModel> words,
    required GameDifficulty difficulty,
    int minCount = 10,
  }) {
    if (words.isEmpty) return [];

    final cleanWords = words.where((w) => w.term.trim().isNotEmpty).toList();
    if (cleanWords.length <= minCount) {
      return List<WordModel>.from(cleanWords);
    }

    List<WordModel> filtered = [];
    switch (difficulty) {
      case GameDifficulty.easy:
        filtered = cleanWords.where((w) {
          final len = w.term.trim().length;
          final isShort = len >= 2 && len <= 5;
          final isBasic = w.level == 'A1' || w.level == 'A2';
          return isShort || isBasic;
        }).toList();
        if (filtered.length < minCount) {
          // Bổ sung các từ ngắn nhất từ danh sách nguồn
          final sortedByLength = List<WordModel>.from(cleanWords)
            ..sort((a, b) => a.term.trim().length.compareTo(b.term.trim().length));
          filtered = sortedByLength.take(max(minCount, sortedByLength.length ~/ 2)).toList();
        }
        break;

      case GameDifficulty.medium:
        filtered = cleanWords.where((w) {
          final len = w.term.trim().length;
          final isMid = len >= 4 && len <= 8;
          final isMidLevel = w.level == 'B1' || w.level == 'B2';
          return isMid || isMidLevel;
        }).toList();
        if (filtered.length < minCount) {
          filtered = List<WordModel>.from(cleanWords);
        }
        break;

      case GameDifficulty.hard:
        filtered = cleanWords.where((w) {
          final len = w.term.trim().length;
          final isLong = len >= 7;
          final isAdvanced = w.level == 'B2' || w.level == 'C1';
          return isLong || isAdvanced;
        }).toList();
        if (filtered.length < minCount) {
          // Bổ sung các từ dài nhất từ danh sách nguồn
          final sortedByLengthDesc = List<WordModel>.from(cleanWords)
            ..sort((a, b) => b.term.trim().length.compareTo(a.term.trim().length));
          filtered = sortedByLengthDesc.take(max(minCount, sortedByLengthDesc.length ~/ 2)).toList();
        }
        break;
    }

    return filtered.isNotEmpty ? filtered : cleanWords;
  }
}
