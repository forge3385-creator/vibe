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

class SetVibeScreen extends StatefulWidget {
  const SetVibeScreen({super.key});

  @override
  State<SetVibeScreen> createState() => _SetVibeScreenState();
}

class _SetVibeScreenState extends State<SetVibeScreen> with SingleTickerProviderStateMixin {
  int _selectedActivityIndex = 0;
  EnergyType _selectedEnergy = EnergyType.medium;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _activities = [
    {'title': 'Grab Coffee', 'icon': '☕', 'sub': 'Casual cafe hang & talk', 'glow': VibeTokens.glowPurple},
    {'title': 'Go for a Walk', 'icon': '🚶', 'sub': 'Park stroll or city walk', 'glow': VibeTokens.glowCyan},
    {'title': 'Study Together', 'icon': '📚', 'sub': 'Coworking / quiet focus', 'glow': VibeTokens.glowIndigo},
    {'title': 'Explore City', 'icon': '🌆', 'sub': 'Thrifting & bookstores', 'glow': VibeTokens.glowPink},
    {'title': 'Gaming Hub', 'icon': '🎮', 'sub': 'Co-op or arcade games', 'glow': VibeTokens.glowPurple},
    {'title': 'Food & Bites', 'icon': '🍜', 'sub': 'Street food & dinner', 'glow': VibeTokens.glowCyan},
    {'title': 'Music & Shows', 'icon': '🎵', 'sub': 'Live sets & vinyl digging', 'glow': VibeTokens.glowPink},
    {'title': 'Fitness & Sport', 'icon': '🏃', 'sub': 'Biking, climbing, run', 'glow': VibeTokens.glowIndigo},
    {'title': 'Art & Creative', 'icon': '🎨', 'sub': 'Museum or sketch walk', 'glow': VibeTokens.glowPurple},
    {'title': 'Spontaneous', 'icon': '✨', 'sub': 'Open to whatever feels right', 'glow': VibeTokens.glowCyan},
  ];

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
    _animController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final activity = _activities[_selectedActivityIndex];
    SoundManager().playStep();
    context.read<OnboardingCubit>().setDraftIntent(
      title: activity['title'] as String,
      icon: activity['icon'] as String,
      energy: _selectedEnergy,
    );
    context.go('/location');
  }

  @override
  Widget build(BuildContext context) {
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

                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                          onTap: () {
                            SoundManager().playTap();
                            context.go('/profile-setup');
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

                      // Step Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: VibeTokens.space4,
                          vertical: VibeTokens.space2,
                        ),
                        decoration: BoxDecoration(
                          color: VibeTokens.glassFillSubtle,
                          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                          border: Border.all(color: VibeTokens.glassBorderLight),
                        ),
                        child: Text(
                          'STEP 5 OF 6',
                          style: VibeTokens.labelSm.copyWith(
                            color: VibeTokens.brandPurple200,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(width: 42),
                    ],
                  ),

                  const SizedBox(height: VibeTokens.space4),

                  // Title
                  Text(
                    'Set Your Intention',
                    style: VibeTokens.displayLg.copyWith(
                      color: VibeTokens.darkTextPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: VibeTokens.space1),
                  Text(
                    'What kind of experience are you seeking right now?',
                    style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextSecondary),
                  ),

                  const SizedBox(height: VibeTokens.space4),

                  // Energy Level Segmented Glass Row
                  GlassContainer(
                    padding: const EdgeInsets.all(8),
                    borderRadius: VibeTokens.radiusLg,
                    child: Row(
                      children: [
                        _buildEnergyOption('Chill', EnergyType.low, '🌱'),
                        _buildEnergyOption('Balanced', EnergyType.medium, '⚡'),
                        _buildEnergyOption('Active', EnergyType.high, '🔥'),
                      ],
                    ),
                  ),

                  const SizedBox(height: VibeTokens.space4),

                  // Grid of Activities
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final act = _activities[index];
                        final isSelected = _selectedActivityIndex == index;
                        final Color glowColor = act['glow'] as Color;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: VibeTokens.space3),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
                            onTap: () {
                              SoundManager().playTap();
                              setState(() => _selectedActivityIndex = index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(VibeTokens.space4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
                                color: isSelected
                                    ? glowColor.withAlpha(35)
                                    : VibeTokens.glassFillSubtle,
                                border: Border.all(
                                  color: isSelected
                                      ? glowColor.withAlpha(180)
                                      : VibeTokens.glassBorderLight,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: glowColor.withAlpha(70),
                                          blurRadius: 18,
                                          spreadRadius: -2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? glowColor.withAlpha(60)
                                          : const Color(0x18FFFFFF),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      act['icon'] as String,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                  const SizedBox(width: VibeTokens.space4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          act['title'] as String,
                                          style: VibeTokens.titleMd.copyWith(
                                            color: VibeTokens.darkTextPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          act['sub'] as String,
                                          style: VibeTokens.bodySm.copyWith(
                                            color: isSelected
                                                ? VibeTokens.darkTextPrimary.withAlpha(200)
                                                : VibeTokens.darkTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: glowColor,
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: VibeTokens.space4),
                    child: GlassButton(
                      label: 'Configure Proximity & Location →',
                      variant: GlassButtonVariant.primary,
                      onTap: _onContinue,
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

  Widget _buildEnergyOption(String label, EnergyType energy, String emoji) {
    final isSelected = _selectedEnergy == energy;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
        onTap: () {
          SoundManager().playTap();
          setState(() => _selectedEnergy = energy);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
            color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: VibeTokens.glowPurple.withAlpha(80),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 5),
              Text(
                label,
                style: VibeTokens.labelSm.copyWith(
                  color: isSelected ? Colors.white : VibeTokens.darkTextSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
