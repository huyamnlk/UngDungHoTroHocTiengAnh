import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/exam_seed_data.dart';
import '../../../core/database/skills_seed_data.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/exam_model.dart';
import '../../../data/models/skill_exercise_model.dart';
import '../../../data/models/topic_model.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/models/word_model.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../../data/repositories/vocabulary_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/user_avatar_widget.dart';
import '../exam/exam_attempt_screen.dart';
import '../skills/exercise_detail_screen.dart';
import '../topics/add_word_dialog.dart';

class AdminScreen extends StatefulWidget {
  final VocabularyRepository? vocabularyRepository;

  const AdminScreen({super.key, this.vocabularyRepository});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final VocabularyRepository _vocabRepo;

  // Trạng thái Tab 1: Quản lý Người dùng & Hồ sơ
  bool _isLoadingUsers = false;
  List<UserProfileModel> _users = [];
  String _userSearchQuery = '';
  String _roleFilter = 'all';
  String _userLevelFilter = 'all';
  final TextEditingController _userSearchController = TextEditingController();

  // Trạng thái Tab 2: Quản lý Kho Từ vựng & Chủ đề
  bool _isLoadingWords = false;
  List<WordModel> _words = [];
  String _wordSearchQuery = '';
  String _wordLevelFilter = 'all';
  int _selectedTopicFilter = 0; // 0 = Tất cả
  final TextEditingController _wordSearchController = TextEditingController();

  // Trạng thái Tab 3: Quản lý Bài đọc & Bài nghe (Skills)
  String _skillTypeFilter = 'all'; // 'all', 'reading', 'listening'
  String _skillLevelFilter = 'all';
  String _skillSearchQuery = '';
  final TextEditingController _skillSearchController = TextEditingController();

  // Trạng thái Tab 4: Quản lý Đề thi thử (Mock Exams)
  String _examCategoryFilter = 'all';
  String _examSearchQuery = '';
  final TextEditingController _examSearchController = TextEditingController();

  // Trạng thái Tab 5: Thống kê Hệ thống
  bool _isLoadingMetrics = false;
  Map<String, int> _systemMetrics = {};

