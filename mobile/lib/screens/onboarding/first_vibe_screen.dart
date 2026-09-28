import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../services/sound_manager.dart';
import '../../ui/chips/energy_chip.dart';
import '../../ui/glass/glass_container.dart';
import '../../ui/glass/glass_button.dart';
import '../../ui/glass/cosmic_background.dart';

class FirstVibeScreen extends StatefulWidget {
  const FirstVibeScreen({super.key});

  @override
  State<FirstVibeScreen> createState() => _FirstVibeScreenState();
}

class _FirstVibeScreenState extends State<FirstVibeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onCreateVibe() {
    SoundManager().playMatch();
    context.go('/matching');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingCubit>().state;
    final intent = state.currentIntent;
    final title = intent?.title ?? 'Grab Coffee';
    final icon = intent?.icon ?? '☕';
    final energy = intent?.energy ?? EnergyType.medium;
    final radius = intent?.radiusKm ?? state.profile.radiusKm;

    return Scaffold(
      backgroundColor: VibeTokens.darkBgCosmic,
      body: CosmicBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: VibeTokens.space3),

                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                          onTap: () {
                            SoundManager().playTap();
                            context.go('/location');
                          },
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: VibeTokens.glassFillSubtle,
                              border: Border.all(color: VibeTokens.glassBorderLight),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: VibeTokens.darkTextPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Ready Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: VibeTokens.space4,
                          vertical: VibeTokens.space2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x3310B981),
                          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                          border: Border.all(color: const Color(0x6610B981)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt, size: 14, color: Color(0xFF6EE7B7)),
                            const SizedBox(width: 5),
                            Text(
                              'READY TO LAUNCH',
                              style: VibeTokens.labelSm.copyWith(
                                color: const Color(0xFF6EE7B7),
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 42),
                    ],
                  ),

                  const SizedBox(height: VibeTokens.space5),

                  Text(
                    'Review Your First Vibe',
                    style: VibeTokens.displayLg.copyWith(
                      color: VibeTokens.darkTextPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: VibeTokens.space1),
                  Text(
                    'Verified members in your radius with aligned intention will discover your signal.',
                    style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextSecondary),
                  ),

                  const SizedBox(height: VibeTokens.space5),

                  // Hero Glass Card with Glowing Intention
                  GlassContainer(
                    padding: const EdgeInsets.all(VibeTokens.space6),
                    borderRadius: VibeTokens.radiusXl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0x337C3AED),
                                border: Border.all(color: const Color(0x66A78BFA), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: VibeTokens.glowPurple.withAlpha(60),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(icon, style: const TextStyle(fontSize: 28)),
                            ),
                            const SizedBox(width: VibeTokens.space4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: VibeTokens.titleLg.copyWith(
                                      color: VibeTokens.darkTextPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      EnergyChip(energy: energy, small: true),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0x22FFFFFF),
                                          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                                        ),
                                        child: Text(
                                          '${radius.toStringAsFixed(1)} km radius',
                                          style: VibeTokens.labelSm.copyWith(color: VibeTokens.darkTextSecondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: VibeTokens.space5),

                        const Divider(color: Color(0x18FFFFFF)),

                        const SizedBox(height: VibeTokens.space4),

                        // Optional Mood Context Note
                        Text(
                          'Add context note (optional)',
                          style: VibeTokens.labelLg.copyWith(color: VibeTokens.darkTextPrimary),
                        ),
                        const SizedBox(height: VibeTokens.space2),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0x18FFFFFF),
                            borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                            border: Border.all(color: const Color(0x33FFFFFF)),
                          ),
                          child: TextField(
                            controller: _noteController,
                            maxLines: 2,
                            style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextPrimary),
                            decoration: InputDecoration(
                              hintText: 'e.g. Grabbing iced matcha around 3pm, open to 30 min chat...',
                              hintStyle: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextMuted),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: VibeTokens.space4),

                  // Privacy Callout
                  GlassContainer(
                    padding: const EdgeInsets.all(VibeTokens.space4),
                    borderRadius: VibeTokens.radiusMd,
                    fillColor: const Color(0x0CFFFFFF),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: VibeTokens.glowPurple, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Active for 2 hours · Closes automatically after meetup check-in.',
                            style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Broadcast Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: VibeTokens.space4),
                    child: GlassButton(
                      label: 'Broadcast Vibe & Find People →',
                      variant: GlassButtonVariant.primary,
                      onTap: _onCreateVibe,
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
