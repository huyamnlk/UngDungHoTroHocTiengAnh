import 'package:flutter/material.dart';

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

  /// Định dạng chuỗi ngày tháng ISO sang dd/MM/yyyy HH:mm
  static String formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Chưa học';
    try {
      final dt = DateTime.parse(isoString);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return isoString;
    }
  }
}
