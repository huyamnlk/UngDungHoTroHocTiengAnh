import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/tts_service.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../../data/models/skill_exercise_model.dart';
import '../../../providers/skills_provider.dart';
import '../../widgets/custom_button.dart';

class SpeakingExerciseScreen extends StatefulWidget {
  final SkillExerciseModel exercise;

  const SpeakingExerciseScreen({super.key, required this.exercise});

  @override
  State<SpeakingExerciseScreen> createState() => _SpeakingExerciseScreenState();
}

class _SpeakingExerciseScreenState extends State<SpeakingExerciseScreen> {
  int _currentIndex = 0;
  bool _isSpeaking = false;
  bool _isSlow = false;

  // Bộ đếm thời gian tự luyện nói
  bool _isPracticeActive = false;
  int _practiceSeconds = 0;
  Timer? _practiceTimer;

  // Lưu checklist tự đánh giá theo từng câu: sentenceIndex -> Set<criterionIndex>
  final Map<int, Set<int>> _rubricBySentence = {};

  static const List<String> _speakingRubricCriteria = [
    'Phát âm rõ nguyên âm và bật âm cuối (Ending sounds: /s/, /t/, /d/)',
    'Nhấn đúng trọng âm từ và từ khóa mang thông tin chính trong câu',
    'Nói trôi chảy, áp dụng nối âm (Linking sounds) theo mẹo hướng dẫn',
    'Ngữ điệu (Intonation) lên/xuống tự nhiên, tốc độ nói ổn định',
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.exercise.writingSentences.length; i++) {
      _rubricBySentence[i] = {0, 1, 2};
    }
  }

  @override
  void dispose() {
    _practiceTimer?.cancel();
    TtsService().stop();
    super.dispose();
  }

  Future<void> _speakCurrentSentence({bool slow = false}) async {
    final current = widget.exercise.writingSentences[_currentIndex];
    setState(() {
      _isSpeaking = true;
      _isSlow = slow;
    });
    await TtsService().speak(current.englishSentence, slow: slow);
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _togglePracticeTimer() {
    if (_isPracticeActive) {
      _practiceTimer?.cancel();
      setState(() => _isPracticeActive = false);
    } else {
      setState(() {
        _isPracticeActive = true;
        _practiceSeconds = 0;
      });
      _practiceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() => _practiceSeconds++);
        }
      });
    }
  }

  Future<void> _finishSpeakingLesson() async {
    _practiceTimer?.cancel();
    int totalChecked = 0;
    final totalPossible = widget.exercise.writingSentences.length *
        _speakingRubricCriteria.length;
    for (int i = 0; i < widget.exercise.writingSentences.length; i++) {
      totalChecked += (_rubricBySentence[i]?.length ?? 0);
    }
    final score = totalPossible > 0
        ? ((totalChecked / totalPossible) * 100).clamp(0.0, 100.0)
        : 100.0;

    final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
    await skillsProvider.saveScore(
      skillType: widget.exercise.type.name,
      exerciseId: widget.exercise.id,
      title: widget.exercise.title,
      score: score,
      detailsJson: 'self_eval_rubric:$totalChecked/$totalPossible',
    );

    if (mounted) {
      UiHelpers.showSnackBar(
        context,
        message:
            context.l10n.speakingSaveSuccess(score.round()),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentence = widget.exercise.writingSentences[_currentIndex];
    final checkedSet = _rubricBySentence[_currentIndex] ?? <int>{};

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(widget.exercise.title),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                context.l10n.examQuestionCounter(_currentIndex + 1, widget.exercise.writingSentences.length),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hướng dẫn luyện nói & Minh bạch kỹ thuật
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.primaryContainerCol,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.record_voice_over_rounded,
                          color: AppColors.primary,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Phương pháp Shadowing & Tự đánh giá: Nghe câu mẫu (1.0x hoặc 0.75x), bấm bắt đầu lượt nói để canh nhịp, sau đó tự kiểm tra theo Rubric 4 tiêu chí. Ứng dụng không tạo điểm chấm phát âm AI giả lập.',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textPrimaryColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Thẻ câu nói mẫu & Điều khiển âm thanh
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Column(
                      children: [
                        Text(
                          sentence.englishSentence,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimaryColor,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          sentence.vietnameseMeaning,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _speakCurrentSentence(slow: false),
                              icon: Icon(_isSpeaking && !_isSlow
                                  ? Icons.volume_up_rounded
                                  : Icons.play_arrow_rounded),
                              label: Text(context.l10n.skillsListenNormal),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _speakCurrentSentence(slow: true),
                              icon: const Icon(Icons.slow_motion_video_rounded),
                              label: Text(context.l10n.skillsListenSlow),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _togglePracticeTimer,
                              icon: Icon(
                                _isPracticeActive
                                    ? Icons.stop_circle_outlined
                                    : Icons.mic_none_rounded,
                                color: _isPracticeActive
                                    ? AppColors.danger
                                    : AppColors.primary,
                              ),
                              label: Text(
                                _isPracticeActive
                                    ? context.l10n.speakingRecordPrompt(_practiceSeconds)
                                    : (_practiceSeconds > 0
                                        ? 'Luyện nói lại (Lần trước: ${_practiceSeconds}s)'
                                        : context.l10n.speakingTimerPractice),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (sentence.hint.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: context.isDark
                                  ? AppColors.warning.withValues(alpha: 0.16)
                                  : AppColors.warningLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.tips_and_updates_rounded,
                                    color: AppColors.warning, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Hướng dẫn phát âm & nối âm: ${sentence.hint}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.textPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Checklist tự đánh giá phát âm (Speaking Self-Evaluation Rubric)
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.speakingRubricSelfCheck(checkedSet.length, _speakingRubricCriteria.length),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimaryColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.primaryContainerCol,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${((checkedSet.length / _speakingRubricCriteria.length) * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._speakingRubricCriteria.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final text = entry.value;
                          final isChecked = checkedSet.contains(idx);
                          return CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            value: isChecked,
                            activeColor: AppColors.primary,
                            title: Text(
                              text,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: context.textPrimaryColor,
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                final currentSet = _rubricBySentence
                                    .putIfAbsent(_currentIndex, () => <int>{});
                                if (val == true) {
                                  currentSet.add(idx);
                                } else {
                                  currentSet.remove(idx);
                                }
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Nút chuyển câu & Lưu kết quả
                  Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          child: CustomButton(
                            text: context.l10n.actionPrevious,
                            isOutlined: true,
                            onPressed: () {
                              _practiceTimer?.cancel();
                              setState(() {
                                _isPracticeActive = false;
                                _practiceSeconds = 0;
                                _currentIndex--;
                              });
                            },
                          ),
                        ),
                      if (_currentIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: _currentIndex <
                                  widget.exercise.writingSentences.length - 1
                              ? context.l10n.quizPlayNext
                              : context.l10n.actionSave,
                          icon: _currentIndex <
                                  widget.exercise.writingSentences.length - 1
                              ? Icons.arrow_forward_rounded
                              : Icons.check_circle_rounded,
                          onPressed: () {
                            if (_currentIndex <
                                widget.exercise.writingSentences.length - 1) {
                              _practiceTimer?.cancel();
                              setState(() {
                                _isPracticeActive = false;
                                _practiceSeconds = 0;
                                _currentIndex++;
                              });
                            } else {
                              _finishSpeakingLesson();
                            }
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
      ),
    );
  }
}
