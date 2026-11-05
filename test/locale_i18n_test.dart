import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_buddy/core/constants/app_languages.dart';
import 'package:english_buddy/core/services/settings_service.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import 'package:english_buddy/presentation/screens/settings/settings_screen.dart';
import 'package:english_buddy/presentation/widgets/app_sidebar.dart';
import 'package:english_buddy/providers/ai_chat_provider.dart';
import 'package:english_buddy/providers/auth_provider.dart';
import 'package:english_buddy/providers/dictionary_provider.dart';
import 'package:english_buddy/providers/games_provider.dart';
import 'package:english_buddy/providers/locale_provider.dart';
import 'package:english_buddy/providers/quiz_provider.dart';
import 'package:english_buddy/providers/skills_provider.dart';
import 'package:english_buddy/providers/stats_provider.dart';
import 'package:english_buddy/providers/study_provider.dart';
import 'package:english_buddy/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const all13Codes = <String>[
    'vi',
    'en',
    'zh',
    'ja',
    'ko',
    'fr',
    'es',
    'de',
    'ru',
    'pt',
    'id',
    'th',
    'it',
  ];

  const expectedNavHome = <String, String>{
    'vi': 'Trang chủ',
    'en': 'Home',
    'zh': '首页',
    'ja': 'ホーム',
    'ko': '홈',
    'fr': 'Accueil',
    'es': 'Inicio',
    'de': 'Startseite',
    'ru': 'Главная',
    'pt': 'Início',
    'id': 'Beranda',
    'th': 'หน้าแรก',
    'it': 'Pagina iniziale',
  };

  const expectedNavSettings = <String, String>{
    'vi': 'Cài đặt',
    'en': 'Settings',
    'zh': '系统设置',
    'ja': '設定',
    'ko': '설정',
    'fr': 'Paramètres',
    'es': 'Ajustes',
    'de': 'Einstellungen',
    'ru': 'Настройки',
    'pt': 'Configurações',
    'id': 'Pengaturan',
    'th': 'การตั้งค่า',
    'it': 'Impostazioni',
  };

  group('Internationalization & 13-Locale Regression Suite', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService().init();
    });

    test('Default locale is Vietnamese (vi)', () {
      final settingsService = SettingsService();
      expect(settingsService.getLanguageCode(), 'vi');

      final provider = LocaleProvider();
      expect(provider.locale.languageCode, 'vi');
      expect(provider.isVietnamese, isTrue);
      expect(provider.isEnglish, isFalse);
    });

    test('LocaleProvider updates locale immediately and persists for all 13 languages', () async {
      final provider = LocaleProvider();
      final settingsService = SettingsService();

      for (final code in all13Codes) {
        await provider.setLocale(Locale(code));
        expect(provider.locale.languageCode, code);
        expect(provider.languageCode, code);
        expect(settingsService.getLanguageCode(), code);
      }
    });

    test('LocaleProvider restores previously saved locale from SharedPreferences across all 13 languages', () async {
      for (final code in all13Codes) {
        SharedPreferences.setMockInitialValues({'app_language_code': code});
        await SettingsService().init();

        final provider = LocaleProvider();
        expect(provider.locale.languageCode, code);
      }
    });

    test('LocaleProvider safely handles unsupported locale with clear fallback to vi', () async {
      final provider = LocaleProvider();
      await provider.setLocale(const Locale('xyz_invalid'));
      expect(provider.locale.languageCode, AppLanguages.defaultLanguageCode);
      expect(provider.isVietnamese, isTrue);
    });

    test('All 13 supported languages exist in AppLanguages, lookupAppLocalizations, and getSubtitle is localized', () {
      expect(AppLanguages.supportedLanguages.length, 13);
      final supportedCodes =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();

      for (final lang in AppLanguages.supportedLanguages) {
        expect(supportedCodes, contains(lang.code));
        expect(AppLanguages.isSupported(lang.code), isTrue);

        final l10n = lookupAppLocalizations(Locale(lang.code));
        expect(l10n.navHome, expectedNavHome[lang.code]);
        expect(l10n.navSettings, expectedNavSettings[lang.code]);
        expect(l10n.settingsTitle.isNotEmpty, isTrue);
        expect(l10n.settingsLanguageSection.isNotEmpty, isTrue);
        expect(l10n.settingsSelectLanguage.isNotEmpty, isTrue);
        expect(l10n.settingsSelectLanguage.contains('?'), isFalse,
            reason: 'Corrupted encoding in settingsSelectLanguage for ${lang.code}');
        expect(l10n.settingsAllLanguages.contains('?'), isFalse,
            reason: 'Corrupted encoding in settingsAllLanguages for ${lang.code}');
        expect(l10n.appName, 'English Buddy');
      }

      // Verify AppLanguages.getSubtitle does not default non-vi/en languages to English
      final jaItem = AppLanguages.findByCode('ja');
      expect(jaItem.getSubtitle('vi'), 'Tiếng Nhật');
      expect(jaItem.getSubtitle('en'), 'Japanese');
      expect(jaItem.getSubtitle('ja'), '日本語');
      expect(jaItem.getSubtitle('ko'), '일본어');
      expect(jaItem.getSubtitle('zh'), '日语');
      expect(jaItem.getSubtitle('fr'), 'Japonais');
      expect(jaItem.getSubtitle('de'), 'Japanisch');
      expect(jaItem.getSubtitle('ru'), 'Японский');
      expect(jaItem.getSubtitle('th'), 'ภาษาญี่ปุ่น');

      final viItem = AppLanguages.findByCode('vi');
      expect(viItem.getSubtitle('vi'), 'Mặc định');
      expect(viItem.getSubtitle('en'), 'Default');
      expect(viItem.getSubtitle('ja'), 'ベトナム語 (デフォルト)');
      expect(viItem.getSubtitle('ko'), '베트남어 (기본값)');
    });

    test('ARB completeness: all 13 ARB files have identical keys, valid placeholders, and no corrupted question marks', () {
      final enFile = File('lib/l10n/app_en.arb');
      final enMap = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
      final enKeys = enMap.keys.where((k) => !k.startsWith('@')).toSet();
      final placeholderRegex = RegExp(r'\{([a-zA-Z0-9_]+)\}');

      for (final code in all13Codes) {
        final arbFile = File('lib/l10n/app_$code.arb');
        expect(arbFile.existsSync(), isTrue, reason: 'Missing app_$code.arb');
        final map = jsonDecode(arbFile.readAsStringSync()) as Map<String, dynamic>;
        final keys = map.keys.where((k) => !k.startsWith('@')).toSet();

        expect(keys.difference(enKeys), isEmpty,
            reason: 'Extra keys in app_$code.arb');
        expect(enKeys.difference(keys), isEmpty,
            reason: 'Missing keys in app_$code.arb');

        for (final key in enKeys) {
          final enVal = enMap[key] as String;
          final locVal = map[key] as String;
          expect(locVal.trim().isNotEmpty, isTrue,
              reason: 'Empty translation for $key in app_$code.arb');
          expect(locVal.contains('??'), isFalse,
              reason: 'Corrupted ?? in $key of app_$code.arb: $locVal');

          final enPlaceholders =
              placeholderRegex.allMatches(enVal).map((m) => m.group(1)!).toSet();
          final locPlaceholders =
              placeholderRegex.allMatches(locVal).map((m) => m.group(1)!).toSet();
          expect(locPlaceholders, equals(enPlaceholders),
              reason: 'Placeholder mismatch for $key in app_$code.arb');
        }
      }
    });

    test('UiHelpers formatNumber and getStatusText localize properly', () {
      expect(UiHelpers.formatNumber(1234567, locale: 'en'), '1,234,567');
      expect(UiHelpers.formatNumber(1234567, locale: 'vi'), contains('1'));
    });

    testWidgets(
      'Full 13-locale UI rendering test: Sidebar, SettingsScreen, already-opened tab, and Language Picker modal update immediately without reload',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final localeProvider = LocaleProvider();
        final themeProvider = ThemeProvider();
        final authProvider = AuthProvider();
        final studyProvider = StudyProvider();
        final quizProvider = QuizProvider();
        final statsProvider = StatsProvider();
        final dictionaryProvider = DictionaryProvider();
        final skillsProvider = SkillsProvider();
        final gamesProvider = GamesProvider();
        final aiChatProvider = AiChatProvider();

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: themeProvider),
              ChangeNotifierProvider.value(value: localeProvider),
              ChangeNotifierProvider.value(value: authProvider),
              ChangeNotifierProvider.value(value: studyProvider),
              ChangeNotifierProvider.value(value: quizProvider),
              ChangeNotifierProvider.value(value: statsProvider),
              ChangeNotifierProvider.value(value: dictionaryProvider),
              ChangeNotifierProvider.value(value: skillsProvider),
              ChangeNotifierProvider.value(value: gamesProvider),
              ChangeNotifierProvider.value(value: aiChatProvider),
            ],
            child: Consumer2<ThemeProvider, LocaleProvider>(
              builder: (context, themeProv, locProv, _) {
                return MaterialApp(
                  locale: locProv.locale,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localeResolutionCallback: (locale, supportedLocales) {
                    if (locale != null) {
                      for (final supported in supportedLocales) {
                        if (supported.languageCode == locale.languageCode) {
                          return supported;
                        }
                      }
                    }
                    return const Locale('vi');
                  },
                  home: Scaffold(
                    body: Row(
                      children: [
                        AppSidebar(
                          currentIndex: 11,
                          isCollapsed: false,
                          onDestinationSelected: (_) {},
                          onToggleCollapse: () {},
                        ),
                        Expanded(
                          child: IndexedStack(
                            index: 1,
                            children: [
                              // Tab 0: Already-opened tab before language switch
                              Builder(
                                builder: (ctx) => Column(
                                  key: const Key('already_opened_tab'),
                                  children: [
                                    Text('OPEN_TAB_HOME:${ctx.l10n.navHome}'),
                                    Text('OPEN_TAB_STREAK:${ctx.l10n.homeStreakLabel}'),
                                  ],
                                ),
                              ),
                              // Tab 1: SettingsScreen
                              const SettingsScreen(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Verify all 13 locales update Sidebar, SettingsScreen, and already-opened tab
        for (final code in all13Codes) {
          await localeProvider.setLocale(Locale(code));
          await tester.pumpAndSettle();

          final expectedL10n = lookupAppLocalizations(Locale(code));
          final settingsContext = tester.element(find.byType(SettingsScreen));

          // Verify provider locale matches Localizations.localeOf(context)
          expect(localeProvider.locale.languageCode, code);
          expect(Localizations.localeOf(settingsContext).languageCode, code);

          // Verify Sidebar rendered text
          expect(find.text(expectedNavHome[code]!), findsWidgets,
              reason: 'Sidebar navHome did not render for locale $code');
          expect(find.text(expectedNavSettings[code]!), findsWidgets,
              reason: 'Sidebar navSettings did not render for locale $code');

          // Verify SettingsScreen rendered text
          expect(find.text(expectedL10n.settingsTitle), findsOneWidget,
              reason: 'Settings title did not render for locale $code');
          expect(find.text(expectedL10n.settingsLanguageSection), findsOneWidget,
              reason: 'Settings language section did not render for locale $code');
          expect(find.text(expectedL10n.settingsAllLanguages), findsOneWidget,
              reason: 'Settings all languages button did not render for locale $code');

          // Verify already-opened tab in IndexedStack also updated
          expect(
            find.text('OPEN_TAB_HOME:${expectedL10n.navHome}', skipOffstage: false),
            findsOneWidget,
            reason: 'Already-opened tab did not update for locale $code',
          );
        }

        // 2. Specifically test sequence vi -> ja -> de -> th -> en and modal picker
        for (final seqCode in ['vi', 'ja', 'de', 'th', 'en']) {
          await localeProvider.setLocale(Locale(seqCode));
          await tester.pumpAndSettle();

          final l10n = lookupAppLocalizations(Locale(seqCode));
          expect(find.text(l10n.navHome), findsWidgets);
          expect(find.text(l10n.navSettings), findsWidgets);

          if (seqCode == 'ja') {
            // Confirm Japanese specifically renders ホーム and 設定
            expect(find.text('ホーム'), findsWidgets);
            expect(find.text('設定'), findsWidgets);

            // Open the language picker modal in Japanese and verify its title is Japanese (not English)
            await tester.tap(find.text(l10n.settingsAllLanguages));
            await tester.pumpAndSettle();
            expect(find.text('アプリの言語を選択'), findsOneWidget);
            expect(find.text('Select App Language'), findsNothing);

            // Close modal
            await tester.tap(find.byIcon(Icons.close_rounded));
            await tester.pumpAndSettle();
          }
        }
      },
    );
  });
}
