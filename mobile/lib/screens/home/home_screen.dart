import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../services/sound_manager.dart';
import '../../ui/cards/suggestion_card.dart';
import '../../ui/cards/meetup_card.dart';
import '../../ui/chips/energy_chip.dart';
import '../../ui/glass/glass_container.dart';
import '../../ui/glass/glass_button.dart';
import '../../ui/glass/cosmic_background.dart';
import '../../ui/map/vibe_map_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  EnergyType? _filterEnergy;
  final Set<String> _hiddenCandidates = {};
  bool _showMapPreview = false;
  bool _isBroadcasting = true;

  // Sound Settings state
  bool _soundEnabled = true;
  double _soundVolume = 0.6;
  bool _reducedMotion = false;
  bool _meshDiscoverable = true;

  @override
  void initState() {
    super.initState();
    _soundEnabled = SoundManager().isSoundEnabled;
    _soundVolume = SoundManager().volume;
  }

  void _showInviteModal(BuildContext context, String candidateName, int affinity) {
    SoundManager().playTap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(VibeTokens.radiusXl)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xF00D0B18),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(VibeTokens.radiusXl)),
                border: Border.all(color: const Color(0x33A78BFA)),
              ),
              padding: const EdgeInsets.all(VibeTokens.space6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0x40FFFFFF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: VibeTokens.space4),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: VibeTokens.heroGradient,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          candidateName.isNotEmpty ? candidateName[0] : 'V',
                          style: VibeTokens.titleMd.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: VibeTokens.space3),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite $candidateName',
                            style: VibeTokens.titleLg.copyWith(
                              color: VibeTokens.darkTextPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '$affinity% Vibe Affinity · Verified Public Spot',
                            style: VibeTokens.bodySm.copyWith(color: VibeTokens.brandPurple200),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: VibeTokens.space4),
                  Text(
                    'Proposed Public Third-Place (Safe, high-visibility venue):',
                    style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextSecondary),
                  ),
                  const SizedBox(height: VibeTokens.space3),
                  Container(
                    padding: const EdgeInsets.all(VibeTokens.space3),
                    decoration: BoxDecoration(
                      color: const Color(0x18FFFFFF),
                      borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.coffee, color: VibeTokens.brandPurple200),
                        const SizedBox(width: VibeTokens.space2),
                        Expanded(
                          child: Text(
                            'Blue Bottle Coffee · 450 W 15th St',
                            style: VibeTokens.labelLg.copyWith(color: VibeTokens.darkTextPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: VibeTokens.space6),
                  GlassButton(
                    label: 'Send Meetup Invitation ✦',
                    variant: GlassButtonVariant.primary,
                    icon: Icons.send_rounded,
                    onTap: () {
                      SoundManager().playSuccess();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Meetup invite sent to $candidateName! Check Meetups tab.'),
                          backgroundColor: const Color(0xFF5B21B6),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: VibeTokens.space2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSafetyReport(BuildContext context) {
    SoundManager().playAlert();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(VibeTokens.radiusXl)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xF00D0B18),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(VibeTokens.radiusXl)),
                border: Border.all(color: const Color(0x40EF4444)),
              ),
              padding: const EdgeInsets.all(VibeTokens.space6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.shield_outlined, color: VibeTokens.semanticDanger, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Safety & Crisis Resources',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: VibeTokens.space3),
                  Text(
                    'Vibe prioritizes genuine offline safety. If you feel unsafe or in distress:',
                    style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextSecondary),
                  ),
                  const SizedBox(height: VibeTokens.space4),
                  _buildHelpRow('988 Suicide & Crisis Lifeline', 'Call or text 988 (24/7 Free & Confidential)'),
                  const SizedBox(height: VibeTokens.space2),
                  _buildHelpRow('Emergency Services', 'Call 911 / Local Emergency Services'),
                  const SizedBox(height: VibeTokens.space2),
                  _buildHelpRow('Instant Block & Moderation Flag', 'Instantly hide and flag behavior to safety team'),
                  const SizedBox(height: VibeTokens.space5),
                  GlassButton(
                    label: 'Close Safety Hub',
                    variant: GlassButtonVariant.glass,
                    onTap: () {
                      SoundManager().playTap();
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpRow(String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(VibeTokens.space3),
      decoration: BoxDecoration(
        color: const Color(0x18FFFFFF),
        borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
        border: Border.all(color: const Color(0x28FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: VibeTokens.labelLg.copyWith(color: VibeTokens.darkTextPrimary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(sub, style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextSecondary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<OnboardingCubit>();
    final state = cubit.state;

    return Scaffold(
      backgroundColor: VibeTokens.darkBgCosmic,
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Glass Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space4, vertical: VibeTokens.space2),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space4, vertical: VibeTokens.space2),
                  borderRadius: VibeTokens.radiusFull,
                  child: Row(
                    children: [
                      // Wordmark
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: VibeTokens.glowPurple, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'VIBE',
                            style: VibeTokens.titleMd.copyWith(
                              color: VibeTokens.darkTextPrimary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Sound Toggle Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                          onTap: () {
                            final sm = SoundManager();
                            sm.setSoundEnabled(!sm.isSoundEnabled);
                            setState(() {
                              _soundEnabled = sm.isSoundEnabled;
                            });
                            if (sm.isSoundEnabled) sm.playTap();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _soundEnabled ? const Color(0x337C3AED) : const Color(0x18FFFFFF),
                              border: Border.all(
                                color: _soundEnabled ? VibeTokens.glowPurple : const Color(0x28FFFFFF),
                              ),
                            ),
                            child: Icon(
                              _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                              size: 16,
                              color: _soundEnabled ? VibeTokens.brandPurple200 : VibeTokens.darkTextMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Safety SOS Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                          onTap: () => _showSafetyReport(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0x28EF4444),
                              borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                              border: Border.all(color: const Color(0x66EF4444)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shield_outlined, color: Color(0xFFFCA5A5), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'SAFETY',
                                  style: VibeTokens.labelSm.copyWith(
                                    color: const Color(0xFFFCA5A5),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Current Tab Content
              Expanded(
                child: _buildCurrentTab(context, state),
              ),

              // Bottom Glass Navigation Bar
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  borderRadius: VibeTokens.radiusFull,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavIcon(0, Icons.radar_rounded, 'Radar'),
                      _buildNavIcon(1, Icons.bolt_rounded, 'Intent'),
                      _buildNavIcon(2, Icons.people_alt_rounded, 'Meetups'),
                      _buildNavIcon(3, Icons.person_rounded, 'Settings'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData icon, String label) {
    final isSelected = _currentTab == index;
    return InkWell(
      borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
      onTap: () {
        SoundManager().playTap();
        setState(() => _currentTab = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x407C3AED) : Colors.transparent,
          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
          border: Border.all(
            color: isSelected ? const Color(0x80A78BFA) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? VibeTokens.brandPurple200 : VibeTokens.darkTextSecondary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: VibeTokens.labelSm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab(BuildContext context, OnboardingState state) {
    switch (_currentTab) {
      case 0:
        return _buildDiscoverTab(context, state);
      case 1:
        return _buildIntentTab(context, state);
      case 2:
        return _buildMeetupsTab(context);
      case 3:
      default:
        return _buildProfileAndSettingsTab(context, state);
    }
  }

  Widget _buildDiscoverTab(BuildContext context, OnboardingState state) {
    final activeIntent = state.currentIntent;
    final candidates = state.candidates.where((c) {
      if (_hiddenCandidates.contains(c.id)) return false;
      if (_filterEnergy != null && c.energy != _filterEnergy!.name) return false;
      return true;
    }).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space4, vertical: VibeTokens.space2),
      children: [
        // Live Broadcast Header Card
        if (activeIntent != null)
          GlassContainer(
            padding: const EdgeInsets.all(VibeTokens.space4),
            borderRadius: VibeTokens.radiusLg,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0x337C3AED),
                    border: Border.all(color: const Color(0x66A78BFA)),
                  ),
                  alignment: Alignment.center,
                  child: Text(activeIntent.icon, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: VibeTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Broadcasting: ${activeIntent.title}',
                        style: VibeTokens.titleMd.copyWith(
                          color: VibeTokens.darkTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${activeIntent.energy.name.toUpperCase()} Energy · ${activeIntent.radiusKm.toStringAsFixed(1)} km radius',
                        style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x3310B981),
                    borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                    border: Border.all(color: const Color(0x6610B981)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF6EE7B7),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'RADAR LIVE',
                        style: VibeTokens.labelSm.copyWith(
                          color: const Color(0xFF6EE7B7),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: VibeTokens.space3),

        // Interactive Map View Collapsible Toggle
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          borderRadius: VibeTokens.radiusMd,
          onTap: () {
            SoundManager().playTap();
            setState(() => _showMapPreview = !_showMapPreview);
          },
          child: Row(
            children: [
              Icon(
                _showMapPreview ? Icons.map_rounded : Icons.map_outlined,
                size: 18,
                color: VibeTokens.glowCyan,
              ),
              const SizedBox(width: 8),
              Text(
                _showMapPreview ? 'Hide Live Map Radar' : 'Show Live OpenStreetMap Radar',
                style: VibeTokens.labelSm.copyWith(
                  color: VibeTokens.darkTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                _showMapPreview ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: VibeTokens.darkTextSecondary,
              ),
            ],
          ),
        ),

        // Collapsible Map View
        if (_showMapPreview) ...[
          const SizedBox(height: VibeTokens.space3),
          SizedBox(
            height: 240,
            child: GlassContainer(
              padding: const EdgeInsets.all(4),
              borderRadius: VibeTokens.radiusLg,
              child: VibeMapView(
                radiusKm: activeIntent?.radiusKm ?? 5.0,
                interactive: true,
                centerLabel: 'You',
              ),
            ),
          ),
        ],

        const SizedBox(height: VibeTokens.space4),

        // Filter Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Matches nearby (${candidates.length})',
              style: VibeTokens.titleMd.copyWith(
                color: VibeTokens.darkTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_filterEnergy != null)
              InkWell(
                onTap: () {
                  SoundManager().playTap();
                  setState(() => _filterEnergy = null);
                },
                child: Text(
                  'Clear Filter',
                  style: VibeTokens.labelSm.copyWith(color: VibeTokens.brandPurple200),
                ),
              ),
          ],
        ),

        const SizedBox(height: VibeTokens.space2),

        // Energy Chips
        Row(
          children: [
            _buildEnergyChip(EnergyType.low, 'Chill 🌱'),
            const SizedBox(width: 8),
            _buildEnergyChip(EnergyType.medium, 'Balanced ⚡'),
            const SizedBox(width: 8),
            _buildEnergyChip(EnergyType.high, 'Active 🔥'),
          ],
        ),

        const SizedBox(height: VibeTokens.space3),

        // Candidate Suggestion Cards
        for (final candidate in candidates)
          SuggestionCard(
            title: candidate.name,
            age: candidate.age,
            affinity: candidate.affinity,
            rationale: candidate.rationale.isNotEmpty
                ? candidate.rationale
                : '${candidate.activities.join(", ")} · ${candidate.distanceKm.toStringAsFixed(1)} km away',
            onOpen: () => _showInviteModal(context, candidate.name, candidate.affinity),
            onHide: () {
              setState(() {
                _hiddenCandidates.add(candidate.id);
              });
            },
          ),
      ],
    );
  }

  Widget _buildEnergyChip(EnergyType type, String label) {
    final isSelected = _filterEnergy == type;
    return InkWell(
      borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
      onTap: () {
        SoundManager().playTap();
        setState(() => _filterEnergy = isSelected ? null : type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C3AED) : VibeTokens.glassFillSubtle,
          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
          border: Border.all(
            color: isSelected ? const Color(0xFFA78BFA) : VibeTokens.glassBorderLight,
          ),
        ),
        child: Text(
          label,
          style: VibeTokens.labelSm.copyWith(
            color: isSelected ? Colors.white : VibeTokens.darkTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildIntentTab(BuildContext context, OnboardingState state) {
    final activeIntent = state.currentIntent;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(VibeTokens.space4),
      children: [
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
                    'Active Intent Broadcast',
                    style: VibeTokens.titleMd.copyWith(color: VibeTokens.darkTextPrimary, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: _isBroadcasting,
                    activeColor: VibeTokens.glowPurple,
                    onChanged: (val) {
                      SoundManager().playTap();
                      setState(() => _isBroadcasting = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: VibeTokens.space3),
              Row(
                children: [
                  Text(
                    activeIntent?.icon ?? '☕',
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeIntent?.title ?? 'Grab Coffee',
                        style: VibeTokens.titleLg.copyWith(color: VibeTokens.darkTextPrimary, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        _isBroadcasting ? 'Broadcasting live nearby' : 'Paused · Not visible to peers',
                        style: VibeTokens.bodySm.copyWith(
                          color: _isBroadcasting ? const Color(0xFF6EE7B7) : VibeTokens.darkTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: VibeTokens.space5),
              GlassButton(
                label: 'Change Vibe Activity',
                variant: GlassButtonVariant.glass,
                onTap: () {
                  SoundManager().playTap();
                  context.go('/set-vibe');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeetupsTab(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(VibeTokens.space4),
      children: [
        Text(
          'Upcoming Meetups',
          style: VibeTokens.titleMd.copyWith(color: VibeTokens.darkTextPrimary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: VibeTokens.space3),
        MeetupCard(
          title: 'Cafe Hang & Study Session',
          timeLabel: 'Today · 3:30 PM (in 2 hours)',
          placeAddress: 'Blue Bottle Coffee · 450 W 15th St',
          attendeesCount: 1,
          onOpen: () {
            SoundManager().playTap();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Meetup confirmed! Safe location shared with your emergency contact.'),
                backgroundColor: Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileAndSettingsTab(BuildContext context, OnboardingState state) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(VibeTokens.space4),
      children: [
        // Profile Card
        GlassContainer(
          padding: const EdgeInsets.all(VibeTokens.space5),
          borderRadius: VibeTokens.radiusXl,
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: VibeTokens.heroGradient,
                ),
                alignment: Alignment.center,
                child: const Text('✨', style: TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: VibeTokens.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.profile.name.isNotEmpty ? state.profile.name : 'Alex Rivera',
                      style: VibeTokens.titleLg.copyWith(
                        color: VibeTokens.darkTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${state.profile.city} · Age ${state.profile.age} (Verified)',
                      style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: VibeTokens.space4),

        // SOUND SETTINGS (Section 10 & 19 Requirements)
        GlassContainer(
          padding: const EdgeInsets.all(VibeTokens.space5),
          borderRadius: VibeTokens.radiusXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.volume_up_rounded, color: VibeTokens.glowPurple, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Sound Design & Audio Feedback',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: VibeTokens.space3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sound Effects',
                        style: VibeTokens.labelLg.copyWith(color: VibeTokens.darkTextPrimary),
                      ),
                      Text(
                        'Subtle glass clicks, matching chimes, alerts',
                        style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextSecondary),
                      ),
                    ],
                  ),
                  Switch(
                    value: _soundEnabled,
                    activeColor: VibeTokens.glowPurple,
                    onChanged: (val) {
                      final sm = SoundManager();
                      sm.setSoundEnabled(val);
                      setState(() => _soundEnabled = val);
                      if (val) sm.playSuccess();
                    },
                  ),
                ],
              ),
              if (_soundEnabled) ...[
                const SizedBox(height: VibeTokens.space3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Volume Level', style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextSecondary)),
                    Text('${(_soundVolume * 100).toInt()}%', style: VibeTokens.labelSm.copyWith(color: VibeTokens.brandPurple200)),
                  ],
                ),
                Slider(
                  value: _soundVolume,
                  min: 0.1,
                  max: 1.0,
                  activeColor: VibeTokens.glowPurple,
                  inactiveColor: const Color(0x33FFFFFF),
                  onChanged: (val) {
                    setState(() => _soundVolume = val);
                    SoundManager().setVolume(val);
                  },
                ),
                const SizedBox(height: VibeTokens.space2),
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                    onTap: () => SoundManager().playMatch(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: VibeTokens.glassFillSubtle,
                        borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                        border: Border.all(color: const Color(0x66A78BFA)),
                      ),
                      child: Text(
                        '♪ Test Harmonic Chime',
                        style: VibeTokens.labelSm.copyWith(color: VibeTokens.brandPurple200),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: VibeTokens.space4),

        // APPEARANCE & ACCESSIBILITY SETTINGS
        GlassContainer(
          padding: const EdgeInsets.all(VibeTokens.space5),
          borderRadius: VibeTokens.radiusXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.palette_outlined, color: VibeTokens.glowCyan, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Appearance & Accessibility',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: VibeTokens.space3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reduced Motion', style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextPrimary)),
                  Switch(
                    value: _reducedMotion,
                    activeColor: VibeTokens.glowCyan,
                    onChanged: (val) {
                      SoundManager().playTap();
                      setState(() => _reducedMotion = val);
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Discoverable in Local Mesh', style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextPrimary)),
                  Switch(
                    value: _meshDiscoverable,
                    activeColor: VibeTokens.glowPurple,
                    onChanged: (val) {
                      SoundManager().playTap();
                      setState(() => _meshDiscoverable = val);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: VibeTokens.space5),

        // Reset Onboarding / Log Out
        GlassButton(
          label: 'Restart Onboarding Flow',
          variant: GlassButtonVariant.glass,
          onTap: () {
            SoundManager().playStep();
            context.read<OnboardingCubit>().resetOnboarding();
            context.go('/intro');
          },
        ),
        const SizedBox(height: VibeTokens.space3),
      ],
    );
  }
}
