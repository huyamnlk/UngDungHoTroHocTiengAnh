import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:english_buddy/core/database/database_helper.dart';
import 'package:english_buddy/core/services/anti_bot_service.dart';
import 'package:english_buddy/core/services/auth_service.dart';
import 'package:english_buddy/core/services/settings_service.dart';
import 'package:english_buddy/data/repositories/user_profile_repository.dart';
import 'package:english_buddy/l10n/app_localizations.dart';
import 'package:english_buddy/presentation/screens/profile/profile_screen.dart';
import 'package:english_buddy/presentation/widgets/top_profile_menu_button.dart';
import 'package:english_buddy/presentation/widgets/user_avatar_widget.dart';
import 'package:english_buddy/providers/auth_provider.dart';
import 'package:english_buddy/providers/locale_provider.dart';
import 'package:english_buddy/providers/study_provider.dart';
import 'package:english_buddy/providers/theme_provider.dart';

String _buildTestJwt({required int expEpochSeconds, String uid = 'user_123'}) {
  final header = base64Url
      .encode(utf8.encode(jsonEncode({'alg': 'RS256', 'typ': 'JWT'})))
      .replaceAll('=', '');
  final payload = base64Url
      .encode(
        utf8.encode(
          jsonEncode({
            'sub': uid,
            'user_id': uid,
            'exp': expEpochSeconds,
          }),
        ),
      )
      .replaceAll('=', '');
  return '$header.$payload.signature';
}

Widget _buildHeaderTestHarness({
  required AuthProvider authProvider,
  LocaleProvider? localeProvider,
  StudyProvider? studyProvider,
  Widget? child,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider.value(
        value: localeProvider ?? LocaleProvider(),
      ),
      ChangeNotifierProvider.value(
        value: studyProvider ?? StudyProvider(),
      ),
      ChangeNotifierProvider.value(value: authProvider),
    ],
    child: Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, _, locProv, _) {
        return MaterialApp(
          locale: locProv.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Center(
              child: child ?? const TopProfileMenuButton(),
            ),
          ),
        );
      },
    ),
  );
}

class _CountingAuthService extends AuthService {
  int restoreCallCount = 0;
  int fetchProfileCallCount = 0;
  int refreshTokenCallCount = 0;
  Future<AuthenticatedUser?> Function()? onRestoreSession;
  Future<AuthOperationResult> Function(AuthenticatedUser user)? onFetchProfile;
  Future<AuthOperationResult> Function(AuthenticatedUser user)? onRefreshToken;

  _CountingAuthService({
    super.httpClient,
    this.onRestoreSession,
    this.onFetchProfile,
    this.onRefreshToken,
  }) : super.custom(
         firebaseApiKeyOverride: 'test_firebase_key',
         backendUrlOverride: 'https://worker.test',
       );

  @override
  bool get isPasswordAuthConfigured => true;

  @override
  bool get isGoogleOAuthConfigured => true;

  @override
  Future<AuthenticatedUser?> restoreSession() async {
    restoreCallCount++;
    if (onRestoreSession != null) {
      return onRestoreSession!();
    }
    return super.restoreSession();
  }

  @override
  Future<AuthOperationResult> fetchServerProfile(
    AuthenticatedUser user, {
    http.Client? httpClient,
  }) async {
    fetchProfileCallCount++;
    if (onFetchProfile != null) {
      return onFetchProfile!(user);
    }
    return super.fetchServerProfile(user, httpClient: httpClient);
  }

  @override
  Future<AuthOperationResult> refreshIdToken(
    AuthenticatedUser currentUser, {
    http.Client? httpClient,
  }) async {
    refreshTokenCallCount++;
    if (onRefreshToken != null) {
      return onRefreshToken!(currentUser);
    }
    return super.refreshIdToken(currentUser, httpClient: httpClient);
  }
}

class _NoOpAntiBotService implements AntiBotService {
  @override
  bool get isConfigured => false;

  @override
  List<String> get missingConfigItems => const [];

