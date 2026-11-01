import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/database/database_helper.dart';
import 'core/services/settings_service.dart';
import 'core/services/tts_service.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'providers/ai_chat_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/dictionary_provider.dart';
import 'providers/games_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/skills_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/study_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo an toàn Settings, Database và TTS
  try {
    await SettingsService().init();
  } catch (e) {
    debugPrint('Settings initialization notice: $e');
  }

  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint('Database initialization warning: $e');
  }

  try {
    await TtsService().init();
  } catch (e) {
    debugPrint('TTS initialization warning: $e');
  }

  runApp(const EnglishBuddyApp());
}

class EnglishBuddyApp extends StatelessWidget {
  const EnglishBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StudyProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StatsProvider()..loadStats(),
        ),
        ChangeNotifierProvider(
          create: (_) => DictionaryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SkillsProvider()..loadSkillScores(),
        ),
        ChangeNotifierProvider(
          create: (_) => GamesProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initAuthSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => AiChatProvider()..init(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final fontFamily = GoogleFonts.plusJakartaSans().fontFamily;

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            // THEME SÁNG (LIGHT)
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: fontFamily,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                surface: Colors.white,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: AppColors.background,
              cardColor: Colors.white,
              dividerColor: AppColors.border,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: false,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.white,
                indicatorColor: AppColors.primaryContainer,
                elevation: 0,
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary);
                  }
                  return const TextStyle(fontSize: 12, color: AppColors.textSecondary);
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(color: AppColors.primary);
                  }
                  return const IconThemeData(color: AppColors.textSecondary);
                }),
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
              ),
              tooltipTheme: TooltipThemeData(
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.background,
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            // THEME TỐI (DARK)
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: fontFamily,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primaryLight,
                secondary: AppColors.secondary,
                surface: AppColors.darkSurface,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: AppColors.darkBackground,
              cardColor: AppColors.darkCard,
              dividerColor: AppColors.darkBorder,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.darkSurface,
                foregroundColor: AppColors.darkTextPrimary,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: false,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: AppColors.darkSurface,
                indicatorColor: AppColors.darkPrimaryContainer,
                elevation: 0,
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryLight);
                  }
                  return const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary);
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(color: AppColors.primaryLight);
                  }
                  return const IconThemeData(color: AppColors.darkTextSecondary);
                }),
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: AppColors.darkCard,
                surfaceTintColor: Colors.transparent,
              ),
              tooltipTheme: TooltipThemeData(
                decoration: BoxDecoration(
                  color: AppColors.darkCardHover,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                textStyle: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.darkCard,
                hintStyle: const TextStyle(color: AppColors.darkTextMuted, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                ),
              ),
            ),
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
