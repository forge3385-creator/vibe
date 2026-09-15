import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

enum EnergyType { low, medium, high }

class EnergyChip extends StatelessWidget {
  final EnergyType energy;
  final bool isSelected;
  final ValueChanged<EnergyType> onSelected;

  const EnergyChip({
    super.key,
    required this.energy,
    required this.isSelected,
    required this.onSelected,
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
    final bg = isSelected ? VibeTokens.brandPurple100 : VibeTokens.neutral000;
    final text = isSelected ? VibeTokens.brandPurple800 : VibeTokens.neutral600;
    final border = isSelected
        ? const BorderSide(color: VibeTokens.brandPurple700, width: 1.5)
        : const BorderSide(color: VibeTokens.neutral200, width: 1.0);

    return Semantics(
      label: label,
      value: energy.name,
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelected(energy),
          borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
          child: AnimatedContainer(
            duration: VibeTokens.motionFast,
            padding: const EdgeInsets.symmetric(
              horizontal: VibeTokens.space4,
              vertical: VibeTokens.space2,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
              border: Border.fromBorderSide(border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: text),
                const SizedBox(width: VibeTokens.space1),
                Text(label, style: VibeTokens.labelLg.copyWith(color: text)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
