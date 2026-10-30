import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/exam_model.dart';
import '../../../data/models/skill_exercise_model.dart';
import '../../../data/models/word_model.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/custom_button.dart';
import 'exam_attempt_screen.dart';

class ExamResultScreen extends StatefulWidget {
  final ExamModel exam;
  final ExamAttemptModel attempt;
  final IeltsWritingEvaluation? writingEvaluation;

  const ExamResultScreen({
    super.key,
    required this.exam,
    required this.attempt,
    this.writingEvaluation,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  final Set<String> _savedWords = {};
  bool _showTranscript = false;

  @override
  void dispose() {
    TtsService().stop();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _saveKeyWord(LessonKeyWord kw) async {
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);
    final topicId =
        studyProvider.topics.isNotEmpty ? studyProvider.topics.first.id : 1;

    final newWord = WordModel(
      id: 0,
      topicId: topicId,
      term: kw.term,
      ipa: kw.ipa.isNotEmpty ? kw.ipa : '/.../',
      partOfSpeech: kw.partOfSpeech,
      meaning: kw.meaning,
      englishDefinition:
          'Exam vocabulary (${widget.exam.category}): ${widget.exam.title}',
      exampleEn: kw.example.isNotEmpty ? kw.example : kw.term,
      exampleVi: kw.meaning,
      level: widget.exam.level.split('-').last,
      status: AppConstants.statusLearning,
      isFavorite: true,
    );

    await studyProvider.addNewWord(newWord);
    if (mounted) {
      setState(() => _savedWords.add(kw.term));
      UiHelpers.showSnackBar(
        context,
        message: 'Đã lưu "${kw.term}" vào danh sách Ôn tập & Yêu thích!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;
    final attempt = widget.attempt;
    final pct = attempt.scorePercentage.round();
    final isHigh = pct >= 70;
    final isIelts = exam.category == 'IELTS';
    final isWriting = exam.skillSection == 'Writing';

    double? estimatedBand;
    if (isIelts) {
      if (isWriting) {
        estimatedBand = widget.writingEvaluation?.overallBand ??
            (attempt.userAnswers['overallBand'] as num?)?.toDouble() ??
            6.0;
      } else {
        estimatedBand = ExamModel.calculateEstimatedIeltsBand(
          attempt.correctAnswers,
          attempt.totalQuestions,
          isGeneralReading: exam.ieltsModule == 'General Training',
        );
      }
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Kết quả & Giải thích chi tiết'),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thẻ tổng kết điểm số & IELTS Band Score
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isHigh ? AppColors.success : AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.primaryContainerCol,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${exam.category} • ${exam.skillSection}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (exam.ieltsModule != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(8),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.scaffoldBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.borderCol),
                            ),
                            child: Text(
                              'Thời gian làm bài: ${_formatDuration(attempt.durationSeconds)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        exam.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (estimatedBand != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'IELTS BAND',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    estimatedBand.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const Text(
                                    'Ước tính',
                                    style: TextStyle(
                                      color: Color(0xFFE0E7FF),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isHigh
                                    ? (context.isDark
                                        ? AppColors.success.withValues(alpha: 0.2)
                                        : AppColors.successLight)
                                    : context.primaryContainerCol,
                                border: Border.all(
                                  color: isHigh ? AppColors.success : AppColors.primary,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$pct%',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: isHigh ? AppColors.success : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isWriting
                                      ? 'Đánh giá năng lực bài viết (${exam.writingTaskType ?? "Writing"})'
                                      : 'Số câu đúng: ${attempt.correctAnswers}/${attempt.totalQuestions} câu ($pct%)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  attempt.competencyFeedback,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: context.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.scaffoldBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_outlined,
                                size: 17, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Lưu ý minh bạch: Điểm Band quy đổi ước tính dựa trên tỷ lệ câu trả lời đúng theo thang 40 câu IELTS và thuật toán phân tích 4 tiêu chí chuẩn. Không tuyên bố là kết quả khảo thí chính thức của IDP / British Council.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ==========================================
                // KHU VỰC CHI TIẾT CHO BÀI WRITING
                // ==========================================
                if (isWriting) ...[
                  _buildWritingDetailedReport(context),
                  const SizedBox(height: 20),
                ] else ...[
                  // ==========================================
                  // KHU VỰC CHO READING / LISTENING
                  // ==========================================
                  // Xem lại Văn bản / Transcript đã mở khóa
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              exam.hasAudioScript
                                  ? 'Transcript bài nghe & Bản dịch'
                                  : 'Nội dung bài đọc & Bản dịch',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimaryColor,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  tooltip: 'Nghe nội dung',
                                  onPressed: () =>
                                      TtsService().speak(exam.passageOrScript),
                                  icon: const Icon(Icons.volume_up_rounded,
                                      color: AppColors.primary),
                                ),
                                TextButton(
                                  onPressed: () => setState(
                                      () => _showTranscript = !_showTranscript),
                                  child: Text(_showTranscript ? 'Thu gọn' : 'Mở rộng'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_showTranscript) ...[
                          const SizedBox(height: 8),
                          SelectableText(
                            exam.passageOrScript,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.55,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            exam.transcriptVi,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              fontStyle: FontStyle.italic,
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chi tiết từng câu hỏi & Giải thích
                  Text(
                    'Chi tiết đáp án & Giải thích (${exam.questions.length} câu)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...exam.questions.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final q = entry.value;
                    final rawAns = attempt.userAnswers[q.id];
                    final isCorrect = q.isCorrectAnswer(rawAns);

                    String userAnswerDisplay = 'Chưa trả lời';
                    if (rawAns != null) {
                      if (q.isFillBlank) {
                        userAnswerDisplay = rawAns.toString();
                      } else {
                        final optIdx = int.tryParse(rawAns.toString());
                        if (optIdx != null &&
                            optIdx >= 0 &&
                            optIdx < q.options.length) {
                          userAnswerDisplay = q.options[optIdx];
                        }
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCorrect ? AppColors.success : AppColors.danger,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCorrect
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: isCorrect ? AppColors.success : AppColors.danger,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: context.primaryContainerCol,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  q.targetSkill,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              if (q.paragraphRef != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    q.paragraphRef!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  q.sectionTitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.textSecondaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Câu ${idx + 1}: ${q.questionText}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Câu trả lời của bạn: $userAnswerDisplay',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: isCorrect ? AppColors.success : AppColors.danger,
                            ),
                          ),
                          if (!isCorrect) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Đáp án đúng: ${q.correctAnswerDisplay}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                          if (q.evidenceQuote != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: context.primaryContainerCol,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.format_quote_rounded,
                                      size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Chứng cứ từ bài: "${q.evidenceQuote}"',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.scaffoldBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Giải thích: ${q.explanation}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // Từ vựng trọng tâm cần ôn trong đề thi
                if (exam.keyWords.isNotEmpty) ...[
                  const SizedBox(height: 10),
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
                        Text(
                          'Từ vựng học thuật / công sở cần lưu ý (${exam.keyWords.length} từ)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...exam.keyWords.map((kw) {
                          final isSaved = _savedWords.contains(kw.term);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: IconButton(
                              icon: const Icon(Icons.volume_up_rounded,
                                  color: AppColors.primary),
                              onPressed: () => TtsService().speak(kw.term),
                            ),
                            title: Text(
                              '${kw.term} (${kw.partOfSpeech}) ${kw.ipa}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.textPrimaryColor,
                              ),
                            ),
                            subtitle: Text(
                              '${kw.meaning}\nVD: ${kw.example}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.textSecondaryColor,
                              ),
                            ),
                            trailing: TextButton.icon(
                              onPressed: isSaved ? null : () => _saveKeyWord(kw),
                              icon: Icon(
                                isSaved
                                    ? Icons.check_circle_rounded
                                    : Icons.bookmark_add_outlined,
                                size: 16,
                              ),
                              label: Text(isSaved ? 'Đã lưu' : 'Lưu từ'),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Quay về Kho đề thi',
                        isOutlined: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Làm lại đề này',
                        icon: Icons.refresh_rounded,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExamAttemptScreen(exam: exam),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Báo cáo chi tiết 4 tiêu chí Writing IELTS
  Widget _buildWritingDetailedReport(BuildContext context) {
    final answers = widget.attempt.userAnswers;
    final ta = (answers['taskAchievement'] as num?)?.toDouble() ?? 6.0;
    final cc = (answers['coherence'] as num?)?.toDouble() ?? 6.0;
    final lr = (answers['lexical'] as num?)?.toDouble() ?? 6.0;
    final gr = (answers['grammar'] as num?)?.toDouble() ?? 6.0;
    final wordCount = (answers['wordCount'] as num?)?.toInt() ?? 0;
    final userSubmission = answers['submission']?.toString() ?? '';
    final linkingWords = (answers['linkingWords'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final academicWords = (answers['academicWords'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final strengths = (answers['strengths'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final improvements = (answers['improvements'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bảng 4 tiêu chí chuẩn IELTS
        Text(
          'Đánh giá theo 4 tiêu chí chuẩn IELTS Writing',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildCriteriaCard(context, 'Task Achievement', ta, Icons.assignment_turned_in_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _buildCriteriaCard(context, 'Coherence & Cohesion', cc, Icons.alt_route_rounded)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildCriteriaCard(context, 'Lexical Resource', lr, Icons.spellcheck_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _buildCriteriaCard(context, 'Grammatical Range', gr, Icons.rule_rounded)),
          ],
        ),
        const SizedBox(height: 16),

        // Thống kê từ nối & Từ học thuật
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
              Text(
                'Phân tích Ngôn ngữ & Độ mạch lạc (Vocabulary & Cohesion)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '• Từ nối học thuật phát hiện được (${linkingWords.length} từ):',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: linkingWords.isNotEmpty
                    ? linkingWords.map((lw) => Chip(
                        label: Text(lw, style: const TextStyle(fontSize: 12)),
                        backgroundColor: context.primaryContainerCol,
                      )).toList()
                    : [const Text('Chưa phát hiện từ nối tiêu biểu. Hãy bổ sung thêm trong bài sau.', style: TextStyle(fontSize: 12.5, color: Colors.grey))],
              ),
              const SizedBox(height: 10),
              Text(
                '• Từ vựng học thuật ghi điểm (${academicWords.length} từ):',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: academicWords.isNotEmpty
                    ? academicWords.map((aw) => Chip(
                        label: Text(aw, style: const TextStyle(fontSize: 12, color: AppColors.success)),
                        backgroundColor: AppColors.success.withValues(alpha: 0.12),
                      )).toList()
                    : [const Text('Nên sử dụng thêm các từ vựng học thuật trang trọng (C1/B2).', style: TextStyle(fontSize: 12.5, color: Colors.grey))],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Điểm mạnh & Điểm cần cải thiện
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
              const Row(
                children: [
                  Icon(Icons.thumb_up_alt_rounded, color: AppColors.success, size: 18),
                  SizedBox(width: 8),
                  Text('Điểm mạnh ghi nhận:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 6),
              ...strengths.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $s', style: TextStyle(fontSize: 13, color: context.textPrimaryColor)),
                  )),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded, color: AppColors.warning, size: 18),
                  SizedBox(width: 8),
                  Text('Cần cải thiện cho lần viết sau:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 6),
              ...improvements.map((im) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $im', style: TextStyle(fontSize: 13, color: context.textSecondaryColor)),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bài làm của thí sinh
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bài viết của bạn ($wordCount từ):',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SelectableText(
                userSubmission.isNotEmpty ? userSubmission : '(Không có nội dung)',
                style: TextStyle(fontSize: 14, height: 1.6, color: context.textPrimaryColor),
              ),
            ],
          ),
        ),

        // Bài mẫu Band 8.5 & Nhận xét của giám khảo
        if (widget.exam.sampleResponseBand8 != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Bài viết mẫu tham khảo (Band 8.5+ Sample)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  widget.exam.sampleResponseBand8!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    color: context.textPrimaryColor,
                  ),
                ),
                if (widget.exam.examinerNotes != null) ...[
                  const Divider(height: 24),
                  Text(
                    'Nhận xét của Giám khảo khảo thí:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.exam.examinerNotes!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCriteriaCard(BuildContext context, String title, double score, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
