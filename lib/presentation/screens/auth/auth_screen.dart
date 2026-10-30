import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/google_web_button.dart';
import '../../widgets/turnstile_widget.dart';
import '../../widgets/user_avatar_widget.dart';
import '../admin/admin_screen.dart';
import '../main_navigation_screen.dart';
import '../profile/profile_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool initialRegisterMode;

  const AuthScreen({super.key, this.initialRegisterMode = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isRegisterMode;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _captchaWidgetGeneration = 0;

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  static bool _isGoogleSdkInitialized = false;
  static Future<void>? _googleSdkInitFuture;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleAuthSubscription;
  bool _googleInitialized = false;
  String? _lastProcessedGoogleToken;
  AuthProvider? _observedAuthProvider;
  bool _wasAuthenticated = false;
  bool _hasNavigatedAfterAuth = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isRegisterMode = widget.initialRegisterMode;
    _initializeGoogleSignIn();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<AuthProvider>(context, listen: false);
    if (_observedAuthProvider != provider) {
      _observedAuthProvider?.removeListener(_onAuthProviderChanged);
      _observedAuthProvider = provider;
      _wasAuthenticated =
          provider.isAuthenticated && provider.currentUser != null;
      _observedAuthProvider!.addListener(_onAuthProviderChanged);
    }
  }

  void _onAuthProviderChanged() {
    if (!mounted) return;
    final authProvider = _observedAuthProvider;
    if (authProvider == null) return;
    final isNowAuthenticated =
        authProvider.isAuthenticated && authProvider.currentUser != null;
    if (!_wasAuthenticated && isNowAuthenticated) {
      _wasAuthenticated = true;
      _navigateToHomeOnSuccess();
    } else {
      _wasAuthenticated = isNowAuthenticated;
    }
  }

  void _navigateToHomeOnSuccess() {
    if (_hasNavigatedAfterAuth || !mounted) return;
    final authProvider = _observedAuthProvider ?? context.read<AuthProvider>();
    if (!authProvider.isAuthenticated || authProvider.currentUser == null) {
      return;
    }
    _hasNavigatedAfterAuth = true;

    void performNavigation() {
      if (!mounted) return;
      final navigator = Navigator.maybeOf(context);
      if (navigator == null) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(initialIndex: 0),
        ),
        (route) => false,
      );
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => performNavigation());
    } else {
      performNavigation();
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    final clientId = AuthService.googleOAuthClientId.trim();
    if (clientId.isEmpty) return;
    try {
      final google = GoogleSignIn.instance;
      if (!_isGoogleSdkInitialized) {
        _googleSdkInitFuture ??= google.initialize(
          clientId: kIsWeb ? clientId : null,
          serverClientId: kIsWeb ? null : clientId,
        );
        await _googleSdkInitFuture;
        _isGoogleSdkInitialized = true;
      }
      _googleAuthSubscription?.cancel();
      _googleAuthSubscription = google.authenticationEvents.listen(
        (event) {
          if (!kIsWeb) {
            // Trên Android/Mobile, luồng xác thực được điều phối trực tiếp bởi
            // `_startGoogleSignIn` (gọi await `authenticate()`).
            // Bỏ qua luồng broadcast song song trên mobile để tránh xung đột tài nguyên.
            return;
          }
          if (event is GoogleSignInAuthenticationEventSignIn) {
            final token = event.user.authentication.idToken;
            if (!mounted) return;
            if (token == null || token.trim().isEmpty) {
              context.read<AuthProvider>().reportExternalError(
                'Chưa nhận được OAuth ID Token từ Google Sign-In. Kiểm tra cấu hình OAuth Client ID.',
              );
              return;
            }
            _handleGoogleIdTokenSignIn(token);
          }
        },
        onError: (Object error) {
          debugPrint('[AuthScreen] Google authenticationEvents error: $error');
          if (!mounted) return;
          if (error is GoogleSignInException) {
            if (error.code == GoogleSignInExceptionCode.canceled) {
              final desc = error.description?.toLowerCase() ?? '';
              if (desc.contains('reauth') || desc.contains('16')) {
                context.read<AuthProvider>().reportExternalError(
                  'Lỗi xác thực Google: Ứng dụng chưa được đăng ký trong Google Cloud Console / Firebase (UNREGISTERED_ON_API_CONSOLE), hoặc tài khoản cần cấp lại quyền.\n\n'
                  'Cần đảm bảo OAuth Client ID (Android) có Package: com.englishbuddy.app.english_buddy và SHA-1: 23:CE:79:EB:C4:E2:69:9E:8E:32:63:12:F2:72:41:11:84:1A:29:C4',
                );
              }
              return;
            }
          }
        },
      );
      if (mounted) setState(() => _googleInitialized = true);
    } catch (_) {
      if (mounted) {
        context.read<AuthProvider>().reportExternalError(
          'Không khởi tạo được Google Sign-In. Kiểm tra OAuth Client ID và cấu hình nền tảng.',
        );
      }
    }
  }

  Future<void> _handleGoogleIdTokenSignIn(String idToken) async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoading || authProvider.isAuthenticated) return;
    if (_lastProcessedGoogleToken == idToken) return;
    _lastProcessedGoogleToken = idToken;
    setState(() => _isSubmitting = true);
    try {
      final ok = await authProvider.signInWithGoogle(googleIdToken: idToken);
      if (!mounted) return;
      if (ok &&
          authProvider.isAuthenticated &&
          authProvider.currentUser != null) {
        _navigateToHomeOnSuccess();
      }
    } finally {
      _lastProcessedGoogleToken = null;
      if (mounted && !_hasNavigatedAfterAuth) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _startGoogleSignIn(AuthProvider authProvider) async {
    if (_isSubmitting || authProvider.isLoading) return;
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      authProvider.reportExternalError(
        'Đăng nhập Google chưa được hỗ trợ trên desktop native trong cấu hình này. Hãy dùng Web hoặc Android.',
      );
      return;
    }
    if (!_googleInitialized) {
      authProvider.reportExternalError(
        'Google Sign-In chưa sẵn sàng. Kiểm tra cấu hình GOOGLE_OAUTH_CLIENT_ID và kết nối mạng.',
      );
      return;
    }
    if (kIsWeb) return; // Web uses Google's official rendered button.
    setState(() => _isSubmitting = true);
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.trim().isEmpty) {
        if (mounted) {
          authProvider.reportExternalError(
            'Chưa nhận được OAuth ID Token từ Google Sign-In. Kiểm tra cấu hình OAuth Client ID và SHA-1 trên Google Cloud Console.',
          );
        }
        return;
      }
      if (mounted) {
        await _handleGoogleIdTokenSignIn(idToken);
      }
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      final desc = (e.description ?? '').toLowerCase();
      debugPrint('[AuthScreen] GoogleSignInException: code=${e.code}, desc=${e.description}');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        if (desc.contains('reauth') || desc.contains('16')) {
          authProvider.reportExternalError(
            'Lỗi xác thực Google trên Android: Ứng dụng chưa được đăng ký trong Google Cloud Console / Firebase cho mã SHA-1 này, hoặc tài khoản Google trên thiết bị cần cấp lại quyền (UNREGISTERED_ON_API_CONSOLE / Account reauth failed).\n\n'
            'Hãy kiểm tra rằng OAuth Client ID (Android) trong Google Cloud Console có:\n'
            '• Package name: com.englishbuddy.app.english_buddy\n'
            '• SHA-1 của máy: 23:CE:79:EB:C4:E2:69:9E:8E:32:63:12:F2:72:41:11:84:1A:29:C4',
          );
          return;
        }
        // Người dùng tự hủy / đóng bảng chọn tài khoản - không báo lỗi đỏ, kết thúc trạng thái chờ.
        return;
      }
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError) {
        authProvider.reportExternalError(
          'Lỗi cấu hình OAuth client (SHA-1 hoặc Package Name chưa khớp trên Google Cloud Console / Firebase): ${e.description ?? ""}',
        );
      } else if (e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        authProvider.reportExternalError(
          'Dịch vụ Google Play Services không khả dụng hoặc chưa được cấu hình: ${e.description ?? ""}',
        );
      } else if (e.code == GoogleSignInExceptionCode.interrupted) {
        authProvider.reportExternalError(
          'Quá trình đăng nhập Google bị gián đoạn. Vui lòng thử lại.',
        );
      } else {
        authProvider.reportExternalError(
          'Đăng nhập Google không thành công (${e.description ?? e.code.name}). Vui lòng kiểm tra kết nối mạng và thử lại.',
        );
      }
    } catch (e) {
      if (mounted) {
        authProvider.reportExternalError(
          'Đăng nhập Google không thành công. Vui lòng kiểm tra kết nối mạng và cấu hình OAuth (${e.toString()}).',
        );
      }
    } finally {
      if (mounted && !_hasNavigatedAfterAuth) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _observedAuthProvider?.removeListener(_onAuthProviderChanged);
    _identifierController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _googleAuthSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleSubmit(AuthProvider authProvider) async {
    if (_isSubmitting || authProvider.isLoading) return;
    FocusScope.of(context).unfocus();
    if (_isRegisterMode) {
      if (_passwordController.text != _confirmPasswordController.text) {
        authProvider.reportExternalError('Mật khẩu xác nhận không khớp!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu xác nhận không khớp!'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
      setState(() => _isSubmitting = true);
      try {
        final ok = await authProvider.register(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        if (ok &&
            authProvider.isAuthenticated &&
            authProvider.currentUser != null) {
          _passwordController.clear();
          _confirmPasswordController.clear();
          _navigateToHomeOnSuccess();
          return;
        }
      } finally {
        if (mounted && !_hasNavigatedAfterAuth) {
          setState(() => _isSubmitting = false);
        }
      }
    } else {
      setState(() => _isSubmitting = true);
      try {
        final ok = await authProvider.signIn(
          identifier: _identifierController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        if (ok &&
            authProvider.isAuthenticated &&
            authProvider.currentUser != null) {
          _passwordController.clear();
          _navigateToHomeOnSuccess();
          return;
        }
      } finally {
        if (mounted && !_hasNavigatedAfterAuth) {
          setState(() => _isSubmitting = false);
        }
      }
    }
    if (mounted && !_hasNavigatedAfterAuth && authProvider.isAntiBotConfigured) {
      setState(() => _captchaWidgetGeneration++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          authProvider.isAuthenticated
              ? 'Tài khoản & Đồng bộ dữ liệu'
              : (_isRegisterMode ? 'Tạo tài khoản mới' : 'Đăng nhập tài khoản'),
        ),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ứng dụng English Buddy (căn giữa hoàn hảo phía trên biểu mẫu đăng nhập / đăng ký)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        key: const Key('auth_screen_app_logo'),
                        width: 112,
                        height: 112,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.school_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),

                // Biểu mẫu đăng nhập / tạo tài khoản hoặc thẻ tài khoản đã đăng nhập
                if (authProvider.isAuthenticated &&
                    authProvider.currentUser != null)
                  _buildAuthenticatedView(context, authProvider)
                else
                  _buildAuthFormView(context, authProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final user = authProvider.currentUser!;
    final profile = authProvider.currentProfile;
    final isAdmin = authProvider.isAdmin;
    final avatarData = profile?.avatarData ?? 'preset:scholar_blue';
    final cefrLevel = profile?.cefrLevel ?? 'A1';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.success),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              UserAvatarWidget(
                avatarData: avatarData,
                displayName: user.displayName,
                size: 56,
                showAdminBadge: isAdmin,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          user.displayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryContainerCol,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'CEFR $cefrLevel',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: context.primaryAccent,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? context.warningLightCol
                                : context.primaryContainerCol,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isAdmin ? 'Vai trò: Admin' : 'Vai trò: User',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isAdmin
                                  ? AppColors.warning
                                  : context.primaryAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.email} • Provider: ${user.providerId}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    if (profile != null && profile.bio.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        profile.bio,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.scaffoldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Tài khoản đã xác thực. Tiến độ học hiện vẫn lưu trên thiết bị; tính năng đồng bộ đám mây chưa được triển khai.',
              style: TextStyle(
                fontSize: 12.5,
                color: context.textSecondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: const Text('Chỉnh sửa Profile'),
              ),
              if (isAdmin)
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
                    );
                  },
                  icon: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 18,
                  ),
                  label: const Text('Khu vực Quản trị (Admin)'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          CustomButton(
            text: 'Đăng xuất tài khoản',
            icon: Icons.logout_rounded,
            isOutlined: true,
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthFormView(BuildContext context, AuthProvider authProvider) {
    final isBusy = _isSubmitting || authProvider.isLoading;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chuyển đổi Đăng nhập / Tạo tài khoản
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Đăng nhập')),
                  selected: !_isRegisterMode,
                  onSelected: isBusy
                      ? null
                      : (_) {
                          authProvider.clearMessages();
                          setState(() => _isRegisterMode = false);
                        },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Tạo tài khoản mới')),
                  selected: _isRegisterMode,
                  onSelected: isBusy
                      ? null
                      : (_) {
                          authProvider.clearMessages();
                          setState(() => _isRegisterMode = true);
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Thông báo lỗi / trạng thái rõ ràng
          if (authProvider.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.isDark
                    ? AppColors.danger.withValues(alpha: 0.18)
                    : AppColors.dangerLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.danger,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      authProvider.errorMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (authProvider.infoMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.isDark
                    ? AppColors.success.withValues(alpha: 0.18)
                    : AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success),
              ),
              child: Text(
                authProvider.infoMessage!,
                style: TextStyle(fontSize: 13, color: context.textPrimaryColor),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Các trường nhập liệu
          if (!_isRegisterMode) ...[
            TextField(
              controller: _identifierController,
              enabled: !isBusy,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: const InputDecoration(
                labelText: 'Tên tài khoản hoặc Email',
                hintText: 'Nhập email (vd: learner@gmail.com) hoặc username',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            TextField(
              controller: _usernameController,
              enabled: !isBusy,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: const InputDecoration(
                labelText: 'Tên tài khoản / Tên hiển thị',
                hintText: 'Nhập tên tài khoản của bạn',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              enabled: !isBusy,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: const InputDecoration(
                labelText: 'Địa chỉ Email',
                hintText: 'Nhập địa chỉ email hợp lệ',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 14),
          ],

          TextField(
            controller: _passwordController,
            enabled: !isBusy,
            obscureText: _obscurePassword,
            style: TextStyle(color: context.textPrimaryColor),
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              hintText: _isRegisterMode
                  ? 'Tối thiểu 8 ký tự (không lưu văn bản thuần cục bộ)'
                  : 'Nhập mật khẩu của bạn',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: isBusy
                    ? null
                    : () =>
                        setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),

          if (_isRegisterMode) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _confirmPasswordController,
              enabled: !isBusy,
              obscureText: _obscureConfirmPassword,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu',
                hintText: 'Nhập lại mật khẩu',
                prefixIcon: const Icon(Icons.lock_reset_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: isBusy
                      ? null
                      : () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),

          // Bước 4: Khung xác thực Chống Bot (Server-Verified Anti-Bot)
          _buildAntiBotSection(context, authProvider),
          const SizedBox(height: 18),

          // Nút Đăng nhập / Tạo tài khoản
          CustomButton(
            text: _isRegisterMode ? 'Tạo tài khoản' : 'Đăng nhập',
            icon: _isRegisterMode
                ? Icons.person_add_alt_1_rounded
                : Icons.login_rounded,
            isLoading: isBusy,
            onPressed: isBusy ? null : () => _handleSubmit(authProvider),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: Divider(color: context.borderCol)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'HOẶC',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: context.textMutedColor,
                  ),
                ),
              ),
              Expanded(child: Divider(color: context.borderCol)),
            ],
          ),
          const SizedBox(height: 14),

          // Nút Đăng nhập bằng Google / Gmail
          if (kIsWeb && _googleInitialized)
            IgnorePointer(
              ignoring: isBusy,
              child: Opacity(
                opacity: isBusy ? 0.5 : 1.0,
                child: Center(child: renderGoogleWebButton()),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: isBusy
                  ? null
                  : () => _startGoogleSignIn(authProvider),
              icon: isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 28,
                      color: AppColors.primary,
                    ),
              label: Text(
                isBusy
                    ? 'Đang xử lý xác thực...'
                    : 'Tiếp tục với Google / Gmail',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAntiBotSection(BuildContext context, AuthProvider authProvider) {
    final isConfigured = authProvider.isAntiBotConfigured;
    final isVerified = authProvider.hasVerifiedAntiBot;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isVerified ? AppColors.success : context.borderCol,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isVerified ? Icons.verified_rounded : Icons.security_rounded,
                size: 19,
                color: isVerified ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  !isConfigured
                      ? 'Trạng thái Anti-Bot: Chưa bật thực sự (Thiếu cấu hình Server/Provider)'
                      : !_isRegisterMode
                      ? 'Anti-Bot được áp dụng khi tạo tài khoản'
                      : (isVerified
                            ? 'Anti-Bot: Đã xác minh token phía server'
                            : 'Bước chống Bot: Cần xác minh token phía server'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (!_isRegisterMode)
            Text(
              'Đăng nhập không yêu cầu CAPTCHA. Chống bot được áp dụng ở luồng tạo tài khoản.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: context.textSecondaryColor,
              ),
            )
          else if (!isConfigured)
            Text(
              'Ứng dụng không dùng câu hỏi hay checkbox giả lập. Turnstile chỉ được xác nhận sau khi endpoint CAPTCHA_VERIFY_URL kiểm tra token bằng secret phía server.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: context.textSecondaryColor,
              ),
            )
          else ...[
            Text(
              kIsWeb
                  ? 'Hoàn tất Cloudflare Turnstile. Token sẽ được gửi đến máy chủ để xác minh; token đã dùng sẽ hết hiệu lực.'
                  : 'Trình duyệt CAPTCHA tích hợp hiện có trên Web. Trên Android/Desktop, dùng trường token từ luồng xác minh native của nhà cung cấp; máy chủ vẫn bắt buộc xác minh token.',
              style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
            ),
            const SizedBox(height: 8),
            if (kIsWeb)
              TurnstileWidget(
                key: ValueKey('$_isRegisterMode-$_captchaWidgetGeneration'),
                siteKey: const String.fromEnvironment('CAPTCHA_SITE_KEY'),
                onToken: (token) {
                  authProvider.verifyAntiBotToken(
                    tokenFromProviderWidget: token,
                    action: 'register',
                  );
                },
                onError: authProvider.reportExternalError,
              )
            else
              Text(
                'Widget chống bot hiện được tích hợp trên Web. Trên Android/Desktop native, đăng ký sẽ bị khóa đến khi tích hợp WebView/provider CAPTCHA cho nền tảng đó.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: context.textSecondaryColor,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
