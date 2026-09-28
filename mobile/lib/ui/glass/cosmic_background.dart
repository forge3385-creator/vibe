import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

class CosmicBackground extends StatefulWidget {
  final Widget child;
  final bool animate;

  const CosmicBackground({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Deep Cosmic Obsidian Canvas
        Container(
          decoration: const BoxDecoration(
            color: VibeTokens.darkBgCosmic,
          ),
        ),

        // Ambient Animated Glowing Orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final double orb1X = -0.4 + 0.15 * math.sin(t * 2 * math.pi);
            final double orb1Y = -0.5 + 0.15 * math.cos(t * 2 * math.pi);
            final double orb2X = 0.5 + 0.2 * math.cos(t * 2 * math.pi);
            final double orb2Y = 0.4 + 0.15 * math.sin(t * 2 * math.pi);
            final double orb3X = 0.0 + 0.1 * math.sin(t * math.pi);
            final double orb3Y = 0.8 + 0.1 * math.cos(t * math.pi);

            return Stack(
              children: [
                // Top Left Violet Nebula Orb
                Positioned(
                  left: (MediaQuery.of(context).size.width * 0.5) + (orb1X * 300) - 200,
                  top: (MediaQuery.of(context).size.height * 0.3) + (orb1Y * 200) - 200,
                  child: Container(
                    width: 440,
                    height: 440,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF7C3AED).withAlpha(65),
                          const Color(0xFF4C1D95).withAlpha(30),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 0.85],
                      ),
                    ),
                  ),
                ),

                // Bottom Right Indigo / Cyan Glow Orb
                Positioned(
                  left: (MediaQuery.of(context).size.width * 0.5) + (orb2X * 300) - 180,
                  top: (MediaQuery.of(context).size.height * 0.6) + (orb2Y * 200) - 180,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF6366F1).withAlpha(55),
                          const Color(0xFF06B6D4).withAlpha(20),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 0.9],
                      ),
                    ),
                  ),
                ),

                // Center Lower Subtle Magenta Pulse
                Positioned(
                  left: (MediaQuery.of(context).size.width * 0.5) + (orb3X * 200) - 150,
                  top: (MediaQuery.of(context).size.height * 0.8) + (orb3Y * 150) - 150,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFD946EF).withAlpha(35),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.75],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Subtle Ambient Mesh Grid
        Positioned.fill(
          child: CustomPaint(
            painter: _SubtleGridPainter(),
          ),
        ),

        // Foreground Content
        widget.child,
      ],
    );
  }
}

class _SubtleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x06FFFFFF)
      ..strokeWidth = 0.5;

    const double step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
