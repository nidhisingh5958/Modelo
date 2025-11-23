import 'package:flutter/foundation.dart';
import '../models/wardrobe_item.dart';
import '../models/outfit.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../services/ai_styling_service.dart';
import '../utils/demo_data.dart';

class WardrobeProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<WardrobeItem> _wardrobeItems = [];
  List<Outfit> _outfits = [];
  List<Outfit> _outfitSuggestions = [];
  UserProfile? _userProfile;
  bool _isLoading = false;

  List<WardrobeItem> get wardrobeItems => _wardrobeItems;
  List<Outfit> get outfits => _outfits;
  List<Outfit> get outfitSuggestions => _outfitSuggestions;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> loadWardrobeItems() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _wardrobeItems = await _databaseService.getAllWardrobeItems();
    } catch (e) {
      debugPrint('Error loading wardrobe items: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWardrobeItem(WardrobeItem item) async {
    try {
      await _databaseService.insertWardrobeItem(item);
      _wardrobeItems.add(item);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding wardrobe item: $e');
    }
  }

  Future<void> updateWardrobeItem(WardrobeItem item) async {
    try {
      await _databaseService.updateWardrobeItem(item);
      int index = _wardrobeItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _wardrobeItems[index] = item;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating wardrobe item: $e');
    }
  }

  Future<void> deleteWardrobeItem(String id) async {
    try {
      await _databaseService.deleteWardrobeItem(id);
      _wardrobeItems.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting wardrobe item: $e');
    }
  }

  Future<void> loadOutfits() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _outfits = await _databaseService.getAllOutfits();
    } catch (e) {
      debugPrint('Error loading outfits: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveOutfit(Outfit outfit) async {
    try {
      await _databaseService.insertOutfit(outfit);
      _outfits.add(outfit);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving outfit: $e');
    }
  }

  Future<void> deleteOutfit(String id) async {
    try {
      await _databaseService.deleteOutfit(id);
      _outfits.removeWhere((outfit) => outfit.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting outfit: $e');
    }
  }

  Future<void> loadUserProfile(String userId) async {
    try {
      _userProfile = await _databaseService.getUserProfile(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      if (_userProfile == null) {
        await _databaseService.insertUserProfile(profile);
      } else {
        await _databaseService.updateUserProfile(profile);
      }
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  void generateOutfitSuggestions({
    required String occasion,
    String? weather,
    int maxSuggestions = 5,
  }) {
    if (_userProfile == null || _wardrobeItems.isEmpty) {
      _outfitSuggestions = [];
      notifyListeners();
      return;
    }

    _outfitSuggestions = AIStylingService.generateOutfitSuggestions(
      wardrobeItems: _wardrobeItems,
      userProfile: _userProfile!,
      occasion: occasion,
      weather: weather,
      maxSuggestions: maxSuggestions,
    );
    
    notifyListeners();
  }

  List<WardrobeItem> getItemsByType(ClothingType type) {
    return _wardrobeItems.where((item) => item.type == type).toList();
  }

  List<WardrobeItem> getItemsById(List<String> ids) {
    return _wardrobeItems.where((item) => ids.contains(item.id)).toList();
  }

  void rateOutfit(String outfitId, int rating) {
    int index = _outfits.indexWhere((outfit) => outfit.id == outfitId);
    if (index != -1) {
      // In a real app, you'd update the database here
      notifyListeners();
    }
  }

  List<String> getStyleTips() {
    if (_userProfile == null) return [];
    return AIStylingService.getStyleTips(_userProfile!);
  }

  Future<void> loadDemoData() async {
    try {
      // Load demo profile
      final demoProfile = DemoData.createDemoProfile();
      await saveUserProfile(demoProfile);
      
      // Load demo wardrobe items
      final demoItems = DemoData.createDemoWardrobe();
      for (final item in demoItems) {
        await addWardrobeItem(item);
      }
      
      // Generate some initial outfit suggestions
      generateOutfitSuggestions(
        occasion: 'casual',
        weather: 'mild',
        maxSuggestions: 3,
      );
      
      debugPrint('Demo data loaded successfully');
    } catch (e) {
      debugPrint('Error loading demo data: $e');
    }
  }
}