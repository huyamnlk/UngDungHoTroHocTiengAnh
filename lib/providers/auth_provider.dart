import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/services/anti_bot_service.dart';
import '../core/services/auth_service.dart';
import '../data/models/user_profile_model.dart';
import '../data/repositories/user_profile_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final AntiBotService _antiBotService;
  final UserProfileRepository _profileRepository;

  AuthProvider({
    AuthService? authService,
    AntiBotService? antiBotService,
    UserProfileRepository? profileRepository,
  })  : _authService = authService ?? AuthService(),
        _antiBotService = antiBotService ?? AntiBotService(),
        _profileRepository = profileRepository ?? UserProfileRepository();

  AuthenticatedUser? _currentUser;
  UserProfileModel? _currentProfile;
  bool _isLoading = false;
  bool _isInitializingAuth = false;
  String? _errorMessage;
  String? _infoMessage;
  String? _verifiedCaptchaToken;

  AuthenticatedUser? get currentUser => _currentUser;
  UserProfileModel? get currentProfile => _currentProfile;
  bool get isAuthenticated => _currentUser != null;
  String? get idToken => _currentUser?.idToken;
  bool get isInitializingAuth => _isInitializingAuth;

  /// Chỉ trả về true khi đã đăng nhập thực sự VÀ có vai trò 'admin'
  bool get isAdmin =>
      _currentUser != null &&
      _currentUser!.role == AppConstants.roleAdmin &&
      (_currentProfile == null || _currentProfile!.isAdmin);

  /// UID đang hoạt động (của tài khoản đã đăng nhập, hoặc 'guest' khi chưa đăng nhập)
  String get activeUid => _currentUser?.uid ?? 'guest';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;

  bool get isAuthServiceConfigured => _authService.isPasswordAuthConfigured;
  bool get isGoogleOAuthConfigured => _authService.isGoogleOAuthConfigured;
  bool get isAntiBotConfigured => _antiBotService.isConfigured;
  // Authentication is implemented separately from learner-data sync.
  // Having a Firebase project configured does not mean local data is synced.
  bool get isCloudSyncReady => false;

  List<String> get missingAuthConfigs => _authService.missingAuthConfigItems;
  List<String> get missingAntiBotConfigs => _antiBotService.missingConfigItems;

  bool get hasVerifiedAntiBot =>
      _antiBotService.isConfigured &&
      _verifiedCaptchaToken != null &&
      _verifiedCaptchaToken!.isNotEmpty;

  void clearMessages() {
    _errorMessage = null;
    _infoMessage = null;
    _verifiedCaptchaToken = null;
    notifyListeners();
  }

  void reportExternalError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Khởi tạo và khôi phục phiên đăng nhập khi vừa mở app hoặc tải lại app
  /// Chỉ khôi phục phiên khi token/phiên còn hợp lệ. Tuyệt đối không tự tạo tài khoản mặc định.
  Future<void> initAuthSession() async {
    _isInitializingAuth = true;
    notifyListeners();
    try {
      final savedUser = await AuthService.getRestorableSession();
      if (savedUser != null) {
        _currentUser = savedUser;
        final profile = await _profileRepository.syncAuthenticatedUserProfile(
          uid: savedUser.uid,
          email: savedUser.email,
          displayName: savedUser.displayName,
          providerId: savedUser.providerId,
          verifiedRoleFromServerOrToken: savedUser.role,
          isBootstrapAdmin: AuthService.isConfiguredBootstrapAdmin(
            uid: savedUser.uid,
            email: savedUser.email,
          ),
        );
        _currentProfile = profile;
        _currentUser = savedUser.copyWith(
          displayName: profile.displayName,
          role: profile.role,
        );
      } else {
        _currentUser = null;
        _currentProfile = null;
      }
    } catch (_) {
      _currentUser = null;
      _currentProfile = null;
    } finally {
      _isInitializingAuth = false;
      notifyListeners();
    }
  }

  /// Tải hồ sơ hiện tại từ SQLite (chỉ khi người dùng đã đăng nhập hợp lệ)
  Future<UserProfileModel?> loadActiveProfile() async {
    try {
      if (_currentUser != null) {
        final synced = await _profileRepository.syncAuthenticatedUserProfile(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          displayName: _currentUser!.displayName,
          providerId: _currentUser!.providerId,
          verifiedRoleFromServerOrToken: _currentUser!.role,
          isBootstrapAdmin: AuthService.isConfiguredBootstrapAdmin(
            uid: _currentUser!.uid,
            email: _currentUser!.email,
          ),
        );
        _currentProfile = synced;
        _currentUser = _currentUser!.copyWith(
          displayName: synced.displayName,
          role: synced.role,
        );
        notifyListeners();
        return synced;
      } else {
        _currentProfile = null;
        notifyListeners();
        return null;
      }
    } catch (e) {
      return _currentProfile;
    }
  }

  Future<bool> _syncProfileAfterAuth(AuthenticatedUser authUser) async {
    try {
      final profile = await _profileRepository.syncAuthenticatedUserProfile(
        uid: authUser.uid,
        email: authUser.email,
        displayName: authUser.displayName,
        providerId: authUser.providerId,
        verifiedRoleFromServerOrToken: authUser.role,
        isBootstrapAdmin: AuthService.isConfiguredBootstrapAdmin(
          uid: authUser.uid,
          email: authUser.email,
        ),
      );
      _currentProfile = profile;
      _currentUser = authUser.copyWith(
        displayName: profile.displayName,
        role: profile.role,
      );
      await AuthService.saveSessionUser(_currentUser!);
      return true;
    } on ProfileAccessDeniedException catch (e) {
      _currentUser = null;
      _currentProfile = null;
      _errorMessage = e.message;
      return false;
    } catch (_) {
      final nowIso = DateTime.now().toIso8601String();
      _currentUser = authUser;
      _currentProfile = UserProfileModel(
        uid: authUser.uid,
        email: authUser.email,
        displayName: authUser.displayName,
        providerId: authUser.providerId,
        role: authUser.role,
        cefrLevel: 'A1',
        createdAt: nowIso,
        updatedAt: nowIso,
      );
      return true;
    }
  }

  /// Bước xác minh chống bot phía server trước khi Đăng ký / Đăng nhập
  Future<bool> verifyAntiBotToken({
    required String tokenFromProviderWidget,
    required String action,
  }) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    final result = await _antiBotService.verifyTokenOnServer(
      captchaResponseToken: tokenFromProviderWidget,
      action: action,
    );

    _isLoading = false;
    if (result.isVerified) {
      _verifiedCaptchaToken = tokenFromProviderWidget.trim();
      _infoMessage = result.message;
      notifyListeners();
      return true;
    } else {
      _verifiedCaptchaToken = null;
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }
  }

  /// Đăng nhập bằng Tên tài khoản hoặc Email + Mật khẩu
  Future<bool> signIn({
    required String identifier,
    required String password,
  }) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      final res = await _authService.signInWithIdentifierAndPassword(
        identifier: identifier,
        password: password,
      );
      _verifiedCaptchaToken = null;

      if (res.isSuccess && res.user != null) {
        final syncedOk = await _syncProfileAfterAuth(res.user!);
        if (!syncedOk) {
          return false;
        }
        _infoMessage = res.message;
        return true;
      } else {
        _errorMessage = res.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi không xác định khi đăng nhập: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng ký tài khoản mới
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      // Khi tạo tài khoản mới, bắt buộc kiểm tra Anti-Bot phía server
      if (!_antiBotService.isConfigured) {
        _errorMessage =
            'Chưa thể hoàn tất tạo tài khoản: Dịch vụ chống bot (CAPTCHA_SITE_KEY & CAPTCHA_VERIFY_URL) và xác thực phía server (${_authService.isPasswordAuthConfigured ? "đã có Auth" : "thiếu FIREBASE_API_KEY"}) chưa được cấu hình. Ứng dụng không tạo trạng thái vượt qua anti-bot hay tài khoản giả.';
        return false;
      }

      if (!hasVerifiedAntiBot) {
        _errorMessage =
            'Vui lòng xác minh token chống bot (Cloudflare Turnstile / Google reCAPTCHA) với máy chủ trước khi tạo tài khoản.';
        return false;
      }

      final res = await _authService.registerAccount(
        username: username,
        email: email,
        password: password,
      );
      _verifiedCaptchaToken = null;

      if (res.isSuccess && res.user != null) {
        final syncedOk = await _syncProfileAfterAuth(res.user!);
        if (!syncedOk) {
          return false;
        }
        _infoMessage = res.message;
        return true;
      } else {
        _errorMessage = res.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi không xác định khi tạo tài khoản: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng nhập bằng Google / Gmail
  Future<bool> signInWithGoogle({String? googleIdToken}) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      final res = await _authService.signInWithGoogle(
        googleIdToken: googleIdToken,
      );
      _verifiedCaptchaToken = null;

      if (res.isSuccess && res.user != null) {
        final syncedOk = await _syncProfileAfterAuth(res.user!);
        if (!syncedOk) {
          return false;
        }
        _infoMessage = res.message;
        return true;
      } else {
        _errorMessage = res.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi không xác định khi xác thực Google: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Người dùng tự cập nhật Profile của chính mình (Chặn sửa profile của người khác hoặc tự nâng cấp role/level)
  Future<bool> updateOwnProfile({
    String? targetUid,
    required String displayName,
    required String bio,
    required String learningGoal,
    required String avatarData,
    String? attemptedRole,
    String? attemptedCefrLevel,
  }) async {
    if (!isAuthenticated || _currentUser == null) {
      _errorMessage =
          'Yêu cầu đăng nhập (401 Unauthorized): Bạn cần đăng nhập tài khoản trước khi thực hiện chỉnh sửa hồ sơ.';
      notifyListeners();
      return false;
    }

    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    final actor = activeUid;
    final target = (targetUid ?? actor).trim();

    try {
      final updated = await _profileRepository.updateOwnProfile(
        actorUid: actor,
        targetUid: target,
        displayName: displayName,
        bio: bio,
        learningGoal: learningGoal,
        avatarData: avatarData,
        attemptedRole: attemptedRole,
        attemptedCefrLevel: attemptedCefrLevel,
      );

      _currentProfile = updated;
      if (_currentUser != null && _currentUser!.uid == updated.uid) {
        _currentUser = _currentUser!.copyWith(
          displayName: updated.displayName,
          role: updated.role,
        );
      }

      _isLoading = false;
      _infoMessage = 'Đã lưu cập nhật hồ sơ cá nhân thành công!';
      notifyListeners();
      return true;
    } on ProfileAccessDeniedException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on ProfileValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể lưu hồ sơ: $e';
      notifyListeners();
      return false;
    }
  }

  // ===========================================================================
  // CÁC PHƯƠNG THỨC QUẢN TRỊ VIÊN (ADMIN-ONLY) - KIỂM TRA QUYỀN CẢ Ở PROVIDER & REPOSITORY
  // ===========================================================================

  Future<List<UserProfileModel>> adminGetUsers({
    String searchQuery = '',
    String roleFilter = 'all',
    String levelFilter = 'all',
  }) async {
    if (!isAdmin || _currentUser == null) {
      throw const AdminAccessDeniedException(
        'Truy cập bị từ chối (403 Forbidden): Chỉ tài khoản Quản trị viên mới được phép truy cập danh sách người dùng.',
      );
    }
    return _profileRepository.adminGetAllProfiles(
      actorUid: _currentUser!.uid,
      searchQuery: searchQuery,
      roleFilter: roleFilter,
      levelFilter: levelFilter,
    );
  }

  Future<UserProfileModel> adminUpdateUser({
    required String targetUid,
    required String displayName,
    required String bio,
    required String learningGoal,
    required String cefrLevel,
    required String role,
    required bool isActive,
  }) async {
    if (!isAdmin || _currentUser == null) {
      throw const AdminAccessDeniedException(
        'Truy cập bị từ chối (403 Forbidden): Chỉ tài khoản Quản trị viên mới được phép chỉnh sửa người dùng.',
      );
    }
    final updated = await _profileRepository.adminUpdateUserProfile(
      actorUid: _currentUser!.uid,
      targetUid: targetUid,
      displayName: displayName,
      bio: bio,
      learningGoal: learningGoal,
      cefrLevel: cefrLevel,
      role: role,
      isActive: isActive,
    );

    if (_currentUser!.uid == updated.uid) {
      _currentProfile = updated;
      _currentUser = _currentUser!.copyWith(
        displayName: updated.displayName,
        role: updated.role,
      );
      notifyListeners();
    }
    return updated;
  }

  Future<void> adminDeleteUser({required String targetUid}) async {
    if (!isAdmin || _currentUser == null) {
      throw const AdminAccessDeniedException(
        'Truy cập bị từ chối (403 Forbidden): Chỉ tài khoản Quản trị viên mới được phép xóa hồ sơ người dùng.',
      );
    }
    await _profileRepository.adminDeleteUserProfile(
      actorUid: _currentUser!.uid,
      targetUid: targetUid,
    );
  }

  /// Đăng xuất an toàn - Xóa phiên đăng nhập/token và giữ nguyên 100% dữ liệu học tập cục bộ trong SQLite
  void signOut() {
    _currentUser = null;
    _currentProfile = null;
    _verifiedCaptchaToken = null;
    _errorMessage = null;
    _infoMessage =
        'Đã đăng xuất khỏi tài khoản. Toàn bộ tiến độ học tập cục bộ trên thiết bị vẫn được giữ nguyên an toàn.';
    AuthService.clearPersistedSessionTokens();
    notifyListeners();
  }

  /// Đăng xuất bất đồng bộ xóa sạch phiên/token trước khi điều hướng về màn hình đăng nhập
  Future<void> signOutSession() async {
    _currentUser = null;
    _currentProfile = null;
    _verifiedCaptchaToken = null;
    _errorMessage = null;
    _infoMessage =
        'Đã đăng xuất khỏi tài khoản. Toàn bộ tiến độ học tập cục bộ trên thiết bị vẫn được giữ nguyên an toàn.';
    await AuthService.clearPersistedSessionTokens();
    notifyListeners();
  }
}
