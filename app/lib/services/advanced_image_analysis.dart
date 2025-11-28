import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/wardrobe_item.dart';

class AdvancedImageAnalysis {
  // Color mapping for better recognition
  static const Map<String, Map<String, int>> _colorRanges = {
    'red': {'r': 255, 'g': 0, 'b': 0, 'tolerance': 50},
    'blue': {'r': 0, 'g': 0, 'b': 255, 'tolerance': 50},
    'green': {'r': 0, 'g': 255, 'b': 0, 'tolerance': 50},
    'yellow': {'r': 255, 'g': 255, 'b': 0, 'tolerance': 40},
    'black': {'r': 0, 'g': 0, 'b': 0, 'tolerance': 30},
    'white': {'r': 255, 'g': 255, 'b': 255, 'tolerance': 30},
    'gray': {'r': 128, 'g': 128, 'b': 128, 'tolerance': 60},
    'brown': {'r': 165, 'g': 42, 'b': 42, 'tolerance': 40},
    'pink': {'r': 255, 'g': 192, 'b': 203, 'tolerance': 40},
    'purple': {'r': 128, 'g': 0, 'b': 128, 'tolerance': 50},
    'orange': {'r': 255, 'g': 165, 'b': 0, 'tolerance': 40},
    'navy': {'r': 0, 'g': 0, 'b': 128, 'tolerance': 30},
    'beige': {'r': 245, 'g': 245, 'b': 220, 'tolerance': 25},
  };

  // Pattern recognition templates
  static const Map<String, List<String>> _patternKeywords = {
    'stripes': ['horizontal', 'vertical', 'diagonal', 'pinstripe'],
    'polka_dots': ['dots', 'spotted', 'circular'],
    'floral': ['flowers', 'botanical', 'roses', 'leaves'],
    'geometric': ['squares', 'triangles', 'diamonds', 'hexagon'],
    'animal_print': ['leopard', 'zebra', 'snake', 'tiger'],
    'plaid': ['checkered', 'tartan', 'gingham'],
    'solid': ['plain', 'uniform', 'single_color'],
  };

  // Fabric texture indicators
  static const Map<String, Map<String, dynamic>> _fabricCharacteristics = {
    'cotton': {
      'texture_variance': [200, 800],
      'smoothness': [0.3, 0.7],
      'keywords': ['casual', 'breathable', 'natural']
    },
    'silk': {
      'texture_variance': [50, 300],
      'smoothness': [0.8, 1.0],
      'keywords': ['smooth', 'lustrous', 'elegant']
    },
    'wool': {
      'texture_variance': [800, 2000],
      'smoothness': [0.1, 0.4],
      'keywords': ['warm', 'textured', 'cozy']
    },
    'denim': {
      'texture_variance': [600, 1200],
      'smoothness': [0.2, 0.5],
      'keywords': ['sturdy', 'casual', 'woven']
    },
    'leather': {
      'texture_variance': [400, 1000],
      'smoothness': [0.4, 0.8],
      'keywords': ['smooth', 'durable', 'luxury']
    },
    'linen': {
      'texture_variance': [500, 1000],
      'smoothness': [0.3, 0.6],
      'keywords': ['breathable', 'natural', 'wrinkled']
    },
  };

