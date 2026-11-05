import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../../data/models/topic_model.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/interactive_card.dart';
import 'topic_detail_screen.dart';

class TopicListScreen extends StatelessWidget {
  const TopicListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.topicsTitle),
        backgroundColor: context.surfaceBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.borderCol),
        ),
      ),
      body: studyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await studyProvider.loadTopics();
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(isWide ? 28 : 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1160),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Tóm tắt kho chủ đề
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              decoration: BoxDecoration(
                                color: context.cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: context.borderCol),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.collections_bookmark_rounded,
                                    color: context.primaryAccent,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n.topicsSubtitle(studyProvider.topics.length),
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: context.textSecondaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (isWide)
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: studyProvider.topics.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 18,
                                  mainAxisExtent: 196,
                                ),
                                itemBuilder: (context, index) {
                                  return _buildTopicCard(context, studyProvider.topics[index]);
                                },
                              )
                            else
                              Column(
                                children: studyProvider.topics
                                    .map(
                                      (topic) => Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: _buildTopicCard(context, topic),
                                      ),
                                    )
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildTopicCard(BuildContext context, TopicModel topic) {
    final topicColor = UiHelpers.hexToColor(topic.colorHex);
    final iconData = UiHelpers.getIconData(topic.iconName);

    return InteractiveCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      hoverBorderColor: topicColor.withValues(alpha: 0.65),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TopicDetailScreen(topic: topic),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: topicColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(iconData, color: topicColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.topicsCountWords(topic.totalWords),
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: context.textMutedColor,
                  ),
                ],
              ),
              if (topic.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  topic.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondaryColor,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.topicsMasteredCount(topic.masteredWords, topic.totalWords),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  Text(
                    '${(topic.progressPercentage * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: topicColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: topic.progressPercentage,
                  minHeight: 6,
                  backgroundColor: context.borderCol,
                  valueColor: AlwaysStoppedAnimation<Color>(topicColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
