import 'dart:math';
import '../models/wardrobe_item.dart';
import '../models/user_profile.dart';
import '../models/outfit.dart';

class EnhancedAIModel {
  // Advanced color theory with seasonal palettes
  static const Map<String, Map<String, List<String>>> _seasonalColorPalettes = {
    'spring': {
      'warm': ['coral', 'peach', 'yellow', 'light green', 'turquoise'],
      'cool': ['pink', 'lavender', 'mint', 'sky blue', 'lemon'],
      'neutral': ['cream', 'camel', 'soft gray', 'warm white']
    },
    'summer': {
      'warm': ['bright coral', 'orange', 'hot pink', 'lime'],
      'cool': ['navy', 'royal blue', 'emerald', 'fuchsia'],
      'neutral': ['white', 'light gray', 'silver']
    },
    'fall': {
      'warm': ['rust', 'burgundy', 'olive', 'mustard', 'brown'],
      'cool': ['plum', 'teal', 'forest green', 'wine'],
      'neutral': ['charcoal', 'taupe', 'cream']
    },
    'winter': {
      'warm': ['deep red', 'chocolate', 'camel', 'gold'],
      'cool': ['black', 'navy', 'emerald', 'royal purple'],
      'neutral': ['gray', 'white', 'silver']
    }
  };

  // Body type enhancement algorithms
  static const Map<String, Map<String, dynamic>> _bodyTypeEnhancements = {
    'pear': {
      'emphasize': ['shoulders', 'upper_body', 'neckline'],
      'balance': ['hip_width', 'lower_body'],
      'colors': {'top': ['bright', 'light'], 'bottom': ['dark', 'neutral']},
      'patterns': {'top': ['horizontal', 'bold'], 'bottom': ['solid', 'subtle']},
      'fits': {'top': ['fitted', 'structured'], 'bottom': ['straight', 'bootcut']},
      'necklines': ['boat', 'off_shoulder', 'scoop', 'v_neck'],
      'avoid': ['skinny_jeans', 'tight_bottoms', 'hip_emphasis']
    },
    'apple': {
      'emphasize': ['legs', 'arms', 'neckline'],
      'minimize': ['midsection', 'waist'],
      'colors': {'top': ['dark', 'solid'], 'bottom': ['bright', 'fitted']},
      'patterns': {'top': ['vertical', 'subtle'], 'bottom': ['any']},
      'fits': {'top': ['empire', 'a_line', 'loose'], 'bottom': ['fitted', 'skinny']},
      'necklines': ['v_neck', 'scoop', 'wrap'],
      'avoid': ['tight_tops', 'horizontal_stripes', 'belt_emphasis']
    },
    'hourglass': {
      'emphasize': ['waist', 'curves', 'silhouette'],
      'maintain': ['proportions', 'balance'],
      'colors': {'any': ['fitted_colors']},
      'patterns': {'any': ['fitted_patterns']},
      'fits': {'any': ['fitted', 'tailored', 'wrap']},
      'necklines': ['any_fitted'],
      'avoid': ['baggy', 'shapeless', 'oversized']
    },
    'rectangle': {
      'create': ['curves', 'waist_definition', 'visual_interest'],
      'add': ['volume', 'texture', 'layers'],
      'colors': {'any': ['contrasting', 'colorblocking']},
      'patterns': {'any': ['horizontal', 'bold', 'textured']},
      'fits': {'top': ['peplum', 'ruffled'], 'bottom': ['wide_leg', 'flared']},
      'necklines': ['sweetheart', 'halter', 'cowl'],
      'avoid': ['straight_lines', 'boxy_cuts', 'minimal_styling']
    },
    'inverted_triangle': {
      'balance': ['broad_shoulders', 'narrow_hips'],
      'emphasize': ['lower_body', 'hips'],
      'colors': {'top': ['dark', 'solid'], 'bottom': ['bright', 'patterned']},
      'patterns': {'top': ['minimal'], 'bottom': ['bold', 'horizontal']},
      'fits': {'top': ['fitted', 'simple'], 'bottom': ['wide', 'flared', 'bootcut']},
      'necklines': ['v_neck', 'scoop', 'round'],
      'avoid': ['shoulder_pads', 'horizontal_top_stripes', 'boat_necks']
    }
  };

