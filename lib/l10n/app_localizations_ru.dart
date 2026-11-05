// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'English Buddy';

  @override
  String get navHome => 'Главная';

  @override
  String get navTopics => 'Темы';

  @override
  String get navListening => 'Аудирование';

  @override
  String get navReading => 'Чтение';

  @override
  String get navWriting => 'Письмо';

  @override
  String get navSpeaking => 'Говорение';

  @override
  String get navShadowing => 'Shadowing';

  @override
  String get navDictionary => 'Словарь и лексика';

  @override
  String get navExam => 'Экзамены';

  @override
  String get navGames => 'Игры';

  @override
  String get navReview => 'Повторение';

  @override
  String get navStats => 'Статистика';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navAdmin => 'Админ-панель';

  @override
  String get navSectionSkills => 'НАВЫКИ И ОБУЧЕНИЕ';

  @override
  String get navSectionSystem => 'ПРОГРЕСС И СИСТЕМА';

  @override
  String get sidebarExpandTooltip =>
      'English Buddy - Развернуть боковую панель';

  @override
  String get sidebarCollapseTooltip => 'Свернуть боковую панель';

  @override
  String get mobileMenuTooltip => 'Открыть меню из 13 навыков и функций';

  @override
  String get aiChatTooltip => 'ИИ-помощник English Buddy';

  @override
  String get aiChatQuickHelp => 'Вопросы по грамматике и перевод';

  @override
  String get aiChatDesc =>
      'ИИ-помощник English Buddy (Вопросы и исправление ошибок)';

  @override
  String get accessDeniedAdminOnly =>
      'Доступ запрещен: панель администратора доступна только учетным записям администраторов.';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionConfirm => 'Подтвердить';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionEdit => 'Редактировать';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionBack => 'Назад';

  @override
  String get actionNext => 'Далее';

  @override
  String get actionPrevious => 'Назад';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionSubmit => 'Отправить';

  @override
  String get actionStart => 'Начать';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionSearch => 'Поиск';

  @override
  String get actionFilter => 'Фильтр';

  @override
  String get actionReset => 'Сбросить';

  @override
  String get actionResetFilter => 'Сбросить фильтры';

  @override
  String get actionClear => 'Очистить';

  @override
  String get actionShowAll => 'Показать все';

  @override
  String get actionExpand => 'Развернуть';

  @override
  String get actionCollapse => 'Свернуть';

  @override
  String get actionPlay => 'Воспроизвести';

  @override
  String get actionPause => 'Пауза';

  @override
  String get actionResume => 'Возобновить';

  @override
  String get actionExit => 'Выйти';

  @override
  String get actionUnderstood => 'Понятно';

  @override
  String get actionCopy => 'Копировать';

  @override
  String get statusActive => 'Активно';

  @override
  String get statusLocked => 'Заблокировано';

  @override
  String get statusCompleted => 'Завершено';

  @override
  String get statusPending => 'В ожидании';

  @override
  String get statusAll => 'Все';

  @override
  String get allTopics => 'Все темы';

  @override
  String get allLevels => 'Все уровни';

  @override
  String get allSkills => 'Все навыки';

  @override
  String get allFormats => 'Все форматы';

  @override
  String get levelA1 => 'A1 - Начальный';

  @override
  String get levelA2 => 'A2 - Элементарный';

  @override
  String get levelB1 => 'B1 - Средний';

  @override
  String get levelB2 => 'B2 - Выше среднего';

  @override
  String get levelC1 => 'C1 - Продвинутый';

  @override
  String get settingsTitle => 'Настройки и параметры';

  @override
  String get settingsLanguageSection => 'Язык и локализация';

  @override
  String get settingsLanguageSubtitle =>
      'Выберите предпочтительный язык интерфейса';

  @override
  String get settingsLangVi => 'Tiếng Việt';

  @override
  String get settingsLangViDesc => 'Вьетнамский';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsLangEnDesc => 'Английский';

  @override
  String get settingsAccountSection => 'Профиль и аккаунт';

  @override
  String get settingsThemeSection => 'Интерфейс и тема';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeSystemDesc =>
      'Автоматически подстраиваться под систему устройства';

  @override
  String get settingsThemeLight => 'Светлая тема';

  @override
  String get settingsThemeDark => 'Темная тема';

  @override
  String get settingsDailyGoalSection => 'Ежедневная цель обучения';

  @override
  String get settingsDailyGoalSubtitle =>
      'Выберите, сколько слов вы хотите изучать каждый день:';

  @override
  String settingsDailyGoalUnit(int count) {
    return '$count слов';
  }

  @override
  String settingsDailyGoalSaved(int count) {
    return 'Дневная цель установлена: $count слов/день!';
  }

  @override
  String get settingsSoundSection => 'Звук и произношение';

  @override
  String get settingsSoundEnable => 'Включить озвучивание произношения';

  @override
  String get settingsSoundEnableDesc =>
      'Движок Text-to-Speech с произношением носителей языка';

  @override
  String get settingsCopyrightSection => 'Источники данных и авторские права';

  @override
  String get settingsCopyrightTitle => 'Прозрачная политика авторских прав';

  @override
  String get settingsCopyrightDesc1 =>
      '• Лексика, примеры предложений и упражнения составлены оригинально на основе уровней CEFR (A1–C1) и открытых языковых стандартов.';

  @override
  String get settingsCopyrightDesc2 =>
      '• Мы не копируем массово определения и материалы из Cambridge Dictionary, DOL English или других коммерческих источников.';

  @override
  String get settingsCopyrightDesc3 =>
      '• Онлайн-поиск использует Free Dictionary API (открытый исходный код, без API-ключа, лицензия CC BY-SA 3.0).';

  @override
  String get settingsAppSubtitle =>
      'Проект мобильного приложения - Flutter и SQLite';

  @override
  String get guestUser => 'Гость (Не авторизован)';

  @override
  String get guestUserDesc =>
      'Вы не вошли в систему. Войдите или создайте аккаунт для управления профилем и синхронизации прогресса.';

  @override
  String authenticatedAs(String email, String provider) {
    return '$email • Подтверждено ($provider)';
  }

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get adminArea => 'Панель администратора';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Создать аккаунт';

  @override
  String get signOut => 'Выйти';

  @override
  String get confirmSignOutTitle => 'Подтверждение выхода';

  @override
  String confirmSignOutMessage(String email) {
    return 'Вы уверены, что хотите выйти из учетной записи \"$email\"?\n\nТекущая сессия и токен будут удалены. Локальный прогресс обучения на этом устройстве сохранится.';
  }

  @override
  String accountMenuHeader(String displayName) {
    return 'Аккаунт ($displayName)';
  }

  @override
  String get homeGreetingGuest => 'Привет! 👋';

  @override
  String homeGreetingUser(String name) {
    return 'Привет, $name! 👋';
  }

  @override
  String get homeSubtitle =>
      'Готовы расширить словарный запас и улучшить английский сегодня?';

  @override
  String homeDayStreak(int days) {
    return '$days дн.';
  }

  @override
  String get homeStreakLabel => 'Серия дней';

  @override
  String homeMasteredWords(int mastered, int total) {
    return 'Освоено $mastered/$total';
  }

  @override
  String homeProgressSummary(int mastered, int total, int percent) {
    return 'Вы освоили $mastered из $total слов CEFR ($percent% завершено).';
  }

  @override
  String homeGoalTitle(int count) {
    return 'Цель на день: $count слов/день';
  }

  @override
  String homeReviewNow(int count) {
    return 'Повторить сейчас ($count слов)';
  }

  @override
  String homeDueSrsCount(int count) {
    return '$count к повторению';
  }

  @override
  String homeWordsToLearn(int count) {
    return '$count слов для изучения';
  }

  @override
  String homeTopicCount(int count) {
    return '$count тем';
  }

  @override
  String homeTopicCefrCount(int count) {
    return '$count тем CEFR';
  }

  @override
  String get homeShortcutsTitle => 'Быстрый доступ';

  @override
  String get homeViewAll => 'Смотреть все';

  @override
  String get homeCardTopicsTitle => 'Темы лексики';

  @override
  String get homeCardTopicsDesc => 'Изучайте темы уровней CEFR';

  @override
  String get homeCardReviewTitle => 'Список на повторение';

  @override
  String get homeCardReviewDesc => 'Слова, требующие повторения прямо сейчас';

  @override
  String get homeCardExamTitle => 'Подготовка к IELTS/TOEIC';

  @override
  String get homeCardExamDesc => 'Тесты на время с подробными объяснениями';

  @override
  String get homeCardGamesTitle => 'Лексические игры';

  @override
  String get homeCardGamesDesc => 'Поиск пар и скоростная викторина';

  @override
  String get homeCardShadowingTitle => 'Рефлекторный Shadowing';

  @override
  String get homeCardShadowingDesc => 'Ударение в предложениях и связная речь';

  @override
  String get homeCardDictionaryTitle => 'Англо-вьетнамский словарь';

  @override
  String get homeCardDictionaryDesc => 'Поиск по более чем 3 000 слов';

  @override
  String get homeCardAiTitle => 'English Buddy AI';

  @override
  String get homeCardAiDesc =>
      'Вопросы по грамматике, поиск слов и отзыв на эссе';

  @override
  String get homeCardStatsTitle => 'Прогресс и статистика';

  @override
  String get homeCardStatsDesc => 'Освоенные слова и история викторин';

  @override
  String get homeTodayWord => 'Слово дня';

  @override
  String get homeChangeWord => 'Новое слово';

  @override
  String get homeSaveFavorite => 'Добавить в избранное';

  @override
  String get homeRemoveFavorite => 'Удалить из избранного';

  @override
  String get homeListenPronunciation => 'Прослушать произношение';

  @override
  String get homeSavedSuccess => 'Сохранено';

  @override
  String get topicsTitle => 'Учебные темы';

  @override
  String topicsSubtitle(int count) {
    return 'Изучите $count практических тем словарного запаса от уровня A1 до C1.';
  }

  @override
  String topicsCountWords(int count) {
    return '$count слов';
  }

  @override
  String topicsMasteredCount(int mastered, int total) {
    return 'Освоено: $mastered/$total';
  }

  @override
  String get topicSearchPlaceholder =>
      'Поиск английского слова или значения...';

  @override
  String topicLearnFlashcard(int count) {
    return 'Учить по карточкам ($count)';
  }

  @override
  String get topicFilterAll => 'Все';

  @override
  String get topicFilterNew => 'Новые';

  @override
  String get topicFilterReview => 'Повторить';

  @override
  String get topicFilterMastered => 'Освоено';

  @override
  String get topicEmptyWord => 'Слова не найдены';

  @override
  String get topicEmptyWordDesc =>
      'Попробуйте изменить поисковый запрос или смените фильтр.';

  @override
  String get addWordTitle => 'Добавить новое слово';

  @override
  String addWordTopicTarget(String topicName) {
    return 'В тему: $topicName';
  }

  @override
  String get addWordEnglishLabel => 'Английское слово *';

  @override
  String get addWordEnglishHint => 'напр.: Innovation';

  @override
  String get addWordMeaningLabel => 'Вьетнамский перевод *';

  @override
  String get addWordMeaningHint => 'напр.: Sự đổi mới, cách tân';

  @override
  String get addWordIpaLabel => 'Транскрипция IPA';

  @override
  String get addWordIpaHint => 'напр.: /ˌɪn.əˈveɪ.ʃən/';

  @override
  String get addWordPartOfSpeechLabel => 'Часть речи';

  @override
  String get addWordExampleEnLabel => 'Пример предложения (на английском)';

  @override
  String get addWordExampleEnHint =>
      'напр.: Innovation drives technology forward.';

  @override
  String get addWordExampleViLabel => 'Перевод примера';

  @override
  String get addWordExampleViHint =>
      'напр.: Sự đổi mới thúc đẩy công nghệ tiến lên.';

  @override
  String get addWordNotesLabel => 'Заметки / Советы по произношению';

  @override
  String get addWordNotesHint => 'напр.: Ударение на 3-й слог';

  @override
  String get addWordSaveButton => 'Сохранить слово';

  @override
  String get addWordRequiredEnglish => 'Пожалуйста, введите английское слово';

  @override
  String get addWordRequiredMeaning => 'Пожалуйста, введите значение слова';

  @override
  String addWordSuccess(String term) {
    return 'Слово \"$term\" успешно добавлено!';
  }

  @override
  String get flashcardTapToFlip =>
      'Нажмите на карточку, чтобы перевернуть к слову';

  @override
  String get flashcardTapToMeaning =>
      'Нажмите на карточку, чтобы увидеть перевод';

  @override
  String get flashcardVietnameseMeaning => 'ЗНАЧЕНИЕ';

  @override
  String get flashcardNeedReview => 'Повторить';

  @override
  String get flashcardMastered => 'Знаю';

  @override
  String get flashcardCompletedTitle => 'Отлично! Вы справились!';

  @override
  String flashcardCompletedDesc(int count) {
    return 'Вы только что повторили $count карточек со словами.';
  }

  @override
  String get flashcardReviewAgain => 'Повторить снова';

  @override
  String get flashcardBack => 'Вернуться назад';

  @override
  String get flashcardEmpty => 'Нет доступных слов для повторения.';

  @override
  String get quizSetupTitle => 'Викторина';

  @override
  String get quizSetupHeader => 'Викторина на скорость и реакцию';

  @override
  String get quizSetupSubtitle =>
      'Закрепляйте слова через разные форматы: выбор значения, выбор слова и вставка пропущенных слов в контексте.';

  @override
  String get quizSetupSelectTopic => 'Выберите тему викторины';

  @override
  String get quizSetupAllTopics => 'Все темы (Комплексный)';

  @override
  String get quizSetupAllTopicsDesc => 'Случайная выборка из всей базы слов';

  @override
  String get quizSetupQuestionCount => 'Количество вопросов';

  @override
  String get quizSetupCountFast => '5 вопросов (Быстро)';

  @override
  String get quizSetupCountStandard => '10 вопросов (Стандарт)';

  @override
  String get quizSetupStart => 'Начать викторину';

  @override
  String get quizPlayTitle => 'Викторина';

  @override
  String quizPlayQuestionCounter(int current, int total) {
    return 'Вопрос $current/$total';
  }

  @override
  String get quizPlayTypeSelectMeaning => 'Выберите правильный перевод';

  @override
  String get quizPlayTypeSelectWord => 'Выберите правильное английское слово';

  @override
  String get quizPlayTypeFillBlank => 'Заполните пропуск подходящим словом';

  @override
  String get quizPlayCheck => 'Проверить';

  @override
  String get quizPlayNext => 'Следующий вопрос';

  @override
  String get quizPlayViewResult => 'Посмотреть результаты';

  @override
  String get quizPlayCorrect => 'Правильно!';

  @override
  String get quizPlayIncorrect => 'Неверно!';

  @override
  String get quizPlayExitTitle => 'Завершить викторину?';

  @override
  String get quizPlayExitMessage =>
      'Текущий прогресс викторины не сохранится, если вы выйдете сейчас.';

  @override
  String get quizPlayContinue => 'Продолжить викторину';

  @override
  String get quizResultTitle => 'Результаты викторины';

  @override
  String quizResultScore(int correct, int total) {
    return 'Правильно $correct из $total вопросов';
  }

  @override
  String get quizResultExcellent => 'Великолепно!';

  @override
  String get quizResultGood => 'Хорошая работа!';

  @override
  String get quizResultNeedsWork => 'Нужно больше практики!';

  @override
  String get quizResultDescExcellent =>
      'Вы отлично усвоили слова из этой викторины. Так держать!';

  @override
  String get quizResultDescGood =>
      'Хороший результат! Слова с ошибками автоматически добавлены в раздел \"Повторить\".';

  @override
  String get quizResultDescNeedsWork =>
      'Не расстраивайтесь! Повторите карточки и попробуйте еще раз.';

  @override
  String get quizResultDetails => 'Разбор ответов';

  @override
  String get quizResultRetake => 'Пройти викторину заново';

  @override
  String get quizResultHome => 'На главную';

  @override
  String quizResultUserSelected(String answer) {
    return 'Ваш выбор: $answer';
  }

  @override
  String quizResultCorrectIs(String answer) {
    return 'Правильный ответ: $answer';
  }

  @override
  String get reviewTitle => 'Повторение и избранное';

  @override
  String reviewTabNeedReview(int count) {
    return 'Повторить ($count)';
  }

  @override
  String reviewTabFavorites(int count) {
    return 'Избранное ($count)';
  }

  @override
  String get reviewEmptyNeedReview => 'Нет слов, требующих повторения';

  @override
  String get reviewEmptyNeedReviewDesc =>
      'Когда вы отмечаете слово как \"Повторить\" в карточках или ошибаетесь в викторине, оно автоматически попадает сюда по алгоритму интервального повторения.';

  @override
  String get reviewEmptyFavorites => 'В избранном пока ничего нет';

  @override
  String get reviewEmptyFavoritesDesc =>
      'Нажмите на значок сердечка у любого слова, чтобы сохранить его здесь.';

  @override
  String get reviewLearnFlashcardsNeed => 'Карточки (Повторить)';

  @override
  String get reviewLearnFlashcardsFav => 'Карточки (Избранное)';

  @override
  String reviewTotalWords(int count) {
    return 'Всего: $count слов';
  }

  @override
  String get reviewViewStats => 'Посмотреть статистику прогресса';

  @override
  String get wordDetailTitle => 'Информация о слове';

  @override
  String get wordDetailVietnameseDef => 'ОПРЕДЕЛЕНИЕ И ПЕРЕВОД';

  @override
  String get wordDetailSrsTitle => 'Интервальное повторение (SRS)';

  @override
  String wordDetailInterval(int days) {
    return 'Интервал: $days дн.';
  }

  @override
  String wordDetailReviewCount(int count) {
    return 'Повторений: $count';
  }

  @override
  String get wordDetailRealWorldExample => 'Пример в реальном контексте';

  @override
  String wordDetailSynonyms(String synonyms) {
    return 'Синонимы: $synonyms';
  }

  @override
  String wordDetailAntonyms(String antonyms) {
    return 'Антонимы: $antonyms';
  }

  @override
  String get wordDetailTips => 'Советы по запоминанию и произношению';

  @override
  String get wordDetailAddedFav => 'Добавлено в избранное';

  @override
  String get wordDetailRemovedFav => 'Удалено из избранного';

  @override
  String get statsTitle => 'Статистика и прогресс';

  @override
  String get statsOverallProgress => 'Общий прогресс обучения';

  @override
  String statsMasteredRatio(int mastered, int total) {
    return 'Освоено $mastered/$total слов';
  }

  @override
  String get statsTotalWords => 'Всего слов';

  @override
  String get statsMasteredWords => 'Освоено';

  @override
  String get statsNeedReviewWords => 'Повторить';

  @override
  String get statsFavoriteWords => 'В избранном';

  @override
  String get statsTopicProgress => 'Прогресс по темам';

  @override
  String get statsQuizHistory => 'История викторин';

  @override
  String statsAverageScore(String score) {
    return 'Средний: $score%';
  }

  @override
  String get statsEmptyQuiz =>
      'История викторин пуста. Пройдите викторину, чтобы проверить свои знания!';

  @override
  String get statsResetTitle => 'Сбросить данные?';

  @override
  String get statsResetMessage =>
      'Все статусы изучения, история тестов и добавленные слова будут сброшены до начальных настроек приложения.';

  @override
  String get statsResetConfirm => 'Подтвердить сброс';

  @override
  String get statsResetSuccess =>
      'Начальные данные приложения успешно восстановлены!';

  @override
  String get dictTitle => 'Двуязычный словарь';

  @override
  String get dictSearchPlaceholder =>
      'Двуязычный поиск: введите слово на вьетнамском (căn hộ) или английском (apartment)...';

  @override
  String get dictRecentSearches => 'Недавние поиски';

  @override
  String get dictClearHistory => 'Очистить историю';

  @override
  String get dictOnlineViEn => 'Онлайн-перевод с вьетнамского на английский';

  @override
  String get dictOnlineEnVi => 'Онлайн-поиск с английского на вьетнамский';

  @override
  String dictOnlineViEnQuery(String query) {
    return 'Онлайн-перевод с вьетнамского на английский для \"$query\"';
  }

  @override
  String dictOnlineEnViQuery(String query) {
    return 'Онлайн-поиск с английского на вьетнамский для \"$query\"';
  }

  @override
  String dictNotFoundInternal(String query) {
    return 'Слово \"$query\" не найдено во внутреннем словаре.';
  }

  @override
  String get dictListenWord => 'Прослушать произношение носителя языка';

  @override
  String get dictCachedBadge => 'Кэш SQLite (Офлайн)';

  @override
  String get dictSaveToReview => 'Сохранить на повторение';

  @override
  String dictSavedSuccess(String term) {
    return 'Слово \"$term\" сохранено в словарь и список на повторение!';
  }

  @override
  String get dictEnglishDefinitions => 'Английские определения и примеры:';

  @override
  String dictSynonymsList(String synonyms) {
    return 'Синонимы: $synonyms';
  }

  @override
  String get dictNoun => 'Существительное (n)';

  @override
  String get dictVerb => 'Глагол (v)';

  @override
  String get dictAdj => 'Прилагательное (adj)';

  @override
  String get dictAdv => 'Наречие (adv)';

  @override
  String get dictPhrase => 'Фраза / Идиома';

  @override
  String get skillsHubTitle => '4 навыка и практика словарного запаса';

  @override
  String get skillsHubAllLevels => 'Показать все уровни (A1–C1)';

  @override
  String get skillsListening => 'Аудирование';

  @override
  String get skillsReading => 'Чтение';

  @override
  String get skillsWriting => 'Письмо';

  @override
  String get skillsSpeaking => 'Говорение';

  @override
  String get skillsListeningDesc =>
      'Обычная (1.0x) или замедленная (0.75x) скорость аудио. Текст и перевод заблокированы до отправки ответов.';

  @override
  String get skillsReadingDesc =>
      'Тексты уровней A1–C1, вопросы с выбором ответа и заполнение пропусков, полные объяснения.';

  @override
  String get skillsWritingDesc =>
      'Составление предложений из слов и написание эссе по 4 критериям с примерами решений.';

  @override
  String get skillsSpeakingDesc =>
      'Произношение, интонация, связывание звуков и самооценка по чек-листу из 4 критериев.';

  @override
  String get skillsStartLearning => 'Учиться сейчас';

  @override
  String skillsProgressText(int completed, int total) {
    return 'Прогресс: пройдено уроков $completed/$total';
  }

  @override
  String skillsCompletedBadge(int score) {
    return 'Завершено • $score%';
  }

  @override
  String skillsLessonList(int count) {
    return 'Список уроков ($count уроков)';
  }

  @override
  String skillsNoLessonLevel(String level) {
    return 'Нет доступных уроков для уровня $level.';
  }

  @override
  String get skillsOpenShadowing => 'Открыть студию Shadowing';

  @override
  String get skillsMatchingGameTitle => 'Игра «Найди пару»';

  @override
  String get skillsFlashcard3dTitle => '3D-карточки';

  @override
  String get skillsQuizReflexTitle => 'Викторина на реакцию';

  @override
  String get skillsExamHubTitle => 'Экзаменационная комната на время';

  @override
  String get skillsSrsReviewTitle => 'Интервальное повторение SRS';

  @override
  String get exerciseListeningTitle => 'Понимание на слух';

  @override
  String get exerciseReadingTitle => 'Понимание прочитанного';

  @override
  String exerciseQuestionsCount(int count) {
    return 'Вопросы на понимание ($count вопросов)';
  }

  @override
  String exerciseScoreResult(int correct, int total, int percent) {
    return 'Результат: правильно $correct/$total ($percent%)';
  }

  @override
  String get exerciseShowTranscript => 'Показать текст и перевод';

  @override
  String get exerciseHideTranscript => 'Скрыть текст и перевод';

  @override
  String get exerciseReadingPassage => 'Текст для чтения';

  @override
  String get exerciseAudioPlayer => 'Аудиоплеер';

  @override
  String exerciseKeyWords(int count) {
    return 'Ключевые слова урока ($count слов)';
  }

  @override
  String get exerciseSubmitGrade => 'Отправить и оценить';

  @override
  String get exerciseRetake => 'Пройти урок заново';

  @override
  String exerciseSaveWordSuccess(String term) {
    return 'Слово \"$term\" добавлено в повторение и избранное!';
  }

  @override
  String get speakingTimerPractice => 'Практика говорения на время';

  @override
  String speakingRecordPrompt(int seconds) {
    return 'Запись ($secondsс) - Нажмите для остановки';
  }

  @override
  String speakingRubricSelfCheck(int checked, int total) {
    return 'Самооценка ($checked/$total критериев выполнено)';
  }

  @override
  String speakingSaveSuccess(int score) {
    return 'Результат самооценки говорения ($score%) сохранен в историю!';
  }

  @override
  String get writingTabScramble => '1. Структура и сборка предложения';

  @override
  String get writingTabRubric => '2. Написание текста и критерии';

  @override
  String get writingTapWordToForm =>
      'Нажимайте на слова ниже, чтобы составить предложение...';

  @override
  String get writingCheckSentence => 'Проверить предложение';

  @override
  String writingWordCountStatus(int count, int min) {
    return 'Слов: $count / мин. $min слов';
  }

  @override
  String writingNeedMoreWords(int count) {
    return 'Нужно еще $count слов';
  }

  @override
  String get writingSaveModelAnswer => 'Сохранить эссе и открыть образец';

  @override
  String get writingModelAnswerTitle => 'Образец сочинения (Для справки)';

  @override
  String get shadowingHubTitle => 'Студия рефлекторного Shadowing';

  @override
  String get shadowingMethodTitle =>
      '4-этапный метод Shadowing для идеальной интонации';

  @override
  String get shadowingMethodDesc =>
      '1. Прослушивание образца (1.0x) → 2. Медленное прослушивание и анализ связок (0.75x) → 3. Синхронное повторение → 4. Честная самооценка.';

  @override
  String shadowingLessonsList(int count) {
    return 'Уроки Shadowing ($count уроков)';
  }

  @override
  String get shadowingPracticeTitle => 'Практика Shadowing';

  @override
  String get shadowingStep1 => 'Шаг 1: Прослушать образец (1.0x)';

  @override
  String get shadowingStep2 => 'Шаг 2: Медленное прослушивание (0.75x)';

  @override
  String get shadowingStep3 => 'Шаг 3: Синхронное повторение за диктором';

  @override
  String get shadowingStep4 => 'Шаг 4: Самооценка (Обязательно)';

  @override
  String shadowingSpeakingStatus(int seconds) {
    return 'Идет Shadowing ($secondsс)...';
  }

  @override
  String get shadowingSaveProgress => 'Сохранить прогресс Shadowing';

  @override
  String shadowingSavedSuccess(int score) {
    return 'Прогресс урока Shadowing ($score% критериев) сохранен в базу данных!';
  }

  @override
  String get gamesHubTitle => 'Центр мини-игр со словами';

  @override
  String get gamesHubSubtitle =>
      'Улучшайте запоминание слов с помощью быстрой печати, боевой арены и падающих капель-слов.';

  @override
  String get gamesSelectGame => 'Выберите игру для старта:';

  @override
  String get gamesSpaceTyperTitle => 'Space Typer';

  @override
  String get gamesSpaceTyperDesc =>
      'Печатайте буквы и слова, чтобы уничтожать астероиды. Автонаведение корабля, лазерные выстрелы и радар защиты.';

  @override
  String get gamesArenaTitle => 'Лексическая арена';

  @override
  String get gamesArenaDesc =>
      'Викторина на реакцию (7-15 сек), комбо-серии очков, поддержка цифровых клавиш 1-4 на клавиатуре.';

  @override
  String get gamesWordRainTitle => 'Дождь из слов';

  @override
  String get gamesWordRainDesc =>
      'Ловите падающие капли с английскими словами, соответствующими заданному значению, пока они не упали в воду.';

  @override
  String get gamesPlayNow => 'Играть сейчас';

  @override
  String get gamesRules => 'Правила и инструкции';

  @override
  String gamesHighScore(int score) {
    return 'Рекорд: $score очков';
  }

  @override
  String gamesRecentHistory(int count) {
    return 'История последних игр ($count игр)';
  }

  @override
  String gameScorePoints(int score) {
    return '$score очков';
  }

  @override
  String get gameOver => 'Игра окончена!';

  @override
  String get gameCompleted => 'Раунд завершен!';

  @override
  String get gamePlayAgain => 'Сыграть снова';

  @override
  String get gameBackToHub => 'Вернуться к списку игр';

  @override
  String get gameAccuracy => 'Точность';

  @override
  String get gameTime => 'Время';

  @override
  String get gameStreak => 'Макс. серия';

  @override
  String get gameNewRecord => '🎉 НОВЫЙ ЛИЧНЫЙ РЕКОРД!';

  @override
  String get gameDiffEasy => 'Легко';

  @override
  String get gameDiffMedium => 'Средне';

  @override
  String get gameDiffHard => 'Сложно';

  @override
  String get examHubTitle => 'Международные сертификационные экзамены';

  @override
  String get examHubSubtitle =>
      'Тренировочные и симуляционные тесты на время (IELTS • TOEIC • CEFR)';

  @override
  String examListTitle(int count) {
    return 'Доступные экзамены ($count тестов)';
  }

  @override
  String get examPracticeMode => 'Режим практики';

  @override
  String get examPracticeModeDesc =>
      'Без ограничения времени, моментальный просмотр подсказок и подробных объяснений к каждому вопросу.';

  @override
  String get examTimedMode => 'Режим экзамена (на время)';

  @override
  String get examTimedModeDesc =>
      'Таймер обратного отсчета, автоматическая сдача по истечении времени, полный отчет с оценками.';

  @override
  String examQuestionCounter(int current, int total) {
    return 'Вопрос $current/$total';
  }

  @override
  String get examSubmitConfirm => 'Сдать экзамен?';

  @override
  String get examSubmitConfirmDesc =>
      'Вы уверены, что хотите завершить и сдать экзамен для проверки результатов?';

  @override
  String get examResultTitle => 'Результаты экзамена и подробный разбор';

  @override
  String examScoreBand(String band) {
    return 'Примерный балл (Band): $band';
  }

  @override
  String examCorrectRatio(int correct, int total, int percent) {
    return 'Правильно: $correct/$total вопросов ($percent%)';
  }

  @override
  String get aiChatTitle => 'ИИ-помощник English Buddy';

  @override
  String get aiChatSubtitle =>
      'Вопросы по грамматике • Перевод предложений • Разбор эссе';

  @override
  String get aiChatGreeting =>
      'Здравствуйте! Чем я могу помочь вам в изучении английского сегодня?';

  @override
  String get aiChatGreetingDesc =>
      'Задайте любой вопрос по грамматике, попросите перевести предложение или оценить эссе!';

  @override
  String get aiChatSuggestions => 'РЕКОМЕНДУЕМЫЕ ВОПРОСЫ ДЛЯ ПРАКТИКИ';

  @override
  String get aiChatInputPlaceholder =>
      'Введите вопрос, предложение для перевода или эссе...';

  @override
  String get aiChatClearTitle => 'Очистить беседу?';

  @override
  String get aiChatClearDesc =>
      'Все сообщения чата с ИИ будут удалены с этого устройства. Это действие нельзя отменить.';

  @override
  String get aiChatClearSuccess => 'История чата успешно очищена.';

  @override
  String get aiChatThinking => 'ИИ думает...';

  @override
  String get authSignInTitle => 'Вход в аккаунт';

  @override
  String get authSignUpTitle => 'Создание аккаунта';

  @override
  String get authAccountOrEmail => 'Имя пользователя или Email';

  @override
  String get authEmail => 'Адрес электронной почты';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authConfirmPassword => 'Подтвердите пароль';

  @override
  String get authDisplayName => 'Отображаемое имя';

  @override
  String get authGoogleSignIn => 'Продолжить с Google';

  @override
  String get authProcessing => 'Обработка...';

  @override
  String get authPasswordMismatch => 'Пароли не совпадают!';

  @override
  String get authMinPassword => 'Не менее 8 символов';

  @override
  String get authInvalidEmail => 'Введите корректный адрес электронной почты';

  @override
  String get authOr => 'ИЛИ';

  @override
  String get statsResetButton => 'Восстановить исходные данные';

  @override
  String statsQuizQuestionsCount(Object correct, Object total) {
    return '$correct/$total вопросов';
  }

  @override
  String statsTopicWordsProgress(
    Object mastered,
    Object percent,
    Object total,
  ) {
    return '$mastered/$total слов ($percent%)';
  }

  @override
  String get dictTitleFull =>
      'Двуязычный словарь вьетнамско-английский и англо-вьетнамский';

  @override
  String dictSearchDirection(Object flag, Object label) {
    return 'Направление поиска: $flag $label';
  }

  @override
  String get dictViDetected =>
      'Определено: вьетнамский ➜ Отображаются эквивалентные английские слова';

  @override
  String get dictEnDetected =>
      'Определено: английский ➜ Отображаются перевод и определения';

  @override
  String get dictAllLevels => 'Все уровни';

  @override
  String get dictAllTopics => 'Все темы';

  @override
  String get dictAllPos => 'Все части речи';

  @override
  String get dictIntroDesc =>
      'Умный двусторонний поиск: введите слово на вьетнамском, чтобы найти английские эквиваленты, или на английском для получения перевода. Более 3 000 слов CEFR A1–C1 офлайн с онлайн-расширением (Google Translate и Wiktionary с кэшированием в SQLite).';

  @override
  String get dictViEnOnlinePrompt =>
      'Вы можете расширить перевод онлайн с вьетнамского на английский (автоматически находит английские слова, определения, произношение и сохраняет в SQLite).';

  @override
  String get dictEnViOnlinePrompt =>
      'Вы можете расширить поиск онлайн с английского на вьетнамский (перевод, толкования на английском, произношение и сохранение в SQLite).';

  @override
  String get dictRetry => 'Повторить';

  @override
  String get dictRetryConnection => 'Повторить подключение';

  @override
  String get dictTtsTooltip => 'Стандартное произношение (TTS)';

  @override
  String get dictInReview => 'На повторении';

  @override
  String get dictAddToReview => 'Добавить в повторение';

  @override
  String dictMovedToNew(Object term) {
    return 'Слово \"$term\" перемещено в новые слова';
  }

  @override
  String dictAddedToReview(Object term) {
    return 'Слово \"$term\" добавлено в список на повторение!';
  }

  @override
  String get dictFavoriteAdd => 'Добавить слово в избранное';

  @override
  String get dictFavoriteRemove => 'Удалить из избранного';

  @override
  String get dictLiveApi => 'Онлайн (Live API)';

  @override
  String get dictSaved => 'Сохранено';

  @override
  String dictViKeyword(Object query) {
    return 'Ключевое слово на вьетнамском: \"$query\"';
  }

  @override
  String get dictEquivalentEnWords => 'Эквивалентные английские слова:';

  @override
  String dictListenTooltip(Object word) {
    return 'Нажмите, чтобы прослушать: $word';
  }

  @override
  String dictViRefMeaning(Object meaning) {
    return 'Справочный перевод: $meaning';
  }

  @override
  String get dictViTranslation => 'Перевод на вьетнамский:';

  @override
  String get dictOtherMeanings => 'Другие варианты перевода:';

  @override
  String dictSourceInfo(Object license, Object source, Object url) {
    return 'Источник: $source • Лицензия: $license ($url)';
  }

  @override
  String dictExamplePrefix(Object example) {
    return 'Пример: \"$example\"';
  }

  @override
  String get avatarChangePhoto => 'Изменить аватар';

  @override
  String get avatarSelectFromDevice => 'Выбрать с устройства / Галереи';

  @override
  String get avatarSelectFromUrl => 'Ввести прямой URL изображения';

  @override
  String get avatarResetDefault => 'Сбросить на аватар по умолчанию';

  @override
  String get avatarEnterUrlTitle => 'Введите URL аватара';

  @override
  String get avatarUrlPlaceholder => 'https://example.com/avatar.jpg';

  @override
  String get avatarInvalidUrl =>
      'Недействительный URL или не является изображением';

  @override
  String get skillsSelectSkill => 'Выберите навык для практики:';

  @override
  String get skillsAllLevels => 'Все уровни';

  @override
  String skillsQuestionsCount(Object count) {
    return '$count вопросов';
  }

  @override
  String skillsExerciseCount(Object count) {
    return '$count упражнений';
  }

  @override
  String get skillsStartPractice => 'Начать практику';

  @override
  String get skillsTranscriptLocked => 'Текст заблокирован';

  @override
  String get skillsTranscriptUnlocked => 'Текст аудиозаписи';

  @override
  String get skillsSubmitExercise => 'Отправить задание';

  @override
  String get skillsCompleted => 'Завершено';

  @override
  String skillsScore(Object score, Object total) {
    return 'Оценка: $score/$total';
  }

  @override
  String get skillsTryAgain => 'Попробовать снова';

  @override
  String get skillsNextExercise => 'Следующее упражнение';

  @override
  String get skillsListenNormal => 'Обычная скорость 1.0x';

  @override
  String get skillsListenSlow => 'Медленная скорость 0.75x';

  @override
  String get skillsExplanation => 'Подробное объяснение';

  @override
  String get skillsMatchingPairs => 'Сопоставьте слова с их значениями';

  @override
  String get skillsSpeakingPrompt => 'Прочитайте следующий текст вслух';

  @override
  String get skillsWritingPrompt => 'Напишите текст по заданию';

  @override
  String gameDifficulty(Object diff) {
    return 'Сложность: $diff';
  }

  @override
  String gameScore(Object score) {
    return 'Счет: $score';
  }

  @override
  String gameHighScore(Object score) {
    return 'Рекорд: $score';
  }

  @override
  String get gameExit => 'Выйти из игры';

  @override
  String gameCombo(Object multiplier) {
    return 'Комбо x$multiplier';
  }

  @override
  String gameWpm(Object wpm) {
    return 'Скорость: $wpm сл/мин';
  }

  @override
  String get gameStart => 'Начать игру';

  @override
  String get gamePause => 'Пауза';

  @override
  String get gameResume => 'Продолжить';

  @override
  String get gameRestart => 'Сначала';

  @override
  String gameLives(Object lives) {
    return 'Жизни: $lives';
  }

  @override
  String gameLevel(Object level) {
    return 'Уровень: $level';
  }

  @override
  String get examMode => 'Режим экзамена';

  @override
  String examTimeRemaining(Object time) {
    return 'Осталось времени: $time';
  }

  @override
  String get examSubmit => 'Сдать экзамен';

  @override
  String get examPassed => 'Сдано';

  @override
  String get examFailed => 'Требуется доработка';

  @override
  String get examScoreBreakdown => 'Разбивка баллов';

  @override
  String get examReviewAnswers => 'Просмотр ответов и пояснений';

  @override
  String get examRetake => 'Пересдать экзамен';

  @override
  String get examBackToHub => 'Назад к центру экзаменов';

  @override
  String get shadowingListen1 => 'Шаг 1: Слушать образец (1.0x)';

  @override
  String get shadowingListen2 => 'Шаг 2: Слушать медленно (0.75x)';

  @override
  String get shadowingRecord => 'Шаг 3: Повторять за диктором';

  @override
  String get shadowingStop => 'Остановить запись';

  @override
  String get shadowingSelfEval => 'Шаг 4: Самооценка';

  @override
  String get shadowingNext => 'Следующее предложение';

  @override
  String get shadowingComplete => 'Практика Shadowing завершена!';

  @override
  String get authLogin => 'Войти';

  @override
  String get authRegister => 'Зарегистрироваться';

  @override
  String get authNoAccount => 'Нет аккаунта? Зарегистрируйтесь';

  @override
  String get authAlreadyHaveAccount => 'Уже есть аккаунт? Войдите';

  @override
  String get authLogout => 'Выйти';

  @override
  String get authLogoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get profileTitle => 'Профиль пользователя';

  @override
  String get profileEdit => 'Редактировать профиль';

  @override
  String get profileSave => 'Сохранить изменения профиля';

  @override
  String get profileDisplayName => 'Отображаемое имя';

  @override
  String get profileEmail => 'Электронная почта';

  @override
  String get profileRole => 'Роль';

  @override
  String get profileJoined => 'Дата регистрации';

  @override
  String get adminTitle => 'Панель администратора (Admin)';

  @override
  String get adminUsers => 'Пользователи и уровни';

  @override
  String get adminVocab => 'Словарь и темы';

  @override
  String get adminExercises => 'Чтение и аудирование';

  @override
  String get adminExams => 'Тренировочные экзамены';

  @override
  String get adminSystem => 'Мониторинг системы';

  @override
  String get adminForbidden =>
      'Зона только для администраторов (403 Запрещено)';

  @override
  String get adminRefresh => 'Обновить данные админки';

  @override
  String get aiChatAsk => 'Спросить ИИ';

  @override
  String get settingsSelectLanguage => 'Выберите язык приложения';

  @override
  String get settingsSearchLanguage => 'Поиск языка...';

  @override
  String get settingsAllLanguages => 'Все 13 языков';

  @override
  String get settingsAllLanguagesSubtitle =>
      'Китайский, японский, корейский, французский, немецкий, испанский, русский...';

  @override
  String get settingsDefaultBadge => 'По умолчанию';

  @override
  String get profileUsernameLabel => 'Имя пользователя для входа (Username)';

  @override
  String get profileUsernameHint =>
      'Введите имя пользователя (3–30 символов: a-z, 0-9, ., _, -)';

  @override
  String get profileUsernameHelperPassword =>
      'Вы можете войти, используя это имя пользователя или Email с паролем.';

  @override
  String get profileUsernameHelperGoogle =>
      'Аккаунты Google продолжают входить через Google; это имя пользователя — ваш уникальный идентификатор.';

  @override
  String get profileEmailReadOnlyHelper =>
      'Email для входа (только для чтения, не меняется при смене имени или логина)';

  @override
  String get weeklyProgressTitle => 'Недельный прогресс';

  @override
  String weeklyProgressActiveDays(int count) {
    return '$count/7 активных дней';
  }

  @override
  String weeklyProgressWordsStudied(int count) {
    return '$count слов изучено/повторено';
  }

  @override
  String weeklyProgressActivitiesDone(int count) {
    return '$count заданий выполнено';
  }

  @override
  String weeklyProgressTodayGoal(int current, int goal) {
    return 'Цель по словам на сегодня: $current/$goal слов';
  }

  @override
  String get weeklyProgressTodayBadge => 'Сегодня';

  @override
  String get weeklyProgressEmptyTitle =>
      'На этой неделе пока нет учебных активностей';

  @override
  String get weeklyProgressEmptyDesc =>
      'Повторите слова или пройдите тест/упражнение, чтобы график недельного прогресса сразу обновился!';

  @override
  String get weeklyProgressStartCta => 'Повторить слова сейчас';

  @override
  String get weeklyProgressScopeNote =>
      'Учитывает реальные действия текущего аккаунта с отметкой времени (пн – вс по местному времени).';

  @override
  String get weeklyProgressUnitWords => 'слов';

  @override
  String get weeklyProgressUnitActivities => 'зад.';

  @override
  String get aiChatErrorGeneral => 'Не удалось получить ответ от ИИ';

  @override
  String get authRegisterSuccessPleaseLogin =>
      'Регистрация прошла успешно! Пожалуйста, войдите, чтобы продолжить.';
}
