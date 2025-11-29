import 'package:uuid/uuid.dart';
import '../models/wardrobe_item.dart';
import '../models/user_profile.dart';

class DemoData {
  static const Uuid _uuid = Uuid();

  static UserProfile createDemoProfile() {
    return UserProfile(
      id: 'default_user',
      name: 'Demo User',
      gender: 'female',
      bodyType: 'hourglass',
      skinUndertone: 'warm',
      faceShape: 'oval',
      favoriteColors: ['blue', 'white', 'black', 'red'],
      dislikedPatterns: ['polka dots', 'animal print'],
      measurements: {
        'bust': '36',
        'waist': '28',
        'hips': '38',
        'height': '5\'6"',
      },
      stylePreferences: {
        'style': 'classic',
        'formality': 'business casual',
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static List<WardrobeItem> createDemoWardrobe() {
    final now = DateTime.now();
    
    return [
      // Tops
      WardrobeItem(
        id: _uuid.v4(),
        name: 'White Button-Down Shirt',
        type: ClothingType.top,
        color: 'white',
        pattern: 'solid',
        fabric: 'cotton',
        fit: 'fitted',
        season: Season.allSeason,
        tags: ['professional', 'classic', 'versatile'],
        rating: 5,
        wearCount: 15,
        lastWorn: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      
      WardrobeItem(
        id: _uuid.v4(),
        name: 'Navy Blazer',
        type: ClothingType.outerwear,
        color: 'navy',
        pattern: 'solid',
        fabric: 'wool blend',
        fit: 'tailored',
        season: Season.allSeason,
        tags: ['professional', 'formal', 'structured'],
        rating: 5,
        wearCount: 8,
        lastWorn: now.subtract(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      
      WardrobeItem(
        id: _uuid.v4(),
        name: 'Striped T-Shirt',
        type: ClothingType.top,
        color: 'blue',
        pattern: 'stripes',
        fabric: 'cotton',
        fit: 'relaxed',
        season: Season.summer,
        tags: ['casual', 'comfortable', 'weekend'],
        rating: 4,
        wearCount: 12,
        lastWorn: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      
      // Bottoms
      WardrobeItem(
        id: _uuid.v4(),
        name: 'Black Pencil Skirt',
        type: ClothingType.bottom,
        color: 'black',
        pattern: 'solid',
        fabric: 'polyester blend',
        fit: 'fitted',
        season: Season.allSeason,
        tags: ['professional', 'formal', 'office'],
        rating: 4,
        wearCount: 10,
        lastWorn: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 35)),
      ),
      
      WardrobeItem(
        id: _uuid.v4(),
        name: 'Dark Wash Jeans',
        type: ClothingType.bottom,
        color: 'blue',
        pattern: 'solid',
        fabric: 'denim',
        fit: 'straight leg',
        season: Season.allSeason,
        tags: ['casual', 'versatile', 'weekend'],
        rating: 5,
        wearCount: 20,
        lastWorn: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      
      WardrobeItem(
        id: _uuid.v4(),
        name: 'Beige Trousers',
        type: ClothingType.bottom,
        color: 'beige',
        pattern: 'solid',
        fabric: 'cotton blend',
        fit: 'straight leg',
        season: Season.spring,
        tags: ['professional', 'neutral', 'versatile'],
        rating: 4,
        wearCount: 6,
        lastWorn: now.subtract(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      
      // Dresses
      WardrobeItem(
        id: _uuid.v4(),
        name: 'Little Black Dress',
        type: ClothingType.dress,
        color: 'black',
        pattern: 'solid',
        fabric: 'jersey',
        fit: 'fitted',
        season: Season.allSeason,
        tags: ['formal', 'elegant', 'party', 'date'],
        rating: 5,
        wearCount: 5,
        lastWorn: now.subtract(const Duration(days: 14)),
        createdAt: now.subtract(const Duration(days: 40)),
      ),
      
      WardrobeItem(
        id: _uuid.v4(),
        name: 'Floral Summer Dress',
        type: ClothingType.dress,
        color: 'pink',
        pattern: 'floral',
        fabric: 'chiffon',
        fit: 'flowy',
        season: Season.summer,
        tags: ['casual', 'feminine', 'vacation'],
        rating: 4,
        wearCount: 3,
        lastWorn: now.subtract(const Duration(days: 21)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      
      // Shoes
      WardrobeItem(
        id: _uuid.v4(),
        name: 'Black Pumps',
        type: ClothingType.shoes,
        color: 'black',
        pattern: 'solid',
        fabric: 'leather',
        fit: 'true to size',
        season: Season.allSeason,
        tags: ['professional', 'formal', 'heels'],
        rating: 4,
        wearCount: 8,
        lastWorn: now.subtract(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 50)),
      ),
      
      WardrobeItem(
        id: _uuid.v4(),
        name: 'White Sneakers',
        type: ClothingType.shoes,
        color: 'white',
        pattern: 'solid',
        fabric: 'leather',
        fit: 'comfortable',
        season: Season.allSeason,
        tags: ['casual', 'comfortable', 'sporty'],
        rating: 5,
        wearCount: 25,
        lastWorn: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      
      WardrobeItem(
        id: _uuid.v4(),
        name: 'Brown Ankle Boots',
        type: ClothingType.shoes,
        color: 'brown',
        pattern: 'solid',
        fabric: 'leather',
        fit: 'true to size',
        season: Season.fall,
        tags: ['casual', 'boots', 'autumn'],
        rating: 4,
        wearCount: 4,
        lastWorn: now.subtract(const Duration(days: 30)),
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      
      // Accessories
      WardrobeItem(
        id: _uuid.v4(),
        name: 'Pearl Necklace',
        type: ClothingType.accessory,
        color: 'white',
        pattern: 'solid',
        fabric: 'pearl',
        fit: 'adjustable',
        season: Season.allSeason,
        tags: ['elegant', 'classic', 'formal'],
        rating: 5,
        wearCount: 6,
        lastWorn: now.subtract(const Duration(days: 14)),
        createdAt: now.subtract(const Duration(days: 100)),
      ),
      
      WardrobeItem(
        id: _uuid.v4(),
        name: 'Black Leather Handbag',
        type: ClothingType.accessory,
        color: 'black',
        pattern: 'solid',
        fabric: 'leather',
        fit: 'medium',
        season: Season.allSeason,
        tags: ['professional', 'versatile', 'structured'],
        rating: 5,
        wearCount: 18,
        lastWorn: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 80)),
      ),
    ];
  }
}