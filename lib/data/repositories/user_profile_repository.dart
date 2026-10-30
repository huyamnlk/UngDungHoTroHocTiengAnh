import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../../core/database/database_helper.dart';
import '../models/user_profile_model.dart';

class AdminAccessDeniedException implements Exception {
  final String message;
  final int statusCode;

  const AdminAccessDeniedException(
    this.message, {
    this.statusCode = 403,
  });

  @override
  String toString() => message;
}

class ProfileAccessDeniedException implements Exception {
  final String message;
  final int statusCode;

  const ProfileAccessDeniedException(
    this.message, {
    this.statusCode = 403,
  });

  @override
  String toString() => message;
}

class ProfileValidationException implements Exception {
  final String message;

  const ProfileValidationException(this.message);

  @override
  String toString() => message;
}

class UserProfileRepository {
  final DatabaseHelper _dbHelper;
  final bool ensureDbOpen;

  /// Bộ nhớ đồng bộ dự phòng khi chạy trong môi trường FakeAsync (widget test)
  /// chưa gọi DatabaseHelper.instance.database ở hàm main().
  static final Map<String, UserProfileModel> _memoryProfiles = {};

  UserProfileRepository({
    DatabaseHelper? dbHelper,
    this.ensureDbOpen = false,
  }) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  bool get _useSqlite => ensureDbOpen || _dbHelper.isInitialized;

  UserProfileModel _buildDefaultLocalLearner() {
    final nowIso = DateTime.now().toIso8601String();
    return UserProfileModel(
      uid: 'local_learner',
      email: 'local@device.offline',
      displayName: 'Buddy Learner',
      providerId: 'local',
      role: AppConstants.roleUser,
      cefrLevel: 'A1',
      levelUpdatedBy: 'system',
      bio: 'Học viên tiếng Anh chăm chỉ trên English Buddy.',
      learningGoal: 'Chinh phục 500+ từ vựng CEFR và tự tin giao tiếp.',
      avatarData: 'preset:scholar_blue',
      isActive: true,
      createdAt: nowIso,
      updatedAt: nowIso,
    );
  }

