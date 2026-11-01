import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:english_buddy/core/constants/app_colors.dart';
import 'package:english_buddy/core/constants/app_constants.dart';
import 'package:english_buddy/core/services/anti_bot_service.dart';
import 'package:english_buddy/core/services/auth_service.dart';
import 'package:english_buddy/data/models/word_model.dart';
import 'package:english_buddy/presentation/screens/admin/admin_screen.dart';
import 'package:english_buddy/presentation/screens/auth/auth_screen.dart';
import 'package:english_buddy/presentation/screens/chat/ai_chat_screen.dart';
import 'package:english_buddy/presentation/screens/home/home_screen.dart';
import 'package:english_buddy/presentation/screens/main_navigation_screen.dart';
import 'package:english_buddy/presentation/screens/profile/profile_screen.dart';
import 'package:english_buddy/presentation/screens/skills/games_hub_screen.dart';
import 'package:english_buddy/presentation/screens/dictionary/dictionary_screen.dart';
import 'package:english_buddy/presentation/screens/games/space_typer_screen.dart';
import 'package:english_buddy/presentation/screens/games/common/game_difficulty.dart';
import 'package:english_buddy/presentation/screens/games/space_typer/logic/space_game_engine.dart';
import 'package:english_buddy/presentation/screens/games/space_typer/rendering/space_game_painter.dart';
import 'package:english_buddy/presentation/screens/games/vocabulary_arena_screen.dart';
import 'package:english_buddy/presentation/screens/games/word_rain_screen.dart';
import 'package:english_buddy/presentation/widgets/app_sidebar.dart';
import 'package:english_buddy/presentation/widgets/custom_button.dart';
import 'package:english_buddy/presentation/widgets/interactive_card.dart';
import 'package:english_buddy/presentation/widgets/stat_card.dart';
import 'package:english_buddy/presentation/widgets/word_card_tile.dart';
import 'package:english_buddy/providers/ai_chat_provider.dart';
import 'package:english_buddy/providers/auth_provider.dart';
import 'package:english_buddy/providers/dictionary_provider.dart';
import 'package:english_buddy/providers/games_provider.dart';
import 'package:english_buddy/providers/study_provider.dart';
import 'package:english_buddy/providers/theme_provider.dart';

