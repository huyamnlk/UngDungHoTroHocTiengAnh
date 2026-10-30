import '../../core/constants/app_constants.dart';

class WordModel {
  final int id;
  final int topicId;
  final String term;
  final String ipa;
  final String partOfSpeech;
  final String meaning;
  final String englishDefinition;
  final String exampleEn;
  final String exampleVi;
  final String pronunciationGuide;
  final String level; // A1, A2, B1, B2, C1
  final String itemType; // word, phrasal_verb, collocation, idiom
  final String synonyms;
  final String antonyms;
  final bool isFavorite;
  final String status; // 'new', 'learning', 'mastered'
  final int reviewCount;
  final String? lastReviewedAt;
  final String? nextReviewAt;
  final int intervalDays;

  const WordModel({
    required this.id,
    required this.topicId,
    required this.term,
    required this.ipa,
    required this.partOfSpeech,
    required this.meaning,
    this.englishDefinition = '',
    required this.exampleEn,
    required this.exampleVi,
    this.pronunciationGuide = '',
    this.level = 'B1',
    this.itemType = 'word',
    this.synonyms = '',
    this.antonyms = '',
    this.isFavorite = false,
    this.status = AppConstants.statusNew,
    this.reviewCount = 0,
    this.lastReviewedAt,
    this.nextReviewAt,
    this.intervalDays = 1,
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'] as int? ?? 0,
      topicId: map['topic_id'] as int? ?? 1,
      term: map['term'] as String? ?? '',
      ipa: map['ipa'] as String? ?? '',
      partOfSpeech: map['part_of_speech'] as String? ?? '',
      meaning: map['meaning'] as String? ?? '',
      englishDefinition: map['english_definition'] as String? ?? '',
      exampleEn: map['example_en'] as String? ?? '',
      exampleVi: map['example_vi'] as String? ?? '',
      pronunciationGuide: map['pronunciation_guide'] as String? ?? '',
      level: map['level'] as String? ?? 'B1',
      itemType: map['item_type'] as String? ?? 'word',
      synonyms: map['synonyms'] as String? ?? '',
      antonyms: map['antonyms'] as String? ?? '',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      status: map['status'] as String? ?? AppConstants.statusNew,
      reviewCount: map['review_count'] as int? ?? 0,
      lastReviewedAt: map['last_reviewed_at'] as String?,
      nextReviewAt: map['next_review_at'] as String?,
      intervalDays: map['interval_days'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'topic_id': topicId,
      'term': term,
      'ipa': ipa,
      'part_of_speech': partOfSpeech,
      'meaning': meaning,
      'english_definition': englishDefinition,
      'example_en': exampleEn,
      'example_vi': exampleVi,
      'pronunciation_guide': pronunciationGuide,
      'level': level,
      'item_type': itemType,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'is_favorite': isFavorite ? 1 : 0,
      'status': status,
      'review_count': reviewCount,
      'last_reviewed_at': lastReviewedAt,
      'next_review_at': nextReviewAt,
      'interval_days': intervalDays,
    };
  }

  bool get isMastered => status == AppConstants.statusMastered;
  bool get isLearning => status == AppConstants.statusLearning;
  bool get isNew => status == AppConstants.statusNew;

  WordModel copyWith({
    int? id,
    int? topicId,
    String? term,
    String? ipa,
    String? partOfSpeech,
    String? meaning,
    String? englishDefinition,
    String? exampleEn,
    String? exampleVi,
    String? pronunciationGuide,
    String? level,
    String? itemType,
    String? synonyms,
    String? antonyms,
    bool? isFavorite,
    String? status,
    int? reviewCount,
    String? lastReviewedAt,
    String? nextReviewAt,
    int? intervalDays,
  }) {
    return WordModel(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      term: term ?? this.term,
      ipa: ipa ?? this.ipa,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      meaning: meaning ?? this.meaning,
      englishDefinition: englishDefinition ?? this.englishDefinition,
      exampleEn: exampleEn ?? this.exampleEn,
      exampleVi: exampleVi ?? this.exampleVi,
      pronunciationGuide: pronunciationGuide ?? this.pronunciationGuide,
      level: level ?? this.level,
      itemType: itemType ?? this.itemType,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      isFavorite: isFavorite ?? this.isFavorite,
      status: status ?? this.status,
      reviewCount: reviewCount ?? this.reviewCount,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      intervalDays: intervalDays ?? this.intervalDays,
    );
  }
}
