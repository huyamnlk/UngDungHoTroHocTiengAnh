import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/topic_model.dart';
import '../../../data/models/word_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/interactive_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/top_profile_menu_button.dart';
import '../chat/ai_chat_screen.dart';
import '../quiz/quiz_setup_screen.dart';
import '../review/word_detail_screen.dart';
import '../topics/topic_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final stats = studyProvider.overallStats;
    final total = stats['total'] ?? 0;
    final mastered = stats['mastered'] ?? 0;
    final learning = stats['learning'] ?? 0;
    final favorite = stats['favorite'] ?? 0;
    final dueSrsCount = studyProvider.dueSrsWords.length;
    final wordOfDay = studyProvider.wordOfTheDay;

    final progressRate = total > 0 ? (mastered / total) : 0.0;
    final settings = SettingsService();
    final streakDays = settings.getStreakDays();
    final dailyGoal = settings.getDailyGoal();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await studyProvider.loadInitialData();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 920;
              final isTablet = constraints.maxWidth >= 640;
              final isCompact = constraints.maxWidth < 520;
              final horizontalPadding = isDesktop ? 32.0 : 20.0;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isDesktop ? 28 : 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Top Header Bar: Lời chào, Streak & Nút công cụ
                        _buildTopHeader(
                          context,
                          streakDays: streakDays,
                          isDesktop: isDesktop,
                          isCompact: isCompact,
                        ),
                        const SizedBox(height: 24),

                        // 2. Hero Card: Tiến độ tổng quan & Mục tiêu hằng ngày
                        _buildHeroProgressBanner(
                          context,
                          dailyGoal: dailyGoal,
                          mastered: mastered,
                          total: total,
                          learning: learning,
                          progressRate: progressRate,
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: 24),

                        // 3. Hàng Thống kê Nhanh (4 chỉ số thực tế)
                        _buildStatsOverviewGrid(
                          context,
                          total: total,
                          mastered: mastered,
                          learning: learning,
                          favorite: favorite,
                          dueSrsCount: dueSrsCount,
                          topicCount: studyProvider.topics.length,
                          progressRate: progressRate,
                          isDesktop: isDesktop,
                        ),
                        const SizedBox(height: 28),

                        // 4. Khu vực Trung tâm: Từ vựng hôm nay & Lối tắt học tập
                        if (isDesktop && wordOfDay != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 11,
                                child: _buildWordOfTheDaySection(
                                  context,
                                  wordOfDay: wordOfDay,
                                  studyProvider: studyProvider,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 10,
                                child: _buildQuickActionsSection(
                                  context,
                                  topicCount: studyProvider.topics.length,
                                  totalWords: total,
                                  learningWords: learning,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          if (wordOfDay != null) ...[
                            _buildWordOfTheDaySection(
                              context,
                              wordOfDay: wordOfDay,
                              studyProvider: studyProvider,
                            ),
                            const SizedBox(height: 24),
                          ],
                          _buildQuickActionsSection(
                            context,
                            topicCount: studyProvider.topics.length,
                            totalWords: total,
                            learningWords: learning,
                          ),
                        ],

                        const SizedBox(height: 28),

                        // 5. Khu vực Khám phá Chủ đề
                        _buildFeaturedTopicsSection(
                          context,
                          topics: studyProvider.topics,
                          isWide: isTablet,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context, {
    required int streakDays,
    required bool isDesktop,
    required bool isCompact,
  }) {
    AuthProvider? authProvider;
    try {
      authProvider = Provider.of<AuthProvider>(context);
    } catch (_) {
      authProvider = null;
    }
    final isAuthenticated = authProvider?.isAuthenticated ?? false;
    final displayName = isAuthenticated && authProvider?.currentUser != null
        ? authProvider!.currentUser!.displayName
        : null;

    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
              Text(
                displayName != null
                    ? 'Xin chào, $displayName! 👋'
                    : 'Xin chào bạn! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: context.textPrimaryColor,
                    ),
              ),
              const SizedBox(height: 4),
              if (!isCompact)
                Text(
                'Sẵn sàng bứt phá vốn từ vựng và kỹ năng tiếng Anh hôm nay?',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          );
    final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Huy hiệu Streak chuỗi học
            Tooltip(
              message: 'Chuỗi ngày học liên tiếp',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: context.warningLightCol,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.45)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$streakDays ngày',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Nút mở Thống kê
            Tooltip(
              message: 'Thống kê tiến độ',
              child: IconButton(
                icon: Icon(Icons.bar_chart_rounded, color: context.textPrimaryColor, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: context.cardBg,
                  padding: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: context.borderCol),
                  ),
                ),
                onPressed: () => onTabChange(11),
              ),
            ),
            const SizedBox(width: 8),
            // Nút mở Cài đặt
            Tooltip(
              message: 'Cài đặt & Giao diện',
              child: IconButton(
                icon: Icon(Icons.settings_outlined, color: context.textPrimaryColor, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: context.cardBg,
                  padding: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: context.borderCol),
                  ),
                ),
                onPressed: () => onTabChange(12),
              ),
            ),
            const SizedBox(width: 8),
            // Nút Ảnh đại diện & Menu Chỉnh sửa hồ sơ / Đăng xuất ở góc trên bên phải
            TopProfileMenuButton(compact: !isDesktop),
          ],
        );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          greeting,
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: actions),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Expanded(child: greeting), const SizedBox(width: 12), actions],
    );
  }

  Widget _buildHeroProgressBanner(
    BuildContext context, {
    required int dailyGoal,
    required int mastered,
    required int total,
    required int learning,
    required double progressRate,
    required bool isTablet,
  }) {
    final percentInt = (progressRate * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
            Color(0xFF1E3A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: context.isDark ? 0.28 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Họa tiết vòng tròn trang trí tinh tế
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 60,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isTablet ? 28 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.flag_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Tiến độ & Mục tiêu học tập',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                      ),
                      child: Text(
                        'Mục tiêu: $dailyGoal từ/ngày',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Bạn đã làm chủ $mastered trên tổng số $total từ vựng CEFR ($percentInt% hoàn thành).',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressRate,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuizSetupScreen()),
                        );
                      },
                      icon: const Icon(Icons.quiz_rounded, size: 18),
                      label: const Text(
                        'Làm Quiz phản xạ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1D4ED8),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => onTabChange(10), // Tab Ôn tập
                      icon: const Icon(Icons.replay_rounded, size: 18, color: Colors.white),
                      label: Text(
                        learning > 0 ? 'Ôn tập ngay ($learning từ)' : 'Danh sách ôn tập',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverviewGrid(
    BuildContext context, {
    required int total,
    required int mastered,
    required int learning,
    required int favorite,
    required int dueSrsCount,
    required int topicCount,
    required double progressRate,
    required bool isDesktop,
  }) {
    final cards = [
      StatCard(
        title: 'Kho từ vựng CEFR',
        value: '$total',
        subtitle: '$topicCount chủ đề',
        icon: Icons.library_books_rounded,
        color: AppColors.primary,
        onTap: () => onTabChange(1),
      ),
      StatCard(
        title: 'Từ đã thuộc lòng',
        value: '$mastered',
        subtitle: '${(progressRate * 100).toInt()}%',
        icon: Icons.check_circle_rounded,
        color: AppColors.success,
        onTap: () => onTabChange(11),
      ),
      StatCard(
        title: 'Từ đang cần ôn',
        value: '$learning',
        subtitle: dueSrsCount > 0 ? '$dueSrsCount đến hạn' : 'SRS',
        icon: Icons.replay_circle_filled_rounded,
        color: AppColors.warning,
        onTap: () => onTabChange(10),
      ),
      StatCard(
        title: 'Từ vựng yêu thích',
        value: '$favorite',
        subtitle: 'Đã lưu',
        icon: Icons.favorite_rounded,
        color: AppColors.danger,
        onTap: () => onTabChange(10),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 16),
          Expanded(child: cards[1]),
          const SizedBox(width: 16),
          Expanded(child: cards[2]),
          const SizedBox(width: 16),
          Expanded(child: cards[3]),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  Widget _buildWordOfTheDaySection(
    BuildContext context, {
    required WordModel wordOfDay,
    required StudyProvider studyProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_incandescent_rounded, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Từ vựng hôm nay',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                studyProvider.loadWordOfTheDay();
              },
              icon: Icon(Icons.refresh_rounded, size: 16, color: context.primaryAccent),
              label: Text(
                'Đổi từ mới',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.primaryAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InteractiveCard(
          borderRadius: 22,
          padding: const EdgeInsets.all(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WordDetailScreen(word: wordOfDay),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tooltip(
                    message: 'Nghe phát âm chuẩn',
                    child: IconButton.filled(
                      onPressed: () => TtsService().speak(wordOfDay.term),
                      icon: const Icon(Icons.volume_up_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: context.primaryContainerCol,
                        foregroundColor: context.primaryAccent,
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
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
                            Text(
                              wordOfDay.term,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimaryColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.primaryContainerCol,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'CEFR ${wordOfDay.level}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.primaryAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (wordOfDay.partOfSpeech.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: context.scaffoldBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: context.borderCol),
                                ),
                                child: Text(
                                  wordOfDay.partOfSpeech,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.textSecondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (wordOfDay.ipa.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            wordOfDay.ipa,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textSecondaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          wordOfDay.meaning,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.primaryAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: wordOfDay.isFavorite ? 'Bỏ yêu thích' : 'Lưu vào yêu thích',
                    child: IconButton(
                      icon: Icon(
                        wordOfDay.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: wordOfDay.isFavorite ? AppColors.danger : context.textMutedColor,
                      ),
                      onPressed: () => studyProvider.toggleFavorite(wordOfDay),
                    ),
                  ),
                ],
              ),
              if (wordOfDay.englishDefinition.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  wordOfDay.englishDefinition,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
              if (wordOfDay.exampleEn.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.scaffoldBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${wordOfDay.exampleEn}"',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (wordOfDay.exampleVi.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '→ ${wordOfDay.exampleVi}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(
    BuildContext context, {
    required int topicCount,
    required int totalWords,
    required int learningWords,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(Icons.bolt_rounded, color: context.primaryAccent, size: 22),
              const SizedBox(width: 6),
              Text(
                'Lối tắt học tập',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                context,
                title: 'Chủ đề từ vựng',
                subtitle: '$topicCount chủ đề CEFR',
                icon: Icons.grid_view_rounded,
                color: AppColors.primary,
                onTap: () => onTabChange(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                context,
                title: 'Shadowing phản xạ',
                subtitle: 'Trọng âm & nối âm',
                icon: Icons.spatial_audio_off_rounded,
                color: const Color(0xFF0D9488),
                onTap: () => onTabChange(6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                context,
                title: 'Từ điển Anh - Việt',
                subtitle: 'Tra cứu $totalWords+ từ',
                icon: Icons.auto_stories_rounded,
                color: AppColors.secondary,
                onTap: () => onTabChange(7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                context,
                title: 'Từ cần ôn tập',
                subtitle: '$learningWords từ cần nhớ',
                icon: Icons.replay_rounded,
                color: AppColors.success,
                onTap: () => onTabChange(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                context,
                title: 'Luyện thi IELTS/TOEIC',
                subtitle: 'Đề bấm giờ & giải thích',
                icon: Icons.workspace_premium_rounded,
                color: const Color(0xFFE11D48),
                onTap: () => onTabChange(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                context,
                title: 'Trò chơi từ vựng',
                subtitle: 'Ghép cặp & Quiz phản xạ',
                icon: Icons.sports_esports_rounded,
                color: AppColors.warning,
                onTap: () => onTabChange(9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          title: 'Trợ lý AI English Buddy',
          subtitle: 'Giải đáp ngữ pháp, tra từ, góp ý bài viết',
          icon: Icons.smart_toy_rounded,
          color: const Color(0xFF6366F1),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiChatScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedTopicsSection(
    BuildContext context, {
    required List<TopicModel> topics,
    required bool isWide,
  }) {
    final displayedTopics = topics.take(isWide ? 4 : 3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.explore_rounded, color: context.primaryAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Khám phá chủ đề',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => onTabChange(1),
              icon: const Text('Xem tất cả'),
              label: const Icon(Icons.arrow_forward_rounded, size: 16),
              style: TextButton.styleFrom(
                foregroundColor: context.primaryAccent,
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isWide)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedTopics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 112,
            ),
            itemBuilder: (context, index) {
              return _buildTopicItemCard(context, displayedTopics[index]);
            },
          )
        else
          Column(
            children: displayedTopics
                .map(
                  (topic) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTopicItemCard(context, topic),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildTopicItemCard(BuildContext context, TopicModel topic) {
    final topicColor = UiHelpers.hexToColor(topic.colorHex);
    final iconData = UiHelpers.getIconData(topic.iconName);
    final percent = (topic.progressPercentage * 100).toInt();

    return InteractiveCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      hoverBorderColor: topicColor.withValues(alpha: 0.6),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TopicDetailScreen(topic: topic),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: topicColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: topicColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        topic.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: context.textPrimaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: topicColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${topic.masteredWords}/${topic.totalWords} từ đã thuộc',
                  style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: topic.progressPercentage,
                    minHeight: 5,
                    backgroundColor: context.borderCol,
                    valueColor: AlwaysStoppedAnimation<Color>(topicColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.textMutedColor),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InteractiveCard(
      onTap: onTap,
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      hoverBorderColor: color.withValues(alpha: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                size: 16,
                color: context.textMutedColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.textPrimaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
