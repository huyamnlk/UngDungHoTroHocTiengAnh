import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AntiBotVerificationResult {
  final bool isVerified;
  final String message;
  final String? verificationId;

  const AntiBotVerificationResult({
    required this.isVerified,
    required this.message,
    this.verificationId,
  });
}

/// Dịch vụ xác minh chống Bot (Cloudflare Turnstile / Google reCAPTCHA Enterprise)
/// tuân thủ nguyên tắc bảo mật:
/// - Client chỉ giữ `CAPTCHA_SITE_KEY` công khai.
/// - Tuyệt đối KHÔNG nhúng `CAPTCHA_SECRET_KEY` trong mã nguồn Flutter client.
/// - Token từ widget CAPTCHA bắt buộc phải gửi lên `CAPTCHA_VERIFY_URL` (Backend/Cloud Function)
///   để xác minh phía server trước khi cho phép Đăng ký / Đăng nhập.
/// - Không sử dụng câu hỏi toán học tự chế hoặc checkbox giả để coi là đã vượt qua kiểm tra bảo mật.
class AntiBotService {
  static final AntiBotService _instance = AntiBotService._internal();
  factory AntiBotService() => _instance;
  AntiBotService._internal();

  static const String providerName = String.fromEnvironment(
    'CAPTCHA_PROVIDER',
    defaultValue: 'cloudflare_turnstile',
  );

  static const String siteKey = String.fromEnvironment(
    'CAPTCHA_SITE_KEY',
    defaultValue: '',
  );

  static const String verifyUrl = String.fromEnvironment(
    'CAPTCHA_VERIFY_URL',
    defaultValue: '',
  );

  bool get isConfigured =>
      siteKey.trim().isNotEmpty && verifyUrl.trim().isNotEmpty;

  List<String> get missingConfigItems {
    final missing = <String>[];
    if (siteKey.trim().isEmpty) {
      missing.add(
        'CAPTCHA_SITE_KEY (Site key công khai từ Cloudflare Turnstile / Google reCAPTCHA)',
      );
    }
    if (verifyUrl.trim().isEmpty) {
      missing.add(
        'CAPTCHA_VERIFY_URL (Endpoint Backend/Cloud Function xác minh token phía server)',
      );
    }
    return missing;
  }

  /// Xác minh token CAPTCHA với Backend Server (nơi lưu trữ Secret Key an toàn)
  Future<AntiBotVerificationResult> verifyTokenOnServer({
    required String captchaResponseToken,
    required String action,
  }) async {
    if (!isConfigured) {
      return const AntiBotVerificationResult(
        isVerified: false,
        message: 'Chống bot (Anti-Bot) chưa thể bật thực sự vì thiếu cấu hình CAPTCHA_SITE_KEY hoặc CAPTCHA_VERIFY_URL phía server. Ứng dụng không tạo trạng thái vượt qua giả.',
      );
    }

    final cleanedToken = captchaResponseToken.trim();
    if (cleanedToken.isEmpty) {
      return const AntiBotVerificationResult(
        isVerified: false,
        message: 'Vui lòng hoàn thành bước xác thực chống bot và cung cấp mã token hợp lệ từ nhà cung cấp CAPTCHA.',
      );
    }

    try {
      final uri = Uri.parse(verifyUrl.trim());
      final response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'provider': providerName,
              'siteKey': siteKey,
              'token': cleanedToken,
              'action': action,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final success = data['success'] == true || data['verified'] == true;
        if (success) {
          return AntiBotVerificationResult(
            isVerified: true,
            message: 'Xác minh chống bot phía server thành công.',
            verificationId: data['verificationId']?.toString(),
          );
        }
        return AntiBotVerificationResult(
          isVerified: false,
          message:
              data['message']?.toString() ??
              'Máy chủ từ chối token CAPTCHA. Vui lòng thử lại.',
        );
      } else {
        return AntiBotVerificationResult(
          isVerified: false,
          message:
              'Máy chủ xác minh chống bot phản hồi mã lỗi ${response.statusCode}.',
        );
      }
    } on TimeoutException {
      return const AntiBotVerificationResult(
        isVerified: false,
        message: 'Hết thời gian chờ kết nối đến máy chủ xác minh chống bot (Timeout). Vui lòng kiểm tra mạng.',
      );
    } catch (_) {
      return const AntiBotVerificationResult(
        isVerified: false,
        message:
            'Không thể kết nối tới endpoint xác minh chống bot phía server.',
      );
    }
  }
}
