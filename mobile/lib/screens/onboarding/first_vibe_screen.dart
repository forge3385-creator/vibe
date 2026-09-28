import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../ui/chips/energy_chip.dart';
import '../../ui/buttons/primary_button.dart';

class FirstVibeScreen extends StatefulWidget {
  const FirstVibeScreen({super.key});

  @override
  State<FirstVibeScreen> createState() => _FirstVibeScreenState();
}

class _FirstVibeScreenState extends State<FirstVibeScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onCreateVibe() {
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
      backgroundColor: VibeTokens.neutral000,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VibeTokens.neutral800),
          onPressed: () => context.go('/location'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: VibeTokens.space2),
              // Badge
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
                    const Icon(Icons.star, size: 14, color: VibeTokens.brandPurple800),
                    const SizedBox(width: 4),
                    Text(
                      'STEP 5 OF 5 · LAUNCH YOUR VIBE',
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

              Text(
                'Your First Vibe',
                style: VibeTokens.displaySm.copyWith(
                  color: VibeTokens.neutral900,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: VibeTokens.space2),
              Text(
                'Ready to broadcast your intention? Verified peers in your radius with compatible vibes will be matched with you.',
                style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral600),
              ),
              const SizedBox(height: VibeTokens.space6),

              // Highlighted Vibe Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(VibeTokens.space5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFAF5FF),
                      Color(0xFFF3E8FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(VibeTokens.radiusXl),
                  border: Border.all(color: VibeTokens.brandPurple200, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: VibeTokens.brandPurple500.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: VibeTokens.neutral000,
                            borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0E000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
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
                                  color: VibeTokens.brandPurple900,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Broadcasting within ${radius.toStringAsFixed(1)} km',
                                style: VibeTokens.bodySm.copyWith(color: VibeTokens.neutral600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: VibeTokens.space4),
                    const Divider(color: VibeTokens.brandPurple200),
                    const SizedBox(height: VibeTokens.space3),

                    // Details Pill Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(
                          icon: Icons.bolt,
                          text: '${energy.name.toUpperCase()} ENERGY',
                          color: VibeTokens.brandPurple800,
                          bg: VibeTokens.brandPurple100,
                        ),
                        _buildBadge(
                          icon: Icons.place_outlined,
                          text: state.profile.city.isNotEmpty ? state.profile.city : 'Nearby',
                          color: VibeTokens.neutral800,
                          bg: VibeTokens.neutral000,
                        ),
                        _buildBadge(
                          icon: Icons.timer_outlined,
                          text: 'Next 3 Hours',
                          color: VibeTokens.neutral800,
                          bg: VibeTokens.neutral000,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: VibeTokens.space5),

              // Optional note input
              Text(
                'Add a quick thought or note (optional)',
                style: VibeTokens.labelLg.copyWith(color: VibeTokens.neutral800),
              ),
              const SizedBox(height: VibeTokens.space2),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'e.g. In the mood for oat milk latte & good conversation',
                  filled: true,
                  fillColor: VibeTokens.neutral050,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                    borderSide: const BorderSide(color: VibeTokens.neutral200),
                  ),
                ),
              ),

              const Spacer(),

              // Create Vibe Button
              Padding(
                padding: const EdgeInsets.only(bottom: VibeTokens.space4),
                child: PrimaryButton(
                  label: 'Create Vibe ✦',
                  icon: Icons.auto_awesome,
                  onTap: _onCreateVibe,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: VibeTokens.labelSm.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
