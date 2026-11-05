// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'English Buddy';

  @override
  String get navHome => '首页';

  @override
  String get navTopics => '主题分类';

  @override
  String get navListening => '听力练习';

  @override
  String get navReading => '阅读理解';

  @override
  String get navWriting => '写作训练';

  @override
  String get navSpeaking => '口语表达';

  @override
  String get navShadowing => '影子跟读';

  @override
  String get navDictionary => '词汇与词典';

  @override
  String get navExam => '模拟考试';

  @override
  String get navGames => '趣味游戏';

  @override
  String get navReview => '复习备忘';

  @override
  String get navStats => '学习统计';

  @override
  String get navSettings => '系统设置';

  @override
  String get navAdmin => '管理后台';

  @override
  String get navSectionSkills => '技能与学习';

  @override
  String get navSectionSystem => '进度与系统';

  @override
  String get sidebarExpandTooltip => 'English Buddy - 展开侧边栏';

  @override
  String get sidebarCollapseTooltip => '折叠侧边栏';

  @override
  String get mobileMenuTooltip => '打开13项技能与功能菜单';

  @override
  String get aiChatTooltip => 'English Buddy AI 学习助手';

  @override
  String get aiChatQuickHelp => '语法答疑与翻译';

  @override
  String get aiChatDesc => 'English Buddy AI 助手（答疑与批改）';

  @override
  String get accessDeniedAdminOnly => '访问被拒绝：管理后台仅对管理员账号开放。';

  @override
  String get actionSave => '保存';

  @override
  String get actionCancel => '取消';

  @override
  String get actionConfirm => '确认';

  @override
  String get actionDelete => '删除';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionClose => '关闭';

  @override
  String get actionBack => '返回';

  @override
  String get actionNext => '下一步';

  @override
  String get actionPrevious => '上一步';

  @override
  String get actionContinue => '继续';

  @override
  String get actionRetry => '重试';

  @override
  String get actionSubmit => '提交';

  @override
  String get actionStart => '开始';

  @override
  String get actionDone => '完成';

  @override
  String get actionSearch => '搜索';

  @override
  String get actionFilter => '筛选';

  @override
  String get actionReset => '重置';

  @override
  String get actionResetFilter => '重置筛选';

  @override
  String get actionClear => '清除';

  @override
  String get actionShowAll => '显示全部';

  @override
  String get actionExpand => '展开';

  @override
  String get actionCollapse => '折叠';

  @override
  String get actionPlay => '播放';

  @override
  String get actionPause => '暂停';

  @override
  String get actionResume => '恢复播放';

  @override
  String get actionExit => '退出';

  @override
  String get actionUnderstood => '明白了';

  @override
  String get actionCopy => '复制';

  @override
  String get statusActive => '进行中';

  @override
  String get statusLocked => '已锁定';

  @override
  String get statusCompleted => '已完成';

  @override
  String get statusPending => '待处理';

  @override
  String get statusAll => '全部状态';

  @override
  String get allTopics => '所有主题';

  @override
  String get allLevels => '所有级别';

  @override
  String get allSkills => '所有技能';

  @override
  String get allFormats => '所有题型';

  @override
  String get levelA1 => 'A1 - 初级入门';

  @override
  String get levelA2 => 'A2 - 初级基础';

  @override
  String get levelB1 => 'B1 - 中级阶段';

  @override
  String get levelB2 => 'B2 - 中高阶';

  @override
  String get levelC1 => 'C1 - 高级阶段';

  @override
  String get settingsTitle => '设置与偏好';

  @override
  String get settingsLanguageSection => '语言与本地化';

  @override
  String get settingsLanguageSubtitle => '选择应用界面首选语言';

  @override
  String get settingsLangVi => 'Tiếng Việt';

  @override
  String get settingsLangViDesc => '越南语';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsLangEnDesc => '英语';

  @override
  String get settingsAccountSection => '个人资料与账号';

  @override
  String get settingsThemeSection => '界面与主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeSystemDesc => '自动匹配设备外观模式';

  @override
  String get settingsThemeLight => '浅色模式';

  @override
  String get settingsThemeDark => '深色模式';

  @override
  String get settingsDailyGoalSection => '每日学习目标';

  @override
  String get settingsDailyGoalSubtitle => '选择您每天计划掌握的单词数量：';

  @override
  String settingsDailyGoalUnit(int count) {
    return '$count 个单词';
  }

  @override
  String settingsDailyGoalSaved(int count) {
    return '每日目标已更新为 $count 词/天！';
  }

  @override
  String get settingsSoundSection => '声音与发音';

  @override
  String get settingsSoundEnable => '启用发音音频';

  @override
  String get settingsSoundEnableDesc => '采用母语者文字转语音（TTS）发音引擎';

  @override
  String get settingsCopyrightSection => '数据来源与版权说明';

  @override
  String get settingsCopyrightTitle => '透明版权政策';

  @override
  String get settingsCopyrightDesc1 =>
      '• 词汇内容、例句与练习均基于CEFR等级（A1–C1）和开放语言框架原创编写。';

  @override
  String get settingsCopyrightDesc2 =>
      '• 本应用绝不大规模复制来自剑桥词典、DOL English或其它商业版权内容。';

  @override
  String get settingsCopyrightDesc3 =>
      '• 在线查词接入 Free Dictionary API（开源、免 API Key，采用 CC BY-SA 3.0 协议许可）。';

  @override
  String get settingsAppSubtitle => '移动端应用工程 - Flutter & SQLite';

  @override
  String get guestUser => '访客（未登录）';

  @override
  String get guestUserDesc => '当前未登录。登录或注册账号以管理个人资料并同步学习进度。';

  @override
  String authenticatedAs(String email, String provider) {
    return '$email • 已认证 ($provider)';
  }

  @override
  String get editProfile => '编辑个人资料';

  @override
  String get adminArea => '管理员后台';

  @override
  String get signIn => '登录';

  @override
  String get signUp => '注册账号';

  @override
  String get signOut => '退出登录';

  @override
  String get confirmSignOutTitle => '确认退出登录';

  @override
  String confirmSignOutMessage(String email) {
    return '确定要退出登录 \"$email\" 吗？\n\n当前的登录会话和令牌将被清除。此设备上的本地学习进度将予以保留。';
  }

  @override
  String accountMenuHeader(String displayName) {
    return '账号 ($displayName)';
  }

  @override
  String get homeGreetingGuest => '你好呀！👋';

  @override
  String homeGreetingUser(String name) {
    return '你好，$name！👋';
  }

  @override
  String get homeSubtitle => '准备好在今天拓展词汇量并提升英语水平了吗？';

  @override
  String homeDayStreak(int days) {
    return '连续 $days 天';
  }

  @override
  String get homeStreakLabel => '坚持天数';

  @override
  String homeMasteredWords(int mastered, int total) {
    return '已掌握 $mastered/$total 词';
  }

  @override
  String homeProgressSummary(int mastered, int total, int percent) {
    return '您已掌握 $total 个 CEFR 词汇中的 $mastered 个（已完成 $percent%）。';
  }

  @override
  String homeGoalTitle(int count) {
    return '每日目标：$count 词/天';
  }

  @override
  String homeReviewNow(int count) {
    return '立即复习 ($count 词)';
  }

  @override
  String homeDueSrsCount(int count) {
    return '$count 个单词待复习';
  }

  @override
  String homeWordsToLearn(int count) {
    return '$count 个单词待学习';
  }

  @override
  String homeTopicCount(int count) {
    return '$count 个主题';
  }

  @override
  String homeTopicCefrCount(int count) {
    return '$count 个 CEFR 主题';
  }

  @override
  String get homeShortcutsTitle => '快捷学习入口';

  @override
  String get homeViewAll => '查看全部';

  @override
  String get homeCardTopicsTitle => '词汇主题分类';

  @override
  String get homeCardTopicsDesc => '探索 CEFR 分级词汇主题';

  @override
  String get homeCardReviewTitle => '复习清单';

  @override
  String get homeCardReviewDesc => '当前需要巩固温习的单词';

  @override
  String get homeCardExamTitle => '雅思/托业备考';

  @override
  String get homeCardExamDesc => '限时模拟测试及深度解析';

  @override
  String get homeCardGamesTitle => '词汇趣味游戏';

  @override
  String get homeCardGamesDesc => '配对连线与速度挑战';

  @override
  String get homeCardShadowingTitle => '反应影子跟读';

  @override
  String get homeCardShadowingDesc => '练习句子重音与连读技巧';

  @override
  String get homeCardDictionaryTitle => '英汉双语词典';

  @override
  String get homeCardDictionaryDesc => '随时查阅 3,000+ 精选词汇';

  @override
  String get homeCardAiTitle => 'English Buddy AI 助手';

  @override
  String get homeCardAiDesc => '语法问答、即时查词与作文批改';

  @override
  String get homeCardStatsTitle => '学习进度与统计';

  @override
  String get homeCardStatsDesc => '已掌握单词量与测验历史记录';

  @override
  String get homeTodayWord => '今日单词';

  @override
  String get homeChangeWord => '换一个';

  @override
  String get homeSaveFavorite => '加入收藏夹';

  @override
  String get homeRemoveFavorite => '取消收藏';

  @override
  String get homeListenPronunciation => '播放发音';

  @override
  String get homeSavedSuccess => '已保存';

  @override
  String get topicsTitle => '学习主题';

  @override
  String topicsSubtitle(int count) {
    return '探索涵盖 A1 至 C1 等级的 $count 个生活实用词汇主题。';
  }

  @override
  String topicsCountWords(int count) {
    return '$count 个词汇';
  }

  @override
  String topicsMasteredCount(int mastered, int total) {
    return '已掌握：$mastered/$total';
  }

  @override
  String get topicSearchPlaceholder => '搜索英文单词或中文释义...';

  @override
  String topicLearnFlashcard(int count) {
    return '闪卡学习 ($count)';
  }

  @override
  String get topicFilterAll => '全部';

  @override
  String get topicFilterNew => '新词';

  @override
  String get topicFilterReview => '需复习';

  @override
  String get topicFilterMastered => '已掌握';

  @override
  String get topicEmptyWord => '未找到相关词汇';

  @override
  String get topicEmptyWordDesc => '请尝试使用不同关键字搜索或切换筛选条件。';

  @override
  String get addWordTitle => '添加新单词';

  @override
  String addWordTopicTarget(String topicName) {
    return '所属主题：$topicName';
  }

  @override
  String get addWordEnglishLabel => '英文单词 *';

  @override
  String get addWordEnglishHint => '例如：Innovation';

  @override
  String get addWordMeaningLabel => '中文释义 *';

  @override
  String get addWordMeaningHint => '例如：创新，革新';

  @override
  String get addWordIpaLabel => 'IPA 国际音标';

  @override
  String get addWordIpaHint => '例如：/ˌɪn.əˈveɪ.ʃən/';

  @override
  String get addWordPartOfSpeechLabel => '词性';

  @override
  String get addWordExampleEnLabel => '英文例句';

  @override
  String get addWordExampleEnHint => '例如：Innovation drives technology forward.';

  @override
  String get addWordExampleViLabel => '例句翻译';

  @override
  String get addWordExampleViHint => '例如：创新推动科技向前发展。';

  @override
  String get addWordNotesLabel => '记忆笔记 / 发音技巧';

  @override
  String get addWordNotesHint => '例如：重音在第3个音节';

  @override
  String get addWordSaveButton => '保存单词';

  @override
  String get addWordRequiredEnglish => '请输入英文单词';

  @override
  String get addWordRequiredMeaning => '请输入中文释义';

  @override
  String addWordSuccess(String term) {
    return '成功添加单词 \"$term\"！';
  }

  @override
  String get flashcardTapToFlip => '点击卡片翻转至单词';

  @override
  String get flashcardTapToMeaning => '点击卡片查看中文释义';

  @override
  String get flashcardVietnameseMeaning => '释义';

  @override
  String get flashcardNeedReview => '需复习';

  @override
  String get flashcardMastered => '已掌握';

  @override
  String get flashcardCompletedTitle => '太棒了！已完成本组复习！';

  @override
  String flashcardCompletedDesc(int count) {
    return '您刚刚完成了 $count 张闪卡的复习巩固。';
  }

  @override
  String get flashcardReviewAgain => '再次复习';

  @override
  String get flashcardBack => '返回上一页';

  @override
  String get flashcardEmpty => '暂无需要复习的词汇。';

  @override
  String get quizSetupTitle => '测验挑战';

  @override
  String get quizSetupHeader => '速度与反应测验';

  @override
  String get quizSetupSubtitle => '通过丰富题型巩固词汇记忆：释义选择、单词匹配及语境填空。';

  @override
  String get quizSetupSelectTopic => '选择测验主题';

  @override
  String get quizSetupAllTopics => '综合练习（全部主题）';

  @override
  String get quizSetupAllTopicsDesc => '从完整词库中随机抽取单词';

  @override
  String get quizSetupQuestionCount => '题目数量';

  @override
  String get quizSetupCountFast => '5 道题（快速测验）';

  @override
  String get quizSetupCountStandard => '10 道题（标准测验）';

  @override
  String get quizSetupStart => '开始测验';

  @override
  String get quizPlayTitle => '测验挑战';

  @override
  String quizPlayQuestionCounter(int current, int total) {
    return '题目 $current/$total';
  }

  @override
  String get quizPlayTypeSelectMeaning => '选择正确的释义';

  @override
  String get quizPlayTypeSelectWord => '选择正确的英文单词';

  @override
  String get quizPlayTypeFillBlank => '在空格处填入正确的单词';

  @override
  String get quizPlayCheck => '检查答案';

  @override
  String get quizPlayNext => '下一题';

  @override
  String get quizPlayViewResult => '查看结果';

  @override
  String get quizPlayCorrect => '回答正确！';

  @override
  String get quizPlayIncorrect => '回答错误！';

  @override
  String get quizPlayExitTitle => '退出测验？';

  @override
  String get quizPlayExitMessage => '如果现在离开，当前测验的答题进度将不会被保存。';

  @override
  String get quizPlayContinue => '继续测验';

  @override
  String get quizResultTitle => '测验结果';

  @override
  String quizResultScore(int correct, int total) {
    return '答对 $correct / $total 题';
  }

  @override
  String get quizResultExcellent => '表现优异！';

  @override
  String get quizResultGood => '做得很棒！';

  @override
  String get quizResultNeedsWork => '继续加油！';

  @override
  String get quizResultDescExcellent => '您对本次测验中的词汇掌握得非常扎实。请继续保持！';

  @override
  String get quizResultDescGood => '干得不错！答错的单词已自动加入“需复习”列表，方便后续巩固。';

  @override
  String get quizResultDescNeedsWork => '不要灰心！多通过闪卡复习几遍，再试一次吧。';

  @override
  String get quizResultDetails => '答题明细分析';

  @override
  String get quizResultRetake => '重新测验';

  @override
  String get quizResultHome => '返回主页';

  @override
  String quizResultUserSelected(String answer) {
    return '您的选择：$answer';
  }

  @override
  String quizResultCorrectIs(String answer) {
    return '正确答案：$answer';
  }

  @override
  String get reviewTitle => '复习与收藏';

  @override
  String reviewTabNeedReview(int count) {
    return '需复习 ($count)';
  }

  @override
  String reviewTabFavorites(int count) {
    return '收藏夹 ($count)';
  }

  @override
  String get reviewEmptyNeedReview => '暂无待复习单词';

  @override
  String get reviewEmptyNeedReviewDesc =>
      '当您在闪卡中标记为“需复习”或在测验中回答错误时，单词会根据艾宾浩斯间隔重复算法自动出现在这里。';

  @override
  String get reviewEmptyFavorites => '暂无收藏单词';

  @override
  String get reviewEmptyFavoritesDesc => '点击任意单词上的爱心图标，即可加入书签以便在此回顾。';

  @override
  String get reviewLearnFlashcardsNeed => '闪卡复习（需巩固词汇）';

  @override
  String get reviewLearnFlashcardsFav => '闪卡温习（收藏夹词汇）';

  @override
  String reviewTotalWords(int count) {
    return '总计：$count 个单词';
  }

  @override
  String get reviewViewStats => '查看进度统计';

  @override
  String get wordDetailTitle => '单词详情';

  @override
  String get wordDetailVietnameseDef => '中文释义';

  @override
  String get wordDetailSrsTitle => '间隔重复系统 (SRS)';

  @override
  String wordDetailInterval(int days) {
    return '复习间隔：$days 天';
  }

  @override
  String wordDetailReviewCount(int count) {
    return '复习次数：$count 次';
  }

  @override
  String get wordDetailRealWorldExample => '真实语境实用例句';

  @override
  String wordDetailSynonyms(String synonyms) {
    return '同义词：$synonyms';
  }

  @override
  String wordDetailAntonyms(String antonyms) {
    return '反义词：$antonyms';
  }

  @override
  String get wordDetailTips => '记忆窍门与发音贴士';

  @override
  String get wordDetailAddedFav => '已添加到收藏夹';

  @override
  String get wordDetailRemovedFav => '已从收藏夹中移除';

  @override
  String get statsTitle => '统计与进度';

  @override
  String get statsOverallProgress => '总体学习进展';

  @override
  String statsMasteredRatio(int mastered, int total) {
    return '已掌握 $mastered/$total 个单词';
  }

  @override
  String get statsTotalWords => '总词汇量';

  @override
  String get statsMasteredWords => '已掌握';

  @override
  String get statsNeedReviewWords => '需复习';

  @override
  String get statsFavoriteWords => '已收藏';

  @override
  String get statsTopicProgress => '各主题学习进度';

  @override
  String get statsQuizHistory => '测验历史记录';

  @override
  String statsAverageScore(String score) {
    return '平均分：$score%';
  }

  @override
  String get statsEmptyQuiz => '暂无测验记录。快去参加一次测验检验学习成果吧！';

  @override
  String get statsResetTitle => '重置数据？';

  @override
  String get statsResetMessage => '所有的学习记录、测验历史以及自定义单词都将被重置为应用默认初始状态。';

  @override
  String get statsResetConfirm => '确认重置';

  @override
  String get statsResetSuccess => '已成功恢复应用初始数据！';

  @override
  String get dictTitle => '双语词典';

  @override
  String get dictSearchPlaceholder => '双语查询：输入中文（例如：公寓）或英文（例如：apartment）...';

  @override
  String get dictRecentSearches => '最近搜索';

  @override
  String get dictClearHistory => '清空搜索历史';

  @override
  String get dictOnlineViEn => '在线翻译：中文 ➔ 英文';

  @override
  String get dictOnlineEnVi => '在线查词：英文 ➔ 中文';

  @override
  String dictOnlineViEnQuery(String query) {
    return '在线翻译 \"$query\"（中文 ➔ 英文）';
  }

  @override
  String dictOnlineEnViQuery(String query) {
    return '在线查词 \"$query\"（英文 ➔ 中文）';
  }

  @override
  String dictNotFoundInternal(String query) {
    return '在本地词库中未找到 \"$query\"。';
  }

  @override
  String get dictListenWord => '播放原声发音';

  @override
  String get dictCachedBadge => 'SQLite 离线缓存';

  @override
  String get dictSaveToReview => '存入复习库';

  @override
  String dictSavedSuccess(String term) {
    return '已成功将 \"$term\" 保存至生词与复习列表！';
  }

  @override
  String get dictEnglishDefinitions => '英文释义与例句：';

  @override
  String dictSynonymsList(String synonyms) {
    return '同义词：$synonyms';
  }

  @override
  String get dictNoun => '名词 (n)';

  @override
  String get dictVerb => '动词 (v)';

  @override
  String get dictAdj => '形容词 (adj)';

  @override
  String get dictAdv => '副词 (adv)';

  @override
  String get dictPhrase => '短语 / 习语';

  @override
  String get skillsHubTitle => '四大技能与词汇实战';

  @override
  String get skillsHubAllLevels => '显示全部等级 (A1–C1)';

  @override
  String get skillsListening => '听力理解';

  @override
  String get skillsReading => '阅读精读';

  @override
  String get skillsWriting => '写作实操';

  @override
  String get skillsSpeaking => '口语表达';

  @override
  String get skillsListeningDesc =>
      '支持标准 (1.0x) 与慢速 (0.75x) 音频播放。提交答案后解锁原文与对照翻译。';

  @override
  String get skillsReadingDesc => '精选 A1–C1 分级短文，配备单选与填空题及深度考点剖析。';

  @override
  String get skillsWritingDesc => '句子连词成句训练以及带范文对照的量表评分写作。';

  @override
  String get skillsSpeakingDesc => '纠正发音、掌握句子重音与连读弱读，对照四项评价量表自评。';

  @override
  String get skillsStartLearning => '立即开始训练';

  @override
  String skillsProgressText(int completed, int total) {
    return '进度：已完成 $completed/$total 课';
  }

  @override
  String skillsCompletedBadge(int score) {
    return '已完成 • 得分 $score%';
  }

  @override
  String skillsLessonList(int count) {
    return '课程列表 ($count 课)';
  }

  @override
  String skillsNoLessonLevel(String level) {
    return '当前 CEFR $level 级别暂无可用课程。';
  }

  @override
  String get skillsOpenShadowing => '进入跟读工坊';

  @override
  String get skillsMatchingGameTitle => '连线配对游戏';

  @override
  String get skillsFlashcard3dTitle => '3D 翻转闪卡';

  @override
  String get skillsQuizReflexTitle => '词汇反应测验';

  @override
  String get skillsExamHubTitle => '限时考场模拟';

  @override
  String get skillsSrsReviewTitle => 'SRS 艾宾浩斯复习';

  @override
  String get exerciseListeningTitle => '听力理解训练';

  @override
  String get exerciseReadingTitle => '阅读理解训练';

  @override
  String exerciseQuestionsCount(int count) {
    return '理解练习题 ($count 题)';
  }

  @override
  String exerciseScoreResult(int correct, int total, int percent) {
    return '成绩：答对 $correct/$total 题 ($percent%)';
  }

  @override
  String get exerciseShowTranscript => '显示原文与翻译';

  @override
  String get exerciseHideTranscript => '隐藏原文与翻译';

  @override
  String get exerciseReadingPassage => '阅读文章';

  @override
  String get exerciseAudioPlayer => '音频播放器';

  @override
  String exerciseKeyWords(int count) {
    return '核心重点词汇 ($count 词)';
  }

  @override
  String get exerciseSubmitGrade => '提交并评分';

  @override
  String get exerciseRetake => '重新学习本课';

  @override
  String exerciseSaveWordSuccess(String term) {
    return '已将 \"$term\" 保存至复习与收藏夹！';
  }

  @override
  String get speakingTimerPractice => '限时口语表达训练';

  @override
  String speakingRecordPrompt(int seconds) {
    return '录音中（$seconds 秒）- 点击停止';
  }

  @override
  String speakingRubricSelfCheck(int checked, int total) {
    return '自我评估（达成 $checked/$total 项评分标准）';
  }

  @override
  String speakingSaveSuccess(int score) {
    return '已将口语自评结果（$score%）保存至学习记录！';
  }

  @override
  String get writingTabScramble => '1. 句子结构与连词成句';

  @override
  String get writingTabRubric => '2. 短文写作与量表自评';

  @override
  String get writingTapWordToForm => '点击下方词块按正确顺序排列句子...';

  @override
  String get writingCheckSentence => '检查句子';

  @override
  String writingWordCountStatus(int count, int min) {
    return '字数：$count / 最低要求 $min 词';
  }

  @override
  String writingNeedMoreWords(int count) {
    return '还需补充 $count 个词';
  }

  @override
  String get writingSaveModelAnswer => '保存作文并解锁参考范文';

  @override
  String get writingModelAnswerTitle => '参考优秀范文';

  @override
  String get shadowingHubTitle => '反应影子跟读工坊';

  @override
  String get shadowingMethodTitle => '四步语调跟读训练法';

  @override
  String get shadowingMethodDesc =>
      '1. 听原声示范 (1.0x) → 2. 慢速精听与连读分析 (0.75x) → 3. 同步影子跟读 → 4. 对照标准自评。';

  @override
  String shadowingLessonsList(int count) {
    return '跟读课程 ($count 课)';
  }

  @override
  String get shadowingPracticeTitle => '跟读训练';

  @override
  String get shadowingStep1 => '第一步：聆听原速示范 (1.0x)';

  @override
  String get shadowingStep2 => '第二步：慢速精听 (0.75x)';

  @override
  String get shadowingStep3 => '第三步：同步影子跟读';

  @override
  String get shadowingStep4 => '第四步：对照量表自我评估（必评）';

  @override
  String shadowingSpeakingStatus(int seconds) {
    return '跟读录音中（$seconds 秒）...';
  }

  @override
  String get shadowingSaveProgress => '保存跟读进度';

  @override
  String shadowingSavedSuccess(int score) {
    return '已将跟读训练进度（达成 $score% 评估项）存入数据库！';
  }

  @override
  String get gamesHubTitle => '词汇趣味游戏中心';

  @override
  String get gamesHubSubtitle => '在急速打字、敏捷反应与单词接球中快乐强化词汇持久记忆。';

  @override
  String get gamesSelectGame => '选择一款游戏开始挑战：';

  @override
  String get gamesSpaceTyperTitle => '太空打字员';

  @override
  String get gamesSpaceTyperDesc => '输入字母与单词摧毁陨石。战舰自动校准航向、发射激光并开启防御雷达。';

  @override
  String get gamesArenaTitle => '词汇竞技场';

  @override
  String get gamesArenaDesc => '7-15秒急速限时选择，连击加成机制，支持电脑键盘 1-4 快捷键操作。';

  @override
  String get gamesWordRainTitle => '词汇接雨水';

  @override
  String get gamesWordRainDesc => '在英文雨滴掉落沉底之前，迅速接住与目标中文释义匹配的雨滴。';

  @override
  String get gamesPlayNow => '立即畅玩';

  @override
  String get gamesRules => '游戏规则与玩法说明';

  @override
  String gamesHighScore(int score) {
    return '最高纪录：$score 分';
  }

  @override
  String gamesRecentHistory(int count) {
    return '最近战绩 ($count 局)';
  }

  @override
  String gameScorePoints(int score) {
    return '$score 分';
  }

  @override
  String get gameOver => '游戏结束！';

  @override
  String get gameCompleted => '本轮通关！';

  @override
  String get gamePlayAgain => '再玩一次';

  @override
  String get gameBackToHub => '返回游戏中心';

  @override
  String get gameAccuracy => '命中准确率';

  @override
  String get gameTime => '用时';

  @override
  String get gameStreak => '最高连击';

  @override
  String get gameNewRecord => '🎉 创下了新的个人纪录！';

  @override
  String get gameDiffEasy => '简单模式';

  @override
  String get gameDiffMedium => '中等模式';

  @override
  String get gameDiffHard => '困难模式';

  @override
  String get examHubTitle => '国际权威英语认证模拟考场';

  @override
  String get examHubSubtitle => '真题模拟与限时冲刺测试（雅思 IELTS • 托业 TOEIC • CEFR）';

  @override
  String examListTitle(int count) {
    return '可参加考试 ($count 套试卷)';
  }

  @override
  String get examPracticeMode => '练习模式';

  @override
  String get examPracticeModeDesc => '不计答题时间，每道题目均可随时查看提示与详尽答案解析。';

  @override
  String get examTimedMode => '正规考试模式（限时）';

  @override
  String get examTimedModeDesc => '严格倒计时，考试时间结束自动交卷并生成全方位能力评估报告。';

  @override
  String examQuestionCounter(int current, int total) {
    return '题目 $current/$total';
  }

  @override
  String get examSubmitConfirm => '确认提交考卷？';

  @override
  String get examSubmitConfirmDesc => '您确定要结束作答并提交试卷吗？';

  @override
  String get examResultTitle => '考试成绩与深度解析报告';

  @override
  String examScoreBand(String band) {
    return '预估得分：$band';
  }

  @override
  String examCorrectRatio(int correct, int total, int percent) {
    return '答对题目：$correct/$total 题 ($percent%)';
  }

  @override
  String get aiChatTitle => 'English Buddy AI 学习助手';

  @override
  String get aiChatSubtitle => '语法解惑 • 句子地道翻译 • 写作批改优化';

  @override
  String get aiChatGreeting => '您好！今天有什么我可以为您协助的英语问题吗？';

  @override
  String get aiChatGreetingDesc => '随时向我咨询任何语法难题、翻译句子，或发送您的短文获取批改润色建议！';

  @override
  String get aiChatSuggestions => '推荐提问范例';

  @override
  String get aiChatInputPlaceholder => '输入您的疑问、需翻译的语句或作文短文...';

  @override
  String get aiChatClearTitle => '清空对话记录？';

  @override
  String get aiChatClearDesc => '此设备上的所有 AI 聊天对话将被彻底删除。此操作无法撤销。';

  @override
  String get aiChatClearSuccess => '已成功清空所有对话历史记录。';

  @override
  String get aiChatThinking => 'AI 助手正在深入思考中...';

  @override
  String get authSignInTitle => '账号登录';

  @override
  String get authSignUpTitle => '创建新账号';

  @override
  String get authAccountOrEmail => '用户名或电子邮箱';

  @override
  String get authEmail => '电子邮箱地址';

  @override
  String get authPassword => '密码';

  @override
  String get authConfirmPassword => '确认密码';

  @override
  String get authDisplayName => '用户昵称';

  @override
  String get authGoogleSignIn => '使用 Google 账号继续';

  @override
  String get authProcessing => '处理中，请稍候...';

  @override
  String get authPasswordMismatch => '两次输入的密码不一致！';

  @override
  String get authMinPassword => '密码长度至少需要 8 个字符';

  @override
  String get authInvalidEmail => '请输入有效的电子邮箱格式';

  @override
  String get authOr => '或';

  @override
  String get statsResetButton => '恢复初始数据';

  @override
  String statsQuizQuestionsCount(Object correct, Object total) {
    return '$correct/$total 题正确';
  }

  @override
  String statsTopicWordsProgress(
    Object mastered,
    Object percent,
    Object total,
  ) {
    return '$mastered/$total 词已掌握 ($percent%)';
  }

  @override
  String get dictTitleFull => '英汉 • 汉英双向智能词典';

  @override
  String dictSearchDirection(Object flag, Object label) {
    return '检索方向：$flag $label';
  }

  @override
  String get dictViDetected => '识别到：中文 ➜ 显示对应的英文词汇';

  @override
  String get dictEnDetected => '识别到：英文 ➜ 显示中文释义与原文字典释义';

  @override
  String get dictAllLevels => '所有级别';

  @override
  String get dictAllTopics => '所有主题';

  @override
  String get dictAllPos => '所有词性';

  @override
  String get dictIntroDesc =>
      '智能双向查询系统：输入中文检索对应英文表达，或输入英文获取地道中文释义。收录超过 3,000+ CEFR A1–C1 离线词汇，并支持在线扩展查词（Google Translate 及 Wiktionary 结果缓存至 SQLite）。';

  @override
  String get dictViEnOnlinePrompt =>
      '您可以通过网络拓展汉英翻译（系统将自动抓取对应的英文单词、释义、发音并离线缓存至 SQLite）。';

  @override
  String get dictEnViOnlinePrompt =>
      '您可以通过网络拓展英汉查词（自动获取中文释义、英文字典释义、发音并离线缓存至 SQLite）。';

  @override
  String get dictRetry => '重试';

  @override
  String get dictRetryConnection => '重试网络连接';

  @override
  String get dictTtsTooltip => '原声朗读 (TTS)';

  @override
  String get dictInReview => '正在复习中';

  @override
  String get dictAddToReview => '加入复习库';

  @override
  String dictMovedToNew(Object term) {
    return '已将 \"$term\" 标记为新词';
  }

  @override
  String dictAddedToReview(Object term) {
    return '已将 \"$term\" 添加到复习清单！';
  }

  @override
  String get dictFavoriteAdd => '收藏该单词';

  @override
  String get dictFavoriteRemove => '从收藏夹中移除';

  @override
  String get dictLiveApi => '在线检索 (Live API)';

  @override
  String get dictSaved => '已保存';

  @override
  String dictViKeyword(Object query) {
    return '检索词：\"$query\"';
  }

  @override
  String get dictEquivalentEnWords => '对应英文单词：';

  @override
  String dictListenTooltip(Object word) {
    return '点击播放发音：$word';
  }

  @override
  String dictViRefMeaning(Object meaning) {
    return '对照参考释义：$meaning';
  }

  @override
  String get dictViTranslation => '中文翻译：';

  @override
  String get dictOtherMeanings => '其他常用释义：';

  @override
  String dictSourceInfo(Object license, Object source, Object url) {
    return '词源：$source • 许可协议：$license ($url)';
  }

  @override
  String dictExamplePrefix(Object example) {
    return '例：\"$example\"';
  }

  @override
  String get avatarChangePhoto => '更换头像';

  @override
  String get avatarSelectFromDevice => '从本地相册 / 图库选取';

  @override
  String get avatarSelectFromUrl => '直接输入网络图片链接';

  @override
  String get avatarResetDefault => '重置为默认头像';

  @override
  String get avatarEnterUrlTitle => '输入头像图片地址';

  @override
  String get avatarUrlPlaceholder => 'https://example.com/avatar.jpg';

  @override
  String get avatarInvalidUrl => '图片链接无效或非合法图片格式';

  @override
  String get skillsSelectSkill => '选择一项技能开始训练：';

  @override
  String get skillsAllLevels => '全等级';

  @override
  String skillsQuestionsCount(Object count) {
    return '$count 道题目';
  }

  @override
  String skillsExerciseCount(Object count) {
    return '$count 组练习';
  }

  @override
  String get skillsStartPractice => '开始练习';

  @override
  String get skillsTranscriptLocked => '原文已隐藏锁定';

  @override
  String get skillsTranscriptUnlocked => '听力文本与原文对照';

  @override
  String get skillsSubmitExercise => '提交答卷';

  @override
  String get skillsCompleted => '已完成';

  @override
  String skillsScore(Object score, Object total) {
    return '得分：$score/$total';
  }

  @override
  String get skillsTryAgain => '再练一次';

  @override
  String get skillsNextExercise => '进入下一练习';

  @override
  String get skillsListenNormal => '正常语速 1.0x';

  @override
  String get skillsListenSlow => '慢速精听 0.75x';

  @override
  String get skillsExplanation => '题目答案详解';

  @override
  String get skillsMatchingPairs => '连线匹配单词与中文释义';

  @override
  String get skillsSpeakingPrompt => '请大声朗读以下短文';

  @override
  String get skillsWritingPrompt => '根据以下要求完成写作';

  @override
  String gameDifficulty(Object diff) {
    return '难度：$diff';
  }

  @override
  String gameScore(Object score) {
    return '得分：$score';
  }

  @override
  String gameHighScore(Object score) {
    return '最高分：$score';
  }

  @override
  String get gameExit => '退出游戏';

  @override
  String gameCombo(Object multiplier) {
    return '连击 x$multiplier';
  }

  @override
  String gameWpm(Object wpm) {
    return '打字速度：$wpm WPM';
  }

  @override
  String get gameStart => '开始游戏';

  @override
  String get gamePause => '暂停游戏';

  @override
  String get gameResume => '继续游戏';

  @override
  String get gameRestart => '重新开始';

  @override
  String gameLives(Object lives) {
    return '剩余生命：$lives';
  }

  @override
  String gameLevel(Object level) {
    return '当前关卡：$level';
  }

  @override
  String get examMode => '考试模式';

  @override
  String examTimeRemaining(Object time) {
    return '剩余答题时间：$time';
  }

  @override
  String get examSubmit => '交卷提交';

  @override
  String get examPassed => '考试通过';

  @override
  String get examFailed => '尚需努力';

  @override
  String get examScoreBreakdown => '各项能力得分详情';

  @override
  String get examReviewAnswers => '回顾答卷与试题解析';

  @override
  String get examRetake => '重新参加考试';

  @override
  String get examBackToHub => '返回模拟考场';

  @override
  String get shadowingListen1 => '第1步：聆听范读 (1.0x)';

  @override
  String get shadowingListen2 => '第2步：慢速精听 (0.75x)';

  @override
  String get shadowingRecord => '第3步：同步影子跟读';

  @override
  String get shadowingStop => '停止录音';

  @override
  String get shadowingSelfEval => '第4步：自我评分评估';

  @override
  String get shadowingNext => '下一句子';

  @override
  String get shadowingComplete => '跟读训练已全部完成！';

  @override
  String get authLogin => '登录';

  @override
  String get authRegister => '注册';

  @override
  String get authNoAccount => '还没有账号？立即注册';

  @override
  String get authAlreadyHaveAccount => '已有账号？立即登录';

  @override
  String get authLogout => '退出登录';

  @override
  String get authLogoutConfirm => '您确定要退出当前账号吗？';

  @override
  String get profileTitle => '个人中心';

  @override
  String get profileEdit => '编辑资料';

  @override
  String get profileSave => '保存资料修改';

  @override
  String get profileDisplayName => '显示昵称';

  @override
  String get profileEmail => '电子邮箱';

  @override
  String get profileRole => '账号身份';

  @override
  String get profileJoined => '注册日期';

  @override
  String get adminTitle => '系统运营管理后台 (Admin)';

  @override
  String get adminUsers => '用户账号与等级';

  @override
  String get adminVocab => '词库与主题管理';

  @override
  String get adminExercises => '阅读与听力题库';

  @override
  String get adminExams => '模拟试卷管理';

  @override
  String get adminSystem => '系统运行监控';

  @override
  String get adminForbidden => '仅限管理员访问权限 (403 Forbidden)';

  @override
  String get adminRefresh => '刷新管理后台数据';

  @override
  String get aiChatAsk => '询问 AI';

  @override
  String get settingsSelectLanguage => '选择应用语言';

  @override
  String get settingsSearchLanguage => '搜索语言...';

  @override
  String get settingsAllLanguages => '查看全部 13 种语言';

  @override
  String get settingsAllLanguagesSubtitle => '中文、日语、韩语、法语、德语、西班牙语、俄语...';

  @override
  String get settingsDefaultBadge => '默认';

  @override
  String get profileUsernameLabel => '登录用户名 (Username)';

  @override
  String get profileUsernameHint => '输入用户名（3–30个字符：a-z, 0-9, ., _, -）';

  @override
  String get profileUsernameHelperPassword => '您可以使用此用户名或电子邮箱配合密码登录。';

  @override
  String get profileUsernameHelperGoogle =>
      'Google 账号继续通过 Google 登录；此用户名作为您的唯一账号标识。';

  @override
  String get profileEmailReadOnlyHelper => '登录邮箱（只读，修改显示名称或用户名时保持不变）';

  @override
  String get weeklyProgressTitle => '每周学习进度';

  @override
  String weeklyProgressActiveDays(int count) {
    return '$count/7 活跃天数';
  }

  @override
  String weeklyProgressWordsStudied(int count) {
    return '已学/复习 $count 个单词';
  }

  @override
  String weeklyProgressActivitiesDone(int count) {
    return '完成 $count 项练习';
  }

  @override
  String weeklyProgressTodayGoal(int current, int goal) {
    return '今日单词目标：$current/$goal 词';
  }

  @override
  String get weeklyProgressTodayBadge => '今天';

  @override
  String get weeklyProgressEmptyTitle => '本周暂无学习活动记录';

  @override
  String get weeklyProgressEmptyDesc => '学习或复习词汇、完成测验或技能练习后，每周进度图表将立即更新！';

  @override
  String get weeklyProgressStartCta => '立即复习词汇';

  @override
  String get weeklyProgressScopeNote => '按本地时区记录当前账号（周一至周日）的真实学习活动时间戳。';

  @override
  String get weeklyProgressUnitWords => '词';

  @override
  String get weeklyProgressUnitActivities => '项';

  @override
  String get aiChatErrorGeneral => '无法获取 AI 响应';

  @override
  String get authRegisterSuccessPleaseLogin => '注册成功！请登录以继续。';
}
