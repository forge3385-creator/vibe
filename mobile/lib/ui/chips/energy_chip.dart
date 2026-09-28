import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

enum EnergyType { low, medium, high }

class EnergyChip extends StatelessWidget {
  final EnergyType energy;
  final bool isSelected;
  final ValueChanged<EnergyType>? onSelected;
  final bool small;

  const EnergyChip({
    super.key,
    required this.energy,
    this.isSelected = false,
    this.onSelected,
    this.small = false,
  });

  String get label {
    switch (energy) {
      case EnergyType.low:
        return 'Low Energy';
      case EnergyType.medium:
        return 'Medium Energy';
      case EnergyType.high:
        return 'High Energy';
    }
  }

  IconData get icon {
    switch (energy) {
      case EnergyType.low:
        return Icons.spa_outlined;
      case EnergyType.medium:
        return Icons.coffee_outlined;
      case EnergyType.high:
        return Icons.bolt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? const Color(0x337C3AED) : VibeTokens.glassFillSubtle;
    final text = isSelected ? VibeTokens.brandPurple200 : VibeTokens.darkTextSecondary;
    final border = isSelected
        ? const BorderSide(color: VibeTokens.brandPurple400, width: 1.5)
        : const BorderSide(color: VibeTokens.glassBorderLight, width: 1.0);

    return Semantics(
      label: label,
      value: energy.name,
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelected != null ? () => onSelected!(energy) : null,
          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
          child: AnimatedContainer(
            duration: VibeTokens.motionFast,
            padding: EdgeInsets.symmetric(
              horizontal: small ? 8 : VibeTokens.space3,
              vertical: small ? 3 : VibeTokens.space1 + 2,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
              border: Border.fromBorderSide(border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: small ? 12 : 15, color: text),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: (small ? VibeTokens.labelSm : VibeTokens.labelLg).copyWith(
                    color: text,
                    fontSize: small ? 11 : 13,
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
