import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/database/database_helper.dart';
import '../core/database/exam_seed_data.dart';
import '../core/database/shadowing_seed_data.dart';
import '../core/database/skills_seed_data.dart';
import '../data/models/exam_model.dart';
import '../data/models/shadowing_model.dart';
import '../data/models/skill_exercise_model.dart';

class SkillsProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper;

  SkillsProvider({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  String _selectedLevel = 'All';
  String get selectedLevel => _selectedLevel;

  String _selectedShadowingTopic = 'All';
  String get selectedShadowingTopic => _selectedShadowingTopic;

  void setSelectedLevel(String level) {
    if (_selectedLevel == level) return;
    _selectedLevel = level;
    notifyListeners();
  }

  void setSelectedShadowingTopic(String topic) {
    if (_selectedShadowingTopic == topic) return;
    _selectedShadowingTopic = topic;
    notifyListeners();
  }

  List<SkillExerciseModel> get listeningExercises =>
      _filterByLevel(SkillsSeedData.listeningExercises);
  List<SkillExerciseModel> get readingExercises =>
      _filterByLevel(SkillsSeedData.readingExercises);
  List<SkillExerciseModel> get writingExercises =>
      _filterByLevel(SkillsSeedData.writingExercises);
  List<SkillExerciseModel> get speakingExercises =>
      _filterByLevel(SkillsSeedData.speakingExercises);

  List<SkillExerciseModel> getExercisesByType(SkillType type) {
    switch (type) {
      case SkillType.listening:
        return listeningExercises;
      case SkillType.reading:
        return readingExercises;
      case SkillType.writing:
        return writingExercises;
      case SkillType.speaking:
        return speakingExercises;
    }
  }

  List<SkillExerciseModel> getAllExercisesByType(SkillType type) {
    switch (type) {
      case SkillType.listening:
        return SkillsSeedData.listeningExercises;
      case SkillType.reading:
        return SkillsSeedData.readingExercises;
      case SkillType.writing:
        return SkillsSeedData.writingExercises;
      case SkillType.speaking:
        return SkillsSeedData.speakingExercises;
    }
  }

  List<SkillExerciseModel> get allExercises => [
        ...SkillsSeedData.listeningExercises,
        ...SkillsSeedData.readingExercises,
        ...SkillsSeedData.writingExercises,
        ...SkillsSeedData.speakingExercises,
      ];

  List<SkillExerciseModel> _filterByLevel(List<SkillExerciseModel> list) {
    if (_selectedLevel == 'All') return list;
    return list
        .where((e) => e.level.toUpperCase() == _selectedLevel.toUpperCase())
        .toList();
  }

  // Danh sách bài học Shadowing riêng
  List<ShadowingLessonModel> get allShadowingLessons =>
      ShadowingSeedData.lessons;

  List<String> get shadowingTopics {
    final topics =
        ShadowingSeedData.lessons.map((l) => l.topic).toSet().toList();
    return ['All', ...topics];
  }

  List<ShadowingLessonModel> get filteredShadowingLessons {
    return ShadowingSeedData.lessons.where((lesson) {
      final matchLevel = _selectedLevel == 'All' ||
          lesson.level.toUpperCase() == _selectedLevel.toUpperCase();
      final matchTopic = _selectedShadowingTopic == 'All' ||
          lesson.topic == _selectedShadowingTopic;
      return matchLevel && matchTopic;
    }).toList();
  }

  // Lịch sử điểm số các bài tập kỹ năng
  List<Map<String, dynamic>> _skillScores = [];
  List<Map<String, dynamic>> get skillScores => _skillScores;

  // Lịch sử làm đề luyện thi (IELTS / TOEIC / CEFR)
  List<ExamAttemptModel> _examAttempts = [];
  List<ExamAttemptModel> get examAttempts => _examAttempts;

  String _selectedExamCategory = 'All';
  String get selectedExamCategory => _selectedExamCategory;

  String _selectedExamSkill = 'All';
  String get selectedExamSkill => _selectedExamSkill;

  void setExamCategoryFilter(String category) {
    if (_selectedExamCategory == category) return;
    _selectedExamCategory = category;
    notifyListeners();
  }

  void setExamSkillFilter(String skill) {
    if (_selectedExamSkill == skill) return;
    _selectedExamSkill = skill;
    notifyListeners();
  }

  List<ExamModel> get allExams => ExamSeedData.exams;

  List<ExamModel> get filteredExams {
    return ExamSeedData.exams.where((exam) {
      final matchCat = _selectedExamCategory == 'All' ||
          exam.category.toUpperCase() == _selectedExamCategory.toUpperCase();
      final matchSkill = _selectedExamSkill == 'All' ||
          exam.skillSection.toLowerCase() == _selectedExamSkill.toLowerCase();
      return matchCat && matchSkill;
    }).toList();
  }

  Future<void> loadSkillScores() async {
    try {
      _skillScores = await _dbHelper.getSkillScores();
      _examAttempts = (await _dbHelper.getExamAttempts())
          .map((row) => ExamAttemptModel.fromMap(row))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading skill scores & exam attempts: $e');
    }
  }

  Future<void> saveScore({
    required String skillType,
    required String exerciseId,
    required String title,
    required double score,
    String userSubmission = '',
    String detailsJson = '',
  }) async {
    try {
      await _dbHelper.saveSkillScore(
        skillType: skillType,
        exerciseId: exerciseId,
        title: title,
        score: score,
        userSubmission: userSubmission,
        detailsJson: detailsJson,
      );
      await loadSkillScores();
    } catch (e) {
      debugPrint('Error saving skill score: $e');
    }
  }

  Future<void> recordExamAttempt(ExamAttemptModel attempt) async {
    try {
      await _dbHelper.saveExamAttempt(
        examId: attempt.examId,
        examTitle: attempt.examTitle,
        examCategory: attempt.examCategory,
        skillSection: attempt.skillSection,
        totalQuestions: attempt.totalQuestions,
        correctAnswers: attempt.correctAnswers,
        scorePercentage: attempt.scorePercentage,
        durationSeconds: attempt.durationSeconds,
        answersJson: jsonEncode(attempt.userAnswers),
      );
      await loadSkillScores();
    } catch (e) {
      debugPrint('Error saving exam attempt: $e');
    }
  }

  double? getBestScore(String exerciseId) {
    final matches = _skillScores
        .where((row) => row['exercise_id'] == exerciseId)
        .map((row) => (row['score'] as num?)?.toDouble() ?? 0.0)
        .toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.compareTo(a));
    return matches.first;
  }

  bool isExerciseCompleted(String exerciseId) {
    return _skillScores.any((row) => row['exercise_id'] == exerciseId);
  }

  int get completedExercisesCount {
    final ids = _skillScores
        .map((row) => row['exercise_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    return ids.length;
  }

  List<Map<String, dynamic>> getSavedSubmissions(String exerciseId) {
    return _skillScores
        .where((row) =>
            row['exercise_id'] == exerciseId &&
            (row['user_submission']?.toString().trim().isNotEmpty ?? false))
        .toList();
  }

  List<Map<String, dynamic>> getScoresForSkillType(String skillType) {
    return _skillScores
        .where((row) =>
            (row['skill_type']?.toString().toLowerCase() ?? '') ==
            skillType.toLowerCase())
        .toList();
  }

  ExamAttemptModel? getBestExamAttempt(String examId) {
    final matches =
        _examAttempts.where((attempt) => attempt.examId == examId).toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.scorePercentage.compareTo(a.scorePercentage));
    return matches.first;
  }

  SkillExerciseModel recommendedExerciseForSkill(SkillType type) {
    final list = getAllExercisesByType(type);
    for (final ex in list) {
      if (!isExerciseCompleted(ex.id)) {
        return ex;
      }
    }
    SkillExerciseModel lowestEx = list.first;
    double lowestScore = 101.0;
    for (final ex in list) {
      final best = getBestScore(ex.id) ?? 0.0;
      if (best < lowestScore) {
        lowestScore = best;
        lowestEx = ex;
      }
    }
    return lowestEx;
  }

  /// Đề xuất bài luyện tập tiếp theo dựa trên lịch sử điểm thực tế trong SQLite
  SkillExerciseModel get recommendedNextExercise {
    final all = allExercises;
    for (final ex in all) {
      if (!isExerciseCompleted(ex.id)) {
        return ex;
      }
    }
    SkillExerciseModel lowestEx = all.first;
    double lowestScore = 101.0;
    for (final ex in all) {
      final best = getBestScore(ex.id) ?? 0.0;
      if (best < lowestScore) {
        lowestScore = best;
        lowestEx = ex;
      }
    }
    return lowestEx;
  }
}
