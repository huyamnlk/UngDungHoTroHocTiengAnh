import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AvatarPresetOption {
  final String key;
  final String label;
  final IconData icon;
  final List<Color> gradientColors;

  const AvatarPresetOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.gradientColors,
  });
}

class UserAvatarWidget extends StatelessWidget {
  final String avatarData;
  final String displayName;
  final double size;
  final bool showAdminBadge;

  const UserAvatarWidget({
    super.key,
    required this.avatarData,
    required this.displayName,
    this.size = 48,
    this.showAdminBadge = false,
  });

  static const List<AvatarPresetOption> presets = [
    AvatarPresetOption(
      key: 'preset:scholar_blue',
      label: 'Học giả Xanh',
      icon: Icons.school_rounded,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    ),
    AvatarPresetOption(
      key: 'preset:fluent_emerald',
      label: 'Phản xạ Ngọc',
      icon: Icons.record_voice_over_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF047857)],
    ),
    AvatarPresetOption(
      key: 'preset:ielts_purple',
      label: 'Chinh phục IELTS',
      icon: Icons.workspace_premium_rounded,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    ),
    AvatarPresetOption(
      key: 'preset:flame_amber',
      label: 'Chiến binh Streak',
      icon: Icons.local_fire_department_rounded,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFB45309)],
    ),
    AvatarPresetOption(
      key: 'preset:global_cyan',
      label: 'Công dân Toàn cầu',
      icon: Icons.public_rounded,
      gradientColors: [Color(0xFF06B6D4), Color(0xFF0E7490)],
    ),
    AvatarPresetOption(
      key: 'preset:reader_rose',
      label: 'Đam mê Đọc sách',
      icon: Icons.auto_stories_rounded,
      gradientColors: [Color(0xFFF43F5E), Color(0xFFBE123C)],
    ),
    AvatarPresetOption(
      key: 'preset:rocket_indigo',
      label: 'Bứt tốc Từ vựng',
      icon: Icons.rocket_launch_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF3730A3)],
    ),
    AvatarPresetOption(
      key: 'preset:admin_shield',
      label: 'Quản trị Hệ thống',
      icon: Icons.admin_panel_settings_rounded,
      gradientColors: [Color(0xFF0F172A), Color(0xFF334155)],
    ),
  ];

  static Uint8List? tryDecodeDataUri(String dataUri) {
    final clean = dataUri.trim();
    if (!clean.startsWith('data:image/')) return null;
    final commaIdx = clean.indexOf(',');
    if (commaIdx <= 0 || commaIdx >= clean.length - 1) return null;
    try {
      return base64Decode(clean.substring(commaIdx + 1));
    } catch (_) {
      return null;
    }
  }

  String _computeInitials() {
    final clean = displayName.trim();
    if (clean.isEmpty) return 'B';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return clean[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cleanAvatar = avatarData.trim();
    Widget avatarCore;

    if (cleanAvatar.startsWith('data:image/')) {
      final bytes = tryDecodeDataUri(cleanAvatar);
      if (bytes != null && bytes.isNotEmpty) {
        avatarCore = ClipOval(
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildFallbackInitials(),
          ),
        );
      } else {
        avatarCore = _buildFallbackInitials();
      }
    } else if (cleanAvatar.startsWith('http://') ||
        cleanAvatar.startsWith('https://')) {
      avatarCore = ClipOval(
        child: Image.network(
          cleanAvatar,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallbackInitials(),
        ),
      );
    } else if (cleanAvatar.startsWith('preset:')) {
      final preset = presets.firstWhere(
        (p) => p.key == cleanAvatar,
        orElse: () => presets.first,
      );
      avatarCore = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: preset.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(
          preset.icon,
          color: Colors.white,
          size: size * 0.52,
        ),
      );
    } else {
      avatarCore = _buildFallbackInitials();
    }

    if (!showAdminBadge) {
      return SizedBox(width: size, height: size, child: avatarCore);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: avatarCore),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
                border: Border.all(color: context.cardBg, width: 1.5),
              ),
              child: Icon(
                Icons.verified_user_rounded,
                size: (size * 0.26).clamp(10.0, 16.0),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackInitials() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _computeInitials(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
