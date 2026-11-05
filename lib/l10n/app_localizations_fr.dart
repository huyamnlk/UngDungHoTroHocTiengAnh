// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'English Buddy';

  @override
  String get navHome => 'Accueil';

  @override
  String get navTopics => 'Thèmes';

  @override
  String get navListening => 'Écoute';

  @override
  String get navReading => 'Lecture';

  @override
  String get navWriting => 'Écriture';

  @override
  String get navSpeaking => 'Expression orale';

  @override
  String get navShadowing => 'Shadowing';

  @override
  String get navDictionary => 'Vocabulaire et dictionnaire';

  @override
  String get navExam => 'Examens';

  @override
  String get navGames => 'Jeux';

  @override
  String get navReview => 'Révision';

  @override
  String get navStats => 'Statistiques';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navAdmin => 'Administration';

  @override
  String get navSectionSkills => 'COMPÉTENCES & ÉTUDE';

  @override
  String get navSectionSystem => 'PROGRÈS & SYSTÈME';

  @override
  String get sidebarExpandTooltip =>
      'English Buddy - Développer la barre latérale';

  @override
  String get sidebarCollapseTooltip => 'Réduire la barre latérale';

  @override
  String get mobileMenuTooltip =>
      'Ouvrir le menu des 13 compétences et fonctionnalités';

  @override
  String get aiChatTooltip => 'Assistant IA English Buddy';

  @override
  String get aiChatQuickHelp => 'Q&R de grammaire et traduction';

  @override
  String get aiChatDesc =>
      'Assistant IA English Buddy (Questions-réponses et correction d\'erreurs)';

  @override
  String get accessDeniedAdminOnly =>
      'Accès refusé : la zone d\'administration est réservée aux comptes administrateurs.';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionNext => 'Suivant';

  @override
  String get actionPrevious => 'Précédent';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionSubmit => 'Soumettre';

  @override
  String get actionStart => 'Commencer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionSearch => 'Rechercher';

  @override
  String get actionFilter => 'Filtrer';

  @override
  String get actionReset => 'Réinitialiser';

  @override
  String get actionResetFilter => 'Réinitialiser les filtres';

  @override
  String get actionClear => 'Effacer';

  @override
  String get actionShowAll => 'Afficher tout';

  @override
  String get actionExpand => 'Développer';

  @override
  String get actionCollapse => 'Réduire';

  @override
  String get actionPlay => 'Lire';

  @override
  String get actionPause => 'Pause';

  @override
  String get actionResume => 'Reprendre';

  @override
  String get actionExit => 'Quitter';

  @override
  String get actionUnderstood => 'Compris';

  @override
  String get actionCopy => 'Copier';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusLocked => 'Verrouillé';

  @override
  String get statusCompleted => 'Terminé';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusAll => 'Tous';

  @override
  String get allTopics => 'Tous les thèmes';

  @override
  String get allLevels => 'Tous les niveaux';

  @override
  String get allSkills => 'Toutes les compétences';

  @override
  String get allFormats => 'Tous les formats';

  @override
  String get levelA1 => 'A1 - Débutant';

  @override
  String get levelA2 => 'A2 - Élémentaire';

  @override
  String get levelB1 => 'B1 - Intermédiaire';

  @override
  String get levelB2 => 'B2 - Intermédiaire supérieur';

  @override
  String get levelC1 => 'C1 - Avancé';

  @override
  String get settingsTitle => 'Paramètres et préférences';

  @override
  String get settingsLanguageSection => 'Langue et localisation';

  @override
  String get settingsLanguageSubtitle =>
      'Sélectionnez votre langue d\'application préférée';

  @override
  String get settingsLangVi => 'Tiếng Việt';

  @override
  String get settingsLangViDesc => 'Vietnamien';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsLangEnDesc => 'Anglais';

  @override
  String get settingsAccountSection => 'Profil et compte';

  @override
  String get settingsThemeSection => 'Interface et thème';

  @override
  String get settingsThemeSystem => 'Système par défaut';

  @override
  String get settingsThemeSystemDesc =>
      'S\'adapte automatiquement à l\'apparence de l\'appareil';

  @override
  String get settingsThemeLight => 'Mode clair';

  @override
  String get settingsThemeDark => 'Mode sombre';

  @override
  String get settingsDailyGoalSection => 'Objectif quotidien d\'apprentissage';

  @override
  String get settingsDailyGoalSubtitle =>
      'Choisissez le nombre de mots que vous souhaitez apprendre chaque jour :';

  @override
  String settingsDailyGoalUnit(int count) {
    return '$count mots';
  }

  @override
  String settingsDailyGoalSaved(int count) {
    return 'Objectif quotidien défini à $count mots/jour !';
  }

  @override
  String get settingsSoundSection => 'Son et prononciation';

  @override
  String get settingsSoundEnable => 'Activer l\'audio de prononciation';

  @override
  String get settingsSoundEnableDesc =>
      'Moteur de synthèse vocale (Text-to-Speech) avec accent natif';

  @override
  String get settingsCopyrightSection =>
      'Sources de données et droits d\'auteur';

  @override
  String get settingsCopyrightTitle =>
      'Politique transparente des droits d\'auteur';

  @override
  String get settingsCopyrightDesc1 =>
      '• Le contenu de vocabulaire, les exemples et les exercices sont rédigés à l\'origine selon les niveaux du CECRL (A1–C1) et des référentiels linguistiques ouverts.';

  @override
  String get settingsCopyrightDesc2 =>
      '• Nous ne copions pas en masse les définitions ou contenus sous droits d\'auteur de Cambridge Dictionary, DOL English ou d\'autres sources commerciales.';

  @override
  String get settingsCopyrightDesc3 =>
      '• La recherche en ligne utilise l\'API Free Dictionary (open source, sans clé API requise, sous licence CC BY-SA 3.0).';

  @override
  String get settingsAppSubtitle =>
      'Projet d\'application mobile - Flutter & SQLite';

  @override
  String get guestUser => 'Invité (Non connecté)';

  @override
  String get guestUserDesc =>
      'Non connecté. Connectez-vous ou créez un compte pour gérer votre profil et synchroniser vos progrès.';

  @override
  String authenticatedAs(String email, String provider) {
    return '$email • Vérifié ($provider)';
  }

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get adminArea => 'Espace administration';

  @override
  String get signIn => 'Connexion';

  @override
  String get signUp => 'Créer un compte';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get confirmSignOutTitle => 'Confirmer la déconnexion';

  @override
  String confirmSignOutMessage(String email) {
    return 'Voulez-vous vraiment vous déconnecter de \"$email\" ?\n\nVotre session et vos jetons actuels seront supprimés. Les progrès d\'apprentissage locaux sur cet appareil sont conservés.';
  }

  @override
  String accountMenuHeader(String displayName) {
    return 'Compte ($displayName)';
  }

  @override
  String get homeGreetingGuest => 'Bonjour ! 👋';

  @override
  String homeGreetingUser(String name) {
    return 'Bonjour, $name ! 👋';
  }

  @override
  String get homeSubtitle =>
      'Prêt à enrichir votre vocabulaire et perfectionner votre anglais aujourd\'hui ?';

  @override
  String homeDayStreak(int days) {
    return '$days jours';
  }

  @override
  String get homeStreakLabel => 'Série de jours';

  @override
  String homeMasteredWords(int mastered, int total) {
    return '$mastered/$total maîtrisés';
  }

  @override
  String homeProgressSummary(int mastered, int total, int percent) {
    return 'Vous avez maîtrisé $mastered mots sur $total mots CECRL ($percent% complété).';
  }

  @override
  String homeGoalTitle(int count) {
    return 'Objectif quotidien : $count mots/jour';
  }

  @override
  String homeReviewNow(int count) {
    return 'Réviser maintenant ($count mots)';
  }

  @override
  String homeDueSrsCount(int count) {
    return '$count à réviser';
  }

  @override
  String homeWordsToLearn(int count) {
    return '$count mots à mémoriser';
  }

  @override
  String homeTopicCount(int count) {
    return '$count thèmes';
  }

  @override
  String homeTopicCefrCount(int count) {
    return '$count thèmes CECRL';
  }

  @override
  String get homeShortcutsTitle => 'Raccourcis d\'apprentissage';

  @override
  String get homeViewAll => 'Voir tout';

  @override
  String get homeCardTopicsTitle => 'Thèmes de vocabulaire';

  @override
  String get homeCardTopicsDesc => 'Explorer les thèmes CECRL';

  @override
  String get homeCardReviewTitle => 'Liste de révision';

  @override
  String get homeCardReviewDesc => 'Mots nécessitant actuellement une révision';

  @override
  String get homeCardExamTitle => 'Préparation aux examens IELTS/TOEIC';

  @override
  String get homeCardExamDesc =>
      'Tests chronométrés avec explications détaillées';

  @override
  String get homeCardGamesTitle => 'Jeux de vocabulaire';

  @override
  String get homeCardGamesDesc => 'Paires correspondantes et quiz de rapidité';

  @override
  String get homeCardShadowingTitle => 'Shadowing réflexe';

  @override
  String get homeCardShadowingDesc =>
      'Accentuation des phrases et liaisons sonores';

  @override
  String get homeCardDictionaryTitle => 'Dictionnaire anglais - vietnamien';

  @override
  String get homeCardDictionaryDesc => 'Consultez plus de 3 000 mots';

  @override
  String get homeCardAiTitle => 'IA English Buddy';

  @override
  String get homeCardAiDesc =>
      'Questions de grammaire, recherche et avis sur vos rédactions';

  @override
  String get homeCardStatsTitle => 'Progrès et statistiques';

  @override
  String get homeCardStatsDesc => 'Mots maîtrisés et historique des quiz';

  @override
  String get homeTodayWord => 'Vocabulaire du jour';

  @override
  String get homeChangeWord => 'Changer de mot';

  @override
  String get homeSaveFavorite => 'Ajouter aux favoris';

  @override
  String get homeRemoveFavorite => 'Retirer des favoris';

  @override
  String get homeListenPronunciation => 'Écouter la prononciation';

  @override
  String get homeSavedSuccess => 'Enregistré';

  @override
  String get topicsTitle => 'Thèmes d\'apprentissage';

  @override
  String topicsSubtitle(int count) {
    return 'Explorez $count thèmes de vocabulaire pratiques classés de A1 à C1.';
  }

  @override
  String topicsCountWords(int count) {
    return '$count éléments de vocabulaire';
  }

  @override
  String topicsMasteredCount(int mastered, int total) {
    return 'Maîtrisés : $mastered/$total';
  }

  @override
  String get topicSearchPlaceholder =>
      'Rechercher un mot anglais ou un sens en vietnamien...';

  @override
  String topicLearnFlashcard(int count) {
    return 'Apprendre par cartes ($count)';
  }

  @override
  String get topicFilterAll => 'Tous';

  @override
  String get topicFilterNew => 'Nouveaux';

  @override
  String get topicFilterReview => 'À réviser';

  @override
  String get topicFilterMastered => 'Maîtrisés';

  @override
  String get topicEmptyWord => 'Aucun vocabulaire trouvé';

  @override
  String get topicEmptyWordDesc =>
      'Essayez avec d\'autres mots-clés ou modifiez les filtres.';

  @override
  String get addWordTitle => 'Ajouter un nouveau mot';

  @override
  String addWordTopicTarget(String topicName) {
    return 'Dans le thème : $topicName';
  }

  @override
  String get addWordEnglishLabel => 'Mot en anglais *';

  @override
  String get addWordEnglishHint => 'ex. : Innovation';

  @override
  String get addWordMeaningLabel => 'Signification en vietnamien *';

  @override
  String get addWordMeaningHint => 'ex. : Sự đổi mới, cách tân';

  @override
  String get addWordIpaLabel => 'Phonétique IPA';

  @override
  String get addWordIpaHint => 'ex. : /ˌɪn.əˈveɪ.ʃən/';

  @override
  String get addWordPartOfSpeechLabel => 'Nature grammaticale';

  @override
  String get addWordExampleEnLabel => 'Exemple de phrase (anglais)';

  @override
  String get addWordExampleEnHint =>
      'ex. : Innovation drives technology forward.';

  @override
  String get addWordExampleViLabel => 'Traduction de la phrase d\'exemple';

  @override
  String get addWordExampleViHint =>
      'ex. : Sự đổi mới thúc đẩy công nghệ tiến lên.';

  @override
  String get addWordNotesLabel => 'Notes / Astuces de prononciation';

  @override
  String get addWordNotesHint => 'ex. : Accent sur la 3e syllabe';

  @override
  String get addWordSaveButton => 'Enregistrer le mot';

  @override
  String get addWordRequiredEnglish => 'Veuillez saisir le mot en anglais';

  @override
  String get addWordRequiredMeaning =>
      'Veuillez saisir la signification en vietnamien';

  @override
  String addWordSuccess(String term) {
    return '« $term » ajouté avec succès !';
  }

  @override
  String get flashcardTapToFlip => 'Touchez la carte pour revenir au mot';

  @override
  String get flashcardTapToMeaning =>
      'Touchez la carte pour voir la signification';

  @override
  String get flashcardVietnameseMeaning => 'SIGNIFICATION EN VIETNAMIEN';

  @override
  String get flashcardNeedReview => 'À réviser';

  @override
  String get flashcardMastered => 'Déjà maîtrisé';

  @override
  String get flashcardCompletedTitle => 'Bravo ! Vous avez terminé !';

  @override
  String flashcardCompletedDesc(int count) {
    return 'Vous venez de réviser $count cartes mémoire.';
  }

  @override
  String get flashcardReviewAgain => 'Réviser à nouveau';

  @override
  String get flashcardBack => 'Retour à la page précédente';

  @override
  String get flashcardEmpty => 'Aucun vocabulaire disponible pour la révision.';

  @override
  String get quizSetupTitle => 'Défi Quiz';

  @override
  String get quizSetupHeader => 'Quiz de rapidité et réflexes';

  @override
  String get quizSetupSubtitle =>
      'Renforcez votre vocabulaire grâce à des formats variés : choix du sens, choix du mot et texte à trous en contexte.';

  @override
  String get quizSetupSelectTopic => 'Sélectionner le thème du quiz';

  @override
  String get quizSetupAllTopics => 'Complet (Tous les thèmes)';

  @override
  String get quizSetupAllTopicsDesc =>
      'Tiré au sort dans l\'ensemble de la base de vocabulaire';

  @override
  String get quizSetupQuestionCount => 'Nombre de questions';

  @override
  String get quizSetupCountFast => '5 questions (Rapide)';

  @override
  String get quizSetupCountStandard => '10 questions (Standard)';

  @override
  String get quizSetupStart => 'Commencer le quiz';

  @override
  String get quizPlayTitle => 'Défi Quiz';

  @override
  String quizPlayQuestionCounter(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get quizPlayTypeSelectMeaning =>
      'Choisissez la signification correcte en vietnamien';

  @override
  String get quizPlayTypeSelectWord => 'Choisissez le mot anglais correct';

  @override
  String get quizPlayTypeFillBlank =>
      'Complétez la phrase avec le mot approprié';

  @override
  String get quizPlayCheck => 'Vérifier';

  @override
  String get quizPlayNext => 'Question suivante';

  @override
  String get quizPlayViewResult => 'Voir les résultats';

  @override
  String get quizPlayCorrect => 'Correct !';

  @override
  String get quizPlayIncorrect => 'Incorrect !';

  @override
  String get quizPlayExitTitle => 'Quitter le quiz ?';

  @override
  String get quizPlayExitMessage =>
      'Votre progression actuelle ne sera pas enregistrée si vous quittez maintenant.';

  @override
  String get quizPlayContinue => 'Continuer le quiz';

  @override
  String get quizResultTitle => 'Résultats du quiz';

  @override
  String quizResultScore(int correct, int total) {
    return '$correct / $total réponses correctes';
  }

  @override
  String get quizResultExcellent => 'Remarquable !';

  @override
  String get quizResultGood => 'Bon travail !';

  @override
  String get quizResultNeedsWork => 'Continuez à vous entraîner !';

  @override
  String get quizResultDescExcellent =>
      'Vous maîtrisez parfaitement le vocabulaire de ce quiz. Continuez ainsi !';

  @override
  String get quizResultDescGood =>
      'Bien joué ! Les mots erronés ont été ajoutés à la section « À réviser » pour vous entraîner.';

  @override
  String get quizResultDescNeedsWork =>
      'Ne vous découragez pas ! Révisez avec les cartes mémoire et réessayez.';

  @override
  String get quizResultDetails => 'Détail des réponses';

  @override
  String get quizResultRetake => 'Refaire le quiz';

  @override
  String get quizResultHome => 'Retour à l\'accueil';

  @override
  String quizResultUserSelected(String answer) {
    return 'Votre choix : $answer';
  }

  @override
  String quizResultCorrectIs(String answer) {
    return 'Bonne réponse : $answer';
  }

  @override
  String get reviewTitle => 'Révision et favoris';

  @override
  String reviewTabNeedReview(int count) {
    return 'À réviser ($count)';
  }

  @override
  String reviewTabFavorites(int count) {
    return 'Favoris ($count)';
  }

  @override
  String get reviewEmptyNeedReview => 'Aucun mot à réviser actuellement';

  @override
  String get reviewEmptyNeedReviewDesc =>
      'Lorsque vous marquez un mot comme « À réviser » ou répondez faux aux quiz, il apparaîtra ici selon la répétition espacée.';

  @override
  String get reviewEmptyFavorites => 'Aucun mot favori pour l\'instant';

  @override
  String get reviewEmptyFavoritesDesc =>
      'Touchez l\'icône de cœur sur un mot pour le mettre en favori et le retrouver ici.';

  @override
  String get reviewLearnFlashcardsNeed => 'Cartes mémoire (À réviser)';

  @override
  String get reviewLearnFlashcardsFav => 'Cartes mémoire (Favoris)';

  @override
  String reviewTotalWords(int count) {
    return 'Total : $count mots';
  }

  @override
  String get reviewViewStats => 'Voir les statistiques de progression';

  @override
  String get wordDetailTitle => 'Détails du mot';

  @override
  String get wordDetailVietnameseDef => 'DÉFINITION EN VIETNAMIEN';

  @override
  String get wordDetailSrsTitle => 'Système de répétition espacée (SRS)';

  @override
  String wordDetailInterval(int days) {
    return 'Intervalle : $days jours';
  }

  @override
  String wordDetailReviewCount(int count) {
    return 'Nombre de révisions : $count';
  }

  @override
  String get wordDetailRealWorldExample => 'Exemple en contexte réel';

  @override
  String wordDetailSynonyms(String synonyms) {
    return 'Synonymes : $synonyms';
  }

  @override
  String wordDetailAntonyms(String antonyms) {
    return 'Antonymes : $antonyms';
  }

  @override
  String get wordDetailTips => 'Astuces de mémorisation et de prononciation';

  @override
  String get wordDetailAddedFav => 'Ajouté aux favoris';

  @override
  String get wordDetailRemovedFav => 'Retiré des favoris';

  @override
  String get statsTitle => 'Statistiques et progression';

  @override
  String get statsOverallProgress => 'Progression globale d\'apprentissage';

  @override
  String statsMasteredRatio(int mastered, int total) {
    return '$mastered/$total mots maîtrisés';
  }

  @override
  String get statsTotalWords => 'Total du vocabulaire';

  @override
  String get statsMasteredWords => 'Maîtrisés';

  @override
  String get statsNeedReviewWords => 'À réviser';

  @override
  String get statsFavoriteWords => 'Favoris';

  @override
  String get statsTopicProgress => 'Progression par thème';

  @override
  String get statsQuizHistory => 'Historique des quiz';

  @override
  String statsAverageScore(String score) {
    return 'Moy. : $score%';
  }

  @override
  String get statsEmptyQuiz =>
      'Aucun historique de quiz. Participez à un quiz pour tester vos réflexes !';

  @override
  String get statsResetTitle => 'Réinitialiser les données ?';

  @override
  String get statsResetMessage =>
      'Tous les états d\'apprentissage, l\'historique des quiz et le vocabulaire personnalisé seront réinitialisés aux valeurs par défaut.';

  @override
  String get statsResetConfirm => 'Confirmer la réinitialisation';

  @override
  String get statsResetSuccess =>
      'Données initiales de l\'application restaurées avec succès !';

  @override
  String get dictTitle => 'Dictionnaire bilingue';

  @override
  String get dictSearchPlaceholder =>
      'Recherche bilingue : tapez en vietnamien (căn hộ) ou en anglais (apartment)...';

  @override
  String get dictRecentSearches => 'Recherches récentes';

  @override
  String get dictClearHistory => 'Effacer l\'historique';

  @override
  String get dictOnlineViEn => 'Traduction en ligne Vietnamien ➔ Anglais';

  @override
  String get dictOnlineEnVi => 'Recherche en ligne Anglais ➔ Vietnamien';

  @override
  String dictOnlineViEnQuery(String query) {
    return 'Traduction en ligne Vietnamien ➔ Anglais pour « $query »';
  }

  @override
  String dictOnlineEnViQuery(String query) {
    return 'Recherche en ligne Anglais ➔ Vietnamien pour « $query »';
  }

  @override
  String dictNotFoundInternal(String query) {
    return 'Impossible de trouver « $query » dans le dictionnaire interne.';
  }

  @override
  String get dictListenWord => 'Écouter la prononciation native';

  @override
  String get dictCachedBadge => 'Mis en cache SQLite (Hors ligne)';

  @override
  String get dictSaveToReview => 'Enregistrer pour révision';

  @override
  String dictSavedSuccess(String term) {
    return '« $term » ajouté au vocabulaire et à la liste de révision !';
  }

  @override
  String get dictEnglishDefinitions => 'Définitions et exemples en anglais :';

  @override
  String dictSynonymsList(String synonyms) {
    return 'Synonymes : $synonyms';
  }

  @override
  String get dictNoun => 'Nom (n)';

  @override
  String get dictVerb => 'Verbe (v)';

  @override
  String get dictAdj => 'Adjectif (adj)';

  @override
  String get dictAdv => 'Adverbe (adv)';

  @override
  String get dictPhrase => 'Locution / Expression';

  @override
  String get skillsHubTitle => 'Pratique des 4 compétences & Vocabulaire';

  @override
  String get skillsHubAllLevels => 'Afficher tous les niveaux (A1–C1)';

  @override
  String get skillsListening => 'Écoute';

  @override
  String get skillsReading => 'Lecture';

  @override
  String get skillsWriting => 'Écriture';

  @override
  String get skillsSpeaking => 'Expression orale';

  @override
  String get skillsListeningDesc =>
      'Audio à vitesse normale (1.0x) ou lente (0.75x). Transcriptions et traductions masquées jusqu\'à la soumission.';

  @override
  String get skillsReadingDesc =>
      'Textes gradués A1–C1, questions à choix multiples et à trous avec explications complètes.';

  @override
  String get skillsWritingDesc =>
      'Remise en ordre de phrases et rédaction guidée par grille d\'évaluation avec modèles.';

  @override
  String get skillsSpeakingDesc =>
      'Prononciation, accentuation des phrases, liaisons et auto-évaluation selon 4 critères.';

  @override
  String get skillsStartLearning => 'S\'entraîner maintenant';

  @override
  String skillsProgressText(int completed, int total) {
    return 'Progression : $completed/$total leçons terminées';
  }

  @override
  String skillsCompletedBadge(int score) {
    return 'Terminé • $score%';
  }

  @override
  String skillsLessonList(int count) {
    return 'Liste des leçons ($count leçons)';
  }

  @override
  String skillsNoLessonLevel(String level) {
    return 'Aucune leçon disponible au niveau CECRL $level.';
  }

  @override
  String get skillsOpenShadowing => 'Ouvrir l\'atelier de Shadowing';

  @override
  String get skillsMatchingGameTitle => 'Jeu des paires';

  @override
  String get skillsFlashcard3dTitle => 'Cartes mémoire 3D';

  @override
  String get skillsQuizReflexTitle => 'Quiz de réflexes de vocabulaire';

  @override
  String get skillsExamHubTitle => 'Salle d\'examen chronométrée';

  @override
  String get skillsSrsReviewTitle => 'Répétition espacée SRS';

  @override
  String get exerciseListeningTitle => 'Compréhension orale';

  @override
  String get exerciseReadingTitle => 'Compréhension écrite';

  @override
  String exerciseQuestionsCount(int count) {
    return 'Questions de compréhension ($count questions)';
  }

  @override
  String exerciseScoreResult(int correct, int total, int percent) {
    return 'Score : $correct/$total correctes ($percent%)';
  }

  @override
  String get exerciseShowTranscript =>
      'Afficher la transcription et la traduction';

  @override
  String get exerciseHideTranscript =>
      'Masquer la transcription et la traduction';

  @override
  String get exerciseReadingPassage => 'Texte de lecture';

  @override
  String get exerciseAudioPlayer => 'Lecteur audio';

  @override
  String exerciseKeyWords(int count) {
    return 'Vocabulaire clé ($count mots)';
  }

  @override
  String get exerciseSubmitGrade => 'Soumettre et évaluer';

  @override
  String get exerciseRetake => 'Recommencer la leçon';

  @override
  String exerciseSaveWordSuccess(String term) {
    return '« $term » enregistré dans Révision et Favoris !';
  }

  @override
  String get speakingTimerPractice => 'Pratique orale chronométrée';

  @override
  String speakingRecordPrompt(int seconds) {
    return 'Enregistrement en cours (${seconds}s) - Touchez pour arrêter';
  }

  @override
  String speakingRubricSelfCheck(int checked, int total) {
    return 'Auto-évaluation ($checked/$total critères remplis)';
  }

  @override
  String speakingSaveSuccess(int score) {
    return 'Auto-évaluation d\'expression orale ($score%) enregistrée !';
  }

  @override
  String get writingTabScramble => '1. Structure & remise en ordre de phrases';

  @override
  String get writingTabRubric => '2. Rédaction de paragraphe & grille';

  @override
  String get writingTapWordToForm =>
      'Touchez les mots ci-dessous pour former une phrase...';

  @override
  String get writingCheckSentence => 'Vérifier la phrase';

  @override
  String writingWordCountStatus(int count, int min) {
    return 'Mots : $count / min $min mots';
  }

  @override
  String writingNeedMoreWords(int count) {
    return 'Encore $count mots nécessaires';
  }

  @override
  String get writingSaveModelAnswer =>
      'Enregistrer le texte et débloquer le modèle';

  @override
  String get writingModelAnswerTitle => 'Texte modèle (Référence)';

  @override
  String get shadowingHubTitle => 'Atelier de Shadowing réflexe';

  @override
  String get shadowingMethodTitle =>
      'Méthode de Shadowing d\'intonation en 4 étapes';

  @override
  String get shadowingMethodDesc =>
      '1. Écouter le modèle (1.0x) → 2. Écoute lente et analyse des liaisons (0.75x) → 3. Répétition synchronisée → 4. Auto-évaluation honnête.';

  @override
  String shadowingLessonsList(int count) {
    return 'Leçons de Shadowing ($count leçons)';
  }

  @override
  String get shadowingPracticeTitle => 'Pratique du Shadowing';

  @override
  String get shadowingStep1 => 'Étape 1 : Écouter le modèle (1.0x)';

  @override
  String get shadowingStep2 => 'Étape 2 : Écoute lente (0.75x)';

  @override
  String get shadowingStep3 => 'Étape 3 : Répétition synchronisée';

  @override
  String get shadowingStep4 => 'Étape 4 : Auto-évaluation (Obligatoire)';

  @override
  String shadowingSpeakingStatus(int seconds) {
    return 'Shadowing en cours (${seconds}s)...';
  }

  @override
  String get shadowingSaveProgress => 'Enregistrer la progression du Shadowing';

  @override
  String shadowingSavedSuccess(int score) {
    return 'Progression de la leçon de Shadowing ($score% des critères) enregistrée !';
  }

  @override
  String get gamesHubTitle => 'Centre de mini-jeux de vocabulaire';

  @override
  String get gamesHubSubtitle =>
      'Mémorisez votre vocabulaire grâce à la frappe rapide, aux arènes de réflexes et aux mots qui tombent.';

  @override
  String get gamesSelectGame => 'Sélectionnez un jeu pour commencer :';

  @override
  String get gamesSpaceTyperTitle => 'Vaisseau Spatial (Space Typer)';

  @override
  String get gamesSpaceTyperDesc =>
      'Tapez les lettres et les mots pour détruire les astéroïdes. Alignement automatique, tirs laser et radar défensif.';

  @override
  String get gamesArenaTitle => 'Arène de vocabulaire';

  @override
  String get gamesArenaDesc =>
      'Choix multiples en réflexe de 7 à 15s, combos de série, touches 1-4 prises en charge sur ordinateur.';

  @override
  String get gamesWordRainTitle => 'Pluie de vocabulaire';

  @override
  String get gamesWordRainDesc =>
      'Attrapez les gouttes de mots anglais qui correspondent au sens cible avant qu\'elles ne tombent.';

  @override
  String get gamesPlayNow => 'Jouer maintenant';

  @override
  String get gamesRules => 'Règles et instructions';

  @override
  String gamesHighScore(int score) {
    return 'Meilleur score : $score pts';
  }

  @override
  String gamesRecentHistory(int count) {
    return 'Parties récentes ($count parties)';
  }

  @override
  String gameScorePoints(int score) {
    return '$score pts';
  }

  @override
  String get gameOver => 'Partie terminée !';

  @override
  String get gameCompleted => 'Manche terminée !';

  @override
  String get gamePlayAgain => 'Rejouer';

  @override
  String get gameBackToHub => 'Retour aux jeux';

  @override
  String get gameAccuracy => 'Précision';

  @override
  String get gameTime => 'Temps';

  @override
  String get gameStreak => 'Série maximale';

  @override
  String get gameNewRecord => '🎉 NOUVEAU RECORD PERSONNEL !';

  @override
  String get gameDiffEasy => 'Facile';

  @override
  String get gameDiffMedium => 'Moyen';

  @override
  String get gameDiffHard => 'Difficile';

  @override
  String get examHubTitle => 'Examens de certification internationale';

  @override
  String get examHubSubtitle =>
      'Entraînement chronométré et examens blancs (IELTS • TOEIC • CECRL)';

  @override
  String examListTitle(int count) {
    return 'Examens disponibles ($count épreuves)';
  }

  @override
  String get examPracticeMode => 'Mode entraînement';

  @override
  String get examPracticeModeDesc =>
      'Sans limite de temps, indices et explications détaillées disponibles immédiatement par question.';

  @override
  String get examTimedMode => 'Mode examen (Chronométré)';

  @override
  String get examTimedModeDesc =>
      'Compte à rebours, soumission automatique à expiration et bilan complet des scores.';

  @override
  String examQuestionCounter(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get examSubmitConfirm => 'Soumettre l\'examen ?';

  @override
  String get examSubmitConfirmDesc =>
      'Voulez-vous vraiment terminer et soumettre votre examen ?';

  @override
  String get examResultTitle => 'Résultats d\'examen et analyse détaillée';

  @override
  String examScoreBand(String band) {
    return 'Score estimé : $band';
  }

  @override
  String examCorrectRatio(int correct, int total, int percent) {
    return 'Correctes : $correct/$total questions ($percent%)';
  }

  @override
  String get aiChatTitle => 'Assistant IA English Buddy';

  @override
  String get aiChatSubtitle =>
      'Q&R de grammaire • Traduction de phrases • Avis sur vos textes';

  @override
  String get aiChatGreeting =>
      'Bonjour ! Comment puis-je vous aider en anglais aujourd\'hui ?';

  @override
  String get aiChatGreetingDesc =>
      'Posez-moi vos questions de grammaire, demandez des traductions ou soumettez vos textes pour correction !';

  @override
  String get aiChatSuggestions => 'SUGGESTIONS DE QUESTIONS';

  @override
  String get aiChatInputPlaceholder =>
      'Tapez votre question, phrase à traduire ou rédaction...';

  @override
  String get aiChatClearTitle => 'Effacer la conversation ?';

  @override
  String get aiChatClearDesc =>
      'Tous les messages de l\'assistant IA seront effacés de cet appareil. Cette action est irréversible.';

  @override
  String get aiChatClearSuccess =>
      'Historique de discussion effacé avec succès.';

  @override
  String get aiChatThinking => 'L\'assistant IA réfléchit...';

  @override
  String get authSignInTitle => 'Connexion au compte';

  @override
  String get authSignUpTitle => 'Créer un nouveau compte';

  @override
  String get authAccountOrEmail => 'Nom d\'utilisateur ou e-mail';

  @override
  String get authEmail => 'Adresse e-mail';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authDisplayName => 'Nom d\'affichage';

  @override
  String get authGoogleSignIn => 'Continuer avec Google';

  @override
  String get authProcessing => 'Traitement en cours...';

  @override
  String get authPasswordMismatch => 'Les mots de passe ne correspondent pas !';

  @override
  String get authMinPassword => 'Au moins 8 caractères';

  @override
  String get authInvalidEmail => 'Entrez une adresse e-mail valide';

  @override
  String get authOr => 'OU';

  @override
  String get statsResetButton => 'Restaurer les données initiales';

  @override
  String statsQuizQuestionsCount(Object correct, Object total) {
    return '$correct/$total réponses correctes';
  }

  @override
  String statsTopicWordsProgress(
    Object mastered,
    Object percent,
    Object total,
  ) {
    return '$mastered/$total mots ($percent%)';
  }

  @override
  String get dictTitleFull =>
      'Dictionnaire bilingue vietnamien – anglais & anglais – vietnamien';

  @override
  String dictSearchDirection(Object flag, Object label) {
    return 'Sens de recherche : $flag $label';
  }

  @override
  String get dictViDetected =>
      'Détecté : vietnamien ➜ Affichage des équivalents en anglais';

  @override
  String get dictEnDetected =>
      'Détecté : anglais ➜ Affichage du sens en vietnamien et définitions';

  @override
  String get dictAllLevels => 'Tous les niveaux';

  @override
  String get dictAllTopics => 'Tous les thèmes';

  @override
  String get dictAllPos => 'Toutes les natures grammaticales';

  @override
  String get dictIntroDesc =>
      'Recherche bidirectionnelle intelligente : tapez en vietnamien pour trouver les termes anglais correspondants, ou tapez en anglais pour le sens en vietnamien. Plus de 3 000 mots CECRL A1–C1 hors ligne avec extension en ligne (Google Translate et Wiktionary en cache SQLite).';

  @override
  String get dictViEnOnlinePrompt =>
      'Vous pouvez élargir la traduction en ligne de vietnamien ➔ anglais (récupère automatiquement les mots équivalents, les définitions, la prononciation et les met en cache SQLite).';

  @override
  String get dictEnViOnlinePrompt =>
      'Vous pouvez élargir la recherche en ligne d\'anglais ➔ vietnamien (sens en vietnamien, définitions en anglais, prononciation et mise en cache SQLite).';

  @override
  String get dictRetry => 'Réessayer';

  @override
  String get dictRetryConnection => 'Réessayer la connexion';

  @override
  String get dictTtsTooltip => 'Prononciation standard (TTS)';

  @override
  String get dictInReview => 'En révision';

  @override
  String get dictAddToReview => 'Ajouter à la révision';

  @override
  String dictMovedToNew(Object term) {
    return '« $term » marqué comme nouveau mot';
  }

  @override
  String dictAddedToReview(Object term) {
    return '« $term » ajouté à la liste de révision !';
  }

  @override
  String get dictFavoriteAdd => 'Ajouter ce mot aux favoris';

  @override
  String get dictFavoriteRemove => 'Retirer des favoris';

  @override
  String get dictLiveApi => 'En ligne (API Live)';

  @override
  String get dictSaved => 'Enregistré';

  @override
  String dictViKeyword(Object query) {
    return 'Mot-clé en vietnamien : « $query »';
  }

  @override
  String get dictEquivalentEnWords => 'Mots équivalents en anglais :';

  @override
  String dictListenTooltip(Object word) {
    return 'Touchez pour écouter : $word';
  }

  @override
  String dictViRefMeaning(Object meaning) {
    return 'Sens de recoupement en vietnamien : $meaning';
  }

  @override
  String get dictViTranslation => 'Traduction en vietnamien :';

  @override
  String get dictOtherMeanings => 'Autres traductions :';

  @override
  String dictSourceInfo(Object license, Object source, Object url) {
    return 'Source : $source • Licence : $license ($url)';
  }

  @override
  String dictExamplePrefix(Object example) {
    return 'Ex. : « $example »';
  }

  @override
  String get avatarChangePhoto => 'Changer l\'avatar';

  @override
  String get avatarSelectFromDevice => 'Choisir depuis l\'appareil / Galerie';

  @override
  String get avatarSelectFromUrl => 'Entrer directement l\'URL de l\'image';

  @override
  String get avatarResetDefault => 'Rétablir l\'avatar par défaut';

  @override
  String get avatarEnterUrlTitle => 'Entrer l\'URL de l\'avatar';

  @override
  String get avatarUrlPlaceholder => 'https://example.com/avatar.jpg';

  @override
  String get avatarInvalidUrl => 'URL invalide ou pas une image';

  @override
  String get skillsSelectSkill => 'Sélectionnez une compétence à pratiquer :';

  @override
  String get skillsAllLevels => 'Tous les niveaux';

  @override
  String skillsQuestionsCount(Object count) {
    return '$count questions à choix';
  }

  @override
  String skillsExerciseCount(Object count) {
    return '$count exercices';
  }

  @override
  String get skillsStartPractice => 'Commencer la pratique';

  @override
  String get skillsTranscriptLocked => 'Transcription verrouillée';

  @override
  String get skillsTranscriptUnlocked => 'Transcription d\'écoute';

  @override
  String get skillsSubmitExercise => 'Soumettre l\'exercice';

  @override
  String get skillsCompleted => 'Terminé';

  @override
  String skillsScore(Object score, Object total) {
    return 'Score : $score/$total';
  }

  @override
  String get skillsTryAgain => 'Réessayer';

  @override
  String get skillsNextExercise => 'Exercice suivant';

  @override
  String get skillsListenNormal => 'Vitesse normale 1.0x';

  @override
  String get skillsListenSlow => 'Vitesse lente 0.75x';

  @override
  String get skillsExplanation => 'Explication détaillée';

  @override
  String get skillsMatchingPairs => 'Associez les mots à leur signification';

  @override
  String get skillsSpeakingPrompt => 'Lisez à voix haute le passage suivant';

  @override
  String get skillsWritingPrompt => 'Rédigez selon la consigne';

  @override
  String gameDifficulty(Object diff) {
    return 'Difficulté : $diff';
  }

  @override
  String gameScore(Object score) {
    return 'Score : $score';
  }

  @override
  String gameHighScore(Object score) {
    return 'Meilleur score : $score';
  }

  @override
  String get gameExit => 'Quitter le jeu';

  @override
  String gameCombo(Object multiplier) {
    return 'Combo x$multiplier';
  }

  @override
  String gameWpm(Object wpm) {
    return 'Vitesse : $wpm MPM';
  }

  @override
  String get gameStart => 'Commencer la partie';

  @override
  String get gamePause => 'Pause';

  @override
  String get gameResume => 'Reprendre';

  @override
  String get gameRestart => 'Recommencer';

  @override
  String gameLives(Object lives) {
    return 'Vies : $lives';
  }

  @override
  String gameLevel(Object level) {
    return 'Niveau : $level';
  }

  @override
  String get examMode => 'Mode examen';

  @override
  String examTimeRemaining(Object time) {
    return 'Temps restant : $time';
  }

  @override
  String get examSubmit => 'Soumettre l\'examen';

  @override
  String get examPassed => 'Réussi';

  @override
  String get examFailed => 'À améliorer';

  @override
  String get examScoreBreakdown => 'Détail des scores';

  @override
  String get examReviewAnswers => 'Revoir les réponses et explications';

  @override
  String get examRetake => 'Repasser l\'examen';

  @override
  String get examBackToHub => 'Retour aux examens';

  @override
  String get shadowingListen1 => 'Étape 1 : Écouter le modèle (1.0x)';

  @override
  String get shadowingListen2 => 'Étape 2 : Écoute lente (0.75x)';

  @override
  String get shadowingRecord => 'Étape 3 : Répéter en shadowing';

  @override
  String get shadowingStop => 'Arrêter l\'enregistrement';

  @override
  String get shadowingSelfEval => 'Étape 4 : Auto-évaluation';

  @override
  String get shadowingNext => 'Phrase suivante';

  @override
  String get shadowingComplete => 'Pratique de Shadowing terminée !';

  @override
  String get authLogin => 'Connexion';

  @override
  String get authRegister => 'Inscription';

  @override
  String get authNoAccount => 'Pas encore de compte ? Inscrivez-vous';

  @override
  String get authAlreadyHaveAccount =>
      'Vous avez déjà un compte ? Connectez-vous';

  @override
  String get authLogout => 'Déconnexion';

  @override
  String get authLogoutConfirm => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get profileTitle => 'Profil utilisateur';

  @override
  String get profileEdit => 'Modifier le profil';

  @override
  String get profileSave => 'Enregistrer les modifications';

  @override
  String get profileDisplayName => 'Nom d\'affichage';

  @override
  String get profileEmail => 'E-mail';

  @override
  String get profileRole => 'Rôle';

  @override
  String get profileJoined => 'Date d\'inscription';

  @override
  String get adminTitle => 'Administration système (Admin)';

  @override
  String get adminUsers => 'Utilisateurs et niveaux';

  @override
  String get adminVocab => 'Vocabulaire et thèmes';

  @override
  String get adminExercises => 'Lecture et écoute';

  @override
  String get adminExams => 'Examens d\'entraînement';

  @override
  String get adminSystem => 'Surveillance du système';

  @override
  String get adminForbidden =>
      'Zone réservée aux administrateurs (403 Forbidden)';

  @override
  String get adminRefresh => 'Actualiser les données d\'administration';

  @override
  String get aiChatAsk => 'Demander à l\'IA';

  @override
  String get settingsSelectLanguage =>
      'Sélectionner la langue de l\'application';

  @override
  String get settingsSearchLanguage => 'Rechercher une langue...';

  @override
  String get settingsAllLanguages => 'Voir les 13 langues';

  @override
  String get settingsAllLanguagesSubtitle =>
      'Chinois, japonais, coréen, français, allemand, espagnol, russe...';

  @override
  String get settingsDefaultBadge => 'Par défaut';

  @override
  String get profileUsernameLabel => 'Nom d\'utilisateur de connexion';

  @override
  String get profileUsernameHint =>
      'Entrez le nom d\'utilisateur (3–30 caract. : a-z, 0-9, ., _, -)';

  @override
  String get profileUsernameHelperPassword =>
      'Vous pouvez vous connecter avec ce nom d\'utilisateur ou votre e-mail et votre mot de passe.';

  @override
  String get profileUsernameHelperGoogle =>
      'Les comptes Google continuent de se connecter via Google ; ce nom d\'utilisateur est votre identifiant unique.';

  @override
  String get profileEmailReadOnlyHelper =>
      'E-mail de connexion (lecture seule, inchangé lors de la modification du nom)';

  @override
  String get weeklyProgressTitle => 'Progression hebdomadaire';

  @override
  String weeklyProgressActiveDays(int count) {
    return '$count/7 jours actifs';
  }

  @override
  String weeklyProgressWordsStudied(int count) {
    return '$count mots étudiés/révisés';
  }

  @override
  String weeklyProgressActivitiesDone(int count) {
    return '$count activités terminées';
  }

  @override
  String weeklyProgressTodayGoal(int current, int goal) {
    return 'Objectif de mots du jour : $current/$goal mots';
  }

  @override
  String get weeklyProgressTodayBadge => 'Aujourd\'hui';

  @override
  String get weeklyProgressEmptyTitle =>
      'Aucune activité d\'apprentissage cette semaine';

  @override
  String get weeklyProgressEmptyDesc =>
      'Révisez du vocabulaire ou terminez un quiz pour mettre à jour votre graphique hebdomadaire instantanément !';

  @override
  String get weeklyProgressStartCta => 'Réviser le vocabulaire';

  @override
  String get weeklyProgressScopeNote =>
      'Suit les activités réelles horodatées du compte actuel (lundi – dimanche, heure locale).';

  @override
  String get weeklyProgressUnitWords => 'mots';

  @override
  String get weeklyProgressUnitActivities => 'act.';

  @override
  String get aiChatErrorGeneral => 'Impossible de recevoir la réponse de l\'IA';

  @override
  String get authRegisterSuccessPleaseLogin =>
      'Inscription réussie ! Veuillez vous connecter pour continuer.';
}
