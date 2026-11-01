import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../../data/models/chat_message_model.dart';

class AiChatServiceResult {
  final bool isSuccess;
  final String? reply;
  final String? errorMessage;
  final bool isConfigured;

  const AiChatServiceResult({
    required this.isSuccess,
    this.reply,
    this.errorMessage,
    this.isConfigured = true,
  });

  factory AiChatServiceResult.success(String reply) => AiChatServiceResult(
        isSuccess: true,
        reply: reply,
      );

  factory AiChatServiceResult.failure(String message, {bool isConfigured = true}) =>
      AiChatServiceResult(
        isSuccess: false,
        errorMessage: message,
        isConfigured: isConfigured,
      );
}

/// Dịch vụ kết nối Trợ lý AI học tiếng Anh qua Cloudflare Worker Backend.
///
/// Nguyên tắc bảo mật & tích hợp:
/// 1. Tuyệt đối không lưu API Key / Secret của nhà cung cấp AI trong mã nguồn Flutter,
///    --dart-define, SharedPreferences hay database máy khách.
/// 2. Toàn bộ logic gọi AI (Gemini, OpenAI, Workers AI), prompt hệ thống chuẩn sư phạm
///    và khóa bí mật được lưu trữ và bảo vệ tại máy chủ backend.
/// 3. Hỗ trợ xác thực phiên người dùng qua Firebase ID Token khi có yêu cầu.
/// 4. Giới hạn kích thước tin nhắn và kiểm soát timeout mạng chặt chẽ.
class AiChatService {
  static final AiChatService _instance = AiChatService._internal();
  factory AiChatService() => _instance;
  AiChatService._internal();

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
    final explicit = _envAiChatBackendUrl.trim();
    if (explicit.isNotEmpty) {
      try {
        final parsed = Uri.parse(explicit);
        // Nếu người dùng truyền domain gốc (không có path hoặc path là / hoặc /auth/verify-captcha)
        if (parsed.path.isEmpty || parsed.path == '/' || parsed.path == '/auth/verify-captcha') {
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

    return '';
  }

  bool get isConfigured => endpointUrl.isNotEmpty;

  /// Gửi tin nhắn đến Trợ lý AI học tiếng Anh qua Backend Worker
  Future<AiChatServiceResult> sendMessage({
    required String message,
    List<ChatMessage> history = const [],
    String? idToken,
    http.Client? httpClient,
  }) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      return AiChatServiceResult.failure('Nội dung tin nhắn không được để trống.');
    }

    if (trimmedMessage.length > 2000) {
      return AiChatServiceResult.failure('Tin nhắn quá dài (tối đa 2.000 ký tự).');
    }

    if (!isConfigured) {
      return AiChatServiceResult.failure(
        'Backend AI chưa được cấu hình. Vui lòng truyền --dart-define=AI_CHAT_BACKEND_URL=... khi biên dịch hoặc triển khai Cloudflare Worker.',
        isConfigured: false,
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

    final client = httpClient ?? http.Client();
    final shouldCloseClient = httpClient == null;

    try {
      final uri = Uri.parse(endpointUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (idToken != null && idToken.trim().isNotEmpty)
          'Authorization': 'Bearer ${idToken.trim()}',
      };

      final body = jsonEncode({
        'message': trimmedMessage,
        'history': sanitizedHistory,
      });

      final response = await client
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['ok'] == true && data['reply'] != null) {
          return AiChatServiceResult.success(data['reply'].toString());
        }
        return AiChatServiceResult.failure(
          data['error']?.toString() ?? 'Máy chủ không trả về câu trả lời hợp lệ.',
        );
      }

      if (response.statusCode == 401) {
        return AiChatServiceResult.failure(
          'Yêu cầu xác thực tài khoản: Vui lòng đăng nhập để trò chuyện cùng Trợ lý AI.',
        );
      }

      if (response.statusCode == 503) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final msg = data['error']?.toString();
          return AiChatServiceResult.failure(
            msg ?? 'Dịch vụ AI chưa được cấu hình khóa API (GEMINI_API_KEY) trên máy chủ backend.',
            isConfigured: false,
          );
        } catch (_) {
          return AiChatServiceResult.failure(
            'Dịch vụ AI chưa được cấu hình khóa API trên máy chủ backend.',
            isConfigured: false,
          );
        }
      }

      if (response.statusCode == 504) {
        return AiChatServiceResult.failure(
          'Dịch vụ AI phản hồi quá thời gian cho phép (timeout). Vui lòng thử lại sau giây lát.',
        );
      }

      // Lỗi khác từ backend
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final errMsg = data['error'] ?? data['message'];
        if (errMsg != null) {
          return AiChatServiceResult.failure(errMsg.toString());
        }
      } catch (_) {}

      return AiChatServiceResult.failure(
        'Lỗi từ máy chủ backend (HTTP ${response.statusCode}). Vui lòng thử lại sau.',
      );
    } on TimeoutException {
      return AiChatServiceResult.failure(
        'Quá thời gian kết nối tới máy chủ AI (timeout sau 25 giây). Vui lòng kiểm tra lại đường truyền mạng và thử lại.',
      );
    } on SocketException {
      return AiChatServiceResult.failure(
        'Không thể kết nối đến máy chủ backend AI. Vui lòng kiểm tra kết nối mạng Internet của thiết bị.',
      );
    } catch (e) {
      if (!kIsWeb && e.toString().contains('Failed host lookup')) {
        return AiChatServiceResult.failure(
          'Không tìm thấy máy chủ backend AI. Vui lòng kiểm tra lại địa chỉ URL cấu hình.',
        );
      }
      return AiChatServiceResult.failure(
        'Không thể kết nối đến Trợ lý AI: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    } finally {
      if (shouldCloseClient) {
        client.close();
      }
    }
  }
}
