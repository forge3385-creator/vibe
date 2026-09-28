import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../services/sound_manager.dart';
import '../../ui/glass/cosmic_background.dart';

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
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      SoundManager().playStep();
    });

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
      backgroundColor: VibeTokens.darkBgCosmic,
      body: CosmicBackground(
        child: GestureDetector(
          onTap: () {
            SoundManager().playTap();
            context.go('/intro');
          },
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Futuristic Emblem Orb
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: VibeTokens.heroGradient,
                            boxShadow: [
                              BoxShadow(
                                color: VibeTokens.glowPurple.withAlpha(140),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: VibeTokens.glowCyan.withAlpha(60),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.auto_awesome,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: VibeTokens.space5),

                        // Wordmark
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'VIBE',
                              style: VibeTokens.displayLg.copyWith(
                                color: VibeTokens.darkTextPrimary,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4.0,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '✦',
                              style: TextStyle(
                                fontSize: 24,
                                color: VibeTokens.glowPurple,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: VibeTokens.space2),

                        // Tagline
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: VibeTokens.glassFillSubtle,
                            borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                            border: Border.all(color: VibeTokens.glassBorderLight),
                          ),
                          child: Text(
                            'INTENTION TO REAL-WORLD CONNECTION',
                            style: VibeTokens.labelSm.copyWith(
                              color: VibeTokens.brandPurple200,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
