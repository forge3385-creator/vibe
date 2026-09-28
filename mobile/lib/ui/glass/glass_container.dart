import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? fillColor;
  final Color? borderColor;
  final Gradient? borderGradient;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = VibeTokens.radiusLg,
    this.blur = VibeTokens.blurStandard,
    this.fillColor,
    this.borderColor,
    this.borderGradient,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor = fillColor ?? VibeTokens.glassFillCard;
    final effectiveBorderGradient = borderGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            borderColor?.withAlpha(120) ?? const Color(0x55FFFFFF),
            borderColor?.withAlpha(40) ?? const Color(0x18FFFFFF),
            const Color(0x33A78BFA),
          ],
        );

    final content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(VibeTokens.space5),
          decoration: BoxDecoration(
            color: effectiveFillColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.transparent,
              width: 0,
            ),
          ),
          child: child,
        ),
      ),
    );

    final wrappedBorder = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: effectiveBorderGradient,
        boxShadow: shadows ??
            [
              BoxShadow(
                color: const Color(0x3D000000),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: VibeTokens.glowPurple.withAlpha(20),
                blurRadius: 18,
                spreadRadius: -4,
              ),
            ],
      ),
      padding: const EdgeInsets.all(1.0), // 1px specular gradient border
      child: content,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: wrappedBorder,
        ),
      );
    }

    return wrappedBorder;
  }
}
