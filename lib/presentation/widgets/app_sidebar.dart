import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/study_provider.dart';
import '../screens/chat/ai_chat_screen.dart';

class SidebarNavItem {
  final int index;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int? badgeCount;

  const SidebarNavItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badgeCount,
  });
}

class AppSidebar extends StatelessWidget {
  final int currentIndex;
  final bool isCollapsed;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onToggleCollapse;

  const AppSidebar({
    super.key,
    required this.currentIndex,
    required this.isCollapsed,
    required this.onDestinationSelected,
    required this.onToggleCollapse,
  });

  static List<SidebarNavItem> buildNavigationItems({
    int reviewCount = 0,
    bool isAdmin = false,
    BuildContext? context,
  }) {
    final l10n = context?.l10n;
    final items = <SidebarNavItem>[
      SidebarNavItem(
        index: 0,
        label: l10n?.navHome ?? 'Trang chủ',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
      ),
      SidebarNavItem(
        index: 1,
        label: l10n?.navTopics ?? 'Chủ đề',
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view_rounded,
      ),
      SidebarNavItem(
        index: 2,
        label: l10n?.navListening ?? 'Luyện nghe',
        icon: Icons.headphones_outlined,
        selectedIcon: Icons.headphones_rounded,
      ),
      SidebarNavItem(
        index: 3,
        label: l10n?.navReading ?? 'Luyện đọc',
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book_rounded,
      ),
      SidebarNavItem(
        index: 4,
        label: l10n?.navWriting ?? 'Luyện viết',
        icon: Icons.edit_note_outlined,
        selectedIcon: Icons.edit_note_rounded,
      ),
      SidebarNavItem(
        index: 5,
        label: l10n?.navSpeaking ?? 'Luyện nói',
        icon: Icons.record_voice_over_outlined,
        selectedIcon: Icons.record_voice_over_rounded,
      ),
      SidebarNavItem(
        index: 6,
        label: l10n?.navShadowing ?? 'Shadowing',
        icon: Icons.graphic_eq_outlined,
        selectedIcon: Icons.graphic_eq_rounded,
      ),
      SidebarNavItem(
        index: 7,
        label: l10n?.navDictionary ?? 'Từ vựng / Từ điển',
        icon: Icons.auto_stories_outlined,
        selectedIcon: Icons.auto_stories_rounded,
      ),
      SidebarNavItem(
        index: 8,
        label: l10n?.navExam ?? 'Luyện thi',
        icon: Icons.workspace_premium_outlined,
        selectedIcon: Icons.workspace_premium_rounded,
      ),
      SidebarNavItem(
        index: 9,
        label: l10n?.navGames ?? 'Trò chơi',
        icon: Icons.extension_outlined,
        selectedIcon: Icons.extension_rounded,
      ),
      SidebarNavItem(
        index: 10,
        label: l10n?.navReview ?? 'Ôn tập',
        icon: Icons.replay_rounded,
        selectedIcon: Icons.replay_circle_filled_rounded,
        badgeCount: reviewCount > 0 ? reviewCount : null,
      ),
      SidebarNavItem(
        index: 11,
        label: l10n?.navStats ?? 'Thống kê',
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart_rounded,
      ),
      SidebarNavItem(
        index: 12,
        label: l10n?.navSettings ?? 'Cài đặt',
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
      ),
    ];

    if (isAdmin) {
      items.add(
        SidebarNavItem(
          index: 13,
          label: l10n?.navAdmin ?? 'Quản trị viên',
          icon: Icons.admin_panel_settings_outlined,
          selectedIcon: Icons.admin_panel_settings_rounded,
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    AuthProvider? authProvider;
    try {
      authProvider = Provider.of<AuthProvider>(context);
    } catch (_) {
      authProvider = null;
    }

    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220);

    final reviewCount = studyProvider.reviewWords.length;

    final allItems = buildNavigationItems(
      reviewCount: reviewCount,
      isAdmin: authProvider?.isAdmin ?? false,
      context: context,
    );
    final learningItems = allItems.sublist(0, 11); // 0..10
    final systemItems = allItems.sublist(11); // 11..12 (và 13 nếu là Admin)

    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutCubic,
      width: isCollapsed ? 80 : 264,
      decoration: BoxDecoration(
        color: context.sidebarBg,
        border: Border(
          right: BorderSide(color: context.borderCol, width: 1),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header: Logo & Tên ứng dụng + Nút Thu gọn
            _buildBrandHeader(context),

            Divider(height: 1, color: context.borderCol),

            // 2. Danh sách điều hướng (SingleChildScrollView + Column)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 10 : 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isCollapsed)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 6),
                        child: Text(
                          context.l10n.navSectionSkills,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: context.textMutedColor,
                          ),
                        ),
                      ),
                    ...learningItems.map(
                      (item) => _SidebarItemTile(
                        item: item,
                        isSelected: currentIndex == item.index,
                        isCollapsed: isCollapsed,
                        onTap: () => onDestinationSelected(item.index),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Divider(height: 1, color: context.borderCol),
                    const SizedBox(height: 6),
                    if (!isCollapsed)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 6),
                        child: Text(
                          context.l10n.navSectionSystem,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: context.textMutedColor,
                          ),
                        ),
                      ),
                    ...systemItems.map(
                      (item) => _SidebarItemTile(
                        item: item,
                        isSelected: currentIndex == item.index,
                        isCollapsed: isCollapsed,
                        onTap: () => onDestinationSelected(item.index),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Footer: Lối vào nhanh Trợ lý AI English Buddy
            Divider(height: 1, color: context.borderCol),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 8 : 12,
                vertical: 8,
              ),
              child: _buildAiAssistantButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiAssistantButton(BuildContext context) {
    if (isCollapsed) {
      return Tooltip(
        message: context.l10n.aiChatDesc,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiChatScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiChatScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.aiChatTooltip,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: context.primaryAccent,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      context.l10n.aiChatQuickHelp,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: context.textSecondaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 12 : 16,
        vertical: 14,
      ),
      child: Row(
        mainAxisAlignment: isCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          if (!isCollapsed)
            Expanded(
              child: Row(
                children: [
                  _buildLogoBadge(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: context.textPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Smart English',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: context.primaryAccent,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Tooltip(
              message: context.l10n.sidebarExpandTooltip,
              child: InkWell(
                onTap: onToggleCollapse,
                borderRadius: BorderRadius.circular(12),
                child: _buildLogoBadge(),
              ),
            ),
          if (!isCollapsed)
            Tooltip(
              message: context.l10n.sidebarCollapseTooltip,
              child: IconButton(
                onPressed: onToggleCollapse,
                icon: Icon(
                  Icons.keyboard_double_arrow_left_rounded,
                  size: 20,
                  color: context.textSecondaryColor,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: context.scaffoldBg,
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(34, 34),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoBadge() {
    return Container(
      key: const Key('sidebar_brand_logo'),
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FEFE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/app_logo.png',
          width: 38,
          height: 38,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) => Container(
            color: AppColors.primary,
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItemTile extends StatefulWidget {
  final SidebarNavItem item;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarItemTile({
    required this.item,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_SidebarItemTile> createState() => _SidebarItemTileState();
}

class _SidebarItemTileState extends State<_SidebarItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 160);

    final isSelected = widget.isSelected;
    final activeColor =
        context.isDark ? AppColors.primaryLight : AppColors.primary;
    final inactiveColor = context.textSecondaryColor;

    Color bgColor = Colors.transparent;
    if (isSelected) {
      bgColor = context.activeNavBg;
    } else if (_isHovered) {
      bgColor = context.isDark
          ? Colors.white.withValues(alpha: 0.05)
          : AppColors.primary.withValues(alpha: 0.05);
    }

    final borderColor = isSelected
        ? context.activeNavBorder
        : (_isHovered ? context.borderCol : Colors.transparent);

    Widget tileContent = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              hoverColor: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isCollapsed ? 0 : 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: widget.isCollapsed
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    if (!widget.isCollapsed)
                      AnimatedContainer(
                        duration: duration,
                        width: 3.5,
                        height: isSelected ? 18 : 0,
                        margin: EdgeInsets.only(right: isSelected ? 9 : 0),
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          isSelected
                              ? widget.item.selectedIcon
                              : widget.item.icon,
                          size: 20,
                          color: isSelected
                              ? activeColor
                              : (_isHovered
                                  ? context.textPrimaryColor
                                  : inactiveColor),
                        ),
                        if (widget.isCollapsed &&
                            widget.item.badgeCount != null)
                          Positioned(
                            right: -6,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${widget.item.badgeCount}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (!widget.isCollapsed) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.item.label,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? context.textPrimaryColor
                                : inactiveColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.item.badgeCount != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? activeColor.withValues(alpha: 0.2)
                                : context.warningLightCol,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${widget.item.badgeCount}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected ? activeColor : AppColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.isCollapsed) {
      return Tooltip(
        message: widget.item.badgeCount != null
            ? '${widget.item.label} (${widget.item.badgeCount})'
            : widget.item.label,
        preferBelow: false,
        child: tileContent,
      );
    }

    return tileContent;
  }
}
