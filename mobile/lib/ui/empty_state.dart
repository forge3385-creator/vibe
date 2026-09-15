import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'buttons/primary_button.dart';

class VibeEmptyState extends StatelessWidget {
  final String headline;
  final String body;
  final String ctaLabel;
  final VoidCallback onAction;
  final IconData icon;

  const VibeEmptyState({
    super.key,
    required this.headline,
    required this.body,
    required this.ctaLabel,
    required this.onAction,
    this.icon = Icons.explore_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: VibeTokens.brandPurple400),
            const SizedBox(height: VibeTokens.space3),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: VibeTokens.titleLg.copyWith(color: VibeTokens.neutral900),
            ),
            const SizedBox(height: VibeTokens.space2),
            Text(
              body,
              textAlign: TextAlign.center,
              style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral600),
            ),
            const SizedBox(height: VibeTokens.space6),
            PrimaryButton(
              label: ctaLabel,
              onTap: onAction,
            ),
          ],
        ),
      ),
    );
  }
}
