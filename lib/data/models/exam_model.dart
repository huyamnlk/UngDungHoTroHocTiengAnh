import 'dart:convert';
import 'skill_exercise_model.dart';

class ExamQuestion {
  final String id;
  final String sectionTitle;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String questionType; // 'mcq', 'fill', 'tfng', 'ynng', 'matching'
  final List<String> acceptedAnswers;
  final String explanation;
  final String targetSkill; // 'Listening', 'Reading', 'Grammar & Vocabulary', 'Writing Structure'
  final int? wordLimit; // Giới hạn số từ cho dạng điền từ (ví dụ: 1 hoặc 2)
  final String? paragraphRef; // Ví dụ: 'Paragraph A', 'Paragraph B'
  final String? evidenceQuote; // Câu trích dẫn bằng chứng trong bài

  const ExamQuestion({
    required this.id,
    this.sectionTitle = 'General Section',
    required this.questionText,
    this.options = const [],
    this.correctOptionIndex = 0,
    this.questionType = 'mcq',
    this.acceptedAnswers = const [],
    required this.explanation,
    this.targetSkill = 'Reading',
    this.wordLimit,
    this.paragraphRef,
    this.evidenceQuote,
  });

  bool get isFillBlank => questionType == 'fill';
  bool get isTfng => questionType == 'tfng';
  bool get isYnng => questionType == 'ynng';
  bool get isMatching => questionType == 'matching';

  bool isCorrectAnswer(dynamic userAnswer) {
    if (userAnswer == null) return false;
    if (isFillBlank) {
      final text = userAnswer.toString().trim().toLowerCase();
      if (text.isEmpty) return false;
      for (final accepted in acceptedAnswers) {
        if (accepted.trim().toLowerCase() == text) return true;
      }
      if (options.isNotEmpty &&
          correctOptionIndex >= 0 &&
          correctOptionIndex < options.length) {
        return options[correctOptionIndex].trim().toLowerCase() == text;
      }
      return false;
    } else {
      if (userAnswer is int) {
        return userAnswer == correctOptionIndex;
      }
      final parsed = int.tryParse(userAnswer.toString());
      return parsed != null && parsed == correctOptionIndex;
    }
  }

  String get correctAnswerDisplay {
    if (isFillBlank && acceptedAnswers.isNotEmpty) {
      return acceptedAnswers.join(' / ');
    }
    if (options.isNotEmpty &&
        correctOptionIndex >= 0 &&
        correctOptionIndex < options.length) {
      return options[correctOptionIndex];
    }
    return '';
  }
}

class ExamModel {
  final String id;
  final String title;
  final String category; // 'IELTS', 'TOEIC', 'CEFR'
  final String skillSection; // 'Reading', 'Listening', 'Writing & Grammar', 'Mini Mock Test'
  final String level; // 'A2-B1', 'B1-B2', 'B2-C1'
  final int durationMinutes;
  final String description;
  final String passageOrScript;
  final String transcriptVi;
  final bool hasAudioScript;
  final List<ExamQuestion> questions;
  final List<LessonKeyWord> keyWords;
  final ContentAttribution attribution;

  final String? ieltsModule; // 'Academic', 'General Training'
  final String? writingTaskType; // 'Task 1 Academic', 'Task 1 General', 'Task 2'
  final String? sampleResponseBand8;
  final String? examinerNotes;
  final String? chartType; // 'bar', 'line', 'pie', 'table', null
  final Map<String, dynamic>? chartData;

  const ExamModel({
    required this.id,
    required this.title,
    required this.category,
    required this.skillSection,
    required this.level,
    required this.durationMinutes,
    required this.description,
    required this.passageOrScript,
    required this.transcriptVi,
    this.hasAudioScript = false,
    required this.questions,
    this.keyWords = const [],
    this.ieltsModule,
    this.writingTaskType,
    this.sampleResponseBand8,
    this.examinerNotes,
    this.chartType,
    this.chartData,
    this.attribution = const ContentAttribution(
      author: 'English Buddy Academic Team',
      source:
          'Đề luyện tập biên soạn gốc mô phỏng dạng bài học thuật & công sở (Không sao chép đề thi bản quyền ETS/Cambridge)',
      license: 'CC BY-NC-SA 4.0 (Mục đích giáo dục)',
      updatedAt: '2026-10',
    ),
  });