  // Occasion-specific styling rules
  static const Map<String, Map<String, dynamic>> _occasionStyling = {
    'work': {
      'formality': 0.8,
      'colors': ['navy', 'black', 'gray', 'white', 'burgundy'],
      'patterns': ['solid', 'subtle_stripes', 'small_prints'],
      'fits': ['tailored', 'professional', 'conservative'],
      'avoid': ['revealing', 'casual', 'bright_neon']
    },
    'formal': {
      'formality': 0.9,
      'colors': ['black', 'navy', 'burgundy', 'emerald', 'gold'],
      'patterns': ['solid', 'elegant_prints'],
      'fits': ['fitted', 'elegant', 'sophisticated'],
      'fabrics': ['silk', 'satin', 'chiffon', 'velvet']
    },
    'casual': {
      'formality': 0.3,
      'colors': ['any'],
      'patterns': ['any'],
      'fits': ['comfortable', 'relaxed'],
      'fabrics': ['cotton', 'denim', 'jersey']
    },
    'party': {
      'formality': 0.7,
      'colors': ['bold', 'metallic', 'bright'],
      'patterns': ['sequins', 'bold_prints', 'metallic'],
      'fits': ['fitted', 'statement'],
      'fabrics': ['sequin', 'metallic', 'satin']
    },
    'date': {
      'formality': 0.6,
      'colors': ['romantic', 'flattering'],
      'patterns': ['feminine', 'elegant'],
      'fits': ['flattering', 'romantic'],
      'style': ['romantic', 'chic', 'elegant']
    }
  };

  // Weather adaptation rules
  static const Map<String, Map<String, dynamic>> _weatherAdaptation = {
    'hot': {
      'fabrics': ['cotton', 'linen', 'bamboo', 'silk'],
      'colors': ['light', 'white', 'pastels'],
      'fits': ['loose', 'breathable', 'sleeveless'],
      'layers': 1,
      'coverage': 'minimal'
    },
    'warm': {
      'fabrics': ['cotton', 'jersey', 'light_wool'],
      'colors': ['light_to_medium'],
      'fits': ['comfortable', 'light_layers'],
      'layers': 2,
      'coverage': 'moderate'
    },
    'mild': {
      'fabrics': ['cotton', 'wool_blend', 'denim'],
      'colors': ['any'],
      'fits': ['layered', 'transitional'],
      'layers': 3,
      'coverage': 'moderate'
    },
    'cool': {
      'fabrics': ['wool', 'cashmere', 'fleece'],
      'colors': ['medium_to_dark'],
      'fits': ['layered', 'cozy'],
      'layers': 3,
      'coverage': 'full'
    },
    'cold': {
      'fabrics': ['wool', 'down', 'thermal'],
      'colors': ['dark', 'rich'],
      'fits': ['insulated', 'warm'],
      'layers': 4,
      'coverage': 'maximum'
    }
  };

  // AI Learning weights
  static Map<String, double> _userPreferenceWeights = {
    'color_preference': 0.3,
    'style_consistency': 0.25,
    'body_type_flattery': 0.2,
    'occasion_appropriateness': 0.15,
    'weather_suitability': 0.1
  };

  /// Generate enhanced outfit recommendations using advanced AI algorithms
  static List<Outfit> generateEnhancedOutfits({
    required List<WardrobeItem> wardrobeItems,
    required UserProfile userProfile,
    required String occasion,
    String? weather,
    int maxSuggestions = 6,
  }) {
    List<Outfit> suggestions = [];
    
    // Filter and score items
    List<WardrobeItem> scoredItems = _scoreAndFilterItems(
      wardrobeItems, userProfile, occasion, weather
    );
    
    // Group items by type
    Map<ClothingType, List<WardrobeItem>> itemsByType = _groupItemsByType(scoredItems);
    
    // Generate outfit combinations using multiple algorithms
    suggestions.addAll(_generateDressOutfits(itemsByType, userProfile, occasion, weather));
    suggestions.addAll(_generateSeparateOutfits(itemsByType, userProfile, occasion, weather));
    suggestions.addAll(_generateLayeredOutfits(itemsByType, userProfile, occasion, weather));
    
    // Score and rank outfits
    List<ScoredOutfit> scoredOutfits = suggestions.map((outfit) => 
      ScoredOutfit(outfit, _calculateOutfitScore(outfit, scoredItems, userProfile, occasion, weather))
    ).toList();
    
    // Sort by score and return top suggestions
    scoredOutfits.sort((a, b) => b.score.compareTo(a.score));
    
    return scoredOutfits
        .take(maxSuggestions)
        .map((scored) => scored.outfit)
        .toList();
  }

