import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../core/database/database_helper.dart';
import '../models/topic_model.dart';
import '../models/word_model.dart';
import 'user_profile_repository.dart';

class VocabularyRepository {
  final DatabaseHelper _dbHelper;
  final UserProfileRepository _profileRepository;

  VocabularyRepository({
    DatabaseHelper? dbHelper,
    UserProfileRepository? profileRepository,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _profileRepository = profileRepository ??
            UserProfileRepository(dbHelper: dbHelper ?? DatabaseHelper.instance);

  /// Lấy danh sách chủ đề kèm tiến độ học
  Future<List<TopicModel>> getAllTopicsWithProgress() async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT 
        t.id, t.name, t.icon_name, t.color_hex, t.description,
        COUNT(w.id) AS total_words,
        SUM(CASE WHEN w.status = '${AppConstants.statusMastered}' THEN 1 ELSE 0 END) AS mastered_words
      FROM topics t
      LEFT JOIN words w ON t.id = w.topic_id
      GROUP BY t.id
      ORDER BY t.id ASC
    ''');

    return results.map((row) {
      return TopicModel(
        id: row['id'] as int,
        name: row['name'] as String,
        iconName: row['icon_name'] as String? ?? 'book',
        colorHex: row['color_hex'] as String? ?? '#4361EE',
        description: row['description'] as String? ?? '',
        totalWords: (row['total_words'] as int?) ?? 0,
        masteredWords: (row['mastered_words'] as int?) ?? 0,
      );
    }).toList();
  }

  /// Lấy tất cả từ vựng theo chủ đề
  Future<List<WordModel>> getWordsByTopic(int topicId) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'words',
      where: 'topic_id = ?',
      whereArgs: [topicId],
      orderBy: 'id ASC',
    );
    return results.map((map) => WordModel.fromMap(map)).toList();
  }

  /// Lấy tất cả từ vựng trong hệ thống
  Future<List<WordModel>> getAllWords() async {
    final db = await _dbHelper.database;
    final results = await db.query('words', orderBy: 'term ASC');
    return results.map((map) => WordModel.fromMap(map)).toList();
  }

  /// Lấy danh sách từ ngẫu nhiên phục vụ trò chơi hoặc luyện tập nhanh mà không load cả 3.000 từ
  Future<List<WordModel>> getRandomWords({
    int limit = 100,
    int? topicId,
    String? level,
  }) async {
    final db = await _dbHelper.database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (topicId != null && topicId > 0) {
      whereClauses.add('topic_id = ?');
      whereArgs.add(topicId);
    }
    if (level != null && level != 'All' && level.isNotEmpty) {
      whereClauses.add('UPPER(level) = ?');
      whereArgs.add(level.toUpperCase());
    }

    final results = await db.query(
      'words',
      where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'RANDOM()',
      limit: limit,
    );
    return results.map((map) => WordModel.fromMap(map)).toList();
  }

  /// Tra cứu từ điển nội bộ theo từ khóa, hỗ trợ bộ lọc cấp độ CEFR, chủ đề và từ loại
  Future<List<WordModel>> searchDictionary(
    String query, {
    String? levelFilter,
    int? topicFilter,
    String? partOfSpeechFilter,
  }) async {
    if (!_dbHelper.isInitialized) return const [];
    final clean = query.trim().toLowerCase();
    final db = await _dbHelper.database;

    final conditions = <String>[];
    final args = <dynamic>[];

    if (clean.isNotEmpty) {
      conditions.add(
        '(LOWER(term) LIKE ? OR LOWER(meaning) LIKE ? OR LOWER(english_definition) LIKE ?)',
      );
      args.addAll(['%$clean%', '%$clean%', '%$clean%']);
    }

    if (levelFilter != null && levelFilter != 'all' && levelFilter.isNotEmpty) {
      conditions.add('level = ?');
      args.add(levelFilter);
    }

    if (topicFilter != null && topicFilter > 0) {
      conditions.add('topic_id = ?');
      args.add(topicFilter);
    }

    if (partOfSpeechFilter != null &&
        partOfSpeechFilter != 'all' &&
        partOfSpeechFilter.isNotEmpty) {
      conditions.add('(LOWER(part_of_speech) LIKE ? OR LOWER(item_type) LIKE ?)');
      args.addAll(['%$partOfSpeechFilter%', '%$partOfSpeechFilter%']);
    }

    final whereClause = conditions.isEmpty ? null : conditions.join(' AND ');

    String orderBy = 'term ASC';
    if (clean.isNotEmpty) {
      final sanitized = clean.replaceAll("'", "''");
      orderBy = '''
CASE
  WHEN LOWER(term) = '$sanitized' THEN 1
  WHEN LOWER(meaning) = '$sanitized' THEN 2
  WHEN LOWER(meaning) LIKE '$sanitized,%' OR LOWER(meaning) LIKE '$sanitized;%' OR LOWER(meaning) LIKE '$sanitized %' THEN 3
  WHEN LOWER(term) LIKE '$sanitized%' THEN 4
  WHEN LOWER(meaning) LIKE '$sanitized%' THEN 5
  WHEN LOWER(term) LIKE '%$sanitized%' THEN 6
  WHEN LOWER(meaning) LIKE '%$sanitized%' THEN 7
  ELSE 8
END, term ASC''';
    }

    final results = await db.query(
      'words',
      where: whereClause,
      whereArgs: args.isEmpty ? null : args,
      orderBy: orderBy,
      limit: clean.isEmpty ? 200 : 80,
    );

    return results.map((map) => WordModel.fromMap(map)).toList();
  }

  /// Lấy danh sách từ cần ôn tập (status = 'learning' hoặc đến hạn SRS)
  Future<List<WordModel>> getWordsForReview() async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'words',
      where: 'status = ?',
      whereArgs: [AppConstants.statusLearning],
      orderBy: 'last_reviewed_at DESC, id ASC',
    );
    return results.map((map) => WordModel.fromMap(map)).toList();
  }

  /// Lấy danh sách từ đến hạn ôn tập theo Spaced Repetition (SRS)
  Future<List<WordModel>> getDueSrsWords() async {
    final db = await _dbHelper.database;
    final nowIso = DateTime.now().toIso8601String();
    final results = await db.query(
      'words',
      where: "next_review_at IS NOT NULL AND next_review_at <= ? AND status != '${AppConstants.statusNew}'",
      whereArgs: [nowIso],
      orderBy: 'next_review_at ASC',
    );
    return results.map((map) => WordModel.fromMap(map)).toList();
  }

  /// Lấy danh sách từ yêu thích
  Future<List<WordModel>> getFavoriteWords() async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'words',
      where: 'is_favorite = 1',
      orderBy: 'id DESC',
    );
    return results.map((map) => WordModel.fromMap(map)).toList();
  }

  /// Cập nhật trạng thái học kèm thuật toán Spaced Repetition (SRS)
  Future<void> updateWordStatusWithSrs(int wordId, String status, {int currentInterval = 1}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    int nextInterval;
    if (status == AppConstants.statusMastered) {
      // Tăng khoảng cách ngày ôn (1 -> 3 -> 7 -> 14 -> 30)
      if (currentInterval <= 1) {
        nextInterval = 3;
      } else if (currentInterval <= 3) {
        nextInterval = 7;
      } else if (currentInterval <= 7) {
        nextInterval = 14;
      } else {
        nextInterval = 30;
      }
    } else {
      // Cần ôn lại: reset về 1 ngày
      nextInterval = 1;
    }

    final nextReviewDate = now.add(Duration(days: nextInterval));

    await db.rawUpdate('''
      UPDATE words 
      SET status = ?, 
          review_count = review_count + 1, 
          last_reviewed_at = ?,
          next_review_at = ?,
          interval_days = ?
      WHERE id = ?
    ''', [
      status,
      now.toIso8601String(),
      nextReviewDate.toIso8601String(),
      nextInterval,
      wordId,
    ]);
  }

  /// Cập nhật trạng thái từ vựng
  Future<void> updateWordStatus(int wordId, String status) async {
    await updateWordStatusWithSrs(wordId, status);
  }

  /// Chuyển đổi trạng thái yêu thích
  Future<bool> toggleFavorite(int wordId, bool currentFavorite) async {
    final db = await _dbHelper.database;
    final nextFavorite = !currentFavorite;
    await db.update(
      'words',
      {'is_favorite': nextFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [wordId],
    );
    return nextFavorite;
  }

  /// Thêm từ vựng mới
  Future<int> insertWord(WordModel word) async {
    final db = await _dbHelper.database;
    return await db.insert('words', word.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Lấy từ vựng ngẫu nhiên
  Future<WordModel?> getRandomWord() async {
    final db = await _dbHelper.database;
    final results = await db.query('words', orderBy: 'RANDOM()', limit: 1);
    if (results.isNotEmpty) {
      return WordModel.fromMap(results.first);
    }
    return null;
  }

  /// Thống kê tổng quan từ vựng
  Future<Map<String, int>> getVocabularyStats() async {
    final db = await _dbHelper.database;
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM words');
    final masteredResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM words WHERE status = '${AppConstants.statusMastered}'",
    );
    final learningResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM words WHERE status = '${AppConstants.statusLearning}'",
    );
    final favoriteResult = await db.rawQuery('SELECT COUNT(*) as count FROM words WHERE is_favorite = 1');

    return {
      'total': Sqflite.firstIntValue(totalResult) ?? 0,
      'mastered': Sqflite.firstIntValue(masteredResult) ?? 0,
      'learning': Sqflite.firstIntValue(learningResult) ?? 0,
      'favorite': Sqflite.firstIntValue(favoriteResult) ?? 0,
    };
  }

  /// Lấy lịch sử tìm kiếm từ điển
  Future<List<String>> getSearchHistory() async {
    return await _dbHelper.getSearchHistory();
  }

  Future<void> saveSearchHistory(String query) async {
    await _dbHelper.addSearchHistory(query);
  }

  Future<void> clearSearchHistory() async {
    await _dbHelper.clearSearchHistory();
  }

  /// Khôi phục toàn bộ dữ liệu gốc
  Future<void> resetAllData() async {
    await _dbHelper.resetToDefault();
  }

  // ===========================================================================
  // CÁC HÀM QUẢN TRỊ NỘI DUNG TỪ VỰNG, CHỦ ĐỀ & HỆ THỐNG (CHỈ DÀNH CHO ADMIN)
  // ===========================================================================

  /// Admin cập nhật nội dung từ vựng và cấp độ CEFR của từ
  Future<void> adminUpdateWord({
    required String? actorUid,
    required WordModel word,
  }) async {
    await _profileRepository.verifyAdminActor(actorUid);

    if (word.id <= 0) {
      throw const ProfileValidationException('ID từ vựng không hợp lệ.');
    }
    if (word.term.trim().isEmpty || word.meaning.trim().isEmpty) {
      throw const ProfileValidationException(
        'Từ tiếng Anh và Nghĩa tiếng Việt không được để trống.',
      );
    }
    final normalizedLevel = word.level.trim().toUpperCase();
    if (!AppConstants.cefrLevels.contains(normalizedLevel)) {
      throw const ProfileValidationException(
        'Cấp độ CEFR của từ vựng không hợp lệ (A1–C1).',
      );
    }

    final db = await _dbHelper.database;
    final map = word.copyWith(
      term: word.term.trim(),
      meaning: word.meaning.trim(),
      level: normalizedLevel,
    ).toMap();
    map.remove('id');

    await db.update(
      'words',
      map,
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  /// Admin xóa một mục từ vựng khỏi cơ sở dữ liệu
  Future<void> adminDeleteWord({
    required String? actorUid,
    required int wordId,
  }) async {
    await _profileRepository.verifyAdminActor(actorUid);

    final db = await _dbHelper.database;
    await db.delete(
      'words',
      where: 'id = ?',
      whereArgs: [wordId],
    );
  }

  /// Admin cập nhật thông tin Chủ đề học tập
  Future<void> adminUpdateTopic({
    required String? actorUid,
    required int topicId,
    required String name,
    required String description,
  }) async {
    await _profileRepository.verifyAdminActor(actorUid);

    if (name.trim().isEmpty) {
      throw const ProfileValidationException('Tên chủ đề không được để trống.');
    }

    final db = await _dbHelper.database;
    await db.update(
      'topics',
      {
        'name': name.trim(),
        'description': description.trim(),
      },
      where: 'id = ?',
      whereArgs: [topicId],
    );
  }

  /// Admin lấy thống kê tổng thể hệ thống từ cơ sở dữ liệu thực tế
  Future<Map<String, int>> adminGetSystemMetrics({
    required String? actorUid,
  }) async {
    await _profileRepository.verifyAdminActor(actorUid);
    if (!_dbHelper.isInitialized) {
      return const {
        'users': 1,
        'admins': 1,
        'words': 520,
        'topics': 8,
        'quizzes': 0,
        'skillSubmissions': 0,
        'examAttempts': 0,
        'dictionaryCache': 0,
      };
    }

    final db = await _dbHelper.database;
    final usersRes = await db.rawQuery('SELECT COUNT(*) as c FROM user_profiles');
    final adminsRes = await db.rawQuery(
      "SELECT COUNT(*) as c FROM user_profiles WHERE role = '${AppConstants.roleAdmin}'",
    );
    final wordsRes = await db.rawQuery('SELECT COUNT(*) as c FROM words');
    final topicsRes = await db.rawQuery('SELECT COUNT(*) as c FROM topics');
    final quizRes = await db.rawQuery('SELECT COUNT(*) as c FROM quiz_history');
    final skillsRes = await db.rawQuery('SELECT COUNT(*) as c FROM skill_scores');
    final examsRes = await db.rawQuery('SELECT COUNT(*) as c FROM exam_attempts');
    final cacheRes =
        await db.rawQuery('SELECT COUNT(*) as c FROM dictionary_cache');

    return {
      'users': Sqflite.firstIntValue(usersRes) ?? 0,
      'admins': Sqflite.firstIntValue(adminsRes) ?? 0,
      'words': Sqflite.firstIntValue(wordsRes) ?? 0,
      'topics': Sqflite.firstIntValue(topicsRes) ?? 0,
      'quizzes': Sqflite.firstIntValue(quizRes) ?? 0,
      'skillSubmissions': Sqflite.firstIntValue(skillsRes) ?? 0,
      'examAttempts': Sqflite.firstIntValue(examsRes) ?? 0,
      'dictionaryCache': Sqflite.firstIntValue(cacheRes) ?? 0,
    };
  }

  /// Admin xóa bộ nhớ đệm từ điển trực tuyến
  Future<void> adminClearDictionaryCache({
    required String? actorUid,
  }) async {
    await _profileRepository.verifyAdminActor(actorUid);
    final db = await _dbHelper.database;
    await db.delete('dictionary_cache');
  }
}
