import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/tts_service.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../data/models/word_model.dart';
import 'interactive_card.dart';

class WordCardTile extends StatelessWidget {
  final WordModel word;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onStatusChanged;

  const WordCardTile({
    super.key,
    required this.word,
    this.onTap,
    this.onFavoriteToggle,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;

    final l10n = context.l10n;
    switch (word.status) {
      case AppConstants.statusMastered:
        statusColor = AppColors.success;
        statusLabel = l10n.topicFilterMastered;
        break;
      case AppConstants.statusLearning:
        statusColor = AppColors.warning;
        statusLabel = l10n.topicFilterReview;
        break;
      default:
        statusColor = AppColors.statusNew;
        statusLabel = l10n.topicFilterNew;
        break;
    }

    return InteractiveCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nút loa phát âm
          Tooltip(
            message: l10n.homeListenPronunciation,
            child: InkWell(
              onTap: () {
                TtsService().speak(word.term);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.primaryContainerCol,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.volume_up_rounded,
                  color: context.primaryAccent,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Nội dung chính
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        word.term,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.primaryContainerCol,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        word.level,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: context.primaryAccent,
                        ),
                      ),
                    ),
                    if (word.partOfSpeech.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.isDark ? Colors.white10 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          word.partOfSpeech,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: context.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (word.ipa.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    word.ipa,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  word.meaning,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Cột bên phải
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: onFavoriteToggle,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    word.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: word.isFavorite ? AppColors.danger : context.textMutedColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
