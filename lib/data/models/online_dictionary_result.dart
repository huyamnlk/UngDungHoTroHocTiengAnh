class OnlineDefinition {
  final String partOfSpeech;
  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  const OnlineDefinition({
    required this.partOfSpeech,
    required this.definition,
    this.example,
    this.synonyms = const [],
    this.antonyms = const [],
  });

  factory OnlineDefinition.fromMap(Map<String, dynamic> map) {
    return OnlineDefinition(
      partOfSpeech: map['partOfSpeech'] as String? ?? '',
      definition: map['definition'] as String? ?? '',
      example: map['example'] as String?,
      synonyms: map['synonyms'] != null
          ? List<String>.from(map['synonyms'] as List)
          : const [],
      antonyms: map['antonyms'] != null
          ? List<String>.from(map['antonyms'] as List)
          : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partOfSpeech': partOfSpeech,
      'definition': definition,
      'example': example,
      'synonyms': synonyms,
      'antonyms': antonyms,
    };
  }
}

class OnlineDictionaryResult {
  final String word; // Từ tiếng Anh mục tiêu (hoặc từ chính)
  final String? originalQuery; // Truy vấn ban đầu của người dùng
  final String? phonetic;
  final String? audioUrl;
  final List<OnlineDefinition> definitions;
  final String sourceName;
  final String sourceUrl;
  final String license;
  final bool isFromCache;
  final String? vietnameseTranslation;
  final String queryDirection; // 'vi_en' hoặc 'en_vi'
  final List<String> alternativeTranslations;

  const OnlineDictionaryResult({
    required this.word,
    this.originalQuery,
    this.phonetic,
    this.audioUrl,
    required this.definitions,
    this.sourceName = 'Free Dictionary API (Wiktionary)',
    this.sourceUrl = 'https://en.wiktionary.org',
    this.license = 'CC BY-SA 3.0',
    this.isFromCache = false,
    this.vietnameseTranslation,
    this.queryDirection = 'en_vi',
    this.alternativeTranslations = const [],
  });

  bool get isVietnameseToEnglish => queryDirection == 'vi_en';
  bool get isEnglishToVietnamese => queryDirection == 'en_vi';

  String get displayQuery => originalQuery ?? word;

  OnlineDictionaryResult copyWith({
    String? word,
    String? originalQuery,
    bool? isFromCache,
    String? phonetic,
    String? audioUrl,
    String? vietnameseTranslation,
    String? queryDirection,
    List<String>? alternativeTranslations,
    List<OnlineDefinition>? definitions,
    String? sourceName,
    String? sourceUrl,
    String? license,
  }) {
    return OnlineDictionaryResult(
      word: word ?? this.word,
      originalQuery: originalQuery ?? this.originalQuery,
      phonetic: phonetic ?? this.phonetic,
      audioUrl: audioUrl ?? this.audioUrl,
      definitions: definitions ?? this.definitions,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      license: license ?? this.license,
      isFromCache: isFromCache ?? this.isFromCache,
      vietnameseTranslation:
          vietnameseTranslation ?? this.vietnameseTranslation,
      queryDirection: queryDirection ?? this.queryDirection,
      alternativeTranslations:
          alternativeTranslations ?? this.alternativeTranslations,
    );
  }

