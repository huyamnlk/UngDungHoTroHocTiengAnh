// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'English Buddy';

  @override
  String get navHome => 'ホーム';

  @override
  String get navTopics => 'トピック';

  @override
  String get navListening => 'リスニング';

  @override
  String get navReading => 'リーディング';

  @override
  String get navWriting => 'ライティング';

  @override
  String get navSpeaking => 'スピーキング';

  @override
  String get navShadowing => 'シャドーイング';

  @override
  String get navDictionary => '単語・辞書';

  @override
  String get navExam => '模擬試験';

  @override
  String get navGames => 'ゲーム';

  @override
  String get navReview => '復習リスト';

  @override
  String get navStats => '学習統計';

  @override
  String get navSettings => '設定';

  @override
  String get navAdmin => '管理者';

  @override
  String get navSectionSkills => 'スキル＆学習';

  @override
  String get navSectionSystem => '進捗＆システム';

  @override
  String get sidebarExpandTooltip => 'English Buddy - サイドバーを展開';

  @override
  String get sidebarCollapseTooltip => 'サイドバーを折りたたむ';

  @override
  String get mobileMenuTooltip => '13のスキル・機能メニューを開く';

  @override
  String get aiChatTooltip => 'English Buddy AI アシスタント';

  @override
  String get aiChatQuickHelp => '文法Q&A・翻訳';

  @override
  String get aiChatDesc => 'English Buddy AI アシスタント（質問＆添削）';

  @override
  String get accessDeniedAdminOnly => 'アクセス拒否：管理者エリアは管理者アカウント専用です。';

  @override
  String get actionSave => '保存';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionConfirm => '確認';

  @override
  String get actionDelete => '削除';

  @override
  String get actionEdit => '編集';

  @override
  String get actionClose => '閉じる';

  @override
  String get actionBack => '戻る';

  @override
  String get actionNext => '次へ';

  @override
  String get actionPrevious => '前へ';

  @override
  String get actionContinue => '続ける';

  @override
  String get actionRetry => '再試行';

  @override
  String get actionSubmit => '提出';

  @override
  String get actionStart => '開始';

  @override
  String get actionDone => '完了';

  @override
  String get actionSearch => '検索';

  @override
  String get actionFilter => '絞り込み';

  @override
  String get actionReset => 'リセット';

  @override
  String get actionResetFilter => 'フィルターをリセット';

  @override
  String get actionClear => 'クリア';

  @override
  String get actionShowAll => 'すべて表示';

  @override
  String get actionExpand => '展開';

  @override
  String get actionCollapse => '折りたたむ';

  @override
  String get actionPlay => '再生';

  @override
  String get actionPause => '一時停止';

  @override
  String get actionResume => '再開';

  @override
  String get actionExit => '終了';

  @override
  String get actionUnderstood => '了解しました';

  @override
  String get actionCopy => 'コピー';

  @override
  String get statusActive => '進行中';

  @override
  String get statusLocked => 'ロック中';

  @override
  String get statusCompleted => '完了';

  @override
  String get statusPending => '保留中';

  @override
  String get statusAll => 'すべて';

  @override
  String get allTopics => 'すべてのトピック';

  @override
  String get allLevels => 'すべてのレベル';

  @override
  String get allSkills => 'すべてのスキル';

  @override
  String get allFormats => 'すべての形式';

  @override
  String get levelA1 => 'A1 - 初級';

  @override
  String get levelA2 => 'A2 - 初中級';

  @override
  String get levelB1 => 'B1 - 中級';

  @override
  String get levelB2 => 'B2 - 中上級';

  @override
  String get levelC1 => 'C1 - 上級';

  @override
  String get settingsTitle => '設定＆環境設定';

  @override
  String get settingsLanguageSection => '言語＆地域';

  @override
  String get settingsLanguageSubtitle => 'アプリの表示言語を選択してください';

  @override
  String get settingsLangVi => 'Tiếng Việt';

  @override
  String get settingsLangViDesc => 'ベトナム語';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsLangEnDesc => '英語';

  @override
  String get settingsAccountSection => 'プロフィール＆アカウント';

  @override
  String get settingsThemeSection => '外観＆テーマ';

  @override
  String get settingsThemeSystem => 'システム標準';

  @override
  String get settingsThemeSystemDesc => 'デバイスの外観設定に自動で合わせる';

  @override
  String get settingsThemeLight => 'ライトモード';

  @override
  String get settingsThemeDark => 'ダークモード';

  @override
  String get settingsDailyGoalSection => '1日の学習目標';

  @override
  String get settingsDailyGoalSubtitle => '1日に学習したい単語数を選択してください：';

  @override
  String settingsDailyGoalUnit(int count) {
    return '$count 単語';
  }

  @override
  String settingsDailyGoalSaved(int count) {
    return '1日の目標を $count 単語/日に設定しました！';
  }

  @override
  String get settingsSoundSection => '音声＆発音';

  @override
  String get settingsSoundEnable => '発音音声を有効にする';

  @override
  String get settingsSoundEnableDesc => 'ネイティブスピーカーのテキスト読み上げ（TTS）エンジン';

  @override
  String get settingsCopyrightSection => 'データソース＆著作権';

  @override
  String get settingsCopyrightTitle => '透明な著作権ポリシー';

  @override
  String get settingsCopyrightDesc1 =>
      '• 単語コンテンツ、例文、および練習問題は、CEFRレベル（A1–C1）およびオープン言語フレームワークに基づいて独自に作成されています。';

  @override
  String get settingsCopyrightDesc2 =>
      '• Cambridge DictionaryやDOL Englishなどの商用ソースから著作権で保護されたコンテンツを無断複製することはありません。';

  @override
  String get settingsCopyrightDesc3 =>
      '• オンライン検索には Free Dictionary API（オープンソース、APIキー不要、CC BY-SA 3.0ライセンス）を利用しています。';

  @override
  String get settingsAppSubtitle => 'モバイルアプリプロジェクト - Flutter & SQLite';

  @override
  String get guestUser => 'ゲスト（未ログイン）';

  @override
  String get guestUserDesc =>
      'ログインしていません。ログインまたはアカウント作成してプロフィールを管理し、学習進捗を同期しましょう。';

  @override
  String authenticatedAs(String email, String provider) {
    return '$email • 認証済み ($provider)';
  }

  @override
  String get editProfile => 'プロフィールを編集';

  @override
  String get adminArea => '管理者エリア';

  @override
  String get signIn => 'ログイン';

  @override
  String get signUp => 'アカウント作成';

  @override
  String get signOut => 'ログアウト';

  @override
  String get confirmSignOutTitle => 'ログアウトの確認';

  @override
  String confirmSignOutMessage(String email) {
    return '\"$email\" からログアウトしてもよろしいですか？\n\n現在のセッションとトークンは削除されます。このデバイス上のローカル学習進捗は保持されます。';
  }

  @override
  String accountMenuHeader(String displayName) {
    return 'アカウント ($displayName)';
  }

  @override
  String get homeGreetingGuest => 'こんにちは！👋';

  @override
  String homeGreetingUser(String name) {
    return 'こんにちは、$nameさん！👋';
  }

  @override
  String get homeSubtitle => '今日も語彙を広げて、英語力をステップアップさせましょう！';

  @override
  String homeDayStreak(int days) {
    return '$days日連続';
  }

  @override
  String get homeStreakLabel => '連続学習記録';

  @override
  String homeMasteredWords(int mastered, int total) {
    return '$mastered/$total 語習得済み';
  }

  @override
  String homeProgressSummary(int mastered, int total, int percent) {
    return '全 $total 単語中 $mastered 単語の CEFR 語彙を習得しました（進捗率 $percent%）。';
  }

  @override
  String homeGoalTitle(int count) {
    return '目標：$count 単語/日';
  }

  @override
  String homeReviewNow(int count) {
    return '今すぐ復習 ($count 語)';
  }

  @override
  String homeDueSrsCount(int count) {
    return '$count 語が復習対象';
  }

  @override
  String homeWordsToLearn(int count) {
    return '$count 語が未暗記';
  }

  @override
  String homeTopicCount(int count) {
    return '$count トピック';
  }

  @override
  String homeTopicCefrCount(int count) {
    return '$count CEFRトピック';
  }

  @override
  String get homeShortcutsTitle => 'ショートカット';

  @override
  String get homeViewAll => 'すべて表示';

  @override
  String get homeCardTopicsTitle => '語彙トピック';

  @override
  String get homeCardTopicsDesc => 'CEFRレベル別トピックを探す';

  @override
  String get homeCardReviewTitle => '復習リスト';

  @override
  String get homeCardReviewDesc => '現在復習が必要な単語';

  @override
  String get homeCardExamTitle => 'IELTS/TOEIC 試験対策';

  @override
  String get homeCardExamDesc => '時間制限付き模試と詳細な解説';

  @override
  String get homeCardGamesTitle => '単語ゲーム';

  @override
  String get homeCardGamesDesc => 'ペアマッチング＆スピードクイズ';

  @override
  String get homeCardShadowingTitle => '反射シャドーイング';

  @override
  String get homeCardShadowingDesc => '文の強勢と音の連結トレーニング';

  @override
  String get homeCardDictionaryTitle => '英和・和英辞書';

  @override
  String get homeCardDictionaryDesc => '3,000語以上の単語を検索';

  @override
  String get homeCardAiTitle => 'English Buddy AI';

  @override
  String get homeCardAiDesc => '文法Q&A・辞書検索・エッセイ添削';

  @override
  String get homeCardStatsTitle => '学習統計＆進捗';

  @override
  String get homeCardStatsDesc => '習得単語数とクイズ履歴';

  @override
  String get homeTodayWord => '今日の単語';

  @override
  String get homeChangeWord => '別の単語';

  @override
  String get homeSaveFavorite => 'お気に入りに追加';

  @override
  String get homeRemoveFavorite => 'お気に入りから削除';

  @override
  String get homeListenPronunciation => '発音を聞く';

  @override
  String get homeSavedSuccess => '保存しました';

  @override
  String get topicsTitle => '学習トピック';

  @override
  String topicsSubtitle(int count) {
    return 'A1からC1までレベル付けされた $count の実用的な語彙トピックを探索しましょう。';
  }

  @override
  String topicsCountWords(int count) {
    return '$count 単語';
  }

  @override
  String topicsMasteredCount(int mastered, int total) {
    return '習得済み：$mastered/$total';
  }

  @override
  String get topicSearchPlaceholder => '英単語または日本語の意味を検索...';

  @override
  String topicLearnFlashcard(int count) {
    return 'フラッシュカードで学ぶ ($count)';
  }

  @override
  String get topicFilterAll => 'すべて';

  @override
  String get topicFilterNew => '新規';

  @override
  String get topicFilterReview => '要復習';

  @override
  String get topicFilterMastered => '習得済み';

  @override
  String get topicEmptyWord => '該当する単語が見つかりません';

  @override
  String get topicEmptyWordDesc => '別のキーワードで検索するか、フィルターを変更してください。';

  @override
  String get addWordTitle => '新しい単語を追加';

  @override
  String addWordTopicTarget(String topicName) {
    return '追加先トピック：$topicName';
  }

  @override
  String get addWordEnglishLabel => '英単語 *';

  @override
  String get addWordEnglishHint => '例：Innovation';

  @override
  String get addWordMeaningLabel => '日本語の意味 *';

  @override
  String get addWordMeaningHint => '例：革新、刷新';

  @override
  String get addWordIpaLabel => 'IPA 発音記号';

  @override
  String get addWordIpaHint => '例：/ˌɪn.əˈveɪ.ʃən/';

  @override
  String get addWordPartOfSpeechLabel => '品詞';

  @override
  String get addWordExampleEnLabel => '例文（英語）';

  @override
  String get addWordExampleEnHint => '例：Innovation drives technology forward.';

  @override
  String get addWordExampleViLabel => '例文の訳';

  @override
  String get addWordExampleViHint => '例：革新はテクノロジーを前進させます。';

  @override
  String get addWordNotesLabel => 'メモ / 発音のポイント';

  @override
  String get addWordNotesHint => '例：第3音節にアクセント';

  @override
  String get addWordSaveButton => '単語を保存';

  @override
  String get addWordRequiredEnglish => '英単語を入力してください';

  @override
  String get addWordRequiredMeaning => '日本語の意味を入力してください';

  @override
  String addWordSuccess(String term) {
    return '\"$term\" を追加しました！';
  }

  @override
  String get flashcardTapToFlip => 'カードをタップして単語を表示';

  @override
  String get flashcardTapToMeaning => 'カードをタップして意味を表示';

  @override
  String get flashcardVietnameseMeaning => '日本語の意味';

  @override
  String get flashcardNeedReview => '要復習';

  @override
  String get flashcardMastered => '習得済み';

  @override
  String get flashcardCompletedTitle => '素晴らしい！完了しました！';

  @override
  String flashcardCompletedDesc(int count) {
    return '$count 枚のフラッシュカードの復習が完了しました。';
  }

  @override
  String get flashcardReviewAgain => 'もう一度復習する';

  @override
  String get flashcardBack => '前のページに戻る';

  @override
  String get flashcardEmpty => '復習可能な単語がありません。';

  @override
  String get quizSetupTitle => 'クイズチャレンジ';

  @override
  String get quizSetupHeader => 'スピード＆反射クイズ';

  @override
  String get quizSetupSubtitle => '意味の選択、単語の選択、文脈穴埋め問題など多様な形式で単語を定着させます。';

  @override
  String get quizSetupSelectTopic => 'クイズのトピックを選択';

  @override
  String get quizSetupAllTopics => '総合（全トピック）';

  @override
  String get quizSetupAllTopicsDesc => '全単語データベースからランダムに出題';

  @override
  String get quizSetupQuestionCount => '問題数';

  @override
  String get quizSetupCountFast => '5問（クイック）';

  @override
  String get quizSetupCountStandard => '10問（標準）';

  @override
  String get quizSetupStart => 'クイズを開始';

  @override
  String get quizPlayTitle => 'クイズチャレンジ';

  @override
  String quizPlayQuestionCounter(int current, int total) {
    return '問題 $current/$total';
  }

  @override
  String get quizPlayTypeSelectMeaning => '正しい日本語の意味を選択してください';

  @override
  String get quizPlayTypeSelectWord => '正しい英単語を選択してください';

  @override
  String get quizPlayTypeFillBlank => '空欄に当てはまる正しい単語を入力してください';

  @override
  String get quizPlayCheck => '回答を確認';

  @override
  String get quizPlayNext => '次の問題';

  @override
  String get quizPlayViewResult => '結果を見る';

  @override
  String get quizPlayCorrect => '正解！';

  @override
  String get quizPlayIncorrect => '不正解！';

  @override
  String get quizPlayExitTitle => 'クイズを終了しますか？';

  @override
  String get quizPlayExitMessage => '今退出すると、現在のクイズ進捗は保存されません。';

  @override
  String get quizPlayContinue => 'クイズを続ける';

  @override
  String get quizResultTitle => 'クイズ結果';

  @override
  String quizResultScore(int correct, int total) {
    return '正解数：$correct / $total 問';
  }

  @override
  String get quizResultExcellent => '素晴らしい成績です！';

  @override
  String get quizResultGood => 'よくできました！';

  @override
  String get quizResultNeedsWork => 'あと少し練習しましょう！';

  @override
  String get quizResultDescExcellent => 'このクイズの単語をしっかり習得できています。この調子で続けましょう！';

  @override
  String get quizResultDescGood => 'よく頑張りました！間違えた単語は自動的に「要復習」に追加され、後から復習できます。';

  @override
  String get quizResultDescNeedsWork =>
      '諦めないでください！フラッシュカードで復習してから、もう一度挑戦しましょう。';

  @override
  String get quizResultDetails => '解答の内訳';

  @override
  String get quizResultRetake => 'クイズをもう一度受ける';

  @override
  String get quizResultHome => 'ホームに戻る';

  @override
  String quizResultUserSelected(String answer) {
    return 'あなたの選択：$answer';
  }

  @override
  String quizResultCorrectIs(String answer) {
    return '正解：$answer';
  }

  @override
  String get reviewTitle => '復習＆お気に入り';

  @override
  String reviewTabNeedReview(int count) {
    return '要復習 ($count)';
  }

  @override
  String reviewTabFavorites(int count) {
    return 'お気に入り ($count)';
  }

  @override
  String get reviewEmptyNeedReview => '復習が必要な単語はありません';

  @override
  String get reviewEmptyNeedReviewDesc =>
      'フラッシュカードで「要復習」にマークした単語や、クイズで間違えた単語は、間隔反復法（SRS）に基づいて自動的にここに表示されます。';

  @override
  String get reviewEmptyFavorites => 'お気に入りの単語はまだありません';

  @override
  String get reviewEmptyFavoritesDesc => '単語のハートアイコンをタップするとブックマークされ、ここで確認できます。';

  @override
  String get reviewLearnFlashcardsNeed => 'フラッシュカード（要復習）';

  @override
  String get reviewLearnFlashcardsFav => 'フラッシュカード（お気に入り）';

  @override
  String reviewTotalWords(int count) {
    return '合計：$count 単語';
  }

  @override
  String get reviewViewStats => '学習進捗の統計を見る';

  @override
  String get wordDetailTitle => '単語の詳細';

  @override
  String get wordDetailVietnameseDef => '日本語の意味';

  @override
  String get wordDetailSrsTitle => '間隔反復システム (SRS)';

  @override
  String wordDetailInterval(int days) {
    return '復習間隔：$days 日';
  }

  @override
  String wordDetailReviewCount(int count) {
    return '復習回数：$count 回';
  }

  @override
  String get wordDetailRealWorldExample => '実践的な用例';

  @override
  String wordDetailSynonyms(String synonyms) {
    return '類義語：$synonyms';
  }

  @override
  String wordDetailAntonyms(String antonyms) {
    return '対義語：$antonyms';
  }

  @override
  String get wordDetailTips => '記憶のヒント＆発音のコツ';

  @override
  String get wordDetailAddedFav => 'お気に入りに追加しました';

  @override
  String get wordDetailRemovedFav => 'お気に入りから削除しました';

  @override
  String get statsTitle => '統計＆学習進捗';

  @override
  String get statsOverallProgress => '総合学習進捗';

  @override
  String statsMasteredRatio(int mastered, int total) {
    return '$total 単語中 $mastered 単語を習得';
  }

  @override
  String get statsTotalWords => '総単語数';

  @override
  String get statsMasteredWords => '習得済み';

  @override
  String get statsNeedReviewWords => '要復習';

  @override
  String get statsFavoriteWords => 'お気に入り';

  @override
  String get statsTopicProgress => 'トピック別進捗';

  @override
  String get statsQuizHistory => 'クイズ履歴';

  @override
  String statsAverageScore(String score) {
    return '平均スコア：$score%';
  }

  @override
  String get statsEmptyQuiz => 'クイズ履歴はまだありません。クイズに挑戦して実力を試してみましょう！';

  @override
  String get statsResetTitle => 'データをリセットしますか？';

  @override
  String get statsResetMessage => 'すべての学習状態、クイズ履歴、カスタム単語がアプリの初期設定にリセットされます。';

  @override
  String get statsResetConfirm => 'リセットを確認';

  @override
  String get statsResetSuccess => 'アプリの初期データを正常に復元しました！';

  @override
  String get dictTitle => '二言語辞書';

  @override
  String get dictSearchPlaceholder => '双方向検索：日本語または英語（例：apartment）を入力...';

  @override
  String get dictRecentSearches => '最近の検索';

  @override
  String get dictClearHistory => '履歴を消去';

  @override
  String get dictOnlineViEn => 'オンライン翻訳：日本語 ➔ 英語';

  @override
  String get dictOnlineEnVi => 'オンライン検索：英語 ➔ 日本語';

  @override
  String dictOnlineViEnQuery(String query) {
    return '\"$query\" を日本語 ➔ 英語でオンライン翻訳';
  }

  @override
  String dictOnlineEnViQuery(String query) {
    return '\"$query\" を英語 ➔ 日本語でオンライン検索';
  }

  @override
  String dictNotFoundInternal(String query) {
    return '内部辞書に \"$query\" が見つかりませんでした。';
  }

  @override
  String get dictListenWord => 'ネイティブの発音を聞く';

  @override
  String get dictCachedBadge => 'SQLiteキャッシュ（オフライン）';

  @override
  String get dictSaveToReview => '復習リストに保存';

  @override
  String dictSavedSuccess(String term) {
    return '\"$term\" を語彙＆復習リストに保存しました！';
  }

  @override
  String get dictEnglishDefinitions => '英語の定義と例文：';

  @override
  String dictSynonymsList(String synonyms) {
    return '類義語：$synonyms';
  }

  @override
  String get dictNoun => '名詞 (n)';

  @override
  String get dictVerb => '動詞 (v)';

  @override
  String get dictAdj => '形容詞 (adj)';

  @override
  String get dictAdv => '副詞 (adv)';

  @override
  String get dictPhrase => '句 / イディオム';

  @override
  String get skillsHubTitle => '4技能＆語彙トレーニング';

  @override
  String get skillsHubAllLevels => '全レベルを表示 (A1–C1)';

  @override
  String get skillsListening => 'リスニング';

  @override
  String get skillsReading => 'リーディング';

  @override
  String get skillsWriting => 'ライティング';

  @override
  String get skillsSpeaking => 'スピーキング';

  @override
  String get skillsListeningDesc =>
      '標準（1.0倍）または低速（0.75倍）音声。スクリプトと翻訳は回答送信後にロック解除されます。';

  @override
  String get skillsReadingDesc => 'A1–C1段階別テキスト、選択式＆穴埋め問題、詳細な解説付き。';

  @override
  String get skillsWritingDesc => '語順並べ替え問題と、模範解答付きのルーブリック評価エッセイ作成。';

  @override
  String get skillsSpeakingDesc => '発音、文の強勢、連結音の練習と、4基準ルーブリックによる自己評価。';

  @override
  String get skillsStartLearning => '今すぐ練習する';

  @override
  String skillsProgressText(int completed, int total) {
    return '進捗：$completed/$total レッスン完了';
  }

  @override
  String skillsCompletedBadge(int score) {
    return '完了 • スコア $score%';
  }

  @override
  String skillsLessonList(int count) {
    return 'レッスン一覧 ($count レッスン)';
  }

  @override
  String skillsNoLessonLevel(String level) {
    return 'CEFR $level レベルのレッスンはありません。';
  }

  @override
  String get skillsOpenShadowing => 'シャドーイングスタジオを開く';

  @override
  String get skillsMatchingGameTitle => 'ペアマッチングゲーム';

  @override
  String get skillsFlashcard3dTitle => '3Dフラッシュカード';

  @override
  String get skillsQuizReflexTitle => '語彙反射クイズ';

  @override
  String get skillsExamHubTitle => '模擬試験ルーム';

  @override
  String get skillsSrsReviewTitle => 'SRS 間隔反復復習';

  @override
  String get exerciseListeningTitle => 'リスニング読解';

  @override
  String get exerciseReadingTitle => 'リーディング読解';

  @override
  String exerciseQuestionsCount(int count) {
    return '読解問題 ($count 問)';
  }

  @override
  String exerciseScoreResult(int correct, int total, int percent) {
    return 'スコア：$correct/$total 正解 ($percent%)';
  }

  @override
  String get exerciseShowTranscript => 'スクリプトと翻訳を表示';

  @override
  String get exerciseHideTranscript => 'スクリプトと翻訳を非表示';

  @override
  String get exerciseReadingPassage => '読解テキスト';

  @override
  String get exerciseAudioPlayer => 'オーディオプレーヤー';

  @override
  String exerciseKeyWords(int count) {
    return '重要単語 ($count 語)';
  }

  @override
  String get exerciseSubmitGrade => '提出して採点';

  @override
  String get exerciseRetake => 'レッスンをやり直す';

  @override
  String exerciseSaveWordSuccess(String term) {
    return '\"$term\" を復習＆お気に入りに保存しました！';
  }

  @override
  String get speakingTimerPractice => '時間制限付きスピーキング練習';

  @override
  String speakingRecordPrompt(int seconds) {
    return '録音中（$seconds秒）- タップして停止';
  }

  @override
  String speakingRubricSelfCheck(int checked, int total) {
    return '自己評価（$checked/$total の評価基準を達成）';
  }

  @override
  String speakingSaveSuccess(int score) {
    return 'スピーキング自己評価（$score%）を学習履歴に保存しました！';
  }

  @override
  String get writingTabScramble => '1. 文構造と並べ替え';

  @override
  String get writingTabRubric => '2. 段落ライティング＆評価';

  @override
  String get writingTapWordToForm => '下の単語をタップして正しい文を組み立ててください...';

  @override
  String get writingCheckSentence => '文を確認';

  @override
  String writingWordCountStatus(int count, int min) {
    return '語数：$count / 最低 $min 語';
  }

  @override
  String writingNeedMoreWords(int count) {
    return 'あと $count 語必要です';
  }

  @override
  String get writingSaveModelAnswer => 'エッセイを保存して模範解答を確認';

  @override
  String get writingModelAnswerTitle => '模範解答（参考）';

  @override
  String get shadowingHubTitle => '反射シャドーイングスタジオ';

  @override
  String get shadowingMethodTitle => '4ステップ・イントネーションシャドーイング法';

  @override
  String get shadowingMethodDesc =>
      '1. お手本を聞く (1.0x) → 2. 低速リスニング＆連結音の確認 (0.75x) → 3. 同期シャドーイング → 4. 率直な自己評価。';

  @override
  String shadowingLessonsList(int count) {
    return 'シャドーイングレッスン ($count レッスン)';
  }

  @override
  String get shadowingPracticeTitle => 'シャドーイング練習';

  @override
  String get shadowingStep1 => 'ステップ1：お手本音声を聞く (1.0x)';

  @override
  String get shadowingStep2 => 'ステップ2：低速で聴き込む (0.75x)';

  @override
  String get shadowingStep3 => 'ステップ3：同期シャドーイング';

  @override
  String get shadowingStep4 => 'ステップ4：自己評価（必須）';

  @override
  String shadowingSpeakingStatus(int seconds) {
    return 'シャドーイング録音中（$seconds秒）...';
  }

  @override
  String get shadowingSaveProgress => 'シャドーイング進捗を保存';

  @override
  String shadowingSavedSuccess(int score) {
    return 'シャドーイングの進捗（基準達成率 $score%）を保存しました！';
  }

  @override
  String get gamesHubTitle => '単語ミニゲームセンター';

  @override
  String get gamesHubSubtitle => 'タイピング、反射神経アリーナ、落下単語キャッチで語彙力を定着させましょう。';

  @override
  String get gamesSelectGame => 'プレイするゲームを選択：';

  @override
  String get gamesSpaceTyperTitle => 'スペースタイパー';

  @override
  String get gamesSpaceTyperDesc =>
      'アルファベットや単語を入力して隕石を破壊します。自動照準宇宙船、レーザー発射、防衛レーダー完備。';

  @override
  String get gamesArenaTitle => 'ボキャブラリーアリーナ';

  @override
  String get gamesArenaDesc => '7〜15秒の反射選択式クイズ、連続コンボボーナス、数字キー1〜4での回答に対応。';

  @override
  String get gamesWordRainTitle => '単語レイン';

  @override
  String get gamesWordRainDesc =>
      '沈んでしまう前に、ターゲットとなる日本語の意味と一致する英単語の雨粒をキャッチしましょう。';

  @override
  String get gamesPlayNow => '今すぐプレイ';

  @override
  String get gamesRules => 'ルールと遊び方';

  @override
  String gamesHighScore(int score) {
    return 'ハイスコア：$score 点';
  }

  @override
  String gamesRecentHistory(int count) {
    return '最近のゲーム履歴 ($count 試合)';
  }

  @override
  String gameScorePoints(int score) {
    return '$score 点';
  }

  @override
  String get gameOver => 'ゲームオーバー！';

  @override
  String get gameCompleted => 'ラウンドクリア！';

  @override
  String get gamePlayAgain => 'もう一度プレイ';

  @override
  String get gameBackToHub => 'ゲームハブに戻る';

  @override
  String get gameAccuracy => '正確度';

  @override
  String get gameTime => 'タイム';

  @override
  String get gameStreak => '最大連続コンボ';

  @override
  String get gameNewRecord => '🎉 自己新記録を達成しました！';

  @override
  String get gameDiffEasy => 'イージー';

  @override
  String get gameDiffMedium => 'ノーマル';

  @override
  String get gameDiffHard => 'ハード';

  @override
  String get examHubTitle => '国際認定英語試験';

  @override
  String get examHubSubtitle => '時間制限付き模試＆実践テスト（IELTS • TOEIC • CEFR）';

  @override
  String examListTitle(int count) {
    return '利用可能な試験 ($count テスト)';
  }

  @override
  String get examPracticeMode => '練習モード';

  @override
  String get examPracticeModeDesc => '時間無制限。各問題のヒントと詳細な解説をその場ですぐに確認できます。';

  @override
  String get examTimedMode => '本番モード（時間制限あり）';

  @override
  String get examTimedModeDesc => 'カウントダウンタイマー、時間切れ時の自動提出、総合スコアレポート付き。';

  @override
  String examQuestionCounter(int current, int total) {
    return '問題 $current/$total';
  }

  @override
  String get examSubmitConfirm => '試験を提出しますか？';

  @override
  String get examSubmitConfirmDesc => '試験を終了して解答を提出してもよろしいですか？';

  @override
  String get examResultTitle => '試験結果＆詳細分析レポート';

  @override
  String examScoreBand(String band) {
    return '推定スコア：$band';
  }

  @override
  String examCorrectRatio(int correct, int total, int percent) {
    return '正解数：$correct/$total 問 ($percent%)';
  }

  @override
  String get aiChatTitle => 'English Buddy AI アシスタント';

  @override
  String get aiChatSubtitle => '文法Q&A • 英文翻訳 • エッセイ添削';

  @override
  String get aiChatGreeting => 'こんにちは！英語学習で何かお手伝いできることはありますか？';

  @override
  String get aiChatGreetingDesc => '文法の質問、英文の翻訳、エッセイの添削など、何でも気軽にお尋ねください！';

  @override
  String get aiChatSuggestions => 'おすすめの質問例';

  @override
  String get aiChatInputPlaceholder => '質問、翻訳したい文、添削したいエッセイを入力...';

  @override
  String get aiChatClearTitle => '会話履歴を消去しますか？';

  @override
  String get aiChatClearDesc => 'すべてのAIチャットメッセージがこのデバイスから削除されます。この操作は元に戻せません。';

  @override
  String get aiChatClearSuccess => 'チャット履歴をすべて消去しました。';

  @override
  String get aiChatThinking => 'AIアシスタントが考え中...';

  @override
  String get authSignInTitle => 'アカウントログイン';

  @override
  String get authSignUpTitle => '新規アカウント登録';

  @override
  String get authAccountOrEmail => 'ユーザー名またはメールアドレス';

  @override
  String get authEmail => 'メールアドレス';

  @override
  String get authPassword => 'パスワード';

  @override
  String get authConfirmPassword => 'パスワード（確認）';

  @override
  String get authDisplayName => '表示名';

  @override
  String get authGoogleSignIn => 'Google で続ける';

  @override
  String get authProcessing => '処理中...';

  @override
  String get authPasswordMismatch => 'パスワードが一致しません！';

  @override
  String get authMinPassword => '8文字以上入力してください';

  @override
  String get authInvalidEmail => '有効なメールアドレスを入力してください';

  @override
  String get authOr => 'または';

  @override
  String get statsResetButton => '初期データを復元';

  @override
  String statsQuizQuestionsCount(Object correct, Object total) {
    return '$correct/$total 問正解';
  }

  @override
  String statsTopicWordsProgress(
    Object mastered,
    Object percent,
    Object total,
  ) {
    return '$mastered/$total 語習得 ($percent%)';
  }

  @override
  String get dictTitleFull => '日英・英日 双方向スマート辞書';

  @override
  String dictSearchDirection(Object flag, Object label) {
    return '検索方向：$flag $label';
  }

  @override
  String get dictViDetected => '検出：日本語 ➜ 相当する英単語を表示';

  @override
  String get dictEnDetected => '検出：英語 ➜ 日本語の意味と定義を表示';

  @override
  String get dictAllLevels => '全レベル';

  @override
  String get dictAllTopics => '全トピック';

  @override
  String get dictAllPos => '全品詞';

  @override
  String get dictIntroDesc =>
      'スマート双方向検索：日本語から相当する英単語を探すか、英語から自然な日本語の意味を調べられます。3,000語以上のCEFR A1–C1オフライン語彙に加え、オンライン拡張（Google翻訳・WiktionaryをSQLiteにキャッシュ）に対応。';

  @override
  String get dictViEnOnlinePrompt =>
      'オンラインで日英翻訳を拡張できます（英単語、定義、発音を自動取得しSQLiteにキャッシュします）。';

  @override
  String get dictEnViOnlinePrompt =>
      'オンラインで英日検索を拡張できます（日本語の意味、英語の定義、発音を自動取得しSQLiteにキャッシュします）。';

  @override
  String get dictRetry => '再試行';

  @override
  String get dictRetryConnection => '接続を再試行';

  @override
  String get dictTtsTooltip => '標準発音 (TTS)';

  @override
  String get dictInReview => '復習中';

  @override
  String get dictAddToReview => '復習に追加';

  @override
  String dictMovedToNew(Object term) {
    return '\"$term\" を新規単語に移動しました';
  }

  @override
  String dictAddedToReview(Object term) {
    return '\"$term\" を復習リストに追加しました！';
  }

  @override
  String get dictFavoriteAdd => 'この単語をお気に入りに追加';

  @override
  String get dictFavoriteRemove => 'お気に入りから削除';

  @override
  String get dictLiveApi => 'オンライン (Live API)';

  @override
  String get dictSaved => '保存済み';

  @override
  String dictViKeyword(Object query) {
    return '検索キーワード：\"$query\"';
  }

  @override
  String get dictEquivalentEnWords => '対応する英単語：';

  @override
  String dictListenTooltip(Object word) {
    return 'タップして発音を聞く：$word';
  }

  @override
  String dictViRefMeaning(Object meaning) {
    return '参照用の日本語の意味：$meaning';
  }

  @override
  String get dictViTranslation => '日本語訳：';

  @override
  String get dictOtherMeanings => 'その他の訳語：';

  @override
  String dictSourceInfo(Object license, Object source, Object url) {
    return '出典：$source • ライセンス：$license ($url)';
  }

  @override
  String dictExamplePrefix(Object example) {
    return '例：\"$example\"';
  }

  @override
  String get avatarChangePhoto => 'アバターを変更';

  @override
  String get avatarSelectFromDevice => '端末・ギャラリーから選択';

  @override
  String get avatarSelectFromUrl => '画像URLを直接入力';

  @override
  String get avatarResetDefault => 'デフォルトのアバターに戻す';

  @override
  String get avatarEnterUrlTitle => 'アバター画像URLを入力';

  @override
  String get avatarUrlPlaceholder => 'https://example.com/avatar.jpg';

  @override
  String get avatarInvalidUrl => 'URLが無効か、画像ファイルではありません';

  @override
  String get skillsSelectSkill => '練習するスキルを選択：';

  @override
  String get skillsAllLevels => 'すべてのレベル';

  @override
  String skillsQuestionsCount(Object count) {
    return '$count 問';
  }

  @override
  String skillsExerciseCount(Object count) {
    return '$count 問の練習';
  }

  @override
  String get skillsStartPractice => '練習を開始';

  @override
  String get skillsTranscriptLocked => 'スクリプトはロックされています';

  @override
  String get skillsTranscriptUnlocked => 'リスニングスクリプト';

  @override
  String get skillsSubmitExercise => '解答を提出';

  @override
  String get skillsCompleted => '完了済み';

  @override
  String skillsScore(Object score, Object total) {
    return 'スコア：$score/$total';
  }

  @override
  String get skillsTryAgain => 'もう一度挑戦';

  @override
  String get skillsNextExercise => '次の問題へ';

  @override
  String get skillsListenNormal => '通常速度 1.0x';

  @override
  String get skillsListenSlow => '低速 0.75x';

  @override
  String get skillsExplanation => '詳しい解説';

  @override
  String get skillsMatchingPairs => '単語と意味をマッチング';

  @override
  String get skillsSpeakingPrompt => '以下の文章を声に出して読んでください';

  @override
  String get skillsWritingPrompt => '指示に従って文章を書いてください';

  @override
  String gameDifficulty(Object diff) {
    return '難易度：$diff';
  }

  @override
  String gameScore(Object score) {
    return 'スコア：$score';
  }

  @override
  String gameHighScore(Object score) {
    return 'ハイスコア：$score';
  }

  @override
  String get gameExit => 'ゲームを終了';

  @override
  String gameCombo(Object multiplier) {
    return 'コンボ x$multiplier';
  }

  @override
  String gameWpm(Object wpm) {
    return '速度：$wpm WPM';
  }

  @override
  String get gameStart => 'ゲーム開始';

  @override
  String get gamePause => '一時停止';

  @override
  String get gameResume => '再開';

  @override
  String get gameRestart => 'リスタート';

  @override
  String gameLives(Object lives) {
    return '残りライフ：$lives';
  }

  @override
  String gameLevel(Object level) {
    return 'レベル：$level';
  }

  @override
  String get examMode => '試験モード';

  @override
  String examTimeRemaining(Object time) {
    return '残り時間：$time';
  }

  @override
  String get examSubmit => '試験を提出';

  @override
  String get examPassed => '合格';

  @override
  String get examFailed => '改善が必要';

  @override
  String get examScoreBreakdown => 'スコアの内訳';

  @override
  String get examReviewAnswers => '解答と解説を確認';

  @override
  String get examRetake => '試験を再受験';

  @override
  String get examBackToHub => '試験ハブに戻る';

  @override
  String get shadowingListen1 => 'ステップ1：お手本を聞く (1.0x)';

  @override
  String get shadowingListen2 => 'ステップ2：低速で聞く (0.75x)';

  @override
  String get shadowingRecord => 'ステップ3：音声をシャドーイング';

  @override
  String get shadowingStop => '録音を停止';

  @override
  String get shadowingSelfEval => 'ステップ4：自己評価';

  @override
  String get shadowingNext => '次の文へ';

  @override
  String get shadowingComplete => 'シャドーイング練習が完了しました！';

  @override
  String get authLogin => 'ログイン';

  @override
  String get authRegister => 'アカウント登録';

  @override
  String get authNoAccount => 'アカウントをお持ちでないですか？ 新規登録';

  @override
  String get authAlreadyHaveAccount => '既にアカウントをお持ちですか？ ログイン';

  @override
  String get authLogout => 'ログアウト';

  @override
  String get authLogoutConfirm => '本当にログアウトしますか？';

  @override
  String get profileTitle => 'ユーザープロフィール';

  @override
  String get profileEdit => 'プロフィール編集';

  @override
  String get profileSave => '変更を保存';

  @override
  String get profileDisplayName => '表示名';

  @override
  String get profileEmail => 'メールアドレス';

  @override
  String get profileRole => '権限ロール';

  @override
  String get profileJoined => '登録日';

  @override
  String get adminTitle => 'システム管理 (Admin)';

  @override
  String get adminUsers => 'ユーザー＆レベル管理';

  @override
  String get adminVocab => '単語＆トピック管理';

  @override
  String get adminExercises => 'リーディング＆リスニング問題';

  @override
  String get adminExams => '模擬試験管理';

  @override
  String get adminSystem => 'システム監視';

  @override
  String get adminForbidden => '管理者専用エリア (403 Forbidden)';

  @override
  String get adminRefresh => '管理データを更新';

  @override
  String get aiChatAsk => 'AIに質問する';

  @override
  String get settingsSelectLanguage => 'アプリの言語を選択';

  @override
  String get settingsSearchLanguage => '言語を検索...';

  @override
  String get settingsAllLanguages => '全13言語を表示';

  @override
  String get settingsAllLanguagesSubtitle =>
      '中国語、日本語、韓国語、フランス語、ドイツ語、スペイン語、ロシア語...';

  @override
  String get settingsDefaultBadge => 'デフォルト';

  @override
  String get profileUsernameLabel => 'ログインユーザー名 (Username)';

  @override
  String get profileUsernameHint => 'ユーザー名を入力 (3〜30文字: a-z, 0-9, ., _, -)';

  @override
  String get profileUsernameHelperPassword =>
      'このユーザー名またはメールアドレスとパスワードでログインできます。';

  @override
  String get profileUsernameHelperGoogle =>
      'Googleアカウントは引き続きGoogleでログインします。このユーザー名は固有のアカウント識別子です。';

  @override
  String get profileEmailReadOnlyHelper =>
      'ログインメール（読み取り専用・表示名やユーザー名を変更しても変わりません）';

  @override
  String get weeklyProgressTitle => '週間進捗';

  @override
  String weeklyProgressActiveDays(int count) {
    return '学習日数 $count/7日';
  }

  @override
  String weeklyProgressWordsStudied(int count) {
    return '学習・復習単語 $count語';
  }

  @override
  String weeklyProgressActivitiesDone(int count) {
    return '完了レッスン $count件';
  }

  @override
  String weeklyProgressTodayGoal(int current, int goal) {
    return '今日の単語目標: $current/$goal語';
  }

  @override
  String get weeklyProgressTodayBadge => '今日';

  @override
  String get weeklyProgressEmptyTitle => '今週の学習アクティビティはまだありません';

  @override
  String get weeklyProgressEmptyDesc =>
      '単語の学習・復習やクイズ、スキル練習を完了すると、週間グラフがすぐに更新されます！';

  @override
  String get weeklyProgressStartCta => '今すぐ単語を復習';

  @override
  String get weeklyProgressScopeNote =>
      '現在のアカウントの実際のタイムスタンプ付き学習履歴を集計しています（月曜〜日曜・現地時間）。';

  @override
  String get weeklyProgressUnitWords => '語';

  @override
  String get weeklyProgressUnitActivities => '件';

  @override
  String get aiChatErrorGeneral => 'AIからの応答を取得できませんでした';

  @override
  String get authRegisterSuccessPleaseLogin => '登録が完了しました！続行するにはログインしてください。';
}
