import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../providers/auth_provider.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/profile/profile_screen.dart';
import 'user_avatar_widget.dart';

enum _TopProfileMenuAction {
  editProfile,
  retryProfile,
  adminPanel,
  signOut,
}

/// Nút trạng thái Tài khoản / Đăng nhập ở góc trên bên phải thanh đầu trang:
/// - Khi đang kiểm tra phiên (loading): hiển thị chỉ báo tải, không lộ menu.
/// - Khi chưa đăng nhập: hiển thị nút "Đăng nhập" (và "Đăng ký"), KHÔNG hiển thị menu tài khoản,
///   "Chỉnh sửa hồ sơ" hoặc "Đăng xuất".
/// - Khi đã đăng nhập: hiển thị ảnh đại diện, tên người dùng, mở menu gồm "Chỉnh sửa hồ sơ",
///   "Khu vực Quản trị" (nếu là Admin) và "Đăng xuất".
class TopProfileMenuButton extends StatelessWidget {
  final bool compact;

  const TopProfileMenuButton({
    super.key,
    this.compact = false,
  });

  /// Mở trang Chỉnh sửa hồ sơ (`ProfileScreen`)
  static void openEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  /// Hiển thị hộp thoại xác nhận trước khi đăng xuất, xóa phiên/token thật và đưa về màn hình Đăng nhập
  static Future<void> confirmAndSignOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return;

    final userEmail = authProvider.currentUser?.email;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: dialogContext.borderCol),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dialogContext.dangerLightCol,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.danger,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dialogContext.l10n.confirmSignOutTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: dialogContext.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            dialogContext.l10n.confirmSignOutMessage(userEmail ?? ''),
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: dialogContext.textSecondaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                dialogContext.l10n.actionCancel,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: dialogContext.textSecondaryColor,
                ),
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.logout_rounded, size: 17),
              label: Text(
                dialogContext.l10n.signOut,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await authProvider.signOutSession();

    if (!context.mounted) return;
    final navigator = Navigator.maybeOf(context, rootNavigator: true) ??
        Navigator.maybeOf(context);
    navigator?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider? authProvider;
    try {
      authProvider = Provider.of<AuthProvider>(context);
    } catch (_) {
      authProvider = null;
    }

    // 1. Trạng thái Đang kiểm tra / Xác minh phiên: Hiển thị chỉ báo tải mượt mà
    if (authProvider != null && authProvider.isInitializingAuth) {
      return Container(
        key: const Key('top_profile_initializing_indicator'),
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderCol),
        ),
        alignment: Alignment.center,
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.primaryAccent,
          ),
        ),
      );
    }

    final isAuthenticated = authProvider?.isAuthenticated ?? false;
    final user = authProvider?.currentUser;

    // 2. Trạng thái CHƯA ĐĂNG NHẬP (Khách): Không hiển thị menu tài khoản, "Chỉnh sửa hồ sơ" hay "Đăng xuất"
    if (!isAuthenticated || user == null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 38),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.tonalIcon(
              key: const Key('top_login_button'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 38),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.login_rounded, size: 16),
              label: Text(
                context.l10n.signIn,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                key: const Key('top_register_button'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const AuthScreen(initialRegisterMode: true),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: context.borderCol),
                ),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: Text(
                  context.l10n.signUp,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // 3. Trạng thái ĐÃ ĐĂNG NHẬP: Hiển thị ảnh đại diện, tên và menu đầy đủ
    final profile = authProvider?.currentProfile;
    final isAdmin = authProvider?.isAdmin ?? false;
    final hasProfileLoadError = authProvider?.hasProfileLoadError ?? false;
    final displayName = (profile?.displayName.trim().isNotEmpty == true)
        ? profile!.displayName.trim()
        : (user.displayName.trim().isNotEmpty
            ? user.displayName.trim()
            : (user.email.contains('@')
                ? user.email.split('@').first
                : 'Learner'));
    final email = user.email;
    final avatarData = (profile?.avatarData.trim().isNotEmpty == true)
        ? profile!.avatarData.trim()
        : (isAdmin ? 'preset:admin_shield' : 'preset:scholar_blue');
    final cefrLevel = (profile?.cefrLevel.trim().isNotEmpty == true)
        ? profile!.cefrLevel.trim()
        : 'A1';

    return PopupMenuButton<_TopProfileMenuAction>(
      key: const Key('top_profile_avatar_menu_button'),
      tooltip: context.l10n.accountMenuHeader(displayName),
      offset: const Offset(0, 48),
      color: context.cardBg,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.borderCol),
      ),
      onSelected: (action) {
        switch (action) {
          case _TopProfileMenuAction.editProfile:
            openEditProfile(context);
            break;
          case _TopProfileMenuAction.retryProfile:
            authProvider?.retryLoadProfile();
            break;
          case _TopProfileMenuAction.adminPanel:
            if (isAdmin) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminScreen()),
              );
            }
            break;
          case _TopProfileMenuAction.signOut:
            confirmAndSignOut(context);
            break;
        }
      },
      itemBuilder: (menuContext) => [
        // Header thông tin tài khoản đã xác thực
        PopupMenuItem<_TopProfileMenuAction>(
          value: _TopProfileMenuAction.editProfile,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              UserAvatarWidget(
                avatarData: avatarData,
                displayName: displayName,
                size: 40,
                showAdminBadge: isAdmin,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: menuContext.textPrimaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: menuContext.primaryContainerCol,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cefrLevel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: menuContext.primaryAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: menuContext.textSecondaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 8),

        if (hasProfileLoadError)
          PopupMenuItem<_TopProfileMenuAction>(
            key: const Key('top_profile_retry_menu_item'),
            value: _TopProfileMenuAction.retryProfile,
            child: Row(
              children: [
                const Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    menuContext.l10n.actionRetry,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: menuContext.textPrimaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        // Mục Chỉnh sửa hồ sơ
        PopupMenuItem<_TopProfileMenuAction>(
          value: _TopProfileMenuAction.editProfile,
          child: Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 20,
                color: menuContext.primaryAccent,
              ),
              const SizedBox(width: 10),
              Text(
                menuContext.l10n.editProfile,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: menuContext.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),

        // Mục Khu vực Quản trị (Chỉ hiển thị khi tài khoản là Admin)
        if (isAdmin)
          PopupMenuItem<_TopProfileMenuAction>(
            value: _TopProfileMenuAction.adminPanel,
            child: Row(
              children: [
                const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 20,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 10),
                Text(
                  menuContext.l10n.adminArea,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: menuContext.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),

        const PopupMenuDivider(height: 8),

        // Mục Đăng xuất (Chỉ khi đã đăng nhập)
        PopupMenuItem<_TopProfileMenuAction>(
          value: _TopProfileMenuAction.signOut,
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 20,
                color: AppColors.danger,
              ),
              const SizedBox(width: 10),
              Text(
                menuContext.l10n.signOut,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: 38),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatarWidget(
              avatarData: avatarData,
              displayName: displayName,
              size: 28,
              showAdminBadge: isAdmin,
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: context.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