  factory OnlineDictionaryResult.fromJson(
    Map<String, dynamic> json, {
    bool isFromCache = false,
  }) {
    String? audio;
    String? fallbackPhonetic = json['phonetic'] as String?;
    if (json['phonetics'] != null && json['phonetics'] is List) {
      for (final p in json['phonetics']) {
        if (p is Map) {
          if ((fallbackPhonetic == null || fallbackPhonetic.isEmpty) &&
              p['text'] != null &&
              (p['text'] as String).isNotEmpty) {
            fallbackPhonetic = p['text'] as String;
          }
          if (p['audio'] != null && (p['audio'] as String).isNotEmpty) {
            audio = p['audio'] as String;
            break;
          }
        }
      }
    }

    final List<OnlineDefinition> defs = [];
    if (json['meanings'] != null && json['meanings'] is List) {
      for (final m in json['meanings']) {
        final pos = m['partOfSpeech'] as String? ?? '';
        final mealSyns = m['synonyms'] != null
            ? List<String>.from(m['synonyms'] as List)
            : <String>[];
        final definitionsList = m['definitions'] as List? ?? [];
        for (final d in definitionsList) {
          final defSyns = d['synonyms'] != null
              ? List<String>.from(d['synonyms'] as List)
              : <String>[];
          defs.add(
            OnlineDefinition(
              partOfSpeech: pos,
              definition: d['definition'] as String? ?? '',
              example: d['example'] as String?,
              synonyms: {...defSyns, ...mealSyns}.take(5).toList(),
              antonyms: d['antonyms'] != null
                  ? List<String>.from(d['antonyms'] as List)
                  : const [],
            ),
          );
        }
      }
    }

    String licenseName = 'CC BY-SA 3.0';
    if (json['license'] is Map && json['license']['name'] != null) {
      licenseName = json['license']['name'].toString();
    }

    String srcUrl = 'https://en.wiktionary.org';
    if (json['sourceUrls'] is List && (json['sourceUrls'] as List).isNotEmpty) {
      srcUrl = (json['sourceUrls'] as List).first.toString();
    }

    return OnlineDictionaryResult(
      word: json['word'] as String? ?? '',
      phonetic: fallbackPhonetic,
      audioUrl: audio,
      definitions: defs,
      sourceName: 'Free Dictionary API / Wiktionary',
      sourceUrl: srcUrl,
      license: licenseName,
      isFromCache: isFromCache,
      queryDirection: 'en_vi',
      alternativeTranslations: const [],
    );
  }

  factory OnlineDictionaryResult.fromWiktionaryJson(
    String word,
    Map<String, dynamic> json, {
    bool isFromCache = false,
  }) {
    final List<OnlineDefinition> defs = [];
    final cleanWord = word.trim();

    // Wikimedia Wiktionary definition endpoint groups by language code, e.g. "en", "vi"
    for (final lang in ['en', 'vi']) {
      final langList = json[lang];
      if (langList is List) {
        for (final item in langList) {
          if (item is Map) {
            final pos = (item['partOfSpeech'] as String? ?? '').toLowerCase();
            final rawDefs = item['definitions'] as List? ?? [];
            for (final d in rawDefs) {
              if (d is Map) {
                final rawDef = d['definition'] as String? ?? '';
                // Loại bỏ các thẻ HTML trong nội dung Wiktionary
                final cleanDef =
                    rawDef.replaceAll(RegExp(r'<[^>]*>'), '').trim();
                String? example;
                if (d['examples'] is List && (d['examples'] as List).isNotEmpty) {
                  final rawEx = (d['examples'] as List).first.toString();
                  example = rawEx.replaceAll(RegExp(r'<[^>]*>'), '').trim();
                }
                if (cleanDef.isNotEmpty) {
                  defs.add(OnlineDefinition(
                    partOfSpeech: pos,
                    definition: cleanDef,
                    example: example?.isNotEmpty == true ? example : null,
                  ));
                }
              }
            }
          }
        }
      }
    }

    return OnlineDictionaryResult(
      word: cleanWord,
      phonetic: null,
      audioUrl: null,
      definitions: defs,
      sourceName: 'Wiktionary (Wikimedia REST API)',
      sourceUrl:
          'https://en.wiktionary.org/wiki/${Uri.encodeComponent(cleanWord)}',
      license: 'CC BY-SA 3.0',
      isFromCache: isFromCache,
      queryDirection: 'en_vi',
      alternativeTranslations: const [],
    );
  }

