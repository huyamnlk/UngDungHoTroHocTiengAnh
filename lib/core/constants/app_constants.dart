class AppConstants {
  AppConstants._();

  static const String appName = 'English Buddy';
  static const String appTagline = 'Học từ vựng tiếng Anh thông minh mỗi ngày';
  static const String dbName = 'english_buddy.db';
  static const int dbVersion = 8; // Version 8: Bổ sung username hồ sơ và bảng learning_activity_log cho Tiến độ hằng tuần

  // Vai trò tài khoản (RBAC)
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';

  // Các cấp độ năng lực CEFR hợp lệ
  static const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1'];

  // Trạng thái từ vựng
  static const String statusNew = 'new';
  static const String statusLearning = 'learning'; // Cần ôn tập
  static const String statusMastered = 'mastered'; // Đã ghi nhớ

  // Loại câu hỏi quiz
  static const String quizTypeMeaning = 'meaning'; // Chọn nghĩa tiếng Việt
  static const String quizTypeWord = 'word';       // Chọn từ tiếng Anh
  static const String quizTypeFill = 'fill';       // Điền từ vào câu ví dụ
}
