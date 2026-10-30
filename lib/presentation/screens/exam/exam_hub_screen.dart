import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/exam_model.dart';
import '../../../providers/skills_provider.dart';
import '../../widgets/interactive_card.dart';
import 'exam_attempt_screen.dart';
import 'exam_result_screen.dart';

class ExamHubScreen extends StatefulWidget {
  const ExamHubScreen({super.key});

  @override
  State<ExamHubScreen> createState() => _ExamHubScreenState();
}

class _ExamHubScreenState extends State<ExamHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SkillsProvider>().loadSkillScores();
      }
    });
  }

  Color _categoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'IELTS':
        return const Color(0xFFE11D48);
      case 'TOEIC':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skillsProvider = context.watch<SkillsProvider>();
    final exams = skillsProvider.filteredExams;
    final attempts = skillsProvider.examAttempts;

    const categories = ['All', 'IELTS', 'TOEIC', 'CEFR'];
    const skills = ['All', 'Reading', 'Listening', 'Writing', 'Mini Mock Test'];

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Luyện thi IELTS • TOEIC • CEFR'),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner giới thiệu & Cam kết bản quyền nội dung
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phòng Luyện Thi Thực Chiến (Timed Practice & Mini-Tests)',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Đồng hồ đếm ngược, đánh dấu câu hỏi (🚩), khóa transcript khi làm bài nghe và giải thích chi tiết từng câu.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFE0E7FF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Bản quyền & Minh bạch: Kho đề được biên soạn gốc mô phỏng sát dạng kỹ năng học thuật/công sở (IELTS, TOEIC, CEFR). Không sao chép trái phép đề thi bản quyền của ETS hay Cambridge.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Bộ lọc Định dạng kỳ thi (IELTS / TOEIC / CEFR)
                Text(
                  'Chọn định dạng kỳ thi:',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected =
                        skillsProvider.selectedExamCategory == cat;
                    final label = cat == 'All' ? 'Tất cả định dạng' : cat;
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) =>
                          skillsProvider.setExamCategoryFilter(cat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Bộ lọc Kỹ năng
                Text(
                  'Lọc theo phần kỹ năng:',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((sk) {
                    final isSelected = skillsProvider.selectedExamSkill == sk;
                    final label = sk == 'All' ? 'Tất cả kỹ năng' : sk;
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) => skillsProvider.setExamSkillFilter(sk),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Danh sách đề luyện tập
                Text(
                  'Danh sách đề thi (${exams.length} đề)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                if (exams.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Center(
                      child: Text(
                        'Không có bộ đề nào khớp với bộ lọc hiện tại.',
                        style: TextStyle(color: context.textSecondaryColor),
                      ),
                    ),
                  )
                else
                  ...exams.map((exam) => _buildExamCard(
                        context,
                        exam: exam,
                        bestAttempt: skillsProvider.getBestExamAttempt(exam.id),
                      )),

                // Lịch sử làm đề gần đây trong SQLite
                if (attempts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Lịch sử làm đề của bạn (${attempts.length} lượt)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...attempts.take(6).map((att) {
                    final matchedExam = skillsProvider.allExams
                        .where((e) => e.id == att.examId)
                        .firstOrNull;
                    final pct = att.scorePercentage.round();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.borderCol),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: pct >= 70
                                  ? (context.isDark
                                      ? AppColors.success.withValues(alpha: 0.2)
                                      : AppColors.successLight)
                                  : context.primaryContainerCol,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$pct%',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: pct >= 70
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  att.examTitle,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${att.examCategory} • Đúng ${att.correctAnswers}/${att.totalQuestions} câu • Thời gian: ${att.durationSeconds}s',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: context.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (matchedExam != null)
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ExamResultScreen(
                                      exam: matchedExam,
                                      attempt: att,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Xem giải thích'),
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

  Widget _buildExamCard(
    BuildContext context, {
    required ExamModel exam,
    required ExamAttemptModel? bestAttempt,
  }) {
    final badgeColor = _categoryColor(exam.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InteractiveCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        onTap: () => _showStartExamSheet(context, exam),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exam.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
                if (exam.ieltsModule != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Text(
                      exam.ieltsModule!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.primaryContainerCol,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${exam.skillSection} • ${exam.level}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 15, color: context.textSecondaryColor),
                    const SizedBox(width: 4),
                    Text(
                      exam.skillSection == 'Writing'
                          ? '${exam.durationMinutes} phút • ${exam.writingTaskType ?? "Writing"}'
                          : '${exam.durationMinutes} phút • ${exam.questions.length} câu hỏi',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                if (bestAttempt != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.successLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Cao nhất: ${bestAttempt.correctAnswers}/${bestAttempt.totalQuestions} (${bestAttempt.scorePercentage.round()}%)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              exam.title,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              exam.description,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exam.attribution.source,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: context.textMutedColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      icon: const Icon(Icons.psychology_outlined, size: 16),
                      label: const Text('Luyện tập'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                      icon: const Icon(Icons.timer_outlined, size: 16),
                      label: const Text('Thi thử'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStartExamSheet(BuildContext context, ExamModel exam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderCol,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              exam.title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${exam.category} • ${exam.skillSection} • ${exam.questions.length} câu hỏi • ${exam.durationMinutes} phút',
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: context.borderCol),
              ),
              tileColor: context.scaffoldBg,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.timer_outlined, color: AppColors.primary),
              ),
              title: const Text(
                'Thi thử tính giờ (Exam Mode)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              subtitle: Text(
                'Đồng hồ đếm ngược ${exam.durationMinutes} phút, tự động nộp bài khi hết giờ, có bảng điểm và giải thích sau khi hoàn thành.',
                style:
                    TextStyle(fontSize: 12, color: context.textSecondaryColor),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(ctx);
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
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: context.borderCol),
              ),
              tileColor: context.scaffoldBg,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology_outlined,
                    color: AppColors.success),
              ),
              title: const Text(
                'Luyện tập tự do (Practice Mode)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              subtitle: Text(
                'Không giới hạn thời gian, có thể xem ngay gợi ý & đáp án giải thích chi tiết trong lúc làm từng câu.',
                style:
                    TextStyle(fontSize: 12, color: context.textSecondaryColor),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(ctx);
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
            ),
          ],
        ),
      ),
    );
  }
}
