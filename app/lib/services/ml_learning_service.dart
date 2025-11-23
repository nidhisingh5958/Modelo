import 'dart:convert';
import 'dart:math';
import '../models/wardrobe_item.dart';
import '../models/user_profile.dart';
import '../models/outfit.dart';

class MLLearningService {
  // User interaction tracking
  static Map<String, Map<String, double>> _userPreferences = {};
  static Map<String, List<OutfitFeedback>> _outfitFeedback = {};
  static Map<String, Map<String, int>> _colorPreferences = {};
  static Map<String, Map<String, int>> _stylePreferences = {};

  /// Track user outfit rating and feedback
  static void recordOutfitFeedback({
    required String userId,
    required String outfitId,
    required double rating,
    required List<String> itemIds,
    String? feedback,
    bool wasWorn = false,
  }) {
    _outfitFeedback.putIfAbsent(userId, () => []).add(
      OutfitFeedback(
        outfitId: outfitId,
        rating: rating,
        itemIds: itemIds,
        feedback: feedback,
        wasWorn: wasWorn,
        timestamp: DateTime.now(),
      )
    );
    
    // Update learning weights based on feedback
    _updateLearningWeights(userId, rating, itemIds);
  }

  /// Track color preferences based on user interactions
  static void recordColorInteraction({
    required String userId,
    required String color,
    required InteractionType type,
  }) {
    _colorPreferences.putIfAbsent(userId, () => {});
    
    int weight = _getInteractionWeight(type);
    _colorPreferences[userId]![color] = 
        (_colorPreferences[userId]![color] ?? 0) + weight;
  }

  /// Track style preferences based on user interactions
  static void recordStyleInteraction({
    required String userId,
    required String style,
    required InteractionType type,
  }) {
    _stylePreferences.putIfAbsent(userId, () => {});
    
    int weight = _getInteractionWeight(type);
    _stylePreferences[userId]![style] = 
        (_stylePreferences[userId]![style] ?? 0) + weight;
  }

  /// Get personalized recommendations based on learning
  static Map<String, double> getPersonalizedWeights(String userId) {
    Map<String, double> weights = {
      'color_preference': 0.3,
      'style_consistency': 0.25,
      'body_type_flattery': 0.2,
      'occasion_appropriateness': 0.15,
      'weather_suitability': 0.1,
    };

    // Adjust weights based on user feedback patterns
    List<OutfitFeedback>? userFeedback = _outfitFeedback[userId];
    if (userFeedback != null && userFeedback.length >= 5) {
      // Analyze feedback patterns to adjust weights
      double avgColorSatisfaction = _analyzeColorSatisfaction(userId);
      double avgStyleSatisfaction = _analyzeStyleSatisfaction(userId);
      
      // Adjust weights based on satisfaction levels
      if (avgColorSatisfaction < 0.6) {
        weights['color_preference'] = weights['color_preference']! * 1.2;
      }
      
      if (avgStyleSatisfaction < 0.6) {
        weights['style_consistency'] = weights['style_consistency']! * 1.2;
      }
      
      // Normalize weights
      double total = weights.values.reduce((a, b) => a + b);
      weights.updateAll((key, value) => value / total);
    }

    return weights;
  }

  /// Predict outfit success probability
  static double predictOutfitSuccess({
    required String userId,
    required List<WardrobeItem> outfitItems,
    required String occasion,
    String? weather,
  }) {
    double baseScore = 0.5;
    
    // Color preference analysis
    Map<String, int>? userColorPrefs = _colorPreferences[userId];
    if (userColorPrefs != null) {
      double colorScore = 0.0;
      for (var item in outfitItems) {
        int colorPref = userColorPrefs[item.color.toLowerCase()] ?? 0;
        colorScore += _normalizePreferenceScore(colorPref);
      }
      baseScore += (colorScore / outfitItems.length) * 0.3;
    }
    
    // Style preference analysis
    Map<String, int>? userStylePrefs = _stylePreferences[userId];
    if (userStylePrefs != null) {
      double styleScore = 0.0;
      int styleCount = 0;
      
      for (var item in outfitItems) {
        for (var tag in item.tags) {
          int stylePref = userStylePrefs[tag.toLowerCase()] ?? 0;
          styleScore += _normalizePreferenceScore(stylePref);
          styleCount++;
        }
      }
      
      if (styleCount > 0) {
        baseScore += (styleScore / styleCount) * 0.25;
      }
    }
    
    // Historical outfit performance
    List<OutfitFeedback>? feedback = _outfitFeedback[userId];
    if (feedback != null && feedback.isNotEmpty) {
      double avgRating = feedback.map((f) => f.rating).reduce((a, b) => a + b) / feedback.length;
      baseScore += (avgRating - 0.5) * 0.2;
    }
    
    return math.min(math.max(baseScore, 0.0), 1.0);
  }

