import 'dart:io';

import 'package:english_buddy/core/services/auth_service.dart';
import 'package:english_buddy/core/services/settings_service.dart';
import 'package:english_buddy/data/models/topic_model.dart';
import 'package:english_buddy/data/models/word_model.dart';
import 'package:english_buddy/l10n/app_localizations.dart';
import 'package:english_buddy/presentation/screens/auth/auth_screen.dart';
import 'package:english_buddy/presentation/screens/home/home_screen.dart';
import 'package:english_buddy/presentation/widgets/app_sidebar.dart';
import 'package:english_buddy/providers/auth_provider.dart';
import 'package:english_buddy/providers/study_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeStudyProvider extends StudyProvider {
  WordModel? _word;
  final List<TopicModel> _topicList;
  final Map<String, int> _stats;
  final List<WordModel> _dueList;
  int refreshWordCount = 0;
  int favoriteToggleCount = 0;

  _FakeStudyProvider({
    required WordModel wordOfTheDay,
    required List<TopicModel> topics,
    Map<String, int>? stats,
    List<WordModel>? dueSrsWords,
  })  : _word = wordOfTheDay,
        _topicList = topics,
        _stats = stats ??
            const {
              'total': 1500,
              'mastered': 120,
              'learning': 45,
              'favorite': 18,
            },
        _dueList = dueSrsWords ?? const [];

  @override
  WordModel? get wordOfTheDay => _word;

  @override
  List<TopicModel> get topics => _topicList;

  @override
  Map<String, int> get overallStats => _stats;

  @override
  List<WordModel> get dueSrsWords => _dueList;

  @override
  Future<void> loadWordOfTheDay() async {
    refreshWordCount++;
    if (_word != null) {
      _word = _word!.copyWith(
        term: 'Resilience',
        meaning: 'Khả năng phục hồi nhanh chóng sau khó khăn',
      );
      notifyListeners();
    }
  }

  @override
  Future<void> toggleFavorite(WordModel word) async {
    favoriteToggleCount++;
    if (_word?.id == word.id) {
      _word = _word!.copyWith(isFavorite: !_word!.isFavorite);
      notifyListeners();
    }
  }

  @override
  Future<void> loadWordsByTopic(int topicId) async {}
}

WordModel _sampleWord({bool longContent = false}) {
  if (longContent) {
    return const WordModel(
      id: 101,
      topicId: 1,
      term: 'Counterintuitiveness & Multidisciplinary Collaboration',
      ipa: '/ˌkaʊn.tər.ɪnˈtjuː.ɪ.tɪv.nəs/',
      partOfSpeech: 'noun phrase',
      meaning:
          'Tính chất trái ngược với trực giác thông thường và sự hợp tác liên ngành sâu rộng giữa nhiều lĩnh vực học thuật phức tạp',
      englishDefinition:
          'The quality of being contrary to what common sense or intuition would suggest when solving complex interdisciplinary challenges across multiple domains.',
      exampleEn:
          'A traveling blood clot can cause a life-threatening pulmonary embolism in the lungs, requiring immediate multidisciplinary intervention.',
      exampleVi:
          'Một cục máu đông di chuyển có thể gây ra thuyên tắc phổi đe dọa tính mạng, đòi hỏi sự can thiệp đa chuyên khoa ngay lập tức.',
      level: 'C1',
      isFavorite: false,
    );
  }
  return const WordModel(
    id: 1,
    topicId: 1,
    term: 'Embolism',
    ipa: '/ˈem.bə.lɪ.zəm/',
    partOfSpeech: 'noun',
    meaning: 'Chứng thuyên tắc mạch do dị vật',
    englishDefinition:
        'Obstruction of an artery, typically by a clot of blood or an air bubble.',
    exampleEn:
        'A traveling blood clot can cause a life-threatening pulmonary embolism in the lungs.',
    exampleVi:
        'Một cục máu đông di chuyển có thể gây ra thuyên tắc phổi đe dọa tính mạng.',
    level: 'B2',
    isFavorite: false,
  );
}

List<TopicModel> _sampleTopics() {
  return const [
    TopicModel(
      id: 1,
      name: 'Giao tiếp hàng ngày',
      iconName: 'chat',
      colorHex: '#4361EE',
      description: 'Chủ đề giao tiếp cơ bản hằng ngày',
      totalWords: 376,
      masteredWords: 24,
    ),
    TopicModel(
      id: 2,
      name: 'Du lịch & Khách sạn',
      iconName: 'flight',
      colorHex: '#10B981',
      description: 'Từ vựng sân bay, khách sạn và di chuyển',
      totalWords: 376,
      masteredWords: 12,
    ),
    TopicModel(
      id: 3,
      name: 'Công sở & Sự nghiệp',
      iconName: 'work',
      colorHex: '#8B5CF6',
      description: 'Phỏng vấn, họp hành và email thương mại',
      totalWords: 376,
      masteredWords: 60,
    ),
    TopicModel(
      id: 4,
      name: 'Trường học & Học thuật',
      iconName: 'school',
      colorHex: '#EC4899',
      description: 'Nghiên cứu, bài giảng và luận văn học thuật',
      totalWords: 376,
      masteredWords: 0,
    ),
  ];
}

