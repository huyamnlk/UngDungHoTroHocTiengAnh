import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/top_profile_menu_button.dart';
import '../../widgets/user_avatar_widget.dart';
import '../admin/admin_screen.dart';
import '../auth/auth_screen.dart';
import '../profile/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService();
  late int _dailyGoal;
  late bool _soundEnabled;

  @override
  void initState() {
    super.initState();
    _dailyGoal = _settingsService.getDailyGoal();
    _soundEnabled = _settingsService.isSoundEnabled();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Cài đặt & Tùy chọn'),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.borderCol),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mục Tài khoản, Hồ sơ cá nhân & Phân quyền
                _buildSectionHeader('Hồ sơ cá nhân & Tài khoản'),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final user = authProvider.currentUser;
                    final profile = authProvider.currentProfile;
                    final isAdmin = authProvider.isAdmin;
                    final isAuthenticated = authProvider.isAuthenticated && user != null;
                    final displayName = isAuthenticated
                        ? user.displayName
                        : 'Khách (Chưa đăng nhập)';
                    final avatarData =
                        profile?.avatarData ?? 'preset:scholar_blue';
                    final cefrLevel = profile?.cefrLevel ?? 'A1';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
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
                                  UserAvatarWidget(
                                    avatarData: avatarData,
                                    displayName: displayName,
                                    size: 52,
                                    showAdminBadge: isAdmin,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              displayName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.5,
                                                color: context.textPrimaryColor,
                                              ),
                                            ),
                                            if (isAuthenticated)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: context
                                                      .primaryContainerCol,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                            if (isAdmin)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      context.warningLightCol,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'ADMIN',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.warning,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isAuthenticated
                                              ? '${user.email} • Đã xác thực (${user.providerId})'
                                              : 'Chưa đăng nhập tài khoản. Đăng nhập hoặc tạo tài khoản mới để quản lý hồ sơ và đồng bộ tiến độ.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.textSecondaryColor,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  if (isAuthenticated) ...[
                                    FilledButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const ProfileScreen(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit_note_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Chỉnh sửa hồ sơ'),
                                    ),
                                    if (isAdmin)
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const AdminScreen(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.admin_panel_settings_rounded,
                                          size: 18,
                                          color: AppColors.warning,
                                        ),
                                        label: const Text('Khu vực Quản trị'),
                                      ),
                                    OutlinedButton.icon(
                                      onPressed: () => TopProfileMenuButton
                                          .confirmAndSignOut(context),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.danger,
                                        side: const BorderSide(
                                          color: AppColors.danger,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.logout_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Đăng xuất'),
                                    ),
                                  ] else ...[
                                    FilledButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const AuthScreen(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.login_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Đăng nhập'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const AuthScreen(
                                              initialRegisterMode: true,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Tạo tài khoản'),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Mục Giao diện
                _buildSectionHeader('Giao diện & Chủ đề'),
          Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.borderCol),
            ),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(
                    'Theo hệ thống',
                    style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                  ),
                  subtitle: Text(
                    'Tự động theo cài đặt của thiết bị',
                    style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                  ),
                  value: ThemeMode.system,
                  activeColor: AppColors.primary,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) {
                    if (val != null) themeProvider.setThemeMode(val);
                  },
                ),
                Divider(height: 1, color: context.borderCol),
                RadioListTile<ThemeMode>(
                  title: Text(
                    'Giao diện sáng (Light Mode)',
                    style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                  ),
                  value: ThemeMode.light,
                  activeColor: AppColors.primary,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) {
                    if (val != null) themeProvider.setThemeMode(val);
                  },
                ),
                Divider(height: 1, color: context.borderCol),
                RadioListTile<ThemeMode>(
                  title: Text(
                    'Giao diện tối (Dark Mode)',
                    style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                  ),
                  value: ThemeMode.dark,
                  activeColor: AppColors.primary,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) {
                    if (val != null) themeProvider.setThemeMode(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Mục Mục tiêu học tập
          _buildSectionHeader('Mục tiêu học tập hằng ngày'),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn số lượng từ bạn muốn hoàn thành mỗi ngày:',
                  style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [5, 10, 20].map((goal) {
                    final isSelected = _dailyGoal == goal;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () async {
                            setState(() => _dailyGoal = goal);
                            await _settingsService.setDailyGoal(goal);
                            if (mounted) {
                              UiHelpers.showSnackBar(context, message: 'Đã đặt mục tiêu $goal từ/ngày!');
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? context.primaryContainerCol : context.scaffoldBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : context.borderCol,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$goal từ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primary : context.textPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Âm thanh
          _buildSectionHeader('Âm thanh & Phát âm'),
          Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.borderCol),
            ),
            child: SwitchListTile(
              title: Text(
                'Bật âm thanh phát âm',
                style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimaryColor),
              ),
              subtitle: Text(
                'Phát âm giọng đọc chuẩn bản xứ Text-to-Speech',
                style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
              ),
              value: _soundEnabled,
              activeColor: AppColors.primary,
              onChanged: (val) async {
                setState(() => _soundEnabled = val);
                await _settingsService.setSoundEnabled(val);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Nguồn dữ liệu & Bản quyền
          _buildSectionHeader('Nguồn dữ liệu & Bản quyền'),
          Container(
            padding: const EdgeInsets.all(18),
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
                    const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Chính sách bản quyền minh bạch',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '• Nội dung từ vựng, câu ví dụ và bài tập được nhóm tác giả tự biên soạn nguyên bản, dựa trên tiêu chuẩn phân cấp CEFR (A1–C1) và các khung năng lực ngôn ngữ mở.\n'
                  '• Không sao chép hàng loạt định nghĩa hay dữ liệu có bản quyền từ Cambridge Dictionary, DOL English hay các nguồn thương mại.\n'
                  '• Chức năng tra cứu trực tuyến tích hợp từ Free Dictionary API (dữ liệu nguồn mở không yêu cầu API key, tuân thủ giấy phép CC BY-SA 3.0).',
                  style: TextStyle(fontSize: 12, color: context.textSecondaryColor, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Thông tin ứng dụng
          Center(
            child: Column(
              children: [
                Text(
                  '${AppConstants.appName} v1.0.0+1',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Đồ án môn Lập trình Thiết bị Di động - Flutter & SQLite',
                  style: TextStyle(fontSize: 12, color: context.textMutedColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textSecondaryColor),
      ),
    );
  }
}
