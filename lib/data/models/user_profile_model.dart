import '../../core/constants/app_constants.dart';

class UserProfileModel {
  final String uid;
  final String email;
  final String username;
  final String displayName;
  final String providerId;
  final String role; // 'user' or 'admin'
  final String cefrLevel; // 'A1', 'A2', 'B1', 'B2', 'C1'
  final String levelUpdatedBy; // 'system' or 'admin'
  final String bio;
  final String learningGoal;
  final String avatarData; // 'data:image/...;base64,...', 'https://...', or 'preset:...'
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  static const Set<String> reservedUsernames = {
    'admin',
    'root',
    'system',
    'support',
    'guest',
    'local_learner',
    'null',
    'undefined',
    'api',
    'auth',
    'profile',
    'login',
    'register',
    'settings',
    'englishbuddy',
    'english_buddy',
  };

  const UserProfileModel({
    required this.uid,
    required this.email,
    this.username = '',
    required this.displayName,
    this.providerId = 'password',
    this.role = AppConstants.roleUser,
    this.cefrLevel = 'A1',
    this.levelUpdatedBy = 'system',
    this.bio = '',
    this.learningGoal = '',
    this.avatarData = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  static String normalizeUsername(String? raw) {
    return (raw ?? '').trim().toLowerCase();
  }

  /// Kiểm tra định dạng tên đăng nhập (username) chuẩn hóa
  static String? validateUsername(
    String? rawUsername, {
    bool allowEmpty = true,
  }) {
    final normalized = normalizeUsername(rawUsername);
    if (normalized.isEmpty) {
      return allowEmpty ? null : 'Tên đăng nhập không được để trống.';
    }
    if (normalized.length < 3 || normalized.length > 30) {
      return 'Tên đăng nhập phải từ 3 đến 30 ký tự.';
    }
    if (normalized.contains('@')) {
      return 'Tên đăng nhập không được chứa ký tự @.';
    }
    if (!RegExp(r'^[a-z0-9](?:[a-z0-9._-]{1,28}[a-z0-9])?$')
        .hasMatch(normalized)) {
      return 'Tên đăng nhập chỉ được gồm chữ thường (a-z), số (0-9), dấu chấm (.), gạch dưới (_) hoặc gạch ngang (-), bắt đầu và kết thúc bằng chữ hoặc số.';
    }
    if (RegExp(r'[._-]{2,}').hasMatch(normalized)) {
      return 'Tên đăng nhập không được chứa các ký tự đặc biệt liên tiếp.';
    }
    if (reservedUsernames.contains(normalized)) {
      return 'Tên đăng nhập này đã được hệ thống đặt trước, vui lòng chọn tên khác.';
    }
    return null;
  }

  bool get isAdmin => role == AppConstants.roleAdmin;
  bool get isRegularUser => role != AppConstants.roleAdmin;

  String get roleDisplayName =>
      isAdmin ? 'Quản trị viên (Admin)' : 'Học viên (User)';

  String get initials {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : 'B';
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  static String describeCefrLevel(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return 'A1 – Sơ cấp (Beginner): Làm quen từ vựng và mẫu câu giao tiếp cơ bản hằng ngày.';
      case 'A2':
        return 'A2 – Tiền trung cấp (Elementary): Giao tiếp trong các tình huống quen thuộc, mô tả trải nghiệm đơn giản.';
      case 'B1':
        return 'B1 – Trung cấp (Intermediate): Tự tin xử lý tình huống học tập, công việc và du lịch phổ biến.';
      case 'B2':
        return 'B2 – Trung cao cấp (Upper-Intermediate): Hiểu văn bản học thuật/chuyên ngành và thảo luận mạch lạc.';
      case 'C1':
        return 'C1 – Cao cấp (Advanced): Sử dụng tiếng Anh linh hoạt, chuẩn xác trong môi trường học thuật và chuyên nghiệp.';
      default:
        return 'A1 – Sơ cấp (Beginner)';
    }
  }

  String get levelDescription => describeCefrLevel(cefrLevel);

  /// Kiểm tra tính hợp lệ của dữ liệu hồ sơ khi người dùng hoặc admin lưu
  static String? validateProfileInput({
    required String displayName,
    String? username,
    required String bio,
    required String learningGoal,
    required String avatarData,
  }) {
    final cleanName = displayName.trim();
    if (cleanName.isEmpty) {
      return 'Tên hiển thị không được để trống.';
    }
    if (cleanName.length < 2) {
      return 'Tên hiển thị phải có ít nhất 2 ký tự.';
    }
    if (cleanName.length > 60) {
      return 'Tên hiển thị không được vượt quá 60 ký tự.';
    }
    if (username != null && username.trim().isNotEmpty) {
      final usernameError = validateUsername(username, allowEmpty: true);
      if (usernameError != null) {
        return usernameError;
      }
    }
    if (bio.trim().length > 300) {
      return 'Phần giới thiệu (Bio) không được vượt quá 300 ký tự.';
    }
    if (learningGoal.trim().length > 150) {
      return 'Mục tiêu học tập không được vượt quá 150 ký tự.';
    }
    final cleanAvatar = avatarData.trim();
    if (cleanAvatar.isNotEmpty) {
      final isPreset = cleanAvatar.startsWith('preset:');
      final isDataImage = cleanAvatar.startsWith('data:image/');
      final isHttpUrl = cleanAvatar.startsWith('https://') ||
          cleanAvatar.startsWith('http://');
      if (!isPreset && !isDataImage && !isHttpUrl) {
        return 'Định dạng ảnh đại diện không hợp lệ. Chỉ chấp nhận ảnh tải lên (PNG/JPG/WEBP/GIF), URL hợp lệ hoặc avatar tích hợp.';
      }
      if (isDataImage && cleanAvatar.length > 3 * 1024 * 1024) {
        return 'Kích thước ảnh đại diện quá lớn (tối đa 2MB). Vui lòng chọn ảnh nhẹ hơn.';
      }
    }
    return null;
  }

  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? displayName,
    String? providerId,
    String? role,
    String? cefrLevel,
    String? levelUpdatedBy,
    String? bio,
    String? learningGoal,
    String? avatarData,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username != null ? normalizeUsername(username) : this.username,
      displayName: displayName ?? this.displayName,
      providerId: providerId ?? this.providerId,
      role: role ?? this.role,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      levelUpdatedBy: levelUpdatedBy ?? this.levelUpdatedBy,
      bio: bio ?? this.bio,
      learningGoal: learningGoal ?? this.learningGoal,
      avatarData: avatarData ?? this.avatarData,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': normalizeUsername(username),
      'display_name': displayName,
      'provider_id': providerId,
      'role': role == AppConstants.roleAdmin
          ? AppConstants.roleAdmin
          : AppConstants.roleUser,
      'cefr_level': AppConstants.cefrLevels.contains(cefrLevel.toUpperCase())
          ? cefrLevel.toUpperCase()
          : 'A1',
      'level_updated_by': levelUpdatedBy,
      'bio': bio,
      'learning_goal': learningGoal,
      'avatar_data': avatarData,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    final rawRole = (map['role'] as String? ?? AppConstants.roleUser)
        .trim()
        .toLowerCase();
    final rawLevel =
        (map['cefr_level'] ?? map['cefrLevel'] ?? 'A1').toString().toUpperCase();
    final nowIso = DateTime.now().toIso8601String();

    return UserProfileModel(
      uid: (map['uid'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      username: normalizeUsername((map['username'] ?? '').toString()),
      displayName: (map['display_name'] ?? map['displayName'] ?? 'Learner')
          .toString(),
      providerId:
          (map['provider_id'] ?? map['providerId'] ?? 'password').toString(),
      role: rawRole == AppConstants.roleAdmin
          ? AppConstants.roleAdmin
          : AppConstants.roleUser,
      cefrLevel: AppConstants.cefrLevels.contains(rawLevel) ? rawLevel : 'A1',
      levelUpdatedBy:
          (map['level_updated_by'] ?? map['levelUpdatedBy'] ?? 'system')
              .toString(),
      bio: (map['bio'] ?? '').toString(),
      learningGoal:
          (map['learning_goal'] ?? map['learningGoal'] ?? '').toString(),
      avatarData: (map['avatar_data'] ?? map['avatarData'] ?? '').toString(),
      isActive: map['is_active'] == null
          ? (map['isActive'] as bool? ?? true)
          : (map['is_active'] as int? ?? 1) == 1,
      createdAt: (map['created_at'] ?? map['createdAt'] ?? nowIso).toString(),
      updatedAt: (map['updated_at'] ?? map['updatedAt'] ?? nowIso).toString(),
    );
  }
}