void main() {
  testWidgets('CustomButton renders text and triggers callback', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Bắt đầu',
            icon: Icons.play_arrow,
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Bắt đầu'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tester.tap(find.text('Bắt đầu'));
    expect(tapped, true);
  });

  testWidgets('StatCard displays title, value and icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatCard(
            title: 'Từ đã thuộc',
            value: '42',
            icon: Icons.check_circle,
            color: AppColors.success,
          ),
        ),
      ),
    );

    expect(find.text('Từ đã thuộc'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('WordCardTile renders word details accurately', (WidgetTester tester) async {
    const word = WordModel(
      id: 1,
      topicId: 1,
      term: 'Collaborate',
      ipa: '/kəˈlæb.ə.reɪt/',
      partOfSpeech: 'verb',
      meaning: 'Hợp tác, cộng tác',
      exampleEn: 'We collaborate on this project.',
      exampleVi: 'Chúng tôi hợp tác trong dự án này.',
      status: AppConstants.statusMastered,
      isFavorite: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WordCardTile(
            word: word,
          ),
        ),
      ),
    );

    expect(find.text('Collaborate'), findsOneWidget);
    expect(find.text('/kəˈlæb.ə.reɪt/'), findsOneWidget);
    expect(find.text('Hợp tác, cộng tác'), findsOneWidget);
    expect(find.text('verb'), findsOneWidget);
    expect(find.text('Đã nhớ'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets('InteractiveCard renders child and handles tap', (WidgetTester tester) async {
    bool cardTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: InteractiveCard(
            onTap: () => cardTapped = true,
            child: const Text('Thẻ tương tác'),
          ),
        ),
      ),
    );

    expect(find.text('Thẻ tương tác'), findsOneWidget);
    await tester.tap(find.text('Thẻ tương tác'));
    expect(cardTapped, true);
  });

  testWidgets('AppSidebar displays all 13 individual skill and navigation items', (WidgetTester tester) async {
    int selectedIndex = 0;
    bool collapsed = false;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: ThemeData.dark(),
              home: Scaffold(
                body: Row(
                  children: [
                    AppSidebar(
                      currentIndex: selectedIndex,
                      isCollapsed: collapsed,
                      onDestinationSelected: (idx) {
                        setState(() => selectedIndex = idx);
                      },
                      onToggleCollapse: () {
                        setState(() => collapsed = !collapsed);
                      },
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('English Buddy'), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Chủ đề'), findsOneWidget);
    expect(find.text('Luyện nghe'), findsOneWidget);
    expect(find.text('Luyện đọc'), findsOneWidget);
    expect(find.text('Luyện viết'), findsOneWidget);
    expect(find.text('Luyện nói'), findsOneWidget);
    expect(find.text('Shadowing'), findsOneWidget);
    expect(find.text('Từ vựng / Từ điển'), findsOneWidget);
    expect(find.text('Luyện thi'), findsOneWidget);
    expect(find.text('Trò chơi'), findsOneWidget);
    expect(find.text('Ôn tập'), findsOneWidget);
    expect(find.text('Thống kê'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);

    await tester.tap(find.text('Shadowing'));
    await tester.pumpAndSettle();
    expect(selectedIndex, 6);

    await tester.tap(find.text('Từ vựng / Từ điển'));
    await tester.pumpAndSettle();
    expect(selectedIndex, 7);
  });

  testWidgets('AuthScreen displays English Buddy owl logo, login form, and hides redundant diagnostics frames', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    // 1. Logo cú English Buddy được hiển thị phía trên biểu mẫu
    expect(find.byKey(const Key('auth_screen_app_logo')), findsOneWidget);

    // 2. Các nút và trường nhập liệu chính của biểu mẫu đăng nhập
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.text('Tạo tài khoản mới'), findsOneWidget);
    expect(find.text('Tiếp tục với Google / Gmail'), findsOneWidget);

    // 3. Hai khung thông tin phụ đã được gỡ bỏ hoàn toàn khỏi giao diện
    expect(find.textContaining('Dữ liệu học tập cục bộ trên thiết bị (Được bảo toàn 100%)'), findsNothing);
    expect(find.text('Chẩn đoán cấu hình Xác thực & Anti-Bot'), findsNothing);
    expect(find.text('Xem bước thiết lập'), findsNothing);
  });

  testWidgets('AuthScreen navigates to HomeScreen and clears auth route on successful Email/Password login, Register, and Google Sign-In', (WidgetTester tester) async {
    final fakeAuthService = _ConfigurableAuthService();
    final fakeAntiBotService = _ConfigurableAntiBotService();

    // 1. Kiểm tra Đăng nhập Email/Mật khẩu: thất bại giữ nguyên màn hình, thành công chuyển về Trang chủ & xóa stack
    final authProvider = AuthProvider(
      authService: fakeAuthService,
      antiBotService: fakeAntiBotService,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  },
                  child: const Text('Mở xác thực'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mở xác thực'));
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);

    // Thử đăng nhập thất bại -> Giữ nguyên ở AuthScreen và hiển thị lỗi
    fakeAuthService.shouldSucceed = false;
    await tester.enterText(find.byType(TextField).first, 'wrong@example.com');
    await tester.enterText(find.byType(TextField).last, 'wrongpass123');
    final loginBtn = find.widgetWithText(CustomButton, 'Đăng nhập');
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.text('Email hoặc mật khẩu không chính xác.'), findsOneWidget);

    // Đăng nhập Email/Password thành công -> Tự động chuyển đến Trang chủ (MainNavigationScreen / HomeScreen) và xóa AuthScreen khỏi stack
    fakeAuthService.shouldSucceed = true;
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AuthScreen), findsNothing);
    expect(fakeAuthService.signInCallCount, 2);

    // Kiểm tra nút Back không thể quay lại AuthScreen
    final navState = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navState.canPop(), false);
  });

  testWidgets('AuthScreen navigates to HomeScreen on successful Email/Password Registration and Google Sign-In', (WidgetTester tester) async {
    final fakeAuthService = _ConfigurableAuthService(shouldSucceed: true);
    final fakeAntiBotService = _ConfigurableAntiBotService(configured: true, verified: true);
    final authProvider = AuthProvider(
      authService: fakeAuthService,
      antiBotService: fakeAntiBotService,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: AuthScreen(initialRegisterMode: true),
        ),
      ),
    );

    // Khi chưa xác minh CAPTCHA -> báo lỗi và giữ nguyên ở màn hình đăng ký
    await tester.enterText(find.byType(TextField).at(0), 'HocVienMoi');
    await tester.enterText(find.byType(TextField).at(1), 'hocvien@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'MatKhauAnToan123');
    await tester.enterText(find.byType(TextField).at(3), 'MatKhauAnToan123');
    final registerBtn = find.widgetWithText(CustomButton, 'Tạo tài khoản');
    await tester.ensureVisible(registerBtn);
    await tester.tap(registerBtn);
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.textContaining('Vui lòng xác minh token chống bot'), findsOneWidget);

    // Sau khi xác minh CAPTCHA phía server -> Tạo tài khoản thành công -> Tự động về Trang chủ
    await authProvider.verifyAntiBotToken(
      tokenFromProviderWidget: 'valid_turnstile_token',
      action: 'register',
    );
    await tester.pump();

    await tester.ensureVisible(registerBtn);
    await tester.tap(registerBtn);
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AuthScreen), findsNothing);

    final navState = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navState.canPop(), false);

    // Kiểm tra luồng Đăng nhập Google thành công từ màn hình AuthScreen mới
    authProvider.signOut();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: MaterialApp(
          key: UniqueKey(),
          home: const AuthScreen(),
        ),
      ),
    );
    expect(find.byType(AuthScreen), findsOneWidget);

    await authProvider.signInWithGoogle(googleIdToken: 'valid_google_id_token');
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AuthScreen), findsNothing);
  });

  testWidgets('AuthScreen prevents duplicate submissions while loading and safely handles widget disposal', (WidgetTester tester) async {
    final completer = Completer<AuthOperationResult>();
    final delayedAuthService = _DelayedAuthService(completer);
    final authProvider = AuthProvider(
      authService: delayedAuthService,
      antiBotService: _ConfigurableAntiBotService(),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'user@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');

    // Bấm nút Đăng nhập lần 1 -> chuyển sang trạng thái đang xử lý (loading)
    final submitBtn = find.widgetWithText(CustomButton, 'Đăng nhập');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Đang xử lý xác thực...'), findsOneWidget);
    expect(delayedAuthService.callCount, 1);

    // Cố gắng gọi signIn lần 2 trong lúc đang xử lý -> bị chặn
    final duplicateResult = await authProvider.signIn(
      identifier: 'user@example.com',
      password: 'password123',
    );
    expect(duplicateResult, false);
    expect(delayedAuthService.callCount, 1);

    // Hủy (dispose) AuthScreen trước khi request hoàn tất -> không gây lỗi điều hướng sau dispose
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Đã đóng'))));
    completer.complete(
      const AuthOperationResult(
        isSuccess: true,
        message: 'Đăng nhập thành công!',
        user: AuthenticatedUser(
          uid: 'u1',
          email: 'user@example.com',
          displayName: 'User',
          providerId: 'password',
          idToken: 'token',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Đã đóng'), findsOneWidget);
  });

  testWidgets('Role-Based Access Control: Regular user does not see Admin menu and is blocked on AdminScreen; Admin sees and accesses AdminScreen', (WidgetTester tester) async {
    final regularAuthService = _ConfigurableAuthService(
      shouldSucceed: true,
      returnedRole: AppConstants.roleUser,
    );
    final authProvider = AuthProvider(
      authService: regularAuthService,
      antiBotService: _ConfigurableAntiBotService(),
    );

    // Đăng nhập với vai trò User thường
    await authProvider.signIn(identifier: 'learner@example.com', password: 'password123');
    expect(authProvider.isAuthenticated, true);
    expect(authProvider.isAdmin, false);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                AppSidebar(
                  currentIndex: 0,
                  isCollapsed: false,
                  onDestinationSelected: (_) {},
                  onToggleCollapse: () {},
                ),
                const Expanded(child: AdminScreen()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // User thường không thấy mục "Quản trị viên" trên Sidebar và bị chặn 403 trên AdminScreen
    expect(find.text('Quản trị viên'), findsNothing);
    expect(find.textContaining('Khu vực dành riêng cho Quản trị viên (403 Forbidden)'), findsOneWidget);

    // Đăng nhập với vai trò Admin
    final adminAuthService = _ConfigurableAuthService(
      shouldSucceed: true,
      returnedRole: AppConstants.roleAdmin,
      returnedUid: 'admin_uid_99',
    );
    final adminAuthProvider = AuthProvider(
      authService: adminAuthService,
      antiBotService: _ConfigurableAntiBotService(),
    );
    await adminAuthProvider.signIn(identifier: 'admin@example.com', password: 'password123');
    expect(adminAuthProvider.isAdmin, true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider.value(value: adminAuthProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                AppSidebar(
                  currentIndex: 13,
                  isCollapsed: false,
                  onDestinationSelected: (_) {},
                  onToggleCollapse: () {},
                ),
                const Expanded(child: AdminScreen()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Admin thấy mục "Quản trị viên" trên Sidebar và truy cập được màn hình Quản trị
    expect(find.text('Quản trị viên'), findsOneWidget);
    expect(find.text('Khu vực Quản trị Hệ thống (Admin)'), findsOneWidget);
    expect(find.text('Người dùng & Cấp độ'), findsOneWidget);
    expect(find.text('Kho Từ vựng & Chủ đề'), findsOneWidget);
  });

  testWidgets('ProfileScreen displays read-only CEFR level for regular user, validates inputs, updates own profile, and blocks editing another account', (WidgetTester tester) async {
    final userAuthService = _ConfigurableAuthService(
      shouldSucceed: true,
      returnedRole: AppConstants.roleUser,
      returnedUid: 'learner_uid_10',
    );
    final authProvider = AuthProvider(
      authService: userAuthService,
      antiBotService: _ConfigurableAntiBotService(),
    );
    await authProvider.signIn(identifier: 'learner10@example.com', password: 'password123');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Hiển thị cấp độ CEFR hiện tại ở chế độ chỉ đọc đối với user thường
    expect(find.textContaining('Cấp độ Năng lực Hiện tại: CEFR A1'), findsOneWidget);
    expect(find.textContaining('Học viên không thể tự ý chỉnh sửa trường này'), findsOneWidget);
    expect(find.text('Cập nhật Cấp độ CEFR (Quyền Admin):'), findsNothing);

    // Cập nhật tên hiển thị và giới thiệu (Bio) hợp lệ
    final nameField = find.byType(TextFormField).at(0);
    final bioField = find.byType(TextFormField).at(1);
    await tester.enterText(nameField, 'Nguyễn Minh Anh');
    await tester.enterText(bioField, 'Yêu thích luyện nghe và Shadowing mỗi ngày.');

    final saveBtn = find.widgetWithText(CustomButton, 'Lưu thay đổi hồ sơ');
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    expect(authProvider.currentUser?.displayName, 'Nguyễn Minh Anh');
    expect(authProvider.currentProfile?.bio, 'Yêu thích luyện nghe và Shadowing mỗi ngày.');

    // Kiểm tra chặn chỉnh sửa hồ sơ của tài khoản khác (targetUid != activeUid)
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: ProfileScreen(targetUid: 'other_user_uid_999'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Không có quyền chỉnh sửa hồ sơ này (403)'), findsOneWidget);
  });

  testWidgets('Top-right profile menu opens Edit Profile & Sign Out, and left sidebar has no account footer', (WidgetTester tester) async {
    final adminAuthService = _ConfigurableAuthService(
      shouldSucceed: true,
      returnedRole: AppConstants.roleAdmin,
      returnedUid: 'admin_top_menu_uid',
    );
    final authProvider = AuthProvider(
      authService: adminAuthService,
      antiBotService: _ConfigurableAntiBotService(),
    );
    await authProvider.signIn(identifier: 'admin@example.com', password: 'password123');
    expect(authProvider.isAuthenticated, true);
    expect(authProvider.isAdmin, true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: const MainNavigationScreen(initialIndex: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Thanh bên trái (AppSidebar) không còn mục/nút tài khoản ở góc dưới bên trái
    expect(find.text('Đăng nhập / Tài khoản'), findsNothing);

    // 2. Ở góc trên bên phải có nút ảnh đại diện (TopProfileMenuButton)
    final topProfileBtn = find.byKey(const Key('top_profile_avatar_menu_button'));
    expect(topProfileBtn, findsOneWidget);

    // Bấm vào nút ảnh đại diện góc trên bên phải -> mở menu có "Chỉnh sửa hồ sơ", "Khu vực Quản trị" (vì là Admin) và "Đăng xuất"
    await tester.tap(topProfileBtn);
    await tester.pumpAndSettle();

    expect(find.text('Chỉnh sửa hồ sơ'), findsOneWidget);
    expect(find.text('Khu vực Quản trị'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);

    // Bấm "Chỉnh sửa hồ sơ" -> mở trang ProfileScreen
    await tester.tap(find.text('Chỉnh sửa hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    // 3. Trong trang Chỉnh sửa hồ sơ cũng có nút Đăng xuất -> bấm mở hộp thoại xác nhận -> xác nhận Đăng xuất -> xóa phiên và về AuthScreen
    final profileSignOutBtn = find.byKey(const Key('profile_appbar_signout_button'));
    expect(profileSignOutBtn, findsOneWidget);
    await tester.tap(profileSignOutBtn);
    await tester.pumpAndSettle();

    expect(find.text('Xác nhận đăng xuất'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng xuất'));
    await tester.pumpAndSettle();

    expect(authProvider.isAuthenticated, false);
    expect(authProvider.isAdmin, false);
    expect(find.byType(AuthScreen), findsOneWidget);
  });

  testWidgets('When unauthenticated: top header displays Login button, does not show Profile/SignOut menu, and ProfileScreen is protected', (WidgetTester tester) async {
    final authProvider = AuthProvider(
      authService: _ConfigurableAuthService(),
      antiBotService: _ConfigurableAntiBotService(),
    );
    // Chưa đăng nhập
    expect(authProvider.isAuthenticated, false);
    expect(authProvider.currentUser, null);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: const MainNavigationScreen(initialIndex: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Khi chưa đăng nhập: Không có menu tài khoản, không có "Chỉnh sửa hồ sơ", không có "Đăng xuất"
    expect(find.byKey(const Key('top_profile_avatar_menu_button')), findsNothing);
    expect(find.text('Chỉnh sửa hồ sơ'), findsNothing);
    expect(find.text('Đăng xuất'), findsNothing);

    // 2. Hiển thị nút "Đăng nhập" trên thanh đầu trang
    final topLoginBtn = find.byKey(const Key('top_login_button'));
    expect(topLoginBtn, findsOneWidget);

    // Bấm "Đăng nhập" -> mở AuthScreen
    await tester.tap(topLoginBtn);
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);

    // 3. Mở trực tiếp ProfileScreen khi chưa đăng nhập -> bị chặn với màn hình Yêu cầu đăng nhập (401), không có nút Đăng xuất
    await tester.pumpWidget(
      MultiProvider(
        key: UniqueKey(),
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Yêu cầu đăng nhập (401)'), findsOneWidget);
    expect(find.byKey(const Key('profile_appbar_signout_button')), findsNothing);
    expect(find.byKey(const Key('profile_bottom_signout_button')), findsNothing);
  });

  testWidgets('GamesHubScreen displays 3 vocabulary games and does not display Speed Typer', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider(create: (_) => GamesProvider()),
        ],
        child: const MaterialApp(
          home: GamesHubScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Kiểm tra tiêu đề màn hình
    expect(find.text('Trung tâm Trò chơi Từ vựng (Mini Games)'), findsOneWidget);

    // Kiểm tra 3 trò chơi có mặt
    expect(find.textContaining('1. Chiến Cơ Vũ Trụ (Space Typer)'), findsOneWidget);
    expect(find.textContaining('2. Đấu trường từ vựng (Vocabulary Arena)'), findsOneWidget);
    expect(find.textContaining('3. Mưa Từ Vựng (Vocabulary Rain)'), findsOneWidget);

    // Game "Luyện Gõ Siêu Tốc (Speed Typer)" đã bị gỡ bỏ
    expect(find.textContaining('Luyện Gõ Siêu Tốc (Speed Typer)'), findsNothing);

    // Kiểm tra 3 nút "Chơi ngay" trong danh sách 3 game
    expect(find.text('Chơi ngay'), findsNWidgets(3));

    // Kiểm tra banner đặc biệt Chiến cơ Vũ trụ
    expect(find.textContaining('Chiến Cơ Vũ Trụ (Space Typer)'), findsWidgets);
    expect(find.text('Khởi hành vũ trụ'), findsOneWidget);

    // Kiểm tra bộ lọc cấp độ CEFR
    expect(find.text('Tất cả cấp độ'), findsOneWidget);
    expect(find.text('A1'), findsOneWidget);
    expect(find.text('B1'), findsOneWidget);
    expect(find.text('C1'), findsOneWidget);
  });

  testWidgets('SpaceTyperScreen renders start menu, HUD and handles game launch', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final words = [
      const WordModel(
        id: 1,
        topicId: 1,
        term: 'GALAXY',
        ipa: '/ˈɡæl.ək.si/',
        partOfSpeech: 'noun',
        meaning: 'Thiên hà vũ trụ',
        exampleEn: 'The galaxy contains billions of stars.',
        exampleVi: 'Thiên hà chứa hàng tỷ ngôi sao.',
      ),
    ];

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => GamesProvider()),
        ],
        child: MaterialApp(
          home: SpaceTyperScreen(words: words),
        ),
      ),
    );
    await tester.pump();

    // Kiểm tra các phần tử trên màn hình bắt đầu
    expect(find.text('CHIẾN CƠ VŨ TRỤ'), findsOneWidget);
    expect(find.text('SPACE SPEED TYPER'), findsOneWidget);
    expect(find.textContaining('BẮT ĐẦU CHIẾN ĐẤU'), findsOneWidget);

    // Chạm bắt đầu chơi
    await tester.tap(find.textContaining('BẮT ĐẦU CHIẾN ĐẤU'));
    await tester.pump();

    // Kiểm tra thanh trạng thái HUD và Radar
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('LEVEL'), findsOneWidget);
    expect(find.text('RADAR'), findsOneWidget);
  });

  testWidgets('SpaceTyperScreen updates HUD reactively and handles keyboard inputs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final words = [
      const WordModel(
        id: 1,
        topicId: 1,
        term: 'GALAXY',
        ipa: '/ˈɡæl.ək.si/',
        partOfSpeech: 'noun',
        meaning: 'Thiên hà vũ trụ',
        exampleEn: 'The galaxy contains billions of stars.',
        exampleVi: 'Thiên hà chứa hàng tỷ ngôi sao.',
      ),
    ];

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => GamesProvider()),
        ],
        child: MaterialApp(
          home: SpaceTyperScreen(words: words),
        ),
      ),
    );
    await tester.pump();

    // Bắt đầu game
    await tester.tap(find.textContaining('BẮT ĐẦU CHIẾN ĐẤU'));
    await tester.pump();

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('0'), findsAtLeast(1));

    // Thử gửi phím gõ bàn phím
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    await tester.pump();

    // Kiểm tra HUD vẫn hiển thị đầy đủ
    expect(find.text('MISSIONS'), findsOneWidget);
    expect(find.text('RADAR'), findsOneWidget);
  });

  testWidgets('SpaceGamePainter renders level-up banner cleanly on narrow and wide screens', (WidgetTester tester) async {
    final words = [
      const WordModel(
        id: 1,
        topicId: 1,
        term: 'GALAXY',
        ipa: '/ˈɡæl.ək.si/',
        partOfSpeech: 'noun',
        meaning: 'Thiên hà vũ trụ',
        exampleEn: 'The galaxy contains billions of stars.',
        exampleVi: 'Thiên hà chứa hàng tỷ ngôi sao.',
      ),
    ];

    final engine = SpaceGameEngine()
      ..init(
        words: words,
        gameDifficulty: GameDifficulty.easy,
        newWidth: 360,
        newHeight: 740,
        newPlayTop: 70,
        newPlayBottom: 640,
      );
    engine.start();
    engine.bannerText = 'LEVEL 2!';
    engine.bannerTimer = 2.0;

    // 1. Màn hình hẹp (360x740)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 740,
            child: CustomPaint(
              painter: SpaceGamePainter(engine: engine),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    // 2. Màn hình rộng (1024x768) với banner thông báo dài
    engine.resize(1024, 768, 70, 680);
    engine.bannerText = 'LEVEL 10 - EXCELLENT!';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1024,
            height: 768,
            child: CustomPaint(
              painter: SpaceGamePainter(engine: engine),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    engine.dispose();
  });

  testWidgets('VocabularyArenaScreen displays difficulty selection and starts match', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final words = [
      const WordModel(
        id: 1,
        topicId: 1,
        term: 'APPLE',
        ipa: '/ˈæp.əl/',
        partOfSpeech: 'noun',
        meaning: 'Quả táo',
        exampleEn: 'An apple a day.',
        exampleVi: 'Một quả táo mỗi ngày.',
        level: 'A1',
      ),
      const WordModel(
        id: 2,
        topicId: 1,
        term: 'BANANA',
        ipa: '/bəˈnæn.ə/',
        partOfSpeech: 'noun',
        meaning: 'Quả chuối',
        exampleEn: 'Monkeys love bananas.',
        exampleVi: 'Khỉ thích chuối.',
        level: 'A1',
      ),
      const WordModel(
        id: 3,
        topicId: 1,
        term: 'ORANGE',
        ipa: '/ˈɔːr.ɪndʒ/',
        partOfSpeech: 'noun',
        meaning: 'Quả cam',
        exampleEn: 'Orange juice is fresh.',
        exampleVi: 'Nước cam rất tươi ngon.',
        level: 'A1',
      ),
      const WordModel(
        id: 4,
        topicId: 1,
        term: 'GRAPE',
        ipa: '/ɡreɪp/',
        partOfSpeech: 'noun',
        meaning: 'Quả nho',
        exampleEn: 'Grapes are sweet.',
        exampleVi: 'Nho rất ngọt.',
        level: 'A1',
      ),
    ];

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => GamesProvider()),
        ],
        child: MaterialApp(
          home: VocabularyArenaScreen(words: words),
        ),
      ),
    );
    await tester.pump();

    // Màn hình chọn độ khó
    expect(find.text('ĐẤU TRƯỜNG TỪ VỰNG'), findsOneWidget);
    expect(find.text('CHỌN CẤP ĐỘ KHÓ:'), findsOneWidget);
    expect(find.text('Dễ'), findsOneWidget);
    expect(find.text('Trung bình'), findsOneWidget);
    expect(find.text('Khó'), findsOneWidget);

    // Chạm chọn 'Dễ' và bấm Vào Đấu Trường
    await tester.tap(find.text('Dễ'));
    await tester.pump();

    final enterBtn = find.textContaining('VÀO ĐẤU TRƯỜNG');
    expect(enterBtn, findsOneWidget);
    await tester.tap(enterBtn);
    await tester.pump();

    // Vào trận đấu, kiểm tra hiển thị câu hỏi và badge độ khó
    expect(find.textContaining('Đấu trường từ vựng (1/15)'), findsOneWidget);
    expect(find.textContaining('Dễ'), findsWidgets);
  });

  testWidgets('WordRainScreen displays difficulty selection and starts match', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final words = [
      const WordModel(
        id: 1,
        topicId: 1,
        term: 'RAIN',
        ipa: '/reɪn/',
        partOfSpeech: 'noun',
        meaning: 'Cơn mưa',
        exampleEn: 'Rain falls from the sky.',
        exampleVi: 'Mưa rơi từ bầu trời.',
        level: 'A1',
      ),
      const WordModel(
        id: 2,
        topicId: 1,
        term: 'DROP',
        ipa: '/drɑːp/',
        partOfSpeech: 'noun',
        meaning: 'Giọt nước',
        exampleEn: 'A drop of water.',
        exampleVi: 'Một giọt nước.',
        level: 'A1',
      ),
    ];

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => GamesProvider()),
        ],
        child: MaterialApp(
          home: WordRainScreen(words: words),
        ),
      ),
    );
    await tester.pump();

    // Màn hình chọn độ khó
    expect(find.text('MƯA TỪ VỰNG'), findsOneWidget);
    expect(find.text('CHỌN CẤP ĐỘ KHÓ:'), findsOneWidget);
    expect(find.text('Dễ'), findsOneWidget);
    expect(find.text('Trung bình'), findsOneWidget);
    expect(find.text('Khó'), findsOneWidget);

    // Chạm chọn 'Dễ'
    await tester.tap(find.text('Dễ'));
    await tester.pump();

    // Bấm Bắt đầu hứng mưa
    final startRainBtn = find.textContaining('BẮT ĐẦU BẮT MƯA');
    expect(startRainBtn, findsOneWidget);
    await tester.tap(startRainBtn);
    await tester.pump();

    // Vào trận đấu
    expect(find.textContaining('HÃY CHẠM VÀO GIỌT MƯA'), findsOneWidget);
    expect(find.textContaining('Dễ'), findsWidgets);
  });

  testWidgets('DictionaryScreen renders cleanly on compact mobile screen without bottom overflow', (WidgetTester tester) async {
    // Kích thước điện thoại di động hẹp/thấp (360x640)
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final studyProvider = StudyProvider();
    final dictProvider = DictionaryProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: studyProvider),
          ChangeNotifierProvider.value(value: dictProvider),
        ],
        child: const MaterialApp(
          home: DictionaryScreen(),
        ),
      ),
    );
    await tester.pump();

    // Xác nhận không có ngoại lệ RenderFlex overflow (vạch sọc vàng đen)
    expect(tester.takeException(), isNull);
    expect(find.text('Từ điển song ngữ Việt – Anh & Anh – Việt'), findsAtLeast(1));
    expect(find.byIcon(Icons.auto_stories_rounded), findsOneWidget);

    // Kiểm tra trên màn hình siêu thấp (chiều cao 480px)
    tester.view.physicalSize = const Size(360, 480);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('AiChatScreen renders app bar, status indicator, prompt suggestions, and input field', (WidgetTester tester) async {
    final chatProvider = AiChatProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider.value(value: chatProvider),
        ],
        child: const MaterialApp(
          home: AiChatScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trợ lý AI English Buddy'), findsOneWidget);
    expect(find.text('Hỏi đáp ngữ pháp • Dịch câu • Góp ý bài viết'), findsOneWidget);
    expect(find.text('Chào bạn! Mình có thể giúp gì cho việc học tiếng Anh?'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);

    // Gõ nội dung vào ô nhập liệu
    await tester.enterText(find.byType(TextField), 'Hello AI');
    await tester.pump();

    // Nút gửi sáng lên và có thể bấm
    final sendBtn = find.byTooltip('Gửi câu hỏi');
    expect(sendBtn, findsOneWidget);

    // Bấm nút info trên AppBar
    final infoBtn = find.byTooltip('Thông tin Trợ lý AI');
    expect(infoBtn, findsOneWidget);
    await tester.tap(infoBtn);
    await tester.pumpAndSettle();
    expect(find.text('Về Trợ lý AI English Buddy'), findsOneWidget);
    expect(find.text('Đã hiểu'), findsOneWidget);
    await tester.tap(find.text('Đã hiểu'));
    await tester.pumpAndSettle();
  });

  testWidgets('MainNavigationScreen displays AI Assistant FAB and entry points', (WidgetTester tester) async {
    final studyProvider = StudyProvider();
    final authProvider = AuthProvider();
    final chatProvider = AiChatProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: studyProvider),
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: chatProvider),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // FAB Hỏi AI hiện diện trên giao diện
    expect(find.byKey(const Key('ai_chat_fab')), findsNothing); // heroTag only
    expect(find.text('Hỏi AI'), findsOneWidget);
    expect(find.byIcon(Icons.smart_toy_rounded), findsAtLeast(1));
  });
}

