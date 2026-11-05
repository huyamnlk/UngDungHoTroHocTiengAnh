import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/tts_service.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../../data/models/word_model.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/custom_button.dart';

class FlashcardScreen extends StatefulWidget {
  final String title;
  final List<WordModel> words;

  const FlashcardScreen({
    super.key,
    required this.title,
    required this.words,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  bool _isFront = true;
  int _currentIndex = 0;
  int _rememberedCount = 0;
  int _needReviewCount = 0;
  bool _isSessionFinished = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_animController.isAnimating) return;
    if (_isFront) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  void _nextCard(bool mastered) async {
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);
    final currentWord = widget.words[_currentIndex];

    if (mastered) {
      _rememberedCount++;
      await studyProvider.markAsMastered(currentWord);
    } else {
      _needReviewCount++;
      await studyProvider.markAsLearning(currentWord);
    }

    if (_currentIndex < widget.words.length - 1) {
      // Đặt lại mặt trước nếu đang ở mặt sau
      if (!_isFront) {
        _animController.reverse();
        _isFront = true;
      }
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() {
        _isSessionFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(child: Text(context.l10n.flashcardEmpty)),
      );
    }

    if (_isSessionFinished) {
      return _buildFinishedView();
    }

    final currentWord = widget.words[_currentIndex];
    final progress = (_currentIndex + 1) / widget.words.length;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_currentIndex + 1}/${widget.words.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Thanh tiến độ học
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: context.borderCol,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),

              // Thẻ Flashcard có hiệu ứng lật 3D
              Expanded(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final angle = _animation.value * pi;
                      final isUnder = angle > pi / 2;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: isUnder
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _buildCardBack(currentWord),
                              )
                            : _buildCardFront(currentWord),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nút hành động phía dưới: Cần ôn & Đã nhớ
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: context.l10n.flashcardNeedReview,
                      icon: Icons.replay_rounded,
                      backgroundColor: AppColors.warning,
                      onPressed: () => _nextCard(false),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: context.l10n.flashcardMastered,
                      icon: Icons.check_circle_rounded,
                      backgroundColor: AppColors.success,
                      onPressed: () => _nextCard(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Giao diện mặt trước thẻ Flashcard
  Widget _buildCardFront(WordModel word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDark ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (word.partOfSpeech.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: context.primaryContainerCol,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                word.partOfSpeech.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            word.term,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: context.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (word.ipa.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              word.ipa,
              style: TextStyle(
                fontSize: 18,
                color: context.textSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 24),
          IconButton.filled(
            onPressed: () => TtsService().speak(word.term),
            icon: const Icon(Icons.volume_up_rounded),
            iconSize: 26,
            style: IconButton.styleFrom(
              backgroundColor: context.primaryContainerCol,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.all(14),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_outlined, size: 16, color: context.textMutedColor),
              const SizedBox(width: 6),
              Text(
                context.l10n.flashcardTapToMeaning,
                style: TextStyle(
                  fontSize: 13,
                  color: context.textMutedColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Giao diện mặt sau thẻ Flashcard
  Widget _buildCardBack(WordModel word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: context.isDark ? context.cardBg : const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.isDark ? context.borderCol : AppColors.primaryLight.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDark ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.flashcardVietnameseMeaning,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            word.meaning,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: context.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Divider(color: context.borderCol),
          const SizedBox(height: 16),
          if (word.exampleEn.isNotEmpty) ...[
            Text(
              '"${word.exampleEn}"',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            if (word.exampleVi.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                word.exampleVi,
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_outlined, size: 16, color: context.textMutedColor),
              const SizedBox(width: 6),
              Text(
                context.l10n.flashcardTapToFlip,
                style: TextStyle(
                  fontSize: 13,
                  color: context.textMutedColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Giao diện khi hoàn thành phiên học thẻ
  Widget _buildFinishedView() {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.actionDone),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 54,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.flashcardCompletedTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.flashcardCompletedDesc(widget.words.length),
                style: TextStyle(
                  fontSize: 15,
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildResultTag(l10n.flashcardMastered, _rememberedCount, AppColors.success),
                  const SizedBox(width: 24),
                  _buildResultTag(l10n.flashcardNeedReview, _needReviewCount, AppColors.warning),
                ],
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: l10n.flashcardReviewAgain,
                icon: Icons.refresh_rounded,
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                    _rememberedCount = 0;
                    _needReviewCount = 0;
                    _isSessionFinished = false;
                    _isFront = true;
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: l10n.flashcardBack,
                isOutlined: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultTag(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