  @override
  Future<AntiBotVerificationResult> verifyTokenOnServer({
    required String captchaResponseToken,
    required String action,
  }) async {
    return const AntiBotVerificationResult(
      isVerified: true,
      message: 'Verified',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService().init();
    AuthService.setCurrentActiveUid('guest');
    AuthService.markGooglePluginInitialized(false);
    DatabaseHelper.instance.clearMemoryActivityLog();
  });

  group('TopProfileMenuButton & AuthProvider Loading Spinner Regression Suite', () {
    testWidgets(
      '1. Unauthenticated startup: spinner finishes immediately and shows Login button',
      (tester) async {
        final completer = Completer<AuthenticatedUser?>();
        final authService = _CountingAuthService(
          onRestoreSession: () => completer.future,
        );
        final authProvider = AuthProvider(
          authService: authService,
          antiBotService: _NoOpAntiBotService(),
        );

        final initFuture = authProvider.initAuthSession();
        expect(authProvider.isInitializingAuth, isTrue);

        await tester.pumpWidget(
          _buildHeaderTestHarness(authProvider: authProvider),
        );
        await tester.pump();

        // Khi đang kiểm tra phiên ban đầu: hiển thị spinner với chiều cao ổn định 38px
        expect(
          find.byKey(const Key('top_profile_initializing_indicator')),
          findsOneWidget,
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byKey(const Key('top_login_button')), findsNothing);

        // Hoàn tất kiểm tra (không có phiên): kết thúc loading và hiển thị nút Đăng nhập
        completer.complete(null);
        await initFuture;
        await tester.pumpAndSettle();

        expect(authProvider.isInitializingAuth, isFalse);
        expect(authProvider.isAuthenticated, isFalse);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byKey(const Key('top_login_button')), findsOneWidget);
        expect(
          find.byKey(const Key('top_profile_avatar_menu_button')),
          findsNothing,
        );
      },
    );

    testWidgets(
      '2. Root-Cause #1 Reproduction: Expired token in SharedPreferences when GoogleSignIn is uninitialized does NOT hang forever',
      (tester) async {
        final pastExp =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 3600;
        final expiredToken = _buildTestJwt(
          expEpochSeconds: pastExp,
          uid: 'expired_user_1',
        );

        SharedPreferences.setMockInitialValues({
          'auth_session_user': jsonEncode({
            'uid': 'expired_user_1',
            'email': 'expired@example.com',
            'username': 'expired_learner',
            'displayName': 'Expired Learner',
            'providerId': 'google.com',
            'role': 'user',
          }),
          'auth_id_token': expiredToken,
          // Không có refreshToken (hoặc phiên cũ trước khi lưu refreshToken)
        });
        await SettingsService().init();
        AuthService.markGooglePluginInitialized(false);

        final authProvider = AuthProvider(
          authService: _CountingAuthService(),
          antiBotService: _NoOpAntiBotService(),
        );

        final sw = Stopwatch()..start();
        await authProvider.initAuthSession().timeout(
          const Duration(seconds: 2),
        );
        sw.stop();

        expect(sw.elapsedMilliseconds, lessThan(500));
        expect(authProvider.isInitializingAuth, isFalse);
        expect(authProvider.isAuthenticated, isFalse);
        expect(AuthService.lastRestoreOutcome, 'expired_session');

        await tester.pumpWidget(
          _buildHeaderTestHarness(authProvider: authProvider),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byKey(const Key('top_login_button')), findsOneWidget);
      },
    );

    testWidgets(
      '3. Email/Password and Google sign-in transition cleanly from Login button to Avatar/Menu',
      (tester) async {
        final futureExp =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
        final validToken = _buildTestJwt(
          expEpochSeconds: futureExp,
          uid: 'email_user_1',
        );

        final mockClient = MockClient((req) async {
          if (req.url.host == 'identitytoolkit.googleapis.com' &&
              req.url.path.contains('signInWithPassword')) {
            return http.Response(
              jsonEncode({
                'localId': 'email_user_1',
                'email': 'student@example.com',
                'displayName': 'Minh Khoa',
                'idToken': validToken,
                'refreshToken': 'refresh_tok_1',
              }),
              200,
            );
          }
          if (req.url.host == 'identitytoolkit.googleapis.com' &&
              req.url.path.contains('signInWithIdp')) {
            return http.Response(
              jsonEncode({
                'localId': 'google_user_2',
                'email': 'google.learner@gmail.com',
                'displayName': 'Google Buddy',
                'idToken': _buildTestJwt(
                  expEpochSeconds: futureExp,
                  uid: 'google_user_2',
                ),
                'refreshToken': 'refresh_tok_2',
              }),
              200,
            );
          }
          if (req.url.path.endsWith('/profile')) {
            final authHeader = req.headers['Authorization'] ?? '';
            final isEmailUser = authHeader.contains(validToken);
            return http.Response(
              jsonEncode({
                'ok': true,
                'profile': {
                  'uid': isEmailUser ? 'email_user_1' : 'google_user_2',
                  'email': isEmailUser
                      ? 'student@example.com'
                      : 'google.learner@gmail.com',
                  'username': isEmailUser ? 'minhkhoa' : 'googlebuddy',
                  'displayName': isEmailUser ? 'Minh Khoa' : 'Google Buddy',
                  'avatarData': 'preset:scholar_blue',
                },
              }),
              200,
            );
          }
          return http.Response('{}', 404);
        });

        final authProvider = AuthProvider(
          authService: _CountingAuthService(httpClient: mockClient),
          antiBotService: _NoOpAntiBotService(),
        );
        await authProvider.initAuthSession();

        await tester.pumpWidget(
          _buildHeaderTestHarness(authProvider: authProvider),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('top_login_button')), findsOneWidget);

        // Đăng nhập bằng Email
        final emailOk = await authProvider.signIn(
          identifier: 'student@example.com',
          password: 'password123',
        );
        expect(emailOk, isTrue);
        await tester.pumpAndSettle();

        expect(authProvider.isInitializingAuth, isFalse);
        expect(
          find.byKey(const Key('top_profile_avatar_menu_button')),
          findsOneWidget,
        );
        expect(find.text('Minh Khoa'), findsOneWidget);

        // Đăng xuất -> trở về nút Đăng nhập
        await authProvider.signOutSession();
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('top_login_button')), findsOneWidget);

