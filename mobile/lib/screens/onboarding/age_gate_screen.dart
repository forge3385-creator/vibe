import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../ui/buttons/primary_button.dart';

class AgeGateScreen extends StatefulWidget {
  const AgeGateScreen({super.key});

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  final TextEditingController _yearController = TextEditingController(text: '2004');
  String? _localError;

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  void _verifyAge() {
    final year = int.tryParse(_yearController.text.trim());
    if (year == null || year < 1920 || year > DateTime.now().year) {
      setState(() {
        _localError = 'Please enter a valid 4-digit birth year.';
      });
      return;
    }

    final cubit = context.read<OnboardingCubit>();
    final passed = cubit.verifyAge(year);

    if (passed) {
      setState(() => _localError = null);
      context.go('/auth');
    } else {
      setState(() {
        _localError = cubit.state.ageGateError ??
            'Vibe is strictly for ages 16 and older to keep our community safe.';
      });
    }
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
          onPressed: () => context.go('/intro'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: VibeTokens.space2),
              // Safety Gate Badge
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
                    const Icon(Icons.shield_outlined, size: 14, color: VibeTokens.brandPurple800),
                    const SizedBox(width: 4),
                    Text(
                      'SAFETY & INTEGRITY',
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
                'Welcome to VIBE',
                style: VibeTokens.displaySm.copyWith(
                  color: VibeTokens.neutral900,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: VibeTokens.space2),
              Text(
                'To preserve a safe and intentional environment, Vibe requires all members to be at least 16 years of age.',
                style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral600),
              ),
              const SizedBox(height: VibeTokens.space6),

              // Year Input Card
              Container(
                padding: const EdgeInsets.all(VibeTokens.space4),
                decoration: BoxDecoration(
                  color: VibeTokens.neutral050,
                  borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
                  border: Border.all(
                    color: _localError != null ? VibeTokens.semanticDanger : VibeTokens.neutral200,
                    width: _localError != null ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What year were you born?',
                      style: VibeTokens.titleMd.copyWith(
                        color: VibeTokens.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: VibeTokens.space2),
                    TextField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      style: VibeTokens.displaySm.copyWith(
                        color: VibeTokens.brandPurple800,
                        letterSpacing: 4.0,
                      ),
                      decoration: InputDecoration(
                        hintText: 'YYYY',
                        counterText: '',
                        filled: true,
                        fillColor: VibeTokens.neutral000,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                          borderSide: const BorderSide(color: VibeTokens.neutral300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                          borderSide: const BorderSide(color: VibeTokens.neutral300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                          borderSide: const BorderSide(color: VibeTokens.brandPurple800, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: VibeTokens.space4,
                          vertical: VibeTokens.space3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Error or Hard-Stop Banner
              if (_localError != null) ...[
                const SizedBox(height: VibeTokens.space3),
                Container(
                  padding: const EdgeInsets.all(VibeTokens.space3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                    border: Border.all(color: VibeTokens.semanticDanger.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: VibeTokens.semanticDanger, size: 20),
                      const SizedBox(width: VibeTokens.space2),
                      Expanded(
                        child: Text(
                          _localError!,
                          style: VibeTokens.bodySm.copyWith(
                            color: VibeTokens.semanticDanger,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Quick Info Note
              Center(
                child: Text(
                  'Your exact birth date is never displayed publicly.',
                  style: VibeTokens.bodySm.copyWith(color: VibeTokens.neutral400),
                ),
              ),
              const SizedBox(height: VibeTokens.space3),

              // Continue Button
              Padding(
                padding: const EdgeInsets.only(bottom: VibeTokens.space4),
                child: PrimaryButton(
                  label: 'Verify & Continue →',
                  onTap: _verifyAge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
