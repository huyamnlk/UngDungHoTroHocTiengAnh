import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../../data/models/chat_message_model.dart';

enum AiChatErrorType {
  none,
  validation,
  network,
  timeout,
  unauthorized,
  backendUnconfigured,
  aiProvider,
  rateLimited,
  unknown,
}

class AiChatServiceResult {
  final bool isSuccess;
  final String? reply;
  final String? errorMessage;
  final bool isConfigured;
  final AiChatErrorType errorType;
  final String errorCode;
  final int statusCode;
  final bool retriedAfterRefresh;

  const AiChatServiceResult({
    required this.isSuccess,
    this.reply,
    this.errorMessage,
    this.isConfigured = true,
    this.errorType = AiChatErrorType.none,
    this.errorCode = '',
    this.statusCode = 200,
    this.retriedAfterRefresh = false,
  });

  factory AiChatServiceResult.success(
    String reply, {
    bool retriedAfterRefresh = false,
  }) =>
      AiChatServiceResult(
        isSuccess: true,
        reply: reply,
        errorType: AiChatErrorType.none,
        statusCode: 200,
        retriedAfterRefresh: retriedAfterRefresh,
      );

  factory AiChatServiceResult.failure(
    String message, {
    bool isConfigured = true,
    AiChatErrorType errorType = AiChatErrorType.unknown,
    String errorCode = '',
    int statusCode = 500,
    bool retriedAfterRefresh = false,
  }) =>
      AiChatServiceResult(
        isSuccess: false,
        errorMessage: message,
        isConfigured: isConfigured,
        errorType: errorType,
        errorCode: errorCode,
        statusCode: statusCode,
        retriedAfterRefresh: retriedAfterRefresh,
      );
}

/// Dịch vụ kết nối Trợ lý AI học tiếng Anh qua Cloudflare Worker Backend.
///
/// Nguyên tắc bảo mật & tích hợp:
/// 1. Tuyệt đối không lưu API Key / Secret của nhà cung cấp AI trong mã nguồn Flutter,
///    --dart-define, SharedPreferences hay database máy khách.
/// 2. Toàn bộ logic gọi AI (Gemini, OpenAI, Workers AI), prompt hệ thống chuẩn sư phạm
///    và khóa bí mật được lưu trữ và bảo vệ tại máy chủ backend.
/// 3. Hỗ trợ cả Khách (không gửi Authorization) và Người đã đăng nhập (xác thực Firebase ID Token).
///    Tuyệt đối không hạ request có token sai/hết hạn thành khách.
/// 4. Hỗ trợ làm mới token hết hạn tối đa 1 lần và kiểm soát timeout mạng chặt chẽ.
class AiChatService {
  static final AiChatService _instance = AiChatService._internal();

  factory AiChatService({
    String? endpointUrlOverride,
    http.Client? httpClient,
  }) {
    if (endpointUrlOverride != null || httpClient != null) {
      return AiChatService.custom(
        endpointUrlOverride: endpointUrlOverride,
        httpClient: httpClient,
      );
    }
    return _instance;
  }

  AiChatService._internal()
      : endpointUrlOverride = null,
        httpClient = null;

  AiChatService.custom({
    this.endpointUrlOverride,
    this.httpClient,
  });

  final String? endpointUrlOverride;
  final http.Client? httpClient;

  static const String defaultWorkerChatEndpoint =
      'https://english-buddy-turnstile.english-buddy-giahu2026.workers.dev/api/chat';

  static const String _envAiChatBackendUrl = String.fromEnvironment(
    'AI_CHAT_BACKEND_URL',
    defaultValue: '',
  );

  static const String _envCaptchaVerifyUrl = String.fromEnvironment(
    'CAPTCHA_VERIFY_URL',
    defaultValue: '',
  );

  static const String _envAuthBackendUrl = String.fromEnvironment(
    'AUTH_BACKEND_URL',
    defaultValue: '',
  );

  /// Phân giải URL endpoint của AI Chat Backend
  String get endpointUrl {
    final overrideUrl = endpointUrlOverride;
    if (overrideUrl != null) {
      return overrideUrl.trim();
    }

    final explicit = _envAiChatBackendUrl.trim();
    if (explicit.isNotEmpty) {
      try {
        final parsed = Uri.parse(explicit);
        if (parsed.path.isEmpty ||
            parsed.path == '/' ||
            parsed.path == '/auth/verify-captcha') {
          return parsed.replace(path: '/api/chat').toString();
        }
        return explicit;
      } catch (_) {
        return explicit;
      }
    }

    final captchaUrl = _envCaptchaVerifyUrl.trim();
    if (captchaUrl.isNotEmpty) {
      try {
        final parsed = Uri.parse(captchaUrl);
        return parsed.replace(path: '/api/chat').toString();
      } catch (_) {}
    }

    final authUrl = _envAuthBackendUrl.trim();
    if (authUrl.isNotEmpty) {
      try {
        final parsed = Uri.parse(authUrl);
        return parsed.replace(path: '/api/chat').toString();
      } catch (_) {}
    }

    return defaultWorkerChatEndpoint;
  }

