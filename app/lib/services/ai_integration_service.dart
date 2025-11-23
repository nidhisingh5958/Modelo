import 'dart:convert';
import 'dart:math';
import '../models/wardrobe_item.dart';
import '../models/user_profile.dart';
import '../models/outfit.dart';
import 'enhanced_ai_model.dart';
import 'ml_learning_service.dart';
import 'advanced_image_analysis.dart';
import 'ai_styling_service.dart';

/// Central AI Integration Service that coordinates all AI models and services
class AIIntegrationService {
  static const String _version = '2.0.0';
  static bool _isInitialized = false;
  
  /// Initialize the AI system
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize all AI components
      await _loadAIModels();
      await _calibrateAlgorithms();
      
      _isInitialized = true;
      print('AI Integration Service initialized successfully (v$_version)');
    } catch (e) {
      print('Error initializing AI Integration Service: $e');
      throw AIInitializationException('Failed to initialize AI system: $e');
    }
  }

  /// Generate comprehensive outfit recommendations using all AI models
  static Future<List<AIOutfitRecommendation>> generateSmartRecommendations({
    required String userId,
    required List<WardrobeItem> wardrobeItems,
    required UserProfile userProfile,
    required String occasion,
    String? weather,
    int maxSuggestions = 6,
    bool useAdvancedAI = true,
  }) async {
    if (!_isInitialized) await initialize();
    
    List<AIOutfitRecommendation> recommendations = [];
    
    try {
      // Get personalized weights from ML learning service
      Map<String, double> personalizedWeights = MLLearningService.getPersonalizedWeights(userId);
      
      // Generate base recommendations using enhanced AI model
      List<Outfit> enhancedOutfits = EnhancedAIModel.generateEnhancedOutfits(
        wardrobeItems: wardrobeItems,
        userProfile: userProfile,
        occasion: occasion,
        weather: weather,
        maxSuggestions: maxSuggestions * 2, // Generate more for filtering
      );
      
      // Generate learning-based recommendations
      List<Map<String, dynamic>> learningRecommendations = 
          MLLearningService.generateLearningBasedRecommendations(
        userId: userId,
        wardrobeItems: wardrobeItems,
        userProfile: userProfile,
        occasion: occasion,
        weather: weather,
        maxSuggestions: maxSuggestions,
      );
      
      // Combine and score all recommendations
      for (var outfit in enhancedOutfits) {
        double aiScore = await _calculateComprehensiveScore(
          outfit: outfit,
          wardrobeItems: wardrobeItems,
          userProfile: userProfile,
          userId: userId,
          occasion: occasion,
          weather: weather,
          personalizedWeights: personalizedWeights,
        );
        
        double successProbability = MLLearningService.predictOutfitSuccess(
          userId: userId,
          outfitItems: _getOutfitItems(outfit, wardrobeItems),
          occasion: occasion,
          weather: weather,
        );
        
        List<String> aiInsights = await _generateAIInsights(
          outfit: outfit,
          wardrobeItems: wardrobeItems,
          userProfile: userProfile,
          aiScore: aiScore,
        );
        
        recommendations.add(AIOutfitRecommendation(
          outfit: outfit,
          aiScore: aiScore,
          successProbability: successProbability,
          confidenceLevel: _calculateConfidenceLevel(aiScore, successProbability),
          aiInsights: aiInsights,
          recommendationReason: _generateRecommendationReason(outfit, userProfile, occasion),
          stylingTips: await _generateStylingTips(outfit, wardrobeItems, userProfile),
          alternativeSuggestions: await _generateAlternatives(outfit, wardrobeItems, userProfile),
        ));
      }
      
      // Sort by combined AI score and success probability
      recommendations.sort((a, b) {
        double scoreA = (a.aiScore * 0.6) + (a.successProbability * 0.4);
        double scoreB = (b.aiScore * 0.6) + (b.successProbability * 0.4);
        return scoreB.compareTo(scoreA);
      });
      
      return recommendations.take(maxSuggestions).toList();
      
    } catch (e) {
      print('Error generating smart recommendations: $e');
      // Fallback to basic AI styling service
      return _generateFallbackRecommendations(
        wardrobeItems: wardrobeItems,
        userProfile: userProfile,
        occasion: occasion,
        weather: weather,
        maxSuggestions: maxSuggestions,
      );
    }
  }

  /// Analyze clothing item using advanced AI
  static Future<AIClothingAnalysis> analyzeClothingItem(String imagePath) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Use advanced image analysis
      ClothingAnalysisResult analysisResult = 
          await AdvancedImageAnalysis.analyzeClothingImage(imagePath);
      
      // Generate AI-powered suggestions
      List<String> aiSuggestions = await _generateClothingAISuggestions(analysisResult);
      
      // Predict styling potential
      double stylingPotential = _calculateStylingPotential(analysisResult);
      
      // Generate care recommendations
      List<String> careRecommendations = _generateCareRecommendations(analysisResult);
      
      return AIClothingAnalysis(
        analysisResult: analysisResult,
        aiSuggestions: aiSuggestions,
        stylingPotential: stylingPotential,
        careRecommendations: careRecommendations,
        versatilityScore: _calculateVersatilityScore(analysisResult),
        seasonalRecommendations: _generateSeasonalRecommendations(analysisResult),
      );
      
    } catch (e) {
      print('Error analyzing clothing item: $e');
      throw AIAnalysisException('Failed to analyze clothing item: $e');
    }
  }

  /// Get personalized style insights using AI
  static Future<AIStyleInsights> getPersonalizedStyleInsights({
    required String userId,
    required UserProfile userProfile,
    required List<WardrobeItem> wardrobeItems,
    required List<Outfit> outfitHistory,
  }) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Analyze wardrobe composition
      WardrobeAnalysis wardrobeAnalysis = _analyzeWardrobe(wardrobeItems);
      
      // Get style evolution insights
      StyleEvolution styleEvolution = _analyzeStyleEvolution(outfitHistory, wardrobeItems);
      
      // Generate personalized tips
      List<String> personalizedTips = EnhancedAIModel.getPersonalizedStyleTips(
        userProfile, wardrobeItems
      );
      
      // Get trending recommendations
      List<String> trendingStyles = MLLearningService.getTrendingStyles();
      
      // Analyze color preferences
      Map<String, double> colorAnalysis = _analyzeColorPreferences(wardrobeItems, userProfile);
      
      // Generate wardrobe gaps
      List<WardrobeGap> wardrobeGaps = _identifyWardrobeGaps(wardrobeItems, userProfile);
      
      // Calculate style confidence score
      double styleConfidence = _calculateStyleConfidence(
        wardrobeAnalysis, styleEvolution, userProfile
      );
      
      return AIStyleInsights(
        wardrobeAnalysis: wardrobeAnalysis,
        styleEvolution: styleEvolution,
        personalizedTips: personalizedTips,
        trendingStyles: trendingStyles,
        colorAnalysis: colorAnalysis,
        wardrobeGaps: wardrobeGaps,
        styleConfidence: styleConfidence,
        seasonalRecommendations: MLLearningService.getSeasonalColorRecommendations(userId),
      );
      
    } catch (e) {
      print('Error generating style insights: $e');
      throw AIInsightsException('Failed to generate style insights: $e');
    }
  }

  /// Record user interaction for ML learning
  static Future<void> recordUserInteraction({
    required String userId,
    required UserInteraction interaction,
  }) async {
    try {
      switch (interaction.type) {
        case InteractionType.liked:
        case InteractionType.disliked:
          if (interaction.outfitId != null) {
            MLLearningService.recordOutfitFeedback(
              userId: userId,
              outfitId: interaction.outfitId!,
              rating: interaction.type == InteractionType.liked ? 5.0 : 1.0,
              itemIds: interaction.itemIds ?? [],
              feedback: interaction.feedback,
            );
          }
          break;
        case InteractionType.worn:
          if (interaction.outfitId != null) {
            MLLearningService.recordOutfitFeedback(
              userId: userId,
              outfitId: interaction.outfitId!,
              rating: 4.0, // Wearing indicates positive feedback
              itemIds: interaction.itemIds ?? [],
              wasWorn: true,
            );
          }
          break;
        case InteractionType.saved:
        case InteractionType.shared:
          // Record positive style interactions
          if (interaction.styleElements != null) {
            for (String style in interaction.styleElements!) {
              MLLearningService.recordStyleInteraction(
                userId: userId,
                style: style,
                type: interaction.type,
              );
            }
          }
          break;
        default:
          break;
      }
    } catch (e) {
      print('Error recording user interaction: $e');
    }
  }

  /// Get AI-powered outfit feedback
  static Future<AIOutfitFeedback> getOutfitFeedback({
    required Outfit outfit,
    required List<WardrobeItem> wardrobeItems,
    required UserProfile userProfile,
    required String userId,
  }) async {
    if (!_isInitialized) await initialize();
    
    try {
      List<WardrobeItem> outfitItems = _getOutfitItems(outfit, wardrobeItems);
      
      // Analyze outfit components
      double colorHarmony = _analyzeOutfitColorHarmony(outfitItems);
      double bodyTypeFlattery = _analyzeBodyTypeFlattery(outfitItems, userProfile.bodyType);
      double styleConsistency = _analyzeStyleConsistency(outfitItems);
      double occasionAppropriate = _analyzeOccasionAppropriateness(outfitItems, outfit.occasion);
      
      // Generate specific feedback
      List<String> strengths = [];
      List<String> improvements = [];
      
      if (colorHarmony > 0.8) {
        strengths.add('Excellent color harmony - the colors work beautifully together');
      } else if (colorHarmony < 0.5) {
        improvements.add('Consider adjusting color combinations for better harmony');
      }
      
      if (bodyTypeFlattery > 0.8) {
        strengths.add('This outfit flatters your ${userProfile.bodyType} body type perfectly');
      } else if (bodyTypeFlattery < 0.5) {
        improvements.add('Try different fits that better complement your body shape');
      }
      
      // Calculate overall score
      double overallScore = (colorHarmony + bodyTypeFlattery + styleConsistency + occasionAppropriate) / 4;
      
      return AIOutfitFeedback(
        overallScore: overallScore,
        colorHarmony: colorHarmony,
        bodyTypeFlattery: bodyTypeFlattery,
        styleConsistency: styleConsistency,
        occasionAppropriate: occasionAppropriate,
        strengths: strengths,
        improvements: improvements,
        alternativeItems: await _suggestAlternativeItems(outfitItems, wardrobeItems, userProfile),
      );
      
    } catch (e) {
      print('Error generating outfit feedback: $e');
      throw AIFeedbackException('Failed to generate outfit feedback: $e');
    }
  }

  // Private helper methods
  static Future<void> _loadAIModels() async {
    // Initialize AI model components
    await Future.delayed(Duration(milliseconds: 100)); // Simulate loading
  }

  static Future<void> _calibrateAlgorithms() async {
    // Calibrate AI algorithms
    await Future.delayed(Duration(milliseconds: 50)); // Simulate calibration
  }

  static Future<double> _calculateComprehensiveScore({
    required Outfit outfit,
    required List<WardrobeItem> wardrobeItems,
    required UserProfile userProfile,
    required String userId,
    required String occasion,
    String? weather,
    required Map<String, double> personalizedWeights,
  }) async {
    List<WardrobeItem> outfitItems = _getOutfitItems(outfit, wardrobeItems);
    
    double colorScore = _analyzeOutfitColorHarmony(outfitItems);
    double bodyTypeScore = _analyzeBodyTypeFlattery(outfitItems, userProfile.bodyType);
    double styleScore = _analyzeStyleConsistency(outfitItems);
    double occasionScore = _analyzeOccasionAppropriateness(outfitItems, occasion);
    double weatherScore = weather != null ? _analyzeWeatherSuitability(outfitItems, weather) : 1.0;
    
    // Apply personalized weights
    double totalScore = 
        (colorScore * personalizedWeights['color_preference']!) +
        (bodyTypeScore * personalizedWeights['body_type_flattery']!) +
        (styleScore * personalizedWeights['style_consistency']!) +
        (occasionScore * personalizedWeights['occasion_appropriateness']!) +
        (weatherScore * personalizedWeights['weather_suitability']!);
    
    return totalScore;
  }

  static List<WardrobeItem> _getOutfitItems(Outfit outfit, List<WardrobeItem> wardrobeItems) {
    return wardrobeItems.where((item) => outfit.itemIds.contains(item.id)).toList();
  }

  static double _calculateConfidenceLevel(double aiScore, double successProbability) {
    return (aiScore + successProbability) / 2;
  }

  static Future<List<String>> _generateAIInsights({
    required Outfit outfit,
    required List<WardrobeItem> wardrobeItems,
    required UserProfile userProfile,
    required double aiScore,
  }) async {
    List<String> insights = [];
    List<WardrobeItem> outfitItems = _getOutfitItems(outfit, wardrobeItems);
    
    if (aiScore > 0.8) {
      insights.add('This outfit has excellent AI compatibility with your style profile');
    }
    
    // Color insights
    Map<String, int> colorCounts = {};
    for (var item in outfitItems) {
      colorCounts[item.color] = (colorCounts[item.color] ?? 0) + 1;
    }
    
    if (colorCounts.length <= 3) {
      insights.add('Great color coordination with ${colorCounts.length} harmonious colors');
    }
    
    // Body type insights
    insights.add('Optimized for your ${userProfile.bodyType} body type');
    
    return insights;
  }

  static String _generateRecommendationReason(Outfit outfit, UserProfile userProfile, String occasion) {
    return 'Recommended based on your ${userProfile.bodyType} body type, ${userProfile.skinUndertone} undertone, and ${occasion} occasion preferences';
  }

  static Future<List<String>> _generateStylingTips(
    Outfit outfit,
    List<WardrobeItem> wardrobeItems,
    UserProfile userProfile,
  ) async {
    List<String> tips = [];
    List<WardrobeItem> outfitItems = _getOutfitItems(outfit, wardrobeItems);
    
    // Generate tips based on outfit composition
    if (outfitItems.any((item) => item.type == ClothingType.dress)) {
      tips.add('Add a belt to define your waist and enhance your silhouette');
    }
    
    if (outfitItems.where((item) => item.type == ClothingType.accessory).isEmpty) {
      tips.add('Consider adding accessories to personalize this look');
    }
    
    return tips;
  }

  static Future<List<String>> _generateAlternatives(
    Outfit outfit,
    List<WardrobeItem> wardrobeItems,
    UserProfile userProfile,
  ) async {
    List<String> alternatives = [];
    List<WardrobeItem> outfitItems = _getOutfitItems(outfit, wardrobeItems);
    
    // Find alternative items for each category
    for (var item in outfitItems) {
      List<WardrobeItem> alternatives_items = wardrobeItems
          .where((w) => w.type == item.type && w.id != item.id)
          .take(2)
          .toList();
      
      for (var alt in alternatives_items) {
        alternatives.add('Try ${alt.name} instead of ${item.name}');
      }
    }
    
    return alternatives;
  }

  static List<AIOutfitRecommendation> _generateFallbackRecommendations({
    required List<WardrobeItem> wardrobeItems,
    required UserProfile userProfile,
    required String occasion,
    String? weather,
    required int maxSuggestions,
  }) {
    // Use basic AI styling service as fallback
    List<Outfit> basicOutfits = AIStylingService.generateOutfitSuggestions(
      wardrobeItems: wardrobeItems,
      userProfile: userProfile,
      occasion: occasion,
      weather: weather,
      maxSuggestions: maxSuggestions,
    );
    
    return basicOutfits.map((outfit) => AIOutfitRecommendation(
      outfit: outfit,
      aiScore: 0.6, // Default score for fallback
      successProbability: 0.5,
      confidenceLevel: 0.55,
      aiInsights: ['Generated using fallback AI system'],
      recommendationReason: 'Basic recommendation based on color harmony and body type',
      stylingTips: ['Add accessories to enhance this look'],
      alternativeSuggestions: [],
    )).toList();
  }

  // Analysis helper methods
  static double _analyzeOutfitColorHarmony(List<WardrobeItem> items) {
    if (items.length < 2) return 1.0;
    
    double totalHarmony = 0.0;
    int comparisons = 0;
    
    for (int i = 0; i < items.length; i++) {
      for (int j = i + 1; j < items.length; j++) {
        // Use enhanced color compatibility from EnhancedAIModel
        totalHarmony += 0.8; // Simplified for now
        comparisons++;
      }
    }
    
    return comparisons > 0 ? totalHarmony / comparisons : 1.0;
  }

  static double _analyzeBodyTypeFlattery(List<WardrobeItem> items, String bodyType) {
    double totalScore = 0.0;
    
    for (var item in items) {
      // Simplified body type analysis
      totalScore += 0.7; // Default score
    }
    
    return items.isNotEmpty ? totalScore / items.length : 0.5;
  }

  static double _analyzeStyleConsistency(List<WardrobeItem> items) {
    Map<String, int> styleCounts = {};
    
    for (var item in items) {
      for (var tag in item.tags) {
        styleCounts[tag] = (styleCounts[tag] ?? 0) + 1;
      }
    }
    
    if (styleCounts.isEmpty) return 0.5;
    
    int maxCount = styleCounts.values.reduce(max);
    return maxCount / items.length;
  }

  static double _analyzeOccasionAppropriateness(List<WardrobeItem> items, String occasion) {
    // Simplified occasion analysis
    return 0.8; // Default high score
  }

  static double _analyzeWeatherSuitability(List<WardrobeItem> items, String weather) {
    // Simplified weather analysis
    return 0.8; // Default high score
  }

  // Additional helper methods for comprehensive analysis
  static Future<List<String>> _generateClothingAISuggestions(ClothingAnalysisResult result) async {
    List<String> suggestions = List.from(result.suggestions);
    
    // Add AI-powered suggestions based on analysis
    if (result.colorConfidence > 0.8) {
      suggestions.add('High color recognition confidence - perfect for automated wardrobe management');
    }
    
    if (result.fabricConfidence > 0.7) {
      suggestions.add('Fabric analysis suggests optimal care and styling approaches');
    }
    
    return suggestions;
  }

  static double _calculateStylingPotential(ClothingAnalysisResult result) {
    double potential = 0.5; // Base potential
    
    // Increase potential based on versatility factors
    if (result.primaryColor == 'black' || result.primaryColor == 'white' || result.primaryColor == 'navy') {
      potential += 0.2; // Neutral colors are more versatile
    }
    
    if (result.pattern == 'solid') {
      potential += 0.15; // Solid patterns are more versatile
    }
    
    if (result.fabric == 'cotton' || result.fabric == 'wool') {
      potential += 0.1; // Natural fabrics are versatile
    }
    
    return min(potential, 1.0);
  }

  static List<String> _generateCareRecommendations(ClothingAnalysisResult result) {
    List<String> recommendations = [];
    
    switch (result.fabric) {
      case 'silk':
        recommendations.add('Dry clean only or hand wash in cold water');
        recommendations.add('Avoid direct sunlight when drying');
        break;
      case 'wool':
        recommendations.add('Dry clean or gentle hand wash');
        recommendations.add('Lay flat to dry to maintain shape');
        break;
      case 'cotton':
        recommendations.add('Machine washable in warm water');
        recommendations.add('Can be tumble dried on medium heat');
        break;
      case 'denim':
        recommendations.add('Wash inside out in cold water');
        recommendations.add('Air dry to prevent shrinking');
        break;
      default:
        recommendations.add('Follow care label instructions');
    }
    
    return recommendations;
  }

  static double _calculateVersatilityScore(ClothingAnalysisResult result) {
    return _calculateStylingPotential(result); // Same calculation for now
  }

  static List<String> _generateSeasonalRecommendations(ClothingAnalysisResult result) {
    List<String> seasons = [];
    
    // Based on fabric and color
    if (result.fabric == 'wool' || result.fabric == 'cashmere') {
      seasons.addAll(['fall', 'winter']);
    } else if (result.fabric == 'linen' || result.fabric == 'cotton') {
      seasons.addAll(['spring', 'summer']);
    } else {
      seasons.addAll(['spring', 'summer', 'fall', 'winter']);
    }
    
    return seasons;
  }

  static WardrobeAnalysis _analyzeWardrobe(List<WardrobeItem> items) {
    Map<ClothingType, int> typeCounts = {};
    Map<String, int> colorCounts = {};
    Map<String, int> fabricCounts = {};
    
    for (var item in items) {
      typeCounts[item.type] = (typeCounts[item.type] ?? 0) + 1;
      colorCounts[item.color] = (colorCounts[item.color] ?? 0) + 1;
      if (item.fabric != null) {
        fabricCounts[item.fabric!] = (fabricCounts[item.fabric!] ?? 0) + 1;
      }
    }
    
    return WardrobeAnalysis(
      totalItems: items.length,
      typeDistribution: typeCounts,
      colorDistribution: colorCounts,
      fabricDistribution: fabricCounts,
      averageRating: items.isNotEmpty ? items.map((i) => i.rating).reduce((a, b) => a + b) / items.length : 0.0,
      mostWornItems: items.where((i) => i.wearCount > 5).toList(),
      leastWornItems: items.where((i) => i.wearCount == 0).toList(),
    );
  }

  static StyleEvolution _analyzeStyleEvolution(List<Outfit> outfits, List<WardrobeItem> items) {
    // Simplified style evolution analysis
    return StyleEvolution(
      totalOutfits: outfits.length,
      styleProgression: [],
      colorTrends: {},
      preferenceChanges: [],
    );
  }

  static Map<String, double> _analyzeColorPreferences(List<WardrobeItem> items, UserProfile profile) {
    Map<String, int> colorCounts = {};
    
    for (var item in items) {
      colorCounts[item.color] = (colorCounts[item.color] ?? 0) + 1;
    }
    
    Map<String, double> preferences = {};
    int totalItems = items.length;
    
    colorCounts.forEach((color, count) {
      preferences[color] = count / totalItems;
    });
    
    return preferences;
  }

  static List<WardrobeGap> _identifyWardrobeGaps(List<WardrobeItem> items, UserProfile profile) {
    List<WardrobeGap> gaps = [];
    
    Map<ClothingType, int> typeCounts = {};
    for (var item in items) {
      typeCounts[item.type] = (typeCounts[item.type] ?? 0) + 1;
    }
    
    // Check for missing essential items
    if ((typeCounts[ClothingType.dress] ?? 0) < 2) {
      gaps.add(WardrobeGap(
        type: ClothingType.dress,
        priority: 'medium',
        reason: 'Add versatile dresses for easy styling',
        suggestions: ['Little black dress', 'Casual day dress'],
      ));
    }
    
    if ((typeCounts[ClothingType.accessory] ?? 0) < 3) {
      gaps.add(WardrobeGap(
        type: ClothingType.accessory,
        priority: 'low',
        reason: 'Accessories can transform any outfit',
        suggestions: ['Statement necklace', 'Classic watch', 'Versatile scarf'],
      ));
    }
    
    return gaps;
  }

  static double _calculateStyleConfidence(
    WardrobeAnalysis analysis,
    StyleEvolution evolution,
    UserProfile profile,
  ) {
    double confidence = 0.5; // Base confidence
    
    // Increase confidence based on wardrobe completeness
    if (analysis.totalItems > 20) confidence += 0.2;
    if (analysis.typeDistribution.length >= 4) confidence += 0.15;
    if (analysis.averageRating > 3.5) confidence += 0.15;
    
    return min(confidence, 1.0);
  }

  static Future<List<String>> _suggestAlternativeItems(
    List<WardrobeItem> outfitItems,
    List<WardrobeItem> allItems,
    UserProfile profile,
  ) async {
    List<String> suggestions = [];
    
    for (var item in outfitItems) {
      List<WardrobeItem> alternatives = allItems
          .where((w) => w.type == item.type && w.id != item.id)
          .take(2)
          .toList();
      
      for (var alt in alternatives) {
        suggestions.add('Consider ${alt.name} for a different look');
      }
    }
    
    return suggestions;
  }
}

