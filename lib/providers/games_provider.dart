import 'package:flutter/foundation.dart';
import '../data/models/game_record_model.dart';
import '../data/models/word_model.dart';
import '../data/repositories/game_repository.dart';
import '../data/repositories/vocabulary_repository.dart';

class GamesProvider extends ChangeNotifier {
  final GameRepository _gameRepository;
  final VocabularyRepository _vocabularyRepository;

  GamesProvider({
    GameRepository? gameRepository,
    VocabularyRepository? vocabularyRepository,
  })  : _gameRepository = gameRepository ?? GameRepository(),
        _vocabularyRepository = vocabularyRepository ?? VocabularyRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _arenaHighScore = 0;
  int get arenaHighScore => _arenaHighScore;

  int _typerHighScore = 0;
  int get typerHighScore => _typerHighScore;

  int _spaceHighScore = 0;
  int get spaceHighScore => _spaceHighScore;

  int _rainHighScore = 0;
  int get rainHighScore => _rainHighScore;

  int _spellingHighScore = 0;
  int get spellingHighScore => _spellingHighScore;

  int _totalGamesPlayed = 0;
  int get totalGamesPlayed => _totalGamesPlayed;

  List<GameRecordModel> _recentHistory = [];
  List<GameRecordModel> get recentHistory => _recentHistory;

  Future<void> init() async {
    await loadHighScoresAndHistory();
  }

  Future<void> loadHighScoresAndHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final stats = await _gameRepository.getOverallGameStats();
      _totalGamesPlayed = stats['totalPlayed'] as int? ?? 0;
      _arenaHighScore = stats['arenaBest'] as int? ?? 0;
      _typerHighScore = stats['typerBest'] as int? ?? 0;
      _spaceHighScore = stats['spaceBest'] as int? ?? 0;
      _rainHighScore = stats['rainBest'] as int? ?? 0;
      _spellingHighScore = stats['spellingBest'] as int? ?? 0;

      _recentHistory = await _gameRepository.getGameHistory(limit: 25);
    } catch (e) {
      debugPrint('Error loading game stats and history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lấy danh sách từ vựng sạch để chơi game theo chủ đề và cấp độ CEFR
  Future<List<WordModel>> getFilteredWords({
    int? topicId,
    String level = 'All',
  }) async {
    try {
      // Tối ưu: Lấy ngẫu nhiên tối đa 100 từ thay vì nạp toàn bộ 3.000 từ vào RAM
      final words = await _vocabularyRepository.getRandomWords(
        limit: 100,
        topicId: topicId,
        level: level,
      );

      if (words.length >= 4) {
        return words;
      }

      // Fallback nếu bộ lọc trả về ít hơn 4 từ
      return await _vocabularyRepository.getRandomWords(limit: 100, topicId: topicId);
    } catch (e) {
      debugPrint('Error getting filtered words for game: $e');
      return [];
    }
  }

  /// Lưu kết quả game vào SQLite và cập nhật kỷ lục
  Future<void> recordGameResult(GameRecordModel record) async {
    try {
      await _gameRepository.saveGameRecord(record);

      if (record.gameType == 'arena' && record.score > _arenaHighScore) {
        _arenaHighScore = record.score;
      } else if (record.gameType == 'typer' && record.score > _typerHighScore) {
        _typerHighScore = record.score;
      } else if (record.gameType == 'space_typer' && record.score > _spaceHighScore) {
        _spaceHighScore = record.score;
      } else if (record.gameType == 'rain' && record.score > _rainHighScore) {
        _rainHighScore = record.score;
      } else if (record.gameType == 'spelling' && record.score > _spellingHighScore) {
        _spellingHighScore = record.score;
      }

      _totalGamesPlayed++;
      _recentHistory.insert(0, record);
      if (_recentHistory.length > 30) {
        _recentHistory.removeLast();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error recording game result: $e');
    }
  }

  int getHighScoreFor(String gameType) {
    switch (gameType) {
      case 'arena':
        return _arenaHighScore;
      case 'typer':
        return _typerHighScore;
      case 'space_typer':
        return _spaceHighScore;
      case 'rain':
        return _rainHighScore;
      case 'spelling':
        return _spellingHighScore;
      default:
        return 0;
    }
  }
}
