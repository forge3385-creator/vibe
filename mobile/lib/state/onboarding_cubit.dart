import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_profile.dart';
import '../models/vibe_intent.dart';
import '../models/candidate.dart';
import '../ui/chips/energy_chip.dart';

class OnboardingState extends Equatable {
  final bool isOnboarded;
  final bool isAuthenticated;
  final bool isLoading;
  final String loadingMessage;
  final UserProfile profile;
  final VibeIntent? currentIntent;
  final List<VibeCandidate> candidates;
  final String? ageGateError;
  final bool phoneOtpSent;
  final String enteredPhone;
  final bool isDark;

  const OnboardingState({
    this.isOnboarded = false,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.loadingMessage = '',
    this.profile = const UserProfile(),
    this.currentIntent,
    this.candidates = defaultCandidates,
    this.ageGateError,
    this.phoneOtpSent = false,
    this.enteredPhone = '',
    this.isDark = false,
  });

  OnboardingState copyWith({
    bool? isOnboarded,
    bool? isAuthenticated,
    bool? isLoading,
    String? loadingMessage,
    UserProfile? profile,
    VibeIntent? currentIntent,
    List<VibeCandidate>? candidates,
    String? ageGateError,
    bool? phoneOtpSent,
    String? enteredPhone,
    bool? isDark,
    bool clearAgeGateError = false,
    bool clearIntent = false,
  }) {
    return OnboardingState(
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      profile: profile ?? this.profile,
      currentIntent: clearIntent ? null : (currentIntent ?? this.currentIntent),
      candidates: candidates ?? this.candidates,
      ageGateError: clearAgeGateError ? null : (ageGateError ?? this.ageGateError),
      phoneOtpSent: phoneOtpSent ?? this.phoneOtpSent,
      enteredPhone: enteredPhone ?? this.enteredPhone,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  List<Object?> get props => [
        isOnboarded,
        isAuthenticated,
        isLoading,
        loadingMessage,
        profile,
        currentIntent,
        candidates,
        ageGateError,
        phoneOtpSent,
        enteredPhone,
        isDark,
      ];
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  void toggleTheme() {
    emit(state.copyWith(isDark: !state.isDark));
  }

  // Age Gate (16+)
  bool verifyAge(int birthYear) {
    final currentYear = DateTime.now().year;
    final age = currentYear - birthYear;
    if (age < 16) {
      emit(state.copyWith(
        ageGateError: 'Vibe is strictly for ages 16 and older to keep our community safe.',
      ));
      return false;
    }
    emit(state.copyWith(
      clearAgeGateError: true,
      profile: state.profile.copyWith(birthYear: birthYear, age: age),
    ));
    return true;
  }

  // Auth: Google, Apple, Phone OTP or Skip
  Future<void> signInWithGoogle() async {
    emit(state.copyWith(isLoading: true, loadingMessage: 'Getting your Vibe ready...'));
    await Future.delayed(const Duration(milliseconds: 700));
    emit(state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      profile: state.profile.copyWith(
        name: state.profile.name.isEmpty ? 'Alex Rivera' : state.profile.name,
        authProvider: 'google',
      ),
    ));
  }

  Future<void> signInWithApple() async {
    emit(state.copyWith(isLoading: true, loadingMessage: 'Getting your Vibe ready...'));
    await Future.delayed(const Duration(milliseconds: 700));
    emit(state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      profile: state.profile.copyWith(
        name: state.profile.name.isEmpty ? 'Alex' : state.profile.name,
        authProvider: 'apple',
      ),
    ));
  }

  void sendPhoneOtp(String phone) {
    emit(state.copyWith(
      enteredPhone: phone,
      phoneOtpSent: true,
    ));
  }

  Future<bool> verifyPhoneOtp(String otp) async {
    emit(state.copyWith(isLoading: true, loadingMessage: 'Verifying code...'));
    await Future.delayed(const Duration(milliseconds: 600));
    emit(state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      profile: state.profile.copyWith(
        phone: state.enteredPhone,
        authProvider: 'phone',
      ),
    ));
    return true;
  }

  void skipAuth() {
    emit(state.copyWith(
      isAuthenticated: true,
      profile: state.profile.copyWith(
        name: state.profile.name.isEmpty ? 'Explorer' : state.profile.name,
        authProvider: 'guest',
      ),
    ));
  }

  // Profile Setup
  void updateProfile({required String name, required String city, int? age}) {
    emit(state.copyWith(
      profile: state.profile.copyWith(
        name: name,
        city: city,
        age: age ?? state.profile.age,
      ),
    ));
  }

  // Intention Selection
  void setDraftIntent({
    required String title,
    required String icon,
    required EnergyType energy,
  }) {
    final intent = VibeIntent(
      id: 'intent-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      icon: icon,
      energy: energy,
      radiusKm: state.profile.radiusKm,
    );
    emit(state.copyWith(currentIntent: intent));
  }

  // Location Permission & Radius
  void setLocationPermission({required bool granted, double? radiusKm}) {
    final radius = radiusKm ?? state.profile.radiusKm;
    emit(state.copyWith(
      profile: state.profile.copyWith(
        locationEnabled: granted,
        radiusKm: radius,
      ),
      currentIntent: state.currentIntent?.copyWith(radiusKm: radius),
    ));
  }

  // Create First Vibe & Start Matching
  Future<void> createFirstVibeAndMatch() async {
    emit(state.copyWith(
      isLoading: true,
      loadingMessage: 'Finding your people...\nMatching your intention with people nearby...',
    ));
    await Future.delayed(const Duration(milliseconds: 1400));
    emit(state.copyWith(
      isLoading: false,
      isOnboarded: true,
    ));
  }

  void resetOnboarding() {
    emit(const OnboardingState());
  }
}
