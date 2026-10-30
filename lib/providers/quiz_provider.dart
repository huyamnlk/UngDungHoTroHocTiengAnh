import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../data/models/quiz_history_model.dart';
import '../data/models/quiz_question_model.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/repositories/vocabulary_repository.dart';

class UserQuizAnswer {
  final QuizQuestionModel question;
  final String selectedOption;
  final bool isCorrect;

  UserQuizAnswer({
    required this.question,
    required this.selectedOption,
    required this.isCorrect,
  });
}

class QuizProvider extends ChangeNotifier {
  final QuizRepository _quizRepository;
  final VocabularyRepository _vocabRepository;

  QuizProvider({
    QuizRepository? quizRepository,
    VocabularyRepository? vocabRepository,
  })  : _quizRepository = quizRepository ?? QuizRepository(),
        _vocabRepository = vocabRepository ?? VocabularyRepository();

  bool _isLoading = false;
  String? _errorMessage;

  List<QuizQuestionModel> _questions = [];
  int _currentIndex = 0;
  String? _selectedOption;
  bool _isAnswerChecked = false;
  final List<UserQuizAnswer> _userAnswers = [];
  int _correctCount = 0;
  bool _isCompleted = false;

  int? _activeTopicId;
  String _activeTopicName = 'Tổng hợp';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<QuizQuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  String? get selectedOption => _selectedOption;
  bool get isAnswerChecked => _isAnswerChecked;
  List<UserQuizAnswer> get userAnswers => _userAnswers;
  int get correctCount => _correctCount;
  bool get isCompleted => _isCompleted;
  String get activeTopicName => _activeTopicName;

  QuizQuestionModel? get currentQuestion {
    if (_questions.isEmpty || _currentIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentIndex];
  }

  double get progressPercentage {
    if (_questions.isEmpty) return 0.0;
    return (_currentIndex + 1) / _questions.length;
  }

  double get scorePercentage {
    if (_questions.isEmpty) return 0.0;
    return (_correctCount / _questions.length) * 100;
  }

  /// Khởi tạo bài Quiz mới
  Future<void> startQuiz({int? topicId, String topicName = 'Tổng hợp', int count = 5}) async {
    _isLoading = true;
    _errorMessage = null;
    _currentIndex = 0;
    _selectedOption = null;
    _isAnswerChecked = false;
    _userAnswers.clear();
    _correctCount = 0;
    _isCompleted = false;
    _activeTopicId = topicId;
    _activeTopicName = topicName;
    notifyListeners();

    try {
      _questions = await _quizRepository.generateQuizQuestions(
        topicId: topicId,
        numberOfQuestions: count,
      );

      if (_questions.isEmpty) {
        _errorMessage = 'Chưa có đủ từ vựng để tạo bài kiểm tra!';
      }
    } catch (e) {
      _errorMessage = 'Không thể tạo câu hỏi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Chọn một đáp án
  void selectOption(String option) {
    if (_isAnswerChecked) return; // Đã kiểm tra thì không cho đổi
    _selectedOption = option;
    notifyListeners();
  }

  /// Xác nhận và kiểm tra đáp án
  Future<void> checkAnswer() async {
    final question = currentQuestion;
    if (question == null || _selectedOption == null || _isAnswerChecked) return;

    _isAnswerChecked = true;
    final isCorrect = _selectedOption == question.correctAnswer;

    if (isCorrect) {
      _correctCount++;
    } else {
      // Nếu sai, tự động gắn cờ từ này là cần ôn tập (learning)
      try {
        await _vocabRepository.updateWordStatus(
          question.targetWord.id,
          AppConstants.statusLearning,
        );
      } catch (e) {
        debugPrint('Auto mark as learning on wrong answer error: $e');
      }
    }

    _userAnswers.add(
      UserQuizAnswer(
        question: question,
        selectedOption: _selectedOption!,
        isCorrect: isCorrect,
      ),
    );

    notifyListeners();
  }

  /// Chuyển sang câu hỏi kế tiếp
  Future<void> nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _selectedOption = null;
      _isAnswerChecked = false;
      notifyListeners();
    } else {
      // Đã trả lời hết tất cả câu hỏi -> Kết thúc bài thi
      _isCompleted = true;
      notifyListeners();
      await _saveResult();
    }
  }

  Future<void> _saveResult() async {
    try {
      final history = QuizHistoryModel(
        id: 0,
        topicId: _activeTopicId,
        topicName: _activeTopicName,
        totalQuestions: _questions.length,
        correctAnswers: _correctCount,
        scorePercentage: scorePercentage,
        completedAt: DateTime.now().toIso8601String(),
      );
      await _quizRepository.saveQuizResult(history);
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
    }
  }
}
