import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../services/sound_manager.dart';
import '../../ui/glass/glass_container.dart';
import '../../ui/glass/glass_button.dart';
import '../../ui/glass/cosmic_background.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool _isSignInMode = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
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
    _phoneController.dispose();
    _otpController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleGoogle() async {
    SoundManager().playTap();
    final cubit = context.read<OnboardingCubit>();
    await cubit.signInWithGoogle();
    SoundManager().playSuccess();
    if (mounted) context.go('/profile-setup');
  }

  void _handleApple() async {
    SoundManager().playTap();
    final cubit = context.read<OnboardingCubit>();
    await cubit.signInWithApple();
    SoundManager().playSuccess();
    if (mounted) context.go('/profile-setup');
  }

  void _handleSkip() {
    SoundManager().playStep();
    context.read<OnboardingCubit>().skipAuth();
    context.go('/profile-setup');
  }

  void _submitPhone() {
    if (_phoneController.text.trim().length >= 7) {
      SoundManager().playSuccess();
      context.read<OnboardingCubit>().sendPhoneOtp(_phoneController.text.trim());
    } else {
      SoundManager().playAlert();
    }
  }

  void _verifyOtp() async {
    SoundManager().playTap();
    final success = await context.read<OnboardingCubit>().verifyPhoneOtp(_otpController.text.trim());
    if (success && mounted) {
      SoundManager().playSuccess();
      Navigator.of(context).pop();
      context.go('/profile-setup');
    } else {
      SoundManager().playAlert();
    }
  }

  void _showPhoneModal(BuildContext context) {
    SoundManager().playTap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(VibeTokens.radiusXl)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xF00D0B18),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(VibeTokens.radiusXl)),
                      border: Border.all(color: const Color(0x33A78BFA)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x80000000),
                          blurRadius: 32,
                        ),
                      ],
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0x337C3AED),
                                border: Border.all(color: const Color(0x66A78BFA)),
                              ),
                              child: const Icon(Icons.phone_android_rounded, color: VibeTokens.brandPurple200, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              state.phoneOtpSent ? 'Verify Phone Code' : 'Phone Verification',
                              style: VibeTokens.titleLg.copyWith(
                                color: VibeTokens.darkTextPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: VibeTokens.space2),
                        Text(
                          state.phoneOtpSent
                              ? 'Enter the 6-digit verification code sent to ${state.enteredPhone}.'
                              : 'We use your phone strictly for account verification. Never shared or marketed.',
                          style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextSecondary),
                        ),
                        const SizedBox(height: VibeTokens.space5),
                        if (!state.phoneOtpSent) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0x22FFFFFF),
                              borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                              border: Border.all(color: const Color(0x33FFFFFF)),
                            ),
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: VibeTokens.bodyLg.copyWith(color: VibeTokens.darkTextPrimary),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.dialpad, color: VibeTokens.brandPurple300, size: 20),
                                hintText: '+1 (555) 000-0000',
                                hintStyle: VibeTokens.bodyLg.copyWith(color: VibeTokens.darkTextMuted),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: VibeTokens.space5),
                          GlassButton(
                            label: 'Send Verification Code',
                            variant: GlassButtonVariant.primary,
                            onTap: _submitPhone,
                          ),
                        ] else ...[
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0x22FFFFFF),
                              borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                              border: Border.all(color: const Color(0x66A78BFA)),
                            ),
                            child: TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: VibeTokens.displaySm.copyWith(
                                color: VibeTokens.brandPurple200,
                                letterSpacing: 8.0,
                              ),
                              decoration: InputDecoration(
                                hintText: '000000',
                                hintStyle: VibeTokens.displaySm.copyWith(
                                  color: VibeTokens.darkTextMuted,
                                  letterSpacing: 8.0,
                                ),
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: VibeTokens.space5),
                          GlassButton(
                            label: 'Confirm & Continue →',
                            variant: GlassButtonVariant.primary,
                            onTap: _verifyOtp,
                          ),
                        ],
                        const SizedBox(height: VibeTokens.space2),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.isAuthenticated && !state.isLoading) {
          context.go('/profile-setup');
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: VibeTokens.darkBgCosmic,
            body: CosmicBackground(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: VibeTokens.heroGradient,
                        boxShadow: [
                          BoxShadow(
                            color: VibeTokens.glowPurple.withAlpha(120),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(height: VibeTokens.space5),
                    Text(
                      state.loadingMessage.isNotEmpty ? state.loadingMessage : 'Getting your Vibe ready...',
                      style: VibeTokens.titleMd.copyWith(
                        color: VibeTokens.darkTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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

                      // Top Glass Header with Back and Skip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                              onTap: () {
                                SoundManager().playTap();
                                context.go('/age-gate');
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
                              'STEP 3 OF 6',
                              style: VibeTokens.labelSm.copyWith(
                                color: VibeTokens.brandPurple200,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          // Skip Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                              onTap: _handleSkip,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                                  color: VibeTokens.glassFillSubtle,
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

                      const SizedBox(height: VibeTokens.space6),

                      // Title
                      Text(
                        _isSignInMode ? 'Welcome Back' : 'Create Account',
                        style: VibeTokens.displayLg.copyWith(
                          color: VibeTokens.darkTextPrimary,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: VibeTokens.space2),
                      Text(
                        _isSignInMode
                            ? 'Sign in to reconnect with your community and offline vibes.'
                            : 'Set up your private identity to discover curated real-world meetups.',
                        style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextSecondary),
                      ),

                      const SizedBox(height: VibeTokens.space6),

                      // Social Buttons Glass Container
                      GlassContainer(
                        padding: const EdgeInsets.all(VibeTokens.space5),
                        borderRadius: VibeTokens.radiusXl,
                        child: Column(
                          children: [
                            // Google
                            _buildGlassAuthRow(
                              label: 'Continue with Google',
                              icon: Icons.g_mobiledata_rounded,
                              iconColor: const Color(0xFFEA4335),
                              onTap: _handleGoogle,
                            ),
                            const SizedBox(height: VibeTokens.space3),

                            // Apple
                            _buildGlassAuthRow(
                              label: 'Continue with Apple',
                              icon: Icons.apple_rounded,
                              iconColor: Colors.white,
                              onTap: _handleApple,
                            ),
                            const SizedBox(height: VibeTokens.space3),

                            // Phone
                            _buildGlassAuthRow(
                              label: 'Continue with Phone SMS',
                              icon: Icons.phone_iphone_rounded,
                              iconColor: VibeTokens.brandPurple300,
                              onTap: () => _showPhoneModal(context),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: VibeTokens.space5),

                      // Privacy Assurance Callout
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space4, vertical: VibeTokens.space3),
                        borderRadius: VibeTokens.radiusMd,
                        fillColor: const Color(0x0CFFFFFF),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_outlined, color: VibeTokens.glowCyan, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'End-to-end encrypted identity · Zero personal data sale guaranteed.',
                                style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Mode Toggle
                      Center(
                        child: TextButton(
                          onPressed: () {
                            SoundManager().playTap();
                            setState(() => _isSignInMode = !_isSignInMode);
                          },
                          child: RichText(
                            text: TextSpan(
                              text: _isSignInMode
                                  ? "Don't have an account? "
                                  : 'Already have an account? ',
                              style: VibeTokens.bodyMd.copyWith(color: VibeTokens.darkTextSecondary),
                              children: [
                                TextSpan(
                                  text: _isSignInMode ? 'Sign up' : 'Sign in',
                                  style: VibeTokens.bodyMd.copyWith(
                                    color: VibeTokens.brandPurple300,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: VibeTokens.space4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassAuthRow({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0x18FFFFFF),
            borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
            border: Border.all(color: const Color(0x28FFFFFF)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space4),
          child: Row(
            children: [
              Icon(icon, size: 24, color: iconColor),
              const SizedBox(width: VibeTokens.space3),
              Expanded(
                child: Text(
                  label,
                  style: VibeTokens.labelLg.copyWith(
                    color: VibeTokens.darkTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: VibeTokens.darkTextMuted),
            ],
          ),
        ),
      ),
    );
  }
}