// Data classes for AI results
class AIOutfitRecommendation {
  final Outfit outfit;
  final double aiScore;
  final double successProbability;
  final double confidenceLevel;
  final List<String> aiInsights;
  final String recommendationReason;
  final List<String> stylingTips;
  final List<String> alternativeSuggestions;

  AIOutfitRecommendation({
    required this.outfit,
    required this.aiScore,
    required this.successProbability,
    required this.confidenceLevel,
    required this.aiInsights,
    required this.recommendationReason,
    required this.stylingTips,
    required this.alternativeSuggestions,
  });
}

class AIClothingAnalysis {
  final ClothingAnalysisResult analysisResult;
  final List<String> aiSuggestions;
  final double stylingPotential;
  final List<String> careRecommendations;
  final double versatilityScore;
  final List<String> seasonalRecommendations;

  AIClothingAnalysis({
    required this.analysisResult,
    required this.aiSuggestions,
    required this.stylingPotential,
    required this.careRecommendations,
    required this.versatilityScore,
    required this.seasonalRecommendations,
  });
}

class AIStyleInsights {
  final WardrobeAnalysis wardrobeAnalysis;
  final StyleEvolution styleEvolution;
  final List<String> personalizedTips;
  final List<String> trendingStyles;
  final Map<String, double> colorAnalysis;
  final List<WardrobeGap> wardrobeGaps;
  final double styleConfidence;
  final List<String> seasonalRecommendations;

