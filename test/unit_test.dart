import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_buddy/core/constants/app_colors.dart';
import 'package:english_buddy/core/constants/app_constants.dart';
import 'package:english_buddy/core/database/exam_seed_data.dart';
import 'package:english_buddy/core/database/seed_data.dart';
import 'package:english_buddy/core/database/shadowing_seed_data.dart';
import 'package:english_buddy/core/database/skills_seed_data.dart';
import 'package:english_buddy/core/services/anti_bot_service.dart';
import 'package:english_buddy/core/services/auth_service.dart';
import 'package:english_buddy/core/services/dictionary_api_service.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import 'package:english_buddy/data/models/exam_model.dart';
import 'package:english_buddy/data/models/game_record_model.dart';
import 'package:english_buddy/data/models/online_dictionary_result.dart';
import 'package:english_buddy/data/models/skill_exercise_model.dart';
import 'package:english_buddy/data/models/topic_model.dart';
import 'package:english_buddy/data/models/user_profile_model.dart';
import 'package:english_buddy/data/models/word_model.dart';
import 'package:english_buddy/data/repositories/user_profile_repository.dart';
import 'package:english_buddy/data/repositories/vocabulary_repository.dart';
import 'package:english_buddy/presentation/screens/games/space_typer/logic/space_game_engine.dart';
import 'package:english_buddy/presentation/screens/games/space_typer/models/space_models.dart';
import 'package:english_buddy/presentation/screens/games/common/game_difficulty.dart';

