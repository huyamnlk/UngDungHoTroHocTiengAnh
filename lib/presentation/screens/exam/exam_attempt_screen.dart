import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/tts_service.dart';
import '../../../data/models/exam_model.dart';
import '../../../providers/skills_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/ielts_chart_widget.dart';
import 'exam_result_screen.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';

class ExamAttemptScreen extends StatefulWidget {
  final ExamModel exam;
  final bool isPracticeMode;

  const ExamAttemptScreen({
    super.key,
    required this.exam,
    this.isPracticeMode = false,
  });

  @override
  State<ExamAttemptScreen> createState() => _ExamAttemptScreenState();
}

class _ExamAttemptScreenState extends State<ExamAttemptScreen>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  late int _totalDurationSeconds;
  int _elapsedSeconds = 0;
  Timer? _countdownTimer;

  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _userAnswers = {}; // questionId -> int or String
  final Map<String, TextEditingController> _fillControllers = {};
  final Set<String> _flaggedQuestionIds = {};
  final Set<String> _revealedExplanations = {};

  // Audio Player State cho Listening
  bool _isPlayingAudio = false;
  bool _isSlowAudio = false;
  int _selectedAudioSection = 1;

  // Writing Exam State
  late final TextEditingController _writingController;
  int _writingWordCount = 0;

  // Mobile Tab cho Reading (0: Bài đọc, 1: Câu hỏi)
  int _mobileReadingTabIndex = 0;

  bool _isSubmitting = false;

  bool get _isWritingExam => widget.exam.skillSection == 'Writing';
  bool get _isReadingExam => widget.exam.skillSection == 'Reading';
  bool get _isListeningExam => widget.exam.skillSection == 'Listening';

  int get _writingTargetWords {
    if (widget.exam.writingTaskType == 'Task 2') return 250;
    return 150;
  }

  @override
  void initState() {
    super.initState();
    _totalDurationSeconds = widget.exam.durationMinutes * 60;
    _remainingSeconds = _totalDurationSeconds;

    _writingController = TextEditingController();
    _writingController.addListener(_onWritingTextChanged);

    for (final q in widget.exam.questions) {
      if (q.isFillBlank) {
        final ctrl = TextEditingController();
        ctrl.addListener(() {
          final val = ctrl.text.trim();
          setState(() {
            if (val.isEmpty) {
              _userAnswers.remove(q.id);
            } else {
              _userAnswers[q.id] = val;
            }
          });
        });
        _fillControllers[q.id] = ctrl;
      }
    }

    if (widget.isPracticeMode) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() => _elapsedSeconds++);
      });
    } else {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          timer.cancel();
          _finalizeExamAttempt(autoSubmitted: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    TtsService().stop();
    _writingController.removeListener(_onWritingTextChanged);
    _writingController.dispose();
    for (final c in _fillControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onWritingTextChanged() {
    final text = _writingController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    if (_writingWordCount != words) {
      setState(() {
        _writingWordCount = words;
      });
    }
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleAudio({bool slow = false, String? customText}) async {
    final textToSpeak = customText ?? _getSectionText(_selectedAudioSection);
    if (_isPlayingAudio && _isSlowAudio == slow) {
      await TtsService().stop();
      if (mounted) setState(() => _isPlayingAudio = false);
      return;
    }
    setState(() {
      _isPlayingAudio = true;
      _isSlowAudio = slow;
    });
    await TtsService().speak(textToSpeak, slow: slow);
    if (mounted) setState(() => _isPlayingAudio = false);
  }

  String _getSectionText(int sectionNumber) {
    final fullScript = widget.exam.passageOrScript;
    final sectionTag = '[SECTION $sectionNumber';
    final nextSectionTag = '[SECTION ${sectionNumber + 1}';

    if (fullScript.contains(sectionTag)) {
      final startIndex = fullScript.indexOf(sectionTag);
      if (fullScript.contains(nextSectionTag)) {
        final endIndex = fullScript.indexOf(nextSectionTag);
        return fullScript.substring(startIndex, endIndex).trim();
      }
      return fullScript.substring(startIndex).trim();
    }
    return fullScript;
  }

  void _confirmSubmitDialog() {
    if (_isWritingExam) {
      final target = _writingTargetWords;
      final current = _writingWordCount;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Xác nhận nộp bài viết IELTS?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Số từ hiện tại: $current / tối thiểu $target từ'),
              if (current < target)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '⚠️ Bài viết còn thiếu ${target - current} từ so với yêu cầu. Viết dưới số từ quy định có thể bị trừ điểm tiêu chí Task Achievement/Response.',
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Viết tiếp'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _finalizeExamAttempt();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Nộp bài ngay'),
            ),
          ],
        ),
      );
      return;
    }

    final total = widget.exam.questions.length;
    final answered = _userAnswers.length;
    final unanswered = total - answered;
    final flagged = _flaggedQuestionIds.length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.l10n.examSubmitConfirm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Đã trả lời: $answered / $total câu'),
            if (unanswered > 0)
              Text(
                '• Chưa trả lời: $unanswered câu',
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (flagged > 0)
              Text(
                '• Đang đánh dấu xem lại (🚩): $flagged câu',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Làm tiếp'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _finalizeExamAttempt();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Nộp bài ngay'),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizeExamAttempt({bool autoSubmitted = false}) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _countdownTimer?.cancel();
    await TtsService().stop();

    final exam = widget.exam;
    final durationUsed = widget.isPracticeMode
        ? _elapsedSeconds
        : (_totalDurationSeconds - _remainingSeconds);

    if (_isWritingExam) {
      final userText = _writingController.text.trim();
      final eval = IeltsWritingEvaluation.analyze(userText, minWords: _writingTargetWords);

      final attempt = ExamAttemptModel(
        examId: exam.id,
        examTitle: exam.title,
        examCategory: exam.category,
        skillSection: exam.skillSection,
        totalQuestions: 1,
        correctAnswers: eval.wordCount >= _writingTargetWords ? 1 : 0,
        scorePercentage: (eval.overallBand / 9.0) * 100,
        durationSeconds: durationUsed,
        userAnswers: {
          'submission': userText,
          'overallBand': eval.overallBand,
          'taskAchievement': eval.taskAchievementScore,
          'coherence': eval.coherenceScore,
          'lexical': eval.lexicalScore,
          'grammar': eval.grammarScore,
          'wordCount': eval.wordCount,
          'linkingWords': eval.detectedLinkingWords,
          'academicWords': eval.academicVocabulary,
          'strengths': eval.strengths,
          'improvements': eval.improvements,
        },
        completedAt: DateTime.now().toIso8601String(),
      );

      final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
      await skillsProvider.recordExamAttempt(attempt);
      await skillsProvider.saveScore(
        skillType: 'Writing',
        exerciseId: exam.id,
        title: exam.title,
        score: eval.overallBand * 10,
        userSubmission: userText,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExamResultScreen(
              exam: exam,
              attempt: attempt,
              writingEvaluation: eval,
            ),
          ),
        );
      }
      return;
    }

    // Xử lý nộp bài cho Reading / Listening / CEFR
    final questions = exam.questions;
    int correctCount = 0;

    for (final q in questions) {
      final ans = _userAnswers[q.id];
      if (q.isCorrectAnswer(ans)) {
        correctCount++;
      }
    }

    final total = questions.isNotEmpty ? questions.length : 1;
    final percentage = (correctCount / total) * 100.0;

    final attempt = ExamAttemptModel(
      examId: exam.id,
      examTitle: exam.title,
      examCategory: exam.category,
      skillSection: exam.skillSection,
      totalQuestions: questions.length,
      correctAnswers: correctCount,
      scorePercentage: percentage,
      durationSeconds: durationUsed,
      userAnswers: Map<String, dynamic>.from(_userAnswers),
      completedAt: DateTime.now().toIso8601String(),
    );

    final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
    await skillsProvider.recordExamAttempt(attempt);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ExamResultScreen(
            exam: widget.exam,
            attempt: attempt,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;
    final questions = exam.questions;
    final isLowTime = !widget.isPracticeMode && _remainingSeconds <= 60;
    final progress = _isWritingExam
        ? (_writingWordCount / _writingTargetWords).clamp(0.0, 1.0)
        : (questions.isNotEmpty ? _userAnswers.length / questions.length : 0.0);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.isPracticeMode
                  ? 'Chế độ Luyện tập tự do'
                  : 'Chế độ Thi tính giờ (${exam.category} • ${exam.skillSection})',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: widget.isPracticeMode ? AppColors.success : AppColors.primary,
              ),
            ),
          ],
        ),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isPracticeMode
                  ? (context.isDark
                      ? AppColors.success.withValues(alpha: 0.16)
                      : AppColors.successLight)
                  : (isLowTime
                      ? AppColors.danger.withValues(alpha: 0.16)
                      : context.primaryContainerCol),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.isPracticeMode
                    ? AppColors.success
                    : (isLowTime ? AppColors.danger : AppColors.primary),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isPracticeMode ? Icons.psychology_outlined : Icons.timer_outlined,
                  size: 16,
                  color: widget.isPracticeMode
                      ? AppColors.success
                      : (isLowTime ? AppColors.danger : AppColors.primary),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.isPracticeMode
                      ? _formatTimer(_elapsedSeconds)
                      : _formatTimer(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: widget.isPracticeMode
                        ? AppColors.success
                        : (isLowTime ? AppColors.danger : AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: _confirmSubmitDialog,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text(
                'Nộp bài',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: context.borderCol,
            color: _isWritingExam
                ? (_writingWordCount >= _writingTargetWords ? AppColors.success : AppColors.primary)
                : AppColors.primary,
          ),
          if (!_isWritingExam) _buildQuestionPalette(context, questions),
          Expanded(
            child: _isWritingExam
                ? _buildWritingBody(context)
                : (_isReadingExam
                    ? _buildReadingResponsiveBody(context)
                    : _buildStandardOrListeningBody(context)),
          ),
        ],
      ),
    );
  }

  // Question Palette điều hướng câu hỏi
  Widget _buildQuestionPalette(BuildContext context, List<ExamQuestion> questions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(bottom: BorderSide(color: context.borderCol)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'Đã làm ${_userAnswers.length}/${questions.length}: ',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(width: 8),
            ...questions.asMap().entries.map((entry) {
              final idx = entry.key;
              final q = entry.value;
              final isCurrent = idx == _currentQuestionIndex;
              final isAnswered = _userAnswers.containsKey(q.id);
              final isQFlagged = _flaggedQuestionIds.contains(q.id);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _currentQuestionIndex = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : (isAnswered ? context.primaryContainerCol : context.scaffoldBg),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isQFlagged
                            ? AppColors.warning
                            : (isCurrent || isAnswered ? AppColors.primary : context.borderCol),
                        width: isCurrent || isQFlagged ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${idx + 1}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? Colors.white
                                : (isAnswered ? AppColors.primary : context.textPrimaryColor),
                          ),
                        ),
                        if (isQFlagged) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.flag_rounded,
                            size: 13,
                            color: isCurrent ? Colors.white : AppColors.warning,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // GIAO DIỆN WRITING EXAM
  // ==========================================
  Widget _buildWritingBody(BuildContext context) {
    final exam = widget.exam;
    final target = _writingTargetWords;
    final isTargetReached = _writingWordCount >= target;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thông tin Đề bài
              Container(
                padding: const EdgeInsets.all(20),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            exam.writingTaskType ?? 'IELTS Writing',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Mục tiêu: Tối thiểu $target từ • Khuyến nghị ${exam.durationMinutes} phút',
                          style: TextStyle(fontSize: 12.5, color: context.textSecondaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      exam.passageOrScript,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.55,
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Biểu đồ dữ liệu (nếu có cho Task 1 Academic)
              if (exam.chartType != null && exam.chartType != 'none' && exam.chartData != null) ...[
                IeltsChartWidget(
                  title: exam.chartData!['title']?.toString() ?? 'Dữ liệu biểu đồ',
                  chartType: exam.chartType!,
                  data: exam.chartData!,
                ),
                const SizedBox(height: 18),
              ],

              // Thanh đếm từ & Thanh tiến độ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.borderCol),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isTargetReached ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                          color: isTargetReached ? AppColors.success : AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Số từ: $_writingWordCount / tối thiểu $target từ',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isTargetReached ? AppColors.success : context.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isTargetReached
                          ? 'Đã đủ số từ quy định'
                          : 'Cần thêm ${target - _writingWordCount} từ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isTargetReached ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Khu vực soạn thảo văn bản
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isTargetReached ? AppColors.success : context.borderCol,
                    width: isTargetReached ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bài viết dự thi của bạn (Your Response):',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _writingController,
                      maxLines: 15,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.6,
                        color: context.textPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Nhập bài viết của bạn tại đây theo đúng chuẩn định dạng bài thi IELTS...',
                        filled: true,
                        fillColor: context.scaffoldBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.borderCol),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              CustomButton(
                text: 'Nộp bài và chấm theo 4 tiêu chí IELTS',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _confirmSubmitDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // GIAO DIỆN READING RESPONSIVE (SPLIT VIEW)
  // ==========================================
  Widget _buildReadingResponsiveBody(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth >= 760;

        if (isWide) {
          // Bố cục 2 cột Split View
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cột trái: Bài đọc cuộn độc lập
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                            const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Bài đọc (${widget.exam.ieltsModule ?? "Academic"})',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Expanded(
                          child: SingleChildScrollView(
                            child: SelectableText(
                              widget.exam.passageOrScript,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.65,
                                color: context.textPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Cột phải: Câu hỏi & Tương tác
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: _buildCurrentQuestionCard(context),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Bố cục Mobile có Tab switcher nhanh
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderCol),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _mobileReadingTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _mobileReadingTabIndex == 0
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Center(
                            child: Text(
                              '📖 Bài đọc',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _mobileReadingTabIndex == 0
                                    ? Colors.white
                                    : context.textSecondaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _mobileReadingTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _mobileReadingTabIndex == 1
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Center(
                            child: Text(
                              '✍️ Câu hỏi (${_currentQuestionIndex + 1}/${widget.exam.questions.length})',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _mobileReadingTabIndex == 1
                                    ? Colors.white
                                    : context.textSecondaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _mobileReadingTabIndex == 0
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.borderCol),
                          ),
                          child: SelectableText(
                            widget.exam.passageOrScript,
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.6,
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _buildCurrentQuestionCard(context),
                      ),
              ),
            ],
          );
        }
      },
    );
  }

  // ==========================================
  // GIAO DIỆN STANDARD & LISTENING
  // ==========================================
  Widget _buildStandardOrListeningBody(BuildContext context) {
    final exam = widget.exam;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (exam.hasAudioScript || _isListeningExam) ...[
                _buildListeningAudioPlayer(context),
                const SizedBox(height: 18),
              ],
              _buildCurrentQuestionCard(context),
            ],
          ),
        ),
      ),
    );
  }

  // Listening Player với nút Section & Tua thời gian
  Widget _buildListeningAudioPlayer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.headphones_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'IELTS Listening Player (Audio Script Mô Phỏng)',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Chọn Section (Section 1 -> 4)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [1, 2, 3, 4].map((s) {
              final isSel = _selectedAudioSection == s;
              return ChoiceChip(
                label: Text('Section $s'),
                selected: isSel,
                onSelected: (_) {
                  setState(() => _selectedAudioSection = s);
                  if (_isPlayingAudio) {
                    _toggleAudio(slow: _isSlowAudio);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Nút điều khiển phát
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _toggleAudio(slow: false),
                icon: Icon(_isPlayingAudio && !_isSlowAudio
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded),
                label: Text(_isPlayingAudio && !_isSlowAudio
                    ? 'Dừng phát'
                    : 'Phát Section $_selectedAudioSection (1.0x)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => _toggleAudio(slow: true),
                icon: const Icon(Icons.slow_motion_video_rounded),
                label: const Text('Nghe chậm (0.8x)'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.isPracticeMode
                ? '💡 Chế độ Luyện tập: Bạn có thể nghe lại từng Section và xem giải thích.'
                : '🔒 Chế độ Thi tính giờ: Lời thoại (Transcript) được ẩn trong phòng thi và sẽ mở kèm dịch nghĩa chi tiết sau khi nộp bài.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  // Thẻ câu hỏi hiện tại (Current Question Card)
  Widget _buildCurrentQuestionCard(BuildContext context) {
    final questions = widget.exam.questions;
    if (questions.isEmpty) return const SizedBox.shrink();

    final currentQ = questions[_currentQuestionIndex];
    final isFlagged = _flaggedQuestionIds.contains(currentQ.id);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.primaryContainerCol,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Câu ${_currentQuestionIndex + 1}/${questions.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      currentQ.sectionTitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    if (currentQ.paragraphRef != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          currentQ.paragraphRef!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    if (isFlagged) {
                      _flaggedQuestionIds.remove(currentQ.id);
                    } else {
                      _flaggedQuestionIds.add(currentQ.id);
                    }
                  });
                },
                icon: Icon(
                  isFlagged ? Icons.flag_rounded : Icons.outlined_flag_rounded,
                  size: 18,
                  color: isFlagged ? AppColors.warning : context.textSecondaryColor,
                ),
                label: Text(
                  isFlagged ? 'Đã đánh dấu' : 'Đánh dấu',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isFlagged ? AppColors.warning : context.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Giới hạn số từ nếu có
          if (currentQ.wordLimit != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '📌 HƯỚNG DẪN: NO MORE THAN ${currentQ.wordLimit} WORD(S)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0284C7),
                ),
              ),
            ),

          Text(
            currentQ.questionText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.45,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Tương tác theo loại câu hỏi
          if (currentQ.isFillBlank) ...[
            TextField(
              controller: _fillControllers[currentQ.id],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
              decoration: InputDecoration(
                hintText: currentQ.wordLimit != null
                    ? 'Nhập tối đa ${currentQ.wordLimit} từ chính xác...'
                    : 'Nhập từ hoặc số chính xác vào chỗ trống...',
                filled: true,
                fillColor: context.scaffoldBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ] else if (currentQ.isTfng || currentQ.isYnng) ...[
            // Giao diện TRUE/FALSE/NOT GIVEN hoặc YES/NO/NOT GIVEN dạng nút bấm lớn
            Row(
              children: currentQ.options.asMap().entries.map((entry) {
                final optIdx = entry.key;
                final optText = entry.value;
                final isSelected = _userAnswers[currentQ.id] == optIdx;

                Color activeColor = AppColors.primary;
                if (optText.toUpperCase().contains('TRUE') || optText.toUpperCase().contains('YES')) {
                  activeColor = AppColors.success;
                } else if (optText.toUpperCase().contains('FALSE') || optText.toUpperCase().contains('NO')) {
                  activeColor = AppColors.danger;
                } else {
                  activeColor = AppColors.warning;
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _userAnswers[currentQ.id] = optIdx;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? activeColor : context.scaffoldBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? activeColor : context.borderCol,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            optText,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : context.textPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            // MCQ thông thường
            ...currentQ.options.asMap().entries.map((entry) {
              final optIdx = entry.key;
              final optText = entry.value;
              final isSelected = _userAnswers[currentQ.id] == optIdx;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isSelected ? context.primaryContainerCol : context.scaffoldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : context.borderCol,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      _userAnswers[currentQ.id] = optIdx;
                    });
                  },
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: isSelected ? AppColors.primary : context.borderCol,
                    child: Text(
                      String.fromCharCode(65 + optIdx),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : context.textPrimaryColor,
                      ),
                    ),
                  ),
                  title: Text(
                    optText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: context.textPrimaryColor,
                    ),
                  ),
                ),
              );
            }),
          ],

          // Chế độ Luyện tập: Xem giải thích & trích dẫn
          if (widget.isPracticeMode) ...[
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  if (_revealedExplanations.contains(currentQ.id)) {
                    _revealedExplanations.remove(currentQ.id);
                  } else {
                    _revealedExplanations.add(currentQ.id);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _revealedExplanations.contains(currentQ.id)
                          ? Icons.lightbulb_rounded
                          : Icons.lightbulb_outline_rounded,
                      size: 17,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _revealedExplanations.contains(currentQ.id)
                          ? 'Ẩn gợi ý & đáp án'
                          : 'Xem gợi ý & giải thích (Chế độ Luyện tập)',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_revealedExplanations.contains(currentQ.id)) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(
                          'Đáp án chuẩn: ${currentQ.correctAnswerDisplay}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    if (currentQ.evidenceQuote != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Chứng cứ trích dẫn: "${currentQ.evidenceQuote}"',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                    if (currentQ.explanation.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        currentQ.explanation,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],

          const SizedBox(height: 20),
          // Điều hướng Câu trước / Câu sau
          Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: CustomButton(
                    text: 'Câu trước',
                    isOutlined: true,
                    onPressed: () {
                      setState(() => _currentQuestionIndex--);
                    },
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 12),
              if (_currentQuestionIndex < questions.length - 1)
                Expanded(
                  child: CustomButton(
                    text: 'Câu tiếp theo',
                    onPressed: () {
                      setState(() => _currentQuestionIndex++);
                    },
                  ),
                )
              else
                Expanded(
                  child: CustomButton(
                    text: context.l10n.examSubmit,
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: _confirmSubmitDialog,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}