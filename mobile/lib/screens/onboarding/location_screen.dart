import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../ui/buttons/primary_button.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  double _radiusKm = 5.0;

  void _onAllow() {
    context.read<OnboardingCubit>().setLocationPermission(
      granted: true,
      radiusKm: _radiusKm,
    );
    context.go('/first-vibe');
  }

  void _onSkip() {
    context.read<OnboardingCubit>().setLocationPermission(
      granted: false,
      radiusKm: _radiusKm,
    );
    context.go('/first-vibe');
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
          onPressed: () => context.go('/set-vibe'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: VibeTokens.space2),
              // Security / Privacy badge
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
                    const Icon(Icons.lock_outline, size: 14, color: VibeTokens.brandPurple800),
                    const SizedBox(width: 4),
                    Text(
                      'PRIVACY PRESERVED',
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
                'Find your people\nnearby',
                style: VibeTokens.displaySm.copyWith(
                  color: VibeTokens.neutral900,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: VibeTokens.space2),
              Text(
                "We'll only use your location to find relevant people, places, and activities nearby. Your real-time GPS coordinates are never exposed or tracked.",
                style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral600),
              ),
              const SizedBox(height: VibeTokens.space6),

              // Visual Map / Radar Graphic
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: VibeTokens.brandPurple050,
                        border: Border.all(color: VibeTokens.brandPurple200.withOpacity(0.6), width: 1.5),
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: VibeTokens.brandPurple100.withOpacity(0.5),
                        border: Border.all(color: VibeTokens.brandPurple300, width: 1.5),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: VibeTokens.brandPurple800,
                        boxShadow: [
                          BoxShadow(
                            color: VibeTokens.brandPurple500.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: VibeTokens.neutral000,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: VibeTokens.space6),

              // Radius Selector Card
              Container(
                padding: const EdgeInsets.all(VibeTokens.space4),
                decoration: BoxDecoration(
                  color: VibeTokens.neutral050,
                  borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
                  border: Border.all(color: VibeTokens.neutral200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Discovery Radius',
                          style: VibeTokens.titleMd.copyWith(
                            color: VibeTokens.neutral900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: VibeTokens.brandPurple100,
                            borderRadius: BorderRadius.circular(VibeTokens.radiusSm),
                          ),
                          child: Text(
                            '${_radiusKm.toStringAsFixed(1)} km',
                            style: VibeTokens.labelSm.copyWith(
                              color: VibeTokens.brandPurple900,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: VibeTokens.space2),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: VibeTokens.brandPurple800,
                        inactiveTrackColor: VibeTokens.neutral200,
                        thumbColor: VibeTokens.brandPurple800,
                        overlayColor: VibeTokens.brandPurple200.withOpacity(0.3),
                      ),
                      child: Slider(
                        value: _radiusKm,
                        min: 1.0,
                        max: 15.0,
                        divisions: 14,
                        onChanged: (val) => setState(() => _radiusKm = val),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary: Allow Location
              PrimaryButton(
                label: 'Allow Location',
                icon: Icons.near_me_outlined,
                onTap: _onAllow,
              ),
              const SizedBox(height: VibeTokens.space2),

              // Secondary: Not now
              Center(
                child: TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    'Not now',
                    style: VibeTokens.labelLg.copyWith(color: VibeTokens.neutral500),
                  ),
                ),
              ),
              const SizedBox(height: VibeTokens.space3),
            ],
          ),
        ),
      ),
    );
  }
}
