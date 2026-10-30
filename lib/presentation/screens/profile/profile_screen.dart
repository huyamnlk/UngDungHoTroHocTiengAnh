import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/avatar_picker.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/top_profile_menu_button.dart';
import '../../widgets/user_avatar_widget.dart';
import '../admin/admin_screen.dart';
import '../auth/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  /// Nếu truyền targetUid khác với activeUid của người dùng hiện tại,
  /// màn hình và tầng Repository sẽ chặn chỉnh sửa để bảo vệ quyền riêng tư.
  final String? targetUid;

  const ProfileScreen({super.key, this.targetUid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _learningGoalController = TextEditingController();
  final _customUrlController = TextEditingController();
  final _settingsService = SettingsService();

  bool _isLoadingProfile = true;
  bool _isSaving = false;
  String? _statusMessage;
  bool _isStatusSuccess = false;

  UserProfileModel? _loadedProfile;
  String _savedAvatarData = 'preset:scholar_blue';
  String _previewAvatarData = 'preset:scholar_blue';
  String? _pickedFileSummary;
  String _selectedAdminCefrLevel = 'A1';
  int _dailyGoal = 10;
  bool _showUrlInput = false;

  @override
  void initState() {
    super.initState();
    _dailyGoal = _settingsService.getDailyGoal();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _learningGoalController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfile = true;
      _statusMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      setState(() {
        _isLoadingProfile = false;
        _isStatusSuccess = false;
        _statusMessage =
            'Yêu cầu đăng nhập: Vui lòng đăng nhập tài khoản để xem và chỉnh sửa hồ sơ.';
      });
      return;
    }

    final activeUid = authProvider.activeUid;
    final requestedUid = (widget.targetUid ?? activeUid).trim();

    if (requestedUid != activeUid) {
      setState(() {
        _isLoadingProfile = false;
        _isStatusSuccess = false;
        _statusMessage =
            'Truy cập bị từ chối (403 Forbidden): Bạn không được phép xem hoặc chỉnh sửa hồ sơ của tài khoản khác.';
      });
      return;
    }

    final profile = await authProvider.loadActiveProfile();
    if (!mounted) return;

    if (profile == null) {
      setState(() {
        _isLoadingProfile = false;
        _isStatusSuccess = false;
        _statusMessage = 'Chưa có thông tin hồ sơ cho tài khoản này.';
      });
      return;
    }

    setState(() {
      _loadedProfile = profile;
      _displayNameController.text = profile.displayName;
      _bioController.text = profile.bio;
      _learningGoalController.text = profile.learningGoal;
      _savedAvatarData = profile.avatarData.isNotEmpty
          ? profile.avatarData
          : 'preset:scholar_blue';
      _previewAvatarData = _savedAvatarData;
      _selectedAdminCefrLevel = profile.cefrLevel;
      if (_savedAvatarData.startsWith('http://') ||
          _savedAvatarData.startsWith('https://')) {
        _customUrlController.text = _savedAvatarData;
      }
      _isLoadingProfile = false;
    });
  }

  Future<void> _handlePickImageFromDevice() async {
    setState(() => _statusMessage = null);
    final picked = await pickAvatarImageFromDevice();
    if (!mounted) return;

    if (picked.isCancelled) return;

    if (!picked.isSuccess) {
      setState(() {
        _isStatusSuccess = false;
        _statusMessage = picked.errorMessage ?? 'Không thể chọn ảnh.';
      });
      UiHelpers.showSnackBar(
        context,
        message: _statusMessage!,
        isError: true,
      );
      return;
    }

    final sizeKb = picked.byteSize != null
        ? '${(picked.byteSize! / 1024).toStringAsFixed(1)} KB'
        : '';
    setState(() {
      _previewAvatarData = picked.dataUri!;
      _pickedFileSummary =
          '${picked.fileName ?? "image"}${sizeKb.isNotEmpty ? " ($sizeKb)" : ""}';
      _showUrlInput = false;
      _isStatusSuccess = true;
      _statusMessage =
          'Đã tải ảnh xem trước thành công. Nhấn "Lưu thay đổi hồ sơ" để áp dụng.';
    });
  }

  void _handleApplyAvatarUrl() {
    final url = _customUrlController.text.trim();
    if (!url.startsWith('https://') && !url.startsWith('http://')) {
      setState(() {
        _isStatusSuccess = false;
        _statusMessage =
            'URL ảnh đại diện phải bắt đầu bằng https:// hoặc http://.';
      });
      return;
    }
    setState(() {
      _previewAvatarData = url;
      _pickedFileSummary = 'Ảnh từ URL bên ngoài';
      _isStatusSuccess = true;
      _statusMessage =
          'Đã cập nhật ảnh xem trước từ URL. Nhấn "Lưu thay đổi hồ sơ" để lưu.';
    });
  }

  Future<void> _handleSaveProfile() async {
    FocusScope.of(context).unfocus();
    setState(() => _statusMessage = null);

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isStatusSuccess = false;
        _statusMessage =
            'Vui lòng kiểm tra lại các trường thông tin chưa hợp lệ bên dưới.';
      });
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final requestedTargetUid =
        (widget.targetUid ?? authProvider.activeUid).trim();

    final validationErr = UserProfileModel.validateProfileInput(
      displayName: _displayNameController.text,
      bio: _bioController.text,
      learningGoal: _learningGoalController.text,
      avatarData: _previewAvatarData,
    );

    if (validationErr != null) {
      setState(() {
        _isStatusSuccess = false;
        _statusMessage = validationErr;
      });
      UiHelpers.showSnackBar(context, message: validationErr, isError: true);
      return;
    }

    setState(() => _isSaving = true);

    await _settingsService.setDailyGoal(_dailyGoal);
    final ok = await authProvider.updateOwnProfile(
      targetUid: requestedTargetUid,
      displayName: _displayNameController.text,
      bio: _bioController.text,
      learningGoal: _learningGoalController.text,
      avatarData: _previewAvatarData,
      attemptedCefrLevel: authProvider.isAdmin ? _selectedAdminCefrLevel : null,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      if (ok && authProvider.currentProfile != null) {
        _loadedProfile = authProvider.currentProfile;
        _savedAvatarData = _loadedProfile!.avatarData;
        _previewAvatarData = _savedAvatarData;
        _pickedFileSummary = null;
        _isStatusSuccess = true;
        _statusMessage =
            authProvider.infoMessage ?? 'Đã lưu thông tin hồ sơ thành công!';
      } else {
        _isStatusSuccess = false;
        _statusMessage =
            authProvider.errorMessage ?? 'Không thể lưu thông tin hồ sơ.';
      }
    });

    UiHelpers.showSnackBar(
      context,
      message: _statusMessage!,
      isSuccess: _isStatusSuccess,
      isError: !_isStatusSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final studyProvider = context.watch<StudyProvider>();
    final stats = studyProvider.overallStats;
    final masteredWords = stats['mastered'] ?? 0;
    final totalWords = stats['total'] ?? 0;
    final streakDays = _settingsService.getStreakDays();

    final activeUid = authProvider.activeUid;
    final requestedUid = (widget.targetUid ?? activeUid).trim();
    final isUnauthorizedOtherUser = requestedUid != activeUid;

    final profile = _loadedProfile ?? authProvider.currentProfile;
    final hasUnsavedAvatarChange = _previewAvatarData != _savedAvatarData;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân & Chỉnh sửa Profile'),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        actions: [
          if (authProvider.isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminScreen()),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                label: const Text('Quản trị'),
              ),
            ),
          if (authProvider.isAuthenticated)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: OutlinedButton.icon(
                key: const Key('profile_appbar_signout_button'),
                onPressed: () => TopProfileMenuButton.confirmAndSignOut(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 17),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.borderCol),
        ),
      ),
      body: !authProvider.isAuthenticated
          ? _buildUnauthenticatedAccessView(context)
          : _isLoadingProfile
              ? const Center(child: CircularProgressIndicator())
              : isUnauthorizedOtherUser
                  ? _buildUnauthorizedProfileAccessView(context)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Thông báo kết quả lưu hoặc lỗi
                            if (_statusMessage != null) ...[
                              _buildStatusBanner(context),
                              const SizedBox(height: 18),
                            ],

                            // 1. Thẻ Tổng quan & Xem trước Ảnh đại diện (Avatar Picker & Preview)
                            _buildAvatarAndSummaryCard(
                              context,
                              authProvider: authProvider,
                              profile: profile,
                              hasUnsavedAvatarChange: hasUnsavedAvatarChange,
                              streakDays: streakDays,
                              masteredWords: masteredWords,
                              totalWords: totalWords,
                            ),
                            const SizedBox(height: 22),

                            // 2. Thẻ Cấp độ Năng lực CEFR Hiện tại (Read-only cho User, Editable cho Admin)
                            _buildCefrLevelCard(
                              context,
                              authProvider: authProvider,
                              profile: profile,
                            ),
                            const SizedBox(height: 22),

                            // 3. Biểu mẫu Chỉnh sửa Thông tin Profile
                            _buildProfileFormCard(
                              context,
                              authProvider: authProvider,
                              profile: profile,
                            ),
                            const SizedBox(height: 22),

                            // 4. Nút Lưu thay đổi
                            CustomButton(
                              text: 'Lưu thay đổi hồ sơ',
                              icon: Icons.save_rounded,
                              isLoading: _isSaving,
                              onPressed: _isSaving ? null : _handleSaveProfile,
                            ),
                            const SizedBox(height: 16),

                            // 5. Nút Đăng xuất tài khoản dễ tìm ngay trong trang Chỉnh sửa hồ sơ (chỉ khi đã đăng nhập)
                            if (authProvider.isAuthenticated) ...[
                              OutlinedButton.icon(
                                key: const Key('profile_bottom_signout_button'),
                                onPressed: () =>
                                    TopProfileMenuButton.confirmAndSignOut(
                                      context,
                                    ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                  side: const BorderSide(color: AppColors.danger),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.logout_rounded, size: 19),
                                label: const Text(
                                  'Đăng xuất tài khoản',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildUnauthenticatedAccessView(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.borderCol),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_person_rounded,
                size: 56,
                color: AppColors.primary,
              ),
              const SizedBox(height: 14),
              Text(
                'Yêu cầu đăng nhập (401)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chức năng Chỉnh sửa hồ sơ chỉ dành cho người dùng đã đăng nhập. Vui lòng đăng nhập hoặc tạo tài khoản mới.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: context.textSecondaryColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Đăng nhập tài khoản',
                icon: Icons.login_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthorizedProfileAccessView(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.danger),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.gpp_bad_rounded,
                size: 56,
                color: AppColors.danger,
              ),
              const SizedBox(height: 14),
              Text(
                'Không có quyền chỉnh sửa hồ sơ này (403)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Người dùng chỉ được phép xem và cập nhật hồ sơ của chính mình. Mọi yêu cầu chỉnh sửa hồ sơ của tài khoản khác đều bị chặn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: context.textSecondaryColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Quay lại',
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context) {
    final color = _isStatusSuccess ? AppColors.success : AppColors.danger;
    final bgColor = _isStatusSuccess
        ? context.successLightCol
        : context.dangerLightCol;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(
            _isStatusSuccess
                ? Icons.check_circle_rounded
                : Icons.error_outline_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusMessage!,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarAndSummaryCard(
    BuildContext context, {
    required AuthProvider authProvider,
    required UserProfileModel? profile,
    required bool hasUnsavedAvatarChange,
    required int streakDays,
    required int masteredWords,
    required int totalWords,
  }) {
    final isAdmin = authProvider.isAdmin;
    final displayName = _displayNameController.text.trim().isNotEmpty
        ? _displayNameController.text.trim()
        : (profile?.displayName ?? 'Buddy Learner');

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Khung Xem trước Ảnh đại diện
              Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: hasUnsavedAvatarChange
                                ? AppColors.warning
                                : AppColors.primary,
                            width: 2.5,
                          ),
                        ),
                        child: UserAvatarWidget(
                          avatarData: _previewAvatarData,
                          displayName: displayName,
                          size: 86,
                          showAdminBadge: isAdmin,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: hasUnsavedAvatarChange
                          ? context.warningLightCol
                          : context.primaryContainerCol,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hasUnsavedAvatarChange
                          ? 'Đang xem trước ảnh mới'
                          : 'Ảnh hiện tại',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: hasUnsavedAvatarChange
                            ? AppColors.warning
                            : context.primaryAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),

              // Thông tin định danh & Thống kê học tập
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? context.warningLightCol
                                : context.primaryContainerCol,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAdmin
                                  ? AppColors.warning
                                  : context.activeNavBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAdmin
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.person_rounded,
                                size: 14,
                                color: isAdmin
                                    ? AppColors.warning
                                    : context.primaryAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isAdmin
                                    ? 'Quản trị viên (Admin)'
                                    : 'Học viên (User)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isAdmin
                                      ? AppColors.warning
                                      : context.primaryAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      authProvider.isAuthenticated
                          ? '${authProvider.currentUser!.email} • UID: ${authProvider.currentUser!.uid}'
                          : 'Chế độ học cục bộ trên thiết bị • Tiến độ lưu an toàn trong SQLite',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _buildMiniStatPill(
                          context,
                          icon: Icons.workspace_premium_rounded,
                          label: 'Cấp độ: CEFR ${profile?.cefrLevel ?? "A1"}',
                          color: AppColors.primary,
                        ),
                        _buildMiniStatPill(
                          context,
                          icon: Icons.local_fire_department_rounded,
                          label: 'Streak: $streakDays ngày',
                          color: AppColors.warning,
                        ),
                        _buildMiniStatPill(
                          context,
                          icon: Icons.check_circle_rounded,
                          label: 'Đã thuộc: $masteredWords/$totalWords từ',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(height: 1, color: context.borderCol),
          const SizedBox(height: 14),

          // Công cụ chọn ảnh đại diện & xem trước
          Text(
            'Thay đổi & Xem trước Ảnh đại diện',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chọn tệp ảnh từ thiết bị (PNG, JPG, WEBP, GIF tối đa 2MB), nhập URL ảnh hoặc chọn từ bộ Avatar học tập bên dưới.',
            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: _handlePickImageFromDevice,
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('Chọn ảnh từ thiết bị'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _showUrlInput = !_showUrlInput);
                },
                icon: const Icon(Icons.link_rounded, size: 18),
                label: const Text('Nhập URL ảnh'),
              ),
              if (hasUnsavedAvatarChange)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _previewAvatarData = _savedAvatarData;
                      _pickedFileSummary = null;
                    });
                  },
                  icon: const Icon(Icons.undo_rounded, size: 18),
                  label: const Text('Hoàn tác ảnh đang chọn'),
                ),
            ],
          ),

          if (_pickedFileSummary != null) ...[
            const SizedBox(height: 8),
            Text(
              'Đã chọn: $_pickedFileSummary',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.primaryAccent,
              ),
            ),
          ],

          if (_showUrlInput) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customUrlController,
                    style: TextStyle(color: context.textPrimaryColor),
                    decoration: const InputDecoration(
                      labelText: 'Đường dẫn URL ảnh đại diện',
                      hintText: 'https://example.com/avatar.png',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _handleApplyAvatarUrl,
                  child: const Text('Xem trước'),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: UserAvatarWidget.presets.map((preset) {
              final isSelected = _previewAvatarData == preset.key;
              return InkWell(
                onTap: () {
                  setState(() {
                    _previewAvatarData = preset.key;
                    _pickedFileSummary = 'Avatar mẫu: ${preset.label}';
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.primaryContainerCol
                        : context.scaffoldBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : context.borderCol,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserAvatarWidget(
                        avatarData: preset.key,
                        displayName: preset.label,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        preset.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCefrLevelCard(
    BuildContext context, {
    required AuthProvider authProvider,
    required UserProfileModel? profile,
  }) {
    final currentLevel = authProvider.isAdmin
        ? _selectedAdminCefrLevel
        : (profile?.cefrLevel ?? 'A1');
    final updatedBy = profile?.levelUpdatedBy == 'admin'
        ? 'Quản trị viên (Admin) xét duyệt'
        : 'Hệ thống đánh giá tự động';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.primaryContainerCol,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.military_tech_rounded,
                  color: context.primaryAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Cấp độ Năng lực Hiện tại: CEFR $currentLevel',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!authProvider.isAdmin)
                          Tooltip(
                            message:
                                'Chỉ đọc: Cấp độ do hệ thống hoặc Admin quản lý',
                            child: Icon(
                              Icons.lock_outline_rounded,
                              size: 16,
                              color: context.textSecondaryColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nguồn: $updatedBy',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.scaffoldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UserProfileModel.describeCefrLevel(currentLevel),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  authProvider.isAdmin
                      ? 'Bạn đang đăng nhập với quyền Quản trị viên (Admin), bạn có thể cập nhật cấp độ CEFR bên dưới hoặc trong Khu vực Quản trị.'
                      : 'Lưu ý phân quyền: Cấp độ năng lực CEFR được hệ thống đánh giá dựa trên tiến độ từ vựng/bài thi hoặc do Quản trị viên xét duyệt. Học viên không thể tự ý chỉnh sửa trường này.',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (authProvider.isAdmin) ...[
            const SizedBox(height: 14),
            Text(
              'Cập nhật Cấp độ CEFR (Quyền Admin):',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.cefrLevels.map((lvl) {
                final selected = _selectedAdminCefrLevel == lvl;
                return ChoiceChip(
                  label: Text('CEFR $lvl'),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedAdminCefrLevel = lvl);
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileFormCard(
    BuildContext context, {
    required AuthProvider authProvider,
    required UserProfileModel? profile,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Thông tin cá nhân & Mục tiêu học tập',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Tên hiển thị
          TextFormField(
            controller: _displayNameController,
            maxLength: 60,
            style: TextStyle(color: context.textPrimaryColor),
            decoration: const InputDecoration(
              labelText: 'Tên hiển thị *',
              hintText: 'Nhập tên hiển thị của bạn (2 - 60 ký tự)',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (val) {
              final clean = val?.trim() ?? '';
              if (clean.isEmpty) {
                return 'Vui lòng nhập tên hiển thị.';
              }
              if (clean.length < 2) {
                return 'Tên hiển thị phải có tối thiểu 2 ký tự.';
              }
              if (clean.length > 60) {
                return 'Tên hiển thị tối đa 60 ký tự.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Bio / Giới thiệu bản thân
          TextFormField(
            controller: _bioController,
            maxLength: 300,
            maxLines: 3,
            style: TextStyle(color: context.textPrimaryColor),
            decoration: const InputDecoration(
              labelText: 'Giới thiệu bản thân (Bio)',
              hintText:
                  'Chia sẻ đôi nét về bản thân, sở thích hoặc định hướng học tiếng Anh của bạn...',
              prefixIcon: Icon(Icons.notes_rounded),
              alignLabelWithHint: true,
            ),
            validator: (val) {
              if ((val?.trim().length ?? 0) > 300) {
                return 'Giới thiệu (Bio) không được vượt quá 300 ký tự.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Mục tiêu học tập
          TextFormField(
            controller: _learningGoalController,
            maxLength: 150,
            style: TextStyle(color: context.textPrimaryColor),
            decoration: const InputDecoration(
              labelText: 'Mục tiêu học tiếng Anh',
              hintText: 'Ví dụ: Đạt IELTS 7.0 & Giao tiếp tự tin trong công việc',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            validator: (val) {
              if ((val?.trim().length ?? 0) > 150) {
                return 'Mục tiêu học tập không được vượt quá 150 ký tự.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Mục tiêu số từ mỗi ngày
          Text(
            'Mục tiêu từ vựng mỗi ngày:',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [5, 10, 20, 30].map((goal) {
              final selected = _dailyGoal == goal;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => setState(() => _dailyGoal = goal),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? context.primaryContainerCol
                            : context.scaffoldBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppColors.primary : context.borderCol,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$goal từ/ngày',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: selected
                              ? AppColors.primary
                              : context.textPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (!authProvider.isAuthenticated) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.scaffoldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderCol),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bạn đang chỉnh sửa hồ sơ học tập cục bộ trên thiết bị. Bạn cũng có thể đăng nhập tài khoản để gắn liền hồ sơ với định danh cá nhân.',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    },
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStatPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
