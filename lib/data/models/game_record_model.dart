class GameRecordModel {
  final int? id;
  final String gameType; // 'arena', 'typer', 'rain', 'spelling'
  final int? topicId;
  final String topicName;
  final String level; // 'All', 'A1', 'A2', 'B1', 'B2', 'C1'
  final int score;
  final int highStreak;
  final int totalItems;
  final int correctItems;
  final double accuracy;
  final int durationSeconds;
  final String completedAt;

  const GameRecordModel({
    this.id,
    required this.gameType,
    this.topicId,
    this.topicName = 'Tất cả chủ đề',
    this.level = 'All',
    required this.score,
    this.highStreak = 0,
    required this.totalItems,
    required this.correctItems,
    required this.accuracy,
    this.durationSeconds = 0,
    required this.completedAt,
  });

  String get gameTitle {
    switch (gameType) {
      case 'arena':
        return 'Đấu trường từ vựng';
      case 'typer':
        return 'Luyện Gõ Siêu Tốc';
      case 'space_typer':
        return 'Chiến cơ Không gian';
      case 'rain':
        return 'Mưa Từ Vựng';
      case 'spelling':
        return 'Ong Chính Tả';
      default:
        return 'Trò chơi từ vựng';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'game_type': gameType,
      'topic_id': topicId,
      'topic_name': topicName,
      'level': level,
      'score': score,
      'high_streak': highStreak,
      'total_items': totalItems,
      'correct_items': correctItems,
      'accuracy': accuracy,
      'duration_seconds': durationSeconds,
      'completed_at': completedAt,
    };
  }

  factory GameRecordModel.fromMap(Map<String, dynamic> map) {
    return GameRecordModel(
      id: map['id'] as int?,
      gameType: map['game_type'] as String? ?? 'arena',
      topicId: map['topic_id'] as int?,
      topicName: map['topic_name'] as String? ?? 'Tất cả chủ đề',
      level: map['level'] as String? ?? 'All',
      score: map['score'] as int? ?? 0,
      highStreak: map['high_streak'] as int? ?? 0,
      totalItems: map['total_items'] as int? ?? 0,
      correctItems: map['correct_items'] as int? ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: map['duration_seconds'] as int? ?? 0,
      completedAt: map['completed_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