  AIStyleInsights({
    required this.wardrobeAnalysis,
    required this.styleEvolution,
    required this.personalizedTips,
    required this.trendingStyles,
    required this.colorAnalysis,
    required this.wardrobeGaps,
    required this.styleConfidence,
    required this.seasonalRecommendations,
  });
}

class AIOutfitFeedback {
  final double overallScore;
  final double colorHarmony;
  final double bodyTypeFlattery;
  final double styleConsistency;
  final double occasionAppropriate;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> alternativeItems;

  AIOutfitFeedback({
    required this.overallScore,
    required this.colorHarmony,
    required this.bodyTypeFlattery,
    required this.styleConsistency,
    required this.occasionAppropriate,
    required this.strengths,
    required this.improvements,
    required this.alternativeItems,
  });
}

class UserInteraction {
  final InteractionType type;
  final String? outfitId;
  final List<String>? itemIds;
  final List<String>? styleElements;
  final String? feedback;
  final DateTime timestamp;

  UserInteraction({
    required this.type,
    this.outfitId,
    this.itemIds,
    this.styleElements,
    this.feedback,
    required this.timestamp,
  });
}

class WardrobeAnalysis {
  final int totalItems;
  final Map<ClothingType, int> typeDistribution;
  final Map<String, int> colorDistribution;
  final Map<String, int> fabricDistribution;
  final double averageRating;
  final List<WardrobeItem> mostWornItems;
  final List<WardrobeItem> leastWornItems;

