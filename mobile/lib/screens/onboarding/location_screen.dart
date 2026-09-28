import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../services/sound_manager.dart';
import '../../ui/glass/glass_container.dart';
import '../../ui/glass/glass_button.dart';
import '../../ui/glass/cosmic_background.dart';
import '../../ui/map/vibe_map_view.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> with SingleTickerProviderStateMixin {
  double _radiusKm = 5.0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Nearby Mock Candidates for Radar Visualization
  final List<Map<String, dynamic>> _radarMarkers = [
    {'dx': -55.0, 'dy': -40.0, 'name': 'Maya · 1.2 km', 'icon': '☕'},
    {'dx': 60.0, 'dy': -30.0, 'name': 'Dev · 2.5 km', 'icon': '📚'},
    {'dx': -30.0, 'dy': 55.0, 'name': 'Jordan · 3.1 km', 'icon': '🚶'},
    {'dx': 45.0, 'dy': 60.0, 'name': 'Liam · 4.8 km', 'icon': '🏃'},
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

  void _onAllow() {
    SoundManager().playSuccess();
    context.read<OnboardingCubit>().setLocationPermission(
      granted: true,
      radiusKm: _radiusKm,
    );
    context.go('/first-vibe');
  }

  void _onSkip() {
    SoundManager().playStep();
    context.read<OnboardingCubit>().setLocationPermission(
      granted: false,
      radiusKm: _radiusKm,
    );
    context.go('/first-vibe');
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
                            context.go('/set-vibe');
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
                          'STEP 6 OF 6',
                          style: VibeTokens.labelSm.copyWith(
                            color: VibeTokens.brandPurple200,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // Skip Pill
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                          onTap: _onSkip,
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

                  const SizedBox(height: VibeTokens.space4),

                  // Title
                  Text(
                    'Proximity Radar',
                    style: VibeTokens.displayLg.copyWith(
                      color: VibeTokens.darkTextPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: VibeTokens.space1),
                  Text(
                    'Discover who is around you. Your exact GPS coordinates are never stored or exposed.',
                    style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextSecondary),
                  ),

                  const SizedBox(height: VibeTokens.space4),

                  // Real Interactive Map Container
                  Expanded(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(4),
                      borderRadius: VibeTokens.radiusXl,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(VibeTokens.radiusXl - 4),
                        child: VibeMapView(
                          radiusKm: _radiusKm,
                          interactive: true,
                          centerLabel: 'Your Location',
                          markers: _radarMarkers,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: VibeTokens.space4),

                  // Radius Slider Glass Card
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space5, vertical: VibeTokens.space4),
                    borderRadius: VibeTokens.radiusLg,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discovery Radius',
                              style: VibeTokens.labelLg.copyWith(color: VibeTokens.darkTextPrimary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x337C3AED),
                                borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                                border: Border.all(color: const Color(0x66A78BFA)),
                              ),
                              child: Text(
                                '${_radiusKm.toStringAsFixed(1)} km (~${(_radiusKm * 0.621371).toStringAsFixed(1)} mi)',
                                style: VibeTokens.labelSm.copyWith(
                                  color: VibeTokens.brandPurple200,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: VibeTokens.space2),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: VibeTokens.glowPurple,
                            inactiveTrackColor: const Color(0x33FFFFFF),
                            thumbColor: Colors.white,
                            overlayColor: VibeTokens.glowPurple.withAlpha(60),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _radiusKm,
                            min: 1.0,
                            max: 15.0,
                            divisions: 28,
                            onChanged: (val) {
                              setState(() => _radiusKm = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: VibeTokens.space4),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.only(bottom: VibeTokens.space4),
                    child: GlassButton(
                      label: 'Enable Proximity & Review Vibe →',
                      variant: GlassButtonVariant.primary,
                      onTap: _onAllow,
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