  /// Score individual items based on multiple factors
  static List<WardrobeItem> _scoreAndFilterItems(
    List<WardrobeItem> items,
    UserProfile profile,
    String occasion,
    String? weather,
  ) {
    return items.where((item) {
      double score = 0.0;
      
      // Color preference score
      if (profile.favoriteColors.contains(item.color.toLowerCase())) {
        score += 0.3;
      }
      
      // Seasonal appropriateness
      if (weather != null) {
        Season targetSeason = _getSeasonFromWeather(weather);
        if (item.season == targetSeason || item.season == Season.allSeason) {
          score += 0.2;
        }
      }
      
      // Body type compatibility
      score += _getBodyTypeCompatibilityScore(item, profile.bodyType);
      
      // Occasion appropriateness
      score += _getOccasionScore(item, occasion);
      
      return score > 0.4; // Filter threshold
    }).toList();
  }

  /// Calculate body type compatibility score
  static double _getBodyTypeCompatibilityScore(WardrobeItem item, String bodyType) {
    Map<String, dynamic>? rules = _bodyTypeEnhancements[bodyType.toLowerCase()];
    if (rules == null) return 0.5;
    
    double score = 0.5;
    
    // Check fit recommendations
    Map<String, List<String>>? fits = rules['fits'];
    if (fits != null && item.fit != null) {
      String itemTypeKey = _getItemTypeKey(item.type);
      List<String>? recommendedFits = fits[itemTypeKey] ?? fits['any'];
      if (recommendedFits?.any((fit) => item.fit!.toLowerCase().contains(fit)) == true) {
        score += 0.3;
      }
    }
    
    return math.min(score, 1.0);
  }

  /// Calculate occasion appropriateness score
  static double _getOccasionScore(WardrobeItem item, String occasion) {
    Map<String, dynamic>? occasionRules = _occasionStyling[occasion.toLowerCase()];
    if (occasionRules == null) return 0.5;
    
    double score = 0.5;
    
    // Check color appropriateness
    List<String>? appropriateColors = occasionRules['colors'];
    if (appropriateColors?.contains(item.color.toLowerCase()) == true || 
        appropriateColors?.contains('any') == true) {
      score += 0.2;
    }
    
    // Check pattern appropriateness
    List<String>? appropriatePatterns = occasionRules['patterns'];
    if (item.pattern != null && appropriatePatterns != null) {
      if (appropriatePatterns.contains(item.pattern!.toLowerCase()) || 
          appropriatePatterns.contains('any')) {
        score += 0.2;
      }
    }
    
    return math.min(score, 1.0);
  }

  /// Generate dress-based outfits
  static List<Outfit> _generateDressOutfits(
    Map<ClothingType, List<WardrobeItem>> itemsByType,
    UserProfile profile,
    String occasion,
    String? weather,
  ) {
    List<Outfit> outfits = [];
    List<WardrobeItem> dresses = itemsByType[ClothingType.dress] ?? [];
    
    for (var dress in dresses.take(3)) {
      List<String> outfitItems = [dress.id];
      
      // Add complementary items
      _addComplementaryShoes(outfitItems, dress, itemsByType[ClothingType.shoes] ?? [], profile);
      _addComplementaryAccessories(outfitItems, dress, itemsByType[ClothingType.accessory] ?? [], profile);
      
      // Add outerwear if weather requires
      if (weather != null && _requiresOuterwear(weather)) {
        _addComplementaryOuterwear(outfitItems, dress, itemsByType[ClothingType.outerwear] ?? [], profile);
      }
      
      outfits.add(Outfit(
        id: 'enhanced_dress_${outfits.length + 1}',
        name: '${dress.name} Ensemble',
        itemIds: outfitItems,
        occasion: occasion,
        weather: weather,
        createdAt: DateTime.now(),
      ));
    }
    
    return outfits;
  }

