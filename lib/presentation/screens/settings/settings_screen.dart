import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_languages.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/locale_provider.dart';
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
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
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
                // Mục Chọn Ngôn ngữ (Language Selection)
                _buildSectionHeader(l10n.settingsLanguageSection),
                Container(
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                    children: [
                      ...[
                        AppLanguages.findByCode('vi'),
                        AppLanguages.findByCode('en'),
                        AppLanguages.findByCode('zh'),
                        AppLanguages.findByCode('ja'),
                        AppLanguages.findByCode('ko'),
                        if (!['vi', 'en', 'zh', 'ja', 'ko'].contains(localeProvider.languageCode))
                          AppLanguages.findByCode(localeProvider.languageCode),
                      ].map((lang) {
                        return Column(
                          children: [
                            RadioListTile<String>(
                              title: Row(
                                children: [
                                  Text('${lang.flag}  ', style: const TextStyle(fontSize: 18)),
                                  Text(
                                    lang.nativeName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                lang.getSubtitle(localeProvider.languageCode),
                                style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                              ),
                              value: lang.code,
                              activeColor: AppColors.primary,
                              groupValue: localeProvider.languageCode,
                              onChanged: (val) {
                                if (val != null) {
                                  localeProvider.setLocale(Locale(val));
                                }
                              },
                            ),
                            Divider(height: 1, color: context.borderCol),
                          ],
                        );
                      }),
                      InkWell(
                        onTap: () => _showLanguagePicker(context, localeProvider),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.primaryContainerCol,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.language_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.settingsAllLanguages,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: context.textPrimaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.settingsAllLanguagesSubtitle,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: context.textSecondaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mục Tài khoản, Hồ sơ cá nhân & Phân quyền
                _buildSectionHeader(l10n.settingsAccountSection),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final user = authProvider.currentUser;
                    final profile = authProvider.currentProfile;
                    final isAdmin = authProvider.isAdmin;
                    final isAuthenticated = authProvider.isAuthenticated && user != null;
                    final displayName = isAuthenticated
                        ? user.displayName
                        : l10n.guestUser;
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
                                              ? l10n.authenticatedAs(user.email, user.providerId)
                                              : l10n.guestUserDesc,
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
                                      label: Text(l10n.editProfile),
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
                                        label: Text(l10n.adminArea),
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
                                      label: Text(l10n.signOut),
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
                                      label: Text(l10n.signIn),
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
                                      label: Text(l10n.signUp),
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
                _buildSectionHeader(l10n.settingsThemeSection),
                Container(
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        title: Text(
                          l10n.settingsThemeSystem,
                          style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                        ),
                        subtitle: Text(
                          l10n.settingsThemeSystemDesc,
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
                          l10n.settingsThemeLight,
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
                          l10n.settingsThemeDark,
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
                ),
                const SizedBox(height: 24),

                // Mục Mục tiêu học tập
                _buildSectionHeader(l10n.settingsDailyGoalSection),
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
                        l10n.settingsDailyGoalSubtitle,
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
                                    UiHelpers.showSnackBar(
                                      context,
                                      message: l10n.settingsDailyGoalSaved(goal),
                                      isSuccess: true,
                                    );
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
                                    l10n.settingsDailyGoalUnit(goal),
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
                _buildSectionHeader(l10n.settingsSoundSection),
                Container(
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                    title: Text(
                      l10n.settingsSoundEnable,
                      style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                    ),
                    subtitle: Text(
                      l10n.settingsSoundEnableDesc,
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
                ),
                const SizedBox(height: 24),

                // Nguồn dữ liệu & Bản quyền
                _buildSectionHeader(l10n.settingsCopyrightSection),
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
                            l10n.settingsCopyrightTitle,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${l10n.settingsCopyrightDesc1}\n${l10n.settingsCopyrightDesc2}\n${l10n.settingsCopyrightDesc3}',
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
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FEFE),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.22),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 42,
                            height: 42,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppConstants.appName} v1.0.0+1',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.settingsAppSubtitle,
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

  void _showLanguagePicker(BuildContext context, LocaleProvider localeProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String query = '';
        return Consumer<LocaleProvider>(
          builder: (context, liveLocaleProvider, _) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                final currentCode = liveLocaleProvider.languageCode;
                final l10n = context.l10n;
                final filtered = AppLanguages.supportedLanguages.where((lang) {
                  if (query.trim().isEmpty) return true;
                  final q = query.toLowerCase();
                  return lang.nativeName.toLowerCase().contains(q) ||
                      lang.viName.toLowerCase().contains(q) ||
                      lang.englishName.toLowerCase().contains(q) ||
                      lang.getSubtitle(currentCode).toLowerCase().contains(q) ||
                      lang.code.toLowerCase().contains(q);
                }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: context.borderCol),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.borderCol,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.language_rounded, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.settingsSelectLanguage,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.settingsSearchLanguage,
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        filled: true,
                        fillColor: context.scaffoldBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.borderCol),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.borderCol),
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() => query = val);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => Divider(height: 1, indent: 64, color: context.borderCol),
                      itemBuilder: (context, index) {
                        final lang = filtered[index];
                        final isSelected = lang.code == currentCode;
                        return ListTile(
                          leading: Text(lang.flag, style: const TextStyle(fontSize: 26)),
                          title: Text(
                            lang.nativeName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? AppColors.primary : context.textPrimaryColor,
                            ),
                          ),
                          subtitle: Text(
                            lang.getSubtitle(currentCode),
                            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                              : null,
                          onTap: () async {
                            Navigator.pop(ctx);
                            await liveLocaleProvider.setLocale(Locale(lang.code));
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              ),
            );
              },
            );
          },
        );
      },
    );
  }
}
