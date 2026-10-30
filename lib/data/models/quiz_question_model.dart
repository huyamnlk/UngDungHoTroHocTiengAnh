import 'word_model.dart';

enum QuizQuestionType {
  meaningToWord,  // Cho nghĩa tiếng Việt -> Chọn từ tiếng Anh
  wordToMeaning,  // Cho từ tiếng Anh -> Chọn nghĩa tiếng Việt
  fillBlank,      // Điền từ còn thiếu vào câu ví dụ
}

class QuizQuestionModel {
  final int id;
  final WordModel targetWord;
  final QuizQuestionType type;
  final String prompt;
  final String? secondaryPrompt; // Ví dụ IPA hoặc gợi ý
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  QuizQuestionModel({
    required this.id,
    required this.targetWord,
    required this.type,
    required this.prompt,
    this.secondaryPrompt,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}