void main() {
  group('SeedData & Vocabulary Corpus Tests', () {
    test('SeedData contains exactly 3,000 words across 8 topics', () {
      expect(SeedData.topics.length, 8);
      expect(SeedData.words.length, 3000);
    });

    test('All seed words have complete metadata and valid CEFR levels', () {
      final validLevels = {'A1', 'A2', 'B1', 'B2', 'C1'};
      final validTypes = {'word', 'phrase', 'collocation', 'phrasal_verb', 'idiom'};

      for (final word in SeedData.words) {
        expect(word['term'], isNotEmpty, reason: 'Term must not be empty');
        expect(word['meaning'], isNotEmpty, reason: 'Meaning must not be empty');
        expect(word['ipa'], isNotEmpty, reason: 'IPA must not be empty for ${word['term']}');
        expect(word['topic_id'], inInclusiveRange(1, 8));
        expect(validLevels.contains(word['level']), true, reason: 'Invalid CEFR level in ${word['term']}');
        expect(validTypes.contains(word['item_type']), true, reason: 'Invalid item_type in ${word['term']}');
      }
    });

    test('All seed word terms are distinct and unique', () {
      final terms = SeedData.words.map((w) => (w['term'] as String).toLowerCase()).toList();
      final uniqueTerms = terms.toSet();
      expect(terms.length, uniqueTerms.length);
    });
  });
  group('WordModel Tests', () {
    test('WordModel serialization and deserialization with CEFR and definition', () {
      final map = {
        'id': 1,
        'topic_id': 2,
        'term': 'Destination',
        'ipa': '/ˌdes.tɪˈneɪ.ʃən/',
        'part_of_speech': 'noun',
        'meaning': 'Điểm đến, đích đến',
        'english_definition': 'The place to which someone or something is going.',
        'example_en': 'Da Nang is a popular travel destination.',
        'example_vi': 'Đà Nẵng là điểm đến du lịch nổi tiếng.',
        'pronunciation_guide': 'Nhấn âm thứ 3',
        'level': 'A2',
        'item_type': 'word',
        'synonyms': 'stop, landing place',
        'antonyms': 'origin',
        'is_favorite': 1,
        'status': AppConstants.statusLearning,
        'review_count': 3,
        'last_reviewed_at': '2026-10-25T10:00:00',
        'interval_days': 3,
      };

      final word = WordModel.fromMap(map);
      expect(word.id, 1);
      expect(word.term, 'Destination');
      expect(word.level, 'A2');
      expect(word.englishDefinition, 'The place to which someone or something is going.');
      expect(word.isFavorite, true);
      expect(word.isLearning, true);
      expect(word.isMastered, false);
      expect(word.reviewCount, 3);
      expect(word.intervalDays, 3);

      final toMap = word.toMap();
      expect(toMap['term'], 'Destination');
      expect(toMap['level'], 'A2');
      expect(toMap['english_definition'], 'The place to which someone or something is going.');
      expect(toMap['is_favorite'], 1);
      expect(toMap['status'], AppConstants.statusLearning);
    });

    test('WordModel copyWith function works correctly', () {
      const word = WordModel(
        id: 1,
        topicId: 1,
        term: 'Appreciate',
        ipa: '/əˈpriː.ʃi.eɪt/',
        partOfSpeech: 'verb',
        meaning: 'Đánh giá cao',
        exampleEn: 'I appreciate your help.',
        exampleVi: 'Tôi biết ơn sự giúp đỡ của bạn.',
        level: 'B1',
      );

      final updated = word.copyWith(
        status: AppConstants.statusMastered,
        isFavorite: true,
        level: 'B2',
      );

      expect(updated.id, 1);
      expect(updated.term, 'Appreciate');
      expect(updated.level, 'B2');
      expect(updated.status, AppConstants.statusMastered);
      expect(updated.isMastered, true);
      expect(updated.isFavorite, true);
    });
  });

  group('TopicModel Tests', () {
    test('Topic progressPercentage calculation', () {
      const topic1 = TopicModel(
        id: 1,
        name: 'Giao tiếp hàng ngày',
        iconName: 'chat',
        colorHex: '#4361EE',
        description: 'Mô tả',
        totalWords: 10,
        masteredWords: 5,
      );

      expect(topic1.progressPercentage, 0.5);

      const topic2 = TopicModel(
        id: 2,
        name: 'Trống',
        iconName: 'book',
        colorHex: '#4361EE',
        description: '',
        totalWords: 0,
        masteredWords: 0,
      );

      expect(topic2.progressPercentage, 0.0);
    });
  });

  group('SkillExerciseModel Tests', () {
    test('SkillQuestion and WritingSentence model initialization', () {
      const question = SkillQuestion(
        questionText: 'What is the main topic?',
        options: ['Travel', 'Work', 'Health'],
        correctOptionIndex: 0,
        explanation: 'Because it talks about vacations.',
      );

      expect(question.questionText, 'What is the main topic?');
      expect(question.options.length, 3);
      expect(question.correctOptionIndex, 0);

      const sentence = WritingSentence(
        englishSentence: 'I appreciate your support.',
        vietnameseMeaning: 'Tôi cảm kích sự hỗ trợ của bạn.',
        scrambledWords: ['your', 'support.', 'I', 'appreciate'],
      );

      expect(sentence.englishSentence, 'I appreciate your support.');
      expect(sentence.scrambledWords.length, 4);
    });
  });

  group('UiHelpers Tests', () {
    test('hexToColor parses valid hex strings correctly', () {
      final color1 = UiHelpers.hexToColor('#4361EE');
      expect(color1.toARGB32(), 0xFF4361EE);

      final color2 = UiHelpers.hexToColor('2EC4B6');
      expect(color2.toARGB32(), 0xFF2EC4B6);
    });

    test('formatDateTime formats correctly', () {
      expect(UiHelpers.formatDateTime(null), 'Chưa học');
      expect(UiHelpers.formatDateTime(''), 'Chưa học');

      final formatted = UiHelpers.formatDateTime('2026-10-25T14:30:00.000Z');
      expect(formatted.isNotEmpty, true);
      expect(formatted.contains('/'), true);
    });
  });

  group('Theme Architecture Tests', () {
    test('AppColors light and dark palettes provide high-contrast values', () {
      // Light mode contrast check
      expect(AppColors.background, isNot(equals(AppColors.textPrimary)));
      expect(AppColors.surface, isNot(equals(AppColors.textPrimary)));

      // Dark mode contrast check
      expect(AppColors.darkBackground, isNot(equals(AppColors.darkTextPrimary)));
      expect(AppColors.darkSurface, isNot(equals(AppColors.darkTextPrimary)));
      expect(AppColors.darkCard, isNot(equals(AppColors.darkTextPrimary)));

      // Dark background must be dark (luminance < 0.2)
      expect(AppColors.darkBackground.computeLuminance(), lessThan(0.2));
      // Dark text primary must be bright (luminance > 0.8)
      expect(AppColors.darkTextPrimary.computeLuminance(), greaterThan(0.8));

      // Light background must be bright (luminance > 0.8)
      expect(AppColors.background.computeLuminance(), greaterThan(0.8));
      // Light text primary must be dark (luminance < 0.2)
      expect(AppColors.textPrimary.computeLuminance(), lessThan(0.2));
    });
  });

  group('4 Skills, Exam Prep & Online Dictionary Cache Tests', () {
    test('SkillQuestion supports both MCQ and fill-in-the-blank answer checking', () {
      const fillQuestion = SkillQuestion(
        questionText: 'Fill in the blank: long-term _______',
        options: ['retention'],
        correctOptionIndex: 0,
        questionType: 'fill',
        acceptedAnswers: ['retention', 'memory retention'],
        explanation: 'Retention means keeping information in memory.',
      );

      expect(fillQuestion.isFillBlank, true);
      expect(fillQuestion.isTextAnswerCorrect('  RETENTION '), true);
      expect(fillQuestion.isTextAnswerCorrect('memory retention'), true);
      expect(fillQuestion.isTextAnswerCorrect('cramming'), false);
    });

    test('SkillsSeedData contains valid A1-C1 exercises with attribution', () {
      final allSkills = [
        ...SkillsSeedData.listeningExercises,
        ...SkillsSeedData.readingExercises,
        ...SkillsSeedData.writingExercises,
        ...SkillsSeedData.speakingExercises,
      ];
      expect(allSkills.length, greaterThanOrEqualTo(16));
      for (final ex in allSkills) {
        expect(ex.id, isNotEmpty);
        expect(ex.title, isNotEmpty);
        expect(ex.attribution.author, isNotEmpty);
        expect(ex.attribution.license, isNotEmpty);
      }
    });

    test('ExamSeedData & ExamAttemptModel validate answers and provide honest feedback', () {
      expect(ExamSeedData.exams.length, greaterThanOrEqualTo(5));
      final ieltsReading = ExamSeedData.exams.first;
      expect(ieltsReading.category, 'IELTS');
      expect(ieltsReading.questions, isNotEmpty);

      final mcqQ = ieltsReading.questions.first;
      expect(mcqQ.isCorrectAnswer(mcqQ.correctOptionIndex), true);
      expect(mcqQ.isCorrectAnswer(99), false);

      final fillQ = ieltsReading.questions.firstWhere((q) => q.isFillBlank);
      expect(fillQ.isCorrectAnswer('Cohesion'), true);
      expect(fillQ.isCorrectAnswer('WrongWord'), false);

      final attempt = ExamAttemptModel.fromMap({
        'id': 1,
        'exam_id': ieltsReading.id,
        'exam_title': ieltsReading.title,
        'exam_category': 'IELTS',
        'skill_section': 'Reading',
        'total_questions': 4,
        'correct_answers': 4,
        'score_percentage': 100.0,
        'duration_seconds': 240,
        'answers_json': '{"ir1_q1":1,"ir1_q3":"cohesion"}',
        'completed_at': '2026-10-26T12:00:00',
      });
      expect(attempt.scorePercentage, 100.0);
      expect(attempt.userAnswers['ir1_q3'], 'cohesion');
      expect(attempt.competencyFeedback, contains('4/4'));
    });

    test('OnlineDictionaryResult parses API JSON and serializes/deserializes SQLite cache', () {
      final sampleApiJson = {
        'word': 'resilient',
        'phonetic': '/rɪˈzɪl.i.ənt/',
        'phonetics': [
          {'text': '/rɪˈzɪl.i.ənt/', 'audio': 'https://example.com/resilient.mp3'}
        ],
        'meanings': [
          {
            'partOfSpeech': 'adjective',
            'definitions': [
              {
                'definition': 'Able to withstand or recover quickly from difficult conditions.',
                'example': 'She is a resilient learner.',
                'synonyms': ['strong', 'adaptable']
              }
            ]
          }
        ],
        'license': {'name': 'CC BY-SA 3.0'},
        'sourceUrls': ['https://en.wiktionary.org/wiki/resilient'],
      };

      final parsed = OnlineDictionaryResult.fromJson(sampleApiJson);
      expect(parsed.word, 'resilient');
      expect(parsed.phonetic, '/rɪˈzɪl.i.ənt/');
      expect(parsed.license, 'CC BY-SA 3.0');
      expect(parsed.definitions.first.synonyms, contains('adaptable'));
      expect(parsed.isFromCache, false);

      final cacheMap = parsed.toCacheMap();
      final restored = OnlineDictionaryResult.fromCacheMap(cacheMap, isFromCache: true);
      expect(restored.word, 'resilient');
      expect(restored.isFromCache, true);
      expect(restored.definitions.first.definition, contains('withstand'));
    });

    test('ShadowingSeedData contains multi-level lessons with stress and intonation maps', () {
      expect(ShadowingSeedData.lessons.length, greaterThanOrEqualTo(5));
      final levels = ShadowingSeedData.lessons.map((l) => l.level).toSet();
      expect(levels, containsAll(['A1', 'A2', 'B1', 'B2', 'C1']));

      for (final lesson in ShadowingSeedData.lessons) {
        expect(lesson.segments, isNotEmpty);
        expect(lesson.fullTranscript, isNotEmpty);
        for (final seg in lesson.segments) {
          expect(seg.englishText, isNotEmpty);
          expect(seg.phoneticStress, isNotEmpty);
          expect(seg.vietnameseMeaning, isNotEmpty);
          expect(seg.coachingTip, isNotEmpty);
        }
      }
    });

    test('AuthService and AntiBotService never fake success when external services are unconfigured', () async {
      final antiBot = AntiBotService();
      expect(antiBot.isConfigured, false);
      final botCheck = await antiBot.verifyTokenOnServer(
        captchaResponseToken: 'sample_token',
        action: 'signup',
      );
      expect(botCheck.isVerified, false);
      expect(botCheck.message, contains('chưa thể bật thực sự'));

      final auth = AuthService();
      final loginAttempt = await auth.signInWithIdentifierAndPassword(
        identifier: 'student@example.com',
        password: 'ValidPassword123',
      );
      expect(loginAttempt.isSuccess, false);
      expect(loginAttempt.user, isNull);
      expect(loginAttempt.message, contains('FIREBASE_API_KEY'));
    });

    test('UserProfileModel validates inputs and extracts JWT role claims properly', () {
      expect(
        UserProfileModel.validateProfileInput(
          displayName: 'A',
          bio: 'Valid bio',
          learningGoal: 'Valid goal',
          avatarData: 'preset:scholar_blue',
        ),
        isNotNull,
      );
      expect(
        UserProfileModel.validateProfileInput(
          displayName: 'Minh Anh',
          bio: 'Yêu thích tiếng Anh giao tiếp',
          learningGoal: 'IELTS 7.5',
          avatarData: 'preset:scholar_blue',
        ),
        isNull,
      );
      expect(
        UserProfileModel.validateProfileInput(
          displayName: 'Minh Anh',
          bio: 'Bio',
          learningGoal: 'Goal',
          avatarData: 'javascript:alert(1)',
        ),
        isNotNull,
      );

      // Kiểm tra giải mã Custom Claims từ JWT payload
      final header = base64Url.encode(utf8.encode('{"alg":"RS256"}'));
      final adminPayload =
          base64Url.encode(utf8.encode('{"sub":"u_admin","role":"admin"}'));
      final userPayload =
          base64Url.encode(utf8.encode('{"sub":"u_regular","role":"user"}'));

      expect(
        AuthService.extractRoleFromTokenOrBootstrap(
          idToken: '$header.$adminPayload.sig',
          uid: 'u_admin',
          email: 'admin@example.com',
        ),
        AppConstants.roleAdmin,
      );
      expect(
        AuthService.extractRoleFromTokenOrBootstrap(
          idToken: '$header.$userPayload.sig',
          uid: 'u_regular',
          email: 'user@example.com',
        ),
        AppConstants.roleUser,
      );

      // Xác minh nhận diện tài khoản chủ dự án bằng email và UID đã lưu
      expect(
        AuthService.isConfiguredBootstrapAdmin(
          uid: 'kK847H8QYXQ3RGBwfIxjYANxZHv2',
          email: 'giahuy2005a@gmail.com',
        ),
        true,
      );
      expect(
        AuthService.isConfiguredBootstrapAdmin(
          uid: 'kK847H8QYXQ3RGBwfIxjYANxZHv2',
          email: 'other_email@example.com',
        ),
        true,
      );
      expect(
        AuthService.isConfiguredBootstrapAdmin(
          uid: 'any_uid',
          email: 'giahuy2005a@gmail.com',
        ),
        true,
      );
      // Tài khoản người dùng mới tạo bất kỳ không phải admin
      expect(
        AuthService.isConfiguredBootstrapAdmin(
          uid: 'newbie_uid_123',
          email: 'newbie@example.com',
        ),
        false,
      );
    });

    test('UserProfileRepository and VocabularyRepository enforce strict RBAC and prevent editing other users profiles', () async {
      final profileRepo = UserProfileRepository(ensureDbOpen: true);
      final vocabRepo = VocabularyRepository(profileRepository: profileRepo);

      // 1. Tài khoản chủ dự án được cấp quyền Admin tự động khi đồng bộ
      final projectOwnerAdmin = await profileRepo.syncAuthenticatedUserProfile(
        uid: 'kK847H8QYXQ3RGBwfIxjYANxZHv2',
        email: 'giahuy2005a@gmail.com',
        displayName: '0808_Hồ Gia Huy',
        providerId: 'google.com',
        isBootstrapAdmin: AuthService.isConfiguredBootstrapAdmin(
          uid: 'kK847H8QYXQ3RGBwfIxjYANxZHv2',
          email: 'giahuy2005a@gmail.com',
        ),
      );
      expect(projectOwnerAdmin.isAdmin, true);
      expect(projectOwnerAdmin.role, AppConstants.roleAdmin);

      // 2. Mọi tài khoản tạo mới từ bây giờ mặc định là user
      final regularUser = await profileRepo.syncAuthenticatedUserProfile(
        uid: 'user_regular_1',
        email: 'learner1@example.com',
        displayName: 'Học Viên 1',
        providerId: 'password',
        verifiedRoleFromServerOrToken: AppConstants.roleUser,
      );
      expect(regularUser.isAdmin, false);
      expect(regularUser.role, AppConstants.roleUser);
      expect(regularUser.cefrLevel, 'A1');

      final secondUser = await profileRepo.syncAuthenticatedUserProfile(
        uid: 'user_regular_2',
        email: 'learner2@example.com',
        displayName: 'Học Viên 2',
        providerId: 'password',
        verifiedRoleFromServerOrToken: AppConstants.roleUser,
      );
      expect(secondUser.isAdmin, false);

      final adminUser = await profileRepo.syncAuthenticatedUserProfile(
        uid: 'admin_master_1',
        email: 'admin@example.com',
        displayName: 'Quản Trị Viên',
        providerId: 'password',
        verifiedRoleFromServerOrToken: AppConstants.roleAdmin,
      );
      expect(adminUser.isAdmin, true);

      // 2. User thường có thể cập nhật profile của chính mình (tên, bio, avatar, mục tiêu)
      final updatedOwn = await profileRepo.updateOwnProfile(
        actorUid: 'user_regular_1',
        targetUid: 'user_regular_1',
        displayName: 'Học Viên Chăm Chỉ',
        bio: 'Đang luyện thi TOEIC & IELTS',
        learningGoal: 'Đạt B2 trong 6 tháng',
        avatarData: 'preset:ielts_purple',
      );
      expect(updatedOwn.displayName, 'Học Viên Chăm Chỉ');
      expect(updatedOwn.bio, 'Đang luyện thi TOEIC & IELTS');
      expect(updatedOwn.avatarData, 'preset:ielts_purple');
      expect(updatedOwn.role, AppConstants.roleUser);
      expect(updatedOwn.cefrLevel, 'A1');

      // 3. User thường KHÔNG được phép sửa profile của tài khoản khác
      expect(
        () => profileRepo.updateOwnProfile(
          actorUid: 'user_regular_1',
          targetUid: 'user_regular_2',
          displayName: 'Hack Tên',
          bio: '',
          learningGoal: '',
          avatarData: 'preset:scholar_blue',
        ),
        throwsA(isA<ProfileAccessDeniedException>()),
      );

      // 4. User thường KHÔNG được tự ý sửa cấp độ CEFR hoặc tự nâng quyền lên admin
      expect(
        () => profileRepo.updateOwnProfile(
          actorUid: 'user_regular_1',
          targetUid: 'user_regular_1',
          displayName: 'Học Viên Chăm Chỉ',
          bio: '',
          learningGoal: '',
          avatarData: 'preset:scholar_blue',
          attemptedCefrLevel: 'C1',
        ),
        throwsA(isA<ProfileAccessDeniedException>()),
      );
      expect(
        () => profileRepo.updateOwnProfile(
          actorUid: 'user_regular_1',
          targetUid: 'user_regular_1',
          displayName: 'Học Viên Chăm Chỉ',
          bio: '',
          learningGoal: '',
          avatarData: 'preset:scholar_blue',
          attemptedRole: AppConstants.roleAdmin,
        ),
        throwsA(isA<ProfileAccessDeniedException>()),
      );

      // 5. User thường gọi trực tiếp các hàm API/Repository của Admin -> bị từ chối (403 Forbidden)
      expect(
        () => profileRepo.adminGetAllProfiles(actorUid: 'user_regular_1'),
        throwsA(isA<AdminAccessDeniedException>()),
      );
      expect(
        () => profileRepo.adminUpdateUserProfile(
          actorUid: 'user_regular_1',
          targetUid: 'user_regular_2',
          displayName: 'Học Viên 2',
          bio: '',
          learningGoal: '',
          cefrLevel: 'C1',
          role: AppConstants.roleAdmin,
          isActive: true,
        ),
        throwsA(isA<AdminAccessDeniedException>()),
      );
      expect(
        () => vocabRepo.adminDeleteWord(
          actorUid: 'user_regular_1',
          wordId: 1,
        ),
        throwsA(isA<AdminAccessDeniedException>()),
      );

      // 6. Admin hợp lệ có thể lấy danh sách người dùng và cập nhật cấp độ CEFR cho học viên
      final allProfiles = await profileRepo.adminGetAllProfiles(
        actorUid: 'admin_master_1',
      );
      expect(allProfiles.length, greaterThanOrEqualTo(3));

      final promotedByAdmin = await profileRepo.adminUpdateUserProfile(
        actorUid: 'admin_master_1',
        targetUid: 'user_regular_1',
        displayName: 'Học Viên Chăm Chỉ',
        bio: 'Đang luyện thi TOEIC & IELTS',
        learningGoal: 'Đạt B2 trong 6 tháng',
        cefrLevel: 'B2',
        role: AppConstants.roleUser,
        isActive: true,
      );
      expect(promotedByAdmin.cefrLevel, 'B2');
      expect(promotedByAdmin.levelUpdatedBy, 'admin');

      // 7. Admin không thể tự hạ quyền hoặc tự xóa chính tài khoản đang đăng nhập
      expect(
        () => profileRepo.adminUpdateUserProfile(
          actorUid: 'admin_master_1',
          targetUid: 'admin_master_1',
          displayName: 'Quản Trị Viên',
          bio: '',
          learningGoal: '',
          cefrLevel: 'C1',
          role: AppConstants.roleUser,
          isActive: true,
        ),
        throwsA(isA<ProfileValidationException>()),
      );
      expect(
        () => profileRepo.adminDeleteUserProfile(
          actorUid: 'admin_master_1',
          targetUid: 'admin_master_1',
        ),
        throwsA(isA<ProfileValidationException>()),
      );
    });

    test('GameRecordModel serializes and deserializes accurately with titles', () {
      const arenaRecord = GameRecordModel(
        id: 1,
        gameType: 'arena',
        topicId: 1,
        topicName: 'Giáo dục & Học tập',
        level: 'B1',
        score: 1850,
        highStreak: 6,
        totalItems: 15,
        correctItems: 13,
        accuracy: 86.67,
        durationSeconds: 95,
        completedAt: '2026-10-26T22:00:00Z',
      );

      expect(arenaRecord.gameTitle, 'Đấu trường từ vựng');
      final map = arenaRecord.toMap();
      expect(map['game_type'], 'arena');
      expect(map['score'], 1850);
      expect(map['high_streak'], 6);

      final fromMap = GameRecordModel.fromMap(map);
      expect(fromMap.id, 1);
      expect(fromMap.score, 1850);
      expect(fromMap.accuracy, closeTo(86.67, 0.01));

      const typerRecord = GameRecordModel(
        gameType: 'typer',
        score: 2400,
        totalItems: 20,
        correctItems: 19,
        accuracy: 95.0,
        completedAt: '2026-10-26T22:10:00Z',
      );
      expect(typerRecord.gameTitle, 'Luyện Gõ Siêu Tốc');

      const rainRecord = GameRecordModel(
        gameType: 'rain',
        score: 1500,
        totalItems: 12,
        correctItems: 10,
        accuracy: 83.33,
        completedAt: '2026-10-26T22:15:00Z',
      );
      expect(rainRecord.gameTitle, 'Mưa Từ Vựng');

      const spellingRecord = GameRecordModel(
        gameType: 'spelling',
        score: 1900,
        totalItems: 10,
        correctItems: 9,
        accuracy: 90.0,
        completedAt: '2026-10-26T22:20:00Z',
      );
      expect(spellingRecord.gameTitle, 'Ong Chính Tả');

      const spaceRecord = GameRecordModel(
        gameType: 'space_typer',
        score: 3200,
        totalItems: 25,
        correctItems: 24,
        accuracy: 96.0,
        completedAt: '2026-10-26T22:25:00Z',
      );
      expect(spaceRecord.gameTitle, 'Chiến cơ Không gian');
    });

    test('SpaceGameEngine initializes with correct defaults and parallax stars', () {
      final engine = SpaceGameEngine();
      final words = [
        const WordModel(
          id: 1,
          topicId: 1,
          term: 'ROCKET',
          ipa: '/ˈrɒk.ɪt/',
          partOfSpeech: 'noun',
          meaning: 'Tên lửa vũ trụ',
          exampleEn: 'The rocket launched into orbit.',
          exampleVi: 'Tên lửa phóng vào quỹ đạo.',
        ),
      ];

      engine.init(
        newWidth: 480,
        newHeight: 760,
        newPlayTop: 64,
        newPlayBottom: 656,
        words: words,
      );

      expect(engine.health, 5);
      expect(engine.shield, 100.0);
      expect(engine.score, 0);
      expect(engine.level, 1);
      expect(engine.stars.length, 90);
      expect(engine.planets.length, 2);
    });

    test('SpaceGameEngine handles typing, locks target and shoots laser', () {
      final engine = SpaceGameEngine();
      final words = [
        const WordModel(
          id: 1,
          topicId: 1,
          term: 'MARS',
          ipa: '/mɑːz/',
          partOfSpeech: 'noun',
          meaning: 'Sao Hỏa',
          exampleEn: 'Mars is the red planet.',
          exampleVi: 'Sao Hỏa là hành tinh đỏ.',
        ),
      ];

      engine.init(
        newWidth: 480,
        newHeight: 760,
        newPlayTop: 64,
        newPlayBottom: 656,
        words: words,
      );
      engine.start();

      expect(engine.asteroids.isNotEmpty, isTrue);
      // Lấy mục tiêu có Y lớn nhất (gần đáy nhất - sẽ được ưu tiên khóa ngắm)
      final candidates = List<AsteroidTarget>.from(engine.asteroids)
        ..sort((a, b) => b.y.compareTo(a.y));
      final target = candidates.first;
      final firstLetter = target.text[0];

      // Gõ chữ cái đầu tiên
      final handled = engine.handleKeyInput(firstLetter);
      expect(handled, isTrue);
      expect(engine.lockedTarget, target);
      expect(target.typedIndex, 1);
      expect(engine.bullets.isNotEmpty, isTrue);
      expect(engine.streak, 1);
    });
  });

  group('Bidirectional Dictionary (Việt–Anh & Anh–Việt) Engine Tests', () {
    test('DictionaryApiService.isVietnameseQuery accurately detects Vietnamese vs English', () {
      // Vietnamese queries with accents
      expect(DictionaryApiService.isVietnameseQuery('căn hộ'), true);
      expect(DictionaryApiService.isVietnameseQuery('nhà ở'), true);
      expect(DictionaryApiService.isVietnameseQuery('học tập'), true);
      expect(DictionaryApiService.isVietnameseQuery('thành phố'), true);
      expect(DictionaryApiService.isVietnameseQuery('phát triển'), true);

      // Vietnamese unaccented common queries
      expect(DictionaryApiService.isVietnameseQuery('can ho'), true);
      expect(DictionaryApiService.isVietnameseQuery('nha o'), true);

      // English queries
      expect(DictionaryApiService.isVietnameseQuery('apartment'), false);
      expect(DictionaryApiService.isVietnameseQuery('flat'), false);
      expect(DictionaryApiService.isVietnameseQuery('sustainable'), false);
      expect(DictionaryApiService.isVietnameseQuery('resilience'), false);
      expect(DictionaryApiService.isVietnameseQuery('vocabulary'), false);
    });

    test('OnlineDictionaryResult.fromTranslationJson handles vi_en and en_vi correctly', () {
      // 1. Vietnamese to English lookup ("căn hộ" -> "apartment")
      final viEnResult = OnlineDictionaryResult.fromTranslationJson(
        query: 'căn hộ',
        translatedText: 'apartment',
        sourceLang: 'vi',
        targetLang: 'en',
        gtxData: [
          [
            ['apartment', 'căn hộ', null, null, 10]
          ],
          [
            [
              'noun',
              ['apartment', 'flat', 'tenement'],
            ]
          ]
        ],
        phonetic: '/əˈpɑːrt.mənt/',
      );

      expect(viEnResult.queryDirection, 'vi_en');
      expect(viEnResult.isVietnameseToEnglish, true);
      expect(viEnResult.isEnglishToVietnamese, false);
      expect(viEnResult.word, 'apartment');
      expect(viEnResult.originalQuery, 'căn hộ');
      expect(viEnResult.vietnameseTranslation, 'căn hộ');
      expect(viEnResult.alternativeTranslations.contains('apartment'), true);
      expect(viEnResult.alternativeTranslations.contains('flat'), true);
      expect(viEnResult.phonetic, '/əˈpɑːrt.mənt/');

      // 2. English to Vietnamese lookup ("apartment" -> "căn hộ")
      final enViResult = OnlineDictionaryResult.fromTranslationJson(
        query: 'apartment',
        translatedText: 'căn hộ',
        sourceLang: 'en',
        targetLang: 'vi',
        gtxData: [
          [
            ['căn hộ', 'apartment', null, null, 10]
          ],
          [
            [
              'noun',
              ['căn hộ', 'nhà cho mướn'],
            ]
          ]
        ],
        phonetic: '/əˈpɑːrt.mənt/',
      );

      expect(enViResult.queryDirection, 'en_vi');
      expect(enViResult.isVietnameseToEnglish, false);
      expect(enViResult.isEnglishToVietnamese, true);
      expect(enViResult.word, 'apartment');
      expect(enViResult.originalQuery, 'apartment');
      expect(enViResult.vietnameseTranslation, 'căn hộ');
      expect(enViResult.alternativeTranslations.contains('căn hộ'), true);
    });

    test('OnlineDictionaryResult cache serialization preserves bidirectional fields', () {
      const original = OnlineDictionaryResult(
        word: 'apartment',
        originalQuery: 'căn hộ',
        phonetic: '/əˈpɑːrt.mənt/',
        definitions: [
          OnlineDefinition(
            partOfSpeech: 'noun',
            definition: 'a suite of rooms forming one residence',
            example: 'They lived in a small apartment.',
          )
        ],
        vietnameseTranslation: 'căn hộ',
        queryDirection: 'vi_en',
        alternativeTranslations: ['apartment', 'flat'],
        sourceName: 'Google Translate / Wiktionary',
        sourceUrl: 'https://en.wiktionary.org/wiki/apartment',
        license: 'CC BY-SA 3.0',
      );

      final cacheMap = original.toCacheMap();
      final roundTrip = OnlineDictionaryResult.fromCacheMap(cacheMap);

      expect(roundTrip.word, 'apartment');
      expect(roundTrip.originalQuery, 'căn hộ');
      expect(roundTrip.vietnameseTranslation, 'căn hộ');
      expect(roundTrip.queryDirection, 'vi_en');
      expect(roundTrip.alternativeTranslations, ['apartment', 'flat']);
      expect(roundTrip.isFromCache, true);
      expect(roundTrip.definitions.length, 1);
      expect(roundTrip.definitions.first.example, 'They lived in a small apartment.');
    });
  });

  group('SpaceSpeedTyper Engine Logic & Scoring Tests', () {
    late SpaceGameEngine engine;

    setUp(() {
      engine = SpaceGameEngine();
      engine.init(
        newWidth: 480.0,
        newHeight: 800.0,
        newPlayTop: 64.0,
        newPlayBottom: 700.0,
        words: [
          const WordModel(
            id: 101,
            topicId: 1,
            term: 'STAR',
            meaning: 'Ngôi sao',
            ipa: '/stɑːr/',
            partOfSpeech: 'noun',
            exampleEn: 'The star shines.',
            exampleVi: 'Ngôi sao tỏa sáng.',
          ),
          const WordModel(
            id: 102,
            topicId: 1,
            term: 'MOON',
            meaning: 'Mặt trăng',
            ipa: '/muːn/',
            partOfSpeech: 'noun',
            exampleEn: 'The moon is bright.',
            exampleVi: 'Mặt trăng rất sáng.',
          ),
        ],
        lettersOnlyMode: false,
      );
      engine.start();
    });

    test('1. Gõ đúng thì cộng điểm một lần, tàu di chuyển tới mục tiêu và phá hủy', () {
      engine.asteroids.clear();
      final target = AsteroidTarget.create(
        id: 'ast_1',
        text: 'STAR',
        meaning: 'Ngôi sao',
        x: 150.0,
        y: 200.0,
      );
      engine.asteroids.add(target);

      expect(engine.score, 0);
      expect(engine.correctKeystrokes, 0);

      // Gõ 'S'
      final sHandled = engine.handleKeyInput('s');
      expect(sHandled, true);
      expect(engine.correctKeystrokes, 1);
      expect(engine.streak, 1);
      expect(engine.targetShipX, 150.0);
      expect(engine.lockedTarget, target);
      expect(target.typedIndex, 1);
      expect(target.isDestroyed, false);

      // Gõ 'T', 'A', 'R'
      engine.handleKeyInput('t');
      engine.handleKeyInput('a');
      engine.handleKeyInput('r');

      expect(target.typedIndex, 4);
      expect(target.isDestroyed, true);
      expect(engine.wordsDestroyedCount, 1);
      expect(engine.targetsDestroyed, 1);
      expect(engine.score, greaterThan(0));
      expect(engine.lockedTarget, null);

      // Gõ tiếp phím không làm tăng điểm của mục tiêu đã nổ
      final initialScore = engine.score;
      engine.handleKeyInput('r');
      expect(engine.score, initialScore);
    });

    test('2. Gõ sai không cộng điểm và không phá hủy nhầm mục tiêu', () {
      engine.asteroids.clear();
      final target = AsteroidTarget.create(
        id: 'ast_2',
        text: 'PLANET',
        meaning: 'Hành tinh',
        x: 200.0,
        y: 180.0,
      );
      engine.asteroids.add(target);

      final initialScore = engine.score;
      final handled = engine.handleKeyInput('z'); // 'Z' không khớp chữ 'P'

      expect(handled, false);
      expect(engine.score, initialScore);
      expect(engine.correctKeystrokes, 0);
      expect(engine.streak, 0);
      expect(target.isDestroyed, false);
      expect(target.typedIndex, 0);
      expect(engine.lockedTarget, null);
    });

    test('3. Mục tiêu lọt qua vạch đỏ trừ đúng 1 HP và đánh dấu đã xử lý', () {
      engine.asteroids.clear();
      final target = AsteroidTarget.create(
        id: 'ast_breach',
        text: 'COMET',
        meaning: 'Sao chổi',
        x: 240.0,
        y: 650.0,
      );
      engine.asteroids.add(target);

      expect(engine.health, 5);
      expect(target.hasBreached, false);

      // Cho mục tiêu vượt qua vạch đỏ (playBottom - 26 = 674.0)
      target.y = 675.0;
      engine.update(0.016);

      expect(target.hasBreached, true);
      expect(target.isDestroyed, true);
      expect(engine.health, 4); // Trừ chính xác 1 HP

      // Update frame tiếp theo: mục tiêu đã breached không được trừ HP lần 2
      engine.update(0.016);
      expect(engine.health, 4);
    });

    test('4. Mục tiêu đã bị bắn phá hủy không trừ HP khi chạm đáy', () {
      engine.asteroids.clear();
      final target = AsteroidTarget.create(
        id: 'ast_dead',
        text: 'A',
        meaning: '',
        x: 200.0,
        y: 600.0,
      );
      engine.asteroids.add(target);

      // Bắn phá hủy mục tiêu trước khi chạm đáy
      engine.handleKeyInput('a');
      expect(target.isDestroyed, true);
      expect(engine.health, 5);

      // Di chuyển xuống qua vạch đỏ
      target.y = 680.0;
      engine.update(0.016);

      // HP phải giữ nguyên không bị trừ
      expect(engine.health, 5);
    });

    test('5. Khi HP về 0, chuyển sang Game Over và dừng cập nhật mục tiêu', () {
      engine.health = 1;
      bool gameOverCallbackFired = false;
      engine.onGameOver = () {
        gameOverCallbackFired = true;
      };

      engine.asteroids.clear();
      final target = AsteroidTarget.create(
        id: 'ast_final',
        text: 'ROCKET',
        meaning: 'Tên lửa',
        x: 200.0,
        y: 675.0,
      );
      engine.asteroids.add(target);

      engine.update(0.016);

      expect(engine.health, 0);
      expect(engine.isGameOver, true);
      expect(gameOverCallbackFired, true);

      // Các frame tiếp theo không sinh hoặc di chuyển mục tiêu khi đã Game Over
      final asteroidCount = engine.asteroids.length;
      engine.update(0.5);
      expect(engine.asteroids.length, asteroidCount);
    });

    test('6. Chơi lại (restart) khôi phục đầy đủ HP, điểm, level và trạng thái game', () {
      engine.score = 1500;
      engine.health = 0;
      engine.isGameOver = true;
      engine.level = 3;
      engine.streak = 8;
      engine.targetsDestroyed = 15;

      engine.restart();

      expect(engine.health, 5);
      expect(engine.score, 0);
      expect(engine.level, 1);
      expect(engine.streak, 0);
      expect(engine.targetsDestroyed, 0);
      expect(engine.isGameOver, false);
      expect(engine.isStarted, true);
      expect(engine.isPaused, false);
      expect(engine.lockedTarget, null);
      expect(engine.asteroids.isNotEmpty, true);
    });

    test('7. WPM và accuracy cập nhật ngay tức thì theo sự kiện gameplay', () {
      engine.asteroids.clear();
      final target = AsteroidTarget.create(
        id: 'ast_speed',
        text: 'SPACE',
        meaning: 'Không gian',
        x: 200.0,
        y: 200.0,
      );
      engine.asteroids.add(target);

      engine.update(1.0); // 1 giây trôi qua
      engine.handleTextInput('SPACE'); // Gõ đúng cả 5 ký tự

      expect(engine.correctKeystrokes, 5);
      expect(engine.totalKeystrokes, 5);
      expect(engine.accuracy, 100.0);
      expect(engine.wordsPerMinute, greaterThanOrEqualTo(50));
    });
  });

  group('GameDifficulty & Multi-game Balance Tests', () {
    final sampleWords = [
      const WordModel(
        id: 1,
        topicId: 1,
        term: 'CAT',
        meaning: 'Con mèo',
        ipa: '/kæt/',
        partOfSpeech: 'noun',
        exampleEn: 'The cat sleeps.',
        exampleVi: 'Con mèo đang ngủ.',
        level: 'A1',
      ),
      const WordModel(
        id: 2,
        topicId: 1,
        term: 'COMPUTER',
        meaning: 'Máy tính',
        ipa: '/kəmˈpjuːtər/',
        partOfSpeech: 'noun',
        exampleEn: 'I use a computer.',
        exampleVi: 'Tôi dùng máy tính.',
        level: 'B1',
      ),
      const WordModel(
        id: 3,
        topicId: 1,
        term: 'EXTRAORDINARY',
        meaning: 'Phi thường',
        ipa: '/ɪkˈstrɔːrdəneri/',
        partOfSpeech: 'adjective',
        exampleEn: 'An extraordinary mind.',
        exampleVi: 'Một trí óc phi thường.',
        level: 'C1',
      ),
    ];

    test('1. GameDifficulty.easy filters short words and handles fallback', () {
      final filtered = GameDifficulty.filterWords(words: sampleWords, difficulty: GameDifficulty.easy);
      expect(filtered.isNotEmpty, true);
      // 'CAT' có 3 chữ cái, thuộc A1
      expect(filtered.any((w) => w.term == 'CAT'), true);

      // Khi danh sách không có từ ngắn nào, fallback đảm bảo không bao giờ rỗng
      final longOnly = [sampleWords[2]];
      final fallbackResult = GameDifficulty.filterWords(words: longOnly, difficulty: GameDifficulty.easy);
      expect(fallbackResult.isNotEmpty, true);
      expect(fallbackResult.first.term, 'EXTRAORDINARY');
    });

    test('2. GameDifficulty.medium filters moderate length words', () {
      final filtered = GameDifficulty.filterWords(words: sampleWords, difficulty: GameDifficulty.medium);
      expect(filtered.isNotEmpty, true);
      // 'COMPUTER' có 8 chữ cái, thuộc B1
      expect(filtered.any((w) => w.term == 'COMPUTER'), true);
    });

    test('3. GameDifficulty.hard filters long and advanced vocabulary', () {
      final filtered = GameDifficulty.filterWords(words: sampleWords, difficulty: GameDifficulty.hard);
      expect(filtered.isNotEmpty, true);
      // 'EXTRAORDINARY' có 13 chữ cái, thuộc C1
      expect(filtered.any((w) => w.term == 'EXTRAORDINARY'), true);
    });

    test('4. SpaceGameEngine scales difficulty parameters according to GameDifficulty', () {
      final easyEngine = SpaceGameEngine();
      easyEngine.init(
        newWidth: 600,
        newHeight: 800,
        newPlayTop: 70,
        newPlayBottom: 700,
        words: sampleWords,
        gameDifficulty: GameDifficulty.easy,
      );
      easyEngine.start();
      expect(easyEngine.maxConcurrentTargets, 3);
      expect(easyEngine.baseSpawnInterval, 2.4);
      expect(easyEngine.speedMultiplier, 0.80);

      final hardEngine = SpaceGameEngine();
      hardEngine.init(
        newWidth: 600,
        newHeight: 800,
        newPlayTop: 70,
        newPlayBottom: 700,
        words: sampleWords,
        gameDifficulty: GameDifficulty.hard,
      );
      hardEngine.start();
      expect(hardEngine.maxConcurrentTargets, 6);
      expect(hardEngine.baseSpawnInterval, 1.35);
      expect(hardEngine.speedMultiplier, 1.55);
    });
  });

  group('IELTS Comprehensive Listening, Reading & Writing Tests', () {
    test('1. IELTS Band score calculation scales accurately according to 40-question standard', () {
      // 39-40 câu đúng -> Band 9.0
      expect(ExamModel.calculateEstimatedIeltsBand(40, 40), 9.0);
      expect(ExamModel.calculateEstimatedIeltsBand(39, 40), 9.0);

      // 30 câu đúng -> Band 7.0
      expect(ExamModel.calculateEstimatedIeltsBand(30, 40), 7.0);

      // Quy đổi từ số câu nhỏ hơn (ví dụ làm bài kiểm tra 10 câu, đúng 7 câu ~ 28/40 câu -> Band 6.5)
      final scaledBand = ExamModel.calculateEstimatedIeltsBand(7, 10);
      expect(scaledBand, inInclusiveRange(6.0, 7.0));

      // Không đúng câu nào -> Band 1.0
      expect(ExamModel.calculateEstimatedIeltsBand(0, 40), 1.0);
    });

    test('2. IELTS Writing 4 Criteria Analysis evaluates word count, linking words, and academic vocabulary', () {
      const sampleEssay = '''
In recent years, the rapid proliferation of artificial intelligence tools has ignited a passionate debate regarding future schooling.
While some observers contend that intelligent instructional machines will replace teachers, I firmly believe that human educators remain irreplaceable.
On the one hand, advocates of automated education point out the undeniable efficiencies and bespoke personalization delivered by modern applications.
Furthermore, intelligent learning algorithms can grade homework objectively around the clock without fatigue.
On the other hand, teaching is inherently an empathetic enterprise. Human mentors inspire curiosity, instill ethical principles, and provide critical emotional encouragement.
In conclusion, although artificial intelligence undoubtedly serves as an extraordinary pedagogical aid, human teachers will remain irreplaceable in modern classrooms.
''';

      final evaluation = IeltsWritingEvaluation.analyze(sampleEssay, minWords: 100);
      expect(evaluation.wordCount >= 100, true);
      expect(evaluation.detectedLinkingWords.isNotEmpty, true);
      expect(evaluation.overallBand >= 6.5, true);
      expect(evaluation.strengths.isNotEmpty, true);

      // Test bài viết quá ngắn
      final shortEval = IeltsWritingEvaluation.analyze('I like studying English.', minWords: 150);
      expect(shortEval.wordCount < 10, true);
      expect(shortEval.overallBand <= 5.0, true);
      expect(shortEval.improvements.any((im) => im.contains('thiếu')), true);
    });

    test('3. ExamSeedData contains IELTS Listening, Academic Reading, General Reading and Writing tasks', () {
      const exams = ExamSeedData.exams;

      // Kiểm tra đề IELTS Listening 4 sections
      final listeningExam = exams.firstWhere((e) => e.id == 'exam_ielts_listen_full');
      expect(listeningExam.hasAudioScript, true);
      expect(listeningExam.questions.length, 8);
      expect(listeningExam.passageOrScript.contains('[SECTION 1:'), true);
      expect(listeningExam.passageOrScript.contains('[SECTION 4:'), true);

      // Kiểm tra đề IELTS Academic Reading
      final acadReading = exams.firstWhere((e) => e.id == 'exam_ielts_read_academic');
      expect(acadReading.ieltsModule, 'Academic');
      expect(acadReading.questions.any((q) => q.isTfng), true);
      expect(acadReading.questions.any((q) => q.paragraphRef != null), true);

      // Kiểm tra đề IELTS General Reading
      final genReading = exams.firstWhere((e) => e.id == 'exam_ielts_read_general');
      expect(genReading.ieltsModule, 'General Training');
      expect(genReading.questions.any((q) => q.isYnng), true);

      // Kiểm tra đề IELTS Writing Task 1 Academic với biểu đồ
      final writeTask1 = exams.firstWhere((e) => e.id == 'exam_ielts_write_task1_acad');
      expect(writeTask1.chartType, 'bar');
      expect(writeTask1.chartData != null, true);
      expect(writeTask1.sampleResponseBand8 != null, true);
      expect(writeTask1.examinerNotes != null, true);

      // Kiểm tra đề IELTS Writing Task 2 với bài luận mẫu
      final writeTask2 = exams.firstWhere((e) => e.id == 'exam_ielts_write_task2');
      expect(writeTask2.writingTaskType, 'Task 2');
      expect(writeTask2.sampleResponseBand8 != null, true);
    });

    test('4. ExamQuestion accurately validates True/False/Not Given, Yes/No/Not Given, and Word Limits', () {
      const tfngQ = ExamQuestion(
        id: 'q_tfng',
        questionText: 'Is bilingualism beneficial?',
        options: ['TRUE', 'FALSE', 'NOT GIVEN'],
        correctOptionIndex: 0,
        questionType: 'tfng',
        explanation: 'Clearly beneficial in Paragraph A.',
        evidenceQuote: 'confers profound cognitive resilience',
      );

      expect(tfngQ.isTfng, true);
      expect(tfngQ.isCorrectAnswer(0), true);
      expect(tfngQ.isCorrectAnswer(1), false);
      expect(tfngQ.evidenceQuote, 'confers profound cognitive resilience');

      const fillQ = ExamQuestion(
        id: 'q_fill',
        questionText: 'Applicant surname:',
        questionType: 'fill',
        wordLimit: 1,
        acceptedAnswers: ['Gallagher'],
        explanation: 'Martin Gallagher.',
      );

      expect(fillQ.isFillBlank, true);
      expect(fillQ.wordLimit, 1);
      expect(fillQ.isCorrectAnswer('gallagher'), true);
      expect(fillQ.isCorrectAnswer('Gallagher '), true);
      expect(fillQ.isCorrectAnswer('Smith'), false);
    });
  });
}