  /// Generate separate piece outfits
  static List<Outfit> _generateSeparateOutfits(
    Map<ClothingType, List<WardrobeItem>> itemsByType,
    UserProfile profile,
    String occasion,
    String? weather,
  ) {
    List<Outfit> outfits = [];
    List<WardrobeItem> tops = itemsByType[ClothingType.top] ?? [];
    List<WardrobeItem> bottoms = itemsByType[ClothingType.bottom] ?? [];
    
    for (var top in tops.take(3)) {
      for (var bottom in bottoms.take(2)) {
        if (_areItemsCompatible(top, bottom, profile)) {
          List<String> outfitItems = [top.id, bottom.id];
          
          // Add complementary items
          _addComplementaryShoes(outfitItems, top, itemsByType[ClothingType.shoes] ?? [], profile);
          _addComplementaryAccessories(outfitItems, top, itemsByType[ClothingType.accessory] ?? [], profile);
          
          if (weather != null && _requiresOuterwear(weather)) {
            _addComplementaryOuterwear(outfitItems, top, itemsByType[ClothingType.outerwear] ?? [], profile);
          }
          
          outfits.add(Outfit(
            id: 'enhanced_separate_${outfits.length + 1}',
            name: '${top.name} & ${bottom.name}',
            itemIds: outfitItems,
            occasion: occasion,
            weather: weather,
            createdAt: DateTime.now(),
          ));
          
          if (outfits.length >= 4) break;
        }
      }
      if (outfits.length >= 4) break;
    }
    
    return outfits;
  }

  /// Generate layered outfits for complex weather
  static List<Outfit> _generateLayeredOutfits(
    Map<ClothingType, List<WardrobeItem>> itemsByType,
    UserProfile profile,
    String occasion,
    String? weather,
  ) {
    if (weather == null || !_requiresLayering(weather)) return [];
    
    List<Outfit> outfits = [];
    // Implementation for layered outfits
    return outfits;
  }

  /// Calculate comprehensive outfit score
  static double _calculateOutfitScore(
    Outfit outfit,
    List<WardrobeItem> allItems,
    UserProfile profile,
    String occasion,
    String? weather,
  ) {
    double totalScore = 0.0;
    List<WardrobeItem> outfitItems = allItems.where((item) => 
      outfit.itemIds.contains(item.id)
    ).toList();
    
    // Color harmony score
    totalScore += _calculateColorHarmonyScore(outfitItems) * _userPreferenceWeights['color_preference']!;
    
    // Style consistency score
    totalScore += _calculateStyleConsistencyScore(outfitItems) * _userPreferenceWeights['style_consistency']!;
    
    // Body type flattery score
    totalScore += _calculateBodyTypeFlattery(outfitItems, profile.bodyType) * _userPreferenceWeights['body_type_flattery']!;
    
    // Occasion appropriateness score
    totalScore += _calculateOccasionAppropriatenessScore(outfitItems, occasion) * _userPreferenceWeights['occasion_appropriateness']!;
    
    // Weather suitability score
    if (weather != null) {
      totalScore += _calculateWeatherSuitabilityScore(outfitItems, weather) * _userPreferenceWeights['weather_suitability']!;
    }
    
    return totalScore;
  }

  /// Advanced color harmony calculation
  static double _calculateColorHarmonyScore(List<WardrobeItem> items) {
    if (items.length < 2) return 1.0;
    
    double harmonyScore = 0.0;
    int comparisons = 0;
    
    for (int i = 0; i < items.length; i++) {
      for (int j = i + 1; j < items.length; j++) {
        harmonyScore += _getColorCompatibilityScore(items[i].color, items[j].color);
        comparisons++;
      }
    }
    
    return comparisons > 0 ? harmonyScore / comparisons : 1.0;
  }

