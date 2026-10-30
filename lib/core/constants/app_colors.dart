import 'package:flutter/material.dart';

/// Bảng màu hiện đại theo phong cách Material 3
/// Hỗ trợ cả Light mode và Dark mode hài hòa, độ tương phản cao đạt chuẩn accessibility (WCAG AA).
class AppColors {
  AppColors._();

  // Primary palette (Vibrant Royal Blue / Indigo)
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryContainer = Color(0xFFEFF6FF);
  static const Color darkPrimaryContainer = Color(0xFF1E3A8A);

  // Secondary palette (Teal / Cyan)
  static const Color secondary = Color(0xFF38BDF8);
  static const Color secondaryContainer = Color(0xFFE0F2FE);

  // Accent & Functional colors
  static const Color accent = Color(0xFF8B5CF6);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color darkSuccessLight = Color(0xFF064E3B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color darkWarningLight = Color(0xFF451A03);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEF2F2);
  static const Color darkDangerLight = Color(0xFF450A0A);

  // Background & Surfaces (Light - Clean & Soft Slate)
  static const Color background = Color(0xFFF1F5F9);
  static const Color surface = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color cardHover = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFCBD5E1);

  // Background & Surfaces (Dark - Deep Navy Slate & Elevated Surfaces)
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkCardHover = Color(0xFF263449);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkBorder = Color(0xFF283548);
  static const Color darkDivider = Color(0xFF1E293B);

  // Status Colors for Learning
  static const Color statusNew = Color(0xFF64748B);
  static const Color statusReview = Color(0xFFF59E0B);
  static const Color statusMastered = Color(0xFF10B981);
}

/// Tiện ích lấy màu động theo chế độ Sáng / Tối trực tiếp từ BuildContext
extension AppThemeContextExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get scaffoldBg => isDark ? AppColors.darkBackground : AppColors.background;
  Color get cardBg => isDark ? AppColors.darkCard : Colors.white;
  Color get cardHoverBg => isDark ? AppColors.darkCardHover : AppColors.cardHover;
  Color get surfaceBg => isDark ? AppColors.darkSurface : Colors.white;
  Color get sidebarBg => isDark ? const Color(0xFF0F172A) : Colors.white;
  Color get textPrimaryColor => isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get textSecondaryColor => isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get textMutedColor => isDark ? AppColors.darkTextMuted : AppColors.textMuted;
  Color get borderCol => isDark ? AppColors.darkBorder : AppColors.border;
  Color get primaryAccent => isDark ? AppColors.primaryLight : AppColors.primaryDark;
  Color get primaryContainerCol =>
      isDark ? AppColors.darkPrimaryContainer.withValues(alpha: 0.55) : AppColors.primaryContainer;
  Color get activeNavBg =>
      isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.45) : const Color(0xFFEFF6FF);
  Color get activeNavBorder =>
      isDark ? const Color(0xFF3B82F6).withValues(alpha: 0.55) : const Color(0xFFBFDBFE);
  Color get successLightCol =>
      isDark ? AppColors.darkSuccessLight.withValues(alpha: 0.6) : AppColors.successLight;
  Color get warningLightCol =>
      isDark ? AppColors.darkWarningLight.withValues(alpha: 0.6) : AppColors.warningLight;
  Color get dangerLightCol =>
      isDark ? AppColors.darkDangerLight.withValues(alpha: 0.6) : AppColors.dangerLight;
}