  /// Ước tính Band Score IELTS tham khảo (1.0 - 9.0) dựa trên tỷ lệ câu đúng quy đổi sang thang 40 câu chuẩn
  static double calculateEstimatedIeltsBand(int correct, int total, {bool isGeneralReading = false}) {
    if (total <= 0 || correct <= 0) return 1.0;
    // Quy đổi số câu đúng sang thang 40 câu IELTS chuẩn
    final scaledCorrect = (correct / total * 40).round().clamp(0, 40);

    if (isGeneralReading) {
      if (scaledCorrect >= 39) return 9.0;
      if (scaledCorrect >= 37) return 8.5;
      if (scaledCorrect >= 36) return 8.0;
      if (scaledCorrect >= 34) return 7.5;
      if (scaledCorrect >= 32) return 7.0;
      if (scaledCorrect >= 29) return 6.5;
      if (scaledCorrect >= 26) return 6.0;
      if (scaledCorrect >= 22) return 5.5;
      if (scaledCorrect >= 18) return 5.0;
      if (scaledCorrect >= 15) return 4.5;
      if (scaledCorrect >= 12) return 4.0;
      if (scaledCorrect >= 9) return 3.5;
      return 3.0;
    } else {
      // Academic Reading / Listening
      if (scaledCorrect >= 39) return 9.0;
      if (scaledCorrect >= 37) return 8.5;
      if (scaledCorrect >= 35) return 8.0;
      if (scaledCorrect >= 33) return 7.5;
      if (scaledCorrect >= 30) return 7.0;
      if (scaledCorrect >= 27) return 6.5;
      if (scaledCorrect >= 23) return 6.0;
      if (scaledCorrect >= 19) return 5.5;
      if (scaledCorrect >= 15) return 5.0;
      if (scaledCorrect >= 13) return 4.5;
      if (scaledCorrect >= 10) return 4.0;
      if (scaledCorrect >= 8) return 3.5;
      return 3.0;
    }
  }
}

/// Mô hình phân tích 4 tiêu chí bài viết IELTS
class IeltsWritingEvaluation {
  final int wordCount;
  final int minWordTarget;
  final double taskAchievementScore;
  final double coherenceScore;
  final double lexicalScore;
  final double grammarScore;
  final double overallBand;
  final List<String> detectedLinkingWords;
  final List<String> academicVocabulary;
  final List<String> strengths;
  final List<String> improvements;

  const IeltsWritingEvaluation({
    required this.wordCount,
    required this.minWordTarget,
    required this.taskAchievementScore,
    required this.coherenceScore,
    required this.lexicalScore,
    required this.grammarScore,
    required this.overallBand,
    required this.detectedLinkingWords,
    required this.academicVocabulary,
    required this.strengths,
    required this.improvements,
  });

  static IeltsWritingEvaluation analyze(String text, {required int minWords}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const IeltsWritingEvaluation(
        wordCount: 0,
        minWordTarget: 150,
        taskAchievementScore: 1.0,
        coherenceScore: 1.0,
        lexicalScore: 1.0,
        grammarScore: 1.0,
        overallBand: 1.0,
        detectedLinkingWords: [],
        academicVocabulary: [],
        strengths: ['Chưa có nội dung bài viết.'],
        improvements: ['Hãy bắt đầu viết các ý chính theo đề bài.'],
      );
    }

    final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final wordCount = words.length;