  /// Analyze clothing item from image with advanced algorithms
  static Future<ClothingAnalysisResult> analyzeClothingImage(String imagePath) async {
    try {
      // Load and process image
      File imageFile = File(imagePath);
      Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Decode image
      ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      ui.FrameInfo frameInfo = await codec.getNextFrame();
      ui.Image image = frameInfo.image;
      
      // Extract image data
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        throw Exception('Failed to extract image data');
      }
      
      Uint8List pixels = byteData.buffer.asUint8List();
      
      // Perform analysis
      ColorAnalysisResult colorResult = await _analyzeColors(pixels, image.width, image.height);
      PatternAnalysisResult patternResult = await _analyzePatterns(pixels, image.width, image.height);
      FabricAnalysisResult fabricResult = await _analyzeFabric(pixels, image.width, image.height);
      ClothingType clothingType = await _classifyClothingType(pixels, image.width, image.height);
      
      return ClothingAnalysisResult(
        primaryColor: colorResult.primaryColor,
        secondaryColors: colorResult.secondaryColors,
        colorConfidence: colorResult.confidence,
        pattern: patternResult.pattern,
        patternConfidence: patternResult.confidence,
        fabric: fabricResult.fabric,
        fabricConfidence: fabricResult.confidence,
        clothingType: clothingType,
        suggestions: _generateSuggestions(colorResult, patternResult, fabricResult, clothingType),
      );
      
    } catch (e) {
      print('Error analyzing image: $e');
      return ClothingAnalysisResult.defaultResult();
    }
  }

  /// Advanced color analysis using clustering and color theory
  static Future<ColorAnalysisResult> _analyzeColors(Uint8List pixels, int width, int height) async {
    Map<String, int> colorCounts = {};
    Map<String, double> colorPercentages = {};
    
    // Sample pixels (every 4th pixel for performance)
    for (int i = 0; i < pixels.length; i += 16) { // RGBA = 4 bytes per pixel, sample every 4th
      if (i + 3 < pixels.length) {
        int r = pixels[i];
        int g = pixels[i + 1];
        int b = pixels[i + 2];
        int a = pixels[i + 3];
        
        // Skip transparent pixels
        if (a < 128) continue;
        
        String closestColor = _getClosestColorName(r, g, b);
        colorCounts[closestColor] = (colorCounts[closestColor] ?? 0) + 1;
      }
    }
    
    // Calculate percentages
    int totalPixels = colorCounts.values.fold(0, (sum, count) => sum + count);
    colorCounts.forEach((color, count) {
      colorPercentages[color] = count / totalPixels;
    });
    
    // Sort by percentage
    var sortedColors = colorPercentages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    String primaryColor = sortedColors.isNotEmpty ? sortedColors.first.key : 'unknown';
    List<String> secondaryColors = sortedColors.skip(1).take(3).map((e) => e.key).toList();
    double confidence = sortedColors.isNotEmpty ? sortedColors.first.value : 0.0;
    
    return ColorAnalysisResult(
      primaryColor: primaryColor,
      secondaryColors: secondaryColors,
      confidence: confidence,
      colorDistribution: colorPercentages,
    );
  }

  /// Pattern recognition using edge detection and frequency analysis
  static Future<PatternAnalysisResult> _analyzePatterns(Uint8List pixels, int width, int height) async {
    // Convert to grayscale for pattern analysis
    List<int> grayscale = [];
    for (int i = 0; i < pixels.length; i += 4) {
      if (i + 3 < pixels.length) {
        int r = pixels[i];
        int g = pixels[i + 1];
        int b = pixels[i + 2];
        int gray = ((r * 0.299) + (g * 0.587) + (b * 0.114)).round();
        grayscale.add(gray);
      }
    }
    
    // Detect edges using simple gradient
    List<int> edges = _detectEdges(grayscale, width, height);
    
    // Analyze patterns
    Map<String, double> patternScores = {};
    
    // Check for stripes (horizontal and vertical lines)
    patternScores['stripes'] = _detectStripes(edges, width, height);
    
    // Check for dots/circles
    patternScores['polka_dots'] = _detectDots(edges, width, height);
    
    // Check for geometric patterns
    patternScores['geometric'] = _detectGeometric(edges, width, height);
    
    // Default to solid if no clear pattern
    patternScores['solid'] = 1.0 - patternScores.values.fold(0.0, (sum, score) => sum + score);
    
    // Find dominant pattern
    var sortedPatterns = patternScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    String dominantPattern = sortedPatterns.first.key;
    double confidence = sortedPatterns.first.value;
    
    return PatternAnalysisResult(
      pattern: dominantPattern,
      confidence: confidence,
      patternScores: patternScores,
    );
  }

  /// Fabric analysis using texture and surface characteristics
  static Future<FabricAnalysisResult> _analyzeFabric(Uint8List pixels, int width, int height) async {
    // Calculate texture variance
    double textureVariance = _calculateTextureVariance(pixels, width, height);
    
    // Calculate smoothness
    double smoothness = _calculateSmoothness(pixels, width, height);
    
    // Match to fabric types
    String bestMatch = 'unknown';
    double bestScore = 0.0;
    
    _fabricCharacteristics.forEach((fabric, characteristics) {
      List<int> varianceRange = characteristics['texture_variance'];
      List<double> smoothnessRange = characteristics['smoothness'];
      
      double varianceScore = 0.0;
      if (textureVariance >= varianceRange[0] && textureVariance <= varianceRange[1]) {
        varianceScore = 1.0 - ((textureVariance - varianceRange[0]) / (varianceRange[1] - varianceRange[0]) - 0.5).abs() * 2;
      }
      
      double smoothnessScore = 0.0;
      if (smoothness >= smoothnessRange[0] && smoothness <= smoothnessRange[1]) {
        smoothnessScore = 1.0 - ((smoothness - smoothnessRange[0]) / (smoothnessRange[1] - smoothnessRange[0]) - 0.5).abs() * 2;
      }
      
      double totalScore = (varianceScore + smoothnessScore) / 2;
      
      if (totalScore > bestScore) {
        bestScore = totalScore;
        bestMatch = fabric;
      }
    });
    
    return FabricAnalysisResult(
      fabric: bestMatch,
      confidence: bestScore,
      textureVariance: textureVariance,
      smoothness: smoothness,
    );
  }

  /// Classify clothing type based on shape and proportions
  static Future<ClothingType> _classifyClothingType(Uint8List pixels, int width, int height) async {
    // Simple heuristic based on aspect ratio and shape analysis
    double aspectRatio = height / width;
    
    // Analyze shape characteristics
    int nonTransparentPixels = 0;
    int topHalfPixels = 0;
    int bottomHalfPixels = 0;
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int index = (y * width + x) * 4;
        if (index + 3 < pixels.length) {
          int alpha = pixels[index + 3];
          if (alpha > 128) {
            nonTransparentPixels++;
            if (y < height / 2) {
              topHalfPixels++;
            } else {
              bottomHalfPixels++;
            }
          }
        }
      }
    }
    
    double topBottomRatio = topHalfPixels / (bottomHalfPixels + 1);
    
    // Classification logic
    if (aspectRatio > 1.8) {
      return ClothingType.dress;
    } else if (aspectRatio > 1.2 && topBottomRatio > 0.8) {
      return ClothingType.top;
    } else if (aspectRatio < 0.8) {
      return ClothingType.bottom;
    } else if (topBottomRatio < 0.3) {
      return ClothingType.bottom;
    } else {
      return ClothingType.top; // Default fallback
    }
  }

  // Helper methods for image analysis
  static String _getClosestColorName(int r, int g, int b) {
    String closestColor = 'unknown';
    double minDistance = double.infinity;
    
    _colorRanges.forEach((colorName, colorData) {
      int targetR = colorData['r']!;
      int targetG = colorData['g']!;
      int targetB = colorData['b']!;
      int tolerance = colorData['tolerance']!;
      
      double distance = ((r - targetR) * (r - targetR) + 
                        (g - targetG) * (g - targetG) + 
                        (b - targetB) * (b - targetB)).toDouble();
      
      if (distance < minDistance && distance <= tolerance * tolerance) {
        minDistance = distance;
        closestColor = colorName;
      }
    });
    
    return closestColor;
  }

  static List<int> _detectEdges(List<int> grayscale, int width, int height) {
    List<int> edges = List.filled(grayscale.length, 0);
    
    // Simple Sobel edge detection
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        int index = y * width + x;
        
        // Sobel X kernel
        int gx = -grayscale[(y-1)*width + (x-1)] + grayscale[(y-1)*width + (x+1)] +
                 -2*grayscale[y*width + (x-1)] + 2*grayscale[y*width + (x+1)] +
                 -grayscale[(y+1)*width + (x-1)] + grayscale[(y+1)*width + (x+1)];
        
        // Sobel Y kernel
        int gy = -grayscale[(y-1)*width + (x-1)] - 2*grayscale[(y-1)*width + x] - grayscale[(y-1)*width + (x+1)] +
                 grayscale[(y+1)*width + (x-1)] + 2*grayscale[(y+1)*width + x] + grayscale[(y+1)*width + (x+1)];
        
        edges[index] = ((gx * gx + gy * gy) / 1000).round().clamp(0, 255);
      }
    }
    
    return edges;
  }

  static double _detectStripes(List<int> edges, int width, int height) {
    int horizontalLines = 0;
    int verticalLines = 0;
    
    // Count horizontal lines
    for (int y = 0; y < height; y += 5) {
      int lineStrength = 0;
      for (int x = 0; x < width; x++) {
        if (edges[y * width + x] > 100) lineStrength++;
      }
      if (lineStrength > width * 0.6) horizontalLines++;
    }
    
    // Count vertical lines
    for (int x = 0; x < width; x += 5) {
      int lineStrength = 0;
      for (int y = 0; y < height; y++) {
        if (edges[y * width + x] > 100) lineStrength++;
      }
      if (lineStrength > height * 0.6) verticalLines++;
    }
    
    int totalLines = horizontalLines + verticalLines;
    return (totalLines / ((height / 5) + (width / 5))).clamp(0.0, 1.0);
  }

  static double _detectDots(List<int> edges, int width, int height) {
    // Simplified dot detection - count circular-like patterns
    int dotCount = 0;
    
    for (int y = 10; y < height - 10; y += 15) {
      for (int x = 10; x < width - 10; x += 15) {
        int circularEdges = 0;
        
        // Check for circular pattern around point
        for (int angle = 0; angle < 360; angle += 45) {
          double rad = angle * 3.14159 / 180;
          int checkX = (x + 5 * cos(rad)).round();
          int checkY = (y + 5 * sin(rad)).round();
          
          if (checkX >= 0 && checkX < width && checkY >= 0 && checkY < height) {
            if (edges[checkY * width + checkX] > 80) circularEdges++;
          }
        }
        
        if (circularEdges >= 6) dotCount++;
      }
    }
    
    int maxPossibleDots = ((width / 15) * (height / 15)).round();
    return (dotCount / maxPossibleDots).clamp(0.0, 1.0);
  }

  static double _detectGeometric(List<int> edges, int width, int height) {
    // Simplified geometric pattern detection
    int geometricFeatures = 0;
    int totalChecks = 0;
    
    // Look for regular patterns and shapes
    for (int y = 0; y < height - 20; y += 20) {
      for (int x = 0; x < width - 20; x += 20) {
        totalChecks++;
        
        // Check for rectangular patterns
        int cornerEdges = 0;
        List<List<int>> corners = [[x, y], [x+20, y], [x, y+20], [x+20, y+20]];
        
        for (var corner in corners) {
          if (corner[0] < width && corner[1] < height) {
            if (edges[corner[1] * width + corner[0]] > 100) cornerEdges++;
          }
        }
        
        if (cornerEdges >= 3) geometricFeatures++;
      }
    }
    
    return totalChecks > 0 ? (geometricFeatures / totalChecks).clamp(0.0, 1.0) : 0.0;
  }

  static double _calculateTextureVariance(Uint8List pixels, int width, int height) {
    List<double> intensities = [];
    
    for (int i = 0; i < pixels.length; i += 4) {
      if (i + 3 < pixels.length) {
        int r = pixels[i];
        int g = pixels[i + 1];
        int b = pixels[i + 2];
        double intensity = (r + g + b) / 3.0;
        intensities.add(intensity);
      }
    }
    
    if (intensities.isEmpty) return 0.0;
    
    double mean = intensities.reduce((a, b) => a + b) / intensities.length;
    double variance = intensities.map((i) => (i - mean) * (i - mean)).reduce((a, b) => a + b) / intensities.length;
    
    return variance;
  }

  static double _calculateSmoothness(Uint8List pixels, int width, int height) {
    double totalGradient = 0.0;
    int gradientCount = 0;
    
    for (int y = 0; y < height - 1; y++) {
      for (int x = 0; x < width - 1; x++) {
        int index1 = (y * width + x) * 4;
        int index2 = (y * width + (x + 1)) * 4;
        int index3 = ((y + 1) * width + x) * 4;
        
        if (index3 + 3 < pixels.length) {
          double intensity1 = (pixels[index1] + pixels[index1 + 1] + pixels[index1 + 2]) / 3.0;
          double intensity2 = (pixels[index2] + pixels[index2 + 1] + pixels[index2 + 2]) / 3.0;
          double intensity3 = (pixels[index3] + pixels[index3 + 1] + pixels[index3 + 2]) / 3.0;
          
          double gradientX = (intensity2 - intensity1).abs();
          double gradientY = (intensity3 - intensity1).abs();
          
          totalGradient += (gradientX + gradientY) / 2;
          gradientCount++;
        }
      }
    }
    
    double avgGradient = gradientCount > 0 ? totalGradient / gradientCount : 0.0;
    return (255 - avgGradient) / 255; // Invert so higher = smoother
  }

  static List<String> _generateSuggestions(
    ColorAnalysisResult colorResult,
    PatternAnalysisResult patternResult,
    FabricAnalysisResult fabricResult,
    ClothingType clothingType,
  ) {
    List<String> suggestions = [];
    
    // Color-based suggestions
    if (colorResult.confidence > 0.7) {
      suggestions.add('Primary color detected as ${colorResult.primaryColor} with high confidence');
    }
    
    // Pattern-based suggestions
    if (patternResult.confidence > 0.6) {
      suggestions.add('${patternResult.pattern} pattern detected - great for ${_getPatternStylingTips(patternResult.pattern)}');
    }
    
    // Fabric-based suggestions
    if (fabricResult.confidence > 0.5) {
      suggestions.add('${fabricResult.fabric} fabric detected - ideal for ${_getFabricOccasions(fabricResult.fabric)}');
    }
    
    // Type-based suggestions
    suggestions.add('Classified as ${clothingType.toString().split('.').last} - ${_getTypeStylingTips(clothingType)}');
    
    return suggestions;
  }

  static String _getPatternStylingTips(String pattern) {
    switch (pattern) {
      case 'stripes':
        return 'creating visual lines and structure';
      case 'polka_dots':
        return 'adding playful, vintage charm';
      case 'floral':
        return 'romantic and feminine looks';
      case 'geometric':
        return 'modern, structured outfits';
      case 'solid':
        return 'versatile layering and mixing';
      default:
        return 'various styling options';
    }
  }

  static String _getFabricOccasions(String fabric) {
    switch (fabric) {
      case 'cotton':
        return 'casual, everyday wear';
      case 'silk':
        return 'formal events and elegant occasions';
      case 'wool':
        return 'cooler weather and professional settings';
      case 'denim':
        return 'casual outings and relaxed styles';
      case 'leather':
        return 'edgy looks and statement pieces';
      case 'linen':
        return 'warm weather and relaxed settings';
      default:
        return 'various occasions';
    }
  }

  static String _getTypeStylingTips(ClothingType type) {
    switch (type) {
      case ClothingType.top:
        return 'pair with complementary bottoms and accessories';
      case ClothingType.bottom:
        return 'style with fitted or flowing tops';
      case ClothingType.dress:
        return 'accessorize for complete looks';
      case ClothingType.outerwear:
        return 'layer over coordinated outfits';
      case ClothingType.shoes:
        return 'complete outfits with proper coordination';
      case ClothingType.accessory:
        return 'enhance and personalize your style';
    }
  }
}

