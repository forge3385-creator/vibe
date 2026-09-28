import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/onboarding/splash_screen.dart';
import '../screens/onboarding/intro_screen.dart';
import '../screens/onboarding/age_gate_screen.dart';
import '../screens/onboarding/auth_screen.dart';
import '../screens/onboarding/profile_setup_screen.dart';
import '../screens/onboarding/set_vibe_screen.dart';
import '../screens/onboarding/location_screen.dart';
import '../screens/onboarding/first_vibe_screen.dart';
import '../screens/onboarding/matching_screen.dart';
import '../screens/home/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => _buildPage(const SplashScreen(), state),
    ),
    GoRoute(
      path: '/intro',
      pageBuilder: (context, state) => _buildPage(const IntroScreen(), state),
    ),
    GoRoute(
      path: '/age-gate',
      pageBuilder: (context, state) => _buildPage(const AgeGateScreen(), state),
    ),
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) => _buildPage(const AuthScreen(), state),
    ),
    GoRoute(
      path: '/profile-setup',
      pageBuilder: (context, state) => _buildPage(const ProfileSetupScreen(), state),
    ),
    GoRoute(
      path: '/set-vibe',
      pageBuilder: (context, state) => _buildPage(const SetVibeScreen(), state),
    ),
    GoRoute(
      path: '/location',
      pageBuilder: (context, state) => _buildPage(const LocationScreen(), state),
    ),
    GoRoute(
      path: '/first-vibe',
      pageBuilder: (context, state) => _buildPage(const FirstVibeScreen(), state),
    ),
    GoRoute(
      path: '/matching',
      pageBuilder: (context, state) => _buildPage(const MatchingScreen(), state),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _buildPage(const HomeScreen(), state),
    ),
  ],
);

CustomTransitionPage<void> _buildPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 220),
  );
}
