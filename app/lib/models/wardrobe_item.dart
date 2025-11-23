enum ClothingType { top, bottom, dress, outerwear, shoes, accessory }
enum Season { spring, summer, fall, winter, allSeason }

class WardrobeItem {
  final String id;
  final String name;
  final ClothingType type;
  final String color;
  final String? pattern;
  final String? fabric;
  final String? fit;
  final Season season;
  final String? imagePath;
  final List<String> tags;
  final int rating;
  final int wearCount;
  final DateTime lastWorn;
  final DateTime createdAt;

  WardrobeItem({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    this.pattern,
    this.fabric,
    this.fit,
    required this.season,
    this.imagePath,
    required this.tags,
    this.rating = 0,
    this.wearCount = 0,
    required this.lastWorn,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'color': color,
      'pattern': pattern,
      'fabric': fabric,
      'fit': fit,
      'season': season.index,
      'imagePath': imagePath,
      'tags': tags.join(','),
      'rating': rating,
      'wearCount': wearCount,
      'lastWorn': lastWorn.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory WardrobeItem.fromMap(Map<String, dynamic> map) {
    return WardrobeItem(
      id: map['id'],
      name: map['name'],
      type: ClothingType.values[map['type']],
      color: map['color'],
      pattern: map['pattern'],
      fabric: map['fabric'],
      fit: map['fit'],
      season: Season.values[map['season']],
      imagePath: map['imagePath'],
      tags: map['tags']?.split(',')?.where((s) => s.isNotEmpty)?.toList() ?? [],
      rating: map['rating'] ?? 0,
      wearCount: map['wearCount'] ?? 0,
      lastWorn: DateTime.fromMillisecondsSinceEpoch(map['lastWorn']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  WardrobeItem copyWith({
    String? name,
    ClothingType? type,
    String? color,
    String? pattern,
    String? fabric,
    String? fit,
    Season? season,
    String? imagePath,
    List<String>? tags,
    int? rating,
    int? wearCount,
    DateTime? lastWorn,
  }) {
    return WardrobeItem(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      pattern: pattern ?? this.pattern,
      fabric: fabric ?? this.fabric,
      fit: fit ?? this.fit,
      season: season ?? this.season,
      imagePath: imagePath ?? this.imagePath,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      wearCount: wearCount ?? this.wearCount,
      lastWorn: lastWorn ?? this.lastWorn,
      createdAt: createdAt,
    );
  }
}