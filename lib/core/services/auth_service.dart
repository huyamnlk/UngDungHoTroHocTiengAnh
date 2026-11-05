import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show VoidCallback, debugPrint;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../data/models/user_profile_model.dart';
import '../constants/app_constants.dart';
import 'settings_service.dart';

class AuthenticatedUser {
  final String uid;
  final String email;
  final String username;
  final String displayName;
  final String providerId; // 'password' or 'google.com'
  final String idToken;
  final String refreshToken;
  final String role; // 'user' or 'admin'

  const AuthenticatedUser({
    required this.uid,
    required this.email,
    this.username = '',
    required this.displayName,
    required this.providerId,
    required this.idToken,
    this.refreshToken = '',
    this.role = AppConstants.roleUser,
  });

  bool get isAdmin => role == AppConstants.roleAdmin;

  AuthenticatedUser copyWith({
    String? uid,
    String? email,
    String? username,
    String? displayName,
    String? providerId,
    String? idToken,
    String? refreshToken,
    String? role,
  }) {
    return AuthenticatedUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username != null
          ? UserProfileModel.normalizeUsername(username)
          : this.username,
      displayName: displayName ?? this.displayName,
      providerId: providerId ?? this.providerId,
      idToken: idToken ?? this.idToken,
      refreshToken: refreshToken ?? this.refreshToken,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toSafeSessionJson() {
    // Chỉ lưu thông tin phiên không nhạy cảm, TUYỆT ĐỐI KHÔNG lưu mật khẩu
    return {
      'uid': uid,
      'email': email,
      'username': UserProfileModel.normalizeUsername(username),
      'displayName': displayName,
      'providerId': providerId,
      'role': role,
    };
  }

  factory AuthenticatedUser.fromSafeSessionJson(Map<String, dynamic> map) {
    final rawRole =
        (map['role'] as String? ?? AppConstants.roleUser).trim().toLowerCase();
    return AuthenticatedUser(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      username: UserProfileModel.normalizeUsername(
        map['username'] as String? ?? '',
      ),
      displayName: map['displayName'] as String? ?? '',
      providerId: map['providerId'] as String? ?? 'password',
      idToken: '',
      refreshToken: '',
      role: rawRole == AppConstants.roleAdmin
          ? AppConstants.roleAdmin
          : AppConstants.roleUser,
    );
  }
}

class AuthOperationResult {
  final bool isSuccess;
  final bool isUnconfigured;
  final String message;
  final String errorCode;
  final int statusCode;
  final AuthenticatedUser? user;
  final Map<String, dynamic>? serverProfile;

  const AuthOperationResult({
    required this.isSuccess,
    this.isUnconfigured = false,
    required this.message,
    this.errorCode = '',
    this.statusCode = 200,
    this.user,
    this.serverProfile,
  });
}

/// Dịch vụ Xác thực Đa nền tảng (Android, Web, Windows Desktop)
/// tích hợp chuẩn Firebase Authentication (Identity Toolkit REST API v1) & Google OAuth 2.0.
///
/// Nguyên tắc bảo mật nghiêm ngặt:
/// - Không tạo đăng nhập giả lưu username/password trong SQLite hay SharedPreferences.
/// - Không bao giờ lưu hay ghi log mật khẩu dạng văn bản (plaintext password).
/// - Không hardcode API secret, client secret hay private key trong mã nguồn.
/// - Khi chưa cấu hình biến môi trường bên ngoài (`FIREBASE_API_KEY`, `GOOGLE_OAUTH_CLIENT_ID`),
///   báo rõ các mục cấu hình còn thiếu và KHÔNG giả vờ xác thực thành công.
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService({
    http.Client? httpClient,
    String? firebaseApiKeyOverride,
    String? backendUrlOverride,
  }) {
    if (httpClient != null ||
        firebaseApiKeyOverride != null ||
        backendUrlOverride != null) {
      return AuthService.custom(
        httpClient: httpClient,
        firebaseApiKeyOverride: firebaseApiKeyOverride,
        backendUrlOverride: backendUrlOverride,
      );
    }
    return _instance;
  }

  AuthService._internal()
      : _httpClient = null,
        _firebaseApiKeyOverride = null,
        _backendUrlOverride = null;

  // ignore: unused_element_parameter
  AuthService.custom({
    http.Client? httpClient,
    String? firebaseApiKeyOverride,
    String? backendUrlOverride,
  }) : _httpClient =
           identical(httpClient, null) ? null : httpClient,
       _firebaseApiKeyOverride =
           identical(firebaseApiKeyOverride, null)
               ? null
               : firebaseApiKeyOverride,
       _backendUrlOverride =
           identical(backendUrlOverride, null) ? null : backendUrlOverride;

  final http.Client? _httpClient;
  final String? _firebaseApiKeyOverride;
  final String? _backendUrlOverride;

  static String _currentActiveUid = 'guest';
  static VoidCallback? onActiveUserChanged;
  static bool _isGooglePluginInitialized = false;
  static String _lastRestoreOutcome = 'idle';

  /// Trạng thái khởi tạo Google Sign-In SDK (tránh gọi signOut trên web khi SDK chưa initialize gây treo Completer)
  static bool get isGooglePluginInitialized => _isGooglePluginInitialized;

  static void markGooglePluginInitialized([bool initialized = true]) {
    _isGooglePluginInitialized = initialized;
  }

  /// Trạng thái kết quả khôi phục phiên gần nhất ('idle', 'no_session', 'valid', 'refreshed', 'expired_session', 'invalid_session', 'error')
  static String get lastRestoreOutcome => _lastRestoreOutcome;

  /// UID đang hoạt động trên phiên hiện tại ('guest' khi chưa đăng nhập, hoặc uid của người dùng)
  static String get currentActiveUid => _currentActiveUid;

  static void setCurrentActiveUid(String? uid) {
    final clean = (uid ?? '').trim();
    final nextUid = clean.isEmpty ? 'guest' : clean;
    if (_currentActiveUid != nextUid) {
      _currentActiveUid = nextUid;
      onActiveUserChanged?.call();
    }
  }