class _ConfigurableAuthService implements AuthService {
  bool shouldSucceed;
  String returnedRole;
  String returnedUid;
  int signInCallCount = 0;

  _ConfigurableAuthService({
    this.shouldSucceed = true,
    this.returnedRole = AppConstants.roleUser,
    this.returnedUid = 'uid_1',
  });

  @override
  bool get isPasswordAuthConfigured => true;

  @override
  bool get isGoogleOAuthConfigured => true;

  @override
  List<String> get missingAuthConfigItems => const [];

  @override
  Future<AuthOperationResult> signInWithIdentifierAndPassword({
    required String identifier,
    required String password,
  }) async {
    signInCallCount++;
    if (!shouldSucceed) {
      return const AuthOperationResult(
        isSuccess: false,
        message: 'Email hoặc mật khẩu không chính xác.',
      );
    }
    return AuthOperationResult(
      isSuccess: true,
      message: 'Đăng nhập thành công!',
      user: AuthenticatedUser(
        uid: returnedUid,
        email: identifier,
        displayName: 'Learner',
        providerId: 'password',
        idToken: 'jwt_token',
        role: returnedRole,
      ),
    );
  }

  @override
  Future<AuthOperationResult> registerAccount({
    required String username,
    required String email,
    required String password,
  }) async {
    if (!shouldSucceed) {
      return const AuthOperationResult(
        isSuccess: false,
        message: 'Không thể tạo tài khoản.',
      );
    }
    return AuthOperationResult(
      isSuccess: true,
      message: 'Tạo tài khoản thành công!',
      user: AuthenticatedUser(
        uid: 'uid_2',
        email: email,
        displayName: username,
        providerId: 'password',
        idToken: 'jwt_token_2',
      ),
    );
  }

