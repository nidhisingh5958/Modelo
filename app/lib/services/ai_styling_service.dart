import '../models/wardrobe_item.dart';
import '../models/user_profile.dart';
import '../models/outfit.dart';

class AIStylingService {
  // Color harmony rules
  static const Map<String, List<String>> _colorHarmony = {
    'red': ['white', 'black', 'navy', 'beige', 'gray'],
    'blue': ['white', 'beige', 'gray', 'navy', 'brown'],
    'green': ['white', 'beige', 'brown', 'navy', 'black'],
    'yellow': ['white', 'navy', 'gray', 'brown', 'black'],
    'black': ['white', 'red', 'blue', 'yellow', 'pink'],
    'white': ['black', 'navy', 'red', 'blue', 'green'],
    'navy': ['white', 'beige', 'red', 'yellow', 'pink'],
    'gray': ['white', 'black', 'red', 'blue', 'yellow'],
    'brown': ['white', 'beige', 'blue', 'green', 'yellow'],
    'beige': ['navy', 'brown', 'blue', 'red', 'green'],
  };

  // Body type recommendations
  static const Map<String, Map<String, List<String>>> _bodyTypeRules = {
    'pear': {
      'tops': ['fitted', 'structured', 'bright colors'],
      'bottoms': ['dark colors', 'straight leg', 'bootcut'],
      'avoid': ['tight bottoms', 'horizontal stripes on bottom']
    },
    'apple': {
      'tops': ['v-neck', 'scoop neck', 'empire waist'],
      'bottoms': ['fitted', 'straight leg', 'skinny'],
      'avoid': ['tight tops', 'high waisted bottoms']
    },
    'hourglass': {
      'tops': ['fitted', 'wrap style', 'belted'],
      'bottoms': ['fitted', 'high waisted', 'straight leg'],
      'avoid': ['baggy clothes', 'shapeless silhouettes']
    },
    'rectangle': {
      'tops': ['peplum', 'ruffles', 'layered'],
      'bottoms': ['wide leg', 'flared', 'textured'],
      'avoid': ['straight silhouettes', 'boxy cuts']
    },
  };

  static List<Outfit> generateOutfitSuggestions({
    required List<WardrobeItem> wardrobeItems,
    required UserProfile userProfile,
    required String occasion,
    String? weather,
    int maxSuggestions = 5,
  }) {
    List<Outfit> suggestions = [];
    
    // Filter items by season if weather is specified
    List<WardrobeItem> availableItems = wardrobeItems;
    if (weather != null) {
      Season targetSeason = _getSeasonFromWeather(weather);
      availableItems = wardrobeItems.where((item) => 
        item.season == targetSeason || item.season == Season.allSeason
      ).toList();
    }

    // Group items by type
    Map<ClothingType, List<WardrobeItem>> itemsByType = {};
    for (var item in availableItems) {
      itemsByType.putIfAbsent(item.type, () => []).add(item);
    }

    // Generate outfit combinations
    List<WardrobeItem> tops = itemsByType[ClothingType.top] ?? [];
    List<WardrobeItem> bottoms = itemsByType[ClothingType.bottom] ?? [];
    List<WardrobeItem> dresses = itemsByType[ClothingType.dress] ?? [];
    List<WardrobeItem> shoes = itemsByType[ClothingType.shoes] ?? [];
    List<WardrobeItem> accessories = itemsByType[ClothingType.accessory] ?? [];

    int suggestionCount = 0;

    // Generate dress-based outfits
    for (var dress in dresses) {
      if (suggestionCount >= maxSuggestions) break;
      
      List<String> outfitItems = [dress.id];
      
      // Add matching shoes
      var matchingShoes = _findMatchingShoes(dress, shoes, userProfile);
      if (matchingShoes != null) outfitItems.add(matchingShoes.id);
      
      // Add accessories
      var accessory = _findMatchingAccessory(dress, accessories, userProfile);
      if (accessory != null) outfitItems.add(accessory.id);

      if (_isValidOutfit(outfitItems, availableItems, userProfile, occasion)) {
        suggestions.add(Outfit(
          id: 'suggestion_${suggestionCount + 1}',
          name: '${dress.name} Outfit',
          itemIds: outfitItems,
          occasion: occasion,
          weather: weather,
          createdAt: DateTime.now(),
        ));
        suggestionCount++;
      }
    }

    // Generate top + bottom combinations
    for (var top in tops) {
      if (suggestionCount >= maxSuggestions) break;
      
      for (var bottom in bottoms) {
        if (suggestionCount >= maxSuggestions) break;
        
        if (_areColorsCompatible(top.color, bottom.color) &&
            _isBodyTypeSuitable(top, bottom, userProfile.bodyType)) {
          
          List<String> outfitItems = [top.id, bottom.id];
          
          // Add matching shoes
          var matchingShoes = _findMatchingShoes(top, shoes, userProfile);
          if (matchingShoes != null) outfitItems.add(matchingShoes.id);
          
          // Add accessories
          var accessory = _findMatchingAccessory(top, accessories, userProfile);
          if (accessory != null) outfitItems.add(accessory.id);

          if (_isValidOutfit(outfitItems, availableItems, userProfile, occasion)) {
            suggestions.add(Outfit(
              id: 'suggestion_${suggestionCount + 1}',
              name: '${top.name} & ${bottom.name}',
              itemIds: outfitItems,
              occasion: occasion,
              weather: weather,
              createdAt: DateTime.now(),
            ));
            suggestionCount++;
          }
        }
      }
    }

    return suggestions;
  }

