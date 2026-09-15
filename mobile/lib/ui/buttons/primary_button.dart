import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool disabled;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.disabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = !loading && !disabled && onTap != null;

    return Semantics(
      label: label,
      button: true,
      enabled: isInteractive,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 48,
          minWidth: 48,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isInteractive ? onTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isInteractive ? VibeTokens.brandPurple800 : VibeTokens.neutral300,
              foregroundColor: isInteractive ? VibeTokens.neutral000 : VibeTokens.neutral500,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: VibeTokens.space6,
                vertical: VibeTokens.space3,
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(VibeTokens.neutral000),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18),
                        const SizedBox(width: VibeTokens.space2),
                      ],
                      Text(
                        label,
                        style: VibeTokens.labelLg.copyWith(
                          color: isInteractive ? VibeTokens.neutral000 : VibeTokens.neutral500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