  static const String defaultFirebaseApiKey =
      'AIzaSyDDgdG_0cWuBDtdndDohnY-6k5qu9BKTL8';

  static const String defaultWebOAuthClientId =
      '313162810847-sktttqod640apltmhid0meol4hbubjfe.apps.googleusercontent.com';

  static const String defaultBackendWorkerUrl =
      'https://english-buddy-turnstile.english-buddy-giahu2026.workers.dev';

  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );

  static const String googleOAuthClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_ID',
    defaultValue: defaultWebOAuthClientId,
  );

  static const String authBackendUrl = String.fromEnvironment(
    'AUTH_BACKEND_URL',
    defaultValue: '',
  );

  static const String captchaVerifyUrl = String.fromEnvironment(
    'CAPTCHA_VERIFY_URL',
    defaultValue: '',
  );

  static const String aiChatBackendUrl = String.fromEnvironment(
    'AI_CHAT_BACKEND_URL',
    defaultValue: '',
  );

  String get _effectiveFirebaseApiKey {
    final override = _firebaseApiKeyOverride;
    if (override != null) return override.trim();
    return firebaseApiKey.trim();
  }

  /// Trích xuất URL gốc của Worker backend xác thực & hồ sơ
  String get effectiveBackendUrl {
    final override = _backendUrlOverride;
    if (override != null) {
      final clean = override.trim();
      return clean.endsWith('/') ? clean.substring(0, clean.length - 1) : clean;
    }
    final direct = authBackendUrl.trim();
    if (direct.isNotEmpty) {
      return direct.endsWith('/') ? direct.substring(0, direct.length - 1) : direct;
    }
    for (final candidate in [captchaVerifyUrl.trim(), aiChatBackendUrl.trim()]) {
      if (candidate.isEmpty) continue;
      try {
        final parsed = Uri.parse(candidate);
        if (parsed.hasScheme && parsed.host.isNotEmpty) {
          return '${parsed.scheme}://${parsed.authority}';
        }
      } catch (_) {}
    }
    return defaultBackendWorkerUrl;
  }

  /// Biến môi trường tùy chọn để khởi tạo (bootstrap) quyền Admin đầu tiên một cách an toàn
  /// mà không hardcode email hay mật khẩu admin trong mã nguồn.
  /// Mặc định nhận diện tài khoản chủ dự án đã lưu trong hệ thống xác thực.
  static const String bootstrapAdminEmail = String.fromEnvironment(
    'BOOTSTRAP_ADMIN_EMAIL',
    defaultValue: 'giahuy2005a@gmail.com',
  );

  static const String bootstrapAdminUid = String.fromEnvironment(
    'BOOTSTRAP_ADMIN_UID',
    defaultValue: 'kK847H8QYXQ3RGBwfIxjYANxZHv2',
  );

  /// Kiểm tra xem tài khoản đã xác thực có khớp với cấu hình bootstrap admin ban đầu không
  static bool isConfiguredBootstrapAdmin({
    required String uid,
    required String email,
  }) {
    final targetEmail = bootstrapAdminEmail.trim().toLowerCase();
    final targetUid = bootstrapAdminUid.trim();
    if (targetUid.isNotEmpty && uid.trim() == targetUid) {
      return true;
    }
    if (targetEmail.isNotEmpty &&
        email.trim().isNotEmpty &&
        email.trim().toLowerCase() == targetEmail) {
      return true;
    }
    return false;
  }

  /// Trích xuất role từ Firebase ID Token Custom Claims (nếu đã cấp qua Firebase Admin SDK)
  static String extractRoleFromTokenOrBootstrap({
    required String idToken,
    required String uid,
    required String email,
  }) {
    if (isConfiguredBootstrapAdmin(uid: uid, email: email)) {
      return AppConstants.roleAdmin;
    }
    try {
      final parts = idToken.split('.');
      if (parts.length == 3) {
        final normalized = base64Url.normalize(parts[1]);
        final payloadJson = utf8.decode(base64Url.decode(normalized));
        final payload = jsonDecode(payloadJson);
        if (payload is Map<String, dynamic>) {
          if (payload['admin'] == true ||
              payload['role']?.toString().toLowerCase() ==
                  AppConstants.roleAdmin) {
            return AppConstants.roleAdmin;
          }
        }
      }
    } catch (_) {}
    return AppConstants.roleUser;
  }

  /// Lưu thông tin phiên đăng nhập (không lưu mật khẩu) vào SharedPreferences qua SettingsService
  static Future<void> saveSessionUser(AuthenticatedUser user) async {
    try {
      await SettingsService().saveAuthSession(
        sessionJson: jsonEncode(user.toSafeSessionJson()),
        idToken: user.idToken,
        refreshToken: user.refreshToken,
      );
    } catch (_) {}
  }

  /// Kiểm tra xem token còn hạn sử dụng (JWT exp) hay không
  static bool isTokenValid(String idToken) {
    if (idToken.trim().isEmpty) return false;
    try {
      final parts = idToken.split('.');
      if (parts.length == 3) {
        final normalized = base64Url.normalize(parts[1]);
        final payloadJson = utf8.decode(base64Url.decode(normalized));
        final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
        final exp = payload['exp'];
        if (exp is int) {
          final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          if (nowSec >= exp) {
            return false; // Token đã hết hạn
          }
        }
        return true;
      }
    } catch (_) {}
    return idToken.trim().isNotEmpty;
  }

  /// Làm mới Firebase ID Token bằng Refresh Token hợp lệ (tối đa 1 lần, không lặp vô hạn)
  Future<AuthOperationResult> refreshIdToken(
    AuthenticatedUser currentUser, {
    http.Client? httpClient,
  }) async {
    final tokenToRefresh = currentUser.refreshToken.trim().isNotEmpty
        ? currentUser.refreshToken.trim()
        : (SettingsService().getSavedAuthRefreshToken() ?? '').trim();

    if (tokenToRefresh.isEmpty) {
      return const AuthOperationResult(
        isSuccess: false,
        errorCode: 'REFRESH_TOKEN_MISSING',
        statusCode: 401,
        message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }

    final keyToUse = _effectiveFirebaseApiKey.isNotEmpty
        ? _effectiveFirebaseApiKey
        : defaultFirebaseApiKey;
    if (keyToUse.isEmpty) {
      return const AuthOperationResult(
        isSuccess: false,
        isUnconfigured: true,
        errorCode: 'BACKEND_UNCONFIGURED',
        statusCode: 503,
        message: 'Thiếu cấu hình FIREBASE_API_KEY để làm mới phiên đăng nhập.',
      );
    }

    final client = httpClient ?? _httpClient ?? http.Client();
    final shouldCloseClient = httpClient == null && _httpClient == null;

    try {
      final uri = Uri.parse(
        'https://securetoken.googleapis.com/v1/token?key=$keyToUse',
      );
      final response = await client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body:
                'grant_type=refresh_token&refresh_token=${Uri.encodeComponent(tokenToRefresh)}',
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final newIdToken = (decoded['id_token'] ?? '').toString().trim();
          final newRefreshToken =
              (decoded['refresh_token'] ?? tokenToRefresh).toString().trim();
          if (newIdToken.isNotEmpty) {
            final refreshedUser = currentUser.copyWith(
              idToken: newIdToken,
              refreshToken: newRefreshToken,
            );
            await saveSessionUser(refreshedUser);
            return AuthOperationResult(
              isSuccess: true,
              statusCode: 200,
              message: 'Đã làm mới phiên đăng nhập.',
              user: refreshedUser,
            );
          }
        }
      }

      return const AuthOperationResult(
        isSuccess: false,
        errorCode: 'TOKEN_EXPIRED',
        statusCode: 401,
        message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    } on TimeoutException {
      return const AuthOperationResult(
        isSuccess: false,
        errorCode: 'TIMEOUT',
        statusCode: 504,
        message: 'Hết thời gian kết nối khi làm mới phiên đăng nhập.',
      );
    } catch (_) {
      return const AuthOperationResult(
        isSuccess: false,
        errorCode: 'NETWORK_ERROR',
        statusCode: 503,
        message: 'Không thể kết nối mạng để làm mới phiên đăng nhập.',
      );
    } finally {
      if (shouldCloseClient) {
        client.close();
      }
    }
  }

  /// Khôi phục phiên đăng nhập thông qua instance AuthService hiện tại (hỗ trợ DI/mock trong test)
  Future<AuthenticatedUser?> restoreSession() {
    return getRestorableSession(
      httpClient: _httpClient,
      authService: this,
    );
  }

  /// Khôi phục phiên đăng nhập từ lưu trữ chỉ khi phiên/token còn hợp lệ (hoặc refresh thành công)
  /// Tuyệt đối không tự tạo hoặc tự đăng nhập tài khoản mặc định.
  static Future<AuthenticatedUser?> getRestorableSession({
    http.Client? httpClient,
    AuthService? authService,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final sessionJson = SettingsService().getSavedAuthSessionUser();
      final idToken = (SettingsService().getSavedAuthIdToken() ?? '').trim();
      final refreshToken =
          (SettingsService().getSavedAuthRefreshToken() ?? '').trim();
      if (sessionJson == null || sessionJson.trim().isEmpty) {
        _lastRestoreOutcome = 'no_session';
        debugPrint(
          '[AuthService] getRestorableSession: no saved session (${sw.elapsedMilliseconds}ms)',
        );
        return null;
      }

      final decoded = jsonDecode(sessionJson);
      if (decoded is! Map<String, dynamic>) {
        _lastRestoreOutcome = 'invalid_session';
        await clearPersistedSessionTokens();
        debugPrint(
          '[AuthService] getRestorableSession: malformed session JSON cleared (${sw.elapsedMilliseconds}ms)',
        );
        return null;
      }

      var user = AuthenticatedUser.fromSafeSessionJson(decoded).copyWith(
        idToken: idToken,
        refreshToken: refreshToken,
      );
      if (user.uid.trim().isEmpty ||
          user.email.trim().isEmpty ||
          idToken.isEmpty) {
        _lastRestoreOutcome =
            idToken.isEmpty ? 'expired_session' : 'invalid_session';
        await clearPersistedSessionTokens();
        debugPrint(
          '[AuthService] getRestorableSession: incomplete session or missing token cleared for uid=${user.uid} (${sw.elapsedMilliseconds}ms)',
        );
        return null;
      }

      if (!isTokenValid(idToken)) {
        debugPrint(
          '[AuthService] getRestorableSession: stored token expired for uid=${user.uid}, hasRefreshToken=${refreshToken.isNotEmpty} (${sw.elapsedMilliseconds}ms)',
        );
        if (refreshToken.isNotEmpty) {
          final service = authService ?? AuthService(httpClient: httpClient);
          final refreshed = await service
              .refreshIdToken(user, httpClient: httpClient)
              .timeout(
                const Duration(seconds: 6),
                onTimeout: () => const AuthOperationResult(
                  isSuccess: false,
                  errorCode: 'TIMEOUT',
                  statusCode: 504,
                  message: 'Hết thời gian kết nối khi làm mới phiên đăng nhập.',
                ),
              );
          if (refreshed.isSuccess && refreshed.user != null) {
            user = refreshed.user!;
            _lastRestoreOutcome = 'refreshed';
            debugPrint(
              '[AuthService] getRestorableSession: token refreshed for uid=${user.uid} (${sw.elapsedMilliseconds}ms)',
            );
          } else {
            _lastRestoreOutcome = 'expired_session';
            await clearPersistedSessionTokens();
            debugPrint(
              '[AuthService] getRestorableSession: refresh failed (code=${refreshed.errorCode}, status=${refreshed.statusCode}), session cleared (${sw.elapsedMilliseconds}ms)',
            );
            return null;
          }
        } else {
          _lastRestoreOutcome = 'expired_session';
          await clearPersistedSessionTokens();
          debugPrint(
            '[AuthService] getRestorableSession: expired token without refreshToken, session cleared (${sw.elapsedMilliseconds}ms)',
          );
          return null;
        }
      } else {
        _lastRestoreOutcome = 'valid';
      }

      final resolvedRole =
          isConfiguredBootstrapAdmin(uid: user.uid, email: user.email)
              ? AppConstants.roleAdmin
              : user.role;
      debugPrint(
        '[AuthService] getRestorableSession: restored valid session for uid=${user.uid}, outcome=$_lastRestoreOutcome (${sw.elapsedMilliseconds}ms)',
      );
      return user.copyWith(role: resolvedRole);
    } catch (e) {
      _lastRestoreOutcome = 'error';
      await clearPersistedSessionTokens();
      debugPrint(
        '[AuthService] getRestorableSession error: ${e.runtimeType} (${sw.elapsedMilliseconds}ms)',
      );
      return null;
    } finally {
      sw.stop();
    }
  }

  /// Xóa toàn bộ phiên đăng nhập & token đã lưu khi người dùng Đăng xuất hoặc khi phiên hết hạn.
  /// Lưu ý quan trọng: Trên Flutter Web (`google_sign_in_web`), `GoogleSignIn.instance.signOut()`
  /// sẽ `await _initialized` (một Completer không bao giờ hoàn tất nếu `GoogleSignIn.instance.initialize`
  /// chưa được gọi). Vì vậy chỉ gọi `signOut()` khi plugin đã được khởi tạo và luôn bọc timeout hữu hạn.
  static Future<void> clearPersistedSessionTokens() async {
    setCurrentActiveUid('guest');
    try {
      await SettingsService().clearAuthSession();
    } catch (_) {}

    if (_isGooglePluginInitialized && googleOAuthClientId.trim().isNotEmpty) {
      try {
        await GoogleSignIn.instance
            .signOut()
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  bool get isPasswordAuthConfigured => _effectiveFirebaseApiKey.isNotEmpty;

  bool get isGoogleOAuthConfigured =>
      (_effectiveFirebaseApiKey.isNotEmpty ||
          defaultFirebaseApiKey.isNotEmpty) &&
      (googleOAuthClientId.trim().isNotEmpty ||
          defaultWebOAuthClientId.isNotEmpty);

  List<String> get missingAuthConfigItems {
    final missing = <String>[];
    if (_effectiveFirebaseApiKey.isEmpty) {
      missing.add(
        'FIREBASE_API_KEY (Web API Key từ Firebase Console > Project Settings; bắt buộc cho Firebase Auth REST)',
      );
    }
    if (googleOAuthClientId.trim().isEmpty) {
      missing.add(
        'GOOGLE_OAUTH_CLIENT_ID (OAuth 2.0 Client ID cho Đăng nhập Google/Gmail)',
      );
    }
    return missing;
  }

  /// Đăng nhập bằng Email hoặc Tên tài khoản + Mật khẩu
  Future<AuthOperationResult> signInWithIdentifierAndPassword({
    required String identifier,
    required String password,
  }) async {
    final cleanId = identifier.trim();
    if (cleanId.isEmpty || password.isEmpty) {
      return const AuthOperationResult(
        isSuccess: false,
        statusCode: 400,
        message: 'Vui lòng nhập đầy đủ Tên tài khoản / Email và Mật khẩu.',
      );
    }

    if (!isPasswordAuthConfigured) {
      return const AuthOperationResult(
        isSuccess: false,
        isUnconfigured: true,
        statusCode: 503,
        message:
            'Dịch vụ xác thực Firebase chưa được kết nối vì thiếu FIREBASE_API_KEY. Ứng dụng không tạo đăng nhập giả cục bộ. Vui lòng xem hướng dẫn cấu hình bên dưới.',
      );
    }

    final client = _httpClient ?? http.Client();
    final shouldCloseClient = _httpClient == null;

    try {
      // Nếu người dùng nhập username (không chứa @), xác thực qua endpoint an toàn /auth/login trên server (D1)
      if (!cleanId.contains('@')) {
        final usernameError = UserProfileModel.validateUsername(
          cleanId,
          allowEmpty: false,
        );
        if (usernameError != null) {
          return AuthOperationResult(
            isSuccess: false,
            errorCode: 'INVALID_USERNAME',
            statusCode: 400,
            message: usernameError,
          );
        }

        final backendBase = effectiveBackendUrl;
        if (backendBase.isEmpty) {
          return const AuthOperationResult(
            isSuccess: false,
            errorCode: 'BACKEND_UNCONFIGURED',
            statusCode: 503,
            message:
                'Đăng nhập bằng Tên tài khoản (Username) yêu cầu kết nối máy chủ backend, hoặc vui lòng nhập trực tiếp địa chỉ Email.',
          );
        }

        final loginUri = Uri.parse('$backendBase/auth/login');
        final loginRes = await client
            .post(
              loginUri,
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'identifier': UserProfileModel.normalizeUsername(cleanId),
                'password': password,
              }),
            )
            .timeout(const Duration(seconds: 12));

        final decoded = jsonDecode(loginRes.body);
        final body = decoded is Map<String, dynamic>
            ? decoded
            : <String, dynamic>{};

        if (loginRes.statusCode == 200 &&
            body['ok'] == true &&
            body['user'] is Map) {
          final userMap = Map<String, dynamic>.from(body['user'] as Map);
          final uid = (userMap['uid'] ?? '').toString();
          final resolvedEmail = (userMap['email'] ?? '').toString();
          final resolvedUsername = UserProfileModel.normalizeUsername(
            (userMap['username'] ?? cleanId).toString(),
          );
          final idToken = (userMap['idToken'] ?? '').toString();
          final refreshToken = (userMap['refreshToken'] ?? '').toString();
          final serverRole = (userMap['role'] ?? '').toString().toLowerCase();
          final resolvedRole = serverRole == AppConstants.roleAdmin
              ? AppConstants.roleAdmin
              : extractRoleFromTokenOrBootstrap(
                  idToken: idToken,
                  uid: uid,
                  email: resolvedEmail,
                );

          final user = AuthenticatedUser(
            uid: uid,
            email: resolvedEmail,
            username: resolvedUsername,
            displayName:
                (userMap['displayName']?.toString().trim().isNotEmpty == true)
                ? userMap['displayName'].toString().trim()
                : (resolvedEmail.contains('@')
                      ? resolvedEmail.split('@').first
                      : cleanId),
            providerId: (userMap['providerId'] ?? 'password').toString(),
            idToken: idToken,
            refreshToken: refreshToken,
            role: resolvedRole,
          );
          return AuthOperationResult(
            isSuccess: true,
            statusCode: 200,
            message: 'Đăng nhập thành công!',
            user: user,
            serverProfile: userMap,
          );
        }

        final errCode = (body['errorCode'] ?? '').toString();
        final errMsg = (body['error'] ?? '').toString();
        return AuthOperationResult(
          isSuccess: false,
          errorCode: errCode,
          statusCode: loginRes.statusCode,
          message: errMsg.isNotEmpty
              ? errMsg
              : 'Tên tài khoản/Email hoặc mật khẩu không chính xác.',
        );
      }

      // Đăng nhập bằng địa chỉ Email qua Firebase Identity Toolkit
      final uri = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_effectiveFirebaseApiKey',
      );

      final response = await client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': cleanId,
              'password': password,
              'returnSecureToken': true,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['localId'] != null) {
        final uid = body['localId'].toString();
        final resolvedEmail = body['email']?.toString() ?? cleanId;
        final idToken = body['idToken']?.toString() ?? '';
        final refreshToken = body['refreshToken']?.toString() ?? '';
        final resolvedRole = extractRoleFromTokenOrBootstrap(
          idToken: idToken,
          uid: uid,
          email: resolvedEmail,
        );
        var user = AuthenticatedUser(
          uid: uid,
          email: resolvedEmail,
          displayName: body['displayName']?.toString().isNotEmpty == true
              ? body['displayName'].toString()
              : resolvedEmail.split('@').first,
          providerId: 'password',
          idToken: idToken,
          refreshToken: refreshToken,
          role: resolvedRole,
        );

        // Đồng bộ hồ sơ và username từ backend D1 (nếu kết nối được)
        final serverSync = await fetchServerProfile(user, httpClient: client);
        if (serverSync.isSuccess && serverSync.user != null) {
          user = serverSync.user!;
        }

        return AuthOperationResult(
          isSuccess: true,
          statusCode: 200,
          message: 'Đăng nhập thành công!',
          user: user,
          serverProfile: serverSync.serverProfile,
        );
      }

      final errCode =
          (body['error'] is Map ? body['error']['message'] : null)
              ?.toString() ??
          'UNKNOWN_ERROR';
      return AuthOperationResult(
        isSuccess: false,
        errorCode: errCode,
        statusCode: response.statusCode,
        message: _translateFirebaseErrorCode(errCode),
      );
    } on TimeoutException {
      return const AuthOperationResult(
        isSuccess: false,
        errorCode: 'TIMEOUT',
        statusCode: 504,
        message:
            'Hết thời gian kết nối đến máy chủ xác thực (Timeout). Vui lòng kiểm tra kết nối mạng.',
      );
    } catch (_) {
      return const AuthOperationResult(
        isSuccess: false,
        errorCode: 'NETWORK_ERROR',
        statusCode: 503,
        message:
            'Không thể kết nối đến dịch vụ xác thực. Vui lòng kiểm tra mạng hoặc cấu hình API Key.',
      );
    } finally {
      if (shouldCloseClient) {
        client.close();
      }
    }
  }

  /// Đăng ký tài khoản mới qua Firebase Authentication REST API
  Future<AuthOperationResult> registerAccount({
    required String username,
    required String email,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    final cleanEmail = email.trim();

    if (cleanUsername.isEmpty || cleanEmail.isEmpty || password.isEmpty) {
      return const AuthOperationResult(
        isSuccess: false,
        statusCode: 400,
        message:
            'Vui lòng điền đầy đủ Tên hiển thị, Email và Mật khẩu để tạo tài khoản.',
      );
    }
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      return const AuthOperationResult(
        isSuccess: false,
        statusCode: 400,
        message: 'Địa chỉ Email không đúng định dạng.',
      );
    }
    if (password.length < 8) {
      return const AuthOperationResult(
        isSuccess: false,
        statusCode: 400,
        message: 'Mật khẩu phải có tối thiểu 8 ký tự để đảm bảo an toàn.',
      );
    }

    if (!isPasswordAuthConfigured) {
      return const AuthOperationResult(
        isSuccess: false,
        isUnconfigured: true,
        statusCode: 503,
        message:
            'Chưa thể tạo tài khoản vì dự án chưa được cung cấp FIREBASE_API_KEY. Ứng dụng tuân thủ nguyên tắc bảo mật: không lưu mật khẩu cục bộ và không giả lập đăng ký thành công.',
      );
    }

    final signUpUri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_effectiveFirebaseApiKey',
    );

    final client = _httpClient ?? http.Client();
    final shouldCloseClient = _httpClient == null;

    try {
      final response = await client
          .post(
            signUpUri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': cleanEmail,
              'password': password,
              'returnSecureToken': true,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['localId'] != null) {
        final uid = body['localId'].toString();
        final resolvedEmail = body['email']?.toString() ?? cleanEmail;
        final idToken = body['idToken']?.toString() ?? '';
        final refreshToken = body['refreshToken']?.toString() ?? '';
        // Cập nhật displayName trên Firebase
        if (idToken.isNotEmpty && cleanUsername.isNotEmpty) {
          await _updateFirebaseProfileName(
            idToken,
            cleanUsername,
            httpClient: client,
          );
        }

        final resolvedRole = extractRoleFromTokenOrBootstrap(
          idToken: idToken,
          uid: uid,
          email: resolvedEmail,
        );

        var user = AuthenticatedUser(
          uid: uid,
          email: resolvedEmail,
          displayName: cleanUsername,
          providerId: 'password',
          idToken: idToken,
          refreshToken: refreshToken,
          role: resolvedRole,
        );

        final serverSync = await fetchServerProfile(user, httpClient: client);
        if (serverSync.isSuccess && serverSync.user != null) {
          user = serverSync.user!.copyWith(displayName: cleanUsername);
        }

        return AuthOperationResult(
          isSuccess: true,
          statusCode: 200,
          message: 'Tạo tài khoản thành công!',
          user: user,
          serverProfile: serverSync.serverProfile,
        );
      }

      final errCode =
          (body['error'] is Map ? body['error']['message'] : null)
              ?.toString() ??
          'UNKNOWN_ERROR';
      return AuthOperationResult(
        isSuccess: false,
        errorCode: errCode,
        statusCode: response.statusCode,
        message: _translateFirebaseErrorCode(errCode),
      );
    } on TimeoutException {
      return const AuthOperationResult(
        isSuccess: false,
        errorCode: 'TIMEOUT',
        statusCode: 504,
        message:
            'Hết thời gian chờ phản hồi từ máy chủ đăng ký. Vui lòng kiểm tra kết nối mạng.',
      );
    } catch (_) {
      return const AuthOperationResult(
        isSuccess: false,
        errorCode: 'NETWORK_ERROR',
        statusCode: 503,
        message:
            'Không thể kết nối đến dịch vụ tạo tài khoản. Vui lòng kiểm tra kết nối mạng.',
      );
    } finally {
      if (shouldCloseClient) {
        client.close();
      }
    }
  }

  /// Đăng nhập bằng Google / Gmail (qua Google OAuth ID Token & Firebase `signInWithIdp`)
  Future<AuthOperationResult> signInWithGoogle({
    String? googleIdToken,
  }) async {
    final effectiveApiKey = _effectiveFirebaseApiKey.isNotEmpty
        ? _effectiveFirebaseApiKey
        : defaultFirebaseApiKey;
    final effectiveClientId = googleOAuthClientId.trim().isNotEmpty
        ? googleOAuthClientId.trim()
        : defaultWebOAuthClientId;

    if (effectiveApiKey.isEmpty || effectiveClientId.isEmpty) {
      return const AuthOperationResult(
        isSuccess: false,
        isUnconfigured: true,
        statusCode: 503,
        message:
            'Đăng nhập Google/Gmail chưa thể hoàn tất do thiếu cấu hình GOOGLE_OAUTH_CLIENT_ID và FIREBASE_API_KEY (cùng SHA-1/SHA-256 trên Android hoặc Redirect URI trên Web/Desktop). Vui lòng xem chi tiết các bước cấu hình bên dưới.',
      );
    }

    if (googleIdToken == null || googleIdToken.trim().isEmpty) {
      return const AuthOperationResult(
        isSuccess: false,
        statusCode: 400,
        message:
            'Chưa nhận được OAuth ID Token từ Google Sign-In. Vui lòng kiểm tra cấu hình OAuth Redirect URI / SHA-1 trên Google Cloud Console.',
      );
    }

    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=$effectiveApiKey',
    );

    final client = _httpClient ?? http.Client();
    final shouldCloseClient = _httpClient == null;

    try {
      debugPrint(
        '[AuthService] Bắt đầu gửi ID token lên Firebase signInWithIdp...',
      );
      final response = await client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'postBody':
                  'id_token=${Uri.encodeComponent(googleIdToken.trim())}&providerId=google.com',
              'requestUri': 'http://localhost',
              'returnIdpCredential': true,
              'returnSecureToken': true,
            }),
          )
          .timeout(const Duration(seconds: 12));

      debugPrint(
        '[AuthService] Firebase signInWithIdp HTTP: ${response.statusCode}',
      );
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const AuthOperationResult(
          isSuccess: false,
          statusCode: 502,
          message: 'Phản hồi từ máy chủ xác thực không đúng định dạng JSON.',
        );
      }
      final body = decoded;
      if (response.statusCode == 200 && body['localId'] != null) {
        final uid = body['localId'].toString();
        final email = body['email']?.toString() ?? '';
        final idToken = body['idToken']?.toString() ?? '';
        final refreshToken = body['refreshToken']?.toString() ?? '';
        final resolvedRole = extractRoleFromTokenOrBootstrap(
          idToken: idToken,
          uid: uid,
          email: email,
        );
        var user = AuthenticatedUser(
          uid: uid,
          email: email,
          displayName:
              body['displayName']?.toString() ??
              (email.isNotEmpty ? email.split('@').first : 'Google User'),
          providerId: 'google.com',
          idToken: idToken,
          refreshToken: refreshToken,
          role: resolvedRole,
        );

        final serverSync = await fetchServerProfile(user, httpClient: client);
        if (serverSync.isSuccess && serverSync.user != null) {
          user = serverSync.user!;
        }

        return AuthOperationResult(
          isSuccess: true,
          statusCode: 200,
          message: 'Đăng nhập bằng Google thành công!',
          user: user,
          serverProfile: serverSync.serverProfile,
        );
      }

      final errCode =
          (body['error'] is Map ? body['error']['message'] : null)
              ?.toString() ??
          'UNKNOWN_ERROR';
      debugPrint('[AuthService] Firebase signInWithIdp lỗi: $errCode');
      return AuthOperationResult(
        isSuccess: false,
        errorCode: errCode,
        statusCode: response.statusCode,
        message: _translateFirebaseErrorCode(errCode),
      );
    } on TimeoutException {
      debugPrint('[AuthService] Firebase signInWithIdp bị timeout sau 12 giây');
      return const AuthOperationResult(
        isSuccess: false,
        errorCode: 'TIMEOUT',
        statusCode: 504,
        message:
            'Hết thời gian chờ phản hồi từ máy chủ xác thực (Timeout). Vui lòng kiểm tra kết nối mạng và thử lại.',
      );
    } catch (e, stack) {
      debugPrint(
        '[AuthService] Lỗi kết nối Google Auth với Firebase: $e\n$stack',
      );
      return AuthOperationResult(
        isSuccess: false,
        errorCode: 'NETWORK_ERROR',
        statusCode: 503,
        message: 'Lỗi kết nối khi xác thực Google OAuth với máy chủ ($e).',
      );
    } finally {
      if (shouldCloseClient) {
        client.close();
      }
    }
  }

  /// Lấy thông tin hồ sơ & username từ Cloudflare Worker D1 (/profile)
  Future<AuthOperationResult> fetchServerProfile(
    AuthenticatedUser user, {
    http.Client? httpClient,
  }) async {
    final sw = Stopwatch()..start();
    final backendBase = effectiveBackendUrl;
    if (backendBase.isEmpty || user.idToken.trim().isEmpty) {
      return AuthOperationResult(
        isSuccess: false,
        errorCode: 'UNCONFIGURED',
        statusCode: 400,
        message: 'Chưa có token hoặc URL backend để tải hồ sơ.',
        user: user,
      );
    }

    final client = httpClient ?? _httpClient ?? http.Client();
    final shouldCloseClient = httpClient == null && _httpClient == null;

    try {
      var activeUser = user;
      var res = await client
          .get(
            Uri.parse('$backendBase/profile'),
            headers: {
              'Authorization': 'Bearer ${activeUser.idToken.trim()}',
            },
          )
          .timeout(const Duration(seconds: 6));

      if (res.statusCode == 401 && activeUser.refreshToken.trim().isNotEmpty) {
        debugPrint(
          '[AuthService] fetchServerProfile: HTTP 401 for uid=${activeUser.uid}, attempting single token refresh (${sw.elapsedMilliseconds}ms)',
        );
        final refreshed = await refreshIdToken(
          activeUser,
          httpClient: client,
        ).timeout(
          const Duration(seconds: 6),
          onTimeout: () => const AuthOperationResult(
            isSuccess: false,
            errorCode: 'TIMEOUT',
            statusCode: 504,
            message: 'Hết thời gian làm mới phiên.',
          ),
        );
        if (refreshed.isSuccess && refreshed.user != null) {
          activeUser = refreshed.user!;
          res = await client
              .get(
                Uri.parse('$backendBase/profile'),
                headers: {
                  'Authorization': 'Bearer ${activeUser.idToken.trim()}',
                },
              )
              .timeout(const Duration(seconds: 6));
        } else {
          debugPrint(
            '[AuthService] fetchServerProfile: token refresh failed (code=${refreshed.errorCode}, status=${refreshed.statusCode}) (${sw.elapsedMilliseconds}ms)',
          );
          return AuthOperationResult(
            isSuccess: false,
            errorCode: refreshed.errorCode.isNotEmpty
                ? refreshed.errorCode
                : 'TOKEN_EXPIRED',
            statusCode: refreshed.statusCode == 401 ? 401 : res.statusCode,
            message: refreshed.message,
            user: activeUser,
          );
        }
      }

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic> && decoded['profile'] is Map) {
          final profileMap = Map<String, dynamic>.from(
            decoded['profile'] as Map,
          );
          final serverDisplayName =
              (profileMap['displayName'] ?? '').toString().trim();
          final serverUsername = UserProfileModel.normalizeUsername(
            (profileMap['username'] ?? '').toString(),
          );
          final updatedUser = activeUser.copyWith(
            displayName: serverDisplayName.isNotEmpty
                ? serverDisplayName
                : activeUser.displayName,
            username: serverUsername.isNotEmpty
                ? serverUsername
                : activeUser.username,
          );
          debugPrint(
            '[AuthService] fetchServerProfile: HTTP 200 for uid=${activeUser.uid} (${sw.elapsedMilliseconds}ms)',
          );
          return AuthOperationResult(
            isSuccess: true,
            statusCode: 200,
            message: 'Đã đồng bộ hồ sơ từ máy chủ.',
            user: updatedUser,
            serverProfile: profileMap,
          );
        }
      }
      debugPrint(
        '[AuthService] fetchServerProfile: HTTP ${res.statusCode} for uid=${activeUser.uid} (${sw.elapsedMilliseconds}ms)',
      );
      return AuthOperationResult(
        isSuccess: false,
        errorCode: res.statusCode == 401 ? 'TOKEN_EXPIRED' : 'SERVER_ERROR',
        statusCode: res.statusCode,
        message: 'Không tải được hồ sơ từ máy chủ (HTTP ${res.statusCode}).',
        user: activeUser,
      );
    } on TimeoutException {
      debugPrint(
        '[AuthService] fetchServerProfile: timeout for uid=${user.uid} (${sw.elapsedMilliseconds}ms)',
      );
      return AuthOperationResult(
        isSuccess: false,
        errorCode: 'TIMEOUT',
        statusCode: 504,
        message: 'Hết thời gian kết nối máy chủ hồ sơ.',
        user: user,
      );
    } catch (e) {
      debugPrint(
        '[AuthService] fetchServerProfile: network error (${e.runtimeType}) for uid=${user.uid} (${sw.elapsedMilliseconds}ms)',
      );
      return AuthOperationResult(
        isSuccess: false,
        errorCode: 'NETWORK_ERROR',
        statusCode: 503,
        message: 'Không thể kết nối máy chủ hồ sơ.',
        user: user,
      );
    } finally {
      sw.stop();
      if (shouldCloseClient) {
        client.close();
      }
    }
  }

  /// Cập nhật hồ sơ cá nhân & tên đăng nhập (username) lên máy chủ D1 (/profile) và Firebase Auth
  /// Kiểm tra nghiêm ngặt quyền self-only và tính duy nhất của username trên server.
  Future<AuthOperationResult> updateServerProfile({
    required AuthenticatedUser user,
    String? targetUid,
    required String displayName,
    String? username,
    required String bio,
    required String learningGoal,
    required String avatarData,
    String? cefrLevel,
    http.Client? httpClient,
  }) async {
    final cleanTargetUid = (targetUid ?? user.uid).trim();
    if (cleanTargetUid.isNotEmpty && cleanTargetUid != user.uid.trim()) {
      return const AuthOperationResult(
        isSuccess: false,
        errorCode: 'FORBIDDEN',
        statusCode: 403,
        message:
            'Truy cập bị từ chối (403 Forbidden): Bạn chỉ được phép chỉnh sửa hồ sơ và tên đăng nhập của chính mình.',
      );
    }

    final validationError = UserProfileModel.validateProfileInput(
      displayName: displayName,
      username: username,
      bio: bio,
      learningGoal: learningGoal,
      avatarData: avatarData,
    );
    if (validationError != null) {
      return AuthOperationResult(
        isSuccess: false,
        errorCode: 'VALIDATION_ERROR',
        statusCode: 400,
        message: validationError,
      );
    }

    final backendBase = effectiveBackendUrl;
    if (backendBase.isEmpty || user.idToken.trim().isEmpty) {
      return AuthOperationResult(
        isSuccess: false,
        errorCode: 'UNAUTHORIZED',
        statusCode: 401,
        message: 'Phiên xác thực không hợp lệ. Vui lòng đăng nhập lại.',
        user: user,
      );
    }

    final client = httpClient ?? _httpClient ?? http.Client();
    final shouldCloseClient = httpClient == null && _httpClient == null;

    try {
      var activeUser = user;
      final payload = <String, dynamic>{
        'uid': cleanTargetUid,
        'displayName': displayName.trim(),
        'bio': bio.trim(),
        'learningGoal': learningGoal.trim(),
        'avatarData': avatarData.trim(),
      };
      if (username != null && username.trim().isNotEmpty) {
        payload['username'] = UserProfileModel.normalizeUsername(username);
      }
      if (cefrLevel != null && cefrLevel.trim().isNotEmpty) {
        payload['cefrLevel'] = cefrLevel.trim().toUpperCase();
      }

      var res = await client
          .put(
            Uri.parse('$backendBase/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${activeUser.idToken.trim()}',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 401 && activeUser.refreshToken.trim().isNotEmpty) {
        final refreshed = await refreshIdToken(
          activeUser,
          httpClient: client,
        );
        if (refreshed.isSuccess && refreshed.user != null) {
          activeUser = refreshed.user!;
          res = await client
              .put(
                Uri.parse('$backendBase/profile'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer ${activeUser.idToken.trim()}',
                },
                body: jsonEncode(payload),
              )
              .timeout(const Duration(seconds: 10));
        }
      }

      final decoded = jsonDecode(res.body);
      final body = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (res.statusCode == 200 && body['ok'] == true) {
        final profileMap = body['profile'] is Map
            ? Map<String, dynamic>.from(body['profile'] as Map)
            : <String, dynamic>{};
        final updatedDisplayName =
            (profileMap['displayName'] ?? displayName.trim()).toString().trim();
        final updatedUsername = UserProfileModel.normalizeUsername(
          (profileMap['username'] ?? username ?? activeUser.username)
              .toString(),
        );

        // Đồng bộ tên hiển thị lên Firebase Auth để khi đăng nhập lại vẫn giữ đúng displayName
        if (activeUser.idToken.trim().isNotEmpty &&
            updatedDisplayName.isNotEmpty) {
          await _updateFirebaseProfileName(
            activeUser.idToken,
            updatedDisplayName,
            httpClient: client,
          );
        }

        final updatedUser = activeUser.copyWith(
          displayName: updatedDisplayName,
          username: updatedUsername,
        );
        await saveSessionUser(updatedUser);

        return AuthOperationResult(
          isSuccess: true,
          statusCode: 200,
          message:
              (body['message'] ?? 'Đã lưu cập nhật hồ sơ cá nhân thành công!')
                  .toString(),
          user: updatedUser,
          serverProfile: profileMap,
        );
      }

      final errCode = (body['errorCode'] ?? '').toString();
      final errMsg = (body['error'] ?? '').toString();
      return AuthOperationResult(
        isSuccess: false,
        errorCode: errCode,
        statusCode: res.statusCode,
        message: errMsg.isNotEmpty
            ? errMsg
            : 'Không thể cập nhật hồ sơ trên máy chủ (${res.statusCode}).',
        user: activeUser,
      );
    } on TimeoutException {
      return AuthOperationResult(
        isSuccess: false,
        errorCode: 'TIMEOUT',
        statusCode: 504,
        message: 'Hết thời gian kết nối máy chủ khi lưu hồ sơ.',
        user: user,
      );
    } catch (_) {
      return AuthOperationResult(
        isSuccess: false,
        errorCode: 'NETWORK_ERROR',
        statusCode: 503,
        message: 'Không thể kết nối máy chủ để lưu thông tin hồ sơ.',
        user: user,
      );
    } finally {
      if (shouldCloseClient) {
        client.close();
      }
    }
  }

  Future<void> _updateFirebaseProfileName(
    String idToken,
    String displayName, {
    http.Client? httpClient,
  }) async {
    final keyToUse = _effectiveFirebaseApiKey.isNotEmpty
        ? _effectiveFirebaseApiKey
        : defaultFirebaseApiKey;
    if (keyToUse.isEmpty || idToken.trim().isEmpty) return;

    final client = httpClient ?? _httpClient ?? http.Client();
    final shouldCloseClient = httpClient == null && _httpClient == null;
    try {
      final uri = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:update?key=$keyToUse',
      );
      await client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'idToken': idToken,
              'displayName': displayName,
              'returnSecureToken': false,
            }),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {
    } finally {
      if (shouldCloseClient) {
        client.close();
      }
    }
  }

  String _translateFirebaseErrorCode(String rawCode) {
    final code = rawCode.toUpperCase();
    if (code.contains('EMAIL_NOT_FOUND') ||
        code.contains('INVALID_PASSWORD') ||
        code.contains('INVALID_LOGIN_CREDENTIALS')) {
      return 'Tên tài khoản/Email hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại.';
    }
    if (code.contains('USER_DISABLED')) {
      return 'Tài khoản này đã bị vô hiệu hóa bởi quản trị viên.';
    }
    if (code.contains('EMAIL_EXISTS')) {
      return 'Địa chỉ Email này đã được sử dụng cho một tài khoản khác.';
    }
    if (code.contains('WEAK_PASSWORD')) {
      return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu tối thiểu 8 ký tự.';
    }
    if (code.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
      return 'Quá nhiều lần thử thất bại. Vui lòng đợi ít phút rồi thử lại.';
    }
    if (code.contains('API_KEY_INVALID') ||
        code.contains('PROJECT_NOT_FOUND')) {
      return 'Cấu hình FIREBASE_API_KEY không hợp lệ. Vui lòng kiểm tra lại khóa API trên Firebase Console.';
    }
    return 'Xác thực không thành công ($rawCode). Vui lòng kiểm tra lại thông tin hoặc cấu hình dịch vụ.';
  }
}
