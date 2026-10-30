import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/word_model.dart';
import '../../../providers/study_provider.dart';

class WordDetailScreen extends StatefulWidget {
  final WordModel word;

  const WordDetailScreen({super.key, required this.word});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late WordModel _currentWord;

  @override
  void initState() {
    super.initState();
    _currentWord = widget.word;
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Chi tiết từ vựng'),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(
              _currentWord.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _currentWord.isFavorite ? AppColors.danger : context.textSecondaryColor,
            ),
            onPressed: () async {
              final currentContext = context;
              await studyProvider.toggleFavorite(_currentWord);
              if (!mounted) return;
              setState(() {
                _currentWord = _currentWord.copyWith(isFavorite: !_currentWord.isFavorite);
              });
              UiHelpers.showSnackBar(
                currentContext,
                message: _currentWord.isFavorite ? 'Đã thêm vào mục Yêu thích' : 'Đã bỏ yêu thích',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thẻ từ vựng chính
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.borderCol),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Huy hiệu Level & Loại từ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.primaryContainerCol,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'CEFR ${_currentWord.level}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_currentWord.partOfSpeech.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.isDark ? AppColors.darkCard : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _currentWord.partOfSpeech,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: context.isDark ? AppColors.darkTextPrimary : Colors.grey.shade800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Từ vựng
                  Text(
                    _currentWord.term,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_currentWord.ipa.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _currentWord.ipa,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.textSecondaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Nút phát âm
                  InkWell(
                    onTap: () {
                      TtsService().speak(_currentWord.term);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: context.primaryContainerCol,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Phát âm chuẩn',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: context.borderCol),
                  const SizedBox(height: 14),

                  // Nghĩa tiếng Việt
                  Text(
                    'ĐỊNH NGHĨA TIẾNG VIỆT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: context.textMutedColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentWord.meaning,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.isDark ? AppColors.primaryLight : AppColors.primaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Định nghĩa tiếng Anh nếu có
                  if (_currentWord.englishDefinition.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'ENGLISH DEFINITION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: context.textMutedColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentWord.englishDefinition,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondaryColor,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Câu ví dụ & Bản dịch
            if (_currentWord.exampleEn.isNotEmpty) ...[
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
                    Row(
                      children: [
                        const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Ví dụ ngữ cảnh thực tế',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.primary),
                          onPressed: () => TtsService().speak(_currentWord.exampleEn),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentWord.exampleEn,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.textPrimaryColor,
                        height: 1.4,
                      ),
                    ),
                    if (_currentWord.exampleVi.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _currentWord.exampleVi,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondaryColor,
                          fontStyle: FontStyle.italic,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Từ đồng nghĩa / Trái nghĩa
            if (_currentWord.synonyms.isNotEmpty || _currentWord.antonyms.isNotEmpty) ...[
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
                    if (_currentWord.synonyms.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.compare_arrows_rounded, color: AppColors.success, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Từ đồng nghĩa: ${_currentWord.synonyms}',
                            style: TextStyle(fontSize: 13, color: context.textPrimaryColor),
                          ),
                        ],
                      ),
                    ],
                    if (_currentWord.antonyms.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.not_interested_rounded, color: AppColors.danger, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Từ trái nghĩa: ${_currentWord.antonyms}',
                            style: TextStyle(fontSize: 13, color: context.textPrimaryColor),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Hướng dẫn phát âm / Mẹo ghi nhớ
            if (_currentWord.pronunciationGuide.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? AppColors.warning.withValues(alpha: 0.15)
                      : AppColors.warningLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.tips_and_updates_rounded, color: AppColors.warning, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mẹo ghi nhớ & phát âm',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentWord.pronunciationGuide,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textPrimaryColor,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Trạng thái học tập & Spaced Repetition (SRS)
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
                    'Tiến trình Spaced Repetition (SRS)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Số lần ôn: ${_currentWord.reviewCount}',
                        style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
                      ),
                      const Spacer(),
                      Text(
                        'Khoảng cách: ${_currentWord.intervalDays} ngày',
                        style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3 Nút chọn trạng thái
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusChoice(
                          label: 'Chưa học',
                          isSelected: _currentWord.status == AppConstants.statusNew,
                          color: AppColors.statusNew,
                          onTap: () async {
                            await studyProvider.markAsNew(_currentWord);
                            setState(() {
                              _currentWord = _currentWord.copyWith(status: AppConstants.statusNew);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatusChoice(
                          label: 'Cần ôn',
                          isSelected: _currentWord.status == AppConstants.statusLearning,
                          color: AppColors.statusReview,
                          onTap: () async {
                            await studyProvider.markAsLearning(_currentWord);
                            setState(() {
                              _currentWord = _currentWord.copyWith(status: AppConstants.statusLearning);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatusChoice(
                          label: 'Đã thuộc',
                          isSelected: _currentWord.status == AppConstants.statusMastered,
                          color: AppColors.statusMastered,
                          onTap: () async {
                            await studyProvider.markAsMastered(_currentWord);
                            setState(() {
                              _currentWord = _currentWord.copyWith(status: AppConstants.statusMastered);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChoice({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
