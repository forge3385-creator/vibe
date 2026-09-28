import '../ui/chips/energy_chip.dart';

class VibeIntent {
  final String id;
  final String title;
  final String icon;
  final EnergyType energy;
  final String notes;
  final double radiusKm;
  final DateTime createdAt;

  VibeIntent({
    required this.id,
    required this.title,
    required this.icon,
    required this.energy,
    this.notes = '',
    this.radiusKm = 5.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  VibeIntent copyWith({
    String? id,
    String? title,
    String? icon,
    EnergyType? energy,
    String? notes,
    double? radiusKm,
  }) {
    return VibeIntent(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      energy: energy ?? this.energy,
      notes: notes ?? this.notes,
      radiusKm: radiusKm ?? this.radiusKm,
      createdAt: createdAt,
    );
  }
}
