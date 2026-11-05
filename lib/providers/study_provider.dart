import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/database/database_helper.dart';
import '../core/services/auth_service.dart';
import '../data/models/topic_model.dart';
import '../data/models/word_model.dart';
import '../data/repositories/vocabulary_repository.dart';

class StudyProvider extends ChangeNotifier {
  final VocabularyRepository _repository;

  static VoidCallback? _onActivityRecordedListener;

  static void notifyActivityRecorded() {
    _onActivityRecordedListener?.call();
  }

  StudyProvider({VocabularyRepository? repository})
      : _repository = repository ?? VocabularyRepository() {
    _onActivityRecordedListener = () {
      if (!_isDisposed) {
        loadWeeklyProgress();
      }
    };
    AuthService.onActiveUserChanged = () {
      if (!_isDisposed) {
        loadWeeklyProgress();
      }
    };
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  bool _isLoading = false;
  String? _errorMessage;

  List<TopicModel> _topics = [];
  List<WordModel> _currentTopicWords = [];
  List<WordModel> _reviewWords = [];
  List<WordModel> _dueSrsWords = [];
  List<WordModel> _favoriteWords = [];
  List<String> _searchHistory = [];
  WordModel? _wordOfTheDay;
  Map<String, int> _overallStats = {
    'total': 0,
    'mastered': 0,
    'learning': 0,
    'favorite': 0,
  };
  Map<String, dynamic> _weeklyProgress = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TopicModel> get topics => _topics;
  List<WordModel> get currentTopicWords => _currentTopicWords;
  List<WordModel> get reviewWords => _reviewWords;
  List<WordModel> get dueSrsWords => _dueSrsWords;
  List<WordModel> get favoriteWords => _favoriteWords;
  List<String> get searchHistory => _searchHistory;
  WordModel? get wordOfTheDay => _wordOfTheDay;
  Map<String, int> get overallStats => _overallStats;
  Map<String, dynamic> get weeklyProgress => _weeklyProgress;

  Future<void> init() async {
    await loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        loadTopics(),
        loadWordOfTheDay(),
        loadReviewWords(),
        loadDueSrsWords(),
        loadFavoriteWords(),
        loadOverallStats(),
        loadSearchHistory(),
        loadWeeklyProgress(notify: false),
      ]);
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu: $e';
      debugPrint('StudyProvider init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> loadWeeklyProgress({
    String? userUid,
    DateTime? referenceNow,
    bool notify = true,
  }) async {
    try {
      final effectiveUid = (userUid != null && userUid.trim().isNotEmpty)
          ? userUid.trim()
          : AuthService.currentActiveUid;
      _weeklyProgress = await DatabaseHelper.instance.getWeeklyActivitySummary(
        userUid: effectiveUid,
        referenceNow: referenceNow,
      );
      if (notify) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading weekly progress: $e');
    }
    return _weeklyProgress;
  }

  Future<void> loadTopics() async {
    try {
      _topics = await _repository.getAllTopicsWithProgress();
    } catch (e) {
      debugPrint('Error loading topics: $e');
    }
  }

  Future<void> loadWordsByTopic(int topicId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentTopicWords = await _repository.getWordsByTopic(topicId);
    } catch (e) {
      _errorMessage = 'Lỗi tải từ vựng của chủ đề: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReviewWords() async {
    try {
      _reviewWords = await _repository.getWordsForReview();
    } catch (e) {
      debugPrint('Error loading review words: $e');
    }
  }

  Future<void> loadDueSrsWords() async {
    try {
      _dueSrsWords = await _repository.getDueSrsWords();
    } catch (e) {
      debugPrint('Error loading due SRS words: $e');
    }
  }

  Future<void> loadFavoriteWords() async {
    try {
      _favoriteWords = await _repository.getFavoriteWords();
    } catch (e) {
      debugPrint('Error loading favorite words: $e');
    }
  }

  Future<void> loadSearchHistory() async {
    try {
      _searchHistory = await _repository.getSearchHistory();
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  Future<void> saveSearchQuery(String query) async {
    try {
      await _repository.saveSearchHistory(query);
      await loadSearchHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving search query: $e');
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      await _repository.clearSearchHistory();
      _searchHistory.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing search history: $e');
    }
  }

  Future<void> loadWordOfTheDay() async {
    try {
      _wordOfTheDay = await _repository.getRandomWord();
    } catch (e) {
      debugPrint('Error loading word of the day: $e');
    }
  }

  Future<void> loadOverallStats() async {
    try {
      _overallStats = await _repository.getVocabularyStats();
    } catch (e) {
      debugPrint('Error loading overall stats: $e');
    }
  }

  /// Đánh dấu từ đã nhớ (Mastered) kèm thuật toán Spaced Repetition (SRS)
  Future<void> markAsMastered(WordModel word) async {
    try {
      await _repository.updateWordStatusWithSrs(
        word.id,
        AppConstants.statusMastered,
        currentInterval: word.intervalDays,
      );
      await DatabaseHelper.instance.recordLearningActivity(
        userUid: AuthService.currentActiveUid,
        activityType: 'word_review',
        itemId: 'word_${word.id}',
        wordCount: 1,
        activityCount: 0,
      );
      await _syncWordUpdate(word.id, AppConstants.statusMastered);
    } catch (e) {
      debugPrint('Error marking word as mastered: $e');
    }
  }

  /// Đánh dấu từ cần ôn tập (Learning)
  Future<void> markAsLearning(WordModel word) async {
    try {
      await _repository.updateWordStatusWithSrs(
        word.id,
        AppConstants.statusLearning,
        currentInterval: 1,
      );
      await DatabaseHelper.instance.recordLearningActivity(
        userUid: AuthService.currentActiveUid,
        activityType: 'word_review',
        itemId: 'word_${word.id}',
        wordCount: 1,
        activityCount: 0,
      );
      await _syncWordUpdate(word.id, AppConstants.statusLearning);
    } catch (e) {
      debugPrint('Error marking word as learning: $e');
    }
  }

  /// Reset từ về trạng thái mới (New)
  Future<void> markAsNew(WordModel word) async {
    try {
      await _repository.updateWordStatusWithSrs(
        word.id,
        AppConstants.statusNew,
        currentInterval: 1,
      );
      await _syncWordUpdate(word.id, AppConstants.statusNew);
    } catch (e) {
      debugPrint('Error marking word as new: $e');
    }
  }

  /// Đổi trạng thái yêu thích của từ
  Future<void> toggleFavorite(WordModel word) async {
    try {
      final newFav = await _repository.toggleFavorite(word.id, word.isFavorite);
      final updatedWord = word.copyWith(isFavorite: newFav);

      _currentTopicWords = _currentTopicWords.map((w) => w.id == word.id ? updatedWord : w).toList();
      if (_wordOfTheDay?.id == word.id) {
        _wordOfTheDay = updatedWord;
      }

      await loadFavoriteWords();
      await loadOverallStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  /// Thêm từ mới thủ công hoặc lưu từ bài học / từ điển trực tuyến
  Future<void> addNewWord(WordModel word) async {
    try {
      await _repository.insertWord(word);
      await loadTopics();
      if (word.topicId > 0) {
        await loadWordsByTopic(word.topicId);
      }
      await loadReviewWords();
      await loadDueSrsWords();
      await loadFavoriteWords();
      await loadOverallStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding new word: $e');
    }
  }

  /// Khôi phục dữ liệu gốc
  Future<void> resetToSeedData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.resetAllData();
      await loadInitialData();
    } catch (e) {
      _errorMessage = 'Lỗi khi khôi phục dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncWordUpdate(int wordId, String newStatus) async {
    _currentTopicWords = _currentTopicWords.map((w) {
      if (w.id == wordId) {
        return w.copyWith(
          status: newStatus,
          reviewCount: w.reviewCount + 1,
          lastReviewedAt: DateTime.now().toIso8601String(),
        );
      }
      return w;
    }).toList();

    if (_wordOfTheDay?.id == wordId) {
      _wordOfTheDay = _wordOfTheDay!.copyWith(
        status: newStatus,
        reviewCount: _wordOfTheDay!.reviewCount + 1,
      );
    }

    await loadTopics();
    await loadReviewWords();
    await loadDueSrsWords();
    await loadOverallStats();
    await loadWeeklyProgress(notify: false);
    notifyListeners();
  }
}
