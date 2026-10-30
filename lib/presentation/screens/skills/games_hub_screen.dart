import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/games_provider.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/interactive_card.dart';
import '../games/vocabulary_arena_screen.dart';
import '../games/word_rain_screen.dart';
import '../games/space_typer_screen.dart';

class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key});

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> {
  int _selectedTopicId = 0; // 0 = Tất cả chủ đề
  String _selectedLevel = 'All'; // 'All', 'A1', 'A2', 'B1', 'B2', 'C1'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GamesProvider>().loadHighScoresAndHistory();
      }
    });
  }

  Future<void> _launchGame(String gameKey) async {
    final gamesProvider = context.read<GamesProvider>();
    final studyProvider = context.read<StudyProvider>();

    // Lấy từ vựng theo bộ lọc chủ đề và cấp độ CEFR đã chọn
    final words = await gamesProvider.getFilteredWords(
      topicId: _selectedTopicId > 0 ? _selectedTopicId : null,
      level: _selectedLevel,
    );

    if (!mounted) return;

    if (words.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Chủ đề hoặc cấp độ này chưa đủ từ vựng để tạo trận đấu. Vui lòng chọn "Tất cả" hoặc chủ đề khác.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    String topicName = 'Tất cả chủ đề';
    if (_selectedTopicId > 0) {
      final found = studyProvider.topics.where((t) => t.id == _selectedTopicId).firstOrNull;
      if (found != null) topicName = found.name;
    }

    Widget screen;
    switch (gameKey) {
      case 'space_typer':
        screen = SpaceTyperScreen(
          words: words,
          topicId: _selectedTopicId > 0 ? _selectedTopicId : null,
          topicName: topicName,
          level: _selectedLevel,
        );
        break;
      case 'arena':
        screen = VocabularyArenaScreen(
          words: words,
          topicId: _selectedTopicId > 0 ? _selectedTopicId : null,
          topicName: topicName,
          level: _selectedLevel,
        );
        break;
      case 'rain':
        screen = WordRainScreen(
          words: words,
          topicId: _selectedTopicId > 0 ? _selectedTopicId : null,
          topicName: topicName,
          level: _selectedLevel,
        );
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showGameGuide(String gameKey) {
    String title = '';
    IconData icon = Icons.info_outline_rounded;
    Color color = AppColors.primary;
    List<String> rules = [];

    switch (gameKey) {
      case 'space_typer':
        title = 'Chiến Cơ Vũ Trụ (Space Typer)';
        icon = Icons.rocket_launch_rounded;
        color = const Color(0xFF38BDF8);
        rules = [
          '🎯 Mục tiêu: Gõ chính xác từng ký tự của từ hoặc chữ cái đang rơi.',
          '🎚️ 3 Cấp độ khó: Dễ (từ ngắn, rơi chậm), Trung bình (từ vừa, rơi nhanh), Khó (từ dài, dồn dập).',
          '🚀 Tàu tự động căn hàng: Chiến cơ tự động lướt ngang bên dưới từ đang gõ.',
          '⚡ Bắn laze tức thì: Mỗi phím đúng lập tức khai hỏa đạn laze, không cần phím cách (SPACE).',
          '🛡️ Phòng tuyến & Khiên: Khiên tự sạc hấp thụ va chạm khi thiên thạch chạm đáy.',
          '📡 Radar Mini-Map: Quan sát vị trí tương quan của mục tiêu và chiến cơ.',
        ];
        break;
      case 'arena':
        title = 'Đấu trường từ vựng (Vocabulary Arena)';
        icon = Icons.sports_kabaddi_rounded;
        color = AppColors.primary;
        rules = [
          '🎯 Mục tiêu: Trả lời đúng trắc nghiệm 15 câu từ vựng.',
          '🎚️ 3 Cấp độ khó: Dễ (15 giây, từ A1-A2 ngắn), Trung bình (10 giây, B1-B2), Khó (7 giây, B2-C1 dài).',
          '🔥 Combo: Trả lời đúng liên tiếp nhân đôi, nhân ba điểm số.',
          '❤️ Lượt chơi: Có 3 trái tim. Sai hoặc hết giờ bị trừ 1 tim.',
          '⌨️ Phím tắt: Hỗ trợ phím số 1, 2, 3, 4 trên máy tính.',
        ];
        break;
      case 'rain':
        title = 'Mưa Từ Vựng (Vocabulary Rain)';
        icon = Icons.water_drop_rounded;
        color = const Color(0xFF06B6D4);
        rules = [
          '🎯 Mục tiêu: Xem nghĩa tiếng Việt ở trên, chạm vào giọt mưa tiếng Anh tương ứng.',
          '🎚️ 3 Cấp độ khó: Dễ (rơi thong thả, từ ngắn), Vừa (tốc độ chuẩn), Khó (rơi nhanh, từ dài).',
          '💧 Hồ nước: Đừng để giọt mục tiêu chìm xuống hồ nước ở đáy.',
          '❤️ Lượt chơi: Bấm nhầm hoặc để chìm mất 1 tim (có 3 tim).',
          '🔊 Âm thanh: Phát âm chuẩn xác tự động mỗi khi bắt trúng giọt mưa.',
        ];
        break;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rules
              .map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(r, style: const TextStyle(fontSize: 13.5, height: 1.4)),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _launchGame(gameKey);
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: const Text('Bắt đầu chơi ngay', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();
    final gamesProvider = context.watch<GamesProvider>();
    final topics = studyProvider.topics;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Trung tâm Trò chơi Từ vựng (Mini Games)'),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1060),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Khung giới thiệu & Bộ lọc chuẩn bị
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.14),
                        AppColors.secondary.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Đấu trường Game Từ vựng English Buddy',
                                        style: TextStyle(
                                          fontSize: 17.5,
                                          fontWeight: FontWeight.w800,
                                          color: context.textPrimaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                                      ),
                                      child: const Text(
                                        '3.000+ từ vựng A1-C1',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Học từ vựng qua phản xạ tốc độ cao, gõ phím phi thuyền, bắt giọt mưa và nghe chính tả âm thanh thực tế.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Bộ lọc Chủ đề
                      Text(
                        '1. Chọn chủ đề từ vựng:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: context.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Tất cả 8 chủ đề (3.000+ từ)'),
                            selected: _selectedTopicId == 0,
                            onSelected: (_) => setState(() => _selectedTopicId = 0),
                          ),
                          ...topics.map((t) {
                            return ChoiceChip(
                              label: Text(t.name),
                              selected: _selectedTopicId == t.id,
                              onSelected: (_) => setState(() => _selectedTopicId = t.id),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Bộ lọc Cấp độ CEFR
                      Text(
                        '2. Chọn cấp độ mục tiêu:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: context.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['All', 'A1', 'A2', 'B1', 'B2', 'C1'].map((lvl) {
                          return ChoiceChip(
                            label: Text(lvl == 'All' ? 'Tất cả cấp độ' : lvl),
                            selected: _selectedLevel == lvl,
                            onSelected: (_) => setState(() => _selectedLevel = lvl),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Banner đặc biệt: Chiến Cơ Vũ Trụ (Space Speed Typer)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0A0C20),
                        Color(0xFF0E1630),
                        Color(0xFF1E293B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.22),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF38BDF8)),
                            ),
                            child: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF38BDF8), size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Flexible(
                                      child: Text(
                                        '🚀 Chiến Cơ Vũ Trụ (Space Typer)',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFC828).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFFFC828)),
                                      ),
                                      child: const Text(
                                        'MỚI',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFFFC828),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Cảm hứng đồ họa & cơ chế Pygame Space Exploration: Tàu tự lướt ngang căn hàng, đạn laze bắn theo phím, radar phòng thủ và sao vũ trụ 3 lớp.',
                                  style: TextStyle(fontSize: 12.5, color: Color(0xFFCBD5E1), height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildCustomTag('Tàu tự căn hàng', const Color(0xFF38BDF8)),
                          _buildCustomTag('Bắn laze theo phím', const Color(0xFF10B981)),
                          _buildCustomTag('Radar Mini-map', const Color(0xFFAA6EFF)),
                          _buildCustomTag('Khiên & Phòng tuyến', const Color(0xFFFFC828)),
                          if (gamesProvider.spaceHighScore > 0)
                            _buildCustomTag('Kỷ lục: ${gamesProvider.spaceHighScore} đ', const Color(0xFFFFC828)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _showGameGuide('space_typer'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF38BDF8),
                              side: const BorderSide(color: Color(0xFF38BDF8)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            icon: const Icon(Icons.help_outline_rounded, size: 16),
                            label: const Text('Luật chơi'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () => _launchGame('space_typer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF38BDF8),
                              foregroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                              elevation: 4,
                            ),
                            icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                            label: const Text(
                              'Khởi hành vũ trụ',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Danh sách 3 Trò chơi Từ vựng
                Text(
                  'Chọn 1 trong 3 trò chơi để bắt đầu:',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 14),

                // Game 1: Chiến Cơ Vũ Trụ
                _buildGameCard(
                  context,
                  gameKey: 'space_typer',
                  title: '1. Chiến Cơ Vũ Trụ (Space Typer)',
                  subtitle:
                      'Gõ chữ cái/từ vựng phá hủy thiên thạch vũ trụ. Tàu tự động lướt ngang căn hàng, đạn laze bắn theo từng phím, radar phòng thủ và 3 cấp độ Dễ - Trung bình - Khó.',
                  icon: Icons.rocket_launch_rounded,
                  accentColor: const Color(0xFF38BDF8),
                  highScore: gamesProvider.spaceHighScore,
                  tags: ['Gõ phím chiến cơ', 'Tàu tự căn hàng', '3 cấp độ Dễ-Khó', 'Radar phòng thủ'],
                  onPlay: () => _launchGame('space_typer'),
                ),
                const SizedBox(height: 14),

                // Game 2: Đấu trường từ vựng
                _buildGameCard(
                  context,
                  gameKey: 'arena',
                  title: '2. Đấu trường từ vựng (Vocabulary Arena)',
                  subtitle:
                      'Trắc nghiệm phản xạ 7-15s theo cấp độ Dễ/Trung bình/Khó, chuỗi combo điểm số cao, lọc từ ngắn đến dài và hỗ trợ phím tắt 1-4 trên máy tính.',
                  icon: Icons.sports_kabaddi_rounded,
                  accentColor: AppColors.primary,
                  highScore: gamesProvider.arenaHighScore,
                  tags: ['Phản xạ 7-15s', 'Combo x2-x5', '3 cấp độ Dễ-Khó', 'Hỗ trợ phím 1-4'],
                  onPlay: () => _launchGame('arena'),
                ),
                const SizedBox(height: 14),

                // Game 3: Mưa Từ Vựng
                _buildGameCard(
                  context,
                  gameKey: 'rain',
                  title: '3. Mưa Từ Vựng (Vocabulary Rain)',
                  subtitle:
                      'Xem nghĩa tiếng Việt ở khung trung tâm, nhanh tay bắt các giọt mưa tiếng Anh đang rơi trước khi chìm xuống hồ nước đáy với 3 mức độ khó linh hoạt.',
                  icon: Icons.water_drop_rounded,
                  accentColor: const Color(0xFF06B6D4),
                  highScore: gamesProvider.rainHighScore,
                  tags: ['Hiệu ứng sóng nước', '3 cấp độ Dễ-Khó', 'Tương tác chạm/click', 'Phát âm tự động'],
                  onPlay: () => _launchGame('rain'),
                ),
                const SizedBox(height: 28),

                // Lịch sử lượt chơi gần đây
                if (gamesProvider.recentHistory.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lịch sử đấu game gần đây (${gamesProvider.recentHistory.length} lượt)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      Text(
                        'Tổng đã chơi: ${gamesProvider.totalGamesPlayed} trận',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...gamesProvider.recentHistory.take(6).map((record) {
                    final pct = record.accuracy.round();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.borderCol),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.primaryContainerCol,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${record.score} đ',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.gameTitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimaryColor,
                                  ),
                                ),
                                Text(
                                  '${record.topicName} (${record.level}) • Đúng ${record.correctItems}/${record.totalItems} ($pct%) • Chuỗi: ${record.highStreak}',
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
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String gameKey,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required int highScore,
    required List<String> tags,
    required VoidCallback onPlay,
  }) {
    return InteractiveCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      hoverBorderColor: accentColor.withValues(alpha: 0.6),
      onTap: onPlay,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isNarrow = constraints.maxWidth < 520;

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, color: accentColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                            ),
                            if (highScore > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Kỷ lục: $highScore đ',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: tags.map((t) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.scaffoldBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: context.borderCol),
                              ),
                              child: Text(
                                t,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  if (!isNarrow) ...[
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: onPlay,
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: const Text('Chơi ngay'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          onPressed: () => _showGameGuide(gameKey),
                          icon: const Icon(Icons.help_outline_rounded, size: 15),
                          label: const Text('Luật chơi', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              if (isNarrow) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _showGameGuide(gameKey),
                        icon: const Icon(Icons.help_outline_rounded, size: 16),
                        label: const Text('Xem luật chơi'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPlay,
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text('Chơi ngay'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
