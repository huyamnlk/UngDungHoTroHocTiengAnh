import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'English Buddy'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get navTopics;

  /// No description provided for @navListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get navListening;

  /// No description provided for @navReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get navReading;

  /// No description provided for @navWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get navWriting;

  /// No description provided for @navSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get navSpeaking;

  /// No description provided for @navShadowing.
  ///
  /// In en, this message translates to:
  /// **'Shadowing'**
  String get navShadowing;

  /// No description provided for @navDictionary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary & Dictionary'**
  String get navDictionary;

  /// No description provided for @navExam.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get navExam;

  /// No description provided for @navGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get navGames;

  /// No description provided for @navReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get navReview;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get navAdmin;

  /// No description provided for @navSectionSkills.
  ///
  /// In en, this message translates to:
  /// **'SKILLS & STUDY'**
  String get navSectionSkills;

  /// No description provided for @navSectionSystem.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS & SYSTEM'**
  String get navSectionSystem;

  /// No description provided for @sidebarExpandTooltip.
  ///
  /// In en, this message translates to:
  /// **'English Buddy - Expand sidebar'**
  String get sidebarExpandTooltip;

  /// No description provided for @sidebarCollapseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Collapse sidebar'**
  String get sidebarCollapseTooltip;

  /// No description provided for @mobileMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open 13 skills and features menu'**
  String get mobileMenuTooltip;

  /// No description provided for @aiChatTooltip.
  ///
  /// In en, this message translates to:
  /// **'English Buddy AI Assistant'**
  String get aiChatTooltip;

  /// No description provided for @aiChatQuickHelp.
  ///
  /// In en, this message translates to:
  /// **'Grammar Q&A & translation'**
  String get aiChatQuickHelp;

  /// No description provided for @aiChatDesc.
  ///
  /// In en, this message translates to:
  /// **'English Buddy AI Assistant (Q&A & Error Correction)'**
  String get aiChatDesc;

  /// No description provided for @accessDeniedAdminOnly.
  ///
  /// In en, this message translates to:
  /// **'Access denied: Admin area is restricted to Admin accounts only.'**
  String get accessDeniedAdminOnly;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get actionPrevious;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get actionSubmit;

  /// No description provided for @actionStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get actionStart;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get actionFilter;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @actionResetFilter.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get actionResetFilter;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get actionShowAll;

  /// No description provided for @actionExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get actionExpand;

  /// No description provided for @actionCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get actionCollapse;

  /// No description provided for @actionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get actionPlay;

  /// No description provided for @actionPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get actionPause;

  /// No description provided for @actionResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get actionResume;

  /// No description provided for @actionExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get actionExit;

  /// No description provided for @actionUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get actionUnderstood;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get statusLocked;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// No description provided for @allTopics.
  ///
  /// In en, this message translates to:
  /// **'All Topics'**
  String get allTopics;

  /// No description provided for @allLevels.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get allLevels;

  /// No description provided for @allSkills.
  ///
  /// In en, this message translates to:
  /// **'All Skills'**
  String get allSkills;

  /// No description provided for @allFormats.
  ///
  /// In en, this message translates to:
  /// **'All Formats'**
  String get allFormats;

  /// No description provided for @levelA1.
  ///
  /// In en, this message translates to:
  /// **'A1 - Beginner'**
  String get levelA1;

  /// No description provided for @levelA2.
  ///
  /// In en, this message translates to:
  /// **'A2 - Elementary'**
  String get levelA2;

  /// No description provided for @levelB1.
  ///
  /// In en, this message translates to:
  /// **'B1 - Intermediate'**
  String get levelB1;

  /// No description provided for @levelB2.
  ///
  /// In en, this message translates to:
  /// **'B2 - Upper Intermediate'**
  String get levelB2;

  /// No description provided for @levelC1.
  ///
  /// In en, this message translates to:
  /// **'C1 - Advanced'**
  String get levelC1;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Preferences'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language & Localization'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred application language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLangVi.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get settingsLangVi;

  /// No description provided for @settingsLangViDesc.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get settingsLangViDesc;

  /// No description provided for @settingsLangEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLangEn;

  /// No description provided for @settingsLangEnDesc.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLangEnDesc;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Profile & Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsThemeSection.
  ///
  /// In en, this message translates to:
  /// **'Interface & Theme'**
  String get settingsThemeSection;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically match device appearance'**
  String get settingsThemeSystemDesc;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsThemeDark;

  /// No description provided for @settingsDailyGoalSection.
  ///
  /// In en, this message translates to:
  /// **'Daily Learning Goal'**
  String get settingsDailyGoalSection;

  /// No description provided for @settingsDailyGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select how many words you want to complete each day:'**
  String get settingsDailyGoalSubtitle;

  /// No description provided for @settingsDailyGoalUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String settingsDailyGoalUnit(int count);

  /// No description provided for @settingsDailyGoalSaved.
  ///
  /// In en, this message translates to:
  /// **'Daily goal set to {count} words/day!'**
  String settingsDailyGoalSaved(int count);

  /// No description provided for @settingsSoundSection.
  ///
  /// In en, this message translates to:
  /// **'Sound & Pronunciation'**
  String get settingsSoundSection;

  /// No description provided for @settingsSoundEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable pronunciation audio'**
  String get settingsSoundEnable;

  /// No description provided for @settingsSoundEnableDesc.
  ///
  /// In en, this message translates to:
  /// **'Native-speaker Text-to-Speech pronunciation engine'**
  String get settingsSoundEnableDesc;

  /// No description provided for @settingsCopyrightSection.
  ///
  /// In en, this message translates to:
  /// **'Data Sources & Copyright'**
  String get settingsCopyrightSection;

  /// No description provided for @settingsCopyrightTitle.
  ///
  /// In en, this message translates to:
  /// **'Transparent Copyright Policy'**
  String get settingsCopyrightTitle;

  /// No description provided for @settingsCopyrightDesc1.
  ///
  /// In en, this message translates to:
  /// **'• Vocabulary content, sample sentences, and exercises are authored originally based on CEFR levels (A1–C1) and open language frameworks.'**
  String get settingsCopyrightDesc1;

  /// No description provided for @settingsCopyrightDesc2.
  ///
  /// In en, this message translates to:
  /// **'• We do not mass-copy copyrighted definitions or content from Cambridge Dictionary, DOL English, or commercial sources.'**
  String get settingsCopyrightDesc2;

  /// No description provided for @settingsCopyrightDesc3.
  ///
  /// In en, this message translates to:
  /// **'• Online lookup uses Free Dictionary API (open source, no API key required, licensed under CC BY-SA 3.0).'**
  String get settingsCopyrightDesc3;

  /// No description provided for @settingsAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile Application Project - Flutter & SQLite'**
  String get settingsAppSubtitle;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest (Not logged in)'**
  String get guestUser;

  /// No description provided for @guestUserDesc.
  ///
  /// In en, this message translates to:
  /// **'Not logged in. Log in or create an account to manage your profile and sync progress.'**
  String get guestUserDesc;

  /// No description provided for @authenticatedAs.
  ///
  /// In en, this message translates to:
  /// **'{email} • Verified ({provider})'**
  String authenticatedAs(String email, String provider);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @adminArea.
  ///
  /// In en, this message translates to:
  /// **'Admin Area'**
  String get adminArea;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @confirmSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sign Out'**
  String get confirmSignOutTitle;

  /// No description provided for @confirmSignOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of \"{email}\"?\n\nYour current session and token will be removed. Local learning progress on this device is preserved.'**
  String confirmSignOutMessage(String email);

  /// No description provided for @accountMenuHeader.
  ///
  /// In en, this message translates to:
  /// **'Account ({displayName})'**
  String accountMenuHeader(String displayName);

  /// No description provided for @homeGreetingGuest.
  ///
  /// In en, this message translates to:
  /// **'Hello there! 👋'**
  String get homeGreetingGuest;

  /// No description provided for @homeGreetingUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}! 👋'**
  String homeGreetingUser(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to expand your vocabulary and English mastery today?'**
  String get homeSubtitle;

  /// No description provided for @homeDayStreak.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String homeDayStreak(int days);

  /// No description provided for @homeStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get homeStreakLabel;

  /// No description provided for @homeMasteredWords.
  ///
  /// In en, this message translates to:
  /// **'{mastered}/{total} mastered'**
  String homeMasteredWords(int mastered, int total);

  /// No description provided for @homeProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'You have mastered {mastered} out of {total} CEFR words ({percent}% completed).'**
  String homeProgressSummary(int mastered, int total, int percent);

  /// No description provided for @homeGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal: {count} words/day'**
  String homeGoalTitle(int count);

  /// No description provided for @homeReviewNow.
  ///
  /// In en, this message translates to:
  /// **'Review Now ({count} words)'**
  String homeReviewNow(int count);

  /// No description provided for @homeDueSrsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} due for review'**
  String homeDueSrsCount(int count);

  /// No description provided for @homeWordsToLearn.
  ///
  /// In en, this message translates to:
  /// **'{count} words to memorize'**
  String homeWordsToLearn(int count);

  /// No description provided for @homeTopicCount.
  ///
  /// In en, this message translates to:
  /// **'{count} topics'**
  String homeTopicCount(int count);

  /// No description provided for @homeTopicCefrCount.
  ///
  /// In en, this message translates to:
  /// **'{count} CEFR topics'**
  String homeTopicCefrCount(int count);

  /// No description provided for @homeShortcutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Shortcuts'**
  String get homeShortcutsTitle;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// No description provided for @homeCardTopicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Topics'**
  String get homeCardTopicsTitle;

  /// No description provided for @homeCardTopicsDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore CEFR topics'**
  String get homeCardTopicsDesc;

  /// No description provided for @homeCardReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review List'**
  String get homeCardReviewTitle;

  /// No description provided for @homeCardReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Words currently needing review'**
  String get homeCardReviewDesc;

  /// No description provided for @homeCardExamTitle.
  ///
  /// In en, this message translates to:
  /// **'IELTS/TOEIC Exam Prep'**
  String get homeCardExamTitle;

  /// No description provided for @homeCardExamDesc.
  ///
  /// In en, this message translates to:
  /// **'Timed tests with detailed explanations'**
  String get homeCardExamDesc;

  /// No description provided for @homeCardGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Games'**
  String get homeCardGamesTitle;

  /// No description provided for @homeCardGamesDesc.
  ///
  /// In en, this message translates to:
  /// **'Matching pairs & speed quiz'**
  String get homeCardGamesDesc;

  /// No description provided for @homeCardShadowingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflex Shadowing'**
  String get homeCardShadowingTitle;

  /// No description provided for @homeCardShadowingDesc.
  ///
  /// In en, this message translates to:
  /// **'Sentence stress & linking sounds'**
  String get homeCardShadowingDesc;

  /// No description provided for @homeCardDictionaryTitle.
  ///
  /// In en, this message translates to:
  /// **'English - Vietnamese Dictionary'**
  String get homeCardDictionaryTitle;

  /// No description provided for @homeCardDictionaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Look up 3,000+ words'**
  String get homeCardDictionaryDesc;

  /// No description provided for @homeCardAiTitle.
  ///
  /// In en, this message translates to:
  /// **'English Buddy AI'**
  String get homeCardAiTitle;

  /// No description provided for @homeCardAiDesc.
  ///
  /// In en, this message translates to:
  /// **'Grammar Q&A, lookup & essay feedback'**
  String get homeCardAiDesc;

  /// No description provided for @homeCardStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress & Statistics'**
  String get homeCardStatsTitle;

  /// No description provided for @homeCardStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Mastered words & quiz history'**
  String get homeCardStatsDesc;

  /// No description provided for @homeTodayWord.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Vocabulary'**
  String get homeTodayWord;

  /// No description provided for @homeChangeWord.
  ///
  /// In en, this message translates to:
  /// **'New Word'**
  String get homeChangeWord;

  /// No description provided for @homeSaveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Save to Favorites'**
  String get homeSaveFavorite;

  /// No description provided for @homeRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get homeRemoveFavorite;

  /// No description provided for @homeListenPronunciation.
  ///
  /// In en, this message translates to:
  /// **'Listen to pronunciation'**
  String get homeListenPronunciation;

  /// No description provided for @homeSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get homeSavedSuccess;

  /// No description provided for @topicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Topics'**
  String get topicsTitle;

  /// No description provided for @topicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore {count} real-life vocabulary topics leveled from A1 to C1.'**
  String topicsSubtitle(int count);

  /// No description provided for @topicsCountWords.
  ///
  /// In en, this message translates to:
  /// **'{count} vocabulary items'**
  String topicsCountWords(int count);

  /// No description provided for @topicsMasteredCount.
  ///
  /// In en, this message translates to:
  /// **'Mastered: {mastered}/{total}'**
  String topicsMasteredCount(int mastered, int total);

  /// No description provided for @topicSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search English word or Vietnamese meaning...'**
  String get topicSearchPlaceholder;

  /// No description provided for @topicLearnFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Learn Flashcards ({count})'**
  String topicLearnFlashcard(int count);

  /// No description provided for @topicFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get topicFilterAll;

  /// No description provided for @topicFilterNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get topicFilterNew;

  /// No description provided for @topicFilterReview.
  ///
  /// In en, this message translates to:
  /// **'Need Review'**
  String get topicFilterReview;

  /// No description provided for @topicFilterMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get topicFilterMastered;

  /// No description provided for @topicEmptyWord.
  ///
  /// In en, this message translates to:
  /// **'No vocabulary found'**
  String get topicEmptyWord;

  /// No description provided for @topicEmptyWordDesc.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords or switch filters.'**
  String get topicEmptyWordDesc;

  /// No description provided for @addWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Word'**
  String get addWordTitle;

  /// No description provided for @addWordTopicTarget.
  ///
  /// In en, this message translates to:
  /// **'Into topic: {topicName}'**
  String addWordTopicTarget(String topicName);

  /// No description provided for @addWordEnglishLabel.
  ///
  /// In en, this message translates to:
  /// **'English Word *'**
  String get addWordEnglishLabel;

  /// No description provided for @addWordEnglishHint.
  ///
  /// In en, this message translates to:
  /// **'e.g.: Innovation'**
  String get addWordEnglishHint;

  /// No description provided for @addWordMeaningLabel.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese Meaning *'**
  String get addWordMeaningLabel;

  /// No description provided for @addWordMeaningHint.
  ///
  /// In en, this message translates to:
  /// **'e.g.: Sự đổi mới, cách tân'**
  String get addWordMeaningHint;

  /// No description provided for @addWordIpaLabel.
  ///
  /// In en, this message translates to:
  /// **'IPA Phonetic'**
  String get addWordIpaLabel;

  /// No description provided for @addWordIpaHint.
  ///
  /// In en, this message translates to:
  /// **'e.g.: /ˌɪn.əˈveɪ.ʃən/'**
  String get addWordIpaHint;

  /// No description provided for @addWordPartOfSpeechLabel.
  ///
  /// In en, this message translates to:
  /// **'Part of Speech'**
  String get addWordPartOfSpeechLabel;

  /// No description provided for @addWordExampleEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Example Sentence (English)'**
  String get addWordExampleEnLabel;

  /// No description provided for @addWordExampleEnHint.
  ///
  /// In en, this message translates to:
  /// **'e.g.: Innovation drives technology forward.'**
  String get addWordExampleEnHint;

  /// No description provided for @addWordExampleViLabel.
  ///
  /// In en, this message translates to:
  /// **'Example Sentence Translation'**
  String get addWordExampleViLabel;

  /// No description provided for @addWordExampleViHint.
  ///
  /// In en, this message translates to:
  /// **'e.g.: Sự đổi mới thúc đẩy công nghệ tiến lên.'**
  String get addWordExampleViHint;

  /// No description provided for @addWordNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes / Pronunciation Tips'**
  String get addWordNotesLabel;

  /// No description provided for @addWordNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g.: Stress on 3rd syllable'**
  String get addWordNotesHint;

  /// No description provided for @addWordSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Word'**
  String get addWordSaveButton;

  /// No description provided for @addWordRequiredEnglish.
  ///
  /// In en, this message translates to:
  /// **'Please enter the English word'**
  String get addWordRequiredEnglish;

  /// No description provided for @addWordRequiredMeaning.
  ///
  /// In en, this message translates to:
  /// **'Please enter the Vietnamese meaning'**
  String get addWordRequiredMeaning;

  /// No description provided for @addWordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added \"{term}\" successfully!'**
  String addWordSuccess(String term);

  /// No description provided for @flashcardTapToFlip.
  ///
  /// In en, this message translates to:
  /// **'Tap card to flip to word'**
  String get flashcardTapToFlip;

  /// No description provided for @flashcardTapToMeaning.
  ///
  /// In en, this message translates to:
  /// **'Tap card to view meaning'**
  String get flashcardTapToMeaning;

  /// No description provided for @flashcardVietnameseMeaning.
  ///
  /// In en, this message translates to:
  /// **'VIETNAMESE MEANING'**
  String get flashcardVietnameseMeaning;

  /// No description provided for @flashcardNeedReview.
  ///
  /// In en, this message translates to:
  /// **'Need Review'**
  String get flashcardNeedReview;

  /// No description provided for @flashcardMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get flashcardMastered;

  /// No description provided for @flashcardCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Awesome! You have completed!'**
  String get flashcardCompletedTitle;

  /// No description provided for @flashcardCompletedDesc.
  ///
  /// In en, this message translates to:
  /// **'You just finished reviewing {count} flashcards.'**
  String flashcardCompletedDesc(int count);

  /// No description provided for @flashcardReviewAgain.
  ///
  /// In en, this message translates to:
  /// **'Review Again'**
  String get flashcardReviewAgain;

  /// No description provided for @flashcardBack.
  ///
  /// In en, this message translates to:
  /// **'Back to Previous Page'**
  String get flashcardBack;

  /// No description provided for @flashcardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No vocabulary available for review.'**
  String get flashcardEmpty;

  /// No description provided for @quizSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Challenge'**
  String get quizSetupTitle;

  /// No description provided for @quizSetupHeader.
  ///
  /// In en, this message translates to:
  /// **'Speed & Reflex Quiz'**
  String get quizSetupHeader;

  /// No description provided for @quizSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reinforce vocabulary through diverse formats: Meaning selection, word selection, and contextual fill-in-the-blank.'**
  String get quizSetupSubtitle;

  /// No description provided for @quizSetupSelectTopic.
  ///
  /// In en, this message translates to:
  /// **'Select Quiz Topic'**
  String get quizSetupSelectTopic;

  /// No description provided for @quizSetupAllTopics.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive (All Topics)'**
  String get quizSetupAllTopics;

  /// No description provided for @quizSetupAllTopicsDesc.
  ///
  /// In en, this message translates to:
  /// **'Randomly drawn from entire vocabulary database'**
  String get quizSetupAllTopicsDesc;

  /// No description provided for @quizSetupQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'Number of Questions'**
  String get quizSetupQuestionCount;

  /// No description provided for @quizSetupCountFast.
  ///
  /// In en, this message translates to:
  /// **'5 questions (Quick)'**
  String get quizSetupCountFast;

  /// No description provided for @quizSetupCountStandard.
  ///
  /// In en, this message translates to:
  /// **'10 questions (Standard)'**
  String get quizSetupCountStandard;

  /// No description provided for @quizSetupStart.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get quizSetupStart;

  /// No description provided for @quizPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Challenge'**
  String get quizPlayTitle;

  /// No description provided for @quizPlayQuestionCounter.
  ///
  /// In en, this message translates to:
  /// **'Question {current}/{total}'**
  String quizPlayQuestionCounter(int current, int total);

  /// No description provided for @quizPlayTypeSelectMeaning.
  ///
  /// In en, this message translates to:
  /// **'Select the correct Vietnamese meaning'**
  String get quizPlayTypeSelectMeaning;

  /// No description provided for @quizPlayTypeSelectWord.
  ///
  /// In en, this message translates to:
  /// **'Select the correct English word'**
  String get quizPlayTypeSelectWord;

  /// No description provided for @quizPlayTypeFillBlank.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank with the correct word'**
  String get quizPlayTypeFillBlank;

  /// No description provided for @quizPlayCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get quizPlayCheck;

  /// No description provided for @quizPlayNext.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get quizPlayNext;

  /// No description provided for @quizPlayViewResult.
  ///
  /// In en, this message translates to:
  /// **'View Results'**
  String get quizPlayViewResult;

  /// No description provided for @quizPlayCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get quizPlayCorrect;

  /// No description provided for @quizPlayIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect!'**
  String get quizPlayIncorrect;

  /// No description provided for @quizPlayExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit quiz?'**
  String get quizPlayExitTitle;

  /// No description provided for @quizPlayExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Current quiz progress will not be saved if you leave now.'**
  String get quizPlayExitMessage;

  /// No description provided for @quizPlayContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue Quiz'**
  String get quizPlayContinue;

  /// No description provided for @quizResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Results'**
  String get quizResultTitle;

  /// No description provided for @quizResultScore.
  ///
  /// In en, this message translates to:
  /// **'Correct {correct} / {total} questions'**
  String quizResultScore(int correct, int total);

  /// No description provided for @quizResultExcellent.
  ///
  /// In en, this message translates to:
  /// **'Outstanding!'**
  String get quizResultExcellent;

  /// No description provided for @quizResultGood.
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get quizResultGood;

  /// No description provided for @quizResultNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'Keep Practicing!'**
  String get quizResultNeedsWork;

  /// No description provided for @quizResultDescExcellent.
  ///
  /// In en, this message translates to:
  /// **'You have a solid command of the words in this quiz. Keep it up!'**
  String get quizResultDescExcellent;

  /// No description provided for @quizResultDescGood.
  ///
  /// In en, this message translates to:
  /// **'Well done! Incorrect words have been automatically saved to \"Need Review\" for further practice.'**
  String get quizResultDescGood;

  /// No description provided for @quizResultDescNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'Don\'t be discouraged! Review the flashcards and give it another try.'**
  String get quizResultDescNeedsWork;

  /// No description provided for @quizResultDetails.
  ///
  /// In en, this message translates to:
  /// **'Answer Breakdown'**
  String get quizResultDetails;

  /// No description provided for @quizResultRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake Quiz'**
  String get quizResultRetake;

  /// No description provided for @quizResultHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get quizResultHome;

  /// No description provided for @quizResultUserSelected.
  ///
  /// In en, this message translates to:
  /// **'Your choice: {answer}'**
  String quizResultUserSelected(String answer);

  /// No description provided for @quizResultCorrectIs.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String quizResultCorrectIs(String answer);

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review & Favorites'**
  String get reviewTitle;

  /// No description provided for @reviewTabNeedReview.
  ///
  /// In en, this message translates to:
  /// **'Need Review ({count})'**
  String reviewTabNeedReview(int count);

  /// No description provided for @reviewTabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites ({count})'**
  String reviewTabFavorites(int count);

  /// No description provided for @reviewEmptyNeedReview.
  ///
  /// In en, this message translates to:
  /// **'No words due for review'**
  String get reviewEmptyNeedReview;

  /// No description provided for @reviewEmptyNeedReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'When you mark a word as \"Need Review\" in Flashcards or answer incorrectly in Quizzes, it will automatically appear here based on Spaced Repetition.'**
  String get reviewEmptyNeedReviewDesc;

  /// No description provided for @reviewEmptyFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorite words yet'**
  String get reviewEmptyFavorites;

  /// No description provided for @reviewEmptyFavoritesDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any word to bookmark and revisit it here.'**
  String get reviewEmptyFavoritesDesc;

  /// No description provided for @reviewLearnFlashcardsNeed.
  ///
  /// In en, this message translates to:
  /// **'Flashcards (Need Review)'**
  String get reviewLearnFlashcardsNeed;

  /// No description provided for @reviewLearnFlashcardsFav.
  ///
  /// In en, this message translates to:
  /// **'Flashcards (Favorites)'**
  String get reviewLearnFlashcardsFav;

  /// No description provided for @reviewTotalWords.
  ///
  /// In en, this message translates to:
  /// **'Total: {count} words'**
  String reviewTotalWords(int count);

  /// No description provided for @reviewViewStats.
  ///
  /// In en, this message translates to:
  /// **'View Progress Statistics'**
  String get reviewViewStats;

  /// No description provided for @wordDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Word Details'**
  String get wordDetailTitle;

  /// No description provided for @wordDetailVietnameseDef.
  ///
  /// In en, this message translates to:
  /// **'VIETNAMESE DEFINITION'**
  String get wordDetailVietnameseDef;

  /// No description provided for @wordDetailSrsTitle.
  ///
  /// In en, this message translates to:
  /// **'Spaced Repetition System (SRS)'**
  String get wordDetailSrsTitle;

  /// No description provided for @wordDetailInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval: {days} days'**
  String wordDetailInterval(int days);

  /// No description provided for @wordDetailReviewCount.
  ///
  /// In en, this message translates to:
  /// **'Review count: {count}'**
  String wordDetailReviewCount(int count);

  /// No description provided for @wordDetailRealWorldExample.
  ///
  /// In en, this message translates to:
  /// **'Real-World Context Example'**
  String get wordDetailRealWorldExample;

  /// No description provided for @wordDetailSynonyms.
  ///
  /// In en, this message translates to:
  /// **'Synonyms: {synonyms}'**
  String wordDetailSynonyms(String synonyms);

  /// No description provided for @wordDetailAntonyms.
  ///
  /// In en, this message translates to:
  /// **'Antonyms: {antonyms}'**
  String wordDetailAntonyms(String antonyms);

  /// No description provided for @wordDetailTips.
  ///
  /// In en, this message translates to:
  /// **'Memory & Pronunciation Tips'**
  String get wordDetailTips;

  /// No description provided for @wordDetailAddedFav.
  ///
  /// In en, this message translates to:
  /// **'Added to Favorites'**
  String get wordDetailAddedFav;

  /// No description provided for @wordDetailRemovedFav.
  ///
  /// In en, this message translates to:
  /// **'Removed from Favorites'**
  String get wordDetailRemovedFav;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics & Progress'**
  String get statsTitle;

  /// No description provided for @statsOverallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Learning Progress'**
  String get statsOverallProgress;

  /// No description provided for @statsMasteredRatio.
  ///
  /// In en, this message translates to:
  /// **'Mastered {mastered}/{total} words'**
  String statsMasteredRatio(int mastered, int total);

  /// No description provided for @statsTotalWords.
  ///
  /// In en, this message translates to:
  /// **'Total Vocabulary'**
  String get statsTotalWords;

  /// No description provided for @statsMasteredWords.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get statsMasteredWords;

  /// No description provided for @statsNeedReviewWords.
  ///
  /// In en, this message translates to:
  /// **'Need Review'**
  String get statsNeedReviewWords;

  /// No description provided for @statsFavoriteWords.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get statsFavoriteWords;

  /// No description provided for @statsTopicProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress by Topic'**
  String get statsTopicProgress;

  /// No description provided for @statsQuizHistory.
  ///
  /// In en, this message translates to:
  /// **'Quiz History'**
  String get statsQuizHistory;

  /// No description provided for @statsAverageScore.
  ///
  /// In en, this message translates to:
  /// **'Avg: {score}%'**
  String statsAverageScore(String score);

  /// No description provided for @statsEmptyQuiz.
  ///
  /// In en, this message translates to:
  /// **'No quiz history yet. Take a quiz to test your reflexes!'**
  String get statsEmptyQuiz;

  /// No description provided for @statsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset data?'**
  String get statsResetTitle;

  /// No description provided for @statsResetMessage.
  ///
  /// In en, this message translates to:
  /// **'All study states, quiz history, and custom vocabulary will be reset to application defaults.'**
  String get statsResetMessage;

  /// No description provided for @statsResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reset'**
  String get statsResetConfirm;

  /// No description provided for @statsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully restored initial application data!'**
  String get statsResetSuccess;

  /// No description provided for @dictTitle.
  ///
  /// In en, this message translates to:
  /// **'Bilingual Dictionary'**
  String get dictTitle;

  /// No description provided for @dictSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Bilingual lookup: type Vietnamese (căn hộ) or English (apartment)...'**
  String get dictSearchPlaceholder;

  /// No description provided for @dictRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get dictRecentSearches;

  /// No description provided for @dictClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get dictClearHistory;

  /// No description provided for @dictOnlineViEn.
  ///
  /// In en, this message translates to:
  /// **'Online Translate Vietnamese ➔ English'**
  String get dictOnlineViEn;

  /// No description provided for @dictOnlineEnVi.
  ///
  /// In en, this message translates to:
  /// **'Online Lookup English ➔ Vietnamese'**
  String get dictOnlineEnVi;

  /// No description provided for @dictOnlineViEnQuery.
  ///
  /// In en, this message translates to:
  /// **'Online Translate Vietnamese ➔ English for \"{query}\"'**
  String dictOnlineViEnQuery(String query);

  /// No description provided for @dictOnlineEnViQuery.
  ///
  /// In en, this message translates to:
  /// **'Online Lookup English ➔ Vietnamese for \"{query}\"'**
  String dictOnlineEnViQuery(String query);

  /// No description provided for @dictNotFoundInternal.
  ///
  /// In en, this message translates to:
  /// **'Could not find \"{query}\" in internal dictionary.'**
  String dictNotFoundInternal(String query);

  /// No description provided for @dictListenWord.
  ///
  /// In en, this message translates to:
  /// **'Listen to native pronunciation'**
  String get dictListenWord;

  /// No description provided for @dictCachedBadge.
  ///
  /// In en, this message translates to:
  /// **'SQLite Cached (Offline)'**
  String get dictCachedBadge;

  /// No description provided for @dictSaveToReview.
  ///
  /// In en, this message translates to:
  /// **'Save to Review'**
  String get dictSaveToReview;

  /// No description provided for @dictSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved \"{term}\" to vocabulary & review list!'**
  String dictSavedSuccess(String term);

  /// No description provided for @dictEnglishDefinitions.
  ///
  /// In en, this message translates to:
  /// **'English Definitions & Examples:'**
  String get dictEnglishDefinitions;

  /// No description provided for @dictSynonymsList.
  ///
  /// In en, this message translates to:
  /// **'Synonyms: {synonyms}'**
  String dictSynonymsList(String synonyms);

  /// No description provided for @dictNoun.
  ///
  /// In en, this message translates to:
  /// **'Noun (n)'**
  String get dictNoun;

  /// No description provided for @dictVerb.
  ///
  /// In en, this message translates to:
  /// **'Verb (v)'**
  String get dictVerb;

  /// No description provided for @dictAdj.
  ///
  /// In en, this message translates to:
  /// **'Adjective (adj)'**
  String get dictAdj;

  /// No description provided for @dictAdv.
  ///
  /// In en, this message translates to:
  /// **'Adverb (adv)'**
  String get dictAdv;

  /// No description provided for @dictPhrase.
  ///
  /// In en, this message translates to:
  /// **'Phrase / Idiom'**
  String get dictPhrase;

  /// No description provided for @skillsHubTitle.
  ///
  /// In en, this message translates to:
  /// **'4 Skills & Vocabulary Practice'**
  String get skillsHubTitle;

  /// No description provided for @skillsHubAllLevels.
  ///
  /// In en, this message translates to:
  /// **'Show all levels (A1–C1)'**
  String get skillsHubAllLevels;

  /// No description provided for @skillsListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get skillsListening;

  /// No description provided for @skillsReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get skillsReading;

  /// No description provided for @skillsWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get skillsWriting;

  /// No description provided for @skillsSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get skillsSpeaking;

  /// No description provided for @skillsListeningDesc.
  ///
  /// In en, this message translates to:
  /// **'Standard (1.0x) or slow (0.75x) audio. Transcripts and translations locked until submission.'**
  String get skillsListeningDesc;

  /// No description provided for @skillsReadingDesc.
  ///
  /// In en, this message translates to:
  /// **'Graded A1–C1 texts, multiple-choice & fill-in-the-blank questions, full explanations.'**
  String get skillsReadingDesc;

  /// No description provided for @skillsWritingDesc.
  ///
  /// In en, this message translates to:
  /// **'Sentence scramble and rubric-based essay writing with model answers.'**
  String get skillsWritingDesc;

  /// No description provided for @skillsSpeakingDesc.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation, sentence stress, linking sounds, and 4-criterion rubric self-evaluation.'**
  String get skillsSpeakingDesc;

  /// No description provided for @skillsStartLearning.
  ///
  /// In en, this message translates to:
  /// **'Practice Now'**
  String get skillsStartLearning;

  /// No description provided for @skillsProgressText.
  ///
  /// In en, this message translates to:
  /// **'Progress: {completed}/{total} lessons completed'**
  String skillsProgressText(int completed, int total);

  /// No description provided for @skillsCompletedBadge.
  ///
  /// In en, this message translates to:
  /// **'Completed • {score}%'**
  String skillsCompletedBadge(int score);

  /// No description provided for @skillsLessonList.
  ///
  /// In en, this message translates to:
  /// **'Lesson List ({count} lessons)'**
  String skillsLessonList(int count);

  /// No description provided for @skillsNoLessonLevel.
  ///
  /// In en, this message translates to:
  /// **'No lessons available at CEFR {level}.'**
  String skillsNoLessonLevel(String level);

  /// No description provided for @skillsOpenShadowing.
  ///
  /// In en, this message translates to:
  /// **'Open Shadowing Studio'**
  String get skillsOpenShadowing;

  /// No description provided for @skillsMatchingGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Matching Pairs Game'**
  String get skillsMatchingGameTitle;

  /// No description provided for @skillsFlashcard3dTitle.
  ///
  /// In en, this message translates to:
  /// **'3D Flashcards'**
  String get skillsFlashcard3dTitle;

  /// No description provided for @skillsQuizReflexTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Reflex Quiz'**
  String get skillsQuizReflexTitle;

  /// No description provided for @skillsExamHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Timed Exam Room'**
  String get skillsExamHubTitle;

  /// No description provided for @skillsSrsReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'SRS Spaced Repetition'**
  String get skillsSrsReviewTitle;

  /// No description provided for @exerciseListeningTitle.
  ///
  /// In en, this message translates to:
  /// **'Listening Comprehension'**
  String get exerciseListeningTitle;

  /// No description provided for @exerciseReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading Comprehension'**
  String get exerciseReadingTitle;

  /// No description provided for @exerciseQuestionsCount.
  ///
  /// In en, this message translates to:
  /// **'Comprehension Questions ({count} questions)'**
  String exerciseQuestionsCount(int count);

  /// No description provided for @exerciseScoreResult.
  ///
  /// In en, this message translates to:
  /// **'Score: {correct}/{total} correct ({percent}%)'**
  String exerciseScoreResult(int correct, int total, int percent);

  /// No description provided for @exerciseShowTranscript.
  ///
  /// In en, this message translates to:
  /// **'Show Transcript & Translation'**
  String get exerciseShowTranscript;

  /// No description provided for @exerciseHideTranscript.
  ///
  /// In en, this message translates to:
  /// **'Hide Transcript & Translation'**
  String get exerciseHideTranscript;

  /// No description provided for @exerciseReadingPassage.
  ///
  /// In en, this message translates to:
  /// **'Reading Passage'**
  String get exerciseReadingPassage;

  /// No description provided for @exerciseAudioPlayer.
  ///
  /// In en, this message translates to:
  /// **'Audio Player'**
  String get exerciseAudioPlayer;

  /// No description provided for @exerciseKeyWords.
  ///
  /// In en, this message translates to:
  /// **'Key Vocabulary ({count} words)'**
  String exerciseKeyWords(int count);

  /// No description provided for @exerciseSubmitGrade.
  ///
  /// In en, this message translates to:
  /// **'Submit & Grade'**
  String get exerciseSubmitGrade;

  /// No description provided for @exerciseRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake Lesson'**
  String get exerciseRetake;

  /// No description provided for @exerciseSaveWordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved \"{term}\" to Review & Favorites!'**
  String exerciseSaveWordSuccess(String term);

  /// No description provided for @speakingTimerPractice.
  ///
  /// In en, this message translates to:
  /// **'Timed Speaking Practice'**
  String get speakingTimerPractice;

  /// No description provided for @speakingRecordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Recording ({seconds}s) - Tap to stop'**
  String speakingRecordPrompt(int seconds);

  /// No description provided for @speakingRubricSelfCheck.
  ///
  /// In en, this message translates to:
  /// **'Self-Evaluation ({checked}/{total} criteria met)'**
  String speakingRubricSelfCheck(int checked, int total);

  /// No description provided for @speakingSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved speaking self-evaluation ({score}%) to learning history!'**
  String speakingSaveSuccess(int score);

  /// No description provided for @writingTabScramble.
  ///
  /// In en, this message translates to:
  /// **'1. Sentence Structure & Scramble'**
  String get writingTabScramble;

  /// No description provided for @writingTabRubric.
  ///
  /// In en, this message translates to:
  /// **'2. Paragraph Writing & Rubric'**
  String get writingTabRubric;

  /// No description provided for @writingTapWordToForm.
  ///
  /// In en, this message translates to:
  /// **'Tap words below to form a sentence...'**
  String get writingTapWordToForm;

  /// No description provided for @writingCheckSentence.
  ///
  /// In en, this message translates to:
  /// **'Check Sentence'**
  String get writingCheckSentence;

  /// No description provided for @writingWordCountStatus.
  ///
  /// In en, this message translates to:
  /// **'Words: {count} / min {min} words'**
  String writingWordCountStatus(int count, int min);

  /// No description provided for @writingNeedMoreWords.
  ///
  /// In en, this message translates to:
  /// **'Need {count} more words'**
  String writingNeedMoreWords(int count);

  /// No description provided for @writingSaveModelAnswer.
  ///
  /// In en, this message translates to:
  /// **'Save Essay & Unlock Model Answer'**
  String get writingSaveModelAnswer;

  /// No description provided for @writingModelAnswerTitle.
  ///
  /// In en, this message translates to:
  /// **'Model Answer (Reference)'**
  String get writingModelAnswerTitle;

  /// No description provided for @shadowingHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflex Shadowing Studio'**
  String get shadowingHubTitle;

  /// No description provided for @shadowingMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'4-Step Intonation Shadowing Method'**
  String get shadowingMethodTitle;

  /// No description provided for @shadowingMethodDesc.
  ///
  /// In en, this message translates to:
  /// **'1. Listen to model (1.0x) → 2. Slow listening & liaison analysis (0.75x) → 3. Synchronous shadowing → 4. Honest self-evaluation.'**
  String get shadowingMethodDesc;

  /// No description provided for @shadowingLessonsList.
  ///
  /// In en, this message translates to:
  /// **'Shadowing Lessons ({count} lessons)'**
  String shadowingLessonsList(int count);

  /// No description provided for @shadowingPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Shadowing Practice'**
  String get shadowingPracticeTitle;

  /// No description provided for @shadowingStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Listen to Model (1.0x)'**
  String get shadowingStep1;

  /// No description provided for @shadowingStep2.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Slow Listening (0.75x)'**
  String get shadowingStep2;

  /// No description provided for @shadowingStep3.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Synchronous Shadowing'**
  String get shadowingStep3;

  /// No description provided for @shadowingStep4.
  ///
  /// In en, this message translates to:
  /// **'Step 4: Self-Evaluation (Required)'**
  String get shadowingStep4;

  /// No description provided for @shadowingSpeakingStatus.
  ///
  /// In en, this message translates to:
  /// **'Shadowing in progress ({seconds}s)...'**
  String shadowingSpeakingStatus(int seconds);

  /// No description provided for @shadowingSaveProgress.
  ///
  /// In en, this message translates to:
  /// **'Save Shadowing Progress'**
  String get shadowingSaveProgress;

  /// No description provided for @shadowingSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved Shadowing lesson progress ({score}% criteria met) to database!'**
  String shadowingSavedSuccess(int score);

  /// No description provided for @gamesHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Mini-Games Center'**
  String get gamesHubTitle;

  /// No description provided for @gamesHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Boost vocabulary retention through fast-paced typing, reflex arenas, and falling word challenges.'**
  String get gamesHubSubtitle;

  /// No description provided for @gamesSelectGame.
  ///
  /// In en, this message translates to:
  /// **'Select a game to start:'**
  String get gamesSelectGame;

  /// No description provided for @gamesSpaceTyperTitle.
  ///
  /// In en, this message translates to:
  /// **'Space Typer'**
  String get gamesSpaceTyperTitle;

  /// No description provided for @gamesSpaceTyperDesc.
  ///
  /// In en, this message translates to:
  /// **'Type letters and words to destroy asteroids. Auto-aligning starship, laser fire, defensive radar.'**
  String get gamesSpaceTyperDesc;

  /// No description provided for @gamesArenaTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Arena'**
  String get gamesArenaTitle;

  /// No description provided for @gamesArenaDesc.
  ///
  /// In en, this message translates to:
  /// **'7-15s reflex multiple-choice, streak combos, computer number keys 1-4 supported.'**
  String get gamesArenaDesc;

  /// No description provided for @gamesWordRainTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Rain'**
  String get gamesWordRainTitle;

  /// No description provided for @gamesWordRainDesc.
  ///
  /// In en, this message translates to:
  /// **'Catch falling English raindrops matching the Vietnamese target meaning before they sink.'**
  String get gamesWordRainDesc;

  /// No description provided for @gamesPlayNow.
  ///
  /// In en, this message translates to:
  /// **'Play Now'**
  String get gamesPlayNow;

  /// No description provided for @gamesRules.
  ///
  /// In en, this message translates to:
  /// **'Rules & Instructions'**
  String get gamesRules;

  /// No description provided for @gamesHighScore.
  ///
  /// In en, this message translates to:
  /// **'High Score: {score} pts'**
  String gamesHighScore(int score);

  /// No description provided for @gamesRecentHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent Game History ({count} matches)'**
  String gamesRecentHistory(int count);

  /// No description provided for @gameScorePoints.
  ///
  /// In en, this message translates to:
  /// **'{score} pts'**
  String gameScorePoints(int score);

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over!'**
  String get gameOver;

  /// No description provided for @gameCompleted.
  ///
  /// In en, this message translates to:
  /// **'Round Completed!'**
  String get gameCompleted;

  /// No description provided for @gamePlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get gamePlayAgain;

  /// No description provided for @gameBackToHub.
  ///
  /// In en, this message translates to:
  /// **'Back to Games Hub'**
  String get gameBackToHub;

  /// No description provided for @gameAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get gameAccuracy;

  /// No description provided for @gameTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get gameTime;

  /// No description provided for @gameStreak.
  ///
  /// In en, this message translates to:
  /// **'Max Streak'**
  String get gameStreak;

  /// No description provided for @gameNewRecord.
  ///
  /// In en, this message translates to:
  /// **'🎉 NEW PERSONAL RECORD!'**
  String get gameNewRecord;

  /// No description provided for @gameDiffEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get gameDiffEasy;

  /// No description provided for @gameDiffMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get gameDiffMedium;

  /// No description provided for @gameDiffHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get gameDiffHard;

  /// No description provided for @examHubTitle.
  ///
  /// In en, this message translates to:
  /// **'International Certification Exams'**
  String get examHubTitle;

  /// No description provided for @examHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Timed Practice & Simulation Tests (IELTS • TOEIC • CEFR)'**
  String get examHubSubtitle;

  /// No description provided for @examListTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Exams ({count} tests)'**
  String examListTitle(int count);

  /// No description provided for @examPracticeMode.
  ///
  /// In en, this message translates to:
  /// **'Practice Mode'**
  String get examPracticeMode;

  /// No description provided for @examPracticeModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Untimed, view hints and in-depth explanations per question immediately.'**
  String get examPracticeModeDesc;

  /// No description provided for @examTimedMode.
  ///
  /// In en, this message translates to:
  /// **'Exam Mode (Timed)'**
  String get examTimedMode;

  /// No description provided for @examTimedModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Countdown timer, auto-submit when time expires, comprehensive score report.'**
  String get examTimedModeDesc;

  /// No description provided for @examQuestionCounter.
  ///
  /// In en, this message translates to:
  /// **'Question {current}/{total}'**
  String examQuestionCounter(int current, int total);

  /// No description provided for @examSubmitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Submit Exam?'**
  String get examSubmitConfirm;

  /// No description provided for @examSubmitConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish and submit your exam?'**
  String get examSubmitConfirmDesc;

  /// No description provided for @examResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam Results & In-Depth Analysis'**
  String get examResultTitle;

  /// No description provided for @examScoreBand.
  ///
  /// In en, this message translates to:
  /// **'Estimated Score: {band}'**
  String examScoreBand(String band);

  /// No description provided for @examCorrectRatio.
  ///
  /// In en, this message translates to:
  /// **'Correct: {correct}/{total} questions ({percent}%)'**
  String examCorrectRatio(int correct, int total, int percent);

  /// No description provided for @aiChatTitle.
  ///
  /// In en, this message translates to:
  /// **'English Buddy AI Assistant'**
  String get aiChatTitle;

  /// No description provided for @aiChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar Q&A • Sentence Translation • Essay Feedback'**
  String get aiChatSubtitle;

  /// No description provided for @aiChatGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! How can I assist you with English today?'**
  String get aiChatGreeting;

  /// No description provided for @aiChatGreetingDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask me any grammar question, request sentence translations, or ask for essay feedback!'**
  String get aiChatGreetingDesc;

  /// No description provided for @aiChatSuggestions.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTED PRACTICE QUESTIONS'**
  String get aiChatSuggestions;

  /// No description provided for @aiChatInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type your question, sentence to translate, or essay...'**
  String get aiChatInputPlaceholder;

  /// No description provided for @aiChatClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear conversation?'**
  String get aiChatClearTitle;

  /// No description provided for @aiChatClearDesc.
  ///
  /// In en, this message translates to:
  /// **'All AI chat messages will be wiped from this device. This action cannot be undone.'**
  String get aiChatClearDesc;

  /// No description provided for @aiChatClearSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully cleared all chat history.'**
  String get aiChatClearSuccess;

  /// No description provided for @aiChatThinking.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant is thinking...'**
  String get aiChatThinking;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Sign In'**
  String get authSignInTitle;

  /// No description provided for @authSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get authSignUpTitle;

  /// No description provided for @authAccountOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Username or Email'**
  String get authAccountOrEmail;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// No description provided for @authDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get authDisplayName;

  /// No description provided for @authGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authGoogleSignIn;

  /// No description provided for @authProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get authProcessing;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match!'**
  String get authPasswordMismatch;

  /// No description provided for @authMinPassword.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authMinPassword;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authInvalidEmail;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authOr;

  /// No description provided for @statsResetButton.
  ///
  /// In en, this message translates to:
  /// **'Restore initial data'**
  String get statsResetButton;

  /// No description provided for @statsQuizQuestionsCount.
  ///
  /// In en, this message translates to:
  /// **'{correct}/{total} questions'**
  String statsQuizQuestionsCount(Object correct, Object total);

  /// No description provided for @statsTopicWordsProgress.
  ///
  /// In en, this message translates to:
  /// **'{mastered}/{total} words ({percent}%)'**
  String statsTopicWordsProgress(Object mastered, Object percent, Object total);

  /// No description provided for @dictTitleFull.
  ///
  /// In en, this message translates to:
  /// **'Bilingual Dictionary Vietnamese – English & English – Vietnamese'**
  String get dictTitleFull;

  /// No description provided for @dictSearchDirection.
  ///
  /// In en, this message translates to:
  /// **'Lookup direction: {flag} {label}'**
  String dictSearchDirection(Object flag, Object label);

  /// No description provided for @dictViDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected: Vietnamese ➜ Showing equivalent English words'**
  String get dictViDetected;

  /// No description provided for @dictEnDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected: English ➜ Showing Vietnamese meaning & definitions'**
  String get dictEnDetected;

  /// No description provided for @dictAllLevels.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get dictAllLevels;

  /// No description provided for @dictAllTopics.
  ///
  /// In en, this message translates to:
  /// **'All topics'**
  String get dictAllTopics;

  /// No description provided for @dictAllPos.
  ///
  /// In en, this message translates to:
  /// **'All parts of speech'**
  String get dictAllPos;

  /// No description provided for @dictIntroDesc.
  ///
  /// In en, this message translates to:
  /// **'Smart two-way lookup: type Vietnamese to find equivalent English terms, or type English for Vietnamese meanings. Over 3,000+ CEFR A1–C1 words offline with online expansion (Google Translate & Wiktionary cached in SQLite).'**
  String get dictIntroDesc;

  /// No description provided for @dictViEnOnlinePrompt.
  ///
  /// In en, this message translates to:
  /// **'You can expand translation online from Vietnamese ➔ English (automatically fetches equivalent English words, definitions, pronunciation, and caches in SQLite).'**
  String get dictViEnOnlinePrompt;

  /// No description provided for @dictEnViOnlinePrompt.
  ///
  /// In en, this message translates to:
  /// **'You can expand lookup online from English ➔ Vietnamese (Vietnamese meaning, English definitions, pronunciation, and caches in SQLite).'**
  String get dictEnViOnlinePrompt;

  /// No description provided for @dictRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get dictRetry;

  /// No description provided for @dictRetryConnection.
  ///
  /// In en, this message translates to:
  /// **'Retry connection'**
  String get dictRetryConnection;

  /// No description provided for @dictTtsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Standard pronunciation (TTS)'**
  String get dictTtsTooltip;

  /// No description provided for @dictInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get dictInReview;

  /// No description provided for @dictAddToReview.
  ///
  /// In en, this message translates to:
  /// **'Add to Review'**
  String get dictAddToReview;

  /// No description provided for @dictMovedToNew.
  ///
  /// In en, this message translates to:
  /// **'Moved \"{term}\" to new words'**
  String dictMovedToNew(Object term);

  /// No description provided for @dictAddedToReview.
  ///
  /// In en, this message translates to:
  /// **'Added \"{term}\" to Review list!'**
  String dictAddedToReview(Object term);

  /// No description provided for @dictFavoriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Favorite this word'**
  String get dictFavoriteAdd;

  /// No description provided for @dictFavoriteRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get dictFavoriteRemove;

  /// No description provided for @dictLiveApi.
  ///
  /// In en, this message translates to:
  /// **'Online (Live API)'**
  String get dictLiveApi;

  /// No description provided for @dictSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get dictSaved;

  /// No description provided for @dictViKeyword.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese keyword: \"{query}\"'**
  String dictViKeyword(Object query);

  /// No description provided for @dictEquivalentEnWords.
  ///
  /// In en, this message translates to:
  /// **'Equivalent English words:'**
  String get dictEquivalentEnWords;

  /// No description provided for @dictListenTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tap to listen: {word}'**
  String dictListenTooltip(Object word);

  /// No description provided for @dictViRefMeaning.
  ///
  /// In en, this message translates to:
  /// **'Cross-reference Vietnamese meaning: {meaning}'**
  String dictViRefMeaning(Object meaning);

  /// No description provided for @dictViTranslation.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese translation:'**
  String get dictViTranslation;

  /// No description provided for @dictOtherMeanings.
  ///
  /// In en, this message translates to:
  /// **'Other translations:'**
  String get dictOtherMeanings;

  /// No description provided for @dictSourceInfo.
  ///
  /// In en, this message translates to:
  /// **'Source: {source} • License: {license} ({url})'**
  String dictSourceInfo(Object license, Object source, Object url);

  /// No description provided for @dictExamplePrefix.
  ///
  /// In en, this message translates to:
  /// **'Ex: \"{example}\"'**
  String dictExamplePrefix(Object example);

  /// No description provided for @avatarChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get avatarChangePhoto;

  /// No description provided for @avatarSelectFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Choose from device / Gallery'**
  String get avatarSelectFromDevice;

  /// No description provided for @avatarSelectFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter image URL directly'**
  String get avatarSelectFromUrl;

  /// No description provided for @avatarResetDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default avatar'**
  String get avatarResetDefault;

  /// No description provided for @avatarEnterUrlTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter avatar URL'**
  String get avatarEnterUrlTitle;

  /// No description provided for @avatarUrlPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/avatar.jpg'**
  String get avatarUrlPlaceholder;

  /// No description provided for @avatarInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL or not an image'**
  String get avatarInvalidUrl;

  /// No description provided for @skillsSelectSkill.
  ///
  /// In en, this message translates to:
  /// **'Select a skill to practice:'**
  String get skillsSelectSkill;

  /// No description provided for @skillsAllLevels.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get skillsAllLevels;

  /// No description provided for @skillsQuestionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String skillsQuestionsCount(Object count);

  /// No description provided for @skillsExerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String skillsExerciseCount(Object count);

  /// No description provided for @skillsStartPractice.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get skillsStartPractice;

  /// No description provided for @skillsTranscriptLocked.
  ///
  /// In en, this message translates to:
  /// **'Transcript locked'**
  String get skillsTranscriptLocked;

  /// No description provided for @skillsTranscriptUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Listening Transcript'**
  String get skillsTranscriptUnlocked;

  /// No description provided for @skillsSubmitExercise.
  ///
  /// In en, this message translates to:
  /// **'Submit exercise'**
  String get skillsSubmitExercise;

  /// No description provided for @skillsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get skillsCompleted;

  /// No description provided for @skillsScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}/{total}'**
  String skillsScore(Object score, Object total);

  /// No description provided for @skillsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get skillsTryAgain;

  /// No description provided for @skillsNextExercise.
  ///
  /// In en, this message translates to:
  /// **'Next exercise'**
  String get skillsNextExercise;

  /// No description provided for @skillsListenNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal speed 1.0x'**
  String get skillsListenNormal;

  /// No description provided for @skillsListenSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow speed 0.75x'**
  String get skillsListenSlow;

  /// No description provided for @skillsExplanation.
  ///
  /// In en, this message translates to:
  /// **'Detailed explanation'**
  String get skillsExplanation;

  /// No description provided for @skillsMatchingPairs.
  ///
  /// In en, this message translates to:
  /// **'Match words with their meanings'**
  String get skillsMatchingPairs;

  /// No description provided for @skillsSpeakingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Read the following passage aloud'**
  String get skillsSpeakingPrompt;

  /// No description provided for @skillsWritingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Write according to prompt'**
  String get skillsWritingPrompt;

  /// No description provided for @gameDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty: {diff}'**
  String gameDifficulty(Object diff);

  /// No description provided for @gameScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String gameScore(Object score);

  /// No description provided for @gameHighScore.
  ///
  /// In en, this message translates to:
  /// **'High score: {score}'**
  String gameHighScore(Object score);

  /// No description provided for @gameExit.
  ///
  /// In en, this message translates to:
  /// **'Exit game'**
  String get gameExit;

  /// No description provided for @gameCombo.
  ///
  /// In en, this message translates to:
  /// **'Combo x{multiplier}'**
  String gameCombo(Object multiplier);

  /// No description provided for @gameWpm.
  ///
  /// In en, this message translates to:
  /// **'Speed: {wpm} WPM'**
  String gameWpm(Object wpm);

  /// No description provided for @gameStart.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get gameStart;

  /// No description provided for @gamePause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get gamePause;

  /// No description provided for @gameResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get gameResume;

  /// No description provided for @gameRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get gameRestart;

  /// No description provided for @gameLives.
  ///
  /// In en, this message translates to:
  /// **'Lives: {lives}'**
  String gameLives(Object lives);

  /// No description provided for @gameLevel.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String gameLevel(Object level);

  /// No description provided for @examMode.
  ///
  /// In en, this message translates to:
  /// **'Exam mode'**
  String get examMode;

  /// No description provided for @examTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining: {time}'**
  String examTimeRemaining(Object time);

  /// No description provided for @examSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit exam'**
  String get examSubmit;

  /// No description provided for @examPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get examPassed;

  /// No description provided for @examFailed.
  ///
  /// In en, this message translates to:
  /// **'Needs improvement'**
  String get examFailed;

  /// No description provided for @examScoreBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Score breakdown'**
  String get examScoreBreakdown;

  /// No description provided for @examReviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review answers & Explanations'**
  String get examReviewAnswers;

  /// No description provided for @examRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake exam'**
  String get examRetake;

  /// No description provided for @examBackToHub.
  ///
  /// In en, this message translates to:
  /// **'Back to Exam Hub'**
  String get examBackToHub;

  /// No description provided for @shadowingListen1.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Listen model (1.0x)'**
  String get shadowingListen1;

  /// No description provided for @shadowingListen2.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Listen slow (0.75x)'**
  String get shadowingListen2;

  /// No description provided for @shadowingRecord.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Shadow the audio'**
  String get shadowingRecord;

  /// No description provided for @shadowingStop.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get shadowingStop;

  /// No description provided for @shadowingSelfEval.
  ///
  /// In en, this message translates to:
  /// **'Step 4: Self evaluation'**
  String get shadowingSelfEval;

  /// No description provided for @shadowingNext.
  ///
  /// In en, this message translates to:
  /// **'Next sentence'**
  String get shadowingNext;

  /// No description provided for @shadowingComplete.
  ///
  /// In en, this message translates to:
  /// **'Shadowing practice completed!'**
  String get shadowingComplete;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authRegister;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get authNoAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get authLogout;

  /// No description provided for @authLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get authLogoutConfirm;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEdit;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save Profile Changes'**
  String get profileSave;

  /// No description provided for @profileDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileDisplayName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRole;

  /// No description provided for @profileJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined Date'**
  String get profileJoined;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'System Administration (Admin)'**
  String get adminTitle;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'Users & Levels'**
  String get adminUsers;

  /// No description provided for @adminVocab.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary & Topics'**
  String get adminVocab;

  /// No description provided for @adminExercises.
  ///
  /// In en, this message translates to:
  /// **'Reading & Listening'**
  String get adminExercises;

  /// No description provided for @adminExams.
  ///
  /// In en, this message translates to:
  /// **'Practice Exams'**
  String get adminExams;

  /// No description provided for @adminSystem.
  ///
  /// In en, this message translates to:
  /// **'System Monitoring'**
  String get adminSystem;

  /// No description provided for @adminForbidden.
  ///
  /// In en, this message translates to:
  /// **'Admin Only Area (403 Forbidden)'**
  String get adminForbidden;

  /// No description provided for @adminRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh admin data'**
  String get adminRefresh;

  /// No description provided for @aiChatAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get aiChatAsk;

  /// settingsSelectLanguage
  ///
  /// In en, this message translates to:
  /// **'Select App Language'**
  String get settingsSelectLanguage;

  /// settingsSearchLanguage
  ///
  /// In en, this message translates to:
  /// **'Search language...'**
  String get settingsSearchLanguage;

  /// settingsAllLanguages
  ///
  /// In en, this message translates to:
  /// **'See all 13 languages'**
  String get settingsAllLanguages;

  /// settingsAllLanguagesSubtitle
  ///
  /// In en, this message translates to:
  /// **'Chinese, Japanese, Korean, French, German, Spanish, Russian...'**
  String get settingsAllLanguagesSubtitle;

  /// settingsDefaultBadge
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingsDefaultBadge;

  /// No description provided for @profileUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Login Username'**
  String get profileUsernameLabel;

  /// No description provided for @profileUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter username (3–30 chars: a-z, 0-9, ., _, -)'**
  String get profileUsernameHint;

  /// No description provided for @profileUsernameHelperPassword.
  ///
  /// In en, this message translates to:
  /// **'You can sign in using either this username or your email with your password.'**
  String get profileUsernameHelperPassword;

  /// No description provided for @profileUsernameHelperGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google accounts continue signing in with Google; this username serves as your unique account handle.'**
  String get profileUsernameHelperGoogle;

  /// No description provided for @profileEmailReadOnlyHelper.
  ///
  /// In en, this message translates to:
  /// **'Login email (read-only, unchanged when updating display name or username)'**
  String get profileEmailReadOnlyHelper;

  /// No description provided for @weeklyProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgressTitle;

  /// No description provided for @weeklyProgressActiveDays.
  ///
  /// In en, this message translates to:
  /// **'{count}/7 active days'**
  String weeklyProgressActiveDays(int count);

  /// No description provided for @weeklyProgressWordsStudied.
  ///
  /// In en, this message translates to:
  /// **'{count} words studied/reviewed'**
  String weeklyProgressWordsStudied(int count);

  /// No description provided for @weeklyProgressActivitiesDone.
  ///
  /// In en, this message translates to:
  /// **'{count} activities completed'**
  String weeklyProgressActivitiesDone(int count);

  /// No description provided for @weeklyProgressTodayGoal.
  ///
  /// In en, this message translates to:
  /// **'Today word goal: {current}/{goal} words'**
  String weeklyProgressTodayGoal(int current, int goal);

  /// No description provided for @weeklyProgressTodayBadge.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get weeklyProgressTodayBadge;

  /// No description provided for @weeklyProgressEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No learning activity recorded this week yet'**
  String get weeklyProgressEmptyTitle;

  /// No description provided for @weeklyProgressEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Study or review vocabulary, complete a quiz, or practice skills to see your weekly chart update immediately!'**
  String get weeklyProgressEmptyDesc;

  /// No description provided for @weeklyProgressStartCta.
  ///
  /// In en, this message translates to:
  /// **'Review vocabulary now'**
  String get weeklyProgressStartCta;

  /// No description provided for @weeklyProgressScopeNote.
  ///
  /// In en, this message translates to:
  /// **'Tracks real timestamped learning events for the current account (Monday – Sunday in local time).'**
  String get weeklyProgressScopeNote;

  /// No description provided for @weeklyProgressUnitWords.
  ///
  /// In en, this message translates to:
  /// **'words'**
  String get weeklyProgressUnitWords;

  /// No description provided for @weeklyProgressUnitActivities.
  ///
  /// In en, this message translates to:
  /// **'acts'**
  String get weeklyProgressUnitActivities;

  /// No description provided for @aiChatErrorGeneral.
  ///
  /// In en, this message translates to:
  /// **'Unable to receive AI response'**
  String get aiChatErrorGeneral;

  /// Success message shown after registration prompting user to sign in
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please log in to continue.'**
  String get authRegisterSuccessPleaseLogin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'th',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
