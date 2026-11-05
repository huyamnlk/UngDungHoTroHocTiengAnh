// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'English Buddy';

  @override
  String get navHome => 'Home';

  @override
  String get navTopics => 'Topics';

  @override
  String get navListening => 'Listening';

  @override
  String get navReading => 'Reading';

  @override
  String get navWriting => 'Writing';

  @override
  String get navSpeaking => 'Speaking';

  @override
  String get navShadowing => 'Shadowing';

  @override
  String get navDictionary => 'Vocabulary & Dictionary';

  @override
  String get navExam => 'Exams';

  @override
  String get navGames => 'Games';

  @override
  String get navReview => 'Review';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String get navAdmin => 'Admin';

  @override
  String get navSectionSkills => 'SKILLS & STUDY';

  @override
  String get navSectionSystem => 'PROGRESS & SYSTEM';

  @override
  String get sidebarExpandTooltip => 'English Buddy - Expand sidebar';

  @override
  String get sidebarCollapseTooltip => 'Collapse sidebar';

  @override
  String get mobileMenuTooltip => 'Open 13 skills and features menu';

  @override
  String get aiChatTooltip => 'English Buddy AI Assistant';

  @override
  String get aiChatQuickHelp => 'Grammar Q&A & translation';

  @override
  String get aiChatDesc =>
      'English Buddy AI Assistant (Q&A & Error Correction)';

  @override
  String get accessDeniedAdminOnly =>
      'Access denied: Admin area is restricted to Admin accounts only.';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionClose => 'Close';

  @override
  String get actionBack => 'Back';

  @override
  String get actionNext => 'Next';

  @override
  String get actionPrevious => 'Previous';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionSubmit => 'Submit';

  @override
  String get actionStart => 'Start';

  @override
  String get actionDone => 'Done';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionResetFilter => 'Reset filters';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionShowAll => 'Show all';

  @override
  String get actionExpand => 'Expand';

  @override
  String get actionCollapse => 'Collapse';

  @override
  String get actionPlay => 'Play';

  @override
  String get actionPause => 'Pause';

  @override
  String get actionResume => 'Resume';

  @override
  String get actionExit => 'Exit';

  @override
  String get actionUnderstood => 'Understood';

  @override
  String get actionCopy => 'Copy';

  @override
  String get statusActive => 'Active';

  @override
  String get statusLocked => 'Locked';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusAll => 'All';

  @override
  String get allTopics => 'All Topics';

  @override
  String get allLevels => 'All Levels';

  @override
  String get allSkills => 'All Skills';

  @override
  String get allFormats => 'All Formats';

  @override
  String get levelA1 => 'A1 - Beginner';

  @override
  String get levelA2 => 'A2 - Elementary';

  @override
  String get levelB1 => 'B1 - Intermediate';

  @override
  String get levelB2 => 'B2 - Upper Intermediate';

  @override
  String get levelC1 => 'C1 - Advanced';

  @override
  String get settingsTitle => 'Settings & Preferences';

  @override
  String get settingsLanguageSection => 'Language & Localization';

  @override
  String get settingsLanguageSubtitle =>
      'Select your preferred application language';

  @override
  String get settingsLangVi => 'Tiếng Việt';

  @override
  String get settingsLangViDesc => 'Vietnamese';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsLangEnDesc => 'English';

  @override
  String get settingsAccountSection => 'Profile & Account';

  @override
  String get settingsThemeSection => 'Interface & Theme';

  @override
  String get settingsThemeSystem => 'System Default';

  @override
  String get settingsThemeSystemDesc => 'Automatically match device appearance';

  @override
  String get settingsThemeLight => 'Light Mode';

  @override
  String get settingsThemeDark => 'Dark Mode';

  @override
  String get settingsDailyGoalSection => 'Daily Learning Goal';

  @override
  String get settingsDailyGoalSubtitle =>
      'Select how many words you want to complete each day:';

  @override
  String settingsDailyGoalUnit(int count) {
    return '$count words';
  }

  @override
  String settingsDailyGoalSaved(int count) {
    return 'Daily goal set to $count words/day!';
  }

  @override
  String get settingsSoundSection => 'Sound & Pronunciation';

  @override
  String get settingsSoundEnable => 'Enable pronunciation audio';

  @override
  String get settingsSoundEnableDesc =>
      'Native-speaker Text-to-Speech pronunciation engine';

  @override
  String get settingsCopyrightSection => 'Data Sources & Copyright';

  @override
  String get settingsCopyrightTitle => 'Transparent Copyright Policy';

  @override
  String get settingsCopyrightDesc1 =>
      '• Vocabulary content, sample sentences, and exercises are authored originally based on CEFR levels (A1–C1) and open language frameworks.';

  @override
  String get settingsCopyrightDesc2 =>
      '• We do not mass-copy copyrighted definitions or content from Cambridge Dictionary, DOL English, or commercial sources.';

  @override
  String get settingsCopyrightDesc3 =>
      '• Online lookup uses Free Dictionary API (open source, no API key required, licensed under CC BY-SA 3.0).';

  @override
  String get settingsAppSubtitle =>
      'Mobile Application Project - Flutter & SQLite';

  @override
  String get guestUser => 'Guest (Not logged in)';

  @override
  String get guestUserDesc =>
      'Not logged in. Log in or create an account to manage your profile and sync progress.';

  @override
  String authenticatedAs(String email, String provider) {
    return '$email • Verified ($provider)';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get adminArea => 'Admin Area';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Create Account';

  @override
  String get signOut => 'Sign Out';

  @override
  String get confirmSignOutTitle => 'Confirm Sign Out';

  @override
  String confirmSignOutMessage(String email) {
    return 'Are you sure you want to sign out of \"$email\"?\n\nYour current session and token will be removed. Local learning progress on this device is preserved.';
  }

  @override
  String accountMenuHeader(String displayName) {
    return 'Account ($displayName)';
  }

  @override
  String get homeGreetingGuest => 'Hello there! 👋';

  @override
  String homeGreetingUser(String name) {
    return 'Hello, $name! 👋';
  }

  @override
  String get homeSubtitle =>
      'Ready to expand your vocabulary and English mastery today?';

  @override
  String homeDayStreak(int days) {
    return '$days days';
  }

  @override
  String get homeStreakLabel => 'Day Streak';

  @override
  String homeMasteredWords(int mastered, int total) {
    return '$mastered/$total mastered';
  }

  @override
  String homeProgressSummary(int mastered, int total, int percent) {
    return 'You have mastered $mastered out of $total CEFR words ($percent% completed).';
  }

  @override
  String homeGoalTitle(int count) {
    return 'Daily Goal: $count words/day';
  }

  @override
  String homeReviewNow(int count) {
    return 'Review Now ($count words)';
  }

  @override
  String homeDueSrsCount(int count) {
    return '$count due for review';
  }

  @override
  String homeWordsToLearn(int count) {
    return '$count words to memorize';
  }

  @override
  String homeTopicCount(int count) {
    return '$count topics';
  }

  @override
  String homeTopicCefrCount(int count) {
    return '$count CEFR topics';
  }

  @override
  String get homeShortcutsTitle => 'Learning Shortcuts';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homeCardTopicsTitle => 'Vocabulary Topics';

  @override
  String get homeCardTopicsDesc => 'Explore CEFR topics';

  @override
  String get homeCardReviewTitle => 'Review List';

  @override
  String get homeCardReviewDesc => 'Words currently needing review';

  @override
  String get homeCardExamTitle => 'IELTS/TOEIC Exam Prep';

  @override
  String get homeCardExamDesc => 'Timed tests with detailed explanations';

  @override
  String get homeCardGamesTitle => 'Vocabulary Games';

  @override
  String get homeCardGamesDesc => 'Matching pairs & speed quiz';

  @override
  String get homeCardShadowingTitle => 'Reflex Shadowing';

  @override
  String get homeCardShadowingDesc => 'Sentence stress & linking sounds';

  @override
  String get homeCardDictionaryTitle => 'English - Vietnamese Dictionary';

  @override
  String get homeCardDictionaryDesc => 'Look up 3,000+ words';

  @override
  String get homeCardAiTitle => 'English Buddy AI';

  @override
  String get homeCardAiDesc => 'Grammar Q&A, lookup & essay feedback';

  @override
  String get homeCardStatsTitle => 'Progress & Statistics';

  @override
  String get homeCardStatsDesc => 'Mastered words & quiz history';

  @override
  String get homeTodayWord => 'Today\'s Vocabulary';

  @override
  String get homeChangeWord => 'New Word';

  @override
  String get homeSaveFavorite => 'Save to Favorites';

  @override
  String get homeRemoveFavorite => 'Remove from Favorites';

  @override
  String get homeListenPronunciation => 'Listen to pronunciation';

  @override
  String get homeSavedSuccess => 'Saved';

  @override
  String get topicsTitle => 'Study Topics';

  @override
  String topicsSubtitle(int count) {
    return 'Explore $count real-life vocabulary topics leveled from A1 to C1.';
  }

  @override
  String topicsCountWords(int count) {
    return '$count vocabulary items';
  }

  @override
  String topicsMasteredCount(int mastered, int total) {
    return 'Mastered: $mastered/$total';
  }

  @override
  String get topicSearchPlaceholder =>
      'Search English word or Vietnamese meaning...';

  @override
  String topicLearnFlashcard(int count) {
    return 'Learn Flashcards ($count)';
  }

  @override
  String get topicFilterAll => 'All';

  @override
  String get topicFilterNew => 'New';

  @override
  String get topicFilterReview => 'Need Review';

  @override
  String get topicFilterMastered => 'Mastered';

  @override
  String get topicEmptyWord => 'No vocabulary found';

  @override
  String get topicEmptyWordDesc =>
      'Try searching with different keywords or switch filters.';

  @override
  String get addWordTitle => 'Add New Word';

  @override
  String addWordTopicTarget(String topicName) {
    return 'Into topic: $topicName';
  }

  @override
  String get addWordEnglishLabel => 'English Word *';

  @override
  String get addWordEnglishHint => 'e.g.: Innovation';

  @override
  String get addWordMeaningLabel => 'Vietnamese Meaning *';

  @override
  String get addWordMeaningHint => 'e.g.: Sự đổi mới, cách tân';

  @override
  String get addWordIpaLabel => 'IPA Phonetic';

  @override
  String get addWordIpaHint => 'e.g.: /ˌɪn.əˈveɪ.ʃən/';

  @override
  String get addWordPartOfSpeechLabel => 'Part of Speech';

  @override
  String get addWordExampleEnLabel => 'Example Sentence (English)';

  @override
  String get addWordExampleEnHint =>
      'e.g.: Innovation drives technology forward.';

  @override
  String get addWordExampleViLabel => 'Example Sentence Translation';

  @override
  String get addWordExampleViHint =>
      'e.g.: Sự đổi mới thúc đẩy công nghệ tiến lên.';

  @override
  String get addWordNotesLabel => 'Notes / Pronunciation Tips';

  @override
  String get addWordNotesHint => 'e.g.: Stress on 3rd syllable';

  @override
  String get addWordSaveButton => 'Save Word';

  @override
  String get addWordRequiredEnglish => 'Please enter the English word';

  @override
  String get addWordRequiredMeaning => 'Please enter the Vietnamese meaning';

  @override
  String addWordSuccess(String term) {
    return 'Added \"$term\" successfully!';
  }

  @override
  String get flashcardTapToFlip => 'Tap card to flip to word';

  @override
  String get flashcardTapToMeaning => 'Tap card to view meaning';

  @override
  String get flashcardVietnameseMeaning => 'VIETNAMESE MEANING';

  @override
  String get flashcardNeedReview => 'Need Review';

  @override
  String get flashcardMastered => 'Mastered';

  @override
  String get flashcardCompletedTitle => 'Awesome! You have completed!';

  @override
  String flashcardCompletedDesc(int count) {
    return 'You just finished reviewing $count flashcards.';
  }

  @override
  String get flashcardReviewAgain => 'Review Again';

  @override
  String get flashcardBack => 'Back to Previous Page';

  @override
  String get flashcardEmpty => 'No vocabulary available for review.';

  @override
  String get quizSetupTitle => 'Quiz Challenge';

  @override
  String get quizSetupHeader => 'Speed & Reflex Quiz';

  @override
  String get quizSetupSubtitle =>
      'Reinforce vocabulary through diverse formats: Meaning selection, word selection, and contextual fill-in-the-blank.';

  @override
  String get quizSetupSelectTopic => 'Select Quiz Topic';

  @override
  String get quizSetupAllTopics => 'Comprehensive (All Topics)';

  @override
  String get quizSetupAllTopicsDesc =>
      'Randomly drawn from entire vocabulary database';

  @override
  String get quizSetupQuestionCount => 'Number of Questions';

  @override
  String get quizSetupCountFast => '5 questions (Quick)';

  @override
  String get quizSetupCountStandard => '10 questions (Standard)';

  @override
  String get quizSetupStart => 'Start Quiz';

  @override
  String get quizPlayTitle => 'Quiz Challenge';

  @override
  String quizPlayQuestionCounter(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get quizPlayTypeSelectMeaning =>
      'Select the correct Vietnamese meaning';

  @override
  String get quizPlayTypeSelectWord => 'Select the correct English word';

  @override
  String get quizPlayTypeFillBlank => 'Fill in the blank with the correct word';

  @override
  String get quizPlayCheck => 'Check';

  @override
  String get quizPlayNext => 'Next Question';

  @override
  String get quizPlayViewResult => 'View Results';

  @override
  String get quizPlayCorrect => 'Correct!';

  @override
  String get quizPlayIncorrect => 'Incorrect!';

  @override
  String get quizPlayExitTitle => 'Quit quiz?';

  @override
  String get quizPlayExitMessage =>
      'Current quiz progress will not be saved if you leave now.';

  @override
  String get quizPlayContinue => 'Continue Quiz';

  @override
  String get quizResultTitle => 'Quiz Results';

  @override
  String quizResultScore(int correct, int total) {
    return 'Correct $correct / $total questions';
  }

  @override
  String get quizResultExcellent => 'Outstanding!';

  @override
  String get quizResultGood => 'Great Job!';

  @override
  String get quizResultNeedsWork => 'Keep Practicing!';

  @override
  String get quizResultDescExcellent =>
      'You have a solid command of the words in this quiz. Keep it up!';

  @override
  String get quizResultDescGood =>
      'Well done! Incorrect words have been automatically saved to \"Need Review\" for further practice.';

  @override
  String get quizResultDescNeedsWork =>
      'Don\'t be discouraged! Review the flashcards and give it another try.';

  @override
  String get quizResultDetails => 'Answer Breakdown';

  @override
  String get quizResultRetake => 'Retake Quiz';

  @override
  String get quizResultHome => 'Back to Home';

  @override
  String quizResultUserSelected(String answer) {
    return 'Your choice: $answer';
  }

  @override
  String quizResultCorrectIs(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get reviewTitle => 'Review & Favorites';

  @override
  String reviewTabNeedReview(int count) {
    return 'Need Review ($count)';
  }

  @override
  String reviewTabFavorites(int count) {
    return 'Favorites ($count)';
  }

  @override
  String get reviewEmptyNeedReview => 'No words due for review';

  @override
  String get reviewEmptyNeedReviewDesc =>
      'When you mark a word as \"Need Review\" in Flashcards or answer incorrectly in Quizzes, it will automatically appear here based on Spaced Repetition.';

  @override
  String get reviewEmptyFavorites => 'No favorite words yet';

  @override
  String get reviewEmptyFavoritesDesc =>
      'Tap the heart icon on any word to bookmark and revisit it here.';

  @override
  String get reviewLearnFlashcardsNeed => 'Flashcards (Need Review)';

  @override
  String get reviewLearnFlashcardsFav => 'Flashcards (Favorites)';

  @override
  String reviewTotalWords(int count) {
    return 'Total: $count words';
  }

  @override
  String get reviewViewStats => 'View Progress Statistics';

  @override
  String get wordDetailTitle => 'Word Details';

  @override
  String get wordDetailVietnameseDef => 'VIETNAMESE DEFINITION';

  @override
  String get wordDetailSrsTitle => 'Spaced Repetition System (SRS)';

  @override
  String wordDetailInterval(int days) {
    return 'Interval: $days days';
  }

  @override
  String wordDetailReviewCount(int count) {
    return 'Review count: $count';
  }

  @override
  String get wordDetailRealWorldExample => 'Real-World Context Example';

  @override
  String wordDetailSynonyms(String synonyms) {
    return 'Synonyms: $synonyms';
  }

  @override
  String wordDetailAntonyms(String antonyms) {
    return 'Antonyms: $antonyms';
  }

  @override
  String get wordDetailTips => 'Memory & Pronunciation Tips';

  @override
  String get wordDetailAddedFav => 'Added to Favorites';

  @override
  String get wordDetailRemovedFav => 'Removed from Favorites';

  @override
  String get statsTitle => 'Statistics & Progress';

  @override
  String get statsOverallProgress => 'Overall Learning Progress';

  @override
  String statsMasteredRatio(int mastered, int total) {
    return 'Mastered $mastered/$total words';
  }

  @override
  String get statsTotalWords => 'Total Vocabulary';

  @override
  String get statsMasteredWords => 'Mastered';

  @override
  String get statsNeedReviewWords => 'Need Review';

  @override
  String get statsFavoriteWords => 'Favorites';

  @override
  String get statsTopicProgress => 'Progress by Topic';

  @override
  String get statsQuizHistory => 'Quiz History';

  @override
  String statsAverageScore(String score) {
    return 'Avg: $score%';
  }

  @override
  String get statsEmptyQuiz =>
      'No quiz history yet. Take a quiz to test your reflexes!';

  @override
  String get statsResetTitle => 'Reset data?';

  @override
  String get statsResetMessage =>
      'All study states, quiz history, and custom vocabulary will be reset to application defaults.';

  @override
  String get statsResetConfirm => 'Confirm Reset';

  @override
  String get statsResetSuccess =>
      'Successfully restored initial application data!';

  @override
  String get dictTitle => 'Bilingual Dictionary';

  @override
  String get dictSearchPlaceholder =>
      'Bilingual lookup: type Vietnamese (căn hộ) or English (apartment)...';

  @override
  String get dictRecentSearches => 'Recent Searches';

  @override
  String get dictClearHistory => 'Clear History';

  @override
  String get dictOnlineViEn => 'Online Translate Vietnamese ➔ English';

  @override
  String get dictOnlineEnVi => 'Online Lookup English ➔ Vietnamese';

  @override
  String dictOnlineViEnQuery(String query) {
    return 'Online Translate Vietnamese ➔ English for \"$query\"';
  }

  @override
  String dictOnlineEnViQuery(String query) {
    return 'Online Lookup English ➔ Vietnamese for \"$query\"';
  }

  @override
  String dictNotFoundInternal(String query) {
    return 'Could not find \"$query\" in internal dictionary.';
  }

  @override
  String get dictListenWord => 'Listen to native pronunciation';

  @override
  String get dictCachedBadge => 'SQLite Cached (Offline)';

  @override
  String get dictSaveToReview => 'Save to Review';

  @override
  String dictSavedSuccess(String term) {
    return 'Saved \"$term\" to vocabulary & review list!';
  }

  @override
  String get dictEnglishDefinitions => 'English Definitions & Examples:';

  @override
  String dictSynonymsList(String synonyms) {
    return 'Synonyms: $synonyms';
  }

  @override
  String get dictNoun => 'Noun (n)';

  @override
  String get dictVerb => 'Verb (v)';

  @override
  String get dictAdj => 'Adjective (adj)';

  @override
  String get dictAdv => 'Adverb (adv)';

  @override
  String get dictPhrase => 'Phrase / Idiom';

  @override
  String get skillsHubTitle => '4 Skills & Vocabulary Practice';

  @override
  String get skillsHubAllLevels => 'Show all levels (A1–C1)';

  @override
  String get skillsListening => 'Listening';

  @override
  String get skillsReading => 'Reading';

  @override
  String get skillsWriting => 'Writing';

  @override
  String get skillsSpeaking => 'Speaking';

  @override
  String get skillsListeningDesc =>
      'Standard (1.0x) or slow (0.75x) audio. Transcripts and translations locked until submission.';

  @override
  String get skillsReadingDesc =>
      'Graded A1–C1 texts, multiple-choice & fill-in-the-blank questions, full explanations.';

  @override
  String get skillsWritingDesc =>
      'Sentence scramble and rubric-based essay writing with model answers.';

  @override
  String get skillsSpeakingDesc =>
      'Pronunciation, sentence stress, linking sounds, and 4-criterion rubric self-evaluation.';

  @override
  String get skillsStartLearning => 'Practice Now';

  @override
  String skillsProgressText(int completed, int total) {
    return 'Progress: $completed/$total lessons completed';
  }

  @override
  String skillsCompletedBadge(int score) {
    return 'Completed • $score%';
  }

  @override
  String skillsLessonList(int count) {
    return 'Lesson List ($count lessons)';
  }

  @override
  String skillsNoLessonLevel(String level) {
    return 'No lessons available at CEFR $level.';
  }

  @override
  String get skillsOpenShadowing => 'Open Shadowing Studio';

  @override
  String get skillsMatchingGameTitle => 'Matching Pairs Game';

  @override
  String get skillsFlashcard3dTitle => '3D Flashcards';

  @override
  String get skillsQuizReflexTitle => 'Vocabulary Reflex Quiz';

  @override
  String get skillsExamHubTitle => 'Timed Exam Room';

  @override
  String get skillsSrsReviewTitle => 'SRS Spaced Repetition';

  @override
  String get exerciseListeningTitle => 'Listening Comprehension';

  @override
  String get exerciseReadingTitle => 'Reading Comprehension';

  @override
  String exerciseQuestionsCount(int count) {
    return 'Comprehension Questions ($count questions)';
  }

  @override
  String exerciseScoreResult(int correct, int total, int percent) {
    return 'Score: $correct/$total correct ($percent%)';
  }

  @override
  String get exerciseShowTranscript => 'Show Transcript & Translation';

  @override
  String get exerciseHideTranscript => 'Hide Transcript & Translation';

  @override
  String get exerciseReadingPassage => 'Reading Passage';

  @override
  String get exerciseAudioPlayer => 'Audio Player';

  @override
  String exerciseKeyWords(int count) {
    return 'Key Vocabulary ($count words)';
  }

  @override
  String get exerciseSubmitGrade => 'Submit & Grade';

  @override
  String get exerciseRetake => 'Retake Lesson';

  @override
  String exerciseSaveWordSuccess(String term) {
    return 'Saved \"$term\" to Review & Favorites!';
  }

  @override
  String get speakingTimerPractice => 'Timed Speaking Practice';

  @override
  String speakingRecordPrompt(int seconds) {
    return 'Recording (${seconds}s) - Tap to stop';
  }

  @override
  String speakingRubricSelfCheck(int checked, int total) {
    return 'Self-Evaluation ($checked/$total criteria met)';
  }

  @override
  String speakingSaveSuccess(int score) {
    return 'Saved speaking self-evaluation ($score%) to learning history!';
  }

  @override
  String get writingTabScramble => '1. Sentence Structure & Scramble';

  @override
  String get writingTabRubric => '2. Paragraph Writing & Rubric';

  @override
  String get writingTapWordToForm => 'Tap words below to form a sentence...';

  @override
  String get writingCheckSentence => 'Check Sentence';

  @override
  String writingWordCountStatus(int count, int min) {
    return 'Words: $count / min $min words';
  }

  @override
  String writingNeedMoreWords(int count) {
    return 'Need $count more words';
  }

  @override
  String get writingSaveModelAnswer => 'Save Essay & Unlock Model Answer';

  @override
  String get writingModelAnswerTitle => 'Model Answer (Reference)';

  @override
  String get shadowingHubTitle => 'Reflex Shadowing Studio';

  @override
  String get shadowingMethodTitle => '4-Step Intonation Shadowing Method';

  @override
  String get shadowingMethodDesc =>
      '1. Listen to model (1.0x) → 2. Slow listening & liaison analysis (0.75x) → 3. Synchronous shadowing → 4. Honest self-evaluation.';

  @override
  String shadowingLessonsList(int count) {
    return 'Shadowing Lessons ($count lessons)';
  }

  @override
  String get shadowingPracticeTitle => 'Shadowing Practice';

  @override
  String get shadowingStep1 => 'Step 1: Listen to Model (1.0x)';

  @override
  String get shadowingStep2 => 'Step 2: Slow Listening (0.75x)';

  @override
  String get shadowingStep3 => 'Step 3: Synchronous Shadowing';

  @override
  String get shadowingStep4 => 'Step 4: Self-Evaluation (Required)';

  @override
  String shadowingSpeakingStatus(int seconds) {
    return 'Shadowing in progress (${seconds}s)...';
  }

  @override
  String get shadowingSaveProgress => 'Save Shadowing Progress';

  @override
  String shadowingSavedSuccess(int score) {
    return 'Saved Shadowing lesson progress ($score% criteria met) to database!';
  }

  @override
  String get gamesHubTitle => 'Vocabulary Mini-Games Center';

  @override
  String get gamesHubSubtitle =>
      'Boost vocabulary retention through fast-paced typing, reflex arenas, and falling word challenges.';

  @override
  String get gamesSelectGame => 'Select a game to start:';

  @override
  String get gamesSpaceTyperTitle => 'Space Typer';

  @override
  String get gamesSpaceTyperDesc =>
      'Type letters and words to destroy asteroids. Auto-aligning starship, laser fire, defensive radar.';

  @override
  String get gamesArenaTitle => 'Vocabulary Arena';

  @override
  String get gamesArenaDesc =>
      '7-15s reflex multiple-choice, streak combos, computer number keys 1-4 supported.';

  @override
  String get gamesWordRainTitle => 'Vocabulary Rain';

  @override
  String get gamesWordRainDesc =>
      'Catch falling English raindrops matching the Vietnamese target meaning before they sink.';

  @override
  String get gamesPlayNow => 'Play Now';

  @override
  String get gamesRules => 'Rules & Instructions';

  @override
  String gamesHighScore(int score) {
    return 'High Score: $score pts';
  }

  @override
  String gamesRecentHistory(int count) {
    return 'Recent Game History ($count matches)';
  }

  @override
  String gameScorePoints(int score) {
    return '$score pts';
  }

  @override
  String get gameOver => 'Game Over!';

  @override
  String get gameCompleted => 'Round Completed!';

  @override
  String get gamePlayAgain => 'Play Again';

  @override
  String get gameBackToHub => 'Back to Games Hub';

  @override
  String get gameAccuracy => 'Accuracy';

  @override
  String get gameTime => 'Time';

  @override
  String get gameStreak => 'Max Streak';

  @override
  String get gameNewRecord => '🎉 NEW PERSONAL RECORD!';

  @override
  String get gameDiffEasy => 'Easy';

  @override
  String get gameDiffMedium => 'Medium';

  @override
  String get gameDiffHard => 'Hard';

  @override
  String get examHubTitle => 'International Certification Exams';

  @override
  String get examHubSubtitle =>
      'Timed Practice & Simulation Tests (IELTS • TOEIC • CEFR)';

  @override
  String examListTitle(int count) {
    return 'Available Exams ($count tests)';
  }

  @override
  String get examPracticeMode => 'Practice Mode';

  @override
  String get examPracticeModeDesc =>
      'Untimed, view hints and in-depth explanations per question immediately.';

  @override
  String get examTimedMode => 'Exam Mode (Timed)';

  @override
  String get examTimedModeDesc =>
      'Countdown timer, auto-submit when time expires, comprehensive score report.';

  @override
  String examQuestionCounter(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get examSubmitConfirm => 'Submit Exam?';

  @override
  String get examSubmitConfirmDesc =>
      'Are you sure you want to finish and submit your exam?';

  @override
  String get examResultTitle => 'Exam Results & In-Depth Analysis';

  @override
  String examScoreBand(String band) {
    return 'Estimated Score: $band';
  }

  @override
  String examCorrectRatio(int correct, int total, int percent) {
    return 'Correct: $correct/$total questions ($percent%)';
  }

  @override
  String get aiChatTitle => 'English Buddy AI Assistant';

  @override
  String get aiChatSubtitle =>
      'Grammar Q&A • Sentence Translation • Essay Feedback';

  @override
  String get aiChatGreeting =>
      'Hello! How can I assist you with English today?';

  @override
  String get aiChatGreetingDesc =>
      'Ask me any grammar question, request sentence translations, or ask for essay feedback!';

  @override
  String get aiChatSuggestions => 'SUGGESTED PRACTICE QUESTIONS';

  @override
  String get aiChatInputPlaceholder =>
      'Type your question, sentence to translate, or essay...';

  @override
  String get aiChatClearTitle => 'Clear conversation?';

  @override
  String get aiChatClearDesc =>
      'All AI chat messages will be wiped from this device. This action cannot be undone.';

  @override
  String get aiChatClearSuccess => 'Successfully cleared all chat history.';

  @override
  String get aiChatThinking => 'AI Assistant is thinking...';

  @override
  String get authSignInTitle => 'Account Sign In';

  @override
  String get authSignUpTitle => 'Create New Account';

  @override
  String get authAccountOrEmail => 'Username or Email';

  @override
  String get authEmail => 'Email Address';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authDisplayName => 'Display Name';

  @override
  String get authGoogleSignIn => 'Continue with Google';

  @override
  String get authProcessing => 'Processing...';

  @override
  String get authPasswordMismatch => 'Passwords do not match!';

  @override
  String get authMinPassword => 'At least 8 characters';

  @override
  String get authInvalidEmail => 'Enter a valid email address';

  @override
  String get authOr => 'OR';

  @override
  String get statsResetButton => 'Restore initial data';

  @override
  String statsQuizQuestionsCount(Object correct, Object total) {
    return '$correct/$total questions';
  }

  @override
  String statsTopicWordsProgress(
    Object mastered,
    Object percent,
    Object total,
  ) {
    return '$mastered/$total words ($percent%)';
  }

  @override
  String get dictTitleFull =>
      'Bilingual Dictionary Vietnamese – English & English – Vietnamese';

  @override
  String dictSearchDirection(Object flag, Object label) {
    return 'Lookup direction: $flag $label';
  }

  @override
  String get dictViDetected =>
      'Detected: Vietnamese ➜ Showing equivalent English words';

  @override
  String get dictEnDetected =>
      'Detected: English ➜ Showing Vietnamese meaning & definitions';

  @override
  String get dictAllLevels => 'All levels';

  @override
  String get dictAllTopics => 'All topics';

  @override
  String get dictAllPos => 'All parts of speech';

  @override
  String get dictIntroDesc =>
      'Smart two-way lookup: type Vietnamese to find equivalent English terms, or type English for Vietnamese meanings. Over 3,000+ CEFR A1–C1 words offline with online expansion (Google Translate & Wiktionary cached in SQLite).';

  @override
  String get dictViEnOnlinePrompt =>
      'You can expand translation online from Vietnamese ➔ English (automatically fetches equivalent English words, definitions, pronunciation, and caches in SQLite).';

  @override
  String get dictEnViOnlinePrompt =>
      'You can expand lookup online from English ➔ Vietnamese (Vietnamese meaning, English definitions, pronunciation, and caches in SQLite).';

  @override
  String get dictRetry => 'Retry';

  @override
  String get dictRetryConnection => 'Retry connection';

  @override
  String get dictTtsTooltip => 'Standard pronunciation (TTS)';

  @override
  String get dictInReview => 'In review';

  @override
  String get dictAddToReview => 'Add to Review';

  @override
  String dictMovedToNew(Object term) {
    return 'Moved \"$term\" to new words';
  }

  @override
  String dictAddedToReview(Object term) {
    return 'Added \"$term\" to Review list!';
  }

  @override
  String get dictFavoriteAdd => 'Favorite this word';

  @override
  String get dictFavoriteRemove => 'Remove from favorites';

  @override
  String get dictLiveApi => 'Online (Live API)';

  @override
  String get dictSaved => 'Saved';

  @override
  String dictViKeyword(Object query) {
    return 'Vietnamese keyword: \"$query\"';
  }

  @override
  String get dictEquivalentEnWords => 'Equivalent English words:';

  @override
  String dictListenTooltip(Object word) {
    return 'Tap to listen: $word';
  }

  @override
  String dictViRefMeaning(Object meaning) {
    return 'Cross-reference Vietnamese meaning: $meaning';
  }

  @override
  String get dictViTranslation => 'Vietnamese translation:';

  @override
  String get dictOtherMeanings => 'Other translations:';

  @override
  String dictSourceInfo(Object license, Object source, Object url) {
    return 'Source: $source • License: $license ($url)';
  }

  @override
  String dictExamplePrefix(Object example) {
    return 'Ex: \"$example\"';
  }

  @override
  String get avatarChangePhoto => 'Change avatar';

  @override
  String get avatarSelectFromDevice => 'Choose from device / Gallery';

  @override
  String get avatarSelectFromUrl => 'Enter image URL directly';

  @override
  String get avatarResetDefault => 'Reset to default avatar';

  @override
  String get avatarEnterUrlTitle => 'Enter avatar URL';

  @override
  String get avatarUrlPlaceholder => 'https://example.com/avatar.jpg';

  @override
  String get avatarInvalidUrl => 'Invalid URL or not an image';

  @override
  String get skillsSelectSkill => 'Select a skill to practice:';

  @override
  String get skillsAllLevels => 'All levels';

  @override
  String skillsQuestionsCount(Object count) {
    return '$count questions';
  }

  @override
  String skillsExerciseCount(Object count) {
    return '$count exercises';
  }

  @override
  String get skillsStartPractice => 'Start practice';

  @override
  String get skillsTranscriptLocked => 'Transcript locked';

  @override
  String get skillsTranscriptUnlocked => 'Listening Transcript';

  @override
  String get skillsSubmitExercise => 'Submit exercise';

  @override
  String get skillsCompleted => 'Completed';

  @override
  String skillsScore(Object score, Object total) {
    return 'Score: $score/$total';
  }

  @override
  String get skillsTryAgain => 'Try again';

  @override
  String get skillsNextExercise => 'Next exercise';

  @override
  String get skillsListenNormal => 'Normal speed 1.0x';

  @override
  String get skillsListenSlow => 'Slow speed 0.75x';

  @override
  String get skillsExplanation => 'Detailed explanation';

  @override
  String get skillsMatchingPairs => 'Match words with their meanings';

  @override
  String get skillsSpeakingPrompt => 'Read the following passage aloud';

  @override
  String get skillsWritingPrompt => 'Write according to prompt';

  @override
  String gameDifficulty(Object diff) {
    return 'Difficulty: $diff';
  }

  @override
  String gameScore(Object score) {
    return 'Score: $score';
  }

  @override
  String gameHighScore(Object score) {
    return 'High score: $score';
  }

  @override
  String get gameExit => 'Exit game';

  @override
  String gameCombo(Object multiplier) {
    return 'Combo x$multiplier';
  }

  @override
  String gameWpm(Object wpm) {
    return 'Speed: $wpm WPM';
  }

  @override
  String get gameStart => 'Start Game';

  @override
  String get gamePause => 'Pause';

  @override
  String get gameResume => 'Resume';

  @override
  String get gameRestart => 'Restart';

  @override
  String gameLives(Object lives) {
    return 'Lives: $lives';
  }

  @override
  String gameLevel(Object level) {
    return 'Level: $level';
  }

  @override
  String get examMode => 'Exam mode';

  @override
  String examTimeRemaining(Object time) {
    return 'Time remaining: $time';
  }

  @override
  String get examSubmit => 'Submit exam';

  @override
  String get examPassed => 'Passed';

  @override
  String get examFailed => 'Needs improvement';

  @override
  String get examScoreBreakdown => 'Score breakdown';

  @override
  String get examReviewAnswers => 'Review answers & Explanations';

  @override
  String get examRetake => 'Retake exam';

  @override
  String get examBackToHub => 'Back to Exam Hub';

  @override
  String get shadowingListen1 => 'Step 1: Listen model (1.0x)';

  @override
  String get shadowingListen2 => 'Step 2: Listen slow (0.75x)';

  @override
  String get shadowingRecord => 'Step 3: Shadow the audio';

  @override
  String get shadowingStop => 'Stop recording';

  @override
  String get shadowingSelfEval => 'Step 4: Self evaluation';

  @override
  String get shadowingNext => 'Next sentence';

  @override
  String get shadowingComplete => 'Shadowing practice completed!';

  @override
  String get authLogin => 'Sign In';

  @override
  String get authRegister => 'Sign Up';

  @override
  String get authNoAccount => 'Don\'t have an account? Sign up';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get authLogout => 'Sign Out';

  @override
  String get authLogoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get profileTitle => 'User Profile';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileSave => 'Save Profile Changes';

  @override
  String get profileDisplayName => 'Display Name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileRole => 'Role';

  @override
  String get profileJoined => 'Joined Date';

  @override
  String get adminTitle => 'System Administration (Admin)';

  @override
  String get adminUsers => 'Users & Levels';

  @override
  String get adminVocab => 'Vocabulary & Topics';

  @override
  String get adminExercises => 'Reading & Listening';

  @override
  String get adminExams => 'Practice Exams';

  @override
  String get adminSystem => 'System Monitoring';

  @override
  String get adminForbidden => 'Admin Only Area (403 Forbidden)';

  @override
  String get adminRefresh => 'Refresh admin data';

  @override
  String get aiChatAsk => 'Ask AI';

  @override
  String get settingsSelectLanguage => 'Select App Language';

  @override
  String get settingsSearchLanguage => 'Search language...';

  @override
  String get settingsAllLanguages => 'See all 13 languages';

  @override
  String get settingsAllLanguagesSubtitle =>
      'Chinese, Japanese, Korean, French, German, Spanish, Russian...';

  @override
  String get settingsDefaultBadge => 'Default';

  @override
  String get profileUsernameLabel => 'Login Username';

  @override
  String get profileUsernameHint =>
      'Enter username (3–30 chars: a-z, 0-9, ., _, -)';

  @override
  String get profileUsernameHelperPassword =>
      'You can sign in using either this username or your email with your password.';

  @override
  String get profileUsernameHelperGoogle =>
      'Google accounts continue signing in with Google; this username serves as your unique account handle.';

  @override
  String get profileEmailReadOnlyHelper =>
      'Login email (read-only, unchanged when updating display name or username)';

  @override
  String get weeklyProgressTitle => 'Weekly Progress';

  @override
  String weeklyProgressActiveDays(int count) {
    return '$count/7 active days';
  }

  @override
  String weeklyProgressWordsStudied(int count) {
    return '$count words studied/reviewed';
  }

  @override
  String weeklyProgressActivitiesDone(int count) {
    return '$count activities completed';
  }

  @override
  String weeklyProgressTodayGoal(int current, int goal) {
    return 'Today word goal: $current/$goal words';
  }

  @override
  String get weeklyProgressTodayBadge => 'Today';

  @override
  String get weeklyProgressEmptyTitle =>
      'No learning activity recorded this week yet';

  @override
  String get weeklyProgressEmptyDesc =>
      'Study or review vocabulary, complete a quiz, or practice skills to see your weekly chart update immediately!';

  @override
  String get weeklyProgressStartCta => 'Review vocabulary now';

  @override
  String get weeklyProgressScopeNote =>
      'Tracks real timestamped learning events for the current account (Monday – Sunday in local time).';

  @override
  String get weeklyProgressUnitWords => 'words';

  @override
  String get weeklyProgressUnitActivities => 'acts';

  @override
  String get aiChatErrorGeneral => 'Unable to receive AI response';

  @override
  String get authRegisterSuccessPleaseLogin =>
      'Registration successful! Please log in to continue.';
}