  Future<UserProfileModel?> _readRowByUid(String uid) async {
    if (!_useSqlite) {
      if (uid == 'local_learner' && !_memoryProfiles.containsKey(uid)) {
        _memoryProfiles[uid] = _buildDefaultLocalLearner();
      }
      return _memoryProfiles[uid];
    }

    final db = await _dbHelper.database;
    final rows = await db.query(
      'user_profiles',
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final model = UserProfileModel.fromMap(rows.first);
    _memoryProfiles[uid] = model;
    return model;
  }

  Future<void> _writeProfile(UserProfileModel profile) async {
    _memoryProfiles[profile.uid] = profile;
    if (!_useSqlite) return;

    final db = await _dbHelper.database;
    await db.insert(
      'user_profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Đảm bảo hồ sơ mặc định của thiết bị (local_learner) tồn tại và trả về
  Future<UserProfileModel> getOrCreateLocalLearnerProfile() async {
    final existing = await _readRowByUid('local_learner');
    if (existing != null) return existing;

    final defaultLocal = _buildDefaultLocalLearner();
    await _writeProfile(defaultLocal);
    return defaultLocal;
  }

  /// Đồng bộ hoặc khởi tạo hồ sơ khi người dùng đăng nhập thành công
  Future<UserProfileModel> syncAuthenticatedUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required String providerId,
    String? verifiedRoleFromServerOrToken,
    bool isBootstrapAdmin = false,
  }) async {
    final cleanUid = uid.trim();
    if (cleanUid.isEmpty) {
      throw const ProfileValidationException('UID người dùng không hợp lệ.');
    }

    final existing = await _readRowByUid(cleanUid);
    final nowIso = DateTime.now().toIso8601String();

    if (existing != null) {
      if (!existing.isActive) {
        throw const ProfileAccessDeniedException(
          'Tài khoản này đã bị quản trị viên khóa quyền truy cập.',
        );
      }

      String resolvedRole = existing.role;
      if (isBootstrapAdmin ||
          verifiedRoleFromServerOrToken == AppConstants.roleAdmin) {
        resolvedRole = AppConstants.roleAdmin;
      }

      final updated = existing.copyWith(
        email: email.trim().isNotEmpty ? email.trim() : existing.email,
        displayName: existing.displayName.trim().isNotEmpty
            ? existing.displayName
            : (displayName.trim().isNotEmpty ? displayName.trim() : 'Learner'),
        providerId: providerId.trim().isNotEmpty
            ? providerId.trim()
            : existing.providerId,
        role: resolvedRole,
        updatedAt: nowIso,
      );

      await _writeProfile(updated);
      return updated;
    }

    final initialRole = (isBootstrapAdmin ||
            verifiedRoleFromServerOrToken == AppConstants.roleAdmin)
        ? AppConstants.roleAdmin
        : AppConstants.roleUser;

    final created = UserProfileModel(
      uid: cleanUid,
      email: email.trim(),
      displayName: displayName.trim().isNotEmpty
          ? displayName.trim()
          : (email.contains('@') ? email.split('@').first : 'Learner'),
      providerId: providerId.trim().isNotEmpty ? providerId.trim() : 'password',
      role: initialRole,
      cefrLevel: 'A1',
      levelUpdatedBy: 'system',
      bio: '',
      learningGoal: 'Nâng cao trình độ tiếng Anh mỗi ngày.',
      avatarData: initialRole == AppConstants.roleAdmin
          ? 'preset:admin_shield'
          : 'preset:scholar_blue',
      isActive: true,
      createdAt: nowIso,
      updatedAt: nowIso,
    );

    await _writeProfile(created);
    return created;
  }

  /// Kiểm tra nghiêm ngặt quyền Admin ở tầng dữ liệu / API nội bộ
  /// Không chỉ dựa vào UI mà truy vấn trực tiếp kho dữ liệu để xác thực role == 'admin'
  Future<UserProfileModel> verifyAdminActor(String? actorUid) async {
    final cleanActor = actorUid?.trim() ?? '';
    if (cleanActor.isEmpty || cleanActor == 'local_learner') {
      throw const AdminAccessDeniedException(
        'Truy cập bị từ chối (401): Vui lòng đăng nhập tài khoản Quản trị viên.',
        statusCode: 401,
      );
    }

    final actorProfile = await _readRowByUid(cleanActor);
    if (actorProfile == null) {
      throw const AdminAccessDeniedException(
        'Truy cập bị từ chối (403): Không tìm thấy hồ sơ định danh của người gọi.',
        statusCode: 403,
      );
    }

    if (!actorProfile.isActive) {
      throw const AdminAccessDeniedException(
        'Truy cập bị từ chối (403): Tài khoản của bạn đã bị vô hiệu hóa.',
        statusCode: 403,
      );
    }

    if (!actorProfile.isAdmin) {
      throw const AdminAccessDeniedException(
        'Truy cập bị từ chối (403 Forbidden): Chỉ tài khoản Quản trị viên (Admin) mới được phép thực hiện thao tác này.',
        statusCode: 403,
      );
    }

    return actorProfile;
  }

  /// Lấy thông tin hồ sơ. User thường chỉ được xem hồ sơ của chính mình; Admin xem được mọi hồ sơ.
  Future<UserProfileModel> getProfile({
    required String actorUid,
    required String targetUid,
  }) async {
    final cleanActor = actorUid.trim();
    final cleanTarget = targetUid.trim();

    if (cleanActor.isEmpty || cleanTarget.isEmpty) {
      throw const ProfileAccessDeniedException(
        'Yêu cầu thông tin định danh tài khoản hợp lệ.',
        statusCode: 401,
      );
    }

    if (cleanActor != cleanTarget) {
      await verifyAdminActor(cleanActor);
    }

    if (cleanTarget == 'local_learner') {
      return getOrCreateLocalLearnerProfile();
    }

    final profile = await _readRowByUid(cleanTarget);
    if (profile == null) {
      throw const ProfileValidationException(
        'Không tìm thấy hồ sơ người dùng yêu cầu.',
      );
    }

    return profile;
  }

  /// Người dùng tự cập nhật Profile của chính mình.
  /// - Bắt buộc actorUid == targetUid (Cấm sửa profile người khác).
  /// - User thường tuyệt đối không được sửa role hay cefrLevel.
  Future<UserProfileModel> updateOwnProfile({
    required String actorUid,
    required String targetUid,
    required String displayName,
    required String bio,
    required String learningGoal,
    required String avatarData,
    String? attemptedRole,
    String? attemptedCefrLevel,
  }) async {
    final cleanActor = actorUid.trim();
    final cleanTarget = targetUid.trim();

    if (cleanActor.isEmpty || cleanTarget.isEmpty) {
      throw const ProfileAccessDeniedException(
        'Vui lòng đăng nhập để cập nhật hồ sơ.',
        statusCode: 401,
      );
    }

    if (cleanActor != cleanTarget) {
      throw const ProfileAccessDeniedException(
        'Truy cập bị từ chối (403 Forbidden): Bạn không được phép chỉnh sửa hồ sơ của tài khoản khác.',
        statusCode: 403,
      );
    }

    final validationError = UserProfileModel.validateProfileInput(
      displayName: displayName,
      bio: bio,
      learningGoal: learningGoal,
      avatarData: avatarData,
    );
    if (validationError != null) {
      throw ProfileValidationException(validationError);
    }

    UserProfileModel existing;
    if (cleanTarget == 'local_learner') {
      existing = await getOrCreateLocalLearnerProfile();
    } else {
      final found = await _readRowByUid(cleanTarget);
      if (found == null) {
        throw const ProfileValidationException(
          'Hồ sơ tài khoản không tồn tại trong hệ thống.',
        );
      }
      existing = found;
    }

    if (!existing.isActive) {
      throw const ProfileAccessDeniedException(
        'Tài khoản của bạn đã bị khóa, không thể chỉnh sửa hồ sơ.',
        statusCode: 403,
      );
    }

    // Kiểm tra bảo mật: chặn user thường tự nâng quyền hoặc tự đổi cấp độ CEFR
    if (!existing.isAdmin) {
      if (attemptedRole != null &&
          attemptedRole.trim().toLowerCase() != existing.role) {
        throw const ProfileAccessDeniedException(
          'Truy cập bị từ chối (403): Người dùng không được phép tự ý thay đổi vai trò tài khoản.',
          statusCode: 403,
        );
      }
      if (attemptedCefrLevel != null &&
          attemptedCefrLevel.trim().toUpperCase() !=
              existing.cefrLevel.toUpperCase()) {
        throw const ProfileAccessDeniedException(
          'Truy cập bị từ chối (403): Cấp độ CEFR do hệ thống hoặc Quản trị viên quản lý, người dùng không được tự ý sửa.',
          statusCode: 403,
        );
      }
    }

    String nextCefrLevel = existing.cefrLevel;
    String nextLevelUpdatedBy = existing.levelUpdatedBy;
    if (existing.isAdmin &&
        attemptedCefrLevel != null &&
        attemptedCefrLevel.trim().isNotEmpty) {
      final normalizedLevel = attemptedCefrLevel.trim().toUpperCase();
      if (!AppConstants.cefrLevels.contains(normalizedLevel)) {
        throw const ProfileValidationException(
          'Cấp độ CEFR không hợp lệ (chỉ chấp nhận A1, A2, B1, B2, C1).',
        );
      }
      if (normalizedLevel != existing.cefrLevel) {
        nextCefrLevel = normalizedLevel;
        nextLevelUpdatedBy = 'admin';
      }
    }

    final nowIso = DateTime.now().toIso8601String();
    final updated = existing.copyWith(
      displayName: displayName.trim(),
      bio: bio.trim(),
      learningGoal: learningGoal.trim(),
      avatarData: avatarData.trim(),
      role: existing.role,
      cefrLevel: nextCefrLevel,
      levelUpdatedBy: nextLevelUpdatedBy,
      updatedAt: nowIso,
    );

    await _writeProfile(updated);
    return updated;
  }

  // ===========================================================================
  // CÁC HÀM DÀNH RIÊNG CHO QUẢN TRỊ VIÊN (ADMIN-ONLY API / REPOSITORY)
  // ===========================================================================

  /// Lấy danh sách toàn bộ hồ sơ người dùng (Chỉ Admin mới gọi được)
  Future<List<UserProfileModel>> adminGetAllProfiles({
    required String? actorUid,
    String searchQuery = '',
    String roleFilter = 'all',
    String levelFilter = 'all',
  }) async {
    await verifyAdminActor(actorUid);

    if (!_useSqlite) {
      final cleanQuery = searchQuery.trim().toLowerCase();
      return _memoryProfiles.values.where((p) {
        if (cleanQuery.isNotEmpty) {
          final match = p.displayName.toLowerCase().contains(cleanQuery) ||
              p.email.toLowerCase().contains(cleanQuery) ||
              p.uid.toLowerCase().contains(cleanQuery);
          if (!match) return false;
        }
        if (roleFilter != 'all' && p.role != roleFilter) return false;
        if (levelFilter != 'all' &&
            p.cefrLevel.toUpperCase() != levelFilter.toUpperCase()) {
          return false;
        }
        return true;
      }).toList();
    }

    final db = await _dbHelper.database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    final cleanQuery = searchQuery.trim().toLowerCase();
    if (cleanQuery.isNotEmpty) {
      whereClauses.add(
        '(LOWER(display_name) LIKE ? OR LOWER(email) LIKE ? OR LOWER(uid) LIKE ?)',
      );
      whereArgs.addAll(['%$cleanQuery%', '%$cleanQuery%', '%$cleanQuery%']);
    }

    if (roleFilter != 'all' &&
        (roleFilter == AppConstants.roleAdmin ||
            roleFilter == AppConstants.roleUser)) {
      whereClauses.add('role = ?');
      whereArgs.add(roleFilter);
    }

    if (levelFilter != 'all' &&
        AppConstants.cefrLevels.contains(levelFilter.toUpperCase())) {
      whereClauses.add('cefr_level = ?');
      whereArgs.add(levelFilter.toUpperCase());
    }

    final rows = await db.query(
      'user_profiles',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: "CASE WHEN role = 'admin' THEN 0 ELSE 1 END, updated_at DESC",
    );

    return rows.map((r) => UserProfileModel.fromMap(r)).toList();
  }

  /// Admin cập nhật hồ sơ, cấp độ CEFR, vai trò và trạng thái hoạt động của người dùng
  Future<UserProfileModel> adminUpdateUserProfile({
    required String? actorUid,
    required String targetUid,
    required String displayName,
    required String bio,
    required String learningGoal,
    required String cefrLevel,
    required String role,
    required bool isActive,
  }) async {
    final adminActor = await verifyAdminActor(actorUid);
    final cleanTarget = targetUid.trim();

    if (cleanTarget.isEmpty) {
      throw const ProfileValidationException('Mã người dùng (UID) không hợp lệ.');
    }

    final validationError = UserProfileModel.validateProfileInput(
      displayName: displayName,
      bio: bio,
      learningGoal: learningGoal,
      avatarData: '',
    );
    if (validationError != null) {
      throw ProfileValidationException(validationError);
    }

    final normalizedLevel = cefrLevel.trim().toUpperCase();
    if (!AppConstants.cefrLevels.contains(normalizedLevel)) {
      throw const ProfileValidationException(
        'Cấp độ CEFR không hợp lệ. Chỉ chấp nhận A1, A2, B1, B2, C1.',
      );
    }

    final normalizedRole = role.trim().toLowerCase();
    if (normalizedRole != AppConstants.roleAdmin &&
        normalizedRole != AppConstants.roleUser) {
      throw const ProfileValidationException(
        'Vai trò không hợp lệ. Chỉ chấp nhận admin hoặc user.',
      );
    }

    if (adminActor.uid == cleanTarget) {
      if (normalizedRole != AppConstants.roleAdmin) {
        throw const ProfileValidationException(
          'Không thể tự thu hồi quyền Quản trị viên của chính tài khoản đang đăng nhập.',
        );
      }
      if (!isActive) {
        throw const ProfileValidationException(
          'Không thể tự khóa tài khoản Quản trị viên đang đăng nhập.',
        );
      }
    }

    final existing = await _readRowByUid(cleanTarget);
    if (existing == null) {
      throw const ProfileValidationException(
        'Không tìm thấy hồ sơ người dùng cần cập nhật.',
      );
    }

    final nowIso = DateTime.now().toIso8601String();
    final updated = existing.copyWith(
      displayName: displayName.trim(),
      bio: bio.trim(),
      learningGoal: learningGoal.trim(),
      cefrLevel: normalizedLevel,
      levelUpdatedBy: 'admin',
      role: normalizedRole,
      isActive: isActive,
      updatedAt: nowIso,
    );

    await _writeProfile(updated);
    return updated;
  }

  /// Admin xóa hồ sơ tài khoản người dùng (có kiểm tra an toàn)
  Future<void> adminDeleteUserProfile({
    required String? actorUid,
    required String targetUid,
  }) async {
    final adminActor = await verifyAdminActor(actorUid);
    final cleanTarget = targetUid.trim();

    if (cleanTarget == adminActor.uid) {
      throw const ProfileValidationException(
        'Không thể xóa tài khoản Quản trị viên đang đăng nhập.',
      );
    }
    if (cleanTarget == 'local_learner') {
      throw const ProfileValidationException(
        'Không thể xóa hồ sơ học tập mặc định trên thiết bị (local_learner).',
      );
    }

    if (!_useSqlite) {
      if (!_memoryProfiles.containsKey(cleanTarget)) {
        throw const ProfileValidationException(
          'Không tìm thấy hồ sơ người dùng để xóa.',
        );
      }
      _memoryProfiles.remove(cleanTarget);
      return;
    }

    final db = await _dbHelper.database;
    _memoryProfiles.remove(cleanTarget);
    final deletedCount = await db.delete(
      'user_profiles',
      where: 'uid = ?',
      whereArgs: [cleanTarget],
    );
    if (deletedCount == 0) {
      throw const ProfileValidationException(
        'Không tìm thấy hồ sơ người dùng để xóa.',
      );
    }
  }
}
