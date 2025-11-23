class Outfit {
  final String id;
  final String name;
  final List<String> itemIds;
  final String occasion;
  final String? weather;
  final int rating;
  final String? notes;
  final DateTime createdAt;
  final DateTime? lastWorn;

  Outfit({
    required this.id,
    required this.name,
    required this.itemIds,
    required this.occasion,
    this.weather,
    this.rating = 0,
    this.notes,
    required this.createdAt,
    this.lastWorn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'itemIds': itemIds.join(','),
      'occasion': occasion,
      'weather': weather,
      'rating': rating,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastWorn': lastWorn?.millisecondsSinceEpoch,
    };
  }

  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'],
      name: map['name'],
      itemIds: map['itemIds'].split(',').where((s) => s.isNotEmpty).toList(),
      occasion: map['occasion'],
      weather: map['weather'],
      rating: map['rating'] ?? 0,
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastWorn: map['lastWorn'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastWorn'])
          : null,
    );
  }
}