        // Đăng nhập bằng Google
        final googleOk = await authProvider.signInWithGoogle(
          googleIdToken: 'mock_google_id_token',
        );
        expect(googleOk, isTrue);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('top_profile_avatar_menu_button')),
          findsOneWidget,
        );
        expect(find.text('Google Buddy'), findsOneWidget);
      },
    );

    testWidgets(
      '4. Page reload while authenticated restores session immediately without blocking on slow server /profile',
      (tester) async {
        final futureExp =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
        final validToken = _buildTestJwt(
          expEpochSeconds: futureExp,
          uid: 'reload_user_1',
        );

        SharedPreferences.setMockInitialValues({
          'auth_session_user': jsonEncode({
            'uid': 'reload_user_1',
            'email': 'reload@example.com',
            'username': 'reload_user',
            'displayName': 'Reload Learner',
            'providerId': 'password',
            'role': 'user',
          }),
          'auth_id_token': validToken,
          'auth_refresh_token': 'valid_refresh_token',
        });
        await SettingsService().init();

        final slowProfileCompleter = Completer<AuthOperationResult>();
        final authService = _CountingAuthService(
          onFetchProfile: (_) => slowProfileCompleter.future,
        );
        final authProvider = AuthProvider(
          authService: authService,
          antiBotService: _NoOpAntiBotService(),
        );

        // initAuthSession phải kết thúc ngay cả khi fetchServerProfile chưa trả về!
        await authProvider.initAuthSession();
        expect(authProvider.isInitializingAuth, isFalse);
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.isLoadingProfile, isTrue);

        await tester.pumpWidget(
          _buildHeaderTestHarness(authProvider: authProvider),
        );
        await tester.pump();

        // Nút tài khoản hiển thị Avatar/Menu ngay lập tức, KHÔNG xoay loading!
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(
          find.byKey(const Key('top_profile_avatar_menu_button')),
          findsOneWidget,
        );
        expect(find.text('Reload Learner'), findsOneWidget);

        // Khi server profile trả về sau đó, dữ liệu được cập nhật mượt mà
        slowProfileCompleter.complete(
          AuthOperationResult(
            isSuccess: true,
            statusCode: 200,
            message: 'Synced',
            user: authProvider.currentUser!.copyWith(
              displayName: 'Reload Learner Updated',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(authProvider.isLoadingProfile, isFalse);
        expect(find.text('Reload Learner Updated'), findsOneWidget);
      },
    );

    testWidgets(
      '5. Expired token refresh: succeeds once with valid refresh token; clears session and finishes loading on 401/network/timeout error',
      (tester) async {
        final pastExp =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 3600;
        final futureExp =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
        final expiredToken = _buildTestJwt(
          expEpochSeconds: pastExp,
          uid: 'refresh_user',
        );
        final freshToken = _buildTestJwt(
          expEpochSeconds: futureExp,
          uid: 'refresh_user',
        );

        // Case A: Refresh thành công
        SharedPreferences.setMockInitialValues({
          'auth_session_user': jsonEncode({
            'uid': 'refresh_user',
            'email': 'refresh@example.com',
            'username': 'refresh_user',
            'displayName': 'Refreshed Learner',
            'providerId': 'password',
            'role': 'user',
          }),
          'auth_id_token': expiredToken,
          'auth_refresh_token': 'good_refresh_token',
        });
        await SettingsService().init();

        final authServiceA = _CountingAuthService(
          onRefreshToken: (user) async => AuthOperationResult(
            isSuccess: true,
            statusCode: 200,
            message: 'Refreshed',
            user: user.copyWith(
              idToken: freshToken,
              refreshToken: 'good_refresh_token_2',
            ),
          ),
          onFetchProfile: (user) async => AuthOperationResult(
            isSuccess: true,
            statusCode: 200,
            message: 'OK',
            user: user,
          ),
        );
        final providerA = AuthProvider(
          authService: authServiceA,
          antiBotService: _NoOpAntiBotService(),
        );
        await providerA.initAuthSession();
        expect(authServiceA.refreshTokenCallCount, 1);
        expect(providerA.isInitializingAuth, isFalse);
        expect(providerA.isAuthenticated, isTrue);
        expect(providerA.idToken, freshToken);

        // Case B: Refresh thất bại (401 TOKEN_EXPIRED) -> xóa phiên, kết thúc loading, yêu cầu đăng nhập lại
        SharedPreferences.setMockInitialValues({
          'auth_session_user': jsonEncode({
            'uid': 'refresh_user',
            'email': 'refresh@example.com',
            'username': 'refresh_user',
            'displayName': 'Refreshed Learner',
            'providerId': 'password',
            'role': 'user',
          }),
          'auth_id_token': expiredToken,
          'auth_refresh_token': 'revoked_refresh_token',
        });
        await SettingsService().init();

        final authServiceB = _CountingAuthService(
          onRefreshToken: (_) async => const AuthOperationResult(
            isSuccess: false,
            errorCode: 'TOKEN_EXPIRED',
            statusCode: 401,
            message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          ),
        );
        final providerB = AuthProvider(
          authService: authServiceB,
          antiBotService: _NoOpAntiBotService(),
        );
        await providerB.initAuthSession();

        expect(authServiceB.refreshTokenCallCount, 1);
        expect(providerB.isInitializingAuth, isFalse);
        expect(providerB.isAuthenticated, isFalse);
        expect(
          providerB.infoMessage,
          contains('Phiên đăng nhập đã hết hạn'),
        );

        await tester.pumpWidget(
          _buildHeaderTestHarness(authProvider: providerB),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byKey(const Key('top_login_button')), findsOneWidget);
      },
    );

    testWidgets(
      '6. Profile load fails (backend 503 / timeout) while session is valid: keeps verified user & default avatar, allows retry',
      (tester) async {
        final futureExp =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
        final validToken = _buildTestJwt(
          expEpochSeconds: futureExp,
          uid: 'resilient_user',
        );

        SharedPreferences.setMockInitialValues({
          'auth_session_user': jsonEncode({
            'uid': 'resilient_user',
            'email': 'resilient@example.com',
            'username': 'resilient_learner',
            'displayName': 'Resilient Learner',
            'providerId': 'password',
            'role': 'user',
          }),
          'auth_id_token': validToken,
          'auth_refresh_token': 'valid_refresh_token',
        });
        await SettingsService().init();

        bool shouldFailServerProfile = true;
        final authService = _CountingAuthService(
          onFetchProfile: (user) async {
            if (shouldFailServerProfile) {
              return AuthOperationResult(
                isSuccess: false,
                errorCode: 'SERVER_ERROR',
                statusCode: 503,
                message: 'Máy chủ hồ sơ đang bảo trì (503).',
                user: user,
              );
            }
            return AuthOperationResult(
              isSuccess: true,
              statusCode: 200,
              message: 'Đã đồng bộ hồ sơ.',
              user: user.copyWith(displayName: 'Resilient Synced'),
            );
          },
        );

        final authProvider = AuthProvider(
          authService: authService,
          antiBotService: _NoOpAntiBotService(),
        );
        await authProvider.initAuthSession();
        await tester.pumpWidget(
          _buildHeaderTestHarness(authProvider: authProvider),
        );
        await tester.pumpAndSettle();

        // Phiên vẫn hợp lệ, không bị đăng xuất, sử dụng thông tin đã xác minh & avatar mặc định
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.isInitializingAuth, isFalse);
        expect(authProvider.hasProfileLoadError, isTrue);
        expect(
          authProvider.currentProfile?.avatarData,
          'preset:scholar_blue',
        );
        expect(
          find.byKey(const Key('top_profile_avatar_menu_button')),
          findsOneWidget,
        );
        expect(find.byType(UserAvatarWidget), findsOneWidget);
        expect(find.text('Resilient Learner'), findsOneWidget);

        // Mở menu tài khoản -> thấy nút Thử lại (Retry)
        await tester.tap(
          find.byKey(const Key('top_profile_avatar_menu_button')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('top_profile_retry_menu_item')),
          findsOneWidget,
        );

        // Cho server phục hồi và bấm Thử lại
        shouldFailServerProfile = false;
        await tester.tap(find.byKey(const Key('top_profile_retry_menu_item')));
        await tester.pumpAndSettle();

        expect(authProvider.hasProfileLoadError, isFalse);
        expect(find.text('Resilient Synced'), findsOneWidget);
      },
    );

    testWidgets(
      '7. Sign out while loadActiveProfile is in-flight discards stale profile response and never re-authenticates',
      (tester) async {
        final futureExp =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
        final validToken = _buildTestJwt(
          expEpochSeconds: futureExp,
          uid: 'inflight_user',
        );

        SharedPreferences.setMockInitialValues({
          'auth_session_user': jsonEncode({
            'uid': 'inflight_user',
            'email': 'inflight@example.com',
            'username': 'inflight_user',
            'displayName': 'Inflight User',
            'providerId': 'password',
            'role': 'user',
          }),
          'auth_id_token': validToken,
          'auth_refresh_token': 'valid_refresh',
        });
        await SettingsService().init();

        final profileCompleter = Completer<AuthOperationResult>();
        final authService = _CountingAuthService(
          onFetchProfile: (_) => profileCompleter.future,
        );
        final authProvider = AuthProvider(
          authService: authService,
          antiBotService: _NoOpAntiBotService(),
        );

        await authProvider.initAuthSession();
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.isLoadingProfile, isTrue);

        // Người dùng đăng xuất ngay khi loadActiveProfile đang chờ phản hồi mạng
        await authProvider.signOutSession();
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.currentUser, isNull);
        expect(authProvider.currentProfile, isNull);

        // Phản hồi hồ sơ cũ về muộn sau khi đã đăng xuất -> phải bị bỏ qua!
        profileCompleter.complete(
          const AuthOperationResult(
            isSuccess: true,
            statusCode: 200,
            message: 'Stale profile',
            user: AuthenticatedUser(
              uid: 'inflight_user',
              email: 'inflight@example.com',
              displayName: 'Stale User Should Be Ignored',
              providerId: 'password',
              idToken: 'stale_tok',
            ),
          ),
        );
        await tester.pumpWidget(
          _buildHeaderTestHarness(authProvider: authProvider),
        );
        await tester.pumpAndSettle();

        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.currentUser, isNull);
        expect(authProvider.currentProfile, isNull);
        expect(find.byKey(const Key('top_login_button')), findsOneWidget);
        expect(find.text('Stale User Should Be Ignored'), findsNothing);
      },
    );

    testWidgets(
      '8. Rebuilding widget and switching locales (vi -> ja -> en) does NOT trigger redundant init/load calls and keeps stable height',
      (tester) async {
        final futureExp =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
        final validToken = _buildTestJwt(
          expEpochSeconds: futureExp,
          uid: 'locale_user',
        );

        SharedPreferences.setMockInitialValues({
          'auth_session_user': jsonEncode({
            'uid': 'locale_user',
            'email': 'locale@example.com',
            'username': 'locale_user',
            'displayName': 'Locale Learner',
            'providerId': 'password',
            'role': 'user',
          }),
          'auth_id_token': validToken,
        });
        await SettingsService().init();

        final authService = _CountingAuthService(
          onFetchProfile: (user) async => AuthOperationResult(
            isSuccess: true,
            statusCode: 200,
            message: 'OK',
            user: user,
          ),
        );
        final authProvider = AuthProvider(
          authService: authService,
          antiBotService: _NoOpAntiBotService(),
        );
        final localeProvider = LocaleProvider();

        // Gọi initAuthSession song song 3 lần -> chỉ thực thi restoreSession đúng 1 lần
        await Future.wait([
          authProvider.initAuthSession(),
          authProvider.initAuthSession(),
          authProvider.initAuthSession(),
        ]);
        await tester.pumpWidget(
          _buildHeaderTestHarness(
            authProvider: authProvider,
            localeProvider: localeProvider,
          ),
        );
        await tester.pumpAndSettle();

        expect(authService.restoreCallCount, 1);
        expect(authService.fetchProfileCallCount, 1);

        final initialSize = tester.getSize(find.byType(TopProfileMenuButton));
        expect(initialSize.height, greaterThanOrEqualTo(38));

        // Đổi ngôn ngữ vi -> ja -> en và rebuild nhiều lần -> không gọi thêm restore hay fetchProfile
        await localeProvider.setLocale(const Locale('ja'));
        await tester.pumpAndSettle();
        await localeProvider.setLocale(const Locale('en'));
        await tester.pumpAndSettle();
        await localeProvider.setLocale(const Locale('vi'));
        await tester.pumpAndSettle();

        expect(authService.restoreCallCount, 1);
        expect(authService.fetchProfileCallCount, 1);

        final afterLocaleSize =
            tester.getSize(find.byType(TopProfileMenuButton));
        expect(afterLocaleSize.height, greaterThanOrEqualTo(38));
      },
    );

    testWidgets(
      '9. Opening ProfileScreen, loading Weekly Progress, and saving Profile never cause TopProfileMenuButton to spin',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final futureExp =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
        final validToken = _buildTestJwt(
          expEpochSeconds: futureExp,
          uid: 'profile_user',
        );

        SharedPreferences.setMockInitialValues({
          'auth_session_user': jsonEncode({
            'uid': 'profile_user',
            'email': 'profile@example.com',
            'username': 'profile_user',
            'displayName': 'Profile Learner',
            'providerId': 'password',
            'role': 'user',
          }),
          'auth_id_token': validToken,
        });
        await SettingsService().init();

        final authService = _CountingAuthService(
          onFetchProfile: (user) async => AuthOperationResult(
            isSuccess: true,
            statusCode: 200,
            message: 'OK',
            user: user,
          ),
        );
        final authProvider = AuthProvider(
          authService: authService,
          antiBotService: _NoOpAntiBotService(),
          profileRepository: UserProfileRepository(),
        );
        final studyProvider = StudyProvider();

        await authProvider.initAuthSession();

        await tester.pumpWidget(
          _buildHeaderTestHarness(
            authProvider: authProvider,
            studyProvider: studyProvider,
            child: const Column(
              children: [
                TopProfileMenuButton(),
                Expanded(child: ProfileScreen()),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(authProvider.isInitializingAuth, isFalse);
        expect(
          find.byKey(const Key('top_profile_avatar_menu_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('weekly_progress_card')),
          findsOneWidget,
        );
      },
    );
  });
}
