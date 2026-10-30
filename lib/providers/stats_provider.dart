import 'package:flutter/foundation.dart';
import '../data/models/quiz_history_model.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/repositories/vocabulary_repository.dart';

class StatsProvider extends ChangeNotifier {
  final VocabularyRepository _vocabRepository;
  final QuizRepository _quizRepository;

  StatsProvider({
    VocabularyRepository? vocabRepository,
    QuizRepository? quizRepository,
  })  : _vocabRepository = vocabRepository ?? VocabularyRepository(),
        _quizRepository = quizRepository ?? QuizRepository();

  bool _isLoading = false;
  Map<String, int> _vocabStats = {
    'total': 0,
    'mastered': 0,
    'learning': 0,
    'favorite': 0,
  };
  List<QuizHistoryModel> _quizHistories = [];

  bool get isLoading => _isLoading;
  Map<String, int> get vocabStats => _vocabStats;
  List<QuizHistoryModel> get quizHistories => _quizHistories;

  int get totalWords => _vocabStats['total'] ?? 0;
  int get masteredWords => _vocabStats['mastered'] ?? 0;
  int get learningWords => _vocabStats['learning'] ?? 0;
  int get favoriteWords => _vocabStats['favorite'] ?? 0;

  double get masteryRate {
    if (totalWords == 0) return 0.0;
    return (masteredWords / totalWords) * 100;
  }

  double get averageQuizScore {
    if (_quizHistories.isEmpty) return 0.0;
    final totalScore = _quizHistories.fold<double>(0.0, (acc, h) => acc + h.scorePercentage);
    return totalScore / _quizHistories.length;
  }

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final stats = await _vocabRepository.getVocabularyStats();
      final histories = await _quizRepository.getQuizHistory();
      _vocabStats = stats;
      _quizHistories = histories;
    } catch (e) {
      debugPrint('StatsProvider load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