  /// Get color compatibility score using advanced color theory
  static double _getColorCompatibilityScore(String color1, String color2) {
    // Implement advanced color theory calculations
    // This is a simplified version
    if (color1.toLowerCase() == color2.toLowerCase()) return 0.9;
    
    // Check complementary colors, analogous colors, etc.
    Map<String, List<String>> colorHarmony = {
      'red': ['white', 'black', 'navy', 'beige', 'gray', 'gold'],
      'blue': ['white', 'beige', 'gray', 'navy', 'brown', 'silver'],
      'green': ['white', 'beige', 'brown', 'navy', 'black', 'gold'],
      // ... extended color harmony rules
    };
    
    List<String>? compatibleColors = colorHarmony[color1.toLowerCase()];
    if (compatibleColors?.contains(color2.toLowerCase()) == true) {
      return 0.8;
    }
    
    return 0.4;
  }

  /// Calculate style consistency score
  static double _calculateStyleConsistencyScore(List<WardrobeItem> items) {
    // Analyze style consistency across items
    Map<String, int> styleCount = {};
    
    for (var item in items) {
      for (var tag in item.tags) {
        styleCount[tag] = (styleCount[tag] ?? 0) + 1;
      }
    }
    
    if (styleCount.isEmpty) return 0.5;
    
    int maxCount = styleCount.values.reduce(math.max);
    return maxCount / items.length;
  }

  /// Calculate body type flattery score
  static double _calculateBodyTypeFlattery(List<WardrobeItem> items, String bodyType) {
    double totalScore = 0.0;
    
    for (var item in items) {
      totalScore += _getBodyTypeCompatibilityScore(item, bodyType);
    }
    
    return items.isNotEmpty ? totalScore / items.length : 0.5;
  }

  /// Calculate occasion appropriateness score
  static double _calculateOccasionAppropriatenessScore(List<WardrobeItem> items, String occasion) {
    double totalScore = 0.0;
    
    for (var item in items) {
      totalScore += _getOccasionScore(item, occasion);
    }
    
    return items.isNotEmpty ? totalScore / items.length : 0.5;
  }

  /// Calculate weather suitability score
  static double _calculateWeatherSuitabilityScore(List<WardrobeItem> items, String weather) {
    Map<String, dynamic>? weatherRules = _weatherAdaptation[weather.toLowerCase()];
    if (weatherRules == null) return 0.5;
    
    double score = 0.0;
    
    for (var item in items) {
      // Check fabric appropriateness
      List<String>? appropriateFabrics = weatherRules['fabrics'];
      if (item.fabric != null && appropriateFabrics?.contains(item.fabric!.toLowerCase()) == true) {
        score += 0.3;
      }
      
      // Check color appropriateness for weather
      List<String>? appropriateColors = weatherRules['colors'];
      if (appropriateColors?.any((colorType) => _isColorType(item.color, colorType)) == true) {
        score += 0.2;
      }
    }
    
    return items.isNotEmpty ? score / items.length : 0.5;
  }

