import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../ui/chips/energy_chip.dart';
import '../../ui/buttons/primary_button.dart';

class SetVibeScreen extends StatefulWidget {
  const SetVibeScreen({super.key});

  @override
  State<SetVibeScreen> createState() => _SetVibeScreenState();
}

class _SetVibeScreenState extends State<SetVibeScreen> {
  int _selectedActivityIndex = 0;
  EnergyType _selectedEnergy = EnergyType.medium;

  final List<Map<String, dynamic>> _activities = [
    {'title': 'Grab Coffee', 'icon': '☕', 'sub': 'Casual cafe hang & talk'},
    {'title': 'Go for a Walk', 'icon': '🚶', 'sub': 'Park stroll or neighborhood walk'},
    {'title': 'Study Together', 'icon': '📚', 'sub': 'Coworking / quiet focus session'},
    {'title': 'Explore Somewhere', 'icon': '🌆', 'sub': 'Thrifting, bookstores, or streets'},
    {'title': 'Gaming', 'icon': '🎮', 'sub': 'Co-op, board games, or arcade'},
    {'title': 'Food & Bites', 'icon': '🍜', 'sub': 'Street food, matcha, or dinner'},
    {'title': 'Music & Shows', 'icon': '🎵', 'sub': 'Live sets, vinyl digging, jam'},
    {'title': 'Fitness & Sport', 'icon': '🏃', 'sub': 'Biking, bouldering, or run'},
    {'title': 'Art & Creative', 'icon': '🎨', 'sub': 'Museum gallery or sketching'},
    {'title': 'Spontaneous Vibe', 'icon': '✨', 'sub': 'Open to whatever feels right'},
  ];

  void _onContinue() {
    final activity = _activities[_selectedActivityIndex];
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
      backgroundColor: VibeTokens.neutral000,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VibeTokens.neutral800),
          onPressed: () => context.go('/profile-setup'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: VibeTokens.space2),
              // Progress indicator
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: VibeTokens.brandPurple800,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: VibeTokens.brandPurple800,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: VibeTokens.brandPurple200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: VibeTokens.space4),

              Text(
                'What are you feeling\nlike doing?',
                style: VibeTokens.displaySm.copyWith(
                  color: VibeTokens.neutral900,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: VibeTokens.space2),
              Text(
                'Pick an intention to match with people nearby on the same wavelength.',
                style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral600),
              ),
              const SizedBox(height: VibeTokens.space4),

              // Energy Level Filter Header
              Text(
                'ENERGY LEVEL',
                style: VibeTokens.labelSm.copyWith(
                  color: VibeTokens.brandPurple800,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: VibeTokens.space2),
              Wrap(
                spacing: 8,
                children: [
                  EnergyChip(
                    energy: EnergyType.low,
                    isSelected: _selectedEnergy == EnergyType.low,
                    onSelected: (e) => setState(() => _selectedEnergy = e),
                  ),
                  EnergyChip(
                    energy: EnergyType.medium,
                    isSelected: _selectedEnergy == EnergyType.medium,
                    onSelected: (e) => setState(() => _selectedEnergy = e),
                  ),
                  EnergyChip(
                    energy: EnergyType.high,
                    isSelected: _selectedEnergy == EnergyType.high,
                    onSelected: (e) => setState(() => _selectedEnergy = e),
                  ),
                ],
              ),
              const SizedBox(height: VibeTokens.space4),

              // Visual Grid of Intentions
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    final item = _activities[index];
                    final isSelected = _selectedActivityIndex == index;

                    return InkWell(
                      onTap: () => setState(() => _selectedActivityIndex = index),
                      borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
                      child: AnimatedContainer(
                        duration: VibeTokens.motionFast,
                        padding: const EdgeInsets.all(VibeTokens.space3),
                        decoration: BoxDecoration(
                          color: isSelected ? VibeTokens.brandPurple050 : VibeTokens.neutral050,
                          borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
                          border: Border.all(
                            color: isSelected ? VibeTokens.brandPurple800 : VibeTokens.neutral200,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: VibeTokens.brandPurple500.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['icon'] as String, style: const TextStyle(fontSize: 26)),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: VibeTokens.brandPurple800,
                                  ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              item['title'] as String,
                              style: VibeTokens.titleMd.copyWith(
                                color: isSelected ? VibeTokens.brandPurple900 : VibeTokens.neutral900,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['sub'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: VibeTokens.bodySm.copyWith(
                                color: VibeTokens.neutral500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.only(bottom: VibeTokens.space4, top: VibeTokens.space2),
                child: PrimaryButton(
                  label: 'Set Intention & Continue →',
                  onTap: _onContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
