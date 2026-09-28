import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../services/sound_manager.dart';
import '../../ui/glass/glass_container.dart';
import '../../ui/glass/glass_button.dart';
import '../../ui/glass/cosmic_background.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  int _selectedAvatarIndex = 0;
  bool _isLocating = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _avatarEmojis = ['⚡', '☕', '🎨', '🎧', '🛹', '🌿', '🚀', '✨'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    final cubit = context.read<OnboardingCubit>();
    final defaultName = cubit.state.profile.name.isNotEmpty ? cubit.state.profile.name : 'Alex Rivera';
    final defaultCity = cubit.state.profile.city.isNotEmpty ? cubit.state.profile.city : 'San Francisco, CA';
    _nameController = TextEditingController(text: defaultName);
    _cityController = TextEditingController(text: defaultCity);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _autoDetectLocation() async {
    SoundManager().playTap();
    setState(() => _isLocating = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      SoundManager().playSuccess();
      setState(() {
        _isLocating = false;
        _cityController.text = 'San Francisco, CA';
      });
    }
  }

  void _onContinue() {
    final name = _nameController.text.trim().isEmpty ? 'Alex' : _nameController.text.trim();
    final city = _cityController.text.trim().isEmpty ? 'San Francisco' : _cityController.text.trim();
    SoundManager().playStep();
    context.read<OnboardingCubit>().updateProfile(name: name, city: city);
    context.go('/set-vibe');
  }

  @override
  Widget build(BuildContext context) {
    final age = context.select((OnboardingCubit c) => c.state.profile.age);

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

                  // Top Navigation & Step Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                          onTap: () {
                            SoundManager().playTap();
                            context.go('/auth');
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
                          'STEP 4 OF 6',
                          style: VibeTokens.labelSm.copyWith(
                            color: VibeTokens.brandPurple200,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(width: 42), // Balance spacer
                    ],
                  ),

                  const SizedBox(height: VibeTokens.space5),

                  // Screen Title
                  Text(
                    'Your Persona',
                    style: VibeTokens.displayLg.copyWith(
                      color: VibeTokens.darkTextPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: VibeTokens.space1),
                  Text(
                    'How you show up to friends and people nearby during meetups.',
                    style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextSecondary),
                  ),

                  const SizedBox(height: VibeTokens.space5),

                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Avatar Emoji Selector Card
                        GlassContainer(
                          padding: const EdgeInsets.all(VibeTokens.space5),
                          borderRadius: VibeTokens.radiusXl,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Choose Vibe Emblem',
                                    style: VibeTokens.titleMd.copyWith(color: VibeTokens.darkTextPrimary),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0x33A78BFA),
                                      borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                                    ),
                                    child: Text(
                                      'Anonymous by default',
                                      style: VibeTokens.labelSm.copyWith(color: VibeTokens.brandPurple200),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: VibeTokens.space4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(_avatarEmojis.length, (index) {
                                  final isSelected = _selectedAvatarIndex == index;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                                    onTap: () {
                                      SoundManager().playTap();
                                      setState(() => _selectedAvatarIndex = index);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? const Color(0xFF7C3AED)
                                            : VibeTokens.glassFillSubtle,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFA78BFA)
                                              : VibeTokens.glassBorderLight,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: VibeTokens.glowPurple.withAlpha(90),
                                                  blurRadius: 10,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _avatarEmojis[index],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: VibeTokens.space4),

                        // Name & Details Glass Card
                        GlassContainer(
                          padding: const EdgeInsets.all(VibeTokens.space5),
                          borderRadius: VibeTokens.radiusXl,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Display Name',
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
                                  controller: _nameController,
                                  style: VibeTokens.bodyLg.copyWith(color: VibeTokens.darkTextPrimary),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.person_outline_rounded, color: VibeTokens.brandPurple300, size: 20),
                                    hintText: 'Enter your preferred name',
                                    hintStyle: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextMuted),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                ),
                              ),

                              const SizedBox(height: VibeTokens.space4),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Base Region / City',
                                    style: VibeTokens.labelLg.copyWith(color: VibeTokens.darkTextPrimary),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(VibeTokens.radiusSm),
                                    onTap: _autoDetectLocation,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _isLocating ? Icons.hourglass_top : Icons.my_location_rounded,
                                          size: 13,
                                          color: VibeTokens.glowCyan,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _isLocating ? 'Detecting...' : 'Auto-detect',
                                          style: VibeTokens.labelSm.copyWith(
                                            color: VibeTokens.glowCyan,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: VibeTokens.space2),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0x18FFFFFF),
                                  borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                                  border: Border.all(color: const Color(0x33FFFFFF)),
                                ),
                                child: TextField(
                                  controller: _cityController,
                                  style: VibeTokens.bodyLg.copyWith(color: VibeTokens.darkTextPrimary),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.location_on_outlined, color: VibeTokens.brandPurple300, size: 20),
                                    hintText: 'City or Campus',
                                    hintStyle: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextMuted),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                ),
                              ),

                              const SizedBox(height: VibeTokens.space4),

                              // Verified Age Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0x2210B981),
                                  borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                                  border: Border.all(color: const Color(0x6610B981)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF6EE7B7), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Age: $age · Verified via Zero-Knowledge Gate',
                                      style: VibeTokens.bodySm.copyWith(
                                        color: const Color(0xFF6EE7B7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: VibeTokens.space4),
                    child: GlassButton(
                      label: 'Save Persona & Set Vibe →',
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
}
