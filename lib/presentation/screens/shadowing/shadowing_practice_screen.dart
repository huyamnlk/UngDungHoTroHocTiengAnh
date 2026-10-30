import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/shadowing_model.dart';
import '../../../providers/skills_provider.dart';
import '../../widgets/custom_button.dart';

class ShadowingPracticeScreen extends StatefulWidget {
  final ShadowingLessonModel lesson;

  const ShadowingPracticeScreen({super.key, required this.lesson});

  @override
  State<ShadowingPracticeScreen> createState() =>
      _ShadowingPracticeScreenState();
}

class _ShadowingPracticeScreenState extends State<ShadowingPracticeScreen> {
  int _currentIndex = 0;
  int _activeStep = 1; // 1: Nghe chuẩn, 2: Nghe chậm, 3: Nhắc theo, 4: Tự đánh giá
  bool _isPlaying = false;
  bool _isSlow = false;
  bool _showFullTranscript = false;

  // Trạng thái luyện nhắc theo (Bước 3)
  bool _isShadowingActive = false;
  int _shadowingElapsedSeconds = 0;
  Timer? _shadowingTimer;
  String? _micStatusMessage;
  bool _hasCompletedShadowingAttempt = false;

  // Trạng thái tự đánh giá (Bước 4) - KHÔNG điền sẵn điểm giả
  final Map<int, Set<int>> _evaluatedCriteriaBySegment = {};
  final Set<int> _explicitlyEvaluatedSegments = {};

  static const List<String> _shadowingCriteria = [
    'Bắt kịp tốc độ và ngắt nhịp đúng dấu "|" của câu mẫu (Rhythm & Chunking)',
    'Nhấn rõ các từ IN HOA mang trọng âm thông tin (Sentence Stress)',
    'Thực hiện nối âm mượt mà tại các vị trí ký hiệu "_" (Linking Sounds)',
    'Lên/xuống ngữ điệu cuối cụm đúng mũi tên ↗ ↘ (Intonation)',
  ];

  @override
  void dispose() {
    _shadowingTimer?.cancel();
    TtsService().stop();
    super.dispose();
  }

