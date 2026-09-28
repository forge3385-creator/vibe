import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../services/sound_manager.dart';
import '../../ui/glass/glass_container.dart';
import '../../ui/glass/glass_button.dart';
import '../../ui/glass/cosmic_background.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibeTokens.darkBgCosmic,
      body: CosmicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: VibeTokens.space3),

                // Top Bar with Skip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: VibeTokens.glassFillSubtle,
                        borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                        border: Border.all(color: VibeTokens.glassBorderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: VibeTokens.glowPurple),
                          const SizedBox(width: 6),
                          Text(
                            'VIBE',
                            style: VibeTokens.labelSm.copyWith(
                              color: VibeTokens.darkTextPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Skip Action
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                        onTap: () {
                          SoundManager().playTap();
                          context.go('/age-gate');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: VibeTokens.glassFillSubtle,
                            borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                            border: Border.all(color: VibeTokens.glassBorderLight),
                          ),
                          child: Text(
                            'Skip',
                            style: VibeTokens.labelSm.copyWith(
                              color: VibeTokens.darkTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: VibeTokens.space5),

                // Eyebrow Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x287C3AED),
                    borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                    border: Border.all(color: const Color(0x66A78BFA)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, size: 14, color: VibeTokens.brandPurple200),
                      const SizedBox(width: 4),
                      Text(
                        'INTENTION-DRIVEN CONNECTION',
                        style: VibeTokens.labelSm.copyWith(
                          color: VibeTokens.brandPurple200,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: VibeTokens.space3),

                // Futuristic Cinematic Headline
                Text(
                  "Real World.\nZero Endless Swiping.",
                  style: VibeTokens.displayLg.copyWith(
                    color: VibeTokens.darkTextPrimary,
                    letterSpacing: -0.8,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: VibeTokens.space2),
                Text(
                  "Match with people nearby who want to do the exact same thing as you, right now.",
                  style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextSecondary),
                ),

                const SizedBox(height: VibeTokens.space5),

                // 3 Value Proposition Glass Cards
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildFeatureCard(
                        icon: Icons.radar_rounded,
                        iconColor: VibeTokens.glowPurple,
                        title: 'Proximity Radar',
                        subtitle: 'Locate peers within 1–15 km aligned to your exact intent and energy level.',
                      ),
                      const SizedBox(height: VibeTokens.space3),
                      _buildFeatureCard(
                        icon: Icons.coffee_rounded,
                        iconColor: VibeTokens.glowCyan,
                        title: 'Curated Public Safe Spots',
                        subtitle: 'Third-place hubs: verified cafes, parks, and campuses with safe check-ins.',
                      ),
                      const SizedBox(height: VibeTokens.space3),
                      _buildFeatureCard(
                        icon: Icons.lock_outline_rounded,
                        iconColor: VibeTokens.glowPink,
                        title: 'Zero-Retention Privacy',
                        subtitle: 'Encrypted journals and transient chats. We never monetize personal chats or locations.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: VibeTokens.space3),

                // Continue CTA
                Padding(
                  padding: const EdgeInsets.only(bottom: VibeTokens.space4),
                  child: GlassButton(
                    label: 'Get Started →',
                    variant: GlassButtonVariant.primary,
                    onTap: () {
                      SoundManager().playStep();
                      context.go('/age-gate');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(VibeTokens.space4),
      borderRadius: VibeTokens.radiusLg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(35),
              borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
              border: Border.all(color: iconColor.withAlpha(70)),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: VibeTokens.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: VibeTokens.titleMd.copyWith(
                    color: VibeTokens.darkTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: VibeTokens.bodySm.copyWith(
                    color: VibeTokens.darkTextSecondary,
                    height: 1.4,
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
