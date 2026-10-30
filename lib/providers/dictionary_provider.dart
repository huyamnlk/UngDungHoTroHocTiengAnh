import 'package:flutter/foundation.dart';
import '../core/services/dictionary_api_service.dart';
import '../data/models/online_dictionary_result.dart';
import '../data/models/word_model.dart';
import '../data/repositories/vocabulary_repository.dart';

class DictionaryProvider extends ChangeNotifier {
  final VocabularyRepository _vocabRepository;
  final DictionaryApiService _apiService;

  DictionaryProvider({
    VocabularyRepository? vocabRepository,
    DictionaryApiService? apiService,
  })  : _vocabRepository = vocabRepository ?? VocabularyRepository(),
        _apiService = apiService ?? DictionaryApiService();

  bool _isLoading = false;
  String _currentQuery = '';
  String _selectedLevel = 'all'; // 'all', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'
  int _selectedTopicId = 0; // 0 = Tất cả chủ đề
  String _selectedPos = 'all'; // 'all', 'noun', 'verb', 'adjective', 'adverb', 'phrase'

  List<WordModel> _localResults = [];
  OnlineDictionaryResult? _onlineResult;
  bool _isSearchingOnline = false;
  String? _onlineErrorMessage;
  DictionarySearchStatus _onlineSearchStatus = DictionarySearchStatus.notFound;

  bool get isLoading => _isLoading;
  String get currentQuery => _currentQuery;
  String get selectedLevel => _selectedLevel;
  int get selectedTopicId => _selectedTopicId;
  String get selectedPos => _selectedPos;
  List<WordModel> get localResults => _localResults;
  OnlineDictionaryResult? get onlineResult => _onlineResult;
  bool get isSearchingOnline => _isSearchingOnline;
  String? get onlineErrorMessage => _onlineErrorMessage;
  DictionarySearchStatus get onlineSearchStatus => _onlineSearchStatus;

  bool get isVietnameseQuery =>
      DictionaryApiService.isVietnameseQuery(_currentQuery);
  String get queryDirection => isVietnameseQuery ? 'vi_en' : 'en_vi';
  String get directionLabel =>
      isVietnameseQuery ? 'Việt ➔ Anh' : 'Anh ➔ Việt';
  String get directionFlag => isVietnameseQuery ? '🇻🇳 ➔ 🇬🇧' : '🇬🇧 ➔ 🇻🇳';

  bool get hasActiveFilters =>
      _selectedLevel != 'all' || _selectedTopicId != 0 || _selectedPos != 'all';

  Future<void> search(String query) async {
    _currentQuery = query.trim();
    _onlineResult = null;
    _onlineErrorMessage = null;
    _onlineSearchStatus = DictionarySearchStatus.notFound;

    if (_currentQuery.isEmpty && !hasActiveFilters) {
      _localResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _localResults = await _vocabRepository.searchDictionary(
        _currentQuery,
        levelFilter: _selectedLevel == 'all' ? null : _selectedLevel,
        topicFilter: _selectedTopicId == 0 ? null : _selectedTopicId,
        partOfSpeechFilter: _selectedPos == 'all' ? null : _selectedPos,
      );

      if (_localResults.isNotEmpty && _currentQuery.isNotEmpty) {
        await _vocabRepository.saveSearchHistory(_currentQuery);
      }
    } catch (e) {
      debugPrint('Dictionary search error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setLevelFilter(String level) {
    if (_selectedLevel == level) return;
    _selectedLevel = level;
    search(_currentQuery);
  }

  void setTopicFilter(int topicId) {
    if (_selectedTopicId == topicId) return;
    _selectedTopicId = topicId;
    search(_currentQuery);
  }

  void setPosFilter(String pos) {
    if (_selectedPos == pos) return;
    _selectedPos = pos;
    search(_currentQuery);
  }

  void resetFilters() {
    _selectedLevel = 'all';
    _selectedTopicId = 0;
    _selectedPos = 'all';
    search(_currentQuery);
  }

  /// Tra cứu trực tuyến mở rộng (Free Dictionary API kết hợp dự phòng Wiktionary REST API)
  Future<void> searchOnline() async {
    if (_currentQuery.isEmpty) return;

    _isSearchingOnline = true;
    _onlineErrorMessage = null;
    _onlineResult = null;
    notifyListeners();

    try {
      final response = await _apiService.searchOnlineDetailed(_currentQuery);
      _onlineSearchStatus = response.status;
      if (response.isSuccess) {
        _onlineResult = response.result;
        _onlineErrorMessage = null;
      } else {
        _onlineResult = null;
        _onlineErrorMessage = response.errorMessage ??
            'Không tìm thấy định nghĩa cho "$_currentQuery" trên từ điển trực tuyến.';
      }
    } catch (e) {
      _onlineSearchStatus = DictionarySearchStatus.networkError;
      _onlineErrorMessage =
          'Lỗi kết nối từ điển trực tuyến ($e). Vui lòng kiểm tra lại mạng.';
    } finally {
      _isSearchingOnline = false;
      notifyListeners();
    }
  }

  /// Thử lại tra cứu trực tuyến khi gặp sự cố mạng hoặc lỗi kết nối
  Future<void> retrySearchOnline() async {
    await searchOnline();
  }
}