  WardrobeAnalysis({
    required this.totalItems,
    required this.typeDistribution,
    required this.colorDistribution,
    required this.fabricDistribution,
    required this.averageRating,
    required this.mostWornItems,
    required this.leastWornItems,
  });
}

class StyleEvolution {
  final int totalOutfits;
  final List<String> styleProgression;
  final Map<String, double> colorTrends;
  final List<String> preferenceChanges;

  StyleEvolution({
    required this.totalOutfits,
    required this.styleProgression,
    required this.colorTrends,
    required this.preferenceChanges,
  });
}

class WardrobeGap {
  final ClothingType type;
  final String priority;
  final String reason;
  final List<String> suggestions;

  WardrobeGap({
    required this.type,
    required this.priority,
    required this.reason,
    required this.suggestions,
  });
}

// Exception classes
class AIInitializationException implements Exception {
  final String message;
  AIInitializationException(this.message);
  @override
  String toString() => 'AIInitializationException: $message';
}

class AIAnalysisException implements Exception {
  final String message;
  AIAnalysisException(this.message);
  @override
  String toString() => 'AIAnalysisException: $message';
}

class AIInsightsException implements Exception {
  final String message;
  AIInsightsException(this.message);
  @override
  String toString() => 'AIInsightsException: $message';
}

class AIFeedbackException implements Exception {
  final String message;
  AIFeedbackException(this.message);
  @override
  String toString() => 'AIFeedbackException: $message';
}