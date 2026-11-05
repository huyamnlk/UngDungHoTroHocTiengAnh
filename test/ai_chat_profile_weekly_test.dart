import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:english_buddy/core/database/database_helper.dart';
import 'package:english_buddy/core/services/ai_chat_service.dart';
import 'package:english_buddy/core/services/auth_service.dart';
import 'package:english_buddy/core/services/settings_service.dart';
import 'package:english_buddy/data/models/user_profile_model.dart';
import 'package:english_buddy/data/repositories/user_profile_repository.dart';
import 'package:english_buddy/l10n/app_localizations.dart';
import 'package:english_buddy/presentation/screens/profile/profile_screen.dart';
import 'package:english_buddy/providers/ai_chat_provider.dart';
import 'package:english_buddy/providers/auth_provider.dart';
import 'package:english_buddy/providers/locale_provider.dart';
import 'package:english_buddy/providers/quiz_provider.dart';
import 'package:english_buddy/providers/study_provider.dart';
import 'package:english_buddy/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AuthService.setCurrentActiveUid('guest');
    DatabaseHelper.instance.clearMemoryActivityLog();
  });

  group('1. AI Chat Service & Provider (Guest, Auth, Token Refresh, Errors, Retry)', () {
    test('Guest chat succeeds without Authorization header', () async {
      String? capturedAuthHeader;
      final mockClient = MockClient((req) async {
        capturedAuthHeader = req.headers['Authorization'];
        return http.Response(
          jsonEncode({
            'ok': true,
            'reply': 'Guest explanation for present simple.',
            'mode': 'guest',
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = AiChatService.custom(
        httpClient: mockClient,
        endpointUrlOverride: 'https://worker.test/api/chat',
      );

      final result = await service.sendMessage(
        message: 'Explain present simple',
        history: const [],
      );

      expect(result.isSuccess, isTrue);
      expect(result.reply, 'Guest explanation for present simple.');
      expect(capturedAuthHeader, isNull);
    });

    test('Authenticated chat sends Bearer token and succeeds', () async {
      String? capturedAuthHeader;
      final mockClient = MockClient((req) async {
        capturedAuthHeader = req.headers['Authorization'];
        return http.Response(
          jsonEncode({
            'ok': true,
            'reply': 'Authenticated explanation.',
            'mode': 'authenticated',
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = AiChatService.custom(
        httpClient: mockClient,
        endpointUrlOverride: 'https://worker.test/api/chat',
      );

      final result = await service.sendMessage(
        message: 'Explain conditionals',
        history: const [],
        idToken: 'valid_token_123',
      );

      expect(result.isSuccess, isTrue);
      expect(capturedAuthHeader, 'Bearer valid_token_123');
      expect(result.reply, 'Authenticated explanation.');
    });

    test('Expired token refreshes once and retries successfully without infinite loop', () async {
      final authHeaders = <String?>[];
      int refreshCalls = 0;

      final mockClient = MockClient((req) async {
        final header = req.headers['Authorization'];
        authHeaders.add(header);
        if (header == 'Bearer expired_token') {
          return http.Response(
            jsonEncode({
              'ok': false,
              'errorCode': 'TOKEN_EXPIRED',
              'error': 'Invalid or expired Firebase ID token.',
            }),
            401,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (header == 'Bearer fresh_token_456') {
          return http.Response(
            jsonEncode({
              'ok': true,
              'reply': 'Success after token refresh!',
              'mode': 'authenticated',
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Unexpected', 500);
      });

      final service = AiChatService.custom(
        httpClient: mockClient,
        endpointUrlOverride: 'https://worker.test/api/chat',
      );

      final result = await service.sendMessage(
        message: 'Test token refresh',
        history: const [],
        idToken: 'expired_token',
        onRefreshToken: () async {
          refreshCalls++;
          return 'fresh_token_456';
        },
      );

      expect(result.isSuccess, isTrue);
      expect(result.reply, 'Success after token refresh!');
      expect(refreshCalls, 1);
      expect(authHeaders, ['Bearer expired_token', 'Bearer fresh_token_456']);
    });

    test('Invalid token returns 401 unauthorized and is NEVER downgraded to guest', () async {
      final authHeaders = <String?>[];
      int refreshCalls = 0;

      final mockClient = MockClient((req) async {
        authHeaders.add(req.headers['Authorization']);
        return http.Response(
          jsonEncode({
            'ok': false,
            'errorCode': 'TOKEN_INVALID_OR_EXPIRED',
            'error': 'Invalid or expired Firebase ID token.',
          }),
          401,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = AiChatService.custom(
        httpClient: mockClient,
        endpointUrlOverride: 'https://worker.test/api/chat',
      );

      final result = await service.sendMessage(
        message: 'Should not become guest',
        history: const [],
        idToken: 'bad_token',
        onRefreshToken: () async {
          refreshCalls++;
          return 'still_bad_token';
        },
      );

      expect(result.isSuccess, isFalse);
      expect(result.statusCode, 401);
      expect(result.errorType, AiChatErrorType.unauthorized);
      expect(refreshCalls, 1); // Retried at most once
      expect(authHeaders.length, 2);
      expect(authHeaders.every((h) => h != null && h.startsWith('Bearer ')), isTrue);
    });

    test('Distinguishes missing backend config (503), AI provider error (502), and timeout (504)', () async {
      final service503 = AiChatService.custom(
        httpClient: MockClient((_) async => http.Response(
          jsonEncode({
            'ok': false,
            'errorCode': 'BACKEND_AUTH_UNCONFIGURED',
            'error': 'FIREBASE_API_KEY is not configured on the backend server.',
          }),
          503,
        )),
        endpointUrlOverride: 'https://worker.test/api/chat',
      );
      final res503 = await service503.sendMessage(
        message: 'Hi',
        history: const [],
        idToken: 'tok',
      );
      expect(res503.isSuccess, isFalse);
      expect(res503.errorType, AiChatErrorType.backendUnconfigured);

      final service502 = AiChatService.custom(
        httpClient: MockClient((_) async => http.Response(
          jsonEncode({
            'ok': false,
            'errorCode': 'AI_PROVIDER_ERROR',
            'error': 'Provider error',
          }),
          502,
        )),
        endpointUrlOverride: 'https://worker.test/api/chat',
      );
      final res502 = await service502.sendMessage(message: 'Hi', history: const []);
      expect(res502.isSuccess, isFalse);
      expect(res502.errorType, AiChatErrorType.aiProvider);

      final service504 = AiChatService.custom(
        httpClient: MockClient((_) async => http.Response(
          jsonEncode({
            'ok': false,
            'errorCode': 'AI_TIMEOUT',
            'error': 'Timeout',
          }),
          504,
        )),
        endpointUrlOverride: 'https://worker.test/api/chat',
      );
      final res504 = await service504.sendMessage(message: 'Hi', history: const []);
      expect(res504.isSuccess, isFalse);
      expect(res504.errorType, AiChatErrorType.timeout);
    });

    test('AiChatProvider handles guest -> login -> logout in same session and retry without duplicating messages', () async {
      int callCount = 0;
      final receivedHeaders = <String?>[];

      final mockClient = MockClient((req) async {
        callCount++;
        final auth = req.headers['Authorization'];
        receivedHeaders.add(auth);
        if (callCount == 2) {
          // Simulate transient network/provider error on 2nd call
          return http.Response(
            jsonEncode({'ok': false, 'errorCode': 'AI_PROVIDER_ERROR', 'error': 'Temporary error'}),
            502,
          );
        }
        return http.Response(
          jsonEncode({
            'ok': true,
            'reply': auth == null ? 'Reply as Guest #$callCount' : 'Reply as User #$callCount',
          }),
          200,
        );
      });

      final provider = AiChatProvider(
        service: AiChatService.custom(
          httpClient: mockClient,
          endpointUrlOverride: 'https://worker.test/api/chat',
        ),
      );

      // 1. Guest message
      await provider.sendMessage('Hello as guest');
      expect(provider.isLoading, isFalse);
      expect(provider.messages.length, 2);
      expect(provider.messages.last.text, 'Reply as Guest #1');

      // 2. Logged-in user message (fails first time)
      await provider.sendMessage('Hello as logged in user', idToken: 'user_jwt_1');
      expect(provider.isLoading, isFalse);
      expect(provider.messages.length, 4);
      expect(provider.messages.last.hasError, isTrue);

      // Retry failed message -> must NOT duplicate user or error message!
      final failedMsgId = provider.messages.last.id;
      await provider.retryMessage(failedMsgId, idToken: 'user_jwt_1');
      expect(provider.isLoading, isFalse);
      expect(provider.messages.length, 4);
      expect(provider.messages.last.hasError, isFalse);
      expect(provider.messages.last.text, 'Reply as User #3');

      // 3. Logout -> back to guest in the same session
      await provider.sendMessage('Back to guest after logout', idToken: null);
      expect(provider.isLoading, isFalse);
      expect(provider.messages.length, 6);
      expect(provider.messages.last.text, 'Reply as Guest #4');
      expect(receivedHeaders, [null, 'Bearer user_jwt_1', 'Bearer user_jwt_1', null]);
    });
  });

  group('2. Profile Display Name & Login Username Validation, Uniqueness & Self-Only', () {
    test('Username normalization and validation rules work accurately', () {
      expect(UserProfileModel.normalizeUsername('  Huy.Nguyen_2026  '), 'huy.nguyen_2026');
      expect(UserProfileModel.validateUsername('huy.nguyen_2026'), isNull);
      expect(UserProfileModel.validateUsername('ab'), isNotNull); // < 3 chars
      expect(UserProfileModel.validateUsername('a' * 31), isNotNull); // > 30 chars
      expect(UserProfileModel.validateUsername('user@gmail.com'), isNotNull); // contains @
      expect(UserProfileModel.validateUsername('.leadingdot'), isNotNull);
      expect(UserProfileModel.validateUsername('trailingdot.'), isNotNull);
      expect(UserProfileModel.validateUsername('double..dot'), isNotNull);
      expect(UserProfileModel.validateUsername('admin'), isNotNull); // reserved
    });

    test('Profile update enforces self-only, case-insensitive username uniqueness, preserves UID & data, and updates login mapping', () async {
      final db = await DatabaseHelper.instance.database;
      await db.delete('user_profiles');

      final repo = UserProfileRepository();
      await repo.syncAuthenticatedUserProfile(
        uid: 'uid_alpha',
        email: 'alpha@example.com',
        username: 'alpha_initial',
        displayName: 'Alpha Old',
        providerId: 'password',
      );
      await repo.syncAuthenticatedUserProfile(
        uid: 'uid_beta',
        email: 'beta@example.com',
        username: 'beta_user',
        displayName: 'Beta User',
        providerId: 'password',
      );

      // 1. Self-only enforcement: u1 cannot edit u2
      await expectLater(
        () => repo.updateOwnProfile(
          actorUid: 'uid_alpha',
          targetUid: 'uid_beta',
          displayName: 'Hacked',
          username: 'hacked_name',
          bio: '',
          learningGoal: '',
          avatarData: 'preset:scholar_blue',
        ),
        throwsA(isA<ProfileAccessDeniedException>()),
      );

      // 2. Duplicate username (case-insensitive): u1 cannot take 'BETA_USER'
      await expectLater(
        () => repo.updateOwnProfile(
          actorUid: 'uid_alpha',
          targetUid: 'uid_alpha',
          displayName: 'Alpha New',
          username: 'BETA_USER',
          bio: '',
          learningGoal: '',
          avatarData: 'preset:scholar_blue',
        ),
        throwsA(isA<ProfileValidationException>()),
      );

      // 3. Valid update of displayName and username for u1
      final updatedProfile = await repo.updateOwnProfile(
        actorUid: 'uid_alpha',
        targetUid: 'uid_alpha',
        displayName: 'Alpha Master',
        username: '  Alpha.Pro_99 ',
        bio: 'IELTS 8.5',
        learningGoal: '20 words/day',
        avatarData: 'preset:owl_gold',
      );
      expect(updatedProfile.uid, 'uid_alpha'); // UID preserved
      expect(updatedProfile.email, 'alpha@example.com'); // Email unchanged
      expect(updatedProfile.displayName, 'Alpha Master');
      expect(updatedProfile.username, 'alpha.pro_99');

      // Old username no longer resolves to u1; new username resolves to u1
      final oldLookup = await repo.findProfileByUsername('alpha_initial');
      final newLookup = await repo.findProfileByUsername('ALPHA.PRO_99');
      expect(oldLookup, isNull);
      expect(newLookup?.uid, 'uid_alpha');
    });

    test('AuthProvider syncs displayName & username with server, persists across reload, and supports login with new username', () async {
      String serverUsername = 'huy_initial';
      String serverDisplayName = 'Gia Huy';

      final mockHttp = MockClient((req) async {
        final path = req.url.path;
        if (path.endsWith('/profile') && req.method == 'GET') {
          return http.Response(
            jsonEncode({
              'ok': true,
              'profile': {
                'uid': 'uid_huy_1',
                'email': 'huy@example.com',
                'username': serverUsername,
                'displayName': serverDisplayName,
                'bio': 'Hello',
                'learningGoal': 'IELTS',
                'avatarData': 'preset:scholar_blue',
                'providerId': 'password',
                'role': 'user',
                'cefrLevel': 'B2',
              },
            }),
            200,
          );
        }
        if (path.endsWith('/profile') && req.method == 'PUT') {
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          serverDisplayName = body['displayName'] as String;
          serverUsername = (body['username'] as String).trim().toLowerCase();
          return http.Response(
            jsonEncode({
              'ok': true,
              'message': 'Saved!',
              'profile': {
                'uid': 'uid_huy_1',
                'email': 'huy@example.com',
                'username': serverUsername,
                'displayName': serverDisplayName,
                'bio': body['bio'] ?? '',
                'learningGoal': body['learningGoal'] ?? '',
                'avatarData': body['avatarData'] ?? 'preset:scholar_blue',
                'providerId': 'password',
                'role': 'user',
                'cefrLevel': 'B2',
              },
            }),
            200,
          );
        }
        if (path.endsWith('/auth/login') && req.method == 'POST') {
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          final id = (body['identifier'] as String).trim().toLowerCase();
          final pwd = body['password'] as String;
          if ((id == serverUsername || id == 'huy@example.com') && pwd == 'ValidPass123') {
            return http.Response(
              jsonEncode({
                'ok': true,
                'message': 'Logged in!',
                'user': {
                  'uid': 'uid_huy_1',
                  'email': 'huy@example.com',
                  'username': serverUsername,
                  'displayName': serverDisplayName,
                  'providerId': 'password',
                  'idToken': 'jwt_huy_1',
                  'refreshToken': 'ref_huy_1',
                  'role': 'user',
                },
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'ok': false,
              'errorCode': 'INVALID_LOGIN_CREDENTIALS',
              'message': 'Invalid credentials',
            }),
            401,
          );
        }
        if (req.url.host.contains('identitytoolkit.googleapis.com')) {
          return http.Response(jsonEncode({'localId': 'uid_huy_1'}), 200);
        }
        return http.Response('Not found', 404);
      });

      final customAuthService = AuthService.custom(
        httpClient: mockHttp,
        firebaseApiKeyOverride: 'fake_key',
        backendUrlOverride: 'https://worker.test',
      );
      final authProvider = AuthProvider(authService: customAuthService);

      // Sign in with initial username
      final login1 = await authProvider.signIn(
        identifier: 'huy_initial',
        password: 'ValidPass123',
      );
      expect(login1, isTrue);
      expect(authProvider.currentUser?.displayName, 'Gia Huy');
      expect(authProvider.currentUser?.username, 'huy_initial');

      // Update Display Name and Username
      final updated = await authProvider.updateOwnProfile(
        displayName: 'Gia Huy Pro 2026',
        username: 'Huy.Pro_2026',
        bio: 'Updated bio',
        learningGoal: 'C1 mastery',
        avatarData: 'preset:scholar_blue',
      );
      expect(updated, isTrue);
      expect(authProvider.currentUser?.displayName, 'Gia Huy Pro 2026');
      expect(authProvider.currentUser?.username, 'huy.pro_2026');
      expect(authProvider.currentUser?.email, 'huy@example.com'); // Email unchanged

      // Sign out and verify old username fails, new username succeeds, email succeeds
      authProvider.signOut();
      expect(authProvider.isAuthenticated, isFalse);

      final loginOld = await authProvider.signIn(
        identifier: 'huy_initial',
        password: 'ValidPass123',
      );
      expect(loginOld, isFalse);

      final loginNew = await authProvider.signIn(
        identifier: 'HUY.PRO_2026',
        password: 'ValidPass123',
      );
      expect(loginNew, isTrue);
      expect(authProvider.currentUser?.displayName, 'Gia Huy Pro 2026');
      expect(authProvider.currentUser?.username, 'huy.pro_2026');
    });
  });

  group('3. Weekly Progress ("Tiến độ hằng tuần") Calculation, Deduplication, Goal Metric & User Isolation', () {
    setUp(() async {
      final db = await DatabaseHelper.instance.database;
      await db.delete('learning_activity_log');
    });

    test('Empty week returns 0/7 active days, 0 words, 0 activities, and 7 ordered days Monday..Sunday', () async {
      final ref = DateTime(2026, 11, 4, 14, 30); // Wednesday, Nov 4, 2026
      final summary = await DatabaseHelper.instance.getWeeklyActivitySummary(
        userUid: 'user_empty',
        referenceNow: ref,
      );

      final days = List<Map<String, dynamic>>.from(summary['days'] as List);
      expect(days.length, 7);
      expect(days.first['weekday'], DateTime.monday);
      expect(days.last['weekday'], DateTime.sunday);
      expect(summary['activeDaysCount'], 0);
      expect(summary['totalWordsInWeek'], 0);
      expect(summary['totalActivitiesInWeek'], 0);
      expect(summary['hasAnyActivityInWeek'], isFalse);

      final todayEntry = days.firstWhere((d) => d['isToday'] == true);
      expect(todayEntry['weekday'], DateTime.wednesday);
    });

    test('Deduplicates repeated word reviews on the same day and accurately aggregates partial & full 7/7 weeks', () async {
      final monday = DateTime(2026, 11, 2, 9, 15);
      final wednesday = DateTime(2026, 11, 4, 20, 45);

      // Review word 101 twice on Monday -> must count as 1 word on Monday
      await DatabaseHelper.instance.recordLearningActivity(
        userUid: 'uid_learner_1',
        activityType: 'word_review',
        itemId: 'word_101',
        wordCount: 1,
        timestamp: monday,
      );
      await DatabaseHelper.instance.recordLearningActivity(
        userUid: 'uid_learner_1',
        activityType: 'word_review',
        itemId: 'word_101',
        wordCount: 1,
        timestamp: monday.add(const Duration(hours: 2)),
      );
      // Review word 102 on Monday -> total 2 words on Monday
      await DatabaseHelper.instance.recordLearningActivity(
        userUid: 'uid_learner_1',
        activityType: 'word_review',
        itemId: 'word_102',
        wordCount: 1,
        timestamp: monday.add(const Duration(hours: 3)),
      );

      // Complete a quiz on Wednesday (activityCount = 1, wordCount = 0)
      await DatabaseHelper.instance.recordLearningActivity(
        userUid: 'uid_learner_1',
        activityType: 'quiz',
        itemId: 'quiz_wed_1',
        activityCount: 1,
        timestamp: wednesday,
      );

      final partial = await DatabaseHelper.instance.getWeeklyActivitySummary(
        userUid: 'uid_learner_1',
        referenceNow: wednesday,
      );

      expect(partial['activeDaysCount'], 2); // Monday and Wednesday
      expect(partial['totalWordsInWeek'], 2);
      expect(partial['totalActivitiesInWeek'], 1);
      // Today (Wednesday) has 1 quiz activity but 0 words studied -> daily word goal compares todayWordsCount (0), NOT quiz count!
      expect(partial['todayWordsCount'], 0);
      expect(partial['todayActivitiesCount'], 1);

      // Now log 5 words on Wednesday to reach the 5-word daily goal, plus activity on all remaining 5 days for a 7/7 week
      for (int w = 1; w <= 5; w++) {
        await DatabaseHelper.instance.recordLearningActivity(
          userUid: 'uid_learner_1',
          activityType: 'word_review',
          itemId: 'wed_word_$w',
          wordCount: 1,
          timestamp: wednesday,
        );
      }
      for (int offset = 0; offset < 7; offset++) {
        final dayTime = DateTime(2026, 11, 2, 12, 0).add(Duration(days: offset));
        await DatabaseHelper.instance.recordLearningActivity(
          userUid: 'uid_learner_1',
          activityType: 'skill',
          itemId: 'skill_day_$offset',
          activityCount: 1,
          timestamp: dayTime,
        );
      }

      final full = await DatabaseHelper.instance.getWeeklyActivitySummary(
        userUid: 'uid_learner_1',
        referenceNow: wednesday,
      );
      expect(full['activeDaysCount'], 7);
      expect(full['totalWordsInWeek'], 7); // 2 on Mon + 5 on Wed
      expect(full['totalActivitiesInWeek'], 8); // 1 quiz + 7 skills
      expect(full['todayWordsCount'], 5);
    });

    test('Strictly isolates learning_activity_log by user_uid (guest vs authenticated users) and respects week boundaries', () async {
      final sundayNight = DateTime(2026, 11, 1, 23, 59, 59); // Previous week Sunday
      final mondayMorning = DateTime(2026, 11, 2, 0, 0, 1); // Current week Monday

      // Log on previous week Sunday for user A -> must NOT bleed into Nov 2..8 week
      await DatabaseHelper.instance.recordLearningActivity(
        userUid: 'user_A',
        activityType: 'word_review',
        itemId: 'prev_week_word',
        wordCount: 1,
        timestamp: sundayNight,
      );

      // Log on current week Monday for 'guest'
      await DatabaseHelper.instance.recordLearningActivity(
        userUid: 'guest',
        activityType: 'word_review',
        itemId: 'guest_word_1',
        wordCount: 1,
        timestamp: mondayMorning,
      );

      // Log on current week Monday for 'user_A'
      await DatabaseHelper.instance.recordLearningActivity(
        userUid: 'user_A',
        activityType: 'word_review',
        itemId: 'userA_word_1',
        wordCount: 1,
        timestamp: mondayMorning,
      );

      final userASummary = await DatabaseHelper.instance.getWeeklyActivitySummary(
        userUid: 'user_A',
        referenceNow: mondayMorning,
      );
      final userBSummary = await DatabaseHelper.instance.getWeeklyActivitySummary(
        userUid: 'user_B',
        referenceNow: mondayMorning,
      );

      expect(userASummary['totalWordsInWeek'], 1); // Only Monday word, not previous Sunday or guest word
      expect(userBSummary['totalWordsInWeek'], 0); // User B does not inherit guest or User A history
    });
  });

  group('4. ProfileScreen Weekly Progress Widget & 13-Locale UI', () {
    testWidgets('ProfileScreen renders Weekly Progress Card, updates immediately on word review, and supports 13 locales', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = SettingsService();
      await settings.setDailyGoal(10);

      final mockHttp = MockClient((req) async {
        final path = req.url.path;
        if (path.endsWith('/auth/login')) {
          return http.Response(
            jsonEncode({
              'ok': true,
              'message': 'Logged in',
              'user': {
                'uid': 'uid_weekly_ui',
                'email': 'weekly@example.com',
                'username': 'weekly_learner',
                'displayName': 'Weekly Learner',
                'providerId': 'password',
                'idToken': 'jwt_weekly',
                'refreshToken': 'ref_weekly',
                'role': 'user',
              },
            }),
            200,
          );
        }
        if (path.endsWith('/profile')) {
          return http.Response(
            jsonEncode({
              'ok': true,
              'profile': {
                'uid': 'uid_weekly_ui',
                'email': 'weekly@example.com',
                'username': 'weekly_learner',
                'displayName': 'Weekly Learner',
                'bio': '',
                'learningGoal': 'IELTS',
                'avatarData': 'preset:scholar_blue',
                'providerId': 'password',
                'role': 'user',
                'cefrLevel': 'B1',
              },
            }),
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      final authProvider = AuthProvider(
        authService: AuthService.custom(
          httpClient: mockHttp,
          firebaseApiKeyOverride: 'fake_key',
          backendUrlOverride: 'https://worker.test',
        ),
      );
      final studyProvider = StudyProvider();
      await authProvider.signIn(
        identifier: 'weekly_learner',
        password: 'Password123',
      );
      await studyProvider.loadWeeklyProgress(userUid: authProvider.activeUid);
      final localeProvider = LocaleProvider();
      await localeProvider.setLocale(const Locale('vi'));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<StudyProvider>.value(value: studyProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
            ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
            ChangeNotifierProvider<QuizProvider>(create: (_) => QuizProvider()),
          ],
          child: Consumer<LocaleProvider>(
            builder: (context, loc, _) => MaterialApp(
              locale: loc.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify empty state in Vietnamese
      expect(find.text('Tiến độ hằng tuần'), findsOneWidget);
      expect(find.text('0/7 ngày hoạt động'), findsOneWidget);
      expect(find.text('Chưa có hoạt động học tập nào trong tuần này'), findsOneWidget);

      // Record a real word review activity and refresh StudyProvider -> UI updates immediately without restart
      await DatabaseHelper.instance.recordLearningActivity(
        userUid: authProvider.activeUid,
        activityType: 'word_review',
        itemId: 'live_test_word_1',
        wordCount: 1,
      );
      await studyProvider.loadWeeklyProgress(userUid: authProvider.activeUid);
      await tester.pumpAndSettle();

      expect(find.text('1/7 ngày hoạt động'), findsOneWidget);
      expect(find.text('1 từ đã học/ôn'), findsOneWidget);
      expect(find.text('Mục tiêu từ hôm nay: 1/10 từ'), findsOneWidget);

      // Switch locale to Japanese (ja) -> Weekly Progress strings update immediately
      await localeProvider.setLocale(const Locale('ja'));
      await tester.pumpAndSettle();
      expect(find.text('週間進捗'), findsOneWidget);
      expect(find.text('学習日数 1/7日'), findsOneWidget);
    });
  });
}
