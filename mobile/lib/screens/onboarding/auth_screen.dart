import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../ui/buttons/primary_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignInMode = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleGoogle() async {
    final cubit = context.read<OnboardingCubit>();
    await cubit.signInWithGoogle();
    if (mounted) context.go('/profile-setup');
  }

  void _handleApple() async {
    final cubit = context.read<OnboardingCubit>();
    await cubit.signInWithApple();
    if (mounted) context.go('/profile-setup');
  }

  void _handleSkip() {
    context.read<OnboardingCubit>().skipAuth();
    context.go('/profile-setup');
  }

  void _submitPhone() {
    if (_phoneController.text.trim().length >= 7) {
      context.read<OnboardingCubit>().sendPhoneOtp(_phoneController.text.trim());
    }
  }

  void _verifyOtp() async {
    final success = await context.read<OnboardingCubit>().verifyPhoneOtp(_otpController.text.trim());
    if (success && mounted) {
      Navigator.of(context).pop();
      context.go('/profile-setup');
    }
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
            backgroundColor: VibeTokens.neutral000,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(VibeTokens.brandPurple800),
                    ),
                  ),
                  const SizedBox(height: VibeTokens.space4),
                  Text(
                    state.loadingMessage.isNotEmpty ? state.loadingMessage : 'Getting your Vibe ready...',
                    style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral700, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: VibeTokens.neutral000,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: VibeTokens.neutral800),
              onPressed: () => context.go('/age-gate'),
            ),
            actions: [
              TextButton(
                onPressed: _handleSkip,
                child: Text('Skip for now', style: VibeTokens.labelLg.copyWith(color: VibeTokens.neutral500)),
              ),
              const SizedBox(width: VibeTokens.space2),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: VibeTokens.space2),
                  // Wordmark badge
                  Row(
                    children: [
                      Text(
                        _isSignInMode ? 'Welcome back to' : 'Join',
                        style: VibeTokens.displaySm.copyWith(
                          color: VibeTokens.neutral900,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'VIBE ✦',
                        style: VibeTokens.displaySm.copyWith(
                          color: VibeTokens.brandPurple800,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: VibeTokens.space2),
                  Text(
                    _isSignInMode
                        ? 'Sign in to reconnect with your community and current vibes.'
                        : 'Create your account to match with people nearby and start meeting up.',
                    style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral600),
                  ),
                  const SizedBox(height: VibeTokens.space6),

                  // Google button
                  _buildSocialButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata_rounded,
                    iconColor: const Color(0xFFEA4335),
                    onTap: _handleGoogle,
                  ),
                  const SizedBox(height: VibeTokens.space3),

                  // Apple button
                  _buildSocialButton(
                    label: 'Continue with Apple',
                    icon: Icons.apple,
                    iconColor: VibeTokens.neutral900,
                    onTap: _handleApple,
                  ),
                  const SizedBox(height: VibeTokens.space3),

                  // Phone button
                  _buildSocialButton(
                    label: 'Continue with Phone',
                    icon: Icons.phone_android_rounded,
                    iconColor: VibeTokens.brandPurple800,
                    onTap: () => _showPhoneModal(context),
                  ),

                  const SizedBox(height: VibeTokens.space6),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: VibeTokens.neutral200)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space3),
                        child: Text(
                          'OR',
                          style: VibeTokens.labelSm.copyWith(color: VibeTokens.neutral400),
                        ),
                      ),
                      const Expanded(child: Divider(color: VibeTokens.neutral200)),
                    ],
                  ),

                  const Spacer(),

                  // Toggle Sign In / Sign Up
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignInMode = !_isSignInMode;
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          text: _isSignInMode
                              ? "Don't have an account? "
                              : 'Already have an account? ',
                          style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral600),
                          children: [
                            TextSpan(
                              text: _isSignInMode ? 'Sign up' : 'Sign in',
                              style: VibeTokens.bodyMd.copyWith(
                                color: VibeTokens.brandPurple800,
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
        );
      },
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: VibeTokens.neutral000,
        borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
        border: Border.all(color: VibeTokens.neutral200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: iconColor),
                const SizedBox(width: VibeTokens.space3),
                Text(
                  label,
                  style: VibeTokens.labelLg.copyWith(
                    color: VibeTokens.neutral800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPhoneModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VibeTokens.neutral000,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VibeTokens.radiusXl)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cubit = modalContext.read<OnboardingCubit>();
            final isSent = cubit.state.phoneOtpSent;

            return Padding(
              padding: EdgeInsets.only(
                left: VibeTokens.space6,
                right: VibeTokens.space6,
                top: VibeTokens.space6,
                bottom: MediaQuery.of(context).viewInsets.bottom + VibeTokens.space6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: VibeTokens.neutral200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: VibeTokens.space4),
                  Text(
                    isSent ? 'Enter 6-digit Code' : 'Enter your mobile number',
                    style: VibeTokens.titleLg.copyWith(
                      color: VibeTokens.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: VibeTokens.space2),
                  Text(
                    isSent
                        ? 'We sent a verification code to ${_phoneController.text}'
                        : 'We will send a one-time SMS verification code.',
                    style: VibeTokens.bodySm.copyWith(color: VibeTokens.neutral600),
                  ),
                  const SizedBox(height: VibeTokens.space4),
                  if (!isSent) ...[
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      autofocus: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_outlined, color: VibeTokens.neutral500),
                        hintText: '+1 (555) 019-2834',
                        filled: true,
                        fillColor: VibeTokens.neutral050,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                          borderSide: const BorderSide(color: VibeTokens.neutral200),
                        ),
                      ),
                    ),
                    const SizedBox(height: VibeTokens.space4),
                    PrimaryButton(
                      label: 'Send Verification Code',
                      onTap: () {
                        _submitPhone();
                        setModalState(() {});
                      },
                    ),
                  ] else ...[
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      autofocus: true,
                      style: VibeTokens.displaySm.copyWith(
                        letterSpacing: 8.0,
                        color: VibeTokens.brandPurple800,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '123456',
                        filled: true,
                        fillColor: VibeTokens.neutral050,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                          borderSide: const BorderSide(color: VibeTokens.neutral200),
                        ),
                      ),
                    ),
                    const SizedBox(height: VibeTokens.space4),
                    PrimaryButton(
                      label: 'Verify & Continue',
                      onTap: () {
                        _verifyOtp();
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
