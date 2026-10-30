enum SkillType {
  listening,
  reading,
  writing,
  speaking,
}

class ContentAttribution {
  final String author;
  final String source;
  final String license;
  final String updatedAt;

  const ContentAttribution({
    this.author = 'English Buddy Editorial Team',
    this.source = 'Biên soạn gốc theo khung năng lực CEFR (Original Educational Content)',
    this.license = 'CC BY-NC-SA 4.0 (Nội bộ dự án học tập)',
    this.updatedAt = '2026-10',
  });

  factory ContentAttribution.fromMap(Map<String, dynamic> map) {
    return ContentAttribution(
      author: map['author'] as String? ?? 'English Buddy Editorial Team',
      source: map['source'] as String? ??
          'Biên soạn gốc theo khung năng lực CEFR (Original Educational Content)',
      license: map['license'] as String? ?? 'CC BY-NC-SA 4.0',
      updatedAt: map['updated_at'] as String? ?? '2026-10',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'source': source,
      'license': license,
      'updated_at': updatedAt,
    };
  }
}

class LessonKeyWord {
  final String term;
  final String ipa;
  final String partOfSpeech;
  final String meaning;
  final String example;

  const LessonKeyWord({
    required this.term,
    this.ipa = '',
    this.partOfSpeech = 'n/v',
    required this.meaning,
    this.example = '',
  });

  factory LessonKeyWord.fromMap(Map<String, dynamic> map) {
    return LessonKeyWord(
      term: map['term'] as String,
      ipa: map['ipa'] as String? ?? '',
      partOfSpeech: map['part_of_speech'] as String? ?? 'n/v',
      meaning: map['meaning'] as String,
      example: map['example'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'term': term,
      'ipa': ipa,
      'part_of_speech': partOfSpeech,
      'meaning': meaning,
      'example': example,
    };
  }
}

class WritingPromptTask {
  final String promptTitle;
  final String promptDescription;
  final int minWords;
  final List<String> targetKeywords;
  final List<String> rubricCriteria;
  final String sampleAnswer;

  const WritingPromptTask({
    required this.promptTitle,
    required this.promptDescription,
    this.minWords = 45,
    this.targetKeywords = const [],
    this.rubricCriteria = const [
      'Đáp ứng đúng trọng tâm yêu cầu đề bài (Task Achievement)',
      'Bố cục rõ ràng: có câu mở đầu, thân đoạn và câu kết (Coherence & Cohesion)',
      'Sử dụng đúng ngữ cảnh các từ vựng gợi ý (Lexical Resource)',
      'Viết câu đúng ngữ pháp, dấu câu và chính tả (Grammatical Range & Accuracy)',
    ],
    required this.sampleAnswer,
  });
}

class SkillQuestion {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String questionType; // 'mcq' or 'fill'
  final List<String> acceptedAnswers;

  const SkillQuestion({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.questionType = 'mcq',
    this.acceptedAnswers = const [],
  });

  bool get isFillBlank => questionType == 'fill';

  bool isTextAnswerCorrect(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    for (final ans in acceptedAnswers) {
      if (ans.trim().toLowerCase() == normalized) return true;
    }
    if (options.isNotEmpty &&
        correctOptionIndex >= 0 &&
        correctOptionIndex < options.length) {
      return options[correctOptionIndex].trim().toLowerCase() == normalized;
    }
    return false;
  }

  factory SkillQuestion.fromMap(Map<String, dynamic> map) {
    return SkillQuestion(
      questionText: map['question_text'] as String,
      options: List<String>.from(map['options'] as List? ?? const []),
      correctOptionIndex: map['correct_option_index'] as int? ?? 0,
      explanation: map['explanation'] as String? ?? '',
      questionType: map['question_type'] as String? ?? 'mcq',
      acceptedAnswers:
          List<String>.from(map['accepted_answers'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question_text': questionText,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'explanation': explanation,
      'question_type': questionType,
      'accepted_answers': acceptedAnswers,
    };
  }
}

class WritingSentence {
  final String englishSentence;
  final String vietnameseMeaning;
  final List<String> scrambledWords;
  final String hint;

  const WritingSentence({
    required this.englishSentence,
    required this.vietnameseMeaning,
    required this.scrambledWords,
    this.hint = '',
  });

  factory WritingSentence.fromMap(Map<String, dynamic> map) {
    return WritingSentence(
      englishSentence: map['english_sentence'] as String,
      vietnameseMeaning: map['vietnamese_meaning'] as String,
      scrambledWords: List<String>.from(map['scrambled_words'] as List),
      hint: map['hint'] as String? ?? '',
    );
  }
}

class SkillExerciseModel {
  final String id;
  final SkillType type;
  final String title;
  final String level; // A1, A2, B1, B2, C1
  final String topic;
  final String content; // Đoạn văn hoặc kịch bản đối thoại
  final String contentVi; // Bản dịch tiếng Việt
  final List<SkillQuestion> questions;
  final List<WritingSentence> writingSentences;
  final List<LessonKeyWord> keyWords;
  final WritingPromptTask? writingPromptTask;
  final ContentAttribution attribution;

  const SkillExerciseModel({
    required this.id,
    required this.type,
    required this.title,
    required this.level,
    required this.topic,
    required this.content,
    required this.contentVi,
    this.questions = const [],
    this.writingSentences = const [],
    this.keyWords = const [],
    this.writingPromptTask,
    this.attribution = const ContentAttribution(),
  });

  int get wordCount =>
      content.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;

  int get estimatedReadMinutes =>
      (wordCount / 120).ceil().clamp(1, 15);
}