  factory OnlineDictionaryResult.fromTranslationJson({
    required String query,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
    required List<dynamic> gtxData,
    String? phonetic,
    List<OnlineDefinition>? extraDefinitions,
    bool isFromCache = false,
  }) {
    final queryDirection = sourceLang == 'vi' ? 'vi_en' : 'en_vi';
    final List<String> alternatives = [];
    final List<OnlineDefinition> defs = [];

    if (gtxData.length > 1 && gtxData[1] is List) {
      for (final group in gtxData[1]) {
        if (group is List && group.isNotEmpty) {
          final pos = group[0].toString();
          final words = group.length > 1 && group[1] is List
              ? List<String>.from(group[1] as List)
              : <String>[];
          alternatives.addAll(words);
          if (words.isNotEmpty) {
            defs.add(OnlineDefinition(
              partOfSpeech: pos,
              definition: words.join(', '),
            ));
          }
        }
      }
    }

    if (extraDefinitions != null && extraDefinitions.isNotEmpty) {
      defs.addAll(extraDefinitions);
    }

    final uniqueAlts = <String>[];
    for (final a in [translatedText, ...alternatives]) {
      final clean = a.trim();
      if (clean.isNotEmpty &&
          !uniqueAlts.any((u) => u.toLowerCase() == clean.toLowerCase())) {
        uniqueAlts.add(clean);
      }
    }

    final primaryEnglish = queryDirection == 'vi_en'
        ? (translatedText.trim().isNotEmpty ? translatedText.trim() : query.trim())
        : query.trim();

    final primaryVietnamese = queryDirection == 'vi_en'
        ? query.trim()
        : (translatedText.trim().isNotEmpty ? translatedText.trim() : query.trim());

    return OnlineDictionaryResult(
      word: primaryEnglish,
      originalQuery: query.trim(),
      phonetic: phonetic,
      audioUrl: null,
      definitions: defs,
      sourceName: 'Google Translate / Wiktionary',
      sourceUrl: queryDirection == 'vi_en'
          ? 'https://translate.google.com/?sl=vi&tl=en&text=${Uri.encodeComponent(query)}'
          : 'https://en.wiktionary.org/wiki/${Uri.encodeComponent(primaryEnglish)}',
      license: 'CC BY-SA 3.0 / Fair Educational Use',
      isFromCache: isFromCache,
      vietnameseTranslation: primaryVietnamese,
      queryDirection: queryDirection,
      alternativeTranslations: uniqueAlts,
    );
  }

  factory OnlineDictionaryResult.fromCacheMap(
    Map<String, dynamic> map, {
    bool isFromCache = true,
  }) {
    final defsRaw = map['definitions'] as List? ?? const [];
    return OnlineDictionaryResult(
      word: map['word'] as String? ?? '',
      originalQuery: map['originalQuery'] as String?,
      phonetic: map['phonetic'] as String?,
      audioUrl: map['audioUrl'] as String?,
      definitions: defsRaw
          .map((d) =>
              OnlineDefinition.fromMap(Map<String, dynamic>.from(d as Map)))
          .toList(),
      sourceName:
          map['sourceName'] as String? ?? 'Free Dictionary API / Wiktionary',
      sourceUrl: map['sourceUrl'] as String? ?? 'https://en.wiktionary.org',
      license: map['license'] as String? ?? 'CC BY-SA 3.0',
      isFromCache: isFromCache,
      vietnameseTranslation: map['vietnameseTranslation'] as String?,
      queryDirection: map['queryDirection'] as String? ?? 'en_vi',
      alternativeTranslations: map['alternativeTranslations'] != null
          ? List<String>.from(map['alternativeTranslations'] as List)
          : const [],
    );
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'word': word,
      'originalQuery': originalQuery,
      'phonetic': phonetic,
      'audioUrl': audioUrl,
      'definitions': definitions.map((d) => d.toMap()).toList(),
      'sourceName': sourceName,
      'sourceUrl': sourceUrl,
      'license': license,
      'vietnameseTranslation': vietnameseTranslation,
      'queryDirection': queryDirection,
      'alternativeTranslations': alternativeTranslations,
    };
  }
}
