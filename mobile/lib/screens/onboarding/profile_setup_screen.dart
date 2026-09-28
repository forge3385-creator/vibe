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

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _bioController;

  int _selectedAvatarIndex = 0;
  bool _isLocating = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Interests/tags
  final List<Map<String, dynamic>> _allInterests = [
    {'label': 'Music 🎵', 'selected': false},
    {'label': 'Art 🎨', 'selected': false},
    {'label': 'Tech 💻', 'selected': false},
    {'label': 'Food 🍜', 'selected': false},
    {'label': 'Sports ⚽', 'selected': false},
    {'label': 'Gaming 🎮', 'selected': false},
    {'label': 'Film 🎬', 'selected': false},
    {'label': 'Travel ✈️', 'selected': false},
    {'label': 'Books 📚', 'selected': false},
    {'label': 'Fitness 🏋️', 'selected': false},
    {'label': 'Coffee ☕', 'selected': false},
    {'label': 'Nature 🌿', 'selected': false},
    {'label': 'Comedy 😂', 'selected': false},
    {'label': 'Fashion 👗', 'selected': false},
    {'label': 'Photography 📷', 'selected': false},
  ];

  // Social energy preference
  int _socialEnergyLevel = 2; // 0=solo, 1=small, 2=open, 3=social butterfly

  // Privacy toggles
  bool _showAgeRange = true;
  bool _showCityOnly = true;
  bool _allowNearbySearch = true;

  // Pronouns
  String _selectedPronoun = 'They/Them';
  final List<String> _pronounOptions = [
    'He/Him',
    'She/Her',
    'They/Them',
    'Any',
    'Prefer not to say',
  ];

  final List<String> _avatarEmojis = [
    '⚡', '☕', '🎨', '🎧', '🛹', '🌿', '🚀', '✨',
    '🦋', '🔮', '🌊', '🎯', '🌙', '🎪', '🦄', '🌸',
  ];

  final List<Map<String, dynamic>> _energyLevels = [
    {'label': 'Solo Mode', 'icon': '🎧', 'desc': 'Just chilling, not looking for crowds'},
    {'label': 'Small Circles', 'icon': '👥', 'desc': 'Open to 1–3 people I vibe with'},
    {'label': 'Open Vibes', 'icon': '✨', 'desc': 'Up for whatever the moment brings'},
    {'label': 'Social Butterfly', 'icon': '🦋', 'desc': 'Let\'s meet everyone tonight'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    final cubit = context.read<OnboardingCubit>();
    final defaultName =
        cubit.state.profile.name.isNotEmpty ? cubit.state.profile.name : '';
    final defaultCity =
        cubit.state.profile.city.isNotEmpty ? cubit.state.profile.city : '';
    _nameController = TextEditingController(text: defaultName);
    _cityController = TextEditingController(text: defaultCity);
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _autoDetectLocation() async {
    SoundManager().playTap();
    setState(() => _isLocating = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      SoundManager().playSuccess();
      setState(() {
        _isLocating = false;
        _cityController.text = 'San Francisco, CA';
      });
    }
  }

  void _onContinue() {
    final name = _nameController.text.trim().isEmpty
        ? 'Anonymous'
        : _nameController.text.trim();
    final city = _cityController.text.trim().isEmpty
        ? 'Somewhere'
        : _cityController.text.trim();
    SoundManager().playStep();
    context.read<OnboardingCubit>().updateProfile(name: name, city: city);
    context.go('/set-vibe');
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: VibeTokens.labelLg.copyWith(
            color: VibeTokens.darkTextPrimary,
            letterSpacing: 0.4,
          ),
        ),
      );

  Widget _glassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x18FFFFFF),
        borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        style: VibeTokens.bodyLg.copyWith(color: VibeTokens.darkTextPrimary),
        decoration: InputDecoration(
          prefixIcon: maxLines == 1
              ? Icon(icon, color: VibeTokens.brandPurple300, size: 20)
              : null,
          hintText: hint,
          hintStyle: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextMuted),
          border: InputBorder.none,
          counterStyle: VibeTokens.labelSm.copyWith(color: VibeTokens.darkTextMuted),
          contentPadding: EdgeInsets.symmetric(
            horizontal: maxLines > 1 ? 16 : 0,
            vertical: maxLines > 1 ? 14 : 0,
          ),
        ),
      ),
    );
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

                  // ── Top Nav ──────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(VibeTokens.radiusFull),
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
                              border:
                                  Border.all(color: VibeTokens.glassBorderLight),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: VibeTokens.darkTextPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: VibeTokens.space4,
                          vertical: VibeTokens.space2,
                        ),
                        decoration: BoxDecoration(
                          color: VibeTokens.glassFillSubtle,
                          borderRadius:
                              BorderRadius.circular(VibeTokens.radiusFull),
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
                      const SizedBox(width: 42),
                    ],
                  ),

                  const SizedBox(height: VibeTokens.space5),

                  // ── Title ────────────────────────────────────────────────
                  Text(
                    'Your Persona',
                    style: VibeTokens.displayLg.copyWith(
                      color: VibeTokens.darkTextPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: VibeTokens.space1),
                  Text(
                    'How you show up. What you\'re about. Authentically you.',
                    style: VibeTokens.bodyMd
                        .copyWith(color: VibeTokens.darkTextSecondary),
                  ),

                  const SizedBox(height: VibeTokens.space5),

                  // ── Scrollable Body ──────────────────────────────────────
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [

                        // ── 1. Vibe Emblem ──────────────────────────────
                        GlassContainer(
                          padding: const EdgeInsets.all(VibeTokens.space5),
                          borderRadius: VibeTokens.radiusXl,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Vibe Emblem',
                                    style: VibeTokens.titleMd
                                        .copyWith(color: VibeTokens.darkTextPrimary),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0x33A78BFA),
                                      borderRadius: BorderRadius.circular(
                                          VibeTokens.radiusFull),
                                    ),
                                    child: Text(
                                      'Anonymous by default',
                                      style: VibeTokens.labelSm
                                          .copyWith(color: VibeTokens.brandPurple200),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'This emoji represents you in the radar and during meetups.',
                                style: VibeTokens.bodySm
                                    .copyWith(color: VibeTokens.darkTextMuted),
                              ),
                              const SizedBox(height: VibeTokens.space4),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: List.generate(
                                    _avatarEmojis.length, (index) {
                                  final isSelected =
                                      _selectedAvatarIndex == index;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(
                                        VibeTokens.radiusFull),
                                    onTap: () {
                                      SoundManager().playTap();
                                      setState(
                                          () => _selectedAvatarIndex = index);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      width: 44,
                                      height: 44,
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
                                                  color: VibeTokens.glowPurple
                                                      .withAlpha(100),
                                                  blurRadius: 14,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _avatarEmojis[index],
                                        style:
                                            const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: VibeTokens.space4),

                        // ── 2. Identity Card ────────────────────────────
                        GlassContainer(
                          padding: const EdgeInsets.all(VibeTokens.space5),
                          borderRadius: VibeTokens.radiusXl,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('Display Name'),
                              _glassTextField(
                                controller: _nameController,
                                hint: 'What should people call you?',
                                icon: Icons.person_outline_rounded,
                                maxLength: 32,
                              ),

                              const SizedBox(height: VibeTokens.space4),

                              // Pronouns
                              _sectionLabel('Pronouns'),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _pronounOptions.map((p) {
                                  final isSelected = _selectedPronoun == p;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(
                                        VibeTokens.radiusFull),
                                    onTap: () {
                                      SoundManager().playTap();
                                      setState(() => _selectedPronoun = p);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF7C3AED)
                                            : VibeTokens.glassFillSubtle,
                                        borderRadius: BorderRadius.circular(
                                            VibeTokens.radiusFull),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFA78BFA)
                                              : VibeTokens.glassBorderLight,
                                        ),
                                      ),
                                      child: Text(
                                        p,
                                        style: VibeTokens.labelMd.copyWith(
                                          color: isSelected
                                              ? Colors.white
                                              : VibeTokens.darkTextSecondary,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: VibeTokens.space4),

                              // Bio
                              _sectionLabel('Bio (optional)'),
                              _glassTextField(
                                controller: _bioController,
                                hint:
                                    'Tell people what you\'re about in a sentence…',
                                icon: Icons.edit_note_rounded,
                                maxLines: 3,
                                maxLength: 120,
                              ),

                              const SizedBox(height: VibeTokens.space4),

                              // City / Region
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _sectionLabel('Base Region'),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(
                                        VibeTokens.radiusSm),
                                    onTap: _autoDetectLocation,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _isLocating
                                              ? Icons.hourglass_top
                                              : Icons.my_location_rounded,
                                          size: 13,
                                          color: VibeTokens.glowCyan,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _isLocating
                                              ? 'Detecting…'
                                              : 'Auto-detect',
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
                              _glassTextField(
                                controller: _cityController,
                                hint: 'City, Campus, or Neighbourhood',
                                icon: Icons.location_on_outlined,
                              ),

                              const SizedBox(height: VibeTokens.space4),

                              // Verified Age Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0x2210B981),
                                  borderRadius: BorderRadius.circular(
                                      VibeTokens.radiusMd),
                                  border: Border.all(
                                      color: const Color(0x6610B981)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: Color(0xFF6EE7B7),
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Age $age · Verified via Zero-Knowledge Gate',
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

                        const SizedBox(height: VibeTokens.space4),

                        // ── 3. Interests / Tags ─────────────────────────
                        GlassContainer(
                          padding: const EdgeInsets.all(VibeTokens.space5),
                          borderRadius: VibeTokens.radiusXl,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Interests',
                                    style: VibeTokens.titleMd.copyWith(
                                        color: VibeTokens.darkTextPrimary),
                                  ),
                                  Text(
                                    '${_allInterests.where((i) => i['selected'] as bool).length}/5 selected',
                                    style: VibeTokens.labelSm.copyWith(
                                        color: VibeTokens.darkTextMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Pick up to 5 things you\'re into right now.',
                                style: VibeTokens.bodySm
                                    .copyWith(color: VibeTokens.darkTextMuted),
                              ),
                              const SizedBox(height: VibeTokens.space4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _allInterests.map((interest) {
                                  final isSelected =
                                      interest['selected'] as bool;
                                  final selectedCount = _allInterests
                                      .where((i) => i['selected'] as bool)
                                      .length;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(
                                        VibeTokens.radiusFull),
                                    onTap: () {
                                      if (!isSelected && selectedCount >= 5) {
                                        return;
                                      }
                                      SoundManager().playTap();
                                      setState(() {
                                        interest['selected'] = !isSelected;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 160),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFF7C3AED),
                                                  Color(0xFF5B21B6),
                                                ],
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : VibeTokens.glassFillSubtle,
                                        borderRadius: BorderRadius.circular(
                                            VibeTokens.radiusFull),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFA78BFA)
                                              : VibeTokens.glassBorderLight,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color:
                                                      VibeTokens.glowPurple
                                                          .withAlpha(70),
                                                  blurRadius: 10,
                                                )
                                              ]
                                            : [],
                                      ),
                                      child: Text(
                                        interest['label'] as String,
                                        style: VibeTokens.labelMd.copyWith(
                                          color: isSelected
                                              ? Colors.white
                                              : VibeTokens.darkTextSecondary,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: VibeTokens.space4),

                        // ── 4. Social Energy Preference ──────────────────
                        GlassContainer(
                          padding: const EdgeInsets.all(VibeTokens.space5),
                          borderRadius: VibeTokens.radiusXl,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Social Energy',
                                style: VibeTokens.titleMd.copyWith(
                                    color: VibeTokens.darkTextPrimary),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'How sociable are you feeling today?',
                                style: VibeTokens.bodySm
                                    .copyWith(color: VibeTokens.darkTextMuted),
                              ),
                              const SizedBox(height: VibeTokens.space4),
                              ...List.generate(_energyLevels.length, (i) {
                                final level = _energyLevels[i];
                                final isSelected = _socialEnergyLevel == i;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                        VibeTokens.radiusMd),
                                    onTap: () {
                                      SoundManager().playTap();
                                      setState(
                                          () => _socialEnergyLevel = i);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 160),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0x337C3AED)
                                            : VibeTokens.glassFillSubtle,
                                        borderRadius: BorderRadius.circular(
                                            VibeTokens.radiusMd),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFA78BFA)
                                              : VibeTokens.glassBorderLight,
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            level['icon'] as String,
                                            style: const TextStyle(
                                                fontSize: 22),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  level['label'] as String,
                                                  style: VibeTokens.labelLg
                                                      .copyWith(
                                                    color: isSelected
                                                        ? VibeTokens
                                                            .brandPurple200
                                                        : VibeTokens
                                                            .darkTextPrimary,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  level['desc'] as String,
                                                  style: VibeTokens.bodySm
                                                      .copyWith(
                                                          color: VibeTokens
                                                              .darkTextMuted),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                                Icons.check_circle_rounded,
                                                color: Color(0xFFA78BFA),
                                                size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: VibeTokens.space4),

                        // ── 5. Privacy Controls ──────────────────────────
                        GlassContainer(
                          padding: const EdgeInsets.all(VibeTokens.space5),
                          borderRadius: VibeTokens.radiusXl,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.shield_outlined,
                                      color: Color(0xFF6EE7B7), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Privacy Preferences',
                                    style: VibeTokens.titleMd.copyWith(
                                        color: VibeTokens.darkTextPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Control what others can see during a vibe session.',
                                style: VibeTokens.bodySm
                                    .copyWith(color: VibeTokens.darkTextMuted),
                              ),
                              const SizedBox(height: VibeTokens.space4),
                              _privacyToggle(
                                icon: Icons.cake_outlined,
                                title: 'Show approximate age range',
                                subtitle: 'e.g. "Early 20s" instead of exact age',
                                value: _showAgeRange,
                                onChanged: (v) =>
                                    setState(() => _showAgeRange = v),
                              ),
                              _divider(),
                              _privacyToggle(
                                icon: Icons.location_city_rounded,
                                title: 'Show city only (not exact area)',
                                subtitle:
                                    'Reduces location precision to borough/district level',
                                value: _showCityOnly,
                                onChanged: (v) =>
                                    setState(() => _showCityOnly = v),
                              ),
                              _divider(),
                              _privacyToggle(
                                icon: Icons.radar_rounded,
                                title: 'Allow nearby vibe search',
                                subtitle:
                                    'People can discover you on the radar',
                                value: _allowNearbySearch,
                                onChanged: (v) =>
                                    setState(() => _allowNearbySearch = v),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: VibeTokens.space6),
                      ],
                    ),
                  ),

                  // ── CTA ───────────────────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: VibeTokens.space4),
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

  Widget _privacyToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: VibeTokens.brandPurple300, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: VibeTokens.labelMd
                      .copyWith(color: VibeTokens.darkTextPrimary)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: VibeTokens.bodySm
                      .copyWith(color: VibeTokens.darkTextMuted)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (v) {
            SoundManager().playTap();
            onChanged(v);
          },
          activeColor: const Color(0xFFA78BFA),
          activeTrackColor: const Color(0x557C3AED),
          inactiveThumbColor: const Color(0xFF6B7280),
          inactiveTrackColor: const Color(0x33FFFFFF),
        ),
      ],
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Divider(
          color: VibeTokens.glassBorderLight,
          thickness: 1,
        ),
      );
}
