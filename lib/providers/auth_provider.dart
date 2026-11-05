import 'dart:async';

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
  bool _isLoadingProfile = false;
  bool _isSavingProfile = false;
  String? _profileLoadError;
  String? _errorMessage;
  String? _infoMessage;
  String? _verifiedCaptchaToken;

  Future<void>? _initSessionFuture;
  Future<UserProfileModel?>? _loadProfileFuture;
  int _sessionEpoch = 0;

  AuthenticatedUser? get currentUser => _currentUser;
  UserProfileModel? get currentProfile => _currentProfile;
  bool get isAuthenticated => _currentUser != null;
  String? get idToken => _currentUser?.idToken;

  /// Chỉ bật trong lúc kiểm tra khôi phục phiên ban đầu (điều khiển spinner trên TopProfileMenuButton)
  bool get isInitializingAuth => _isInitializingAuth;

  /// Trạng thái tải/đồng bộ hồ sơ cá nhân (tách biệt với khởi tạo phiên để không làm xoay nút tài khoản)
  bool get isLoadingProfile => _isLoadingProfile;

  /// Trạng thái lưu hồ sơ cá nhân
  bool get isSavingProfile => _isSavingProfile;

  /// Thông báo lỗi tải hồ sơ khi phiên đăng nhập vẫn còn hợp lệ (cho phép người dùng bấm Thử lại)
  String? get profileLoadError => _profileLoadError;
  bool get hasProfileLoadError =>
      _profileLoadError != null && _profileLoadError!.trim().isNotEmpty;

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

  /// Tạo hồ sơ dự phòng an toàn từ thông tin tài khoản đã xác minh và avatar mặc định
  /// khi việc tải hồ sơ từ máy chủ hoặc SQLite gặp lỗi tạm thời.
  UserProfileModel _buildFallbackProfile(AuthenticatedUser user) {
    final nowIso = DateTime.now().toIso8601String();
    final existing = _currentProfile;
    final defaultAvatar =
        user.isAdmin ? 'preset:admin_shield' : 'preset:scholar_blue';
    if (existing != null && existing.uid == user.uid) {
      return existing.copyWith(
        email: user.email.isNotEmpty ? user.email : existing.email,
        username: user.username.isNotEmpty ? user.username : existing.username,
        displayName: user.displayName.trim().isNotEmpty
            ? user.displayName.trim()
            : existing.displayName,
        role: user.role,
        avatarData: existing.avatarData.trim().isNotEmpty
            ? existing.avatarData
            : defaultAvatar,
      );
    }
    return UserProfileModel(
      uid: user.uid,
      email: user.email,
      username: user.username,
      displayName: user.displayName.trim().isNotEmpty
          ? user.displayName.trim()
          : (user.email.contains('@') ? user.email.split('@').first : 'Learner'),
      providerId:
          user.providerId.trim().isNotEmpty ? user.providerId.trim() : 'password',
      role: user.role,
      cefrLevel: 'A1',
      avatarData: defaultAvatar,
      createdAt: nowIso,
      updatedAt: nowIso,
    );
  }

  Future<void> _expireCurrentSession(String reasonMessage) async {
    _sessionEpoch++;
    _currentUser = null;
    _currentProfile = null;
    _profileLoadError = null;
    _isLoadingProfile = false;
    _isInitializingAuth = false;
    _errorMessage = reasonMessage;
    AuthService.setCurrentActiveUid('guest');
    await AuthService.clearPersistedSessionTokens();
    notifyListeners();
  }

  /// Khởi tạo và khôi phục phiên đăng nhập khi vừa mở app hoặc tải lại app.
  /// - Ngăn gọi trùng song song bằng `_initSessionFuture`.
  /// - Tách riêng bước khôi phục phiên (`_isInitializingAuth`) với bước đồng bộ hồ sơ (`_isLoadingProfile`),
  ///   đảm bảo nút tài khoản kết thúc loading ngay khi xác định xong phiên.
  Future<void> initAuthSession() {
    if (_initSessionFuture != null) {
      return _initSessionFuture!;
    }
    final future = _performInitAuthSession();
    _initSessionFuture = future;
    return future.whenComplete(() {
      if (identical(_initSessionFuture, future)) {
        _initSessionFuture = null;
      }
    });
  }

  Future<void> _performInitAuthSession() async {
    final epoch = ++_sessionEpoch;
    final sw = Stopwatch()..start();
    _isInitializingAuth = true;
    _profileLoadError = null;
    notifyListeners();
    debugPrint('[AuthProvider] initAuthSession: start (epoch=$epoch)');

    bool shouldSyncProfileInBackground = false;
    try {
      final savedUser = await _authService.restoreSession().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          debugPrint(
            '[AuthProvider] initAuthSession: restoreSession timed out (${sw.elapsedMilliseconds}ms)',
          );
          return null;
        },
      );

      if (epoch != _sessionEpoch) {
        return;
      }

      if (savedUser != null) {
        _currentUser = savedUser;
        _currentProfile = _buildFallbackProfile(savedUser);
        AuthService.setCurrentActiveUid(savedUser.uid);

        try {
          final localProfile = await _profileRepository
              .syncAuthenticatedUserProfile(
                uid: savedUser.uid,
                email: savedUser.email,
                username: savedUser.username,
                displayName: savedUser.displayName,
                providerId: savedUser.providerId,
                verifiedRoleFromServerOrToken: savedUser.role,
                isBootstrapAdmin: AuthService.isConfiguredBootstrapAdmin(
                  uid: savedUser.uid,
                  email: savedUser.email,
                ),
                preferIncomingDisplayName:
                    savedUser.displayName.trim().isNotEmpty,
              )
              .timeout(const Duration(seconds: 2));

          if (epoch != _sessionEpoch) return;
          _currentProfile = localProfile;
          _currentUser = savedUser.copyWith(
            username: localProfile.username,
            displayName: localProfile.displayName,
            role: localProfile.role,
          );
          await AuthService.saveSessionUser(_currentUser!);
        } on ProfileAccessDeniedException catch (e) {
          if (epoch != _sessionEpoch) return;
          _currentUser = null;
          _currentProfile = null;
          _errorMessage = e.message;
          AuthService.setCurrentActiveUid('guest');
          await AuthService.clearPersistedSessionTokens();
          return;
        } catch (e) {
          // Phiên vẫn hợp lệ nhưng đọc SQLite lỗi: giữ phiên, dùng hồ sơ dự phòng & avatar mặc định
          debugPrint(
            '[AuthProvider] initAuthSession: local profile sync error (${e.runtimeType}), using verified fallback (${sw.elapsedMilliseconds}ms)',
          );
          _profileLoadError =
              'Không thể tải hồ sơ cục bộ. Đang dùng thông tin tài khoản đã xác minh.';
        }

        shouldSyncProfileInBackground =
            _currentUser != null && _currentUser!.idToken.trim().isNotEmpty;
      } else {
        _currentUser = null;
        _currentProfile = null;
        AuthService.setCurrentActiveUid('guest');
        if (AuthService.lastRestoreOutcome == 'expired_session') {
          _infoMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
        }
      }
    } catch (e) {
      if (epoch == _sessionEpoch) {
        _currentUser = null;
        _currentProfile = null;
        AuthService.setCurrentActiveUid('guest');
      }
      debugPrint(
        '[AuthProvider] initAuthSession: unexpected error (${e.runtimeType}) (${sw.elapsedMilliseconds}ms)',
      );
    } finally {
      sw.stop();
      if (epoch == _sessionEpoch) {
        _isInitializingAuth = false;
      } else {
        _isInitializingAuth = false;
      }
      debugPrint(
        '[AuthProvider] initAuthSession: finished isAuthenticated=$isAuthenticated, uid=$activeUid, outcome=${AuthService.lastRestoreOutcome} (${sw.elapsedMilliseconds}ms)',
      );
      notifyListeners();
    }

    if (shouldSyncProfileInBackground &&
        epoch == _sessionEpoch &&
        _currentUser != null) {
      unawaited(loadActiveProfile());
    }
  }

  /// Làm mới Firebase ID Token tối đa 1 lần khi hết hạn
  Future<String?> refreshSessionToken() async {
    final user = _currentUser;
    if (user == null) return null;
    final epoch = _sessionEpoch;
    final res = await _authService
        .refreshIdToken(user)
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () => const AuthOperationResult(
            isSuccess: false,
            errorCode: 'TIMEOUT',
            statusCode: 504,
            message: 'Hết thời gian kết nối khi làm mới phiên đăng nhập.',
          ),
        );
    if (epoch != _sessionEpoch) return null;
    if (res.isSuccess && res.user != null) {
      _currentUser = res.user!;
      notifyListeners();
      return _currentUser!.idToken;
    }
    if (res.errorCode == 'TOKEN_EXPIRED' ||
        res.errorCode == 'REFRESH_TOKEN_MISSING' ||
        res.statusCode == 401) {
      await _expireCurrentSession(res.message);
    }
    return null;
  }

  /// Cho phép người dùng thử tải lại hồ sơ khi tải hồ sơ trước đó bị lỗi nhưng phiên vẫn hợp lệ
  Future<UserProfileModel?> retryLoadProfile() {
    return loadActiveProfile(forceRefresh: true);
  }

  /// Tải hồ sơ hiện tại từ SQLite & đồng bộ D1 (chỉ khi người dùng đã đăng nhập hợp lệ).
  /// - Tách riêng biến `_isLoadingProfile` để không bao giờ khóa nút tài khoản trên thanh tiêu đề.
  /// - Nếu tải profile lỗi nhưng phiên còn hợp lệ: giữ nguyên đăng nhập, dùng thông tin tài khoản đã xác minh
  ///   và avatar mặc định (`preset:scholar_blue`), đồng thời cho phép thử lại.
  Future<UserProfileModel?> loadActiveProfile({
    bool forceRefresh = false,
  }) {
    if (!forceRefresh && _loadProfileFuture != null) {
      return _loadProfileFuture!;
    }
    final future = _performLoadActiveProfile();
    _loadProfileFuture = future;
    return future.whenComplete(() {
      if (identical(_loadProfileFuture, future)) {
        _loadProfileFuture = null;
      }
    });
  }

  Future<UserProfileModel?> _performLoadActiveProfile() async {
    if (_currentUser == null) {
      _currentProfile = null;
      _profileLoadError = null;
      _isLoadingProfile = false;
      AuthService.setCurrentActiveUid('guest');
      notifyListeners();
      return null;
    }

    final epoch = _sessionEpoch;
    final targetUid = _currentUser!.uid;
    final sw = Stopwatch()..start();

    _isLoadingProfile = true;
    _profileLoadError = null;
    _currentProfile ??= _buildFallbackProfile(_currentUser!);
    notifyListeners();

    try {
      var activeUser = _currentUser!;
      String? serverSyncWarning;

      if (activeUser.idToken.trim().isNotEmpty) {
        final serverSync = await _authService
            .fetchServerProfile(activeUser)
            .timeout(
              const Duration(seconds: 7),
              onTimeout: () => AuthOperationResult(
                isSuccess: false,
                errorCode: 'TIMEOUT',
                statusCode: 504,
                message: 'Hết thời gian kết nối máy chủ hồ sơ.',
                user: activeUser,
              ),
            );

        // Chặn ghi đè nếu người dùng đã đăng xuất hoặc chuyển tài khoản trong lúc chờ mạng
        if (epoch != _sessionEpoch ||
            _currentUser == null ||
            _currentUser!.uid != targetUid) {
          debugPrint(
            '[AuthProvider] loadActiveProfile: stale response ignored after session change (epoch=$epoch vs $_sessionEpoch)',
          );
          return _currentProfile;
        }

        if (serverSync.isSuccess && serverSync.user != null) {
          activeUser = serverSync.user!;
        } else if (serverSync.statusCode == 401 &&
            serverSync.errorCode == 'TOKEN_EXPIRED') {
          // Phiên thực sự hết hạn và làm mới token thất bại -> kết thúc loading và yêu cầu đăng nhập lại
          debugPrint(
            '[AuthProvider] loadActiveProfile: session expired (401) for uid=$targetUid (${sw.elapsedMilliseconds}ms)',
          );
          await _expireCurrentSession(
            'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          );
          return null;
        } else if (serverSync.errorCode != 'UNCONFIGURED') {
          serverSyncWarning = serverSync.message.isNotEmpty
              ? serverSync.message
              : 'Không tải được hồ sơ từ máy chủ. Đang dùng thông tin đã xác minh.';
        }
      }

      final synced = await _profileRepository
          .syncAuthenticatedUserProfile(
            uid: activeUser.uid,
            email: activeUser.email,
            username: activeUser.username,
            displayName: activeUser.displayName,
            providerId: activeUser.providerId,
            verifiedRoleFromServerOrToken: activeUser.role,
            isBootstrapAdmin: AuthService.isConfiguredBootstrapAdmin(
              uid: activeUser.uid,
              email: activeUser.email,
            ),
            preferIncomingDisplayName:
                activeUser.displayName.trim().isNotEmpty,
          )
          .timeout(const Duration(seconds: 3));

      if (epoch != _sessionEpoch ||
          _currentUser == null ||
          _currentUser!.uid != targetUid) {
        return _currentProfile;
      }

      _currentProfile = synced.avatarData.trim().isNotEmpty
          ? synced
          : synced.copyWith(
              avatarData: activeUser.isAdmin
                  ? 'preset:admin_shield'
                  : 'preset:scholar_blue',
            );
      _currentUser = activeUser.copyWith(
        username: _currentProfile!.username,
        displayName: _currentProfile!.displayName,
        role: _currentProfile!.role,
      );
      _profileLoadError = serverSyncWarning;
      AuthService.setCurrentActiveUid(_currentUser!.uid);
      await AuthService.saveSessionUser(_currentUser!);
      return _currentProfile;
    } on ProfileAccessDeniedException catch (e) {
      if (epoch == _sessionEpoch) {
        _currentUser = null;
        _currentProfile = null;
        _profileLoadError = null;
        _errorMessage = e.message;
        AuthService.setCurrentActiveUid('guest');
        await AuthService.clearPersistedSessionTokens();
      }
      return null;
    } catch (e) {
      if (epoch == _sessionEpoch &&
          _currentUser != null &&
          _currentUser!.uid == targetUid) {
        _currentProfile = _buildFallbackProfile(_currentUser!);
        _profileLoadError =
            'Không thể đồng bộ hồ sơ lúc này. Đang dùng thông tin tài khoản đã xác minh.';
        debugPrint(
          '[AuthProvider] loadActiveProfile: fallback profile kept for uid=$targetUid on ${e.runtimeType} (${sw.elapsedMilliseconds}ms)',
        );
      }
      return _currentProfile;
    } finally {
      sw.stop();
      if (epoch == _sessionEpoch) {
        _isLoadingProfile = false;
        debugPrint(
          '[AuthProvider] loadActiveProfile: completed for uid=$targetUid, hasProfileError=$hasProfileLoadError (${sw.elapsedMilliseconds}ms)',
        );
        notifyListeners();
      }
    }
  }

  Future<bool> _syncProfileAfterAuth(AuthenticatedUser authUser) async {
    _sessionEpoch++;
    _profileLoadError = null;
    try {
      AuthService.setCurrentActiveUid(authUser.uid);
      final profile = await _profileRepository
          .syncAuthenticatedUserProfile(
            uid: authUser.uid,
            email: authUser.email,
            username: authUser.username,
            displayName: authUser.displayName,
            providerId: authUser.providerId,
            verifiedRoleFromServerOrToken: authUser.role,
            isBootstrapAdmin: AuthService.isConfiguredBootstrapAdmin(
              uid: authUser.uid,
              email: authUser.email,
            ),
            preferIncomingDisplayName: authUser.displayName.trim().isNotEmpty,
          )
          .timeout(const Duration(seconds: 3));
      _currentProfile = profile;
      _currentUser = authUser.copyWith(
        username: profile.username,
        displayName: profile.displayName,
        role: profile.role,
      );
      await AuthService.saveSessionUser(_currentUser!);
      return true;
    } on ProfileAccessDeniedException catch (e) {
      _currentUser = null;
      _currentProfile = null;
      AuthService.setCurrentActiveUid('guest');
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _currentUser = authUser;
      AuthService.setCurrentActiveUid(authUser.uid);
      _currentProfile = _buildFallbackProfile(authUser);
      _profileLoadError =
          'Đã đăng nhập thành công nhưng chưa đồng bộ được hồ sơ chi tiết.';
      await AuthService.saveSessionUser(_currentUser!);
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

  /// Đăng ký tài khoản mới (Không tự động đăng nhập - người dùng sẽ tự đăng nhập ở tab Đăng nhập)
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
        // Hoàn tất lưu hồ sơ người dùng nếu cần thiết mà KHÔNG gán phiên đăng nhập hoạt động
        final cleanUid = res.user!.uid.trim();
        final cleanEmail = res.user!.email.trim();
        final cleanUsername = res.user!.username.trim();
        final cleanDisplayName = res.user!.displayName.trim();

        try {
          await _profileRepository.syncAuthenticatedUserProfile(
            uid: cleanUid,
            email: cleanEmail,
            username: cleanUsername,
            displayName: cleanDisplayName,
            providerId: res.user!.providerId,
            verifiedRoleFromServerOrToken: res.user!.role,
            isBootstrapAdmin: AuthService.isConfiguredBootstrapAdmin(
              uid: cleanUid,
              email: cleanEmail,
            ),
            preferIncomingDisplayName: cleanDisplayName.isNotEmpty,
          ).timeout(const Duration(seconds: 3));
        } catch (e) {
          debugPrint('[AuthProvider] register: profile sync non-fatal error: $e');
        }

        // TUYỆT ĐỐI KHÔNG gán _currentUser, KHÔNG phát trạng thái authenticated trung gian,
        // và KHÔNG lưu token đăng nhập vào SettingsService.
        // Đảm bảo phiên active vẫn là 'guest' và xóa mọi token tạm của phiên đăng ký.
        _currentUser = null;
        _currentProfile = null;
        AuthService.setCurrentActiveUid('guest');
        await AuthService.clearPersistedSessionTokens();

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
    String? username,
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

    if (_isLoading || _isSavingProfile) return false;
    _isLoading = true;
    _isSavingProfile = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    final actor = activeUid;
    final target = (targetUid ?? actor).trim();

    if (actor != target) {
      _isLoading = false;
      _isSavingProfile = false;
      _errorMessage =
          'Truy cập bị từ chối (403 Forbidden): Bạn không được phép chỉnh sửa hồ sơ hoặc tên đăng nhập của tài khoản khác.';
      notifyListeners();
      return false;
    }

    final validationError = UserProfileModel.validateProfileInput(
      displayName: displayName,
      username: username,
      bio: bio,
      learningGoal: learningGoal,
      avatarData: avatarData,
    );
    if (validationError != null) {
      _isLoading = false;
      _isSavingProfile = false;
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    final epoch = _sessionEpoch;
    try {
      String? resolvedUsername = username;
      String resolvedDisplayName = displayName.trim();

      // Đồng bộ và kiểm tra tính duy nhất của username trên máy chủ D1 khi có idToken xác thực
      if (_currentUser!.idToken.trim().isNotEmpty) {
        final serverRes = await _authService.updateServerProfile(
          user: _currentUser!,
          targetUid: target,
          displayName: resolvedDisplayName,
          username: username,
          bio: bio,
          learningGoal: learningGoal,
          avatarData: avatarData,
          cefrLevel: isAdmin ? attemptedCefrLevel : null,
        );
        if (epoch != _sessionEpoch) return false;
        if (!serverRes.isSuccess) {
          _errorMessage = serverRes.message;
          return false;
        }
        if (serverRes.user != null) {
          _currentUser = serverRes.user!;
          resolvedDisplayName = _currentUser!.displayName;
          if (_currentUser!.username.isNotEmpty) {
            resolvedUsername = _currentUser!.username;
          }
        }
      }

      final updated = await _profileRepository.updateOwnProfile(
        actorUid: actor,
        targetUid: target,
        displayName: resolvedDisplayName,
        username: resolvedUsername,
        bio: bio,
        learningGoal: learningGoal,
        avatarData: avatarData,
        attemptedRole: attemptedRole,
        attemptedCefrLevel: attemptedCefrLevel,
      );

      if (epoch != _sessionEpoch) return false;

      _currentProfile = updated;
      _profileLoadError = null;
      if (_currentUser != null && _currentUser!.uid == updated.uid) {
        _currentUser = _currentUser!.copyWith(
          username: updated.username,
          displayName: updated.displayName,
          role: updated.role,
        );
        await AuthService.saveSessionUser(_currentUser!);
      }

      _infoMessage = 'Đã lưu cập nhật hồ sơ cá nhân thành công!';
      return true;
    } on ProfileAccessDeniedException catch (e) {
      _errorMessage = e.message;
      return false;
    } on ProfileValidationException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Không thể lưu hồ sơ: $e';
      return false;
    } finally {
      _isLoading = false;
      _isSavingProfile = false;
      notifyListeners();
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
    _sessionEpoch++;
    _currentUser = null;
    _currentProfile = null;
    _profileLoadError = null;
    _isLoading = false;
    _isInitializingAuth = false;
    _isLoadingProfile = false;
    _isSavingProfile = false;
    _verifiedCaptchaToken = null;
    _errorMessage = null;
    _infoMessage =
        'Đã đăng xuất khỏi tài khoản. Toàn bộ tiến độ học tập cục bộ trên thiết bị vẫn được giữ nguyên an toàn.';
    AuthService.setCurrentActiveUid('guest');
    AuthService.clearPersistedSessionTokens();
    notifyListeners();
  }

  /// Đăng xuất bất đồng bộ xóa sạch phiên/token trước khi điều hướng về màn hình đăng nhập
  Future<void> signOutSession() async {
    _sessionEpoch++;
    _currentUser = null;
    _currentProfile = null;
    _profileLoadError = null;
    _isLoading = false;
    _isInitializingAuth = false;
    _isLoadingProfile = false;
    _isSavingProfile = false;
    _verifiedCaptchaToken = null;
    _errorMessage = null;
    _infoMessage =
        'Đã đăng xuất khỏi tài khoản. Toàn bộ tiến độ học tập cục bộ trên thiết bị vẫn được giữ nguyên an toàn.';
    AuthService.setCurrentActiveUid('guest');
    await AuthService.clearPersistedSessionTokens();
    notifyListeners();
  }
}
