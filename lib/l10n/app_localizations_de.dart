// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'English Buddy';

  @override
  String get navHome => 'Startseite';

  @override
  String get navTopics => 'Themen';

  @override
  String get navListening => 'Hören';

  @override
  String get navReading => 'Lesen';

  @override
  String get navWriting => 'Schreiben';

  @override
  String get navSpeaking => 'Sprechen';

  @override
  String get navShadowing => 'Shadowing';

  @override
  String get navDictionary => 'Wortschatz & Wörterbuch';

  @override
  String get navExam => 'Prüfungen';

  @override
  String get navGames => 'Spiele';

  @override
  String get navReview => 'Wiederholung';

  @override
  String get navStats => 'Statistiken';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get navAdmin => 'Admin';

  @override
  String get navSectionSkills => 'FERTIGKEITEN & LERNEN';

  @override
  String get navSectionSystem => 'FORTSCHRITT & SYSTEM';

  @override
  String get sidebarExpandTooltip => 'English Buddy - Seitenleiste erweitern';

  @override
  String get sidebarCollapseTooltip => 'Seitenleiste einklappen';

  @override
  String get mobileMenuTooltip =>
      'Menü mit 13 Fertigkeiten & Funktionen öffnen';

  @override
  String get aiChatTooltip => 'English Buddy KI-Assistent';

  @override
  String get aiChatQuickHelp => 'Grammatik-Fragen & Übersetzung';

  @override
  String get aiChatDesc =>
      'English Buddy KI-Assistent (Fragen & Fehlerkorrektur)';

  @override
  String get accessDeniedAdminOnly =>
      'Zugriff verweigert: Der Admin-Bereich ist nur für Administratorkonten zugänglich.';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionConfirm => 'Bestätigen';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionBack => 'Zurück';

  @override
  String get actionNext => 'Weiter';

  @override
  String get actionPrevious => 'Zurück';

  @override
  String get actionContinue => 'Fortfahren';

  @override
  String get actionRetry => 'Wiederholen';

  @override
  String get actionSubmit => 'Abgeben';

  @override
  String get actionStart => 'Starten';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionSearch => 'Suchen';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionReset => 'Zurücksetzen';

  @override
  String get actionResetFilter => 'Filter zurücksetzen';

  @override
  String get actionClear => 'Löschen';

  @override
  String get actionShowAll => 'Alle anzeigen';

  @override
  String get actionExpand => 'Erweitern';

  @override
  String get actionCollapse => 'Einklappen';

  @override
  String get actionPlay => 'Abspielen';

  @override
  String get actionPause => 'Pausieren';

  @override
  String get actionResume => 'Fortsetzen';

  @override
  String get actionExit => 'Beenden';

  @override
  String get actionUnderstood => 'Verstanden';

  @override
  String get actionCopy => 'Kopieren';

  @override
  String get statusActive => 'Aktiv';

  @override
  String get statusLocked => 'Gesperrt';

  @override
  String get statusCompleted => 'Abgeschlossen';

  @override
  String get statusPending => 'Ausstehend';

  @override
  String get statusAll => 'Alle';

  @override
  String get allTopics => 'Alle Themen';

  @override
  String get allLevels => 'Alle Niveaustufen';

  @override
  String get allSkills => 'Alle Fertigkeiten';

  @override
  String get allFormats => 'Alle Formate';

  @override
  String get levelA1 => 'A1 - Anfänger';

  @override
  String get levelA2 => 'A2 - Grundlegende Kenntnisse';

  @override
  String get levelB1 => 'B1 - Mittelstufe';

  @override
  String get levelB2 => 'B2 - Gute Mittelstufe';

  @override
  String get levelC1 => 'C1 - Fortgeschritten';

  @override
  String get settingsTitle => 'Einstellungen & Präferenzen';

  @override
  String get settingsLanguageSection => 'Sprache & Lokalisierung';

  @override
  String get settingsLanguageSubtitle =>
      'Wählen Sie Ihre bevorzugte App-Sprache';

  @override
  String get settingsLangVi => 'Tiếng Việt';

  @override
  String get settingsLangViDesc => 'Vietnamesisch';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsLangEnDesc => 'Englisch';

  @override
  String get settingsAccountSection => 'Profil & Konto';

  @override
  String get settingsThemeSection => 'Design & Benutzeroberfläche';

  @override
  String get settingsThemeSystem => 'Systemstandard';

  @override
  String get settingsThemeSystemDesc =>
      'Automatisch an Geräteeinstellungen anpassen';

  @override
  String get settingsThemeLight => 'Heller Modus';

  @override
  String get settingsThemeDark => 'Dunkler Modus';

  @override
  String get settingsDailyGoalSection => 'Tägliches Lernziel';

  @override
  String get settingsDailyGoalSubtitle =>
      'Wählen Sie, wie viele Wörter Sie täglich lernen möchten:';

  @override
  String settingsDailyGoalUnit(int count) {
    return '$count Wörter';
  }

  @override
  String settingsDailyGoalSaved(int count) {
    return 'Tagesziel auf $count Wörter/Tag festgelegt!';
  }

  @override
  String get settingsSoundSection => 'Audio & Aussprache';

  @override
  String get settingsSoundEnable => 'Aussprache-Audio aktivieren';

  @override
  String get settingsSoundEnableDesc =>
      'Muttersprachliche Text-to-Speech Aussprache-Engine';

  @override
  String get settingsCopyrightSection => 'Datenquellen & Urheberrecht';

  @override
  String get settingsCopyrightTitle => 'Transparente Urheberrechtsrichtlinie';

  @override
  String get settingsCopyrightDesc1 =>
      '• Wortschatzinhalte, Beispielsätze und Übungen wurden ursprünglich auf Basis der GER-Stufen (A1–C1) und offener Sprachrahmen erstellt.';

  @override
  String get settingsCopyrightDesc2 =>
      '• Wir kopieren keine urheberrechtlich geschützten Definitionen oder Inhalte aus Cambridge Dictionary, DOL English oder kommerziellen Quellen.';

  @override
  String get settingsCopyrightDesc3 =>
      '• Die Online-Suche nutzt die Free Dictionary API (Open Source, kein API-Schlüssel erforderlich, lizenziert unter CC BY-SA 3.0).';

  @override
  String get settingsAppSubtitle =>
      'Mobiles Anwendungsprojekt - Flutter & SQLite';

  @override
  String get guestUser => 'Gast (Nicht angemeldet)';

  @override
  String get guestUserDesc =>
      'Nicht angemeldet. Melden Sie sich an oder erstellen Sie ein Konto, um Ihr Profil zu verwalten und den Lernfortschritt zu synchronisieren.';

  @override
  String authenticatedAs(String email, String provider) {
    return '$email • Bestätigt ($provider)';
  }

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get adminArea => 'Admin-Bereich';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signUp => 'Konto erstellen';

  @override
  String get signOut => 'Abmelden';

  @override
  String get confirmSignOutTitle => 'Abmeldung bestätigen';

  @override
  String confirmSignOutMessage(String email) {
    return 'Sind Sie sicher, dass Sie sich von \"$email\" abmelden möchten?\n\nIhre aktuelle Sitzung und Ihr Token werden entfernt. Der lokale Lernfortschritt auf diesem Gerät bleibt erhalten.';
  }

  @override
  String accountMenuHeader(String displayName) {
    return 'Konto ($displayName)';
  }

  @override
  String get homeGreetingGuest => 'Hallo! 👋';

  @override
  String homeGreetingUser(String name) {
    return 'Hallo, $name! 👋';
  }

  @override
  String get homeSubtitle =>
      'Bereit, deinen Wortschatz und deine Englischkenntnisse heute zu erweitern?';

  @override
  String homeDayStreak(int days) {
    return '$days Tage';
  }

  @override
  String get homeStreakLabel => 'Tages-Serie';

  @override
  String homeMasteredWords(int mastered, int total) {
    return '$mastered/$total gemeistert';
  }

  @override
  String homeProgressSummary(int mastered, int total, int percent) {
    return 'Du hast $mastered von $total GER-Wörtern gemeistert ($percent% abgeschlossen).';
  }

  @override
  String homeGoalTitle(int count) {
    return 'Tagesziel: $count Wörter/Tag';
  }

  @override
  String homeReviewNow(int count) {
    return 'Jetzt wiederholen ($count Wörter)';
  }

  @override
  String homeDueSrsCount(int count) {
    return '$count zur Wiederholung fällig';
  }

  @override
  String homeWordsToLearn(int count) {
    return '$count Wörter zu lernen';
  }

  @override
  String homeTopicCount(int count) {
    return '$count Themen';
  }

  @override
  String homeTopicCefrCount(int count) {
    return '$count GER-Themen';
  }

  @override
  String get homeShortcutsTitle => 'Lern-Verknüpfungen';

  @override
  String get homeViewAll => 'Alle anzeigen';

  @override
  String get homeCardTopicsTitle => 'Wortschatz-Themen';

  @override
  String get homeCardTopicsDesc => 'GER-Themen erkunden';

  @override
  String get homeCardReviewTitle => 'Wiederholungsliste';

  @override
  String get homeCardReviewDesc =>
      'Wörter, die aktuell wiederholt werden müssen';

  @override
  String get homeCardExamTitle => 'IELTS/TOEIC Prüfungsvorbereitung';

  @override
  String get homeCardExamDesc =>
      'Tests mit Zeitbegrenzung & detaillierten Erklärungen';

  @override
  String get homeCardGamesTitle => 'Wortschatz-Spiele';

  @override
  String get homeCardGamesDesc => 'Paare zuordnen & Reaktions-Quiz';

  @override
  String get homeCardShadowingTitle => 'Reflex-Shadowing';

  @override
  String get homeCardShadowingDesc => 'Satzbetonung & Lautverbindungen';

  @override
  String get homeCardDictionaryTitle => 'Englisch - Vietnamesisch Wörterbuch';

  @override
  String get homeCardDictionaryDesc => 'Über 3.000 Wörter nachschlagen';

  @override
  String get homeCardAiTitle => 'English Buddy KI';

  @override
  String get homeCardAiDesc => 'Grammatikfragen, Nachschlagen & Text-Feedback';

  @override
  String get homeCardStatsTitle => 'Fortschritt & Statistiken';

  @override
  String get homeCardStatsDesc => 'Gemeisterte Wörter & Quiz-Verlauf';

  @override
  String get homeTodayWord => 'Wort des Tages';

  @override
  String get homeChangeWord => 'Neues Wort';

  @override
  String get homeSaveFavorite => 'Zu Favoriten hinzufügen';

  @override
  String get homeRemoveFavorite => 'Aus Favoriten entfernen';

  @override
  String get homeListenPronunciation => 'Aussprache anhören';

  @override
  String get homeSavedSuccess => 'Gespeichert';

  @override
  String get topicsTitle => 'Lern-Themen';

  @override
  String topicsSubtitle(int count) {
    return 'Entdecken Sie $count lebensnahe Wortschatzthemen von Niveau A1 bis C1.';
  }

  @override
  String topicsCountWords(int count) {
    return '$count Vokabeleinträge';
  }

  @override
  String topicsMasteredCount(int mastered, int total) {
    return 'Gemeistert: $mastered/$total';
  }

  @override
  String get topicSearchPlaceholder =>
      'Englisches Wort oder vietnamesische Bedeutung suchen...';

  @override
  String topicLearnFlashcard(int count) {
    return 'Karteikarten lernen ($count)';
  }

  @override
  String get topicFilterAll => 'Alle';

  @override
  String get topicFilterNew => 'Neu';

  @override
  String get topicFilterReview => 'Wiederholen';

  @override
  String get topicFilterMastered => 'Gemeistert';

  @override
  String get topicEmptyWord => 'Keine Vokabeln gefunden';

  @override
  String get topicEmptyWordDesc =>
      'Versuchen Sie es mit anderen Suchbegriffen oder ändern Sie die Filter.';

  @override
  String get addWordTitle => 'Neues Wort hinzufügen';

  @override
  String addWordTopicTarget(String topicName) {
    return 'In Thema: $topicName';
  }

  @override
  String get addWordEnglishLabel => 'Englisches Wort *';

  @override
  String get addWordEnglishHint => 'z. B.: Innovation';

  @override
  String get addWordMeaningLabel => 'Vietnamesische Bedeutung *';

  @override
  String get addWordMeaningHint => 'z. B.: Sự đổi mới, cách tân';

  @override
  String get addWordIpaLabel => 'IPA-Lautschrift';

  @override
  String get addWordIpaHint => 'z. B.: /ˌɪn.əˈveɪ.ʃən/';

  @override
  String get addWordPartOfSpeechLabel => 'Wortart';

  @override
  String get addWordExampleEnLabel => 'Beispielsatz (Englisch)';

  @override
  String get addWordExampleEnHint =>
      'z. B.: Innovation drives technology forward.';

  @override
  String get addWordExampleViLabel => 'Übersetzung des Beispielsatzes';

  @override
  String get addWordExampleViHint =>
      'z. B.: Sự đổi mới thúc đẩy công nghệ tiến lên.';

  @override
  String get addWordNotesLabel => 'Notizen / Aussprache-Tipps';

  @override
  String get addWordNotesHint => 'z. B.: Betonung auf der 3. Silbe';

  @override
  String get addWordSaveButton => 'Wort speichern';

  @override
  String get addWordRequiredEnglish => 'Bitte geben Sie das englische Wort ein';

  @override
  String get addWordRequiredMeaning =>
      'Bitte geben Sie die vietnamesische Bedeutung ein';

  @override
  String addWordSuccess(String term) {
    return '\"$term\" erfolgreich hinzugefügt!';
  }

  @override
  String get flashcardTapToFlip => 'Tippen, um zum Wort umzudrehen';

  @override
  String get flashcardTapToMeaning => 'Tippen, um Bedeutung anzuzeigen';

  @override
  String get flashcardVietnameseMeaning => 'VIETNAMESISCHE BEDEUTUNG';

  @override
  String get flashcardNeedReview => 'Wiederholen';

  @override
  String get flashcardMastered => 'Gemeistert';

  @override
  String get flashcardCompletedTitle => 'Großartig! Du hast es geschafft!';

  @override
  String flashcardCompletedDesc(int count) {
    return 'Du hast gerade $count Karteikarten wiederholt.';
  }

  @override
  String get flashcardReviewAgain => 'Erneut wiederholen';

  @override
  String get flashcardBack => 'Zurück zur vorherigen Seite';

  @override
  String get flashcardEmpty => 'Keine Vokabeln zur Wiederholung verfügbar.';

  @override
  String get quizSetupTitle => 'Quiz-Herausforderung';

  @override
  String get quizSetupHeader => 'Schnelligkeits- & Reflex-Quiz';

  @override
  String get quizSetupSubtitle =>
      'Festige deinen Wortschatz durch vielseitige Formate: Bedeutungsauswahl, Wortauswahl und Lückentexte im Kontext.';

  @override
  String get quizSetupSelectTopic => 'Quiz-Thema auswählen';

  @override
  String get quizSetupAllTopics => 'Umfassend (Alle Themen)';

  @override
  String get quizSetupAllTopicsDesc =>
      'Zufällig aus der gesamten Wortschatzdatenbank ausgewählt';

  @override
  String get quizSetupQuestionCount => 'Anzahl der Fragen';

  @override
  String get quizSetupCountFast => '5 Fragen (Schnell)';

  @override
  String get quizSetupCountStandard => '10 Fragen (Standard)';

  @override
  String get quizSetupStart => 'Quiz starten';

  @override
  String get quizPlayTitle => 'Quiz-Herausforderung';

  @override
  String quizPlayQuestionCounter(int current, int total) {
    return 'Frage $current/$total';
  }

  @override
  String get quizPlayTypeSelectMeaning =>
      'Wählen Sie die richtige vietnamesische Bedeutung';

  @override
  String get quizPlayTypeSelectWord => 'Wählen Sie das richtige englische Wort';

  @override
  String get quizPlayTypeFillBlank =>
      'Füllen Sie die Lücke mit dem passenden Wort aus';

  @override
  String get quizPlayCheck => 'Prüfen';

  @override
  String get quizPlayNext => 'Nächste Frage';

  @override
  String get quizPlayViewResult => 'Ergebnisse anzeigen';

  @override
  String get quizPlayCorrect => 'Richtig!';

  @override
  String get quizPlayIncorrect => 'Falsch!';

  @override
  String get quizPlayExitTitle => 'Quiz beenden?';

  @override
  String get quizPlayExitMessage =>
      'Der aktuelle Quiz-Fortschritt geht verloren, wenn Sie jetzt abbrechen.';

  @override
  String get quizPlayContinue => 'Quiz fortsetzen';

  @override
  String get quizResultTitle => 'Quiz-Ergebnisse';

  @override
  String quizResultScore(int correct, int total) {
    return '$correct / $total Fragen richtig beantwortet';
  }

  @override
  String get quizResultExcellent => 'Hervorragend!';

  @override
  String get quizResultGood => 'Gut gemacht!';

  @override
  String get quizResultNeedsWork => 'Weiter üben!';

  @override
  String get quizResultDescExcellent =>
      'Du beherrschst die Wörter in diesem Quiz souverän. Weiter so!';

  @override
  String get quizResultDescGood =>
      'Gut gemacht! Falsch beantwortete Wörter wurden automatisch unter \"Wiederholen\" gespeichert.';

  @override
  String get quizResultDescNeedsWork =>
      'Lass dich nicht entmutigen! Wiederhole die Karteikarten und versuche es noch einmal.';

  @override
  String get quizResultDetails => 'Antwort-Übersicht';

  @override
  String get quizResultRetake => 'Quiz wiederholen';

  @override
  String get quizResultHome => 'Zurück zur Startseite';

  @override
  String quizResultUserSelected(String answer) {
    return 'Deine Auswahl: $answer';
  }

  @override
  String quizResultCorrectIs(String answer) {
    return 'Richtige Antwort: $answer';
  }

  @override
  String get reviewTitle => 'Wiederholung & Favoriten';

  @override
  String reviewTabNeedReview(int count) {
    return 'Wiederholen ($count)';
  }

  @override
  String reviewTabFavorites(int count) {
    return 'Favoriten ($count)';
  }

  @override
  String get reviewEmptyNeedReview => 'Keine fälligen Wörter zur Wiederholung';

  @override
  String get reviewEmptyNeedReviewDesc =>
      'Wenn Sie ein Wort in den Karteikarten als \"Wiederholen\" markieren oder in Quizzes falsch beantworten, erscheint es automatisch hier basierend auf Spaced Repetition.';

  @override
  String get reviewEmptyFavorites => 'Noch keine Favoriten vorhanden';

  @override
  String get reviewEmptyFavoritesDesc =>
      'Tippen Sie auf das Herzsymbol bei einem beliebigen Wort, um es hier zu speichern.';

  @override
  String get reviewLearnFlashcardsNeed => 'Karteikarten (Wiederholen)';

  @override
  String get reviewLearnFlashcardsFav => 'Karteikarten (Favoriten)';

  @override
  String reviewTotalWords(int count) {
    return 'Gesamt: $count Wörter';
  }

  @override
  String get reviewViewStats => 'Fortschrittsstatistiken anzeigen';

  @override
  String get wordDetailTitle => 'Wortdetails';

  @override
  String get wordDetailVietnameseDef => 'VIETNAMESISCHE DEFINITION';

  @override
  String get wordDetailSrsTitle => 'Spaced-Repetition-System (SRS)';

  @override
  String wordDetailInterval(int days) {
    return 'Intervall: $days Tage';
  }

  @override
  String wordDetailReviewCount(int count) {
    return 'Wiederholungen: $count';
  }

  @override
  String get wordDetailRealWorldExample => 'Beispiel im realen Kontext';

  @override
  String wordDetailSynonyms(String synonyms) {
    return 'Synonyme: $synonyms';
  }

  @override
  String wordDetailAntonyms(String antonyms) {
    return 'Antonyme: $antonyms';
  }

  @override
  String get wordDetailTips => 'Gedächtnis- & Aussprache-Tipps';

  @override
  String get wordDetailAddedFav => 'Zu Favoriten hinzugefügt';

  @override
  String get wordDetailRemovedFav => 'Aus Favoriten entfernt';

  @override
  String get statsTitle => 'Statistiken & Fortschritt';

  @override
  String get statsOverallProgress => 'Gesamter Lernfortschritt';

  @override
  String statsMasteredRatio(int mastered, int total) {
    return '$mastered/$total Wörter gemeistert';
  }

  @override
  String get statsTotalWords => 'Gesamtwortschatz';

  @override
  String get statsMasteredWords => 'Gemeistert';

  @override
  String get statsNeedReviewWords => 'Wiederholen';

  @override
  String get statsFavoriteWords => 'Favoriten';

  @override
  String get statsTopicProgress => 'Fortschritt nach Themen';

  @override
  String get statsQuizHistory => 'Quiz-Verlauf';

  @override
  String statsAverageScore(String score) {
    return 'Durchschnitt: $score%';
  }

  @override
  String get statsEmptyQuiz =>
      'Noch kein Quiz-Verlauf vorhanden. Mach ein Quiz, um deine Reflexe zu testen!';

  @override
  String get statsResetTitle => 'Daten zurücksetzen?';

  @override
  String get statsResetMessage =>
      'Alle Lernstände, Quiz-Verläufe und benutzerdefinierten Vokabeln werden auf den Ausgangszustand zurückgesetzt.';

  @override
  String get statsResetConfirm => 'Zurücksetzen bestätigen';

  @override
  String get statsResetSuccess =>
      'Ursprüngliche Anwendungsdaten erfolgreich wiederhergestellt!';

  @override
  String get dictTitle => 'Zweisprachiges Wörterbuch';

  @override
  String get dictSearchPlaceholder =>
      'Zweisprachige Suche: Vietnamesisch (căn hộ) oder Englisch (apartment) eingeben...';

  @override
  String get dictRecentSearches => 'Letzte Suchanfragen';

  @override
  String get dictClearHistory => 'Verlauf löschen';

  @override
  String get dictOnlineViEn => 'Online-Übersetzung Vietnamesisch ➔ Englisch';

  @override
  String get dictOnlineEnVi => 'Online-Suche Englisch ➔ Vietnamesisch';

  @override
  String dictOnlineViEnQuery(String query) {
    return 'Online-Übersetzung Vietnamesisch ➔ Englisch für \"$query\"';
  }

  @override
  String dictOnlineEnViQuery(String query) {
    return 'Online-Suche Englisch ➔ Vietnamesisch für \"$query\"';
  }

  @override
  String dictNotFoundInternal(String query) {
    return '\"$query\" wurde im internen Wörterbuch nicht gefunden.';
  }

  @override
  String get dictListenWord => 'Muttersprachliche Aussprache anhören';

  @override
  String get dictCachedBadge => 'SQLite gecacht (Offline)';

  @override
  String get dictSaveToReview => 'Zur Wiederholung speichern';

  @override
  String dictSavedSuccess(String term) {
    return '\"$term\" zu Wortschatz & Wiederholungsliste hinzugefügt!';
  }

  @override
  String get dictEnglishDefinitions => 'Englische Definitionen & Beispiele:';

  @override
  String dictSynonymsList(String synonyms) {
    return 'Synonyme: $synonyms';
  }

  @override
  String get dictNoun => 'Substantiv (n)';

  @override
  String get dictVerb => 'Zeitwort / Verb (v)';

  @override
  String get dictAdj => 'Adjektiv (adj)';

  @override
  String get dictAdv => 'Umstandswort / Adverb (adv)';

  @override
  String get dictPhrase => 'Redewendung / Idiom';

  @override
  String get skillsHubTitle => '4 Fertigkeiten & Wortschatztraining';

  @override
  String get skillsHubAllLevels => 'Alle Niveaustufen anzeigen (A1–C1)';

  @override
  String get skillsListening => 'Hörverstehen';

  @override
  String get skillsReading => 'Leseverstehen';

  @override
  String get skillsWriting => 'Schreiben';

  @override
  String get skillsSpeaking => 'Sprechen';

  @override
  String get skillsListeningDesc =>
      'Standard (1.0x) oder verlangsamtes (0.75x) Audio. Transkripte und Übersetzungen sind bis zur Abgabe gesperrt.';

  @override
  String get skillsReadingDesc =>
      'Abgestufte A1–C1-Texte, Multiple-Choice- & Lückentextfragen, vollständige Erklärungen.';

  @override
  String get skillsWritingDesc =>
      'Satzbau-Übungen und kriterienbasierte Aufsätze mit Musterantworten.';

  @override
  String get skillsSpeakingDesc =>
      'Aussprache, Satzbetonung, Lautverbindungen und Selbsteinschätzung anhand von 4 Kriterien.';

  @override
  String get skillsStartLearning => 'Jetzt üben';

  @override
  String skillsProgressText(int completed, int total) {
    return 'Fortschritt: $completed/$total Lektionen abgeschlossen';
  }

  @override
  String skillsCompletedBadge(int score) {
    return 'Abgeschlossen • $score%';
  }

  @override
  String skillsLessonList(int count) {
    return 'Lektionsliste ($count Lektionen)';
  }

  @override
  String skillsNoLessonLevel(String level) {
    return 'Keine Lektionen auf GER-Niveau $level verfügbar.';
  }

  @override
  String get skillsOpenShadowing => 'Shadowing-Studio öffnen';

  @override
  String get skillsMatchingGameTitle => 'Paare-Zuordnungsspiel';

  @override
  String get skillsFlashcard3dTitle => '3D-Karteikarten';

  @override
  String get skillsQuizReflexTitle => 'Wortschatz-Reflex-Quiz';

  @override
  String get skillsExamHubTitle => 'Prüfungsraum mit Zeitmessung';

  @override
  String get skillsSrsReviewTitle => 'SRS-Wiederholung mit Zeitabständen';

  @override
  String get exerciseListeningTitle => 'Hörverstehen';

  @override
  String get exerciseReadingTitle => 'Leseverstehen';

  @override
  String exerciseQuestionsCount(int count) {
    return 'Verständnisfragen ($count Fragen)';
  }

  @override
  String exerciseScoreResult(int correct, int total, int percent) {
    return 'Ergebnis: $correct/$total richtig ($percent%)';
  }

  @override
  String get exerciseShowTranscript => 'Transkript & Übersetzung anzeigen';

  @override
  String get exerciseHideTranscript => 'Transkript & Übersetzung ausblenden';

  @override
  String get exerciseReadingPassage => 'Lesetext';

  @override
  String get exerciseAudioPlayer => 'Audio-Player';

  @override
  String exerciseKeyWords(int count) {
    return 'Schlüsselwörter der Lektion ($count Wörter)';
  }

  @override
  String get exerciseSubmitGrade => 'Abgeben & Bewerten';

  @override
  String get exerciseRetake => 'Lektion wiederholen';

  @override
  String exerciseSaveWordSuccess(String term) {
    return '\"$term\" zu Wiederholung & Favoriten hinzugefügt!';
  }

  @override
  String get speakingTimerPractice => 'Sprechübung mit Zeitmessung';

  @override
  String speakingRecordPrompt(int seconds) {
    return 'Aufnahme läuft (${seconds}s) - Zum Stoppen tippen';
  }

  @override
  String speakingRubricSelfCheck(int checked, int total) {
    return 'Selbsteinschätzung ($checked/$total Kriterien erfüllt)';
  }

  @override
  String speakingSaveSuccess(int score) {
    return 'Sprech-Selbsteinschätzung ($score%) im Lernverlauf gespeichert!';
  }

  @override
  String get writingTabScramble => '1. Satzstruktur & Wortfolge';

  @override
  String get writingTabRubric => '2. Textverfassung & Bewertungsraster';

  @override
  String get writingTapWordToForm =>
      'Wörter unten antippen, um einen Satz zu bilden...';

  @override
  String get writingCheckSentence => 'Satz überprüfen';

  @override
  String writingWordCountStatus(int count, int min) {
    return 'Wörter: $count / mind. $min Wörter';
  }

  @override
  String writingNeedMoreWords(int count) {
    return 'Noch $count Wörter benötigt';
  }

  @override
  String get writingSaveModelAnswer =>
      'Aufsatz speichern & Musterlösung freischalten';

  @override
  String get writingModelAnswerTitle => 'Musterlösung (Referenz)';

  @override
  String get shadowingHubTitle => 'Reflex-Shadowing-Studio';

  @override
  String get shadowingMethodTitle => '4-Schritte-Intonations-Shadowing-Methode';

  @override
  String get shadowingMethodDesc =>
      '1. Vorbild anhören (1.0x) → 2. Langsam hören & Lautverbindungen analysieren (0.75x) → 3. Synchron nachsprechen → 4. Ehrliche Selbsteinschätzung.';

  @override
  String shadowingLessonsList(int count) {
    return 'Shadowing-Lektionen ($count Lektionen)';
  }

  @override
  String get shadowingPracticeTitle => 'Shadowing-Übung';

  @override
  String get shadowingStep1 => 'Schritt 1: Vorbild anhören (1.0x)';

  @override
  String get shadowingStep2 => 'Schritt 2: Langsam anhören (0.75x)';

  @override
  String get shadowingStep3 => 'Schritt 3: Synchron nachsprechen';

  @override
  String get shadowingStep4 => 'Schritt 4: Selbsteinschätzung (Erforderlich)';

  @override
  String shadowingSpeakingStatus(int seconds) {
    return 'Shadowing läuft (${seconds}s)...';
  }

  @override
  String get shadowingSaveProgress => 'Shadowing-Fortschritt speichern';

  @override
  String shadowingSavedSuccess(int score) {
    return 'Shadowing-Lektionsfortschritt ($score% Kriterien erfüllt) in der Datenbank gespeichert!';
  }

  @override
  String get gamesHubTitle => 'Wortschatz-Minispiele';

  @override
  String get gamesHubSubtitle =>
      'Stärke dein Wortgedächtnis durch schnelles Tippen, Reaktionsarenen und herabfallende Wort-Herausforderungen.';

  @override
  String get gamesSelectGame => 'Wähle ein Spiel zum Starten:';

  @override
  String get gamesSpaceTyperTitle => 'Space Typer';

  @override
  String get gamesSpaceTyperDesc =>
      'Tippe Buchstaben und Wörter, um Asteroiden zu zerstören. Automatisches Raumschiff-Tracking, Laserfeuer und Abwehrradar.';

  @override
  String get gamesArenaTitle => 'Wortschatz-Arena';

  @override
  String get gamesArenaDesc =>
      '7-15s Reaktions-Multiple-Choice, Serien-Combos, Zifferntasten 1-4 am Computer unterstützt.';

  @override
  String get gamesWordRainTitle => 'Wörter-Regen';

  @override
  String get gamesWordRainDesc =>
      'Fange herabfallende englische Regentropfen, die zur vietnamesischen Zielbedeutung passen, bevor sie versinken.';

  @override
  String get gamesPlayNow => 'Jetzt spielen';

  @override
  String get gamesRules => 'Spielregeln & Anleitung';

  @override
  String gamesHighScore(int score) {
    return 'Highscore: $score Pkt.';
  }

  @override
  String gamesRecentHistory(int count) {
    return 'Letzte Spielergebnisse ($count Runden)';
  }

  @override
  String gameScorePoints(int score) {
    return '$score Pkt.';
  }

  @override
  String get gameOver => 'Spiel vorbei!';

  @override
  String get gameCompleted => 'Runde abgeschlossen!';

  @override
  String get gamePlayAgain => 'Noch einmal spielen';

  @override
  String get gameBackToHub => 'Zurück zur Spieleübersicht';

  @override
  String get gameAccuracy => 'Genauigkeit';

  @override
  String get gameTime => 'Zeit';

  @override
  String get gameStreak => 'Max. Serie';

  @override
  String get gameNewRecord => '🎉 NEUER PERSÖNLICHER REKORD!';

  @override
  String get gameDiffEasy => 'Einfach';

  @override
  String get gameDiffMedium => 'Mittel';

  @override
  String get gameDiffHard => 'Schwer';

  @override
  String get examHubTitle => 'Internationale Zertifikatsprüfungen';

  @override
  String get examHubSubtitle =>
      'Prüfungssimulationen & Zeittests (IELTS • TOEIC • GER)';

  @override
  String examListTitle(int count) {
    return 'Verfügbare Prüfungen ($count Tests)';
  }

  @override
  String get examPracticeMode => 'Übungsmodus';

  @override
  String get examPracticeModeDesc =>
      'Ohne Zeitbegrenzung, Hinweise und ausführliche Erklärungen pro Frage sofort einsehbar.';

  @override
  String get examTimedMode => 'Prüfungsmodus (mit Zeitmessung)';

  @override
  String get examTimedModeDesc =>
      'Countdown-Timer, automatische Abgabe nach Ablauf der Zeit, ausführlicher Ergebnisbericht.';

  @override
  String examQuestionCounter(int current, int total) {
    return 'Frage $current/$total';
  }

  @override
  String get examSubmitConfirm => 'Prüfung abgeben?';

  @override
  String get examSubmitConfirmDesc =>
      'Sind Sie sicher, dass Sie die Prüfung abschließen und abgeben möchten?';

  @override
  String get examResultTitle => 'Prüfungsergebnisse & Detaillierte Analyse';

  @override
  String examScoreBand(String band) {
    return 'Geschätzte Band-Bewertung: $band';
  }

  @override
  String examCorrectRatio(int correct, int total, int percent) {
    return 'Richtig: $correct/$total Fragen ($percent%)';
  }

  @override
  String get aiChatTitle => 'English Buddy KI-Assistent';

  @override
  String get aiChatSubtitle =>
      'Grammatikfragen • Satzübersetzung • Text-Feedback';

  @override
  String get aiChatGreeting =>
      'Hallo! Wie kann ich dir heute beim Englischlernen helfen?';

  @override
  String get aiChatGreetingDesc =>
      'Stelle mir beliebige Grammatikfragen, frage nach Satzübersetzungen oder bitte um Text-Feedback!';

  @override
  String get aiChatSuggestions => 'VORSCHLÄGE FÜR ÜBUNGSFRAGEN';

  @override
  String get aiChatInputPlaceholder =>
      'Frage, zu übersetzenden Satz oder Text eingeben...';

  @override
  String get aiChatClearTitle => 'Unterhaltung löschen?';

  @override
  String get aiChatClearDesc =>
      'Alle KI-Chatnachrichten werden von diesem Gerät gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get aiChatClearSuccess =>
      'Gesamter Chat-Verlauf erfolgreich gelöscht.';

  @override
  String get aiChatThinking => 'KI-Assistent denkt nach...';

  @override
  String get authSignInTitle => 'Konto-Anmeldung';

  @override
  String get authSignUpTitle => 'Neues Konto erstellen';

  @override
  String get authAccountOrEmail => 'Benutzername oder E-Mail';

  @override
  String get authEmail => 'E-Mail-Adresse';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authConfirmPassword => 'Passwort bestätigen';

  @override
  String get authDisplayName => 'Anzeigename';

  @override
  String get authGoogleSignIn => 'Mit Google fortfahren';

  @override
  String get authProcessing => 'Wird verarbeitet...';

  @override
  String get authPasswordMismatch => 'Passwörter stimmen nicht überein!';

  @override
  String get authMinPassword => 'Mindestens 8 Zeichen';

  @override
  String get authInvalidEmail => 'Gültige E-Mail-Adresse eingeben';

  @override
  String get authOr => 'ODER';

  @override
  String get statsResetButton => 'Ursprüngliche Daten wiederherstellen';

  @override
  String statsQuizQuestionsCount(Object correct, Object total) {
    return '$correct/$total Fragen';
  }

  @override
  String statsTopicWordsProgress(
    Object mastered,
    Object percent,
    Object total,
  ) {
    return '$mastered/$total Wörter ($percent%)';
  }

  @override
  String get dictTitleFull =>
      'Zweisprachiges Wörterbuch Vietnamesisch – Englisch & Englisch – Vietnamesisch';

  @override
  String dictSearchDirection(Object flag, Object label) {
    return 'Suchrichtung: $flag $label';
  }

  @override
  String get dictViDetected =>
      'Erkannt: Vietnamesisch ➜ Entsprechende englische Wörter werden angezeigt';

  @override
  String get dictEnDetected =>
      'Erkannt: Englisch ➜ Vietnamesische Bedeutung & Definitionen werden angezeigt';

  @override
  String get dictAllLevels => 'Alle Niveaustufen';

  @override
  String get dictAllTopics => 'Alle Themen';

  @override
  String get dictAllPos => 'Alle Wortarten';

  @override
  String get dictIntroDesc =>
      'Intelligente Zwei-Wege-Suche: Geben Sie Vietnamesisch ein, um englische Entsprechungen zu finden, oder Englisch für vietnamesische Bedeutungen. Über 3.000 GER A1–C1 Wörter offline verfügbar mit Online-Erweiterung (Google Translate & Wiktionary gecacht in SQLite).';

  @override
  String get dictViEnOnlinePrompt =>
      'Sie können die Übersetzung online von Vietnamesisch ➔ Englisch erweitern (ruft automatisch englische Entsprechungen, Definitionen und Aussprache ab und speichert sie in SQLite).';

  @override
  String get dictEnViOnlinePrompt =>
      'Sie können die Suche online von Englisch ➔ Vietnamesisch erweitern (vietnamesische Bedeutung, englische Definitionen, Aussprache und Speicherung in SQLite).';

  @override
  String get dictRetry => 'Wiederholen';

  @override
  String get dictRetryConnection => 'Verbindung wiederholen';

  @override
  String get dictTtsTooltip => 'Standard-Aussprache (TTS)';

  @override
  String get dictInReview => 'Wird wiederholt';

  @override
  String get dictAddToReview => 'Zur Wiederholung hinzufügen';

  @override
  String dictMovedToNew(Object term) {
    return '\"$term\" zu neuen Wörtern verschoben';
  }

  @override
  String dictAddedToReview(Object term) {
    return '\"$term\" zur Wiederholungsliste hinzugefügt!';
  }

  @override
  String get dictFavoriteAdd => 'Dieses Wort favorisieren';

  @override
  String get dictFavoriteRemove => 'Aus Favoriten entfernen';

  @override
  String get dictLiveApi => 'Online (Live-API)';

  @override
  String get dictSaved => 'Gespeichert';

  @override
  String dictViKeyword(Object query) {
    return 'Vietnamesisches Stichwort: \"$query\"';
  }

  @override
  String get dictEquivalentEnWords => 'Entsprechende englische Wörter:';

  @override
  String dictListenTooltip(Object word) {
    return 'Tippen zum Anhören: $word';
  }

  @override
  String dictViRefMeaning(Object meaning) {
    return 'Vergleichsbedeutung Vietnamesisch: $meaning';
  }

  @override
  String get dictViTranslation => 'Vietnamesische Übersetzung:';

  @override
  String get dictOtherMeanings => 'Weitere Übersetzungen:';

  @override
  String dictSourceInfo(Object license, Object source, Object url) {
    return 'Quelle: $source • Lizenz: $license ($url)';
  }

  @override
  String dictExamplePrefix(Object example) {
    return 'Bsp.: \"$example\"';
  }

  @override
  String get avatarChangePhoto => 'Profilbild ändern';

  @override
  String get avatarSelectFromDevice => 'Vom Gerät / Galerie auswählen';

  @override
  String get avatarSelectFromUrl => 'Bild-URL direkt eingeben';

  @override
  String get avatarResetDefault => 'Auf Standardbild zurücksetzen';

  @override
  String get avatarEnterUrlTitle => 'Profilbild-URL eingeben';

  @override
  String get avatarUrlPlaceholder => 'https://example.com/avatar.jpg';

  @override
  String get avatarInvalidUrl => 'Ungültige URL oder kein Bild';

  @override
  String get skillsSelectSkill => 'Wählen Sie eine Fertigkeit zum Üben:';

  @override
  String get skillsAllLevels => 'Alle Niveaustufen';

  @override
  String skillsQuestionsCount(Object count) {
    return '$count Fragen';
  }

  @override
  String skillsExerciseCount(Object count) {
    return '$count Übungen';
  }

  @override
  String get skillsStartPractice => 'Übung starten';

  @override
  String get skillsTranscriptLocked => 'Transkript gesperrt';

  @override
  String get skillsTranscriptUnlocked => 'Hör-Transkript';

  @override
  String get skillsSubmitExercise => 'Übung abgeben';

  @override
  String get skillsCompleted => 'Abgeschlossen';

  @override
  String skillsScore(Object score, Object total) {
    return 'Ergebnis: $score/$total';
  }

  @override
  String get skillsTryAgain => 'Erneut versuchen';

  @override
  String get skillsNextExercise => 'Nächste Übung';

  @override
  String get skillsListenNormal => 'Normale Geschwindigkeit 1.0x';

  @override
  String get skillsListenSlow => 'Langsame Geschwindigkeit 0.75x';

  @override
  String get skillsExplanation => 'Detaillierte Erklärung';

  @override
  String get skillsMatchingPairs => 'Wörter mit ihren Bedeutungen verbinden';

  @override
  String get skillsSpeakingPrompt => 'Lesen Sie den folgenden Text laut vor';

  @override
  String get skillsWritingPrompt => 'Schreiben Sie gemäß der Aufgabenstellung';

  @override
  String gameDifficulty(Object diff) {
    return 'Schwierigkeitsgrad: $diff';
  }

  @override
  String gameScore(Object score) {
    return 'Punktzahl: $score';
  }

  @override
  String gameHighScore(Object score) {
    return 'Highscore: $score';
  }

  @override
  String get gameExit => 'Spiel beenden';

  @override
  String gameCombo(Object multiplier) {
    return 'Combo x$multiplier';
  }

  @override
  String gameWpm(Object wpm) {
    return 'Geschwindigkeit: $wpm WPM';
  }

  @override
  String get gameStart => 'Spiel starten';

  @override
  String get gamePause => 'Pausieren';

  @override
  String get gameResume => 'Fortsetzen';

  @override
  String get gameRestart => 'Neu starten';

  @override
  String gameLives(Object lives) {
    return 'Leben: $lives';
  }

  @override
  String gameLevel(Object level) {
    return 'Level: $level';
  }

  @override
  String get examMode => 'Prüfungsmodus';

  @override
  String examTimeRemaining(Object time) {
    return 'Verbleibende Zeit: $time';
  }

  @override
  String get examSubmit => 'Prüfung abgeben';

  @override
  String get examPassed => 'Bestanden';

  @override
  String get examFailed => 'Verbesserungsbedarf';

  @override
  String get examScoreBreakdown => 'Punkteübersicht';

  @override
  String get examReviewAnswers => 'Antworten & Erklärungen überprüfen';

  @override
  String get examRetake => 'Prüfung wiederholen';

  @override
  String get examBackToHub => 'Zurück zur Prüfungsübersicht';

  @override
  String get shadowingListen1 => 'Schritt 1: Vorbild anhören (1.0x)';

  @override
  String get shadowingListen2 => 'Schritt 2: Langsam anhören (0.75x)';

  @override
  String get shadowingRecord => 'Schritt 3: Audio nachsprechen';

  @override
  String get shadowingStop => 'Aufnahme stoppen';

  @override
  String get shadowingSelfEval => 'Schritt 4: Selbsteinschätzung';

  @override
  String get shadowingNext => 'Nächster Satz';

  @override
  String get shadowingComplete => 'Shadowing-Übung abgeschlossen!';

  @override
  String get authLogin => 'Anmelden';

  @override
  String get authRegister => 'Registrieren';

  @override
  String get authNoAccount => 'Noch kein Konto? Jetzt registrieren';

  @override
  String get authAlreadyHaveAccount => 'Bereits ein Konto? Jetzt anmelden';

  @override
  String get authLogout => 'Abmelden';

  @override
  String get authLogoutConfirm =>
      'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get profileTitle => 'Benutzerprofil';

  @override
  String get profileEdit => 'Profil bearbeiten';

  @override
  String get profileSave => 'Profiländerungen speichern';

  @override
  String get profileDisplayName => 'Anzeigename';

  @override
  String get profileEmail => 'E-Mail';

  @override
  String get profileRole => 'Rolle';

  @override
  String get profileJoined => 'Beitrittsdatum';

  @override
  String get adminTitle => 'Systemverwaltung (Admin)';

  @override
  String get adminUsers => 'Benutzer & Niveaustufen';

  @override
  String get adminVocab => 'Wortschatz & Themen';

  @override
  String get adminExercises => 'Lesen & Hören';

  @override
  String get adminExams => 'Übungsprüfungen';

  @override
  String get adminSystem => 'Systemüberwachung';

  @override
  String get adminForbidden => 'Nur für Administratoren (403 Verboten)';

  @override
  String get adminRefresh => 'Admin-Daten aktualisieren';

  @override
  String get aiChatAsk => 'KI fragen';

  @override
  String get settingsSelectLanguage => 'App-Sprache auswählen';

  @override
  String get settingsSearchLanguage => 'Sprache suchen...';

  @override
  String get settingsAllLanguages => 'Alle 13 Sprachen anzeigen';

  @override
  String get settingsAllLanguagesSubtitle =>
      'Chinesisch, Japanisch, Koreanisch, Französisch, Deutsch, Spanisch, Russisch...';

  @override
  String get settingsDefaultBadge => 'Standard';

  @override
  String get profileUsernameLabel => 'Anmelde-Benutzername (Username)';

  @override
  String get profileUsernameHint =>
      'Benutzername eingeben (3–30 Zeichen: a-z, 0-9, ., _, -)';

  @override
  String get profileUsernameHelperPassword =>
      'Sie können sich mit diesem Benutzernamen oder Ihrer E-Mail-Adresse und Ihrem Passwort anmelden.';

  @override
  String get profileUsernameHelperGoogle =>
      'Google-Konten melden sich weiterhin über Google an; dieser Benutzername ist Ihre eindeutige Kennung.';

  @override
  String get profileEmailReadOnlyHelper =>
      'Anmelde-E-Mail (schreibgeschützt, bleibt bei Namensänderung unverändert)';

  @override
  String get weeklyProgressTitle => 'Wöchentlicher Fortschritt';

  @override
  String weeklyProgressActiveDays(int count) {
    return '$count/7 aktive Tage';
  }

  @override
  String weeklyProgressWordsStudied(int count) {
    return '$count Wörter gelernt/wiederholt';
  }

  @override
  String weeklyProgressActivitiesDone(int count) {
    return '$count Aktivitäten abgeschlossen';
  }

  @override
  String weeklyProgressTodayGoal(int current, int goal) {
    return 'Heutiges Wortziel: $current/$goal Wörter';
  }

  @override
  String get weeklyProgressTodayBadge => 'Heute';

  @override
  String get weeklyProgressEmptyTitle =>
      'Noch keine Lernaktivität in dieser Woche';

  @override
  String get weeklyProgressEmptyDesc =>
      'Wiederholen Sie Vokabeln oder schließen Sie ein Quiz ab, um Ihr Wochendiagramm sofort zu aktualisieren!';

  @override
  String get weeklyProgressStartCta => 'Jetzt Vokabeln wiederholen';

  @override
  String get weeklyProgressScopeNote =>
      'Erfasst echte zeitgestempelte Lernaktivitäten des aktuellen Kontos (Montag – Sonntag in lokaler Zeit).';

  @override
  String get weeklyProgressUnitWords => 'Wörter';

  @override
  String get weeklyProgressUnitActivities => 'Akt.';

  @override
  String get aiChatErrorGeneral => 'KI-Antwort konnte nicht empfangen werden';

  @override
  String get authRegisterSuccessPleaseLogin =>
      'Registrierung erfolgreich! Bitte melden Sie sich an, um fortzufahren.';
}
