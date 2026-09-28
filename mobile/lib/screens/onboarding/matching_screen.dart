import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _executeMatching();
  }

  void _executeMatching() async {
    final cubit = context.read<OnboardingCubit>();
    await cubit.createFirstVibeAndMatch();
    if (mounted) {
      context.go('/home');
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
      backgroundColor: VibeTokens.brandPurple900,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branded animated matching radar
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: VibeTokens.brandPurple700.withOpacity(0.3),
                            ),
                          ),
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: VibeTokens.brandPurple600.withOpacity(0.5),
                            ),
                          ),
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: VibeTokens.brandPurple500,
                              boxShadow: [
                                BoxShadow(
                                  color: VibeTokens.brandPurple400.withOpacity(0.5),
                                  blurRadius: 24,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: VibeTokens.space8),

                // Sparkles row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('✦', style: TextStyle(color: VibeTokens.brandPurple300, fontSize: 18)),
                    SizedBox(width: 8),
                    Text('✦', style: TextStyle(color: VibeTokens.brandPurple200, fontSize: 24)),
                    SizedBox(width: 8),
                    Text('✦', style: TextStyle(color: VibeTokens.brandPurple300, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: VibeTokens.space4),

                Text(
                  'Finding your people...',
                  style: VibeTokens.displaySm.copyWith(
                    color: VibeTokens.neutral000,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: VibeTokens.space2),
                Text(
                  'Matching your "$title" intention with verified peers nearby...',
                  textAlign: TextAlign.center,
                  style: VibeTokens.bodyMd.copyWith(
                    color: VibeTokens.brandPurple100.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: VibeTokens.space8),

                // Subtle progress indicator
                SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      backgroundColor: VibeTokens.brandPurple800,
                      valueColor: AlwaysStoppedAnimation<Color>(VibeTokens.brandPurple300),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
