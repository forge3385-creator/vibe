import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../ui/buttons/primary_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  int _selectedAvatarIndex = 0;

  final List<String> _avatarEmojis = ['⚡', '☕', '🎨', '🎧', '🛹', '🌿', '🚀', '✨'];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<OnboardingCubit>();
    final defaultName = cubit.state.profile.name.isNotEmpty ? cubit.state.profile.name : 'Alex Rivera';
    final defaultCity = cubit.state.profile.city.isNotEmpty ? cubit.state.profile.city : 'New York';
    _nameController = TextEditingController(text: defaultName);
    _cityController = TextEditingController(text: defaultCity);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final name = _nameController.text.trim().isEmpty ? 'Alex' : _nameController.text.trim();
    final city = _cityController.text.trim().isEmpty ? 'New York' : _cityController.text.trim();
    context.read<OnboardingCubit>().updateProfile(name: name, city: city);
    context.go('/set-vibe');
  }

  @override
  Widget build(BuildContext context) {
    final age = context.select((OnboardingCubit c) => c.state.profile.age);

    return Scaffold(
      backgroundColor: VibeTokens.neutral000,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VibeTokens.neutral800),
          onPressed: () => context.go('/auth'),
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
                      color: VibeTokens.brandPurple200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: VibeTokens.neutral200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: VibeTokens.space4),

              Text(
                'A little about you',
                style: VibeTokens.displaySm.copyWith(
                  color: VibeTokens.neutral900,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: VibeTokens.space2),
              Text(
                'Help people identify you when meeting up in the real world.',
                style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral600),
              ),
              const SizedBox(height: VibeTokens.space5),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Avatar Picker
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: VibeTokens.brandPurple100,
                              shape: BoxShape.circle,
                              border: Border.all(color: VibeTokens.brandPurple300, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _avatarEmojis[_selectedAvatarIndex],
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                          const SizedBox(height: VibeTokens.space3),
                          Text(
                            'Choose your vibe icon',
                            style: VibeTokens.labelSm.copyWith(color: VibeTokens.neutral500),
                          ),
                          const SizedBox(height: VibeTokens.space2),
                          Wrap(
                            spacing: 8,
                            children: List.generate(_avatarEmojis.length, (index) {
                              final isSelected = _selectedAvatarIndex == index;
                              return InkWell(
                                onTap: () => setState(() => _selectedAvatarIndex = index),
                                borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? VibeTokens.brandPurple200 : VibeTokens.neutral100,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(color: VibeTokens.brandPurple800, width: 1.5)
                                        : null,
                                  ),
                                  child: Text(_avatarEmojis[index], style: const TextStyle(fontSize: 18)),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: VibeTokens.space6),

                    // Name Input
                    Text('Preferred Name or Handle', style: VibeTokens.labelLg.copyWith(color: VibeTokens.neutral800)),
                    const SizedBox(height: VibeTokens.space2),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Maya or Maya R.',
                        prefixIcon: const Icon(Icons.person_outline, color: VibeTokens.neutral500),
                        filled: true,
                        fillColor: VibeTokens.neutral050,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                          borderSide: const BorderSide(color: VibeTokens.neutral200),
                        ),
                      ),
                    ),
                    const SizedBox(height: VibeTokens.space4),

                    // Age / City Row
                    Row(
                      children: [
                        // Age badge (confirmed from age gate)
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Age', style: VibeTokens.labelLg.copyWith(color: VibeTokens.neutral800)),
                              const SizedBox(height: VibeTokens.space2),
                              Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space3),
                                decoration: BoxDecoration(
                                  color: VibeTokens.neutral100,
                                  borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                                  border: Border.all(color: VibeTokens.neutral200),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '$age y/o',
                                  style: VibeTokens.titleMd.copyWith(color: VibeTokens.neutral700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: VibeTokens.space4),
                        // City
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('City / Neighborhood', style: VibeTokens.labelLg.copyWith(color: VibeTokens.neutral800)),
                              const SizedBox(height: VibeTokens.space2),
                              TextField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  hintText: 'e.g. Brooklyn, NY',
                                  prefixIcon: const Icon(Icons.location_on_outlined, color: VibeTokens.neutral500),
                                  filled: true,
                                  fillColor: VibeTokens.neutral050,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                                    borderSide: const BorderSide(color: VibeTokens.neutral200),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.only(bottom: VibeTokens.space4, top: VibeTokens.space2),
                child: PrimaryButton(
                  label: 'Continue to Vibe Setup →',
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
