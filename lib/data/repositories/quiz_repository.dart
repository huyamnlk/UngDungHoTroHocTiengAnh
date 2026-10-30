import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/quiz_history_model.dart';
import '../models/quiz_question_model.dart';
import '../models/word_model.dart';

class QuizRepository {
  final DatabaseHelper _dbHelper;
  final Random _random = Random();

  QuizRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Tạo bộ câu hỏi trắc nghiệm từ danh sách từ vựng
  Future<List<QuizQuestionModel>> generateQuizQuestions({
    int? topicId,
    int numberOfQuestions = 5,
  }) async {
    final db = await _dbHelper.database;

    // 1. Lấy danh sách từ của chủ đề (hoặc tất cả)
    List<Map<String, dynamic>> targetRows;
    if (topicId != null && topicId > 0) {
      targetRows = await db.query(
        'words',
        where: 'topic_id = ?',
        whereArgs: [topicId],
      );
    } else {
      targetRows = await db.query(
        'words',
        orderBy: 'RANDOM()',
        limit: 100,
      );
    }

    if (targetRows.isEmpty) {
      return [];
    }

    // 2. Lấy mẫu từ ngẫu nhiên trong DB để làm đáp án nhiễu (distractors) mà không phải load cả 3.000 từ
    final distractorRows = await db.query(
      'words',
      orderBy: 'RANDOM()',
      limit: (numberOfQuestions * 4).clamp(40, 100),
    );
    final allWords = distractorRows.map((m) => WordModel.fromMap(m)).toList();
    final targetWords = targetRows.map((m) => WordModel.fromMap(m)).toList();

    // Xáo trộn danh sách từ nguồn
    targetWords.shuffle(_random);
    final selectedWords = targetWords.take(numberOfQuestions).toList();

    final List<QuizQuestionModel> questions = [];

    for (int i = 0; i < selectedWords.length; i++) {
      final word = selectedWords[i];
      // Chọn ngẫu nhiên loại câu hỏi
      final types = [
        QuizQuestionType.wordToMeaning,
        QuizQuestionType.meaningToWord,
        if (word.exampleEn.isNotEmpty && word.exampleEn.toLowerCase().contains(word.term.toLowerCase()))
          QuizQuestionType.fillBlank,
      ];
      final type = types[_random.nextInt(types.length)];

      late String prompt;
      String? secondaryPrompt;
      late String correctAnswer;
      late List<String> options;
      late String explanation;

      switch (type) {
        case QuizQuestionType.wordToMeaning:
          prompt = 'Nghĩa tiếng Việt của từ "${word.term}" là gì?';
          secondaryPrompt = word.ipa.isNotEmpty ? word.ipa : null;
          correctAnswer = word.meaning;

          // Lấy 3 distractors nghĩa
          final distractors = allWords
              .where((w) => w.id != word.id && w.meaning != word.meaning)
              .map((w) => w.meaning)
              .toSet()
              .toList()..shuffle(_random);

          final wrongOptions = distractors.take(3).toList();
          options = [correctAnswer, ...wrongOptions]..shuffle(_random);
          explanation = '${word.term} ${word.ipa} (${word.partOfSpeech}): ${word.meaning}';
          break;

        case QuizQuestionType.meaningToWord:
          prompt = 'Từ tiếng Anh nào mang nghĩa: "${word.meaning}"?';
          secondaryPrompt = 'Loại từ: ${word.partOfSpeech}';
          correctAnswer = word.term;

          // Lấy 3 distractors từ tiếng Anh
          final distractors = allWords
              .where((w) => w.id != word.id && w.term != word.term)
              .map((w) => w.term)
              .toSet()
              .toList()..shuffle(_random);

          final wrongOptions = distractors.take(3).toList();
          options = [correctAnswer, ...wrongOptions]..shuffle(_random);
          explanation = '${word.term} có nghĩa là "${word.meaning}". Ví dụ: ${word.exampleEn}';
          break;

        case QuizQuestionType.fillBlank:
          // Thay thế từ trong câu bằng _____
          final regex = RegExp(RegExp.escape(word.term), caseSensitive: false);
          prompt = word.exampleEn.replaceAll(regex, '_______');
          secondaryPrompt = 'Dịch nghĩa: ${word.exampleVi}';
          correctAnswer = word.term;

          final distractors = allWords
              .where((w) => w.id != word.id && w.term.toLowerCase() != word.term.toLowerCase())
              .map((w) => w.term)
              .toSet()
              .toList()..shuffle(_random);

          final wrongOptions = distractors.take(3).toList();
          options = [correctAnswer, ...wrongOptions]..shuffle(_random);
          explanation = 'Câu hoàn chỉnh: "${word.exampleEn}". Nghĩa: ${word.exampleVi}';
          break;
      }

      questions.add(
        QuizQuestionModel(
          id: i + 1,
          targetWord: word,
          type: type,
          prompt: prompt,
          secondaryPrompt: secondaryPrompt,
          options: options,
          correctAnswer: correctAnswer,
          explanation: explanation,
        ),
      );
    }

    return questions;
  }

  /// Lưu kết quả bài quiz vào lịch sử
  Future<int> saveQuizResult(QuizHistoryModel result) async {
    final db = await _dbHelper.database;
    return await db.insert('quiz_history', result.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Lấy toàn bộ lịch sử quiz
  Future<List<QuizHistoryModel>> getQuizHistory() async {
    final db = await _dbHelper.database;
    final results = await db.query('quiz_history', orderBy: 'id DESC', limit: 20);
    return results.map((m) => QuizHistoryModel.fromMap(m)).toList();
  }
}