  /// Generate learning-based outfit recommendations
  static List<Map<String, dynamic>> generateLearningBasedRecommendations({
    required String userId,
    required List<WardrobeItem> wardrobeItems,
    required UserProfile userProfile,
    required String occasion,
    String? weather,
    int maxSuggestions = 5,
  }) {
    List<Map<String, dynamic>> recommendations = [];
    
    // Get user's learned preferences
    Map<String, int>? colorPrefs = _colorPreferences[userId];
    Map<String, int>? stylePrefs = _stylePreferences[userId];
    
    // Score items based on learned preferences
    List<WardrobeItem> scoredItems = wardrobeItems.map((item) {
      double score = 0.5; // Base score
      
      // Color preference score
      if (colorPrefs != null) {
        int colorPref = colorPrefs[item.color.toLowerCase()] ?? 0;
        score += _normalizePreferenceScore(colorPref) * 0.4;
      }
      
      // Style preference score
      if (stylePrefs != null) {
        double styleScore = 0.0;
        for (var tag in item.tags) {
          int stylePref = stylePrefs[tag.toLowerCase()] ?? 0;
          styleScore += _normalizePreferenceScore(stylePref);
        }
        if (item.tags.isNotEmpty) {
          score += (styleScore / item.tags.length) * 0.3;
        }
      }
      
      // Wear frequency bonus (items worn more often get slight preference)
      score += (item.wearCount / 100.0) * 0.1;
      
      return item;
    }).toList();
    
    // Sort by preference score and generate combinations
    // Implementation would continue with outfit generation logic...
    
    return recommendations;
  }

  /// Analyze user's color satisfaction patterns
  static double _analyzeColorSatisfaction(String userId) {
    List<OutfitFeedback>? feedback = _outfitFeedback[userId];
    if (feedback == null || feedback.isEmpty) return 0.5;
    
    double totalSatisfaction = 0.0;
    int count = 0;
    
    for (var fb in feedback) {
      // Analyze if high-rated outfits correlate with preferred colors
      if (fb.rating >= 4.0) {
        totalSatisfaction += 1.0;
      } else if (fb.rating >= 3.0) {
        totalSatisfaction += 0.6;
      } else {
        totalSatisfaction += 0.2;
      }
      count++;
    }
    
    return count > 0 ? totalSatisfaction / count : 0.5;
  }

  /// Analyze user's style satisfaction patterns
  static double _analyzeStyleSatisfaction(String userId) {
    List<OutfitFeedback>? feedback = _outfitFeedback[userId];
    if (feedback == null || feedback.isEmpty) return 0.5;
    
    double totalSatisfaction = 0.0;
    int count = 0;
    
    for (var fb in feedback) {
      if (fb.rating >= 4.0) {
        totalSatisfaction += 1.0;
      } else if (fb.rating >= 3.0) {
        totalSatisfaction += 0.6;
      } else {
        totalSatisfaction += 0.2;
      }
      count++;
    }
    
    return count > 0 ? totalSatisfaction / count : 0.5;
  }

  /// Update learning weights based on feedback
  static void _updateLearningWeights(String userId, double rating, List<String> itemIds) {
    _userPreferences.putIfAbsent(userId, () => {});
    
    // Positive feedback increases weights, negative decreases
    double adjustment = (rating - 3.0) / 10.0; // Scale to -0.2 to +0.2
    
    // Update general satisfaction weight
    _userPreferences[userId]!['general_satisfaction'] = 
        (_userPreferences[userId]!['general_satisfaction'] ?? 0.5) + adjustment;
  }

  /// Get interaction weight based on type
  static int _getInteractionWeight(InteractionType type) {
    switch (type) {
      case InteractionType.liked:
        return 3;
      case InteractionType.worn:
        return 5;
      case InteractionType.saved:
        return 2;
      case InteractionType.shared:
        return 4;
      case InteractionType.disliked:
        return -2;
      case InteractionType.skipped:
        return -1;
    }
  }

