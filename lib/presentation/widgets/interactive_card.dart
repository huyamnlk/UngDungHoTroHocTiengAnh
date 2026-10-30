import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Thẻ tương tác thông minh hỗ trợ hiệu ứng Hover mượt mà trên Desktop/Web
/// và phản hồi chạm (Ripple/Tap) trên Điện thoại/Tablet, tôn trọng cấu hình giảm chuyển động.
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hoverBorderColor;
  final bool enableHoverScale;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = 18,
    this.backgroundColor,
    this.borderColor,
    this.hoverBorderColor,
    this.enableHoverScale = true,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final duration = disableAnimations ? Duration.zero : const Duration(milliseconds: 180);

    final baseBg = widget.backgroundColor ?? context.cardBg;
    final effectiveBg = (_isHovered && widget.onTap != null) ? context.cardHoverBg : baseBg;

    final baseBorder = widget.borderColor ?? context.borderCol;
    final effectiveBorder = _isHovered
        ? (widget.hoverBorderColor ?? AppColors.primary.withValues(alpha: context.isDark ? 0.65 : 0.45))
        : baseBorder;

    final scale = (_isHovered && widget.enableHoverScale && !disableAnimations && widget.onTap != null)
        ? 1.008
        : 1.0;

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: AnimatedScale(
          scale: scale,
          duration: duration,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: effectiveBg,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: effectiveBorder,
                width: _isHovered ? 1.3 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? AppColors.primary.withValues(alpha: context.isDark ? 0.16 : 0.08)
                      : Colors.black.withValues(alpha: context.isDark ? 0.22 : 0.03),
                  blurRadius: _isHovered ? 16 : 10,
                  offset: Offset(0, _isHovered ? 6 : 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                hoverColor: Colors.transparent,
                highlightColor: AppColors.primary.withValues(alpha: 0.06),
                splashColor: AppColors.primary.withValues(alpha: 0.1),
                child: Padding(
                  padding: widget.padding ?? const EdgeInsets.all(18),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
