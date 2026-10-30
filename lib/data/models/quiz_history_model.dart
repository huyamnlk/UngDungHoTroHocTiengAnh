class QuizHistoryModel {
  final int id;
  final int? topicId;
  final String topicName;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final String completedAt;

  QuizHistoryModel({
    required this.id,
    this.topicId,
    required this.topicName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.completedAt,
  });

  factory QuizHistoryModel.fromMap(Map<String, dynamic> map) {
    return QuizHistoryModel(
      id: map['id'] as int,
      topicId: map['topic_id'] as int?,
      topicName: map['topic_name'] as String? ?? 'Tổng hợp',
      totalQuestions: map['total_questions'] as int,
      correctAnswers: map['correct_answers'] as int,
      scorePercentage: (map['score_percentage'] as num).toDouble(),
      completedAt: map['completed_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'topic_id': topicId,
      'topic_name': topicName,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'score_percentage': scorePercentage,
      'completed_at': completedAt,
    };
  }
}