  Future<void> _playModel({required bool slow, int? nextStep}) async {
    final seg = widget.lesson.segments[_currentIndex];
    if (_isPlaying && _isSlow == slow) {
      await TtsService().stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    setState(() {
      _isPlaying = true;
      _isSlow = slow;
      if (nextStep != null) _activeStep = nextStep;
    });
    await TtsService().speak(seg.englishText, slow: slow);
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _startSynchronizedShadowing() async {
    final seg = widget.lesson.segments[_currentIndex];
    if (_isShadowingActive) {
      _shadowingTimer?.cancel();
      await TtsService().stop();
      setState(() {
        _isShadowingActive = false;
        _hasCompletedShadowingAttempt = true;
        _activeStep = 4;
      });
      return;
    }

    setState(() {
      _activeStep = 3;
      _isShadowingActive = true;
      _shadowingElapsedSeconds = 0;
      _micStatusMessage =
          'Đang chạy nhịp Shadowing đồng bộ với giọng mẫu. Hãy nói to cùng lúc với âm thanh phát ra!';
    });

    // Phát giọng mẫu để người học nói đuổi theo (Shadowing thực chất)
    TtsService().speak(seg.englishText, slow: false);

    _shadowingTimer?.cancel();
    _shadowingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _shadowingElapsedSeconds++;
        if (_shadowingElapsedSeconds >= seg.targetDurationSeconds + 2) {
          timer.cancel();
          _isShadowingActive = false;
          _hasCompletedShadowingAttempt = true;
          _activeStep = 4;
          _micStatusMessage =
              'Đã hoàn thành lượt nói đuổi theo (${_shadowingElapsedSeconds}s). Hãy nghe lại hoặc chuyển sang Bước 4 để tự đánh giá.';
        }
      });
    });
  }

  void _requestMicrophoneCheck() {
    setState(() {
      _activeStep = 3;
      _micStatusMessage =
          'Thiết bị hiện đang ở chế độ Shadowing trực tiếp qua loa/tai nghe (chưa gắn plugin thu âm phần cứng ngoài). Bạn hãy bấm "Bắt đầu nói đuổi theo mẫu" để luyện đồng bộ và tự đánh giá trung thực ở Bước 4.';
    });
  }

  void _toggleCriterion(int criterionIndex, bool checked) {
    setState(() {
      _activeStep = 4;
      _explicitlyEvaluatedSegments.add(_currentIndex);
      final set =
          _evaluatedCriteriaBySegment.putIfAbsent(_currentIndex, () => <int>{});
      if (checked) {
        set.add(criterionIndex);
      } else {
        set.remove(criterionIndex);
      }
    });
  }

  void _markSegmentEvaluatedWithZero() {
    setState(() {
      _activeStep = 4;
      _explicitlyEvaluatedSegments.add(_currentIndex);
      _evaluatedCriteriaBySegment[_currentIndex] = <int>{};
    });
  }

  Future<void> _saveShadowingProgress() async {
    final totalSegments = widget.lesson.segments.length;
    if (_explicitlyEvaluatedSegments.length < totalSegments) {
      UiHelpers.showSnackBar(
        context,
        message:
            'Vui lòng tự đánh giá đủ cả $totalSegments câu ở Bước 4 trước khi lưu kết quả (đã đánh giá ${_explicitlyEvaluatedSegments.length}/$totalSegments câu). Ứng dụng không tự ghi điểm giả.',
        isError: true,
      );
      return;
    }

    int totalChecked = 0;
    final maxPossible = totalSegments * _shadowingCriteria.length;
    for (int i = 0; i < totalSegments; i++) {
      totalChecked += (_evaluatedCriteriaBySegment[i]?.length ?? 0);
    }

    final score =
        maxPossible > 0 ? ((totalChecked / maxPossible) * 100.0) : 0.0;

    final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
    await skillsProvider.saveScore(
      skillType: 'shadowing',
      exerciseId: widget.lesson.id,
      title: 'Shadowing: ${widget.lesson.title}',
      score: score,
      detailsJson:
          'evaluated_segments:${_explicitlyEvaluatedSegments.length}/$totalSegments,criteria:$totalChecked/$maxPossible',
    );

    if (mounted) {
      UiHelpers.showSnackBar(
        context,
        message:
            'Đã lưu tiến độ bài Shadowing (${score.round()}% tiêu chí đạt) vào cơ sở dữ liệu!',
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final segments = widget.lesson.segments;
    final currentSeg = segments[_currentIndex];
    final currentChecked =
        _evaluatedCriteriaBySegment[_currentIndex] ?? const <int>{};
    final isCurrentEvaluated =
        _explicitlyEvaluatedSegments.contains(_currentIndex);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Câu ${_currentIndex + 1}/${segments.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thanh tiến trình 4 bước luyện Shadowing
                _buildStepProgressHeader(context),
                const SizedBox(height: 18),

                // Thẻ câu Shadowing hiện tại + Ký hiệu Trọng âm / Nối âm
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.primaryContainerCol,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'CEFR ${widget.lesson.level} • ${widget.lesson.topic}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCurrentEvaluated
                                  ? (context.isDark
                                      ? AppColors.success.withValues(alpha: 0.2)
                                      : AppColors.successLight)
                                  : context.scaffoldBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCurrentEvaluated
                                    ? AppColors.success
                                    : context.borderCol,
                              ),
                            ),
                            child: Text(
                              isCurrentEvaluated
                                  ? 'Đã tự đánh giá câu này (${currentChecked.length}/4)'
                                  : 'Chưa tự đánh giá câu này',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCurrentEvaluated
                                    ? AppColors.success
                                    : context.textSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentSeg.englishText,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Ký hiệu Prosody (Trọng âm, Ngắt nhịp |, Nối âm _, Ngữ điệu ↗ ↘)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.scaffoldBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bản đồ Trọng âm • Nối âm (_) • Ngắt nhịp (|) • Ngữ điệu (↗ ↘):',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              currentSeg.phoneticStress,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimaryColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nghĩa tiếng Việt: ${currentSeg.vietnameseMeaning}',
                        style: TextStyle(
                          fontSize: 14.5,
                          color: context.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? AppColors.warning.withValues(alpha: 0.16)
                              : AppColors.warningLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.tips_and_updates_rounded,
                                size: 19, color: AppColors.warning),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Hướng dẫn khẩu hình & ngữ điệu: ${currentSeg.coachingTip}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Khu vực điều khiển Bước 1, 2, 3 (Nghe mẫu -> Nghe chậm -> Nhắc theo đồng bộ)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thực hành 3 bước Nghe & Nhắc theo (Shadowing Controls)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () =>
                                _playModel(slow: false, nextStep: 1),
                            icon: Icon(_isPlaying && !_isSlow
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded),
                            label: Text(_isPlaying && !_isSlow
                                ? 'Dừng phát'
                                : 'Bước 1: Nghe mẫu (1.0x)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _playModel(slow: true, nextStep: 2),
                            icon: Icon(_isPlaying && _isSlow
                                ? Icons.stop_rounded
                                : Icons.slow_motion_video_rounded),
                            label: Text(_isPlaying && _isSlow
                                ? 'Dừng'
                                : 'Bước 2: Nghe chậm (0.75x)'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _startSynchronizedShadowing,
                            icon: Icon(_isShadowingActive
                                ? Icons.stop_circle_outlined
                                : Icons.record_voice_over_rounded),
                            label: Text(_isShadowingActive
                                ? 'Đang nói đuổi theo (${_shadowingElapsedSeconds}s)...'
                                : 'Bước 3: Bắt đầu nói đuổi theo mẫu'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isShadowingActive
                                  ? AppColors.danger
                                  : AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _requestMicrophoneCheck,
                            icon: const Icon(Icons.mic_none_rounded, size: 18),
                            label: const Text('Kiểm tra thu âm thiết bị'),
                          ),
                        ],
                      ),
                      if (_micStatusMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.scaffoldBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.borderCol),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _hasCompletedShadowingAttempt
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.info_outline_rounded,
                                size: 18,
                                color: _hasCompletedShadowingAttempt
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _micStatusMessage!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: context.textSecondaryColor,
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

                // Bước 4: Tự đánh giá trung thực (Không ghi điểm giả khi chưa đánh giá)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCurrentEvaluated
                          ? AppColors.success
                          : context.borderCol,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Bước 4: Tự đánh giá câu ${_currentIndex + 1} (Bắt buộc trước khi lưu)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimaryColor,
                              ),
                            ),
                          ),
                          if (!isCurrentEvaluated)
                            TextButton(
                              onPressed: _markSegmentEvaluatedWithZero,
                              child: const Text('Đánh dấu cần luyện lại (0/4)'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ứng dụng không giả lập AI chấm phát âm. Hãy tích vào các tiêu chí bạn thực sự đạt được khi nói đuổi theo câu mẫu:',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._shadowingCriteria.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final label = entry.value;
                        final checked = currentChecked.contains(idx);
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: checked,
                          activeColor: AppColors.primary,
                          title: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          onChanged: (val) =>
                              _toggleCriterion(idx, val ?? false),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Toàn bộ Transcript bài học
                Container(
                  padding: const EdgeInsets.all(16),
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
                            'Toàn bộ Transcript bài học (${segments.length} câu)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => setState(() =>
                                _showFullTranscript = !_showFullTranscript),
                            icon: Icon(
                              _showFullTranscript
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              size: 18,
                            ),
                            label: Text(
                                _showFullTranscript ? 'Thu gọn' : 'Xem tất cả'),
                          ),
                        ],
                      ),
                      if (_showFullTranscript) ...[
                        Divider(color: context.borderCol),
                        ...segments.asMap().entries.map((e) {
                          final idx = e.key;
                          final s = e.value;
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            selected: idx == _currentIndex,
                            onTap: () => setState(() => _currentIndex = idx),
                            leading: CircleAvatar(
                              radius: 13,
                              backgroundColor: idx == _currentIndex
                                  ? AppColors.primary
                                  : context.primaryContainerCol,
                              child: Text(
                                '${idx + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: idx == _currentIndex
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            title: Text(
                              s.englishText,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: context.textPrimaryColor,
                              ),
                            ),
                            subtitle: Text(
                              s.vietnameseMeaning,
                              style: TextStyle(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Điều hướng Câu trước / Câu tiếp / Lưu hoàn thành
                Row(
                  children: [
                    if (_currentIndex > 0)
                      Expanded(
                        child: CustomButton(
                          text: 'Câu trước',
                          isOutlined: true,
                          onPressed: () {
                            _shadowingTimer?.cancel();
                            setState(() {
                              _isShadowingActive = false;
                              _currentIndex--;
                              _activeStep = 1;
                            });
                          },
                        ),
                      ),
                    if (_currentIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: _currentIndex < segments.length - 1
                            ? 'Câu tiếp theo'
                            : 'Lưu tiến độ Shadowing',
                        icon: _currentIndex < segments.length - 1
                            ? Icons.arrow_forward_rounded
                            : Icons.check_circle_rounded,
                        onPressed: () {
                          if (_currentIndex < segments.length - 1) {
                            _shadowingTimer?.cancel();
                            setState(() {
                              _isShadowingActive = false;
                              _currentIndex++;
                              _activeStep = 1;
                            });
                          } else {
                            _saveShadowingProgress();
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
    );
  }

  Widget _buildStepProgressHeader(BuildContext context) {
    final steps = [
      (1, '1. Nghe mẫu'),
      (2, '2. Nghe chậm'),
      (3, '3. Nhắc theo'),
      (4, '4. Tự đánh giá'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: steps.map((st) {
          final isCurrent = _activeStep == st.$1;
          final isDone = _activeStep > st.$1;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isCurrent
                    ? AppColors.primary
                    : (isDone
                        ? AppColors.success
                        : context.primaryContainerCol),
                child: Icon(
                  isDone ? Icons.check_rounded : Icons.circle,
                  size: isDone ? 14 : 8,
                  color: isCurrent || isDone ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                st.$2,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: isCurrent
                      ? AppColors.primary
                      : context.textSecondaryColor,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
