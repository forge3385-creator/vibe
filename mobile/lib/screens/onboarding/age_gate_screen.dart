import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../services/sound_manager.dart';
import '../../ui/glass/glass_container.dart';
import '../../ui/glass/glass_button.dart';
import '../../ui/glass/cosmic_background.dart';

class AgeGateScreen extends StatefulWidget {
  const AgeGateScreen({super.key});

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _yearController = TextEditingController(text: '2004');
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  String? _localError;
  int? _calculatedAge;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
    _updateCalculatedAge('2004');
  }

  @override
  void dispose() {
    _yearController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _updateCalculatedAge(String text) {
    final year = int.tryParse(text.trim());
    if (year != null && year >= 1920 && year <= DateTime.now().year) {
      setState(() {
        _calculatedAge = DateTime.now().year - year;
        _localError = null;
      });
    } else {
      setState(() {
        _calculatedAge = null;
      });
    }
  }

  void _verifyAge() {
    final year = int.tryParse(_yearController.text.trim());
    if (year == null || year < 1920 || year > DateTime.now().year) {
      SoundManager().playAlert();
      setState(() {
        _localError = 'Please enter a valid 4-digit birth year.';
      });
      return;
    }

    final cubit = context.read<OnboardingCubit>();
    final passed = cubit.verifyAge(year);

    if (passed) {
      SoundManager().playSuccess();
      setState(() => _localError = null);
      context.go('/auth');
    } else {
      SoundManager().playAlert();
      setState(() {
        _localError = cubit.state.ageGateError ??
            'Vibe is strictly for ages 16 and older to preserve our community standard.';
      });
    }
  }

  void _selectPreset(String yearStr) {
    SoundManager().playTap();
    _yearController.text = yearStr;
    _updateCalculatedAge(yearStr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibeTokens.darkBgCosmic,
      body: CosmicBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: VibeTokens.space3),

                    // Top Glass Navigation Bar & Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Glass Back Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                            onTap: () {
                              SoundManager().playTap();
                              context.go('/intro');
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

                        // Progress Step Badge
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
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: VibeTokens.glowPurple,
                                  boxShadow: [
                                    BoxShadow(
                                      color: VibeTokens.glowPurple,
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'STEP 2 OF 6',
                                style: VibeTokens.labelSm.copyWith(
                                  color: VibeTokens.brandPurple200,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Sound Toggle Pill
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                            onTap: () {
                              final sm = SoundManager();
                              sm.setSoundEnabled(!sm.isSoundEnabled);
                              if (sm.isSoundEnabled) sm.playTap();
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                                color: VibeTokens.glassFillSubtle,
                                border: Border.all(
                                  color: SoundManager().isSoundEnabled
                                      ? VibeTokens.glowPurple.withAlpha(90)
                                      : VibeTokens.glassBorderLight,
                                ),
                              ),
                              child: Icon(
                                SoundManager().isSoundEnabled
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                                color: SoundManager().isSoundEnabled
                                    ? VibeTokens.brandPurple300
                                    : VibeTokens.darkTextMuted,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: VibeTokens.space5),

                    // Safety Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: VibeTokens.space3 + 2,
                        vertical: VibeTokens.space1 + 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x287C3AED),
                        borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                        border: Border.all(color: const Color(0x66A78BFA)),
                        boxShadow: [
                          BoxShadow(
                            color: VibeTokens.glowPurple.withAlpha(30),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: VibeTokens.brandPurple200,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SAFETY & INTEGRITY',
                            style: VibeTokens.labelSm.copyWith(
                              color: VibeTokens.brandPurple200,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.9,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: VibeTokens.space3),

                    // Cinematic Display Heading
                    Text(
                      'Welcome to VIBE',
                      style: VibeTokens.displayLg.copyWith(
                        color: VibeTokens.darkTextPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: VibeTokens.space2),
                    Text(
                      'To preserve a safe and intentional environment, Vibe requires all members to be at least 16 years of age.',
                      style: VibeTokens.bodyMd.copyWith(
                        color: VibeTokens.darkTextSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: VibeTokens.space6),

                    // Main Floating Glass Card
                    GlassContainer(
                      padding: const EdgeInsets.all(VibeTokens.space6),
                      borderRadius: VibeTokens.radiusXl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'What year were you born?',
                                style: VibeTokens.titleMd.copyWith(
                                  color: VibeTokens.darkTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // Live Age Badge
                              if (_calculatedAge != null)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _calculatedAge! >= 16
                                        ? const Color(0x3310B981)
                                        : const Color(0x33EF4444),
                                    borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                                    border: Border.all(
                                      color: _calculatedAge! >= 16
                                          ? const Color(0x8010B981)
                                          : const Color(0x80EF4444),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _calculatedAge! >= 16
                                            ? Icons.check_circle_outline
                                            : Icons.error_outline,
                                        size: 13,
                                        color: _calculatedAge! >= 16
                                            ? VibeTokens.semanticSuccess
                                            : VibeTokens.semanticDanger,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _calculatedAge! >= 16
                                            ? 'Age $_calculatedAge · Eligible'
                                            : 'Age $_calculatedAge · Must be 16+',
                                        style: VibeTokens.labelSm.copyWith(
                                          color: _calculatedAge! >= 16
                                              ? const Color(0xFF6EE7B7)
                                              : const Color(0xFFFCA5A5),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: VibeTokens.space4),

                          // Futuristic Year Input Field
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0x1A000000),
                              borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                              border: Border.all(
                                color: _localError != null
                                    ? VibeTokens.semanticDanger
                                    : const Color(0x55A78BFA),
                                width: _localError != null ? 1.5 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _localError != null
                                      ? VibeTokens.semanticDanger.withAlpha(40)
                                      : VibeTokens.glowPurple.withAlpha(30),
                                  blurRadius: 14,
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              onChanged: _updateCalculatedAge,
                              style: VibeTokens.displaySm.copyWith(
                                color: VibeTokens.brandPurple200,
                                letterSpacing: 8.0,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'YYYY',
                                hintStyle: VibeTokens.displaySm.copyWith(
                                  color: VibeTokens.darkTextMuted,
                                  letterSpacing: 8.0,
                                ),
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: VibeTokens.space4,
                                  vertical: VibeTokens.space4,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: VibeTokens.space4),

                          // Quick Preset Chips for Easy Tap
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Quick select: ',
                                style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextMuted),
                              ),
                              const SizedBox(width: 6),
                              for (final yearStr in ['2004', '2002', '2000', '1998']) ...[
                                InkWell(
                                  borderRadius: BorderRadius.circular(VibeTokens.radiusSm),
                                  onTap: () => _selectPreset(yearStr),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _yearController.text == yearStr
                                          ? const Color(0x407C3AED)
                                          : VibeTokens.glassFillSubtle,
                                      borderRadius: BorderRadius.circular(VibeTokens.radiusSm),
                                      border: Border.all(
                                        color: _yearController.text == yearStr
                                            ? VibeTokens.brandPurple400
                                            : VibeTokens.glassBorderLight,
                                      ),
                                    ),
                                    child: Text(
                                      yearStr,
                                      style: VibeTokens.labelSm.copyWith(
                                        color: _yearController.text == yearStr
                                            ? VibeTokens.brandPurple200
                                            : VibeTokens.darkTextSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Error Notification Banner
                    if (_localError != null) ...[
                      const SizedBox(height: VibeTokens.space3),
                      Container(
                        padding: const EdgeInsets.all(VibeTokens.space3),
                        decoration: BoxDecoration(
                          color: const Color(0x33DC2626),
                          borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                          border: Border.all(color: const Color(0x80EF4444)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22EF4444),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFFCA5A5),
                              size: 20,
                            ),
                            const SizedBox(width: VibeTokens.space2),
                            Expanded(
                              child: Text(
                                _localError!,
                                style: VibeTokens.bodySm.copyWith(
                                  color: const Color(0xFFFCA5A5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Zero-Knowledge Privacy Note
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline, size: 14, color: VibeTokens.darkTextMuted),
                          const SizedBox(width: 6),
                          Text(
                            'Your exact birth year is hashed and never shared publicly.',
                            style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextMuted),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: VibeTokens.space4),

                    // Primary Action Button with Sound & Glow
                    Padding(
                      padding: const EdgeInsets.only(bottom: VibeTokens.space4),
                      child: GlassButton(
                        label: 'Verify & Continue →',
                        variant: GlassButtonVariant.primary,
                        onTap: _verifyAge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
