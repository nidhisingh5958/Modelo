import 'dart:io';
import 'dart:math';
import '../models/wardrobe_item.dart';
import 'advanced_image_analysis.dart';

class ImageAnalysisService {
  static Future<Map<String, dynamic>> analyzeClothingImage(File imageFile) async {
    try {
      // Use advanced on-device image analysis
      final analysisResult = await AdvancedImageAnalysis.analyzeClothingImage(imageFile.path);
      
      return {
        'name': _generateItemName(analysisResult.clothingType, analysisResult.primaryColor),
        'type': analysisResult.clothingType,
        'color': analysisResult.primaryColor,
        'pattern': analysisResult.pattern,
        'fabric': analysisResult.fabric,
        'fit': _determineFit(analysisResult.fabric, analysisResult.clothingType),
        'season': _detectSeason(analysisResult.clothingType, analysisResult.fabric),
        'tags': _generateTags(analysisResult.clothingType, analysisResult.primaryColor, analysisResult.pattern, analysisResult.fabric),
        'confidence': (analysisResult.colorConfidence + analysisResult.patternConfidence + analysisResult.fabricConfidence) / 3,
        'suggestions': analysisResult.suggestions,
        'secondaryColors': analysisResult.secondaryColors,
      };
    } catch (e) {
      // Fallback to basic analysis if advanced analysis fails
      return _basicImageAnalysis(imageFile);
    }
  }
  
  static Future<Map<String, dynamic>> _basicImageAnalysis(File imageFile) async {
    // Basic fallback analysis
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'name': 'Clothing Item',
      'type': ClothingType.top,
      'color': 'unknown',
      'pattern': 'solid',
      'fabric': 'unknown',
      'fit': 'regular',
      'season': Season.allSeason,
      'tags': ['clothing'],
      'confidence': 0.3,
      'suggestions': ['Please try again with better lighting for improved analysis'],
    };
  }
  
  static String _determineFit(String fabric, ClothingType type) {
    // Determine fit based on fabric and type
    if (fabric == 'silk' || fabric == 'wool') {
      return 'fitted';
    } else if (fabric == 'cotton' && type == ClothingType.top) {
      return 'regular';
    } else if (fabric == 'denim') {
      return 'slim';
    }
    return 'regular';
  }
  
  static Season _detectSeason(ClothingType type, String fabric) {
    if (fabric == 'wool' || type == ClothingType.outerwear) {
      return Season.winter;
    } else if (fabric == 'cotton' && type == ClothingType.top) {
      return Season.summer;
    }
    return Season.allSeason;
  }
  
  static String _generateItemName(ClothingType type, String color) {
    final typeNames = {
      ClothingType.top: ['Shirt', 'Blouse', 'T-Shirt', 'Tank Top'],
      ClothingType.bottom: ['Pants', 'Jeans', 'Skirt', 'Shorts'],
      ClothingType.dress: ['Dress', 'Gown', 'Sundress'],
      ClothingType.outerwear: ['Jacket', 'Coat', 'Blazer', 'Cardigan'],
      ClothingType.shoes: ['Shoes', 'Sneakers', 'Boots', 'Heels'],
      ClothingType.accessory: ['Bag', 'Belt', 'Scarf', 'Hat'],
    };
    
    final names = typeNames[type] ?? ['Item'];
    final name = names[Random().nextInt(names.length)];
    return '$color $name';
  }
  
  static List<String> _generateTags(ClothingType type, String color, String pattern, String fabric) {
    final tags = <String>[];
    
    // Add type-based tags
    switch (type) {
      case ClothingType.top:
        tags.addAll(['casual', 'versatile']);
        break;
      case ClothingType.bottom:
        tags.addAll(['comfortable', 'everyday']);
        break;
      case ClothingType.dress:
        tags.addAll(['elegant', 'feminine']);
        break;
      case ClothingType.outerwear:
        tags.addAll(['layering', 'weather']);
        break;
      case ClothingType.shoes:
        tags.addAll(['footwear', 'comfort']);
        break;
      case ClothingType.accessory:
        tags.addAll(['accent', 'style']);
        break;
    }
    
    // Add color-based tags
    if (color == 'black' || color == 'white' || color == 'gray') {
      tags.add('neutral');
    }
    
    // Add pattern-based tags
    if (pattern != 'solid') {
      tags.add('patterned');
    }
    
    // Add fabric-based tags
    switch (fabric) {
      case 'cotton':
        tags.addAll(['breathable', 'natural']);
        break;
      case 'silk':
        tags.addAll(['luxury', 'elegant']);
        break;
      case 'wool':
        tags.addAll(['warm', 'cozy']);
        break;
      case 'denim':
        tags.addAll(['casual', 'durable']);
        break;
      case 'leather':
        tags.addAll(['edgy', 'statement']);
        break;
    }
    
    return tags;
  }
}