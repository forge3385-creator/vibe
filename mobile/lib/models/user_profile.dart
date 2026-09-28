class UserProfile {
  final String name;
  final int age;
  final int birthYear;
  final String city;
  final String? phone;
  final String? authProvider;
  final bool locationEnabled;
  final double radiusKm;

  const UserProfile({
    this.name = '',
    this.age = 19,
    this.birthYear = 2005,
    this.city = 'New York',
    this.phone,
    this.authProvider,
    this.locationEnabled = false,
    this.radiusKm = 5.0,
  });

  UserProfile copyWith({
    String? name,
    int? age,
    int? birthYear,
    String? city,
    String? phone,
    String? authProvider,
    bool? locationEnabled,
    double? radiusKm,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      birthYear: birthYear ?? this.birthYear,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      authProvider: authProvider ?? this.authProvider,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }
}
