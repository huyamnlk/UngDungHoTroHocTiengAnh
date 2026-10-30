import 'skill_exercise_model.dart';

class ShadowingSegment {
  final String id;
  final String englishText;
  final String phoneticStress; // Ký hiệu IPA + Trọng âm từ (IN HOA) + Ngữ điệu (↗ ↘)
  final String vietnameseMeaning;
  final String coachingTip;
  final int targetDurationSeconds;

  const ShadowingSegment({
    required this.id,
    required this.englishText,
    required this.phoneticStress,
    required this.vietnameseMeaning,
    required this.coachingTip,
    this.targetDurationSeconds = 5,
  });
}

class ShadowingLessonModel {
  final String id;
  final String title;
  final String topic;
  final String level; // A1, A2, B1, B2, C1
  final String description;
  final List<ShadowingSegment> segments;
  final ContentAttribution attribution;

  const ShadowingLessonModel({
    required this.id,
    required this.title,
    required this.topic,
    required this.level,
    required this.description,
    required this.segments,
    this.attribution = const ContentAttribution(
      author: 'English Buddy Phonetics Team',
      source: 'Biên soạn gốc theo phương pháp Shadowing & Prosody CEFR A1–C1',
      license: 'CC BY-NC-SA 4.0 (Nội bộ dự án học tập)',
      updatedAt: '2026-10',
    ),
  });

  String get fullTranscript =>
      segments.map((s) => s.englishText).join(' ');

  String get fullTranslationVi =>
      segments.map((s) => s.vietnameseMeaning).join(' ');
}