// Result classes for image analysis
class ClothingAnalysisResult {
  final String primaryColor;
  final List<String> secondaryColors;
  final double colorConfidence;
  final String pattern;
  final double patternConfidence;
  final String fabric;
  final double fabricConfidence;
  final ClothingType clothingType;
  final List<String> suggestions;

  ClothingAnalysisResult({
    required this.primaryColor,
    required this.secondaryColors,
    required this.colorConfidence,
    required this.pattern,
    required this.patternConfidence,
    required this.fabric,
    required this.fabricConfidence,
    required this.clothingType,
    required this.suggestions,
  });

  factory ClothingAnalysisResult.defaultResult() {
    return ClothingAnalysisResult(
      primaryColor: 'unknown',
      secondaryColors: [],
      colorConfidence: 0.0,
      pattern: 'solid',
      patternConfidence: 0.5,
      fabric: 'unknown',
      fabricConfidence: 0.0,
      clothingType: ClothingType.top,
      suggestions: ['Unable to analyze image - please try again with better lighting'],
    );
  }
}

class ColorAnalysisResult {
  final String primaryColor;
  final List<String> secondaryColors;
  final double confidence;
  final Map<String, double> colorDistribution;

  ColorAnalysisResult({
    required this.primaryColor,
    required this.secondaryColors,
    required this.confidence,
    required this.colorDistribution,
  });
}

class PatternAnalysisResult {
  final String pattern;
  final double confidence;
  final Map<String, double> patternScores;

  PatternAnalysisResult({
    required this.pattern,
    required this.confidence,
    required this.patternScores,
  });
}

class FabricAnalysisResult {
  final String fabric;
  final double confidence;
  final double textureVariance;
  final double smoothness;

  FabricAnalysisResult({
    required this.fabric,
    required this.confidence,
    required this.textureVariance,
    required this.smoothness,
  });
}