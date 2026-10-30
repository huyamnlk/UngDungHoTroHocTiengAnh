import 'dart:io' show Directory, Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../constants/app_constants.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  bool _isInMemoryFallback = false;

  DatabaseHelper._init();

  bool get isInMemoryFallback => _isInMemoryFallback;
  bool get isInitialized => _database != null;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      String path;

      if (kIsWeb) {
        // Cấu hình SQLite cho Web qua WebAssembly & IndexedDB
        databaseFactory = databaseFactoryFfiWeb;
        path = filePath;
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Cấu hình SQLite FFI cho Desktop
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;

        final appDocDir = await getApplicationDocumentsDirectory();
        path = join(appDocDir.path, 'EnglishBuddy', filePath);
        final directory = Directory(dirname(path));
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } else {
        // Mobile (Android & iOS)
        final dbPath = await getDatabasesPath();
        path = join(dbPath, filePath);
      }

      debugPrint('Initializing SQLite database at: $path (kIsWeb: $kIsWeb)');

      final db = await openDatabase(
        path,
        version: AppConstants.dbVersion,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
      await _ensureV4Schema(db);
      await _ensureV5Schema(db);
      await _ensureGameSchema(db);
      await ensureVocabularySeeded(db);
      return db;
    } catch (e, stackTrace) {
      debugPrint('Error opening primary SQLite database: $e\n$stackTrace');
      debugPrint('Falling back to safe in-memory database to prevent white screen...');
      _isInMemoryFallback = true;
      return await _initInMemoryFallback();
    }
  }

  /// Dự phòng trường hợp trình duyệt hoặc hệ thống bị chặn IndexedDB/FFI
  Future<Database> _initInMemoryFallback() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppConstants.dbVersion,
        onCreate: _createDB,
      ),
    );
    await _ensureV4Schema(db);
    await _ensureV5Schema(db);
    await _ensureGameSchema(db);
    await ensureVocabularySeeded(db);
    return db;
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Bảng Topics
    await db.execute('''
      CREATE TABLE topics (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        description TEXT
      )
    ''');

    // 2. Bảng Words (Đã mở rộng CEFR level, English definition, item_type, SRS intervals)
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic_id INTEGER NOT NULL,
        term TEXT NOT NULL,
        ipa TEXT,
        part_of_speech TEXT,
        meaning TEXT NOT NULL,
        english_definition TEXT,
        example_en TEXT,
        example_vi TEXT,
        pronunciation_guide TEXT,
        level TEXT DEFAULT 'B1',
        item_type TEXT DEFAULT 'word',
        synonyms TEXT,
        antonyms TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT '${AppConstants.statusNew}',
        review_count INTEGER NOT NULL DEFAULT 0,
        last_reviewed_at TEXT,
        next_review_at TEXT,
        interval_days INTEGER DEFAULT 1,
        FOREIGN KEY (topic_id) REFERENCES topics (id) ON DELETE CASCADE
      )
    ''');

    // Indexes tối ưu tốc độ tra cứu
    await db.execute('CREATE INDEX IF NOT EXISTS idx_words_topic ON words (topic_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_words_status ON words (status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_words_favorite ON words (is_favorite)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_words_term ON words (term)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_words_level ON words (level)');

    // 3. Bảng Lịch sử Quiz
    await db.execute('''
      CREATE TABLE quiz_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic_id INTEGER,
        topic_name TEXT NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_answers INTEGER NOT NULL,
        score_percentage REAL NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');

    // 4. Bảng Lịch sử Tìm kiếm Từ điển
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        searched_at TEXT NOT NULL
      )
    ''');

    // 5. Bảng Điểm Kỹ năng (Listening, Reading, Writing, Speaking)
    await db.execute('''
      CREATE TABLE skill_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        skill_type TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        title TEXT NOT NULL,
        score REAL NOT NULL,
        user_submission TEXT DEFAULT '',
        details_json TEXT DEFAULT '',
        completed_at TEXT NOT NULL
      )
    ''');

    // 6. Bảng Lịch sử Luyện thi (IELTS, TOEIC, CEFR Mock & Section Tests)
    await db.execute('''
      CREATE TABLE exam_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exam_id TEXT NOT NULL,
        exam_title TEXT NOT NULL,
        exam_category TEXT NOT NULL,
        skill_section TEXT NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_answers INTEGER NOT NULL,
        score_percentage REAL NOT NULL,
        duration_seconds INTEGER NOT NULL DEFAULT 0,
        answers_json TEXT DEFAULT '',
        completed_at TEXT NOT NULL
      )
    ''');

    // 7. Bảng Cache Từ điển trực tuyến (CC BY-SA 3.0 Attribution)
    await db.execute('''
      CREATE TABLE dictionary_cache (
        word TEXT PRIMARY KEY,
        payload_json TEXT NOT NULL,
        source_name TEXT NOT NULL,
        source_url TEXT NOT NULL,
        license TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');

    // 8. Bảng Hồ sơ Người dùng & Phân quyền RBAC (user_profiles)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profiles (
        uid TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        display_name TEXT NOT NULL,
        provider_id TEXT NOT NULL DEFAULT 'password',
        role TEXT NOT NULL DEFAULT '${AppConstants.roleUser}',
        cefr_level TEXT NOT NULL DEFAULT 'A1',
        level_updated_by TEXT NOT NULL DEFAULT 'system',
        bio TEXT NOT NULL DEFAULT '',
        learning_goal TEXT NOT NULL DEFAULT '',
        avatar_data TEXT NOT NULL DEFAULT '',
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON user_profiles (role)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON user_profiles (email)');

    // 9. Bảng Lịch sử Trò chơi Từ vựng (game_history)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_type TEXT NOT NULL,
        topic_id INTEGER,
        topic_name TEXT NOT NULL DEFAULT 'Tất cả chủ đề',
        level TEXT NOT NULL DEFAULT 'All',
        score INTEGER NOT NULL DEFAULT 0,
        high_streak INTEGER NOT NULL DEFAULT 0,
        total_items INTEGER NOT NULL DEFAULT 0,
        correct_items INTEGER NOT NULL DEFAULT 0,
        accuracy REAL NOT NULL DEFAULT 0.0,
        duration_seconds INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_game_history_type ON game_history (game_type)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_game_history_score ON game_history (score)');

    // Nạp dữ liệu ban đầu
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    final batch = db.batch();

    for (final topic in SeedData.topics) {
      batch.insert('topics', topic, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (final word in SeedData.words) {
      batch.insert('words', word, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);
    debugPrint('Database seeded successfully with ${SeedData.topics.length} topics and ${SeedData.words.length} words.');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database schema from $oldVersion to $newVersion');
    if (oldVersion < 2) {
      // Safe migration: Thêm các cột mới nếu nâng cấp từ version 1
      try {
        await db.execute("ALTER TABLE words ADD COLUMN english_definition TEXT DEFAULT ''");
        await db.execute("ALTER TABLE words ADD COLUMN level TEXT DEFAULT 'B1'");
        await db.execute("ALTER TABLE words ADD COLUMN item_type TEXT DEFAULT 'word'");
        await db.execute("ALTER TABLE words ADD COLUMN synonyms TEXT DEFAULT ''");
        await db.execute("ALTER TABLE words ADD COLUMN antonyms TEXT DEFAULT ''");
        await db.execute('ALTER TABLE words ADD COLUMN next_review_at TEXT');
        await db.execute('ALTER TABLE words ADD COLUMN interval_days INTEGER DEFAULT 1');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS search_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            query TEXT NOT NULL,
            searched_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS skill_scores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            skill_type TEXT NOT NULL,
            exercise_id TEXT NOT NULL,
            title TEXT NOT NULL,
            score REAL NOT NULL,
            completed_at TEXT NOT NULL
          )
        ''');
      } catch (e) {
        debugPrint('Safe migration v2 notice: $e');
      }
    }

    if (oldVersion < 3) {
      debugPrint('Upgrading to v3: ensuring indexes and 500+ vocabulary corpus...');
      try {
        await db.execute('CREATE INDEX IF NOT EXISTS idx_words_term ON words (term)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_words_level ON words (level)');
      } catch (e) {
        debugPrint('Safe migration v3 index notice: $e');
      }
    }

    if (oldVersion < 4) {
      await _ensureV4Schema(db);
    }

    if (oldVersion < 5) {
      await _ensureV5Schema(db);
    }

    await _ensureGameSchema(db);

    if (oldVersion < 7) {
      debugPrint('Upgrading to v7: ensuring 3,000+ vocabulary items seeded safely without overwriting user progress...');
    }

    // Luôn đảm bảo nạp toàn bộ từ mới mà không ghi đè tiến độ cũ của người học
    await ensureVocabularySeeded(db);
  }

  /// Đảm bảo bảng user_profiles (Version 5 - RBAC & Profile) luôn tồn tại mà không mất dữ liệu
  Future<void> _ensureV5Schema(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_profiles (
          uid TEXT PRIMARY KEY,
          email TEXT NOT NULL,
          display_name TEXT NOT NULL,
          provider_id TEXT NOT NULL DEFAULT 'password',
          role TEXT NOT NULL DEFAULT '${AppConstants.roleUser}',
          cefr_level TEXT NOT NULL DEFAULT 'A1',
          level_updated_by TEXT NOT NULL DEFAULT 'system',
          bio TEXT NOT NULL DEFAULT '',
          learning_goal TEXT NOT NULL DEFAULT '',
          avatar_data TEXT NOT NULL DEFAULT '',
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON user_profiles (role)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON user_profiles (email)');

      // Đảm bảo hồ sơ học viên cục bộ (local_learner) tồn tại mặc định với quyền 'user'
      final localRows = await db.query(
        'user_profiles',
        where: 'uid = ?',
        whereArgs: ['local_learner'],
        limit: 1,
      );
      if (localRows.isEmpty) {
        final nowIso = DateTime.now().toIso8601String();
        await db.insert(
          'user_profiles',
          {
            'uid': 'local_learner',
            'email': 'local@device.offline',
            'display_name': 'Buddy Learner',
            'provider_id': 'local',
            'role': AppConstants.roleUser,
            'cefr_level': 'A1',
            'level_updated_by': 'system',
            'bio': 'Học viên tiếng Anh chăm chỉ trên English Buddy.',
            'learning_goal': 'Chinh phục 3.000+ từ vựng CEFR và tự tin giao tiếp.',
            'avatar_data': 'preset:scholar_blue',
            'is_active': 1,
            'created_at': nowIso,
            'updated_at': nowIso,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    } catch (e) {
      debugPrint('Schema v5 user_profiles notice: $e');
    }
  }

  /// Đảm bảo bảng game_history lưu kết quả 4 mini game luôn tồn tại
  Future<void> _ensureGameSchema(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS game_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_type TEXT NOT NULL,
          topic_id INTEGER,
          topic_name TEXT NOT NULL DEFAULT 'Tất cả chủ đề',
          level TEXT NOT NULL DEFAULT 'All',
          score INTEGER NOT NULL DEFAULT 0,
          high_streak INTEGER NOT NULL DEFAULT 0,
          total_items INTEGER NOT NULL DEFAULT 0,
          correct_items INTEGER NOT NULL DEFAULT 0,
          accuracy REAL NOT NULL DEFAULT 0.0,
          duration_seconds INTEGER NOT NULL DEFAULT 0,
          completed_at TEXT NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_game_history_type ON game_history (game_type)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_game_history_score ON game_history (score)');
    } catch (e) {
      debugPrint('Schema game_history notice: $e');
    }
  }

  /// Đảm bảo các bảng và cột của Version 4 luôn tồn tại trên mọi nền tảng mà không mất dữ liệu
  Future<void> _ensureV4Schema(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS exam_attempts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          exam_id TEXT NOT NULL,
          exam_title TEXT NOT NULL,
          exam_category TEXT NOT NULL,
          skill_section TEXT NOT NULL,
          total_questions INTEGER NOT NULL,
          correct_answers INTEGER NOT NULL,
          score_percentage REAL NOT NULL,
          duration_seconds INTEGER NOT NULL DEFAULT 0,
          answers_json TEXT DEFAULT '',
          completed_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS dictionary_cache (
          word TEXT PRIMARY KEY,
          payload_json TEXT NOT NULL,
          source_name TEXT NOT NULL,
          source_url TEXT NOT NULL,
          license TEXT NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');
    } catch (e) {
      debugPrint('Schema v4 tables notice: $e');
    }

    try {
      await db.execute("ALTER TABLE skill_scores ADD COLUMN user_submission TEXT DEFAULT ''");
    } catch (_) {}

    try {
      await db.execute("ALTER TABLE skill_scores ADD COLUMN details_json TEXT DEFAULT ''");
    } catch (_) {}
  }

  /// Đảm bảo tất cả chủ đề và 500+ từ vựng từ SeedData có mặt trong DB
  /// Tuyệt đối KHÔNG xóa hoặc ghi đè từ người dùng đã yêu thích hoặc đã học
  Future<void> ensureVocabularySeeded(Database db) async {
    try {
      // 1. Kiểm tra Topics
      final existingTopics = await db.rawQuery('SELECT id FROM topics');
      final existingTopicIds = existingTopics.map((r) => r['id'] as int).toSet();
      final topicBatch = db.batch();
      for (final topic in SeedData.topics) {
        if (!existingTopicIds.contains(topic['id'])) {
          topicBatch.insert('topics', topic, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
      await topicBatch.commit(noResult: true);

      // 2. Kiểm tra Words hiện có
      final existingWords = await db.rawQuery('SELECT LOWER(term) as term FROM words');
      final existingTerms = existingWords.map((r) => (r['term'] as String?)?.toLowerCase() ?? '').toSet();

      final missingWords = SeedData.words.where((w) {
        final term = (w['term'] as String?)?.toLowerCase() ?? '';
        return !existingTerms.contains(term);
      }).toList();

      if (missingWords.isNotEmpty) {
        debugPrint('Seeding ${missingWords.length} missing vocabulary items into database...');
        final wordBatch = db.batch();
        for (final word in missingWords) {
          wordBatch.insert('words', word, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
        await wordBatch.commit(noResult: true);
        debugPrint('Successfully seeded ${missingWords.length} new vocabulary items.');
      }
    } catch (e) {
      debugPrint('ensureVocabularySeeded notice: $e');
    }
  }

  Future<void> resetToDefault() async {
    final db = await database;
    await db.transaction((txn) async {
      try {
        await txn.delete('exam_attempts');
      } catch (_) {}
      await txn.delete('skill_scores');
      await txn.delete('search_history');
      await txn.delete('quiz_history');
      await txn.delete('words');
      await txn.delete('topics');

      final batch = txn.batch();
      for (final topic in SeedData.topics) {
        batch.insert('topics', topic);
      }
      for (final word in SeedData.words) {
        batch.insert('words', word);
      }
      await batch.commit(noResult: true);
    });
    debugPrint('Database has been reset to default seed data.');
  }

  // --- Quản lý Lịch sử Tìm kiếm Từ điển ---
  Future<void> addSearchHistory(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    final db = await database;
    await db.delete('search_history', where: 'query = ?', whereArgs: [clean]);
    await db.insert('search_history', {
      'query': clean,
      'searched_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<String>> getSearchHistory({int limit = 10}) async {
    final db = await database;
    final results = await db.query(
      'search_history',
      orderBy: 'id DESC',
      limit: limit,
    );
    return results.map((row) => row['query'] as String).toList();
  }

  Future<void> clearSearchHistory() async {
    final db = await database;
    await db.delete('search_history');
  }

  // --- Quản lý Điểm Kỹ năng & Bài làm ---
  Future<void> saveSkillScore({
    required String skillType,
    required String exerciseId,
    required String title,
    required double score,
    String userSubmission = '',
    String detailsJson = '',
  }) async {
    final db = await database;
    await db.insert('skill_scores', {
      'skill_type': skillType,
      'exercise_id': exerciseId,
      'title': title,
      'score': score,
      'user_submission': userSubmission,
      'details_json': detailsJson,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSkillScores({int limit = 50}) async {
    final db = await database;
    return await db.query('skill_scores', orderBy: 'id DESC', limit: limit);
  }

  // --- Quản lý Lịch sử Luyện thi (IELTS, TOEIC, CEFR) ---
  Future<void> saveExamAttempt({
    required String examId,
    required String examTitle,
    required String examCategory,
    required String skillSection,
    required int totalQuestions,
    required int correctAnswers,
    required double scorePercentage,
    required int durationSeconds,
    String answersJson = '',
  }) async {
    final db = await database;
    await db.insert('exam_attempts', {
      'exam_id': examId,
      'exam_title': examTitle,
      'exam_category': examCategory,
      'skill_section': skillSection,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'score_percentage': scorePercentage,
      'duration_seconds': durationSeconds,
      'answers_json': answersJson,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getExamAttempts({int limit = 40}) async {
    final db = await database;
    return await db.query('exam_attempts', orderBy: 'id DESC', limit: limit);
  }

  // --- Quản lý Cache Từ điển Trực tuyến (CC BY-SA 3.0) ---
  Future<void> saveDictionaryCache({
    required String word,
    required String payloadJson,
    required String sourceName,
    required String sourceUrl,
    required String license,
  }) async {
    final db = await database;
    await db.insert(
      'dictionary_cache',
      {
        'word': word.trim().toLowerCase(),
        'payload_json': payloadJson,
        'source_name': sourceName,
        'source_url': sourceUrl,
        'license': license,
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getCachedDictionaryResult(String word) async {
    final db = await database;
    final clean = word.trim().toLowerCase();
    final rows = await db.query(
      'dictionary_cache',
      where: 'word = ?',
      whereArgs: [clean],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
