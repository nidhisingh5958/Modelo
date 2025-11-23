class UserProfile {
  final String id;
  final String name;
  final String gender;
  final String bodyType;
  final String skinUndertone;
  final String faceShape;
  final List<String> favoriteColors;
  final List<String> dislikedPatterns;
  final Map<String, String> measurements;
  final Map<String, dynamic> stylePreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.gender,
    required this.bodyType,
    required this.skinUndertone,
    required this.faceShape,
    required this.favoriteColors,
    required this.dislikedPatterns,
    required this.measurements,
    required this.stylePreferences,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'bodyType': bodyType,
      'skinUndertone': skinUndertone,
      'faceShape': faceShape,
      'favoriteColors': favoriteColors.join(','),
      'dislikedPatterns': dislikedPatterns.join(','),
      'measurements': measurements.entries.map((e) => '${e.key}:${e.value}').join(','),
      'stylePreferences': stylePreferences.entries.map((e) => '${e.key}:${e.value}').join(','),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      gender: map['gender'],
      bodyType: map['bodyType'],
      skinUndertone: map['skinUndertone'],
      faceShape: map['faceShape'],
      favoriteColors: map['favoriteColors'].split(',').where((s) => s.isNotEmpty).toList(),
      dislikedPatterns: map['dislikedPatterns'].split(',').where((s) => s.isNotEmpty).toList(),
      measurements: Map.fromEntries(
        map['measurements'].split(',').where((s) => s.isNotEmpty).map((e) {
          final parts = e.split(':');
          return MapEntry(parts[0], parts[1]);
        }),
      ),
      stylePreferences: Map.fromEntries(
        map['stylePreferences'].split(',').where((s) => s.isNotEmpty).map((e) {
          final parts = e.split(':');
          return MapEntry(parts[0], parts[1]);
        }),
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}