  static bool _areColorsCompatible(String color1, String color2) {
    if (color1.toLowerCase() == color2.toLowerCase()) return true;
    
    List<String>? compatibleColors = _colorHarmony[color1.toLowerCase()];
    return compatibleColors?.contains(color2.toLowerCase()) ?? false;
  }

  static bool _isBodyTypeSuitable(WardrobeItem top, WardrobeItem bottom, String bodyType) {
    Map<String, List<String>>? rules = _bodyTypeRules[bodyType.toLowerCase()];
    if (rules == null) return true;

    // Check if items match body type recommendations
    List<String> topRules = rules['tops'] ?? [];
    List<String> bottomRules = rules['bottoms'] ?? [];
    List<String> avoidRules = rules['avoid'] ?? [];

    // Simple rule checking with flexible matching
    bool topSuitable = topRules.isEmpty || 
        topRules.any((rule) => _matchesFitRule(top.fit, rule));
    bool bottomSuitable = bottomRules.isEmpty || 
        bottomRules.any((rule) => _matchesFitRule(bottom.fit, rule));
    
    return topSuitable && bottomSuitable;
  }

  static WardrobeItem? _findMatchingShoes(WardrobeItem mainItem, List<WardrobeItem> shoes, UserProfile profile) {
    for (var shoe in shoes) {
      if (_areColorsCompatible(mainItem.color, shoe.color)) {
        return shoe;
      }
    }
    return shoes.isNotEmpty ? shoes.first : null;
  }

  static WardrobeItem? _findMatchingAccessory(WardrobeItem mainItem, List<WardrobeItem> accessories, UserProfile profile) {
    for (var accessory in accessories) {
      if (_areColorsCompatible(mainItem.color, accessory.color)) {
        return accessory;
      }
    }
    return accessories.isNotEmpty ? accessories.first : null;
  }

  static bool _isValidOutfit(List<String> itemIds, List<WardrobeItem> allItems, UserProfile profile, String occasion) {
    // Basic validation - ensure we have at least one main clothing item
    return itemIds.isNotEmpty;
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

  static bool _matchesFitRule(String? itemFit, String rule) {
    if (itemFit == null) return false;
    
    String fit = itemFit.toLowerCase();
    String ruleKey = rule.toLowerCase();
    
    // Flexible matching for common fit descriptions
    switch (ruleKey) {
      case 'fitted':
        return fit.contains('fitted') || fit.contains('tight') || fit.contains('slim');
      case 'straight leg':
        return fit.contains('straight') || fit.contains('regular');
      case 'high waisted':
        return fit.contains('high') || fit.contains('waisted');
      case 'wrap style':
        return fit.contains('wrap');
      case 'belted':
        return fit.contains('belted');
      default:
        return fit.contains(ruleKey);
    }
  }

  static List<String> getStyleTips(UserProfile profile) {
    List<String> tips = [];
    
    // Body type specific tips
    switch (profile.bodyType.toLowerCase()) {
      case 'pear':
        tips.add('Highlight your upper body with bright colors and patterns');
        tips.add('Choose darker colors for bottoms to balance your silhouette');
        break;
      case 'apple':
        tips.add('Draw attention away from your midsection with V-necks');
        tips.add('Choose fitted bottoms to balance your proportions');
        break;
      case 'hourglass':
        tips.add('Emphasize your waist with belted styles');
        tips.add('Choose fitted clothing that follows your natural curves');
        break;
      case 'rectangle':
        tips.add('Create curves with peplum tops and textured fabrics');
        tips.add('Add visual interest with patterns and layers');
        break;
    }

    // Color tips based on skin undertone
    switch (profile.skinUndertone.toLowerCase()) {
      case 'warm':
        tips.add('Warm colors like coral, peach, and gold complement your skin');
        break;
      case 'cool':
        tips.add('Cool colors like blue, purple, and silver enhance your complexion');
        break;
      case 'neutral':
        tips.add('You can wear both warm and cool colors - lucky you!');
        break;
    }

    return tips;
  }
}