import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
export '../../l10n/app_localizations.dart';

extension ContextL10nExtension on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? lookupAppLocalizations(const Locale('vi'));
}

class UiHelpers {
  UiHelpers._();

  /// Chuyển đổi mã màu Hex (e.g. #4361EE hoặc 4361EE) sang Flutter Color
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF4361EE);
    }
  }

  /// Ánh xạ tên icon sang IconData Material Icons
  static IconData getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'chat_bubble':
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'flight_takeoff':
      case 'travel':
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'business_center':
      case 'work':
      case 'business':
        return Icons.business_center_outlined;
      case 'school':
      case 'study':
        return Icons.school_outlined;
      case 'restaurant':
      case 'food':
        return Icons.restaurant_rounded;
      case 'devices':
      case 'tech':
      case 'computer':
        return Icons.devices_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  /// Hiển thị thông báo SnackBar nhanh, đẹp
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : isSuccess
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFE63946)
            : isSuccess
                ? const Color(0xFF2EC4B6)
                : const Color(0xFF212529),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Định dạng chuỗi ngày tháng ISO sang chuẩn phù hợp locale
  static String formatDateTime(String? isoString, {BuildContext? context, String? locale}) {
    if (isoString == null || isoString.isEmpty) {
      if (context != null) return context.l10n.statusPending;
      return 'Chưa học';
    }
    try {
      final dt = DateTime.parse(isoString);
      final currentLocale = locale ?? (context != null ? Localizations.localeOf(context).toString() : 'vi');
      if (currentLocale.startsWith('vi')) {
        return DateFormat('dd/MM/yyyy HH:mm').format(dt);
      }
      return DateFormat.yMd(currentLocale).add_jm().format(dt);
    } catch (_) {
      return isoString;
    }
  }

  /// Định dạng số nguyên/thực theo chuẩn locale
  static String formatNumber(num number, {BuildContext? context, String? locale}) {
    final currentLocale = locale ?? (context != null ? Localizations.localeOf(context).toString() : 'vi');
    return NumberFormat.decimalPattern(currentLocale).format(number);
  }
}
