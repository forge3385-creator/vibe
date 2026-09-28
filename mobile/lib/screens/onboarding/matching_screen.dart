import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../services/sound_manager.dart';
import '../../ui/glass/glass_container.dart';
import '../../ui/glass/cosmic_background.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _statusStep = 0;

  final List<String> _statusMessages = [
    'Broadcasting intention to local mesh...',
    'Scanning 5.0 km radius for compatible energy...',
    'Evaluating shared interests & public third-places...',
    'Vibe Affinity computed: 8 matches ready!',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _cycleStatus();
    _executeMatching();
  }

  void _cycleStatus() async {
    for (int i = 0; i < _statusMessages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        SoundManager().playTap();
        setState(() => _statusStep = i);
      }
    }
  }

  void _executeMatching() async {
    final cubit = context.read<OnboardingCubit>();
    await cubit.createFirstVibeAndMatch();
    if (mounted) {
      SoundManager().playMatch();
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intent = context.select((OnboardingCubit c) => c.state.currentIntent);
    final title = intent?.title ?? 'Coffee';
    final icon = intent?.icon ?? '☕';

    return Scaffold(
      backgroundColor: VibeTokens.darkBgCosmic,
      body: CosmicBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sonar Radar Concentric Rings
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Ripple Ring
                          Transform.scale(
                            scale: _pulseAnimation.value * 1.35,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: VibeTokens.glowPurple.withAlpha(12),
                                border: Border.all(
                                  color: VibeTokens.glowPurple.withAlpha(35),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          // Middle Ripple Ring
                          Transform.scale(
                            scale: _pulseAnimation.value * 1.15,
                            child: Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: VibeTokens.glowPurple.withAlpha(25),
                                border: Border.all(
                                  color: VibeTokens.glowPurple.withAlpha(60),
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                          // Inner Core Glow Orb
                          Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: VibeTokens.heroGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: VibeTokens.glowPurple.withAlpha(140),
                                    blurRadius: 36,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                icon,
                                style: const TextStyle(fontSize: 44),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: VibeTokens.space8),

                  // Headline
                  Text(
                    'Broadcasting Vibe',
                    style: VibeTokens.displaySm.copyWith(
                      color: VibeTokens.darkTextPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: VibeTokens.space2),
                  Text(
                    title,
                    style: VibeTokens.titleMd.copyWith(
                      color: VibeTokens.brandPurple200,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: VibeTokens.space6),

                  // Dynamic Real-time Status Card
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    borderRadius: VibeTokens.radiusFull,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(VibeTokens.glowCyan),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            _statusMessages[_statusStep],
                            style: VibeTokens.bodySm.copyWith(
                              color: VibeTokens.darkTextPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