  @override
  Future<AuthOperationResult> signInWithGoogle({String? googleIdToken}) async {
    if (!shouldSucceed) {
      return const AuthOperationResult(
        isSuccess: false,
        message: 'Đăng nhập Google thất bại.',
      );
    }
    return const AuthOperationResult(
      isSuccess: true,
      message: 'Đăng nhập bằng Google thành công!',
      user: AuthenticatedUser(
        uid: 'uid_google',
        email: 'googleuser@gmail.com',
        displayName: 'Google Learner',
        providerId: 'google.com',
        idToken: 'google_jwt',
      ),
    );
  }
}

class _DelayedAuthService extends _ConfigurableAuthService {
  final Completer<AuthOperationResult> completer;
  int callCount = 0;

  _DelayedAuthService(this.completer);

  @override
  Future<AuthOperationResult> signInWithIdentifierAndPassword({
    required String identifier,
    required String password,
  }) {
    callCount++;
    return completer.future;
  }
}

class _ConfigurableAntiBotService implements AntiBotService {
  final bool configured;
  final bool verified;

  _ConfigurableAntiBotService({this.configured = false, this.verified = false});

  @override
  bool get isConfigured => configured;

  @override
  List<String> get missingConfigItems =>
      configured ? const [] : const ['CAPTCHA_SITE_KEY', 'CAPTCHA_VERIFY_URL'];

  @override
  Future<AntiBotVerificationResult> verifyTokenOnServer({
    required String captchaResponseToken,
    required String action,
  }) async {
    return AntiBotVerificationResult(
      isVerified: verified,
      message: verified ? 'Đã xác minh chống bot.' : 'Token không hợp lệ.',
    );
  }
}
