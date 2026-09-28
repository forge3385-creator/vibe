import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Auto navigate after subtle branded intro
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        context.go('/intro');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibeTokens.brandPurple900,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => context.go('/intro'),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Ambient soft purple gradient glow
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        VibeTokens.brandPurple500.withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        VibeTokens.brandPurple700.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Sparkling logo mark
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: VibeTokens.brandPurple800,
                          borderRadius: BorderRadius.circular(VibeTokens.radiusXl),
                          border: Border.all(
                            color: VibeTokens.brandPurple300.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: VibeTokens.brandPurple500.withOpacity(0.4),
                              blurRadius: 32,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_awesome,
                            size: 44,
                            color: VibeTokens.brandPurple100,
                          ),
                        ),
                      ),
                      const SizedBox(height: VibeTokens.space6),
                      // Brand Wordmark
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'VIBE',
                            style: VibeTokens.displayLg.copyWith(
                              color: VibeTokens.neutral000,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '✦',
                            style: TextStyle(
                              color: VibeTokens.brandPurple300,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: VibeTokens.space3),
                      // Gen-Z Brand Line
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space8),
                        child: Text(
                          'Turn intentions into real connections.',
                          textAlign: TextAlign.center,
                          style: VibeTokens.bodyLg.copyWith(
                            color: VibeTokens.brandPurple100.withOpacity(0.9),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: VibeTokens.space6,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Tap anywhere to begin',
                    style: VibeTokens.bodySm.copyWith(
                      color: VibeTokens.brandPurple200.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
