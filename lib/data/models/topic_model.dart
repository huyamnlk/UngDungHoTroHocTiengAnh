class TopicModel {
  final int id;
  final String name;
  final String iconName;
  final String colorHex;
  final String description;
  final int totalWords;
  final int masteredWords;

  const TopicModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.description,
    this.totalWords = 0,
    this.masteredWords = 0,
  });

  factory TopicModel.fromMap(Map<String, dynamic> map, {int total = 0, int mastered = 0}) {
    return TopicModel(
      id: map['id'] as int,
      name: map['name'] as String,
      iconName: map['icon_name'] as String? ?? 'book',
      colorHex: map['color_hex'] as String? ?? '#4361EE',
      description: map['description'] as String? ?? '',
      totalWords: (map['total_words'] as int?) ?? total,
      masteredWords: (map['mastered_words'] as int?) ?? mastered,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'color_hex': colorHex,
      'description': description,
    };
  }

  double get progressPercentage {
    if (totalWords == 0) return 0.0;
    return (masteredWords / totalWords).clamp(0.0, 1.0);
  }

  TopicModel copyWith({
    int? id,
    String? name,
    String? iconName,
    String? colorHex,
    String? description,
    int? totalWords,
    int? masteredWords,
  }) {
    return TopicModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      description: description ?? this.description,
      totalWords: totalWords ?? this.totalWords,
      masteredWords: masteredWords ?? this.masteredWords,
    );
  }
}
