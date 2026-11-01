import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/skill_exercise_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/study_provider.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/top_profile_menu_button.dart';
import 'admin/admin_screen.dart';
import 'chat/ai_chat_screen.dart';
import 'dictionary/dictionary_screen.dart';
import 'exam/exam_hub_screen.dart';
import 'home/home_screen.dart';
import 'review/review_screen.dart';
import 'settings/settings_screen.dart';
import 'shadowing/shadowing_hub_screen.dart';
import 'skills/games_hub_screen.dart';
import 'skills/single_skill_screen.dart';
import 'stats/stats_screen.dart';
import 'topics/topic_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _mobileScaffoldKey =
      GlobalKey<ScaffoldState>();
  late int _currentIndex;
  late final Set<int> _visitedTabs;
  bool _isSidebarCollapsed = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 13);
    _visitedTabs = {_currentIndex};
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      value: 1.0,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    bool isAdmin = false;
    try {
      isAdmin = Provider.of<AuthProvider>(context, listen: false).isAdmin;
    } catch (_) {
      isAdmin = false;
    }

    if (index == 13 && !isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Truy cập bị từ chối: Khu vực Quản trị chỉ dành cho tài khoản Admin.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final maxIndex = isAdmin ? 13 : 12;
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final clampedIndex = index.clamp(0, maxIndex);
    setState(() {
      _currentIndex = clampedIndex;
      _visitedTabs.add(clampedIndex);
    });

    if (!disableAnimations) {
      _fadeController.forward(from: 0.72);
    }

    if (index == 11) {
      try {
        Provider.of<StatsProvider>(context, listen: false).loadStats();
      } catch (_) {}
    } else if (index == 10) {
      try {
        final study = Provider.of<StudyProvider>(context, listen: false);
        study.loadReviewWords();
        study.loadFavoriteWords();
      } catch (_) {}
    }
  }

  int _mapIndexToMobileBottomBar(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return 0; // Trang chủ
      case 1:
        return 1; // Chủ đề
      case 6:
        return 2; // Shadowing
      case 7:
        return 3; // Từ vựng / Từ điển
      case 10:
        return 4; // Ôn tập
      default:
        return 0;
    }
  }

  int _mapMobileBottomBarToIndex(int bottomIndex) {
    switch (bottomIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 6;
      case 3:
        return 7;
      case 4:
        return 10;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = screenWidth >= 820;
    final studyProvider = Provider.of<StudyProvider>(context);
    final reviewCount = studyProvider.reviewWords.length;
    AuthProvider? authProvider;
    try {
      authProvider = Provider.of<AuthProvider>(context);
    } catch (_) {
      authProvider = null;
    }
    final isAdmin = authProvider?.isAdmin ?? false;

    final List<Widget> screenBuilders = [
      HomeScreen(onTabChange: _onTabTapped), // 0: Trang chủ
      const TopicListScreen(), // 1: Chủ đề
      const SingleSkillScreen(skillType: SkillType.listening), // 2: Luyện nghe
      const SingleSkillScreen(skillType: SkillType.reading), // 3: Luyện đọc
      const SingleSkillScreen(skillType: SkillType.writing), // 4: Luyện viết
      const SingleSkillScreen(skillType: SkillType.speaking), // 5: Luyện nói
      const ShadowingHubScreen(), // 6: Shadowing
      const DictionaryScreen(), // 7: Từ vựng / Từ điển
      const ExamHubScreen(), // 8: Luyện thi
      const GamesHubScreen(), // 9: Trò chơi
      const ReviewScreen(), // 10: Ôn tập
      const StatsScreen(), // 11: Thống kê
      const SettingsScreen(), // 12: Cài đặt
      if (isAdmin) const AdminScreen(), // 13: Quản trị viên (Chỉ khi là Admin)
    ];

    final effectiveIndex =
        _currentIndex >= screenBuilders.length ? 0 : _currentIndex;

    final List<Widget> screens = List<Widget>.generate(
      screenBuilders.length,
      (index) => _visitedTabs.contains(index)
          ? screenBuilders[index]
          : const SizedBox.shrink(),
    );

    final contentStack = FadeTransition(
      opacity: _fadeAnimation,
      child: IndexedStack(
        index: effectiveIndex,
        children: screens,
      ),
    );

    if (isWideScreen) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        floatingActionButton: _buildAiChatFab(context),
        body: Row(
          children: [
            AppSidebar(
              currentIndex: effectiveIndex,
              isCollapsed: _isSidebarCollapsed,
              onDestinationSelected: _onTabTapped,
              onToggleCollapse: () {
                setState(() {
                  _isSidebarCollapsed = !_isSidebarCollapsed;
                });
              },
            ),
            Expanded(
              child: contentStack,
            ),
          ],
        ),
      );
    }

    // Giao diện Màn hình hẹp (Mobile / Điện thoại): Drawer đầy đủ + NavigationBar gọn
    final navItems = AppSidebar.buildNavigationItems(
      reviewCount: reviewCount,
      isAdmin: isAdmin,
    );
    final currentNavItem = navItems[effectiveIndex];

    return Scaffold(
      key: _mobileScaffoldKey,
      backgroundColor: context.scaffoldBg,
      drawer: _buildMobileDrawer(context, navItems),
      floatingActionButton: _buildAiChatFab(context),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.surfaceBg,
                border: Border(bottom: BorderSide(color: context.borderCol)),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Mở danh mục 13 kỹ năng & chức năng',
                    onPressed: () =>
                        _mobileScaffoldKey.currentState?.openDrawer(),
                    icon: Icon(
                      Icons.menu_rounded,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${AppConstants.appName} • ${currentNavItem.label}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Trợ lý AI English Buddy',
                    icon: const Icon(
                      Icons.smart_toy_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AiChatScreen()),
                      );
                    },
                  ),
                  if (effectiveIndex != 0) ...[
                    const SizedBox(width: 4),
                    const TopProfileMenuButton(compact: true),
                  ],
                ],
              ),
            ),
          ),
          Expanded(child: contentStack),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.borderCol, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _mapIndexToMobileBottomBar(_currentIndex),
          onDestinationSelected: (bottomIdx) =>
              _onTabTapped(_mapMobileBottomBarToIndex(bottomIdx)),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Trang chủ',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Chủ đề',
            ),
            const NavigationDestination(
              icon: Icon(Icons.graphic_eq_outlined),
              selectedIcon: Icon(Icons.graphic_eq_rounded),
              label: 'Shadowing',
            ),
            const NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories_rounded),
              label: 'Từ điển',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: reviewCount > 0,
                label: Text('$reviewCount'),
                child: const Icon(Icons.replay_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: reviewCount > 0,
                label: Text('$reviewCount'),
                child: const Icon(Icons.replay_circle_filled_rounded),
              ),
              label: 'Ôn tập',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(
      BuildContext context, List<SidebarNavItem> navItems) {
    AuthProvider? authProvider;
    try {
      authProvider = Provider.of<AuthProvider>(context);
    } catch (_) {
      authProvider = null;
    }
    final user = authProvider?.currentUser;

    return Drawer(
      backgroundColor: context.sidebarBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Text(
                          user != null
                              ? user.email
                              : 'Chế độ học cục bộ an toàn',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.borderCol),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AiChatScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Trợ lý AI English Buddy',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Hỏi đáp ngữ pháp & góp ý bài viết',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                itemCount: navItems.length,
                itemBuilder: (ctx, i) {
                  final item = navItems[i];
                  final isSelected = _currentIndex == item.index;
                  return ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selected: isSelected,
                    selectedTileColor: context.activeNavBg,
                    leading: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected
                          ? context.primaryAccent
                          : context.textSecondaryColor,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? context.textPrimaryColor
                            : context.textSecondaryColor,
                      ),
                    ),
                    trailing: item.badgeCount != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.warningLightCol,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.badgeCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      _onTabTapped(item.index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiChatFab(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'ai_chat_fab',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiChatScreen()),
        );
      },
      icon: const Icon(Icons.smart_toy_rounded, size: 20),
      label: const Text(
        'Hỏi AI',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 3,
      tooltip: 'Trò chuyện cùng Trợ lý AI English Buddy',
    );
  }
}
