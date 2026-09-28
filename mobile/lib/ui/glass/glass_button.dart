import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../services/sound_manager.dart';

enum GlassButtonVariant {
  primary,
  secondary,
  glass,
  danger,
}

class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool disabled;
  final IconData? icon;
  final GlassButtonVariant variant;
  final double height;
  final double? width;

  const GlassButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.disabled = false,
    this.icon,
    this.variant = GlassButtonVariant.primary,
    this.height = 52.0,
    this.width,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _handleTap() {
    if (widget.loading || widget.disabled || widget.onTap == null) return;
    SoundManager().playTap();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = !widget.loading && !widget.disabled && widget.onTap != null;

    Color startColor;
    Color endColor;
    Color textColor;
    List<BoxShadow> glowShadows;

    switch (widget.variant) {
      case GlassButtonVariant.primary:
        startColor = _isHovered ? const Color(0xFF9333EA) : const Color(0xFF7C3AED);
        endColor = _isHovered ? const Color(0xFF7E22CE) : const Color(0xFF6D28D9);
        textColor = VibeTokens.neutral000;
        glowShadows = [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withAlpha(_isHovered ? 90 : 50),
            blurRadius: _isHovered ? 20 : 12,
            offset: const Offset(0, 4),
          ),
        ];
        break;
      case GlassButtonVariant.secondary:
        startColor = const Color(0x33A78BFA);
        endColor = const Color(0x1AA78BFA);
        textColor = VibeTokens.brandPurple200;
        glowShadows = [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withAlpha(20),
            blurRadius: 10,
          ),
        ];
        break;
      case GlassButtonVariant.glass:
        startColor = _isHovered ? const Color(0x28FFFFFF) : const Color(0x14FFFFFF);
        endColor = _isHovered ? const Color(0x18FFFFFF) : const Color(0x0AFFFFFF);
        textColor = VibeTokens.darkTextPrimary;
        glowShadows = [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
        break;
      case GlassButtonVariant.danger:
        startColor = const Color(0xFFDC2626);
        endColor = const Color(0xFF991B1B);
        textColor = VibeTokens.neutral000;
        glowShadows = [
          BoxShadow(
            color: const Color(0xFFEF4444).withAlpha(60),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ];
        break;
    }

    if (!isInteractive) {
      startColor = const Color(0x1AFFFFFF);
      endColor = const Color(0x0DFFFFFF);
      textColor = const Color(0x66FFFFFF);
      glowShadows = [];
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : (_isHovered ? 1.01 : 1.0),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _isHovered ? const Color(0x80FFFFFF) : const Color(0x40FFFFFF),
                  const Color(0x18FFFFFF),
                  const Color(0x33A78BFA),
                ],
              ),
              boxShadow: glowShadows,
            ),
            padding: const EdgeInsets.all(1.0), // 1px specular gradient rim
            child: ClipRRect(
              borderRadius: BorderRadius.circular(VibeTokens.radiusMd - 1),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [startColor, endColor],
                    ),
                    borderRadius: BorderRadius.circular(VibeTokens.radiusMd - 1),
                  ),
                  child: Center(
                    child: widget.loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(widget.icon, size: 18, color: textColor),
                                const SizedBox(width: VibeTokens.space2),
                              ],
                              Text(
                                widget.label,
                                style: VibeTokens.labelLg.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
