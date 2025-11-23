import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/wardrobe_item.dart';
import '../models/user_profile.dart';
import '../models/outfit.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  
  static Future<List<Outfit>> getOutfitRecommendations({
    required List<WardrobeItem> wardrobeItems,
    required UserProfile userProfile,
    required String occasion,
    String? weather,
    int maxSuggestions = 5,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recommendations/outfits'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'wardrobeItems': wardrobeItems.map((item) => {
            'id': item.id,
            'name': item.name,
            'type': item.type.name,
            'color': item.color,
            'pattern': item.pattern,
            'fabric': item.fabric,
            'fit': item.fit,
            'season': item.season.name,
            'tags': item.tags,
            'rating': item.rating,
            'wearCount': item.wearCount,
          }).toList(),
          'userProfile': {
            'id': userProfile.id,
            'name': userProfile.name,
            'gender': userProfile.gender,
            'bodyType': userProfile.bodyType,
            'skinUndertone': userProfile.skinUndertone,
            'faceShape': userProfile.faceShape,
            'favoriteColors': userProfile.favoriteColors,
            'dislikedPatterns': userProfile.dislikedPatterns,
            'measurements': userProfile.measurements,
            'stylePreferences': userProfile.stylePreferences,
          },
          'occasion': occasion,
          'weather': weather,
          'maxSuggestions': maxSuggestions,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Outfit(
          id: 'api_${DateTime.now().millisecondsSinceEpoch}',
          name: 'AI Suggestion',
          itemIds: List<String>.from(item['items']),
          occasion: item['occasion'],
          weather: item['weather'],
          createdAt: DateTime.now(),
        )).toList();
      } else {
        throw Exception('Failed to get recommendations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }

  static Future<List<String>> getStyleTips(UserProfile userProfile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recommendations/style-tips'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': userProfile.id,
          'name': userProfile.name,
          'gender': userProfile.gender,
          'bodyType': userProfile.bodyType,
          'skinUndertone': userProfile.skinUndertone,
          'faceShape': userProfile.faceShape,
          'favoriteColors': userProfile.favoriteColors,
          'dislikedPatterns': userProfile.dislikedPatterns,
          'measurements': userProfile.measurements,
          'stylePreferences': userProfile.stylePreferences,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['tips']);
      } else {
        throw Exception('Failed to get style tips: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting style tips: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> analyzeColorCompatibility(String color1, String color2) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/analysis/color-compatibility'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'color1': color1,
          'color2': color2,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze colors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error analyzing colors: $e');
      return {'compatible': false, 'compatibility_score': 0.0};
    }
  }

  static Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload/image'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var response = await request.send();
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = jsonDecode(responseData);
        return data['file_path'];
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}