  // Helper methods
  static Map<ClothingType, List<WardrobeItem>> _groupItemsByType(List<WardrobeItem> items) {
    Map<ClothingType, List<WardrobeItem>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.type, () => []).add(item);
    }
    return grouped;
  }

  static bool _areItemsCompatible(WardrobeItem item1, WardrobeItem item2, UserProfile profile) {
    // Check color compatibility
    double colorScore = _getColorCompatibilityScore(item1.color, item2.color);
    if (colorScore < 0.6) return false;
    
    // Check style compatibility
    Set<String> commonTags = item1.tags.toSet().intersection(item2.tags.toSet());
    if (commonTags.isEmpty && item1.tags.isNotEmpty && item2.tags.isNotEmpty) {
      return false;
    }
    
    return true;
  }

  static void _addComplementaryShoes(List<String> outfitItems, WardrobeItem mainItem, List<WardrobeItem> shoes, UserProfile profile) {
    for (var shoe in shoes) {
      if (_getColorCompatibilityScore(mainItem.color, shoe.color) >= 0.6) {
        outfitItems.add(shoe.id);
        break;
      }
    }
  }

  static void _addComplementaryAccessories(List<String> outfitItems, WardrobeItem mainItem, List<WardrobeItem> accessories, UserProfile profile) {
    for (var accessory in accessories) {
      if (_getColorCompatibilityScore(mainItem.color, accessory.color) >= 0.6) {
        outfitItems.add(accessory.id);
        break;
      }
    }
  }

  static void _addComplementaryOuterwear(List<String> outfitItems, WardrobeItem mainItem, List<WardrobeItem> outerwear, UserProfile profile) {
    for (var outer in outerwear) {
      if (_getColorCompatibilityScore(mainItem.color, outer.color) >= 0.6) {
        outfitItems.add(outer.id);
        break;
      }
    }
  }

  static bool _requiresOuterwear(String weather) {
    return ['cool', 'cold', 'rainy', 'snowy'].contains(weather.toLowerCase());
  }

  static bool _requiresLayering(String weather) {
    return ['mild', 'cool', 'cold'].contains(weather.toLowerCase());
  }

  static Season _getSeasonFromWeather(String weather) {
    switch (weather.toLowerCase()) {
      case 'hot':
      case 'sunny':
        return Season.summer;
      case 'cold':
      case 'snowy':
        return Season.winter;
      case 'mild':
      case 'rainy':
        return Season.spring;
      case 'cool':
        return Season.fall;
      default:
        return Season.allSeason;
    }
  }

  static String _getItemTypeKey(ClothingType type) {
    switch (type) {
      case ClothingType.top:
        return 'top';
      case ClothingType.bottom:
        return 'bottom';
      case ClothingType.dress:
        return 'dress';
      default:
        return 'any';
    }
  }

  static bool _isColorType(String color, String colorType) {
    // Implement color type checking (light, dark, bright, etc.)
    switch (colorType) {
      case 'light':
        return ['white', 'cream', 'beige', 'light gray', 'pastels'].any((c) => color.toLowerCase().contains(c));
      case 'dark':
        return ['black', 'navy', 'dark gray', 'brown'].any((c) => color.toLowerCase().contains(c));
      case 'bright':
        return ['red', 'blue', 'green', 'yellow', 'orange', 'pink'].contains(color.toLowerCase());
      default:
        return true;
    }
  }

  /// Generate personalized style recommendations
  static List<String> getPersonalizedStyleTips(UserProfile profile, List<WardrobeItem> wardrobe) {
    List<String> tips = [];
    
    // Analyze wardrobe gaps
    Map<ClothingType, int> typeCounts = {};
    Map<String, int> colorCounts = {};
    
    for (var item in wardrobe) {
      typeCounts[item.type] = (typeCounts[item.type] ?? 0) + 1;
      colorCounts[item.color] = (colorCounts[item.color] ?? 0) + 1;
    }
    
    // Body type specific tips
    Map<String, dynamic>? bodyRules = _bodyTypeEnhancements[profile.bodyType.toLowerCase()];
    if (bodyRules != null) {
      if (bodyRules['emphasize'] != null) {
        tips.add('For your ${profile.bodyType} shape, emphasize your ${bodyRules['emphasize'].join(' and ')}');
      }
    }
    
    // Color analysis tips
    String season = _getCurrentSeason();
    Map<String, List<String>>? seasonalColors = _seasonalColorPalettes[season];
    if (seasonalColors != null) {
      List<String>? recommendedColors = seasonalColors[profile.skinUndertone.toLowerCase()];
      if (recommendedColors != null) {
        tips.add('This $season, try incorporating ${recommendedColors.take(3).join(', ')} to complement your ${profile.skinUndertone} undertone');
      }
    }
    
    // Wardrobe gap analysis
    if ((typeCounts[ClothingType.dress] ?? 0) < 2) {
      tips.add('Consider adding a versatile dress to your wardrobe for easy styling');
    }
    
    if ((typeCounts[ClothingType.accessory] ?? 0) < 3) {
      tips.add('Accessories can transform any outfit - consider adding statement pieces');
    }
    
    return tips;
  }

  static String _getCurrentSeason() {
    int month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'fall';
    return 'winter';
  }
}

/// Helper class for scored outfits
class ScoredOutfit {
  final Outfit outfit;
  final double score;
  
  ScoredOutfit(this.outfit, this.score);
}