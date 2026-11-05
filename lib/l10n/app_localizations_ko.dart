// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'English Buddy';

  @override
  String get navHome => '홈';

  @override
  String get navTopics => '주제별 단어';

  @override
  String get navListening => '듣기 연습';

  @override
  String get navReading => '읽기 연습';

  @override
  String get navWriting => '쓰기 연습';

  @override
  String get navSpeaking => '말하기 연습';

  @override
  String get navShadowing => '쉐도잉';

  @override
  String get navDictionary => '단어 및 사전';

  @override
  String get navExam => '모의시험';

  @override
  String get navGames => '미니게임';

  @override
  String get navReview => '복습 목록';

  @override
  String get navStats => '학습 통계';

  @override
  String get navSettings => '설정';

  @override
  String get navAdmin => '관리자';

  @override
  String get navSectionSkills => '영역별 학습';

  @override
  String get navSectionSystem => '진도 및 시스템';

  @override
  String get sidebarExpandTooltip => 'English Buddy - 사이드바 펼치기';

  @override
  String get sidebarCollapseTooltip => '사이드바 접기';

  @override
  String get mobileMenuTooltip => '13가지 학습 기능 메뉴 열기';

  @override
  String get aiChatTooltip => 'English Buddy AI 학습 도우미';

  @override
  String get aiChatQuickHelp => '문법 질문 & 문장 번역';

  @override
  String get aiChatDesc => 'English Buddy AI 도우미 (질의응답 및 영작 첨삭)';

  @override
  String get accessDeniedAdminOnly => '접근 거부: 관리자 영역은 관리자 계정만 이용할 수 있습니다.';

  @override
  String get actionSave => '저장';

  @override
  String get actionCancel => '취소';

  @override
  String get actionConfirm => '확인';

  @override
  String get actionDelete => '삭제';

  @override
  String get actionEdit => '수정';

  @override
  String get actionClose => '닫기';

  @override
  String get actionBack => '뒤로';

  @override
  String get actionNext => '다음';

  @override
  String get actionPrevious => '이전';

  @override
  String get actionContinue => '계속';

  @override
  String get actionRetry => '다시 시도';

  @override
  String get actionSubmit => '제출';

  @override
  String get actionStart => '시작';

  @override
  String get actionDone => '완료';

  @override
  String get actionSearch => '검색';

  @override
  String get actionFilter => '필터';

  @override
  String get actionReset => '초기화';

  @override
  String get actionResetFilter => '필터 초기화';

  @override
  String get actionClear => '지우기';

  @override
  String get actionShowAll => '전체 보기';

  @override
  String get actionExpand => '펼치기';

  @override
  String get actionCollapse => '접기';

  @override
  String get actionPlay => '재생';

  @override
  String get actionPause => '일시정지';

  @override
  String get actionResume => '다시 재생';

  @override
  String get actionExit => '종료';

  @override
  String get actionUnderstood => '확인했습니다';

  @override
  String get actionCopy => '복사';

  @override
  String get statusActive => '진행 중';

  @override
  String get statusLocked => '잠김';

  @override
  String get statusCompleted => '완료됨';

  @override
  String get statusPending => '대기 중';

  @override
  String get statusAll => '전체';

  @override
  String get allTopics => '모든 주제';

  @override
  String get allLevels => '모든 레벨';

  @override
  String get allSkills => '모든 영역';

  @override
  String get allFormats => '모든 유형';

  @override
  String get levelA1 => 'A1 - 입문';

  @override
  String get levelA2 => 'A2 - 초급';

  @override
  String get levelB1 => 'B1 - 중급';

  @override
  String get levelB2 => 'B2 - 중상급';

  @override
  String get levelC1 => 'C1 - 고급';

  @override
  String get settingsTitle => '설정 및 환경설정';

  @override
  String get settingsLanguageSection => '언어 및 현지화';

  @override
  String get settingsLanguageSubtitle => '애플리케이션 표시 언어를 선택하세요';

  @override
  String get settingsLangVi => 'Tiếng Việt';

  @override
  String get settingsLangViDesc => '베트남어';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsLangEnDesc => '영어';

  @override
  String get settingsAccountSection => '프로필 및 계정';

  @override
  String get settingsThemeSection => '화면 및 테마';

  @override
  String get settingsThemeSystem => '시스템 기본값';

  @override
  String get settingsThemeSystemDesc => '기기의 화면 설정에 맞춤';

  @override
  String get settingsThemeLight => '라이트 모드';

  @override
  String get settingsThemeDark => '다크 모드';

  @override
  String get settingsDailyGoalSection => '일일 학습 목표';

  @override
  String get settingsDailyGoalSubtitle => '매일 학습할 단어 수를 선택하세요:';

  @override
  String settingsDailyGoalUnit(int count) {
    return '$count개 단어';
  }

  @override
  String settingsDailyGoalSaved(int count) {
    return '일일 학습 목표가 하루 $count개로 설정되었습니다!';
  }

  @override
  String get settingsSoundSection => '소리 및 발음';

  @override
  String get settingsSoundEnable => '발음 음성 활성화';

  @override
  String get settingsSoundEnableDesc => '원어민 음성 합성(TTS) 엔진 사용';

  @override
  String get settingsCopyrightSection => '데이터 출처 및 저작권';

  @override
  String get settingsCopyrightTitle => '투명한 저작권 정책';

  @override
  String get settingsCopyrightDesc1 =>
      '• 어휘 콘텐츠, 예문, 연습문제는 CEFR 레벨(A1–C1) 및 공개 언어 프레임워크를 기반으로 독자적으로 제작되었습니다.';

  @override
  String get settingsCopyrightDesc2 =>
      '• Cambridge Dictionary, DOL English 등 상용 서비스의 저작권 보호 콘텐츠를 무단 복제하지 않습니다.';

  @override
  String get settingsCopyrightDesc3 =>
      '• 온라인 단어 검색은 Free Dictionary API(오픈 소스, API 키 불필요, CC BY-SA 3.0 라이선스)를 사용합니다.';

  @override
  String get settingsAppSubtitle => '모바일 애플리케이션 프로젝트 - Flutter & SQLite';

  @override
  String get guestUser => '게스트 (로그인되지 않음)';

  @override
  String get guestUserDesc =>
      '로그인되지 않았습니다. 프로필 관리 및 학습 진도 동기화를 위해 로그인하거나 새 계정을 만드세요.';

  @override
  String authenticatedAs(String email, String provider) {
    return '$email • 인증됨 ($provider)';
  }

  @override
  String get editProfile => '프로필 수정';

  @override
  String get adminArea => '관리자 페이지';

  @override
  String get signIn => '로그인';

  @override
  String get signUp => '회원가입';

  @override
  String get signOut => '로그아웃';

  @override
  String get confirmSignOutTitle => '로그아웃 확인';

  @override
  String confirmSignOutMessage(String email) {
    return '\"$email\" 계정에서 로그아웃하시겠습니까?\n\n현재 세션과 토큰이 삭제됩니다. 기기에 저장된 로컬 학습 진행 데이터는 유지됩니다.';
  }

  @override
  String accountMenuHeader(String displayName) {
    return '계정 ($displayName)';
  }

  @override
  String get homeGreetingGuest => '안녕하세요! 👋';

  @override
  String homeGreetingUser(String name) {
    return '안녕하세요, $name님! 👋';
  }

  @override
  String get homeSubtitle => '오늘도 새로운 단어를 배우고 영어 실력을 키워볼까요?';

  @override
  String homeDayStreak(int days) {
    return '$days일 연속';
  }

  @override
  String get homeStreakLabel => '연속 학습일';

  @override
  String homeMasteredWords(int mastered, int total) {
    return '$mastered/$total개 암기 완료';
  }

  @override
  String homeProgressSummary(int mastered, int total, int percent) {
    return '총 $total개의 CEFR 단어 중 $mastered개를 완전히 익혔습니다 ($percent% 달성).';
  }

  @override
  String homeGoalTitle(int count) {
    return '목표: 하루 $count단어';
  }

  @override
  String homeReviewNow(int count) {
    return '지금 복습하기 ($count단어)';
  }

  @override
  String homeDueSrsCount(int count) {
    return '$count개 단어 복습 필요';
  }

  @override
  String homeWordsToLearn(int count) {
    return '$count개 단어 학습 대기';
  }

  @override
  String homeTopicCount(int count) {
    return '$count개 주제';
  }

  @override
  String homeTopicCefrCount(int count) {
    return '$count개 CEFR 주제';
  }

  @override
  String get homeShortcutsTitle => '학습 바로가기';

  @override
  String get homeViewAll => '전체 보기';

  @override
  String get homeCardTopicsTitle => '주제별 어휘';

  @override
  String get homeCardTopicsDesc => 'CEFR 레벨별 실전 주제 탐색';

  @override
  String get homeCardReviewTitle => '복습 목록';

  @override
  String get homeCardReviewDesc => '현재 복습이 필요한 단어들';

  @override
  String get homeCardExamTitle => 'IELTS/TOEIC 시험 대비';

  @override
  String get homeCardExamDesc => '시간제한 모의고사 및 상세한 해설';

  @override
  String get homeCardGamesTitle => '단어 게임';

  @override
  String get homeCardGamesDesc => '단어 짝 맞추기 & 스피드 퀴즈';

  @override
  String get homeCardShadowingTitle => '반사 쉐도잉';

  @override
  String get homeCardShadowingDesc => '문장 억양과 연음 마스터하기';

  @override
  String get homeCardDictionaryTitle => '영한・한영 사전';

  @override
  String get homeCardDictionaryDesc => '3,000개 이상의 핵심 단어 검색';

  @override
  String get homeCardAiTitle => 'English Buddy AI';

  @override
  String get homeCardAiDesc => '문법 질문, 단어 검색 및 영작 첨삭';

  @override
  String get homeCardStatsTitle => '학습 진도 및 통계';

  @override
  String get homeCardStatsDesc => '외운 단어 수 및 퀴즈 이력 확인';

  @override
  String get homeTodayWord => '오늘의 단어';

  @override
  String get homeChangeWord => '다른 단어 보기';

  @override
  String get homeSaveFavorite => '즐겨찾기에 추가';

  @override
  String get homeRemoveFavorite => '즐겨찾기에서 제거';

  @override
  String get homeListenPronunciation => '원어민 발음 듣기';

  @override
  String get homeSavedSuccess => '저장되었습니다';

  @override
  String get topicsTitle => '학습 주제';

  @override
  String topicsSubtitle(int count) {
    return 'A1부터 C1까지 수준별로 구성된 $count개의 실생활 어휘 주제를 만나보세요.';
  }

  @override
  String topicsCountWords(int count) {
    return '$count개 어휘';
  }

  @override
  String topicsMasteredCount(int mastered, int total) {
    return '완전 암기: $mastered/$total';
  }

  @override
  String get topicSearchPlaceholder => '영어 단어 또는 한국어 뜻 검색...';

  @override
  String topicLearnFlashcard(int count) {
    return '플래시카드로 학습 ($count)';
  }

  @override
  String get topicFilterAll => '전체';

  @override
  String get topicFilterNew => '새 단어';

  @override
  String get topicFilterReview => '복습 필요';

  @override
  String get topicFilterMastered => '암기 완료';

  @override
  String get topicEmptyWord => '단어를 찾을 수 없습니다';

  @override
  String get topicEmptyWordDesc => '다른 키워드로 검색하거나 필터를 변경해 보세요.';

  @override
  String get addWordTitle => '새 단어 추가';

  @override
  String addWordTopicTarget(String topicName) {
    return '대상 주제: $topicName';
  }

  @override
  String get addWordEnglishLabel => '영어 단어 *';

  @override
  String get addWordEnglishHint => '예: Innovation';

  @override
  String get addWordMeaningLabel => '한국어 뜻 *';

  @override
  String get addWordMeaningHint => '예: 혁신, 쇄신';

  @override
  String get addWordIpaLabel => 'IPA 발음 기호';

  @override
  String get addWordIpaHint => '예: /ˌɪn.əˈveɪ.ʃən/';

  @override
  String get addWordPartOfSpeechLabel => '품사';

  @override
  String get addWordExampleEnLabel => '예문 (영어)';

  @override
  String get addWordExampleEnHint => '예: Innovation drives technology forward.';

  @override
  String get addWordExampleViLabel => '예문 해석';

  @override
  String get addWordExampleViHint => '예: 혁신은 기술을 발전시킵니다.';

  @override
  String get addWordNotesLabel => '학습 메모 / 발음 팁';

  @override
  String get addWordNotesHint => '예: 세 번째 음절에 강세';

  @override
  String get addWordSaveButton => '단어 저장';

  @override
  String get addWordRequiredEnglish => '영어 단어를 입력해 주세요';

  @override
  String get addWordRequiredMeaning => '한국어 뜻을 입력해 주세요';

  @override
  String addWordSuccess(String term) {
    return '\"$term\" 단어를 성공적으로 추가했습니다!';
  }

  @override
  String get flashcardTapToFlip => '카드를 탭하여 단어 보기';

  @override
  String get flashcardTapToMeaning => '카드를 탭하여 뜻 보기';

  @override
  String get flashcardVietnameseMeaning => '한국어 뜻';

  @override
  String get flashcardNeedReview => '복습 필요';

  @override
  String get flashcardMastered => '암기 완료';

  @override
  String get flashcardCompletedTitle => '훌륭해요! 학습을 마쳤습니다!';

  @override
  String flashcardCompletedDesc(int count) {
    return '$count장의 플래시카드 복습을 성공적으로 마쳤습니다.';
  }

  @override
  String get flashcardReviewAgain => '다시 복습하기';

  @override
  String get flashcardBack => '이전 페이지로 돌아가기';

  @override
  String get flashcardEmpty => '복습할 단어가 없습니다.';

  @override
  String get quizSetupTitle => '퀴즈 챌린지';

  @override
  String get quizSetupHeader => '스피드 & 반사 퀴즈';

  @override
  String get quizSetupSubtitle =>
      '뜻 고르기, 단어 맞추기, 문맥 빈칸 채우기 등 다양한 문제 유형으로 단어를 완벽히 기억하세요.';

  @override
  String get quizSetupSelectTopic => '퀴즈 주제 선택';

  @override
  String get quizSetupAllTopics => '종합 퀴즈 (전체 주제)';

  @override
  String get quizSetupAllTopicsDesc => '전체 단어 데이터베이스에서 무작위 출제';

  @override
  String get quizSetupQuestionCount => '문제 수';

  @override
  String get quizSetupCountFast => '5문제 (빠른 퀴즈)';

  @override
  String get quizSetupCountStandard => '10문제 (표준 퀴즈)';

  @override
  String get quizSetupStart => '퀴즈 시작';

  @override
  String get quizPlayTitle => '퀴즈 챌린지';

  @override
  String quizPlayQuestionCounter(int current, int total) {
    return '문제 $current/$total';
  }

  @override
  String get quizPlayTypeSelectMeaning => '올바른 한국어 뜻을 선택하세요';

  @override
  String get quizPlayTypeSelectWord => '올바른 영어 단어를 선택하세요';

  @override
  String get quizPlayTypeFillBlank => '빈칸에 들어갈 알맞은 단어를 입력하세요';

  @override
  String get quizPlayCheck => '정답 확인';

  @override
  String get quizPlayNext => '다음 문제';

  @override
  String get quizPlayViewResult => '결과 보기';

  @override
  String get quizPlayCorrect => '정답입니다!';

  @override
  String get quizPlayIncorrect => '틀렸습니다!';

  @override
  String get quizPlayExitTitle => '퀴즈를 종료하시겠습니까?';

  @override
  String get quizPlayExitMessage => '지금 나가면 현재 퀴즈 진행 상황이 저장되지 않습니다.';

  @override
  String get quizPlayContinue => '퀴즈 계속하기';

  @override
  String get quizResultTitle => '퀴즈 결과';

  @override
  String quizResultScore(int correct, int total) {
    return '$total문제 중 $correct문제 정답';
  }

  @override
  String get quizResultExcellent => '완벽합니다!';

  @override
  String get quizResultGood => '아주 잘하셨어요!';

  @override
  String get quizResultNeedsWork => '조금 더 연습해 볼까요?';

  @override
  String get quizResultDescExcellent =>
      '이번 퀴즈에 출제된 단어를 확실하게 마스터하셨습니다. 계속 유지하세요!';

  @override
  String get quizResultDescGood =>
      '수고하셨습니다! 틀린 단어는 복습할 수 있도록 \'복습 필요\' 목록에 자동 저장되었습니다.';

  @override
  String get quizResultDescNeedsWork =>
      '실망하지 마세요! 플래시카드로 다시 복습하고 한 번 더 도전해 보세요.';

  @override
  String get quizResultDetails => '문제별 정답 확인';

  @override
  String get quizResultRetake => '다시 풀기';

  @override
  String get quizResultHome => '홈으로 돌아가기';

  @override
  String quizResultUserSelected(String answer) {
    return '선택한 답: $answer';
  }

  @override
  String quizResultCorrectIs(String answer) {
    return '정답: $answer';
  }

  @override
  String get reviewTitle => '복습 및 즐겨찾기';

  @override
  String reviewTabNeedReview(int count) {
    return '복습 필요 ($count)';
  }

  @override
  String reviewTabFavorites(int count) {
    return '즐겨찾기 ($count)';
  }

  @override
  String get reviewEmptyNeedReview => '복습할 단어가 없습니다';

  @override
  String get reviewEmptyNeedReviewDesc =>
      '플래시카드에서 \'복습 필요\'로 표시하거나 퀴즈에서 틀린 단어는 망각곡선 주기에 따라 자동으로 이곳에 모입니다.';

  @override
  String get reviewEmptyFavorites => '즐겨찾기한 단어가 없습니다';

  @override
  String get reviewEmptyFavoritesDesc =>
      '단어 카드에서 하트 아이콘을 누르면 이곳에 저장되어 언제든 다시 볼 수 있습니다.';

  @override
  String get reviewLearnFlashcardsNeed => '플래시카드 (복습 필요)';

  @override
  String get reviewLearnFlashcardsFav => '플래시카드 (즐겨찾기)';

  @override
  String reviewTotalWords(int count) {
    return '총 $count개 단어';
  }

  @override
  String get reviewViewStats => '학습 진도 통계 보기';

  @override
  String get wordDetailTitle => '단어 상세 정보';

  @override
  String get wordDetailVietnameseDef => '한국어 뜻';

  @override
  String get wordDetailSrsTitle => '간격 반복 시스템 (SRS)';

  @override
  String wordDetailInterval(int days) {
    return '복습 주기: $days일';
  }

  @override
  String wordDetailReviewCount(int count) {
    return '복습 횟수: $count회';
  }

  @override
  String get wordDetailRealWorldExample => '실제 문맥 활용 예문';

  @override
  String wordDetailSynonyms(String synonyms) {
    return '유의어: $synonyms';
  }

  @override
  String wordDetailAntonyms(String antonyms) {
    return '반의어: $antonyms';
  }

  @override
  String get wordDetailTips => '기억법 및 발음 팁';

  @override
  String get wordDetailAddedFav => '즐겨찾기에 추가되었습니다';

  @override
  String get wordDetailRemovedFav => '즐겨찾기에서 제거되었습니다';

  @override
  String get statsTitle => '통계 및 학습 현황';

  @override
  String get statsOverallProgress => '전체 학습 진행률';

  @override
  String statsMasteredRatio(int mastered, int total) {
    return '$total개 단어 중 $mastered개 완벽 암기';
  }

  @override
  String get statsTotalWords => '총 단어 수';

  @override
  String get statsMasteredWords => '암기 완료';

  @override
  String get statsNeedReviewWords => '복습 필요';

  @override
  String get statsFavoriteWords => '즐겨찾기';

  @override
  String get statsTopicProgress => '주제별 학습 진도';

  @override
  String get statsQuizHistory => '퀴즈 기록';

  @override
  String statsAverageScore(String score) {
    return '평균 점수: $score%';
  }

  @override
  String get statsEmptyQuiz => '아직 퀴즈 기록이 없습니다. 퀴즈를 풀고 실력을 확인해 보세요!';

  @override
  String get statsResetTitle => '데이터를 초기화하시겠습니까?';

  @override
  String get statsResetMessage =>
      '모든 학습 상태, 퀴즈 이력 및 사용자 추가 단어가 앱 초기 상태로 리셋됩니다.';

  @override
  String get statsResetConfirm => '초기화 확인';

  @override
  String get statsResetSuccess => '앱 초기 데이터를 성공적으로 복원했습니다!';

  @override
  String get dictTitle => '양방향 사전';

  @override
  String get dictSearchPlaceholder => '양방향 검색: 한국어 또는 영어(예: apartment) 입력...';

  @override
  String get dictRecentSearches => '최근 검색어';

  @override
  String get dictClearHistory => '기록 지우기';

  @override
  String get dictOnlineViEn => '온라인 번역: 한국어 ➔ 영어';

  @override
  String get dictOnlineEnVi => '온라인 검색: 영어 ➔ 한국어';

  @override
  String dictOnlineViEnQuery(String query) {
    return '\"$query\" 온라인 번역 (한국어 ➔ 영어)';
  }

  @override
  String dictOnlineEnViQuery(String query) {
    return '\"$query\" 온라인 검색 (영어 ➔ 한국어)';
  }

  @override
  String dictNotFoundInternal(String query) {
    return '내부 사전에서 \"$query\" 단어를 찾을 수 없습니다.';
  }

  @override
  String get dictListenWord => '원어민 발음 듣기';

  @override
  String get dictCachedBadge => 'SQLite 오프라인 캐시';

  @override
  String get dictSaveToReview => '복습 목록에 저장';

  @override
  String dictSavedSuccess(String term) {
    return '\"$term\" 단어를 단어장 및 복습 목록에 저장했습니다!';
  }

  @override
  String get dictEnglishDefinitions => '영영 정의 및 예문:';

  @override
  String dictSynonymsList(String synonyms) {
    return '유의어: $synonyms';
  }

  @override
  String get dictNoun => '명사 (n)';

  @override
  String get dictVerb => '동사 (v)';

  @override
  String get dictAdj => '형용사 (adj)';

  @override
  String get dictAdv => '부사 (adv)';

  @override
  String get dictPhrase => '숙어 / 관용구';

  @override
  String get skillsHubTitle => '4대 영역 및 어휘 집중 훈련';

  @override
  String get skillsHubAllLevels => '모든 레벨 보기 (A1–C1)';

  @override
  String get skillsListening => '듣기 (Listening)';

  @override
  String get skillsReading => '읽기 (Reading)';

  @override
  String get skillsWriting => '쓰기 (Writing)';

  @override
  String get skillsSpeaking => '말하기 (Speaking)';

  @override
  String get skillsListeningDesc =>
      '기본 배속(1.0x) 또는 느린 배속(0.75x) 오디오 지원. 스크립트와 번역은 제출 후 공개됩니다.';

  @override
  String get skillsReadingDesc => 'A1–C1 수준별 지문 독해, 객관식 및 빈칸 완성 문제와 꼼꼼한 해설 제공.';

  @override
  String get skillsWritingDesc => '문장 단어 재배열 영작 연습 및 모범 답안 루브릭 기준 작문 훈련.';

  @override
  String get skillsSpeakingDesc => '발음, 문장 강세, 연음 교정 훈련 및 4가지 루브릭 기준 자가 진단.';

  @override
  String get skillsStartLearning => '지금 시작하기';

  @override
  String skillsProgressText(int completed, int total) {
    return '진도: $total개 레슨 중 $completed개 완료';
  }

  @override
  String skillsCompletedBadge(int score) {
    return '완료됨 • $score%';
  }

  @override
  String skillsLessonList(int count) {
    return '레슨 목록 ($count개 레슨)';
  }

  @override
  String skillsNoLessonLevel(String level) {
    return 'CEFR $level 레벨에 해당하는 레슨이 없습니다.';
  }

  @override
  String get skillsOpenShadowing => '쉐도잉 스튜디오 열기';

  @override
  String get skillsMatchingGameTitle => '짝 맞추기 게임';

  @override
  String get skillsFlashcard3dTitle => '3D 플래시카드';

  @override
  String get skillsQuizReflexTitle => '단어 반사 퀴즈';

  @override
  String get skillsExamHubTitle => '실전 모의고사실';

  @override
  String get skillsSrsReviewTitle => 'SRS 간격 반복 복습';

  @override
  String get exerciseListeningTitle => '듣기 이해 훈련';

  @override
  String get exerciseReadingTitle => '읽기 독해 훈련';

  @override
  String exerciseQuestionsCount(int count) {
    return '이해력 평가 문제 ($count문제)';
  }

  @override
  String exerciseScoreResult(int correct, int total, int percent) {
    return '점수: $total문제 중 $correct문제 정답 ($percent%)';
  }

  @override
  String get exerciseShowTranscript => '대본 및 번역 보기';

  @override
  String get exerciseHideTranscript => '대본 및 번역 숨기기';

  @override
  String get exerciseReadingPassage => '본문 지문';

  @override
  String get exerciseAudioPlayer => '오디오 플레이어';

  @override
  String exerciseKeyWords(int count) {
    return '핵심 어휘 ($count단어)';
  }

  @override
  String get exerciseSubmitGrade => '제출 및 채점';

  @override
  String get exerciseRetake => '다시 학습하기';

  @override
  String exerciseSaveWordSuccess(String term) {
    return '\"$term\" 단어를 복습 및 즐겨찾기에 저장했습니다!';
  }

  @override
  String get speakingTimerPractice => '시간제한 스피킹 훈련';

  @override
  String speakingRecordPrompt(int seconds) {
    return '녹음 중 ($seconds초) - 탭하여 중지';
  }

  @override
  String speakingRubricSelfCheck(int checked, int total) {
    return '자기 평가 ($total개 평가 기준 중 $checked개 충족)';
  }

  @override
  String speakingSaveSuccess(int score) {
    return '말하기 자기 평가 결과($score%)를 학습 기록에 저장했습니다!';
  }

  @override
  String get writingTabScramble => '1. 문장 구조 및 단어 배열';

  @override
  String get writingTabRubric => '2. 단락 작문 및 루브릭 평가';

  @override
  String get writingTapWordToForm => '아래 단어를 순서대로 탭하여 올바른 문장을 만드세요...';

  @override
  String get writingCheckSentence => '문장 확인';

  @override
  String writingWordCountStatus(int count, int min) {
    return '단어 수: $count개 / 최소 $min개';
  }

  @override
  String writingNeedMoreWords(int count) {
    return '$count개 단어가 더 필요합니다';
  }

  @override
  String get writingSaveModelAnswer => '글 저장하고 모범 답안 보기';

  @override
  String get writingModelAnswerTitle => '모범 답안 (참고용)';

  @override
  String get shadowingHubTitle => '반사 쉐도잉 스튜디오';

  @override
  String get shadowingMethodTitle => '4단계 억양 쉐도잉 학습법';

  @override
  String get shadowingMethodDesc =>
      '1. 원어민 음성 듣기 (1.0x) → 2. 느린 듣기 및 연음 분석 (0.75x) → 3. 동시 쉐도잉 따라하기 → 4. 루브릭 기반 솔직한 자가 평가.';

  @override
  String shadowingLessonsList(int count) {
    return '쉐도잉 레슨 ($count개 레슨)';
  }

  @override
  String get shadowingPracticeTitle => '쉐도잉 실전 연습';

  @override
  String get shadowingStep1 => '1단계: 원어민 음성 듣기 (1.0x)';

  @override
  String get shadowingStep2 => '2단계: 느리게 집중 듣기 (0.75x)';

  @override
  String get shadowingStep3 => '3단계: 원어민 음성과 동시에 쉐도잉';

  @override
  String get shadowingStep4 => '4단계: 자기 평가 진행 (필수)';

  @override
  String shadowingSpeakingStatus(int seconds) {
    return '쉐도잉 녹음 중 ($seconds초)...';
  }

  @override
  String get shadowingSaveProgress => '쉐도잉 진도 저장';

  @override
  String shadowingSavedSuccess(int score) {
    return '쉐도잉 학습 진도(평가 기준 충족도 $score%)가 데이터베이스에 저장되었습니다!';
  }

  @override
  String get gamesHubTitle => '단어 미니게임 센터';

  @override
  String get gamesHubSubtitle =>
      '스피드 타자, 반사신경 아레나, 단어비 맞추기 게임으로 단어를 즐겁게 암기하세요.';

  @override
  String get gamesSelectGame => '시작할 게임을 선택하세요:';

  @override
  String get gamesSpaceTyperTitle => '우주 타자왕';

  @override
  String get gamesSpaceTyperDesc =>
      '글자와 단어를 입력해 소행성을 파괴하세요. 우주선 자동 조준, 레이저 발사 및 방어 레이더 지원.';

  @override
  String get gamesArenaTitle => '보캐블러리 아레나';

  @override
  String get gamesArenaDesc =>
      '7~15초 제한 시간 객관식 퀴즈, 연속 콤보 보너스 및 키보드 1~4번 단축키 지원.';

  @override
  String get gamesWordRainTitle => '단어비 게임';

  @override
  String get gamesWordRainDesc =>
      '빗방울이 바닥에 닿기 전에 목표 한국어 뜻과 일치하는 영어 빗방울을 빠르게 터치하세요.';

  @override
  String get gamesPlayNow => '지금 플레이';

  @override
  String get gamesRules => '게임 규칙 및 안내';

  @override
  String gamesHighScore(int score) {
    return '최고 점수: $score점';
  }

  @override
  String gamesRecentHistory(int count) {
    return '최근 게임 이력 ($count회)';
  }

  @override
  String gameScorePoints(int score) {
    return '$score점';
  }

  @override
  String get gameOver => '게임 종료!';

  @override
  String get gameCompleted => '라운드 클리어!';

  @override
  String get gamePlayAgain => '다시 플레이';

  @override
  String get gameBackToHub => '게임 센터로 돌아가기';

  @override
  String get gameAccuracy => '정확도';

  @override
  String get gameTime => '시간';

  @override
  String get gameStreak => '최대 콤보';

  @override
  String get gameNewRecord => '🎉 최고 기록을 경신했습니다!';

  @override
  String get gameDiffEasy => '쉬움';

  @override
  String get gameDiffMedium => '보통';

  @override
  String get gameDiffHard => '어려움';

  @override
  String get examHubTitle => '공인 영어 인증 모의시험장';

  @override
  String get examHubSubtitle => '실전 대비 시간제한 모의고사 (IELTS • TOEIC • CEFR)';

  @override
  String examListTitle(int count) {
    return '응시 가능한 시험 ($count개 모의고사)';
  }

  @override
  String get examPracticeMode => '연습 모드';

  @override
  String get examPracticeModeDesc => '시간제한 없이 문제별 힌트와 상세 해설을 바로 확인하며 학습합니다.';

  @override
  String get examTimedMode => '실전 모의고사 모드 (시간제한)';

  @override
  String get examTimedModeDesc => '카운트다운 타이머 적용, 시간 종료 시 자동 제출 및 종합 성적 리포트 제공.';

  @override
  String examQuestionCounter(int current, int total) {
    return '문제 $current/$total';
  }

  @override
  String get examSubmitConfirm => '시험을 제출하시겠습니까?';

  @override
  String get examSubmitConfirmDesc => '시험을 종료하고 답안을 최종 제출하시겠습니까?';

  @override
  String get examResultTitle => '시험 결과 및 심층 분석 리포트';

  @override
  String examScoreBand(String band) {
    return '예상 점수: $band';
  }

  @override
  String examCorrectRatio(int correct, int total, int percent) {
    return '정답률: $total문제 중 $correct문제 ($percent%)';
  }

  @override
  String get aiChatTitle => 'English Buddy AI 학습 도우미';

  @override
  String get aiChatSubtitle => '문법 질의응답 • 문장 자연스러운 번역 • 영작문 첨삭';

  @override
  String get aiChatGreeting => '안녕하세요! 오늘 어떤 영어 공부를 도와드릴까요?';

  @override
  String get aiChatGreetingDesc => '어려운 문법 질문, 영작 번역, 에세이 첨삭 등 무엇이든 편하게 물어보세요!';

  @override
  String get aiChatSuggestions => '추천 질문 예시';

  @override
  String get aiChatInputPlaceholder => '질문, 번역할 문장 또는 첨삭받을 영작문을 입력하세요...';

  @override
  String get aiChatClearTitle => '대화 내용을 지우시겠습니까?';

  @override
  String get aiChatClearDesc => '기기에 저장된 모든 AI 대화 기록이 삭제됩니다. 이 작업은 되돌릴 수 없습니다.';

  @override
  String get aiChatClearSuccess => '모든 대화 기록이 성공적으로 삭제되었습니다.';

  @override
  String get aiChatThinking => 'AI 도우미가 답변을 생각하는 중입니다...';

  @override
  String get authSignInTitle => '계정 로그인';

  @override
  String get authSignUpTitle => '새 계정 만들기';

  @override
  String get authAccountOrEmail => '사용자명 또는 이메일';

  @override
  String get authEmail => '이메일 주소';

  @override
  String get authPassword => '비밀번호';

  @override
  String get authConfirmPassword => '비밀번호 확인';

  @override
  String get authDisplayName => '닉네임';

  @override
  String get authGoogleSignIn => 'Google 계정으로 계속';

  @override
  String get authProcessing => '처리 중입니다...';

  @override
  String get authPasswordMismatch => '비밀번호가 일치하지 않습니다!';

  @override
  String get authMinPassword => '최소 8자 이상 입력해야 합니다';

  @override
  String get authInvalidEmail => '올바른 이메일 형식을 입력하세요';

  @override
  String get authOr => '또는';

  @override
  String get statsResetButton => '초기 데이터로 복원';

  @override
  String statsQuizQuestionsCount(Object correct, Object total) {
    return '$total문제 중 $correct문제 정답';
  }

  @override
  String statsTopicWordsProgress(
    Object mastered,
    Object percent,
    Object total,
  ) {
    return '$total개 중 $mastered개 완료 ($percent%)';
  }

  @override
  String get dictTitleFull => '스마트 영한・한영 양방향 사전';

  @override
  String dictSearchDirection(Object flag, Object label) {
    return '검색 방향: $flag $label';
  }

  @override
  String get dictViDetected => '감지됨: 한국어 ➔ 일치하는 영어 단어 표시';

  @override
  String get dictEnDetected => '감지됨: 영어 ➔ 한국어 뜻 및 영영 사전 정의 표시';

  @override
  String get dictAllLevels => '모든 레벨';

  @override
  String get dictAllTopics => '모든 주제';

  @override
  String get dictAllPos => '모든 품사';

  @override
  String get dictIntroDesc =>
      '스마트 양방향 검색 시스템: 한국어로 입력해 해당하는 영어 단어를 찾거나, 영어를 입력해 자연스러운 한국어 뜻을 검색하세요. 3,000개 이상의 오프라인 CEFR A1–C1 단어와 온라인 확장 검색(Google 번역 및 Wiktionary를 SQLite에 캐시)을 지원합니다.';

  @override
  String get dictViEnOnlinePrompt =>
      '온라인으로 한영 번역을 확장할 수 있습니다 (해당하는 영어 단어, 뜻, 발음을 자동으로 가져와 SQLite에 캐시합니다).';

  @override
  String get dictEnViOnlinePrompt =>
      '온라인으로 영한 검색을 확장할 수 있습니다 (한국어 뜻, 영영 정의, 발음을 자동으로 가져와 SQLite에 캐시합니다).';

  @override
  String get dictRetry => '다시 시도';

  @override
  String get dictRetryConnection => '연결 재시도';

  @override
  String get dictTtsTooltip => '표준 발음 듣기 (TTS)';

  @override
  String get dictInReview => '복습 중';

  @override
  String get dictAddToReview => '복습 목록에 추가';

  @override
  String dictMovedToNew(Object term) {
    return '\"$term\" 단어를 새 단어로 이동했습니다';
  }

  @override
  String dictAddedToReview(Object term) {
    return '\"$term\" 단어를 복습 목록에 추가했습니다!';
  }

  @override
  String get dictFavoriteAdd => '이 단어 즐겨찾기';

  @override
  String get dictFavoriteRemove => '즐겨찾기에서 제거';

  @override
  String get dictLiveApi => '온라인 검색 (Live API)';

  @override
  String get dictSaved => '저장됨';

  @override
  String dictViKeyword(Object query) {
    return '검색 키워드: \"$query\"';
  }

  @override
  String get dictEquivalentEnWords => '해당하는 영어 단어:';

  @override
  String dictListenTooltip(Object word) {
    return '탭하여 발음 듣기: $word';
  }

  @override
  String dictViRefMeaning(Object meaning) {
    return '대조 참고 한국어 뜻: $meaning';
  }

  @override
  String get dictViTranslation => '한국어 번역:';

  @override
  String get dictOtherMeanings => '기타 뜻:';

  @override
  String dictSourceInfo(Object license, Object source, Object url) {
    return '출처: $source • 라이선스: $license ($url)';
  }

  @override
  String dictExamplePrefix(Object example) {
    return '예: \"$example\"';
  }

  @override
  String get avatarChangePhoto => '프로필 사진 변경';

  @override
  String get avatarSelectFromDevice => '기기 사진첩 / 갤러리에서 선택';

  @override
  String get avatarSelectFromUrl => '이미지 URL 직접 입력';

  @override
  String get avatarResetDefault => '기본 아바타로 초기화';

  @override
  String get avatarEnterUrlTitle => '아바타 이미지 URL 입력';

  @override
  String get avatarUrlPlaceholder => 'https://example.com/avatar.jpg';

  @override
  String get avatarInvalidUrl => '유효하지 않은 URL이거나 이미지 파일이 아닙니다';

  @override
  String get skillsSelectSkill => '연습할 영역을 선택하세요:';

  @override
  String get skillsAllLevels => '모든 레벨';

  @override
  String skillsQuestionsCount(Object count) {
    return '$count문제';
  }

  @override
  String skillsExerciseCount(Object count) {
    return '$count개 연습문제';
  }

  @override
  String get skillsStartPractice => '연습 시작';

  @override
  String get skillsTranscriptLocked => '대본 비공개 상태';

  @override
  String get skillsTranscriptUnlocked => '듣기 대본 확인';

  @override
  String get skillsSubmitExercise => '답안 제출';

  @override
  String get skillsCompleted => '완료됨';

  @override
  String skillsScore(Object score, Object total) {
    return '점수: $score/$total';
  }

  @override
  String get skillsTryAgain => '다시 풀기';

  @override
  String get skillsNextExercise => '다음 연습으로';

  @override
  String get skillsListenNormal => '보통 배속 1.0x';

  @override
  String get skillsListenSlow => '느린 배속 0.75x';

  @override
  String get skillsExplanation => '상세 정답 해설';

  @override
  String get skillsMatchingPairs => '단어와 알맞은 뜻을 연결하세요';

  @override
  String get skillsSpeakingPrompt => '다음 지문을 소리 내어 읽으세요';

  @override
  String get skillsWritingPrompt => '주어진 조건에 맞추어 글을 작성하세요';

  @override
  String gameDifficulty(Object diff) {
    return '난이도: $diff';
  }

  @override
  String gameScore(Object score) {
    return '점수: $score';
  }

  @override
  String gameHighScore(Object score) {
    return '최고 점수: $score';
  }

  @override
  String get gameExit => '게임 나가기';

  @override
  String gameCombo(Object multiplier) {
    return '콤보 x$multiplier';
  }

  @override
  String gameWpm(Object wpm) {
    return '타자 속도: $wpm WPM';
  }

  @override
  String get gameStart => '게임 시작';

  @override
  String get gamePause => '일시 정지';

  @override
  String get gameResume => '이어 하기';

  @override
  String get gameRestart => '다시 시작';

  @override
  String gameLives(Object lives) {
    return '남은 하트: $lives';
  }

  @override
  String gameLevel(Object level) {
    return '레벨: $level';
  }

  @override
  String get examMode => '시험 모드';

  @override
  String examTimeRemaining(Object time) {
    return '남은 시간: $time';
  }

  @override
  String get examSubmit => '시험 답안 제출';

  @override
  String get examPassed => '합격';

  @override
  String get examFailed => '보충 필요';

  @override
  String get examScoreBreakdown => '영역별 점수 내역';

  @override
  String get examReviewAnswers => '답안 및 정답 해설 확인';

  @override
  String get examRetake => '시험 다시 보기';

  @override
  String get examBackToHub => '모의시험장으로 돌아가기';

  @override
  String get shadowingListen1 => '1단계: 원어민 음성 듣기 (1.0x)';

  @override
  String get shadowingListen2 => '2단계: 느린 속도로 듣기 (0.75x)';

  @override
  String get shadowingRecord => '3단계: 원어민 음성 따라 쉐도잉';

  @override
  String get shadowingStop => '녹음 중지';

  @override
  String get shadowingSelfEval => '4단계: 자기 평가';

  @override
  String get shadowingNext => '다음 문장';

  @override
  String get shadowingComplete => '쉐도잉 연습을 모두 완료했습니다!';

  @override
  String get authLogin => '로그인';

  @override
  String get authRegister => '회원가입';

  @override
  String get authNoAccount => '계정이 없으신가요? 회원가입';

  @override
  String get authAlreadyHaveAccount => '이미 계정이 있으신가요? 로그인';

  @override
  String get authLogout => '로그아웃';

  @override
  String get authLogoutConfirm => '정말 로그아웃하시겠습니까?';

  @override
  String get profileTitle => '회원 프로필';

  @override
  String get profileEdit => '프로필 수정';

  @override
  String get profileSave => '프로필 변경사항 저장';

  @override
  String get profileDisplayName => '닉네임';

  @override
  String get profileEmail => '이메일';

  @override
  String get profileRole => '계정 권한';

  @override
  String get profileJoined => '가입일';

  @override
  String get adminTitle => '시스템 운영 관리자 (Admin)';

  @override
  String get adminUsers => '회원 및 레벨 관리';

  @override
  String get adminVocab => '단어 및 주제 관리';

  @override
  String get adminExercises => '읽기 및 듣기 문제 관리';

  @override
  String get adminExams => '모의시험 문제 관리';

  @override
  String get adminSystem => '시스템 모니터링';

  @override
  String get adminForbidden => '관리자 전용 영역 (403 Forbidden)';

  @override
  String get adminRefresh => '관리 데이터 새로고침';

  @override
  String get aiChatAsk => 'AI에게 질문하기';

  @override
  String get settingsSelectLanguage => '앱 언어 선택';

  @override
  String get settingsSearchLanguage => '언어 검색...';

  @override
  String get settingsAllLanguages => '13개 언어 모두 보기';

  @override
  String get settingsAllLanguagesSubtitle =>
      '중국어, 일본어, 한국어, 프랑스어, 독일어, 스페인어, 러시아어...';

  @override
  String get settingsDefaultBadge => '기본값';

  @override
  String get profileUsernameLabel => '로그인 사용자 이름 (Username)';

  @override
  String get profileUsernameHint => '사용자 이름 입력 (3~30자: a-z, 0-9, ., _, -)';

  @override
  String get profileUsernameHelperPassword =>
      '이 사용자 이름 또는 이메일과 비밀번호로 로그인할 수 있습니다.';

  @override
  String get profileUsernameHelperGoogle =>
      'Google 계정은 계속 Google로 로그인하며, 이 사용자 이름은 고유 계정 식별자로 사용됩니다.';

  @override
  String get profileEmailReadOnlyHelper =>
      '로그인 이메일 (읽기 전용, 표시 이름이나 사용자 이름을 변경해도 유지됨)';

  @override
  String get weeklyProgressTitle => '주간 학습 진도';

  @override
  String weeklyProgressActiveDays(int count) {
    return '$count/7일 활동';
  }

  @override
  String weeklyProgressWordsStudied(int count) {
    return '학습/복습 단어 $count개';
  }

  @override
  String weeklyProgressActivitiesDone(int count) {
    return '완료한 활동 $count건';
  }

  @override
  String weeklyProgressTodayGoal(int current, int goal) {
    return '오늘의 단어 목표: $current/$goal단어';
  }

  @override
  String get weeklyProgressTodayBadge => '오늘';

  @override
  String get weeklyProgressEmptyTitle => '이번 주 학습 활동 기록이 아직 없습니다';

  @override
  String get weeklyProgressEmptyDesc =>
      '단어를 복습하거나 퀴즈·스킬 연습을 완료하면 주간 진도 차트가 즉시 업데이트됩니다!';

  @override
  String get weeklyProgressStartCta => '지금 단어 복습하기';

  @override
  String get weeklyProgressScopeNote =>
      '현재 계정의 실제 타임스탬프 기반 학습 활동을 로컬 시간대(월~일) 기준으로 집계합니다.';

  @override
  String get weeklyProgressUnitWords => '단어';

  @override
  String get weeklyProgressUnitActivities => '건';

  @override
  String get aiChatErrorGeneral => 'AI 응답을 받을 수 없습니다';

  @override
  String get authRegisterSuccessPleaseLogin => '회원가입이 완료되었습니다! 계속하려면 로그인하세요.';
}