  bool get isConfigured => endpointUrl.isNotEmpty;

  /// Gửi tin nhắn đến Trợ lý AI học tiếng Anh qua Backend Worker
  /// - Nếu `idToken` rỗng/null: gửi ở chế độ Khách (public chat endpoint).
  /// - Nếu `idToken` có giá trị: gửi kèm `Authorization: Bearer <token>`.
  ///   Khi gặp HTTP 401 và có `onRefreshToken`, tự động làm mới token tối đa 1 lần rồi gửi lại.
  Future<AiChatServiceResult> sendMessage({
    required String message,
    List<ChatMessage> history = const [],
    String? idToken,
    Future<String?> Function()? onRefreshToken,
    http.Client? httpClient,
  }) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      return AiChatServiceResult.failure(
        'Nội dung tin nhắn không được để trống.',
        errorType: AiChatErrorType.validation,
        errorCode: 'EMPTY_MESSAGE',
        statusCode: 400,
      );
    }

    if (trimmedMessage.length > 2000) {
      return AiChatServiceResult.failure(
        'Tin nhắn quá dài (tối đa 2.000 ký tự).',
        errorType: AiChatErrorType.validation,
        errorCode: 'MESSAGE_TOO_LONG',
        statusCode: 400,
      );
    }

    if (!isConfigured) {
      return AiChatServiceResult.failure(
        'Backend AI chưa được cấu hình. Vui lòng truyền --dart-define=AI_CHAT_BACKEND_URL=... khi biên dịch hoặc triển khai Cloudflare Worker.',
        isConfigured: false,
        errorType: AiChatErrorType.backendUnconfigured,
        errorCode: 'BACKEND_UNCONFIGURED',
        statusCode: 503,
      );
    }

    // Lọc lịch sử hội thoại chỉ lấy tối đa 15 tin nhắn hoàn chỉnh gần nhất
    final historyPayload = history
        .where((m) => m.status == ChatMessageStatus.sent && m.text.trim().isNotEmpty)
        .toList();
    final recentHistory = historyPayload.length > 15
        ? historyPayload.sublist(historyPayload.length - 15)
        : historyPayload;

    final sanitizedHistory = recentHistory
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'content': m.text.trim(),
            })
        .toList();

    final client = httpClient ?? this.httpClient ?? http.Client();
    final shouldCloseClient = httpClient == null && this.httpClient == null;

    try {
      final uri = Uri.parse(endpointUrl);
      final body = jsonEncode({
        'message': trimmedMessage,
        'history': sanitizedHistory,
      });

      final isAuthenticatedRequest = idToken != null && idToken.trim().isNotEmpty;
      String? activeToken = isAuthenticatedRequest ? idToken.trim() : null;
      bool retriedAfterRefresh = false;

      http.Response response = await _performPost(
        client: client,
        uri: uri,
        body: body,
        bearerToken: activeToken,
      );

      // Nếu người dùng đã đăng nhập gặp 401 (token hết hạn), thử refresh tối đa 1 lần
      // Tuyệt đối KHÔNG hạ cấp request có token lỗi xuống thành khách (guest).
      if (isAuthenticatedRequest &&
          response.statusCode == 401 &&
          onRefreshToken != null) {
        final refreshedToken = await onRefreshToken();
        if (refreshedToken != null && refreshedToken.trim().isNotEmpty) {
          activeToken = refreshedToken.trim();
          retriedAfterRefresh = true;
          response = await _performPost(
            client: client,
            uri: uri,
            body: body,
            bearerToken: activeToken,
          );
        }
      }

      Map<String, dynamic> data = const {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}

      final serverErrorCode = (data['errorCode'] ?? '').toString();
      final serverErrorMsg = (data['error'] ?? data['message'])?.toString();

      if (response.statusCode == 200) {
        if (data['ok'] == true && data['reply'] != null) {
          return AiChatServiceResult.success(
            data['reply'].toString(),
            retriedAfterRefresh: retriedAfterRefresh,
          );
        }
        return AiChatServiceResult.failure(
          serverErrorMsg ?? 'Máy chủ không trả về câu trả lời hợp lệ.',
          errorType: AiChatErrorType.aiProvider,
          errorCode: serverErrorCode.isNotEmpty
              ? serverErrorCode
              : 'INVALID_AI_RESPONSE',
          statusCode: 502,
          retriedAfterRefresh: retriedAfterRefresh,
        );
      }

      if (response.statusCode == 401) {
        return AiChatServiceResult.failure(
          'Phiên đăng nhập đã hết hạn hoặc không hợp lệ (401). Vui lòng thử lại hoặc đăng nhập lại tài khoản.',
          errorType: AiChatErrorType.unauthorized,
          errorCode:
              serverErrorCode.isNotEmpty ? serverErrorCode : 'UNAUTHORIZED',
          statusCode: 401,
          retriedAfterRefresh: retriedAfterRefresh,
        );
      }

      if (response.statusCode == 429) {
        return AiChatServiceResult.failure(
          serverErrorMsg ??
              'Bạn đang gửi câu hỏi quá nhanh (429). Vui lòng đợi ít giây rồi thử lại.',
          errorType: AiChatErrorType.rateLimited,
          errorCode:
              serverErrorCode.isNotEmpty ? serverErrorCode : 'RATE_LIMITED',
          statusCode: 429,
          retriedAfterRefresh: retriedAfterRefresh,
        );
      }

      if (response.statusCode == 503) {
        return AiChatServiceResult.failure(
          serverErrorMsg ??
              'Máy chủ AI chưa hoàn tất cấu hình biến môi trường (503). Vui lòng kiểm tra cấu hình Worker.',
          isConfigured: false,
          errorType: AiChatErrorType.backendUnconfigured,
          errorCode: serverErrorCode.isNotEmpty
              ? serverErrorCode
              : 'BACKEND_UNCONFIGURED',
          statusCode: 503,
          retriedAfterRefresh: retriedAfterRefresh,
        );
      }

      if (response.statusCode == 504) {
        return AiChatServiceResult.failure(
          serverErrorMsg ??
              'Dịch vụ AI phản hồi quá thời gian cho phép (Timeout 504). Vui lòng thử lại sau giây lát.',
          errorType: AiChatErrorType.timeout,
          errorCode:
              serverErrorCode.isNotEmpty ? serverErrorCode : 'AI_TIMEOUT',
          statusCode: 504,
          retriedAfterRefresh: retriedAfterRefresh,
        );
      }

      if (response.statusCode == 502) {
        return AiChatServiceResult.failure(
          serverErrorMsg ??
              'Nhà cung cấp mô hình AI đang tạm thời gián đoạn (502). Vui lòng thử lại.',
          errorType: AiChatErrorType.aiProvider,
          errorCode: serverErrorCode.isNotEmpty
              ? serverErrorCode
              : 'AI_PROVIDER_ERROR',
          statusCode: 502,
          retriedAfterRefresh: retriedAfterRefresh,
        );
      }

      return AiChatServiceResult.failure(
        serverErrorMsg ??
            'Lỗi từ máy chủ backend (HTTP ${response.statusCode}). Vui lòng thử lại sau.',
        errorType: response.statusCode >= 500
            ? AiChatErrorType.aiProvider
            : AiChatErrorType.unknown,
        errorCode: serverErrorCode,
        statusCode: response.statusCode,
        retriedAfterRefresh: retriedAfterRefresh,
      );
    } on TimeoutException {
      return AiChatServiceResult.failure(
        'Quá thời gian kết nối tới máy chủ AI (timeout sau 25 giây). Vui lòng kiểm tra lại đường truyền mạng và thử lại.',
        errorType: AiChatErrorType.timeout,
        errorCode: 'CLIENT_TIMEOUT',
        statusCode: 504,
      );
    } on SocketException {
      return AiChatServiceResult.failure(
        'Không thể kết nối đến máy chủ backend AI. Vui lòng kiểm tra kết nối mạng Internet của thiết bị.',
        errorType: AiChatErrorType.network,
        errorCode: 'NETWORK_ERROR',
        statusCode: 503,
      );
    } catch (e) {
      if (!kIsWeb && e.toString().contains('Failed host lookup')) {
        return AiChatServiceResult.failure(
          'Không tìm thấy máy chủ backend AI. Vui lòng kiểm tra lại kết nối mạng hoặc địa chỉ URL cấu hình.',
          errorType: AiChatErrorType.network,
          errorCode: 'HOST_LOOKUP_FAILED',
          statusCode: 503,
        );
      }
      return AiChatServiceResult.failure(
        'Không thể kết nối đến Trợ lý AI: ${e.toString().replaceAll('Exception:', '').trim()}',
        errorType: AiChatErrorType.network,
        errorCode: 'NETWORK_ERROR',
        statusCode: 503,
      );
    } finally {
      if (shouldCloseClient) {
        client.close();
      }
    }
  }

  Future<http.Response> _performPost({
    required http.Client client,
    required Uri uri,
    required String body,
    String? bearerToken,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (bearerToken != null && bearerToken.isNotEmpty)
        'Authorization': 'Bearer $bearerToken',
    };
    return client
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 25));
  }
}