    // Phân tích từ nối (Coherence & Cohesion)
    final linkingList = [
      'moreover', 'furthermore', 'in addition', 'on the other hand',
      'however', 'nevertheless', 'consequently', 'as a result',
      'for instance', 'for example', 'in contrast', 'whereas',
      'specifically', 'subsequently', 'therefore', 'overall',
      'in conclusion', 'firstly', 'secondly', 'finally',
      'to begin with', 'notably', 'in particular'
    ];
    final lowerText = trimmed.toLowerCase();
    final detectedLinks = <String>{};
    for (final lw in linkingList) {
      if (lowerText.contains(lw)) {
        detectedLinks.add(lw);
      }
    }

    // Phân tích từ vựng học thuật (Lexical Resource)
    final academicList = [
      'significant', 'substantially', 'illustrate', 'demonstrate',
      'fluctuation', 'proportion', 'exponentially', 'phenomenon',
      'perspective', 'sustainable', 'infrastructure', 'implication',
      'predominantly', 'dramatic', 'correlation', 'constitute',
      'implement', 'paradigm', 'comprehensive', 'facilitate'
    ];
    final detectedAcademic = <String>{};
    for (final aw in academicList) {
      if (lowerText.contains(aw)) {
        detectedAcademic.add(aw);
      }
    }

    // Tính điểm thành phần (Thang 1-9)
    // 1. Task Achievement: phạt nặng nếu dưới minWords
    double ta = 6.0;
    if (wordCount < minWords * 0.5) {
      ta = 3.5;
    } else if (wordCount < minWords * 0.8) {
      ta = 5.0;
    } else if (wordCount < minWords) {
      ta = 5.5;
    } else if (wordCount >= minWords + 50) {
      ta = 7.5;
    } else {
      ta = 6.5;
    }

    // 2. Coherence & Cohesion: dựa vào số từ nối và số đoạn văn
    final paragraphs = trimmed.split(RegExp(r'\n+')).where((p) => p.trim().isNotEmpty).length;
    double cc = 5.5;
    if (paragraphs >= 3 && detectedLinks.length >= 4) {
      cc = 7.0;
      if (detectedLinks.length >= 7) cc = 7.5;
    } else if (paragraphs >= 2 && detectedLinks.isNotEmpty) {
      cc = 6.0;
    } else if (paragraphs < 2) {
      cc = 5.0;
    }

    // 3. Lexical Resource: dựa vào từ học thuật và độ phong phú từ vựng
    final uniqueWords = words.map((w) => w.toLowerCase().replaceAll(RegExp(r'[^\w]'), '')).toSet().length;
    final diversity = wordCount > 0 ? (uniqueWords / wordCount) : 0.0;
    double lr = 5.5;
    if (detectedAcademic.length >= 4 && diversity > 0.5) {
      lr = 7.5;
    } else if (detectedAcademic.length >= 2 || diversity > 0.45) {
      lr = 6.5;
    } else {
      lr = 5.5;
    }