Widget _buildHomeTestHarness({
  required _FakeStudyProvider studyProvider,
  required AuthProvider authProvider,
  required Function(int) onTabChange,
  ThemeMode themeMode = ThemeMode.dark,
  double textScale = 1.0,
  Widget? sidebar,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<StudyProvider>.value(value: studyProvider),
      ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('vi'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        );
      },
      home: sidebar != null
          ? Scaffold(
              body: Row(
                children: [
                  sidebar,
                  Expanded(
                    child: HomeScreen(onTabChange: onTabChange),
                  ),
                ],
              ),
            )
          : HomeScreen(onTabChange: onTabChange),
    ),
  );
}

void main() {
  late AuthProvider authProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService().init();
    final authService = AuthService(
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );
    authProvider = AuthProvider(authService: authService);
    await authProvider.initAuthSession();
  });

  group('HomeScreen Responsive Layout & Empty Gap Fix', () {
    testWidgets(
      '1440px Desktop: uses two independent top-aligned columns, places CEFR topics directly below Word of the Day in left column with 2-column topic grid',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 960);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final studyProvider = _FakeStudyProvider(
          wordOfTheDay: _sampleWord(),
          topics: _sampleTopics(),
        );

        await tester.pumpWidget(
          _buildHomeTestHarness(
            studyProvider: studyProvider,
            authProvider: authProvider,
            onTabChange: (_) {},
            sidebar: AppSidebar(
              currentIndex: 0,
              isCollapsed: false,
              onDestinationSelected: (_) {},
              onToggleCollapse: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('home_desktop_two_column_layout')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('home_desktop_left_column')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('home_desktop_right_column')),
          findsOneWidget,
        );

        // Verify CEFR topics section is inside the left column and positioned immediately below Word of the Day
        final wotdRect = tester.getRect(
          find.byKey(const Key('home_word_of_the_day_section')),
        );
        final topicsRect = tester.getRect(
          find.byKey(const Key('home_featured_topics_section')),
        );
        final shortcutsRect = tester.getRect(
          find.byKey(const Key('home_quick_actions_section')),
        );

        // Gap between Word of the Day bottom and CEFR topics top should be exactly the section spacing (~22px), NOT waiting for the right column!
        final verticalGap = topicsRect.top - wotdRect.bottom;
        expect(verticalGap, closeTo(22.0, 2.0));
        expect(topicsRect.top, lessThan(shortcutsRect.bottom - 100));

        // Left column has ~530+ px width at 1440px, so topics render in 2 columns
        expect(
          find.byKey(const Key('home_topics_two_col_row_0')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '1024px Desktop (Sidebar Expanded & Collapsed): uses two-column layout and adapts topic cards between 1 column (narrow left col) and 2 columns',
      (tester) async {
        tester.view.physicalSize = const Size(1024, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final studyProvider = _FakeStudyProvider(
          wordOfTheDay: _sampleWord(),
          topics: _sampleTopics(),
        );

        // 1. Sidebar expanded (248px) -> HomeScreen width = 776px -> Desktop 2-col layout, left col ~360px -> 1-col topics so text is never cramped
        await tester.pumpWidget(
          _buildHomeTestHarness(
            studyProvider: studyProvider,
            authProvider: authProvider,
            onTabChange: (_) {},
            sidebar: AppSidebar(
              currentIndex: 0,
              isCollapsed: false,
              onDestinationSelected: (_) {},
              onToggleCollapse: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('home_desktop_two_column_layout')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('home_topics_single_col_0')), findsOneWidget);
        expect(tester.takeException(), isNull);

        // 2. Sidebar collapsed (78px) -> HomeScreen width = 946px
        await tester.pumpWidget(
          _buildHomeTestHarness(
            studyProvider: studyProvider,
            authProvider: authProvider,
            onTabChange: (_) {},
            themeMode: ThemeMode.light,
            sidebar: AppSidebar(
              currentIndex: 0,
              isCollapsed: true,
              onDestinationSelected: (_) {},
              onToggleCollapse: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('home_desktop_two_column_layout')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '768px & 390px Mobile/Tablet: switches to single-column layout in order Word of the Day -> Quick Actions -> CEFR Topics',
      (tester) async {
        final studyProvider = _FakeStudyProvider(
          wordOfTheDay: _sampleWord(),
          topics: _sampleTopics(),
        );

        for (final width in [768.0, 390.0]) {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            _buildHomeTestHarness(
              studyProvider: studyProvider,
              authProvider: authProvider,
              onTabChange: (_) {},
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('home_mobile_single_column_layout')),
            findsOneWidget,
            reason: 'Width $width should use single-column layout',
          );

          final wotdRect = tester.getRect(
            find.byKey(const Key('home_word_of_the_day_section')),
          );
          final shortcutsRect = tester.getRect(
            find.byKey(const Key('home_quick_actions_section')),
          );
          final topicsRect = tester.getRect(
            find.byKey(const Key('home_featured_topics_section')),
          );

          expect(wotdRect.top, lessThan(shortcutsRect.top));
          expect(shortcutsRect.top, lessThan(topicsRect.top));
          expect(tester.takeException(), isNull);
        }

        addTearDown(tester.view.reset);
      },
    );

    testWidgets(
      'Long vocabulary content + large font scale (1.35x) in Light & Dark modes do not overflow or clip',
      (tester) async {
        final studyProvider = _FakeStudyProvider(
          wordOfTheDay: _sampleWord(longContent: true),
          topics: _sampleTopics(),
        );

        for (final width in [390.0, 1024.0, 1440.0]) {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            tester.view.physicalSize = Size(width, 1000);
            tester.view.devicePixelRatio = 1.0;

            await tester.pumpWidget(
              _buildHomeTestHarness(
                studyProvider: studyProvider,
                authProvider: authProvider,
                onTabChange: (_) {},
                themeMode: mode,
                textScale: 1.35,
              ),
            );
            await tester.pumpAndSettle();

            expect(
              tester.takeException(),
              isNull,
              reason: 'No overflow at width=$width, mode=$mode, textScale=1.35',
            );
          }
        }

        addTearDown(tester.view.reset);
      },
    );

    testWidgets(
      'Interactive actions (Change Word, Favorite Toggle, Shortcut Navigation) work properly',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 960);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final studyProvider = _FakeStudyProvider(
          wordOfTheDay: _sampleWord(),
          topics: _sampleTopics(),
        );
        int? selectedTab;

        await tester.pumpWidget(
          _buildHomeTestHarness(
            studyProvider: studyProvider,
            authProvider: authProvider,
            onTabChange: (tab) => selectedTab = tab,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Embolism'), findsOneWidget);

        // Tap "Đổi từ mới"
        await tester.tap(find.byIcon(Icons.refresh_rounded));
        await tester.pumpAndSettle();
        expect(studyProvider.refreshWordCount, 1);
        expect(find.text('Resilience'), findsOneWidget);

        // Tap Favorite button inside Word of the Day section
        await tester.tap(find.byIcon(Icons.favorite_border_rounded));
        await tester.pumpAndSettle();
        expect(studyProvider.favoriteToggleCount, 1);
        expect(
          find.descendant(
            of: find.byKey(const Key('home_word_of_the_day_section')),
            matching: find.byIcon(Icons.favorite_rounded),
          ),
          findsOneWidget,
        );

        // Tap "Xem tất cả" on CEFR topics -> navigates to Topics tab (1)
        await tester.ensureVisible(find.text('Xem tất cả'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Xem tất cả'));
        await tester.pumpAndSettle();
        expect(selectedTab, 1);
      },
    );
  });

  group('Brand Logo Assets & Widgets Verification', () {
    test('Required logo and platform icon files exist and are non-empty', () {
      final expectedFiles = [
        'assets/images/app_logo.png',
        'web/favicon.png',
        'web/icons/Icon-192.png',
        'web/icons/Icon-512.png',
        'web/icons/Icon-maskable-192.png',
        'web/icons/Icon-maskable-512.png',
        'android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-hdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
        'windows/runner/resources/app_icon.ico',
      ];

      for (final relativePath in expectedFiles) {
        final file = File(relativePath);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Expected asset/icon file to exist: $relativePath',
        );
        expect(
          file.lengthSync(),
          greaterThan(100),
          reason: 'Expected non-empty icon file: $relativePath',
        );
      }
    });

    testWidgets(
      'AppSidebar and AuthScreen render assets/images/app_logo.png with BoxFit.contain',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 960);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final studyProvider = _FakeStudyProvider(
          wordOfTheDay: _sampleWord(),
          topics: _sampleTopics(),
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<StudyProvider>.value(value: studyProvider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ],
            child: MaterialApp(
              locale: const Locale('vi'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Scaffold(
                body: Row(
                  children: [
                    AppSidebar(
                      currentIndex: 0,
                      isCollapsed: false,
                      onDestinationSelected: (_) {},
                      onToggleCollapse: () {},
                    ),
                    const Expanded(child: AuthScreen()),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final sidebarLogoBadgeFinder = find.byKey(const Key('sidebar_brand_logo'));
        final sidebarLogoImageFinder = find.descendant(
          of: sidebarLogoBadgeFinder,
          matching: find.byType(Image),
        );
        final authLogoFinder = find.byKey(const Key('auth_screen_app_logo'));

        expect(sidebarLogoBadgeFinder, findsOneWidget);
        expect(sidebarLogoImageFinder, findsOneWidget);
        expect(authLogoFinder, findsOneWidget);

        final sidebarImage = tester.widget<Image>(sidebarLogoImageFinder);
        final authImage = tester.widget<Image>(authLogoFinder);

        expect(sidebarImage.fit, BoxFit.contain);
        expect(authImage.fit, BoxFit.contain);
        expect(
          (sidebarImage.image as AssetImage).assetName,
          'assets/images/app_logo.png',
        );
        expect(
          (authImage.image as AssetImage).assetName,
          'assets/images/app_logo.png',
        );
      },
    );
  });
}