  /// Normalize preference score to 0-1 range
  static double _normalizePreferenceScore(int rawScore) {
    // Convert raw interaction score to normalized preference
    if (rawScore <= 0) return 0.0;
    if (rawScore >= 20) return 1.0;
    return rawScore / 20.0;
  }

  /// Get trending styles based on all users (anonymized)
  static List<String> getTrendingStyles() {
    Map<String, int> globalStyleCounts = {};
    
    for (var userStyles in _stylePreferences.values) {
      for (var entry in userStyles.entries) {
        if (entry.value > 0) { // Only positive preferences
          globalStyleCounts[entry.key] = 
              (globalStyleCounts[entry.key] ?? 0) + entry.value;
        }
      }
    }
    
    // Sort by popularity and return top trends
    var sortedStyles = globalStyleCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedStyles.take(10).map((e) => e.key).toList();
  }

  /// Get seasonal color recommendations based on user data
  static List<String> getSeasonalColorRecommendations(String userId) {
    Map<String, int>? userColorPrefs = _colorPreferences[userId];
    if (userColorPrefs == null) return [];
    
    // Get current season
    String season = _getCurrentSeason();
    
    // Filter user's preferred colors by seasonal appropriateness
    List<String> seasonalColors = _getSeasonalColors(season);
    
    List<String> recommendations = [];
    for (var color in seasonalColors) {
      if (userColorPrefs[color.toLowerCase()] != null && 
          userColorPrefs[color.toLowerCase()]! > 0) {
        recommendations.add(color);
      }
    }
    
    return recommendations.take(5).toList();
  }

  /// Export user learning data for backup/sync
  static Map<String, dynamic> exportUserLearningData(String userId) {
    return {
      'colorPreferences': _colorPreferences[userId] ?? {},
      'stylePreferences': _stylePreferences[userId] ?? {},
      'outfitFeedback': _outfitFeedback[userId]?.map((f) => f.toMap()).toList() ?? [],
      'userPreferences': _userPreferences[userId] ?? {},
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Import user learning data from backup/sync
  static void importUserLearningData(String userId, Map<String, dynamic> data) {
    if (data['colorPreferences'] != null) {
      _colorPreferences[userId] = Map<String, int>.from(data['colorPreferences']);
    }
    
    if (data['stylePreferences'] != null) {
      _stylePreferences[userId] = Map<String, int>.from(data['stylePreferences']);
    }
    
    if (data['outfitFeedback'] != null) {
      _outfitFeedback[userId] = (data['outfitFeedback'] as List)
          .map((f) => OutfitFeedback.fromMap(f))
          .toList();
    }
    
    if (data['userPreferences'] != null) {
      _userPreferences[userId] = Map<String, double>.from(data['userPreferences']);
    }
  }

  // Helper methods
  static String _getCurrentSeason() {
    int month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'fall';
    return 'winter';
  }

  static List<String> _getSeasonalColors(String season) {
    switch (season) {
      case 'spring':
        return ['coral', 'peach', 'yellow', 'light green', 'turquoise', 'pink'];
      case 'summer':
        return ['white', 'light blue', 'coral', 'mint', 'yellow', 'pink'];
      case 'fall':
        return ['rust', 'burgundy', 'olive', 'mustard', 'brown', 'orange'];
      case 'winter':
        return ['black', 'navy', 'burgundy', 'emerald', 'gray', 'white'];
      default:
        return [];
    }
  }
}

/// Enum for different types of user interactions
enum InteractionType {
  liked,
  disliked,
  worn,
  saved,
  shared,
  skipped,
}

/// Class to track outfit feedback
class OutfitFeedback {
  final String outfitId;
  final double rating;
  final List<String> itemIds;
  final String? feedback;
  final bool wasWorn;
  final DateTime timestamp;

  OutfitFeedback({
    required this.outfitId,
    required this.rating,
    required this.itemIds,
    this.feedback,
    required this.wasWorn,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'outfitId': outfitId,
      'rating': rating,
      'itemIds': itemIds,
      'feedback': feedback,
      'wasWorn': wasWorn,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory OutfitFeedback.fromMap(Map<String, dynamic> map) {
    return OutfitFeedback(
      outfitId: map['outfitId'],
      rating: map['rating'].toDouble(),
      itemIds: List<String>.from(map['itemIds']),
      feedback: map['feedback'],
      wasWorn: map['wasWorn'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}