  // Thông báo trạng thái chung
  String? _bannerMessage;
  bool _isBannerError = false;
  String? _loadedForAdminUid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _vocabRepo = widget.vocabularyRepository ?? VocabularyRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isAdmin &&
        authProvider.currentUser != null &&
        _loadedForAdminUid != authProvider.currentUser!.uid) {
      _loadedForAdminUid = authProvider.currentUser!.uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshAllAdminData();
      });
    } else if (!authProvider.isAdmin) {
      _loadedForAdminUid = null;
      _users = [];
      _words = [];
      _systemMetrics = {};
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userSearchController.dispose();
    _wordSearchController.dispose();
    _skillSearchController.dispose();
    _examSearchController.dispose();
    super.dispose();
  }

  void _setBanner(String message, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _bannerMessage = message;
      _isBannerError = isError;
    });
  }

  Future<void> _refreshAllAdminData() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAdmin || authProvider.currentUser == null) return;

    await Future.wait([
      _loadUsers(),
      _loadWords(),
      _loadSystemMetrics(),
    ]);
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAdmin) return;

    setState(() => _isLoadingUsers = true);
    try {
      final list = await authProvider.adminGetUsers(
        searchQuery: _userSearchQuery,
        roleFilter: _roleFilter,
        levelFilter: _userLevelFilter,
      );
      if (!mounted) return;
      setState(() {
        _users = list;
        _isLoadingUsers = false;
      });
    } on AdminAccessDeniedException catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingUsers = false);
      _setBanner(e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingUsers = false);
      _setBanner('Không thể tải danh sách người dùng: $e', isError: true);
    }
  }

  Future<void> _loadWords() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAdmin) return;

    setState(() => _isLoadingWords = true);
    try {
      List<WordModel> results = await _vocabRepo.searchDictionary(
        _wordSearchQuery,
        levelFilter: _wordLevelFilter,
      );
      if (_selectedTopicFilter > 0) {
        results = results
            .where((w) => w.topicId == _selectedTopicFilter)
            .toList();
      }
      if (!mounted) return;
      setState(() {
        _words = results;
        _isLoadingWords = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingWords = false);
      _setBanner('Lỗi tải danh sách từ vựng: $e', isError: true);
    }
  }

  Future<void> _loadSystemMetrics() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAdmin || authProvider.currentUser == null) return;

    setState(() => _isLoadingMetrics = true);
    try {
      final metrics = await _vocabRepo.adminGetSystemMetrics(
        actorUid: authProvider.currentUser!.uid,
      );
      if (!mounted) return;
      setState(() {
        _systemMetrics = metrics;
        _isLoadingMetrics = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMetrics = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Chốt chặn phân quyền nghiêm ngặt ở giao diện:
    // Nếu không phải Admin, hiển thị màn hình 403 Forbidden và không render nội dung quản trị.
    if (!authProvider.isAdmin || authProvider.currentUser == null) {
      return _buildAccessDeniedScreen(context);
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.warning,
              size: 24,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Khu vực Quản trị Hệ thống (Admin)',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: context.surfaceBg,
        foregroundColor: context.textPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Làm mới dữ liệu quản trị',
            onPressed: _refreshAllAdminData,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: context.primaryAccent,
          unselectedLabelColor: context.textSecondaryColor,
          indicatorColor: context.primaryAccent,
          tabs: const [
            Tab(
              icon: Icon(Icons.people_alt_rounded, size: 19),
              text: 'Người dùng & Cấp độ',
            ),
            Tab(
              icon: Icon(Icons.library_books_rounded, size: 19),
              text: 'Kho Từ vựng & Chủ đề',
            ),
            Tab(
              icon: Icon(Icons.chrome_reader_mode_rounded, size: 19),
              text: 'Bài đọc & Bài nghe',
            ),
            Tab(
              icon: Icon(Icons.assignment_turned_in_rounded, size: 19),
              text: 'Đề thi thử (Exams)',
            ),
            Tab(
              icon: Icon(Icons.analytics_rounded, size: 19),
              text: 'Giám sát Hệ thống',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_bannerMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isBannerError
                    ? context.dangerLightCol
                    : context.successLightCol,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isBannerError ? AppColors.danger : AppColors.success,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isBannerError
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_rounded,
                    color:
                        _isBannerError ? AppColors.danger : AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _bannerMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => setState(() => _bannerMessage = null),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersManagementTab(context, authProvider),
                _buildVocabularyManagementTab(context, authProvider),
                _buildSkillsContentTab(context, authProvider),
                _buildExamsManagementTab(context, authProvider),
                _buildSystemOverviewTab(context, authProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDeniedScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Truy cập bị từ chối (403)'),
        backgroundColor: context.surfaceBg,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
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
                  Icons.shield_outlined,
                  size: 60,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 16),
                Text(
                  'Khu vực dành riêng cho Quản trị viên (403 Forbidden)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tài khoản hiện tại của bạn không có quyền Quản trị viên (Admin). Mọi truy cập giao diện và lời gọi API quản trị đều được kiểm tra phân quyền nghiêm ngặt.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: context.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1: QUẢN LÝ NGƯỜI DÙNG, HỒ SƠ & CẤP ĐỘ CEFR
  // ===========================================================================
  Widget _buildUsersManagementTab(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final totalUsers = _users.length;
    final adminCount = _users.where((u) => u.isAdmin).length;
    final regularCount = _users.where((u) => !u.isAdmin).length;
    final activeCount = _users.where((u) => u.isActive).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hàng thống kê nhanh
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: 260,
                    child: StatCard(
                      title: 'Tổng hồ sơ tài khoản',
                      value: '$totalUsers',
                      subtitle: 'Trong CSDL thực tế',
                      icon: Icons.people_alt_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: StatCard(
                      title: 'Quản trị viên (Admin)',
                      value: '$adminCount',
                      subtitle: 'Toàn quyền hệ thống',
                      icon: Icons.admin_panel_settings_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: StatCard(
                      title: 'Học viên (User)',
                      value: '$regularCount',
                      subtitle: '$activeCount đang hoạt động',
                      icon: Icons.school_rounded,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Thanh tìm kiếm và lọc
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _userSearchController,
                      style: TextStyle(color: context.textPrimaryColor),
                      decoration: InputDecoration(
                        labelText: 'Tìm kiếm người dùng',
                        hintText: 'Nhập tên hiển thị, email hoặc UID...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _userSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _userSearchController.clear();
                                  setState(() => _userSearchQuery = '');
                                  _loadUsers();
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        setState(() => _userSearchQuery = val);
                        _loadUsers();
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Vai trò:',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Tất cả'),
                          selected: _roleFilter == 'all',
                          onSelected: (_) {
                            setState(() => _roleFilter = 'all');
                            _loadUsers();
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Admin'),
                          selected: _roleFilter == AppConstants.roleAdmin,
                          onSelected: (_) {
                            setState(
                                () => _roleFilter = AppConstants.roleAdmin);
                            _loadUsers();
                          },
                        ),
                        ChoiceChip(
                          label: const Text('User'),
                          selected: _roleFilter == AppConstants.roleUser,
                          onSelected: (_) {
                            setState(() => _roleFilter = AppConstants.roleUser);
                            _loadUsers();
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Cấp độ CEFR:',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Tất cả'),
                          selected: _userLevelFilter == 'all',
                          onSelected: (_) {
                            setState(() => _userLevelFilter = 'all');
                            _loadUsers();
                          },
                        ),
                        ...AppConstants.cefrLevels.map(
                          (lvl) => ChoiceChip(
                            label: Text(lvl),
                            selected: _userLevelFilter == lvl,
                            onSelected: (_) {
                              setState(() => _userLevelFilter = lvl);
                              _loadUsers();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Danh sách hồ sơ người dùng
              if (_isLoadingUsers)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_users.isEmpty)
                EmptyStateView(
                  icon: Icons.person_search_rounded,
                  title: 'Không tìm thấy hồ sơ người dùng phù hợp',
                  description:
                      'Không có tài khoản nào khớp với bộ lọc hiện tại. Hãy thử xóa từ khóa tìm kiếm hoặc đổi bộ lọc.',
                  buttonText: 'Đặt lại bộ lọc',
                  onButtonPressed: () {
                    _userSearchController.clear();
                    setState(() {
                      _userSearchQuery = '';
                      _roleFilter = 'all';
                      _userLevelFilter = 'all';
                    });
                    _loadUsers();
                  },
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final userProfile = _users[index];
                    return _buildUserAdminCard(
                      context,
                      authProvider: authProvider,
                      userProfile: userProfile,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAdminCard(
    BuildContext context, {
    required AuthProvider authProvider,
    required UserProfileModel userProfile,
  }) {
    final isCurrentAdmin = authProvider.currentUser?.uid == userProfile.uid;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: userProfile.isAdmin
              ? AppColors.warning.withValues(alpha: 0.65)
              : context.borderCol,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatarWidget(
            avatarData: userProfile.avatarData,
            displayName: userProfile.displayName,
            size: 52,
            showAdminBadge: userProfile.isAdmin,
          ),
          const SizedBox(width: 14),
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
                      userProfile.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    if (isCurrentAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.successLightCol,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Bạn',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: userProfile.isAdmin
                            ? context.warningLightCol
                            : context.primaryContainerCol,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        userProfile.isAdmin ? 'ADMIN' : 'USER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: userProfile.isAdmin
                              ? AppColors.warning
                              : context.primaryAccent,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryContainerCol,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'CEFR ${userProfile.cefrLevel}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.primaryAccent,
                        ),
                      ),
                    ),
                    if (!userProfile.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.dangerLightCol,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Đã khóa',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Email: ${userProfile.email} • UID: ${userProfile.uid} • Nguồn: ${userProfile.providerId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondaryColor,
                  ),
                ),
                if (userProfile.bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Bio: ${userProfile.bio}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: context.textPrimaryColor,
                    ),
                  ),
                ],
                if (userProfile.learningGoal.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Mục tiêu: ${userProfile.learningGoal}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'Cập nhật lần cuối: ${UiHelpers.formatDateTime(userProfile.updatedAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textMutedColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _openEditUserDialog(
                  context,
                  authProvider: authProvider,
                  targetUser: userProfile,
                ),
                icon: const Icon(Icons.edit_rounded, size: 17),
                label: const Text('Quản lý hồ sơ'),
              ),
              if (!isCurrentAdmin && userProfile.uid != 'local_learner') ...[
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: () => _confirmDeleteUser(
                    context,
                    authProvider: authProvider,
                    targetUser: userProfile,
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 17,
                    color: AppColors.danger,
                  ),
                  label: const Text(
                    'Xóa hồ sơ',
                    style: TextStyle(color: AppColors.danger, fontSize: 12.5),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openEditUserDialog(
    BuildContext context, {
    required AuthProvider authProvider,
    required UserProfileModel targetUser,
  }) async {
    final nameCtrl = TextEditingController(text: targetUser.displayName);
    final bioCtrl = TextEditingController(text: targetUser.bio);
    final goalCtrl = TextEditingController(text: targetUser.learningGoal);
    String selectedLevel = targetUser.cefrLevel;
    String selectedRole = targetUser.role;
    bool isActive = targetUser.isActive;
    final isSelf = authProvider.currentUser?.uid == targetUser.uid;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(
                    Icons.manage_accounts_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Chi tiết & Phân quyền: ${targetUser.displayName}',
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Thông tin định danh cố định (Admin không sửa email/UID/mật khẩu)
                      Container(
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
                              'Thông tin định danh hệ thống (Chỉ đọc)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: context.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• UID: ${targetUser.uid}\n'
                              '• Email: ${targetUser.email}\n'
                              '• Phương thức xác thực: ${targetUser.providerId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textPrimaryColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cấp độ CEFR
                      Text(
                        'Cấp độ Năng lực CEFR (Do Admin xét duyệt):',
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
                          return ChoiceChip(
                            label: Text('CEFR $lvl'),
                            selected: selectedLevel == lvl,
                            onSelected: (_) {
                              setDialogState(() => selectedLevel = lvl);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Vai trò tài khoản
                      Text(
                        'Vai trò phân quyền (Role):',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(
                                child: Text('Học viên (user)'),
                              ),
                              selected: selectedRole == AppConstants.roleUser,
                              onSelected: isSelf
                                  ? null
                                  : (_) {
                                      setDialogState(
                                        () => selectedRole =
                                            AppConstants.roleUser,
                                      );
                                    },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(
                                child: Text('Quản trị viên (admin)'),
                              ),
                              selected: selectedRole == AppConstants.roleAdmin,
                              onSelected: isSelf
                                  ? null
                                  : (_) {
                                      setDialogState(
                                        () => selectedRole =
                                            AppConstants.roleAdmin,
                                      );
                                    },
                            ),
                          ),
                        ],
                      ),
                      if (isSelf)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Lưu ý: Không thể tự hạ quyền hoặc khóa tài khoản Admin đang đăng nhập.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: context.textMutedColor,
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),

                      // Trạng thái hoạt động
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Trạng thái hoạt động tài khoản',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        subtitle: Text(
                          isActive
                              ? 'Đang hoạt động bình thường'
                              : 'Tài khoản đang bị tạm khóa',
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                        value: isActive,
                        onChanged: isSelf
                            ? null
                            : (val) {
                                setDialogState(() => isActive = val);
                              },
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tên hiển thị',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: bioCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Giới thiệu (Bio)',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: goalCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Mục tiêu học tập',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Hủy'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    final hasSensitiveChange =
                        selectedRole != targetUser.role ||
                        !isActive != !targetUser.isActive ||
                        selectedLevel != targetUser.cefrLevel;

                    if (hasSensitiveChange) {
                      final confirmed = await _showConfirmDialog(
                        context,
                        title: 'Xác nhận cập nhật quản trị',
                        message:
                            'Bạn sắp thay đổi thông tin quan trọng của "${targetUser.displayName}":\n'
                            '• Vai trò: ${targetUser.role} → $selectedRole\n'
                            '• Cấp độ CEFR: ${targetUser.cefrLevel} → $selectedLevel\n'
                            '• Trạng thái: ${isActive ? "Hoạt động" : "Tạm khóa"}\n\n'
                            'Bạn có chắc chắn muốn áp dụng thay đổi này?',
                      );
                      if (!confirmed) return;
                    }

                    try {
                      await authProvider.adminUpdateUser(
                        targetUid: targetUser.uid,
                        displayName: nameCtrl.text,
                        bio: bioCtrl.text,
                        learningGoal: goalCtrl.text,
                        cefrLevel: selectedLevel,
                        role: selectedRole,
                        isActive: isActive,
                      );
                      if (!dialogCtx.mounted) return;
                      Navigator.pop(dialogCtx);
                      _setBanner(
                        'Đã cập nhật hồ sơ & cấp độ của "${nameCtrl.text.trim()}" thành công!',
                      );
                      await _loadUsers();
                      await _loadSystemMetrics();
                    } catch (e) {
                      if (!dialogCtx.mounted) return;
                      UiHelpers.showSnackBar(
                        dialogCtx,
                        message: e.toString(),
                        isError: true,
                      );
                    }
                  },
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Lưu thay đổi'),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    bioCtrl.dispose();
    goalCtrl.dispose();
  }

  Future<void> _confirmDeleteUser(
    BuildContext context, {
    required AuthProvider authProvider,
    required UserProfileModel targetUser,
  }) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Xác nhận xóa hồ sơ tài khoản',
      message:
          'Bạn có chắc chắn muốn xóa hồ sơ của "${targetUser.displayName}" (${targetUser.email}) khỏi cơ sở dữ liệu?\nThao tác này không thể hoàn tác.',
      isDanger: true,
    );
    if (!confirmed) return;

    try {
      await authProvider.adminDeleteUser(targetUid: targetUser.uid);
      _setBanner('Đã xóa hồ sơ "${targetUser.displayName}" thành công.');
      await _loadUsers();
      await _loadSystemMetrics();
    } catch (e) {
      _setBanner(e.toString(), isError: true);
    }
  }

  // ===========================================================================
  // TAB 2: QUẢN LÝ KHO TỪ VỰNG & CHỦ ĐỀ CEFR
  // ===========================================================================
  Widget _buildVocabularyManagementTab(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final studyProvider = context.watch<StudyProvider>();
    final topics = studyProvider.topics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh công cụ Tìm kiếm, Lọc từ vựng & Thêm từ mới
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _wordSearchController,
                            style: TextStyle(color: context.textPrimaryColor),
                            decoration: InputDecoration(
                              labelText: 'Tìm từ vựng trong CSDL (3.000+ mục từ)',
                              hintText:
                                  'Nhập từ tiếng Anh, nghĩa tiếng Việt hoặc định nghĩa...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _wordSearchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _wordSearchController.clear();
                                        setState(() => _wordSearchQuery = '');
                                        _loadWords();
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (val) {
                              setState(() => _wordSearchQuery = val);
                              _loadWords();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () async {
                            final defaultTopic = topics.isNotEmpty
                                ? topics.first
                                : const TopicModel(
                                    id: 1,
                                    name: 'Giao tiếp thông dụng',
                                    iconName: 'chat',
                                    colorHex: '#3B82F6',
                                    description: '',
                                  );
                            final added = await showDialog<bool>(
                              context: context,
                              builder: (_) => AddWordDialog(
                                topicId: defaultTopic.id,
                                topicName: defaultTopic.name,
                              ),
                            );
                            if (added == true) {
                              await _loadWords();
                              await _loadSystemMetrics();
                            }
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Thêm từ mới'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Cấp độ CEFR:',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Tất cả'),
                          selected: _wordLevelFilter == 'all',
                          onSelected: (_) {
                            setState(() => _wordLevelFilter = 'all');
                            _loadWords();
                          },
                        ),
                        ...AppConstants.cefrLevels.map(
                          (lvl) => ChoiceChip(
                            label: Text(lvl),
                            selected: _wordLevelFilter == lvl,
                            onSelected: (_) {
                              setState(() => _wordLevelFilter = lvl);
                              _loadWords();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Chủ đề:',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Tất cả chủ đề'),
                          selected: _selectedTopicFilter == 0,
                          onSelected: (_) {
                            setState(() => _selectedTopicFilter = 0);
                            _loadWords();
                          },
                        ),
                        ...topics.map(
                          (t) => ChoiceChip(
                            label: Text(t.name),
                            selected: _selectedTopicFilter == t.id,
                            onSelected: (_) {
                              setState(() => _selectedTopicFilter = t.id);
                              _loadWords();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              if (_isLoadingWords)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_words.isEmpty)
                EmptyStateView(
                  icon: Icons.menu_book_rounded,
                  title: 'Không tìm thấy mục từ vựng nào',
                  description:
                      'Không có từ vựng nào khớp với điều kiện tìm kiếm và bộ lọc hiện tại.',
                  buttonText: 'Hiển thị tất cả',
                  onButtonPressed: () {
                    _wordSearchController.clear();
                    setState(() {
                      _wordSearchQuery = '';
                      _wordLevelFilter = 'all';
                      _selectedTopicFilter = 0;
                    });
                    _loadWords();
                  },
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _words.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final word = _words[idx];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.borderCol),
                      ),
                      child: Row(
                        children: [
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
                                      word.term,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: context.textPrimaryColor,
                                      ),
                                    ),
                                    if (word.ipa.isNotEmpty)
                                      Text(
                                        word.ipa,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                          color: context.textSecondaryColor,
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.primaryContainerCol,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'CEFR ${word.level}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: context.primaryAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  word.meaning,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: context.primaryAccent,
                                  ),
                                ),
                                if (word.englishDefinition.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    word.englishDefinition,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Chỉnh sửa từ & Cấp độ CEFR',
                            onPressed: () => _openEditWordDialog(
                              context,
                              authProvider: authProvider,
                              word: word,
                            ),
                            icon: Icon(
                              Icons.edit_outlined,
                              color: context.primaryAccent,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Xóa từ vựng',
                            onPressed: () => _confirmDeleteWord(
                              context,
                              authProvider: authProvider,
                              word: word,
                            ),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditWordDialog(
    BuildContext context, {
    required AuthProvider authProvider,
    required WordModel word,
  }) async {
    final termCtrl = TextEditingController(text: word.term);
    final ipaCtrl = TextEditingController(text: word.ipa);
    final meaningCtrl = TextEditingController(text: word.meaning);
    final defCtrl = TextEditingController(text: word.englishDefinition);
    final exEnCtrl = TextEditingController(text: word.exampleEn);
    String selectedLevel = AppConstants.cefrLevels.contains(word.level)
        ? word.level
        : 'B1';

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text('Chỉnh sửa từ vựng: ${word.term}'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: termCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Từ tiếng Anh *',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: ipaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Phiên âm IPA',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: meaningCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nghĩa tiếng Việt *',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: defCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Định nghĩa tiếng Anh',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: exEnCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Câu ví dụ tiếng Anh',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Cấp độ từ vựng CEFR:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: AppConstants.cefrLevels.map((lvl) {
                          return ChoiceChip(
                            label: Text(lvl),
                            selected: selectedLevel == lvl,
                            onSelected: (_) {
                              setDialogState(() => selectedLevel = lvl);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      final updatedWord = word.copyWith(
                        term: termCtrl.text.trim(),
                        ipa: ipaCtrl.text.trim(),
                        meaning: meaningCtrl.text.trim(),
                        englishDefinition: defCtrl.text.trim(),
                        exampleEn: exEnCtrl.text.trim(),
                        level: selectedLevel,
                      );
                      await _vocabRepo.adminUpdateWord(
                        actorUid: authProvider.currentUser?.uid,
                        word: updatedWord,
                      );
                      if (!dialogCtx.mounted) return;
                      Navigator.pop(dialogCtx);
                      _setBanner(
                        'Đã cập nhật từ "${updatedWord.term}" (CEFR $selectedLevel).',
                      );
                      await _loadWords();
                      if (context.mounted) {
                        await context.read<StudyProvider>().loadInitialData();
                      }
                    } catch (e) {
                      if (!dialogCtx.mounted) return;
                      UiHelpers.showSnackBar(
                        dialogCtx,
                        message: e.toString(),
                        isError: true,
                      );
                    }
                  },
                  child: const Text('Lưu từ vựng'),
                ),
              ],
            );
          },
        );
      },
    );

    termCtrl.dispose();
    ipaCtrl.dispose();
    meaningCtrl.dispose();
    defCtrl.dispose();
    exEnCtrl.dispose();
  }

  Future<void> _confirmDeleteWord(
    BuildContext context, {
    required AuthProvider authProvider,
    required WordModel word,
  }) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Xác nhận xóa từ vựng',
      message:
          'Bạn có chắc chắn muốn xóa từ "${word.term}" (${word.meaning}) khỏi cơ sở dữ liệu?',
      isDanger: true,
    );
    if (!confirmed) return;

    try {
      await _vocabRepo.adminDeleteWord(
        actorUid: authProvider.currentUser?.uid,
        wordId: word.id,
      );
      _setBanner('Đã xóa từ "${word.term}" khỏi kho từ vựng.');
      await _loadWords();
      await _loadSystemMetrics();
      if (context.mounted) {
        await context.read<StudyProvider>().loadInitialData();
      }
    } catch (e) {
      _setBanner(e.toString(), isError: true);
    }
  }

  // ===========================================================================
  // TAB 3: QUẢN LÝ BÀI ĐỌC & BÀI NGHE (READING & LISTENING)
  // ===========================================================================
  Widget _buildSkillsContentTab(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final allReading = SkillsSeedData.readingExercises;
    final allListening = SkillsSeedData.listeningExercises;

    var filtered = <SkillExerciseModel>[];
    if (_skillTypeFilter == 'all' || _skillTypeFilter == 'reading') {
      filtered.addAll(allReading);
    }
    if (_skillTypeFilter == 'all' || _skillTypeFilter == 'listening') {
      filtered.addAll(allListening);
    }

    if (_skillLevelFilter != 'all') {
      filtered = filtered.where((e) => e.level == _skillLevelFilter).toList();
    }

    if (_skillSearchQuery.trim().isNotEmpty) {
      final q = _skillSearchQuery.trim().toLowerCase();
      filtered = filtered.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.topic.toLowerCase().contains(q) ||
            e.content.toLowerCase().contains(q);
      }).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _skillSearchController,
                            style: TextStyle(color: context.textPrimaryColor),
                            decoration: InputDecoration(
                              labelText:
                                  'Tìm bài đọc / bài nghe (${filtered.length} bài)',
                              hintText:
                                  'Nhập tiêu đề bài, chủ đề hoặc nội dung...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _skillSearchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _skillSearchController.clear();
                                        setState(() => _skillSearchQuery = '');
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (val) {
                              setState(() => _skillSearchQuery = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Kỹ năng:',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Tất cả'),
                          selected: _skillTypeFilter == 'all',
                          onSelected: (_) =>
                              setState(() => _skillTypeFilter = 'all'),
                        ),
                        ChoiceChip(
                          label: const Text('📖 Bài đọc (Reading)'),
                          selected: _skillTypeFilter == 'reading',
                          onSelected: (_) =>
                              setState(() => _skillTypeFilter = 'reading'),
                        ),
                        ChoiceChip(
                          label: const Text('🎧 Bài nghe (Listening)'),
                          selected: _skillTypeFilter == 'listening',
                          onSelected: (_) =>
                              setState(() => _skillTypeFilter = 'listening'),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cấp độ:',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        ...['all', 'A1', 'A2', 'B1', 'B2', 'C1'].map((lvl) {
                          return ChoiceChip(
                            label: Text(lvl == 'all' ? 'Tất cả' : lvl),
                            selected: _skillLevelFilter == lvl,
                            onSelected: (_) =>
                                setState(() => _skillLevelFilter = lvl),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Center(
                    child: Text(
                      'Không tìm thấy bài luyện kỹ năng nào phù hợp với bộ lọc.',
                      style: TextStyle(color: context.textSecondaryColor),
                    ),
                  ),
                )
              else
                ...filtered.map((item) {
                  final isReading = item.type == SkillType.reading;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isReading
                                    ? AppColors.primary
                                    : AppColors.secondary)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isReading
                                ? Icons.menu_book_rounded
                                : Icons.headphones_rounded,
                            color: isReading
                                ? AppColors.primary
                                : AppColors.secondary,
                            size: 24,
                          ),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: context.primaryContainerCol,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.level,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item.topic,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    isReading
                                        ? '• ${item.wordCount} từ (~${item.estimatedReadMinutes} phút đọc)'
                                        : '• ${item.wordCount} từ kịch bản • ${item.keyWords.length} từ then chốt',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    '• ${item.questions.length} câu hỏi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.attribution.source,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: context.textMutedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ExerciseDetailScreen(exercise: item),
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          label: const Text('Xem trước bài'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 4: QUẢN LÝ ĐỀ THI THỬ (MOCK EXAMS)
  // ===========================================================================
  Widget _buildExamsManagementTab(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    const allExams = ExamSeedData.exams;
    var filtered = List<ExamModel>.from(allExams);

    if (_examCategoryFilter != 'all') {
      filtered = filtered
          .where((e) =>
              e.category.toLowerCase() == _examCategoryFilter.toLowerCase())
          .toList();
    }

    if (_examSearchQuery.trim().isNotEmpty) {
      final q = _examSearchQuery.trim().toLowerCase();
      filtered = filtered.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q) ||
            e.skillSection.toLowerCase().contains(q);
      }).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _examSearchController,
                            style: TextStyle(color: context.textPrimaryColor),
                            decoration: InputDecoration(
                              labelText:
                                  'Tìm kiếm bộ đề thi thử (${filtered.length} đề)',
                              hintText:
                                  'Nhập tên đề thi, kỹ năng hoặc mô tả...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _examSearchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _examSearchController.clear();
                                        setState(() => _examSearchQuery = '');
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (val) {
                              setState(() => _examSearchQuery = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Định dạng kỳ thi:',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        ...['all', 'IELTS', 'TOEIC', 'CEFR'].map((cat) {
                          return ChoiceChip(
                            label: Text(cat == 'all' ? 'Tất cả' : cat),
                            selected: _examCategoryFilter == cat,
                            onSelected: (_) =>
                                setState(() => _examCategoryFilter = cat),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Center(
                    child: Text(
                      'Không tìm thấy bộ đề thi thử nào phù hợp với bộ lọc.',
                      style: TextStyle(color: context.textSecondaryColor),
                    ),
                  ),
                )
              else
                ...filtered.map((exam) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          exam.category,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color:
                                              context.primaryContainerCol,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${exam.skillSection} • ${exam.level}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '⏱️ ${exam.durationMinutes} phút • ${exam.questions.length} câu hỏi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              context.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    exam.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    exam.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    exam.attribution.source,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: context.textMutedColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ExamAttemptScreen(
                                          exam: exam,
                                          isPracticeMode: true,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.psychology_outlined,
                                      size: 16),
                                  label: const Text('Xem chế độ Luyện tập'),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ExamAttemptScreen(
                                          exam: exam,
                                          isPracticeMode: false,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.timer_outlined,
                                      size: 16),
                                  label: const Text('Thi thử tính giờ'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 5: GIÁM SÁT HỆ THỐNG & DỮ LIỆU HỌC TẬP THỰC TẾ
  // ===========================================================================
  Widget _buildSystemOverviewTab(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    if (_isLoadingMetrics) {
      return const Center(child: CircularProgressIndicator());
    }

    final wordsCount = _systemMetrics['words'] ?? 0;
    final topicsCount = _systemMetrics['topics'] ?? 0;
    final quizCount = _systemMetrics['quizzes'] ?? 0;
    final skillsCount = _systemMetrics['skillSubmissions'] ?? 0;
    final examsCount = _systemMetrics['examAttempts'] ?? 0;
    final cacheCount = _systemMetrics['dictionaryCache'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: 225,
                    child: StatCard(
                      title: 'Tổng mục từ CEFR',
                      value: '$wordsCount',
                      subtitle: '$topicsCount chủ đề',
                      icon: Icons.menu_book_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: 225,
                    child: StatCard(
                      title: 'Lượt làm Quiz',
                      value: '$quizCount',
                      subtitle: 'Bảng quiz_history',
                      icon: Icons.quiz_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: 225,
                    child: StatCard(
                      title: 'Bài luyện 4 Kỹ năng',
                      value: '$skillsCount',
                      subtitle: 'Bảng skill_scores',
                      icon: Icons.record_voice_over_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                  SizedBox(
                    width: 225,
                    child: StatCard(
                      title: 'Lượt thi thử IELTS/TOEIC',
                      value: '$examsCount',
                      subtitle: 'Bảng exam_attempts',
                      icon: Icons.workspace_premium_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Quản lý Bộ nhớ đệm Từ điển trực tuyến
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.borderCol),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.primaryContainerCol,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.cached_rounded,
                        color: context.primaryAccent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bộ nhớ đệm Từ điển Trực tuyến (dictionary_cache)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Đang lưu trữ $cacheCount từ đã tra cứu trực tuyến (Wiktionary CC BY-SA 3.0) để phục vụ tra cứu Offline.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: cacheCount == 0
                          ? null
                          : () async {
                              final ok = await _showConfirmDialog(
                                context,
                                title: 'Xác nhận dọn bộ nhớ đệm từ điển',
                                message:
                                    'Bạn có chắc chắn muốn xóa toàn bộ $cacheCount mục từ trong bảng dictionary_cache?',
                                isDanger: true,
                              );
                              if (!ok) return;
                              await _vocabRepo.adminClearDictionaryCache(
                                actorUid: authProvider.currentUser?.uid,
                              );
                              _setBanner(
                                'Đã dọn sạch bộ nhớ đệm từ điển trực tuyến.',
                              );
                              await _loadSystemMetrics();
                            },
                      icon: const Icon(Icons.cleaning_services_rounded, size: 17),
                      label: const Text('Dọn Cache'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy bỏ'),
          ),
          FilledButton(
            style: isDanger
                ? FilledButton.styleFrom(backgroundColor: AppColors.danger)
                : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    return result == true;
  }
}
