import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/wardrobe_provider.dart';
import '../models/user_profile.dart';
import '../utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedGender = 'female';
  String _selectedBodyType = 'hourglass';
  String _selectedSkinUndertone = 'neutral';
  String _selectedFaceShape = 'oval';
  
  List<String> _favoriteColors = [];
  List<String> _dislikedPatterns = [];
  
  final Map<String, String> _measurements = {};

  final List<String> _genders = ['female', 'male', 'non-binary'];
  final List<String> _bodyTypes = ['pear', 'apple', 'hourglass', 'rectangle', 'inverted triangle'];
  final List<String> _skinUndertones = ['warm', 'cool', 'neutral'];
  final List<String> _faceShapes = ['oval', 'round', 'square', 'heart', 'diamond'];
  final List<String> _colors = ['red', 'blue', 'green', 'yellow', 'black', 'white', 'pink', 'purple', 'orange', 'brown'];
  final List<String> _patterns = ['stripes', 'polka dots', 'floral', 'geometric', 'animal print', 'plaid'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().loadUserProfile('default_user');
      _loadProfileData();
    });
  }

  void _loadProfileData() {
    final provider = context.read<WardrobeProvider>();
    final profile = provider.userProfile;
    
    if (profile != null) {
      _nameController.text = profile.name;
      _selectedGender = profile.gender;
      _selectedBodyType = profile.bodyType;
      _selectedSkinUndertone = profile.skinUndertone;
      _selectedFaceShape = profile.faceShape;
      _favoriteColors = List.from(profile.favoriteColors);
      _dislikedPatterns = List.from(profile.dislikedPatterns);
      _measurements.addAll(profile.measurements);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Consumer<WardrobeProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Basic Information',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                            ),
                            items: _genders.map((gender) {
                              return DropdownMenuItem(
                                value: gender,
                                child: Text(gender.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedGender = value!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Body Analysis
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Body Analysis',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            value: _selectedBodyType,
                            decoration: const InputDecoration(
                              labelText: 'Body Type',
                              border: OutlineInputBorder(),
                            ),
                            items: _bodyTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedBodyType = value!),
                          ),
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            value: _selectedSkinUndertone,
                            decoration: const InputDecoration(
                              labelText: 'Skin Undertone',
                              border: OutlineInputBorder(),
                            ),
                            items: _skinUndertones.map((tone) {
                              return DropdownMenuItem(
                                value: tone,
                                child: Text(tone.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedSkinUndertone = value!),
                          ),
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            value: _selectedFaceShape,
                            decoration: const InputDecoration(
                              labelText: 'Face Shape',
                              border: OutlineInputBorder(),
                            ),
                            items: _faceShapes.map((shape) {
                              return DropdownMenuItem(
                                value: shape,
                                child: Text(shape.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedFaceShape = value!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Style Preferences
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Style Preferences',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          
                          const Text('Favorite Colors:'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _colors.map((color) {
                              final isSelected = _favoriteColors.contains(color);
                              return FilterChip(
                                label: Text(color.toUpperCase()),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _favoriteColors.add(color);
                                    } else {
                                      _favoriteColors.remove(color);
                                    }
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: AppColors.secondary.withOpacity(0.2),
                                checkmarkColor: AppColors.secondary,
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                                side: BorderSide(
                                  color: isSelected ? AppColors.secondary : AppColors.border,
                                ),
                                avatar: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _getColorFromName(color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          const Text('Disliked Patterns:'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _patterns.map((pattern) {
                              final isSelected = _dislikedPatterns.contains(pattern);
                              return FilterChip(
                                label: Text(pattern.toUpperCase()),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _dislikedPatterns.add(pattern);
                                    } else {
                                      _dislikedPatterns.remove(pattern);
                                    }
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: AppColors.secondary.withOpacity(0.2),
                                checkmarkColor: AppColors.secondary,
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                                side: BorderSide(
                                  color: isSelected ? AppColors.secondary : AppColors.border,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Style Tips
                  if (provider.userProfile != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Style Tips',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ...provider.getStyleTips().map((tip) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(tip)),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        id: 'default_user',
        name: _nameController.text,
        gender: _selectedGender,
        bodyType: _selectedBodyType,
        skinUndertone: _selectedSkinUndertone,
        faceShape: _selectedFaceShape,
        favoriteColors: _favoriteColors,
        dislikedPatterns: _dislikedPatterns,
        measurements: _measurements,
        stylePreferences: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<WardrobeProvider>().saveUserProfile(profile);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'pink': return Colors.pink;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'brown': return Colors.brown;
      default: return Colors.grey;
    }
  }
}