    // 4. Grammatical Range: câu phức, độ dài trung bình câu
    final sentences = trimmed.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).length;
    final avgSentenceLength = sentences > 0 ? wordCount / sentences : 0.0;
    double gr = 6.0;
    if (avgSentenceLength >= 14 && avgSentenceLength <= 26 && sentences >= 4) {
      gr = 7.0;
    } else if (avgSentenceLength < 8) {
      gr = 5.0; // Câu quá ngắn, cấu trúc đơn giản
    }

    final overall = ((ta + cc + lr + gr) / 4.0 * 2).round() / 2.0;

    final strengths = <String>[];
    final improvements = <String>[];

    if (wordCount >= minWords) {
      strengths.add('Đạt yêu cầu độ dài tối thiểu ($wordCount/$minWords từ).');
    } else {
      improvements.add('Bài viết thiếu ${minWords - wordCount} từ so với mục tiêu $minWords từ.');
    }

    if (detectedLinks.length >= 3) {
      strengths.add('Sử dụng đa dạng từ nối liên kết ý (${detectedLinks.join(", ")}).');
    } else {
      improvements.add('Cần bổ sung thêm từ nối học thuật để tăng tính mạch lạc (Coherence).');
    }

    if (detectedAcademic.isNotEmpty) {
      strengths.add('Có sử dụng vốn từ vựng học thuật ghi điểm: ${detectedAcademic.take(4).join(", ")}.');
    } else {
      improvements.add('Hãy bổ sung các từ vựng trang trọng, chuyên ngành thay cho từ thông dụng.');
    }

    if (paragraphs >= 3) {
      strengths.add('Bố cục chia đoạn rõ ràng ($paragraphs đoạn: Mở bài, Thân bài, Kết luận/Tổng quan).');
    } else {
      improvements.add('Nên phân tách bài viết thành ít nhất 3-4 đoạn văn để đạt chuẩn IELTS.');
    }

    return IeltsWritingEvaluation(
      wordCount: wordCount,
      minWordTarget: minWords,
      taskAchievementScore: ta,
      coherenceScore: cc,
      lexicalScore: lr,
      grammarScore: gr,
      overallBand: overall.clamp(1.0, 9.0),
      detectedLinkingWords: detectedLinks.toList(),
      academicVocabulary: detectedAcademic.toList(),
      strengths: strengths,
      improvements: improvements,
    );
  }
}

class ExamAttemptModel {
  final int? id;
  final String examId;
  final String examTitle;
  final String examCategory;
  final String skillSection;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final int durationSeconds;
  final Map<String, dynamic> userAnswers;
  final String completedAt;

  const ExamAttemptModel({
    this.id,
    required this.examId,
    required this.examTitle,
    required this.examCategory,
    required this.skillSection,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.durationSeconds,
    this.userAnswers = const {},
    required this.completedAt,
  });

  factory ExamAttemptModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> parsedAnswers = {};
    final rawJson = map['answers_json'] as String? ?? '';
    if (rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson);
        if (decoded is Map<String, dynamic>) {
          parsedAnswers = decoded;
        }
      } catch (_) {}
    }

    return ExamAttemptModel(
      id: map['id'] as int?,
      examId: map['exam_id'] as String? ?? '',
      examTitle: map['exam_title'] as String? ?? '',
      examCategory: map['exam_category'] as String? ?? 'CEFR',
      skillSection: map['skill_section'] as String? ?? 'General',
      totalQuestions: (map['total_questions'] as num?)?.toInt() ?? 0,
      correctAnswers: (map['correct_answers'] as num?)?.toInt() ?? 0,
      scorePercentage: (map['score_percentage'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 0,
      userAnswers: parsedAnswers,
      completedAt: map['completed_at'] as String? ?? '',
    );
  }

  /// Nhận xét năng lực minh bạch dựa trên tỷ lệ đúng thực tế (Không quy đổi điểm thi chuẩn hóa giả tạo)
  String get competencyFeedback {
    if (scorePercentage >= 85) {
      return 'Nắm vững dạng bài ($correctAnswers/$totalQuestions câu đúng). Bạn xử lý tốt cả câu hỏi thông tin chi tiết, từ vựng học thuật và suy luận ngữ cảnh.';
    } else if (scorePercentage >= 65) {
      return 'Mức độ Khá ($correctAnswers/$totalQuestions câu đúng). Bạn nắm được ý chính nhưng cần chú ý các bẫy từ đồng nghĩa (paraphrase) và chi tiết phủ định.';
    } else if (scorePercentage >= 45) {
      return 'Mức độ Đạt yêu cầu cơ bản ($correctAnswers/$totalQuestions câu đúng). Hãy đọc kỹ giải thích từng câu sai và lưu lại các từ vựng trọng tâm trong bài.';
    } else {
      return 'Cần củng cố nền tảng ($correctAnswers/$totalQuestions câu đúng). Bạn nên ôn lại từ vựng của bài trước khi làm lại đề với thời gian thoải mái hơn.';
    }
  }
}
