import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import 'settings_service.dart';

class AuthenticatedUser {
  final String uid;
  final String email;
  final String displayName;
  final String providerId; // 'password' or 'google.com'
  final String idToken;
  final String role; // 'user' or 'admin'

  const AuthenticatedUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.providerId,
    required this.idToken,
    this.role = AppConstants.roleUser,
  });

  bool get isAdmin => role == AppConstants.roleAdmin;

  AuthenticatedUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? providerId,
    String? idToken,
    String? role,
  }) {
    return AuthenticatedUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      providerId: providerId ?? this.providerId,
      idToken: idToken ?? this.idToken,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toSafeSessionJson() {
    // Chỉ lưu thông tin phiên không nhạy cảm, TUYỆT ĐỐI KHÔNG lưu mật khẩu
    return {
      'uid': uid,
      'email': email,
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
      displayName: map['displayName'] as String? ?? '',
      providerId: map['providerId'] as String? ?? 'password',
      idToken: '',
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
  final AuthenticatedUser? user;

  const AuthOperationResult({
    required this.isSuccess,
    this.isUnconfigured = false,
    required this.message,
    this.user,
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
  factory AuthService() => _instance;
  AuthService._internal();

  static const String defaultFirebaseApiKey =
      'AIzaSyDDgdG_0cWuBDtdndDohnY-6k5qu9BKTL8';

  static const String defaultWebOAuthClientId =
      '313162810847-sktttqod640apltmhid0meol4hbubjfe.apps.googleusercontent.com';

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

  /// Khôi phục phiên đăng nhập từ lưu trữ chỉ khi phiên/token còn hợp lệ
  /// Tuyệt đối không tự tạo hoặc tự đăng nhập tài khoản mặc định.
  static Future<AuthenticatedUser?> getRestorableSession() async {
    try {
      final sessionJson = SettingsService().getSavedAuthSessionUser();
      final idToken = SettingsService().getSavedAuthIdToken() ?? '';
      if (sessionJson == null || sessionJson.trim().isEmpty) {
        return null;
      }
      if (idToken.isNotEmpty && !isTokenValid(idToken)) {
        await clearPersistedSessionTokens();
        return null;
      }
      final map = jsonDecode(sessionJson) as Map<String, dynamic>;
      final user = AuthenticatedUser.fromSafeSessionJson(map).copyWith(
        idToken: idToken,
      );
      if (user.uid.trim().isEmpty || user.email.trim().isEmpty) {
        await clearPersistedSessionTokens();
        return null;
      }
      final resolvedRole =
          isConfiguredBootstrapAdmin(uid: user.uid, email: user.email)
              ? AppConstants.roleAdmin
              : user.role;
      return user.copyWith(role: resolvedRole);
    } catch (_) {
      return null;
    }
  }

  /// Xóa toàn bộ phiên đăng nhập & token đã lưu khi người dùng Đăng xuất
  static Future<void> clearPersistedSessionTokens() async {
    try {
      await SettingsService().clearAuthSession();
    } catch (_) {}

    if (googleOAuthClientId.trim().isNotEmpty) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
  }

  bool get isPasswordAuthConfigured => firebaseApiKey.trim().isNotEmpty;

  bool get isGoogleOAuthConfigured =>
      (firebaseApiKey.trim().isNotEmpty || defaultFirebaseApiKey.isNotEmpty) &&
      (googleOAuthClientId.trim().isNotEmpty ||
          defaultWebOAuthClientId.isNotEmpty);

  List<String> get missingAuthConfigItems {
    final missing = <String>[];
    if (firebaseApiKey.trim().isEmpty) {
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
        message: 'Vui lòng nhập đầy đủ Tên tài khoản / Email và Mật khẩu.',
      );
    }

    if (!isPasswordAuthConfigured) {
      return const AuthOperationResult(
        isSuccess: false,
        isUnconfigured: true,
        message: 'Dịch vụ xác thực Firebase chưa được kết nối vì thiếu FIREBASE_API_KEY. Ứng dụng không tạo đăng nhập giả cục bộ. Vui lòng xem hướng dẫn cấu hình bên dưới.',
      );
    }

    // Nếu người dùng nhập username (không chứa @), cần AUTH_BACKEND_URL để phân giải username -> email
    String emailToUse = cleanId;
    if (!cleanId.contains('@')) {
      if (authBackendUrl.trim().isEmpty) {
        return const AuthOperationResult(
          isSuccess: false,
          message: 'Đăng nhập bằng Tên tài khoản (Username) yêu cầu cấu hình AUTH_BACKEND_URL để ánh xạ sang Email, hoặc bạn vui lòng nhập trực tiếp địa chỉ Email.',
        );
      }
      final resolvedEmail = await _resolveUsernameToEmail(cleanId);
      if (resolvedEmail == null) {
        return const AuthOperationResult(
          isSuccess: false,
          message: 'Không tìm thấy tài khoản tương ứng với tên đăng nhập này hoặc không kết nối được máy chủ.',
        );
      }
      emailToUse = resolvedEmail;
    }

    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${firebaseApiKey.trim()}',
    );

    try {
      final response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': emailToUse,
              'password': password,
              'returnSecureToken': true,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['localId'] != null) {
        final uid = body['localId'].toString();
        final resolvedEmail = body['email']?.toString() ?? emailToUse;
        final idToken = body['idToken']?.toString() ?? '';
        final resolvedRole = extractRoleFromTokenOrBootstrap(
          idToken: idToken,
          uid: uid,
          email: resolvedEmail,
        );
        final user = AuthenticatedUser(
          uid: uid,
          email: resolvedEmail,
          displayName: body['displayName']?.toString().isNotEmpty == true
              ? body['displayName'].toString()
              : emailToUse.split('@').first,
          providerId: 'password',
          idToken: idToken,
          role: resolvedRole,
        );
        return AuthOperationResult(
          isSuccess: true,
          message: 'Đăng nhập thành công!',
          user: user,
        );
      }

      final errCode =
          (body['error'] is Map ? body['error']['message'] : null)
              ?.toString() ??
          'UNKNOWN_ERROR';
      return AuthOperationResult(
        isSuccess: false,
        message: _translateFirebaseErrorCode(errCode),
      );
    } on TimeoutException {
      return const AuthOperationResult(
        isSuccess: false,
        message: 'Hết thời gian kết nối đến máy chủ xác thực (Timeout). Vui lòng kiểm tra kết nối mạng.',
      );
    } catch (_) {
      return const AuthOperationResult(
        isSuccess: false,
        message: 'Không thể kết nối đến dịch vụ xác thực. Vui lòng kiểm tra mạng hoặc cấu hình API Key.',
      );
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
        message: 'Vui lòng điền đầy đủ Tên hiển thị, Email và Mật khẩu để tạo tài khoản.',
      );
    }
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      return const AuthOperationResult(
        isSuccess: false,
        message: 'Địa chỉ Email không đúng định dạng.',
      );
    }
    if (password.length < 8) {
      return const AuthOperationResult(
        isSuccess: false,
        message: 'Mật khẩu phải có tối thiểu 8 ký tự để đảm bảo an toàn.',
      );
    }

    if (!isPasswordAuthConfigured) {
      return const AuthOperationResult(
        isSuccess: false,
        isUnconfigured: true,
        message: 'Chưa thể tạo tài khoản vì dự án chưa được cung cấp FIREBASE_API_KEY. Ứng dụng tuân thủ nguyên tắc bảo mật: không lưu mật khẩu cục bộ và không giả lập đăng ký thành công.',
      );
    }

    final signUpUri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${firebaseApiKey.trim()}',
    );

    try {
      final response = await http
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
        // Cập nhật displayName trên Firebase
        if (idToken.isNotEmpty && cleanUsername.isNotEmpty) {
          await _updateFirebaseProfileName(idToken, cleanUsername);
        }

        final resolvedRole = extractRoleFromTokenOrBootstrap(
          idToken: idToken,
          uid: uid,
          email: resolvedEmail,
        );

        final user = AuthenticatedUser(
          uid: uid,
          email: resolvedEmail,
          displayName: cleanUsername,
          providerId: 'password',
          idToken: idToken,
          role: resolvedRole,
        );
        return AuthOperationResult(
          isSuccess: true,
          message: 'Tạo tài khoản thành công!',
          user: user,
        );
      }

      final errCode =
          (body['error'] is Map ? body['error']['message'] : null)
              ?.toString() ??
          'UNKNOWN_ERROR';
      return AuthOperationResult(
        isSuccess: false,
        message: _translateFirebaseErrorCode(errCode),
      );
    } on TimeoutException {
      return const AuthOperationResult(
        isSuccess: false,
        message: 'Hết thời gian chờ phản hồi từ máy chủ đăng ký. Vui lòng kiểm tra kết nối mạng.',
      );
    } catch (_) {
      return const AuthOperationResult(
        isSuccess: false,
        message: 'Không thể kết nối đến dịch vụ tạo tài khoản. Vui lòng kiểm tra kết nối mạng.',
      );
    }
  }

  /// Đăng nhập bằng Google / Gmail (qua Google OAuth ID Token & Firebase `signInWithIdp`)
  Future<AuthOperationResult> signInWithGoogle({String? googleIdToken}) async {
    final effectiveApiKey = firebaseApiKey.trim().isNotEmpty
        ? firebaseApiKey.trim()
        : defaultFirebaseApiKey;
    final effectiveClientId = googleOAuthClientId.trim().isNotEmpty
        ? googleOAuthClientId.trim()
        : defaultWebOAuthClientId;

    if (effectiveApiKey.isEmpty || effectiveClientId.isEmpty) {
      return const AuthOperationResult(
        isSuccess: false,
        isUnconfigured: true,
        message:
            'Đăng nhập Google/Gmail chưa thể hoàn tất do thiếu cấu hình GOOGLE_OAUTH_CLIENT_ID và FIREBASE_API_KEY (cùng SHA-1/SHA-256 trên Android hoặc Redirect URI trên Web/Desktop). Vui lòng xem chi tiết các bước cấu hình bên dưới.',
      );
    }

    if (googleIdToken == null || googleIdToken.trim().isEmpty) {
      return const AuthOperationResult(
        isSuccess: false,
        message:
            'Chưa nhận được OAuth ID Token từ Google Sign-In. Vui lòng kiểm tra cấu hình OAuth Redirect URI / SHA-1 trên Google Cloud Console.',
      );
    }

    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=$effectiveApiKey',
    );

    try {
      debugPrint('[AuthService] Bắt đầu gửi ID token lên Firebase signInWithIdp...');
      final response = await http
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

      debugPrint('[AuthService] Firebase signInWithIdp HTTP: ${response.statusCode}');
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const AuthOperationResult(
          isSuccess: false,
          message: 'Phản hồi từ máy chủ xác thực không đúng định dạng JSON.',
        );
      }
      final body = decoded;
      if (response.statusCode == 200 && body['localId'] != null) {
        final uid = body['localId'].toString();
        final email = body['email']?.toString() ?? '';
        final idToken = body['idToken']?.toString() ?? '';
        final resolvedRole = extractRoleFromTokenOrBootstrap(
          idToken: idToken,
          uid: uid,
          email: email,
        );
        final user = AuthenticatedUser(
          uid: uid,
          email: email,
          displayName:
              body['displayName']?.toString() ??
              (email.isNotEmpty ? email.split('@').first : 'Google User'),
          providerId: 'google.com',
          idToken: idToken,
          role: resolvedRole,
        );
        return AuthOperationResult(
          isSuccess: true,
          message: 'Đăng nhập bằng Google thành công!',
          user: user,
        );
      }

      final errCode =
          (body['error'] is Map ? body['error']['message'] : null)
              ?.toString() ??
          'UNKNOWN_ERROR';
      debugPrint('[AuthService] Firebase signInWithIdp lỗi: $errCode');
      return AuthOperationResult(
        isSuccess: false,
        message: _translateFirebaseErrorCode(errCode),
      );
    } on TimeoutException {
      debugPrint('[AuthService] Firebase signInWithIdp bị timeout sau 12 giây');
      return const AuthOperationResult(
        isSuccess: false,
        message:
            'Hết thời gian chờ phản hồi từ máy chủ xác thực (Timeout). Vui lòng kiểm tra kết nối mạng và thử lại.',
      );
    } catch (e, stack) {
      debugPrint('[AuthService] Lỗi kết nối Google Auth với Firebase: $e\n$stack');
      return AuthOperationResult(
        isSuccess: false,
        message: 'Lỗi kết nối khi xác thực Google OAuth với máy chủ ($e).',
      );
    }
  }

  Future<String?> _resolveUsernameToEmail(String username) async {
    try {
      final uri = Uri.parse(
        '${authBackendUrl.trim()}/resolve-username?u=${Uri.encodeComponent(username)}',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['email'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _updateFirebaseProfileName(
    String idToken,
    String displayName,
  ) async {
    try {
      final uri = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:update?key=${firebaseApiKey.trim()}',
      );
      await http
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
    } catch (_) {}
  }

  String _translateFirebaseErrorCode(String rawCode) {
    final code = rawCode.toUpperCase();
    if (code.contains('EMAIL_NOT_FOUND')) {
      return 'Không tìm thấy tài khoản với địa chỉ Email này.';
    }
    if (code.contains('INVALID_PASSWORD') ||
        code.contains('INVALID_LOGIN_CREDENTIALS')) {
      return 'Email hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại.';
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
