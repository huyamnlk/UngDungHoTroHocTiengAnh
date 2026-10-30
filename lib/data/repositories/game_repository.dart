import 'package:flutter/foundation.dart';
import '../../core/database/database_helper.dart';
import '../models/game_record_model.dart';

class GameRepository {
  final DatabaseHelper _dbHelper;

  GameRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Lưu kết quả lượt chơi game
  Future<int> saveGameRecord(GameRecordModel record) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert('game_history', record.toMap());
    } catch (e) {
      debugPrint('Error saving game record: $e');
      return -1;
    }
  }

  /// Lấy điểm cao nhất của từng game
  Future<int> getHighScore(String gameType) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT MAX(score) as max_score FROM game_history WHERE game_type = ?',
        [gameType],
      );
      if (result.isNotEmpty && result.first['max_score'] != null) {
        return (result.first['max_score'] as num).toInt();
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting high score for $gameType: $e');
      return 0;
    }
  }

  /// Lấy danh sách lịch sử chơi game gần đây
  Future<List<GameRecordModel>> getGameHistory({
    String? gameType,
    int limit = 20,
  }) async {
    try {
      final db = await _dbHelper.database;
      List<Map<String, dynamic>> results;
      if (gameType != null && gameType.isNotEmpty && gameType != 'all') {
        results = await db.query(
          'game_history',
          where: 'game_type = ?',
          whereArgs: [gameType],
          orderBy: 'id DESC',
          limit: limit,
        );
      } else {
        results = await db.query(
          'game_history',
          orderBy: 'id DESC',
          limit: limit,
        );
      }
      return results.map((m) => GameRecordModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error getting game history: $e');
      return [];
    }
  }

  /// Thống kê tổng quan về các game đã chơi
  Future<Map<String, dynamic>> getOverallGameStats() async {
    try {
      final db = await _dbHelper.database;
      final totalGamesRow = await db.rawQuery('SELECT COUNT(*) as cnt FROM game_history');
      final totalPlayed = (totalGamesRow.firstOrNull?['cnt'] as num?)?.toInt() ?? 0;

      final arenaBest = await getHighScore('arena');
      final typerBest = await getHighScore('typer');
      final spaceBest = await getHighScore('space_typer');
      final rainBest = await getHighScore('rain');
      final spellingBest = await getHighScore('spelling');

      return {
        'totalPlayed': totalPlayed,
        'arenaBest': arenaBest,
        'typerBest': typerBest,
        'spaceBest': spaceBest,
        'rainBest': rainBest,
        'spellingBest': spellingBest,
      };
    } catch (e) {
      debugPrint('Error getting overall game stats: $e');
      return {
        'totalPlayed': 0,
        'arenaBest': 0,
        'typerBest': 0,
        'spaceBest': 0,
        'rainBest': 0,
        'spellingBest': 0,
      };
    }
  }
}
