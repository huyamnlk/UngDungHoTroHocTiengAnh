import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:english_buddy/core/constants/app_constants.dart';
import 'package:english_buddy/core/services/anti_bot_service.dart';
import 'package:english_buddy/core/services/auth_service.dart';
import 'package:english_buddy/core/services/settings_service.dart';
import 'package:english_buddy/l10n/app_localizations.dart';
import 'package:english_buddy/presentation/screens/auth/auth_screen.dart';
import 'package:english_buddy/presentation/screens/home/home_screen.dart';
import 'package:english_buddy/presentation/screens/main_navigation_screen.dart';
import 'package:english_buddy/presentation/widgets/custom_button.dart';
import 'package:english_buddy/providers/auth_provider.dart';
import 'package:english_buddy/providers/study_provider.dart';
import 'package:english_buddy/providers/theme_provider.dart';

class _MockRegistrationAuthService extends AuthService {
  final bool shouldSucceed;
  final String? errorMessage;
  final int statusCode;
  int registerCallCount = 0;
  int signInCallCount = 0;

  _MockRegistrationAuthService({
    this.shouldSucceed = true,
    this.errorMessage,
    this.statusCode = 200,
  }) : super.custom();

  @override
  bool get isPasswordAuthConfigured => true;

  @override
  bool get isGoogleOAuthConfigured => true;

  @override
  Future<AuthOperationResult> registerAccount({
    required String username,
    required String email,
    required String password,
  }) async {
    registerCallCount++;
    if (!shouldSucceed) {
      return AuthOperationResult(
        isSuccess: false,
        statusCode: statusCode,
        errorCode: 'REGISTRATION_FAILED',
        message: errorMessage ?? 'Tài khoản hoặc email đã tồn tại.',
      );
    }
    return AuthOperationResult(
      isSuccess: true,
      statusCode: 200,
      message: 'Tạo tài khoản thành công!',
      user: AuthenticatedUser(
        uid: 'new_registered_uid_123',
        email: email,
        username: username,
        displayName: username,
        providerId: 'password',
        idToken: 'mock_registration_id_token',
        refreshToken: 'mock_registration_refresh_token',
        role: AppConstants.roleUser,
      ),
    );
  }

  @override
  Future<AuthOperationResult> signInWithIdentifierAndPassword({
    required String identifier,
    required String password,
  }) async {
    signInCallCount++;
    if (!shouldSucceed) {
      return const AuthOperationResult(
        isSuccess: false,
        statusCode: 400,
        message: 'Tên tài khoản hoặc mật khẩu không chính xác.',
      );
    }
    return AuthOperationResult(
      isSuccess: true,
      statusCode: 200,
      message: 'Đăng nhập thành công!',
      user: AuthenticatedUser(
        uid: 'new_registered_uid_123',
        email: 'tester@example.com',
        username: identifier,
        displayName: identifier,
        providerId: 'password',
        idToken: 'mock_signin_id_token',
        refreshToken: 'mock_signin_refresh_token',
        role: AppConstants.roleUser,
      ),
    );
  }
}

class _MockRegistrationAntiBotService implements AntiBotService {
  final bool verified;
  _MockRegistrationAntiBotService({this.verified = true});

  @override
  bool get isConfigured => true;

  @override
  List<String> get missingConfigItems => const [];

  @override
  Future<AntiBotVerificationResult> verifyTokenOnServer({
    required String captchaResponseToken,
    required String action,
  }) async {
    return AntiBotVerificationResult(
      isVerified: verified,
      message: verified ? 'Anti-Bot hợp lệ' : 'Xác minh token chống bot thất bại',
    );
  }
}

