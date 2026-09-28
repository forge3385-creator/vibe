import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../ui/buttons/primary_button.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibeTokens.neutral000,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/age-gate'),
            child: Text(
              'Skip',
              style: VibeTokens.labelLg.copyWith(color: VibeTokens.neutral500),
            ),
          ),
          const SizedBox(width: VibeTokens.space2),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: VibeTokens.space2),
              // Brand Eyebrow Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: VibeTokens.space3,
                  vertical: VibeTokens.space1,
                ),
                decoration: BoxDecoration(
                  color: VibeTokens.brandPurple050,
                  borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                  border: Border.all(color: VibeTokens.brandPurple200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 14, color: VibeTokens.brandPurple800),
                    const SizedBox(width: 4),
                    Text(
                      'A NEW SOCIAL REALITY',
                      style: VibeTokens.labelSm.copyWith(
                        color: VibeTokens.brandPurple800,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: VibeTokens.space4),
              // Headline
              Text(
                "You don't need\nanother dating app.",
                style: VibeTokens.displayLg.copyWith(
                  color: VibeTokens.neutral900,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: VibeTokens.space3),
              Text(
                "Find people who actually want to do the exact same things you do, right now.",
                style: VibeTokens.bodyLg.copyWith(
                  color: VibeTokens.neutral600,
                ),
              ),
              const SizedBox(height: VibeTokens.space6),

              // 3 Value Proposition Cards
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildFeatureCard(
                      icon: Icons.explore_outlined,
                      title: 'Meet people nearby',
                      subtitle: 'Connect with verified peers within your immediate radius based on shared vibes.',
                    ),
                    const SizedBox(height: VibeTokens.space3),
                    _buildFeatureCard(
                      icon: Icons.lightbulb_outline,
                      title: 'Find things to do',
                      subtitle: 'From spontaneous coffee to study sessions, music, and art walks.',
                    ),
                    const SizedBox(height: VibeTokens.space3),
                    _buildFeatureCard(
                      icon: Icons.groups_outlined,
                      title: 'Turn plans into real meetups',
                      subtitle: 'Safe, low-pressure gatherings in public spots with zero endless chat or ghosting.',
                    ),
                  ],
                ),
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.only(bottom: VibeTokens.space4, top: VibeTokens.space2),
                child: PrimaryButton(
                  label: 'Continue →',
                  onTap: () => context.go('/age-gate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(VibeTokens.space4),
      decoration: BoxDecoration(
        color: VibeTokens.neutral050,
        borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
        border: Border.all(color: VibeTokens.neutral200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(VibeTokens.space2),
            decoration: BoxDecoration(
              color: VibeTokens.brandPurple100,
              borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
            ),
            child: Icon(icon, size: 22, color: VibeTokens.brandPurple800),
          ),
          const SizedBox(width: VibeTokens.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: VibeTokens.titleMd.copyWith(
                    color: VibeTokens.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: VibeTokens.bodySm.copyWith(
                    color: VibeTokens.neutral600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