Widget _buildAuthScreenTestApp({
  required AuthProvider authProvider,
  Locale locale = const Locale('vi'),
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => StudyProvider()),
      ChangeNotifierProvider.value(value: authProvider),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthScreen(initialRegisterMode: true),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService().init();
    await AuthService.clearPersistedSessionTokens();
  });

  group('Registration Flow Separation Regression Suite', () {
    testWidgets(
      '1. Successful registration: NEVER auto-navigates to HomeScreen, switches to SignIn tab, pre-fills identifier, clears passwords, and shows prompt',
      (tester) async {
        final mockAuth = _MockRegistrationAuthService(shouldSucceed: true);
        final mockAntiBot = _MockRegistrationAntiBotService(verified: true);
        final authProvider = AuthProvider(
          authService: mockAuth,
          antiBotService: mockAntiBot,
        );

        await authProvider.verifyAntiBotToken(
          tokenFromProviderWidget: 'valid_turnstile',
          action: 'register',
        );

        await tester.pumpWidget(_buildAuthScreenTestApp(authProvider: authProvider));
        await tester.pumpAndSettle();

        // Điền form đăng ký
        await tester.enterText(find.byType(TextField).at(0), 'alex_english');
        await tester.enterText(find.byType(TextField).at(1), 'alex@example.com');
        await tester.enterText(find.byType(TextField).at(2), 'SecretPass123!');
        await tester.enterText(find.byType(TextField).at(3), 'SecretPass123!');

        final registerBtn = find.widgetWithText(CustomButton, 'Tạo tài khoản');
        await tester.ensureVisible(registerBtn);
        await tester.tap(registerBtn);
        await tester.pumpAndSettle();

        // 1. Không tự đăng nhập
        expect(authProvider.isAuthenticated, false);
        expect(authProvider.currentUser, isNull);

        // 2. Không điều hướng vào HomeScreen
        expect(find.byType(MainNavigationScreen), findsNothing);
        expect(find.byType(HomeScreen), findsNothing);
        expect(find.byType(AuthScreen), findsOneWidget);

        // 3. Đã chuyển sang tab Đăng nhập
        final signInBtn = find.widgetWithText(CustomButton, 'Đăng nhập');
        expect(signInBtn, findsOneWidget);

        // 4. Ô identifier được điền sẵn username 'alex_english'
        expect(find.text('alex_english'), findsOneWidget);

        // 5. Mật khẩu và xác nhận mật khẩu đã bị xóa sạch khỏi form
        expect(find.text('SecretPass123!'), findsNothing);

        // 6. Hiển thị thông báo yêu cầu người dùng đăng nhập
        expect(
          find.text('Đăng ký thành công! Vui lòng đăng nhập để tiếp tục.'),
          findsOneWidget,
        );

        // 7. Session storage không bị ghi token tự động (refresh / reopen vẫn unauthenticated)
        expect(SettingsService().getSavedAuthSessionUser(), isNull);
        expect(SettingsService().getSavedAuthIdToken(), isNull);

        // 8. Người dùng nhập mật khẩu và bấm Đăng nhập -> lúc này mới vào HomeScreen
        final passwordField = find.byType(TextField).at(1);
        await tester.enterText(passwordField, 'SecretPass123!');
        await tester.ensureVisible(signInBtn);
        await tester.tap(signInBtn);
        await tester.pumpAndSettle();

        expect(find.byType(MainNavigationScreen), findsOneWidget);
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(AuthScreen), findsNothing);
      },
    );

    testWidgets(
      '2. Registration failure: stays on registration tab, displays error, does not navigate or clear inputs',
      (tester) async {
        final mockAuth = _MockRegistrationAuthService(
          shouldSucceed: false,
          errorMessage: 'Email này đã được sử dụng bởi tài khoản khác.',
        );
        final mockAntiBot = _MockRegistrationAntiBotService(verified: true);
        final authProvider = AuthProvider(
          authService: mockAuth,
          antiBotService: mockAntiBot,
        );

        await authProvider.verifyAntiBotToken(
          tokenFromProviderWidget: 'valid_turnstile',
          action: 'register',
        );

        await tester.pumpWidget(_buildAuthScreenTestApp(authProvider: authProvider));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).at(0), 'alex_english');
        await tester.enterText(find.byType(TextField).at(1), 'alex@example.com');
        await tester.enterText(find.byType(TextField).at(2), 'SecretPass123!');
        await tester.enterText(find.byType(TextField).at(3), 'SecretPass123!');

        final registerBtn = find.widgetWithText(CustomButton, 'Tạo tài khoản');
        await tester.ensureVisible(registerBtn);
        await tester.tap(registerBtn);
        await tester.pumpAndSettle();

        // Vẫn ở tab Đăng ký
        expect(find.widgetWithText(CustomButton, 'Tạo tài khoản'), findsOneWidget);
        expect(find.byType(MainNavigationScreen), findsNothing);
        expect(find.byType(HomeScreen), findsNothing);

        // Hiển thị lỗi cụ thể từ server
        expect(
          find.text('Email này đã được sử dụng bởi tài khoản khác.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '3. Password mismatch validation: shows error, prevents registration request from firing',
      (tester) async {
        final mockAuth = _MockRegistrationAuthService(shouldSucceed: true);
        final mockAntiBot = _MockRegistrationAntiBotService(verified: true);
        final authProvider = AuthProvider(
          authService: mockAuth,
          antiBotService: mockAntiBot,
        );

        await authProvider.verifyAntiBotToken(
          tokenFromProviderWidget: 'valid_turnstile',
          action: 'register',
        );

        await tester.pumpWidget(_buildAuthScreenTestApp(authProvider: authProvider));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).at(0), 'alex_english');
        await tester.enterText(find.byType(TextField).at(1), 'alex@example.com');
        await tester.enterText(find.byType(TextField).at(2), 'PasswordAAA');
        await tester.enterText(find.byType(TextField).at(3), 'PasswordBBB');

        final registerBtn = find.widgetWithText(CustomButton, 'Tạo tài khoản');
        await tester.ensureVisible(registerBtn);
        await tester.tap(registerBtn);
        await tester.pumpAndSettle();

        expect(mockAuth.registerCallCount, 0);
        expect(find.widgetWithText(CustomButton, 'Tạo tài khoản'), findsOneWidget);
        expect(find.text('Mật khẩu xác nhận không khớp!'), findsWidgets);
      },
    );

    testWidgets(
      '4. Localization test: Registration success message renders across 13 locales',
      (tester) async {
        for (final locale in AppLocalizations.supportedLocales) {
          final l10n = lookupAppLocalizations(locale);
          expect(
            l10n.authRegisterSuccessPleaseLogin.isNotEmpty,
            isTrue,
            reason: 'Locale ${locale.languageCode} must provide authRegisterSuccessPleaseLogin',
          );
        }
      },
    );
  });
}
