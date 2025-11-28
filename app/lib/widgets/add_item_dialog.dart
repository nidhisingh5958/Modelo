import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/wardrobe_item.dart';
import '../providers/wardrobe_provider.dart';
import '../services/image_analysis_service.dart';
import '../widgets/camera_capture_dialog.dart';
import '../utils/app_colors.dart';

class AddItemDialog extends StatefulWidget {
  final WardrobeItem? item;

  const AddItemDialog({super.key, this.item});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();

  static void show(BuildContext context, {WardrobeItem? item}) {
    if (item == null) {
      // Show camera dialog for new items
      showDialog(
        context: context,
        builder: (context) => CameraCaptureDialog(
          onImageSelected: (imageFile) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _ImageAnalysisScreen(imageFile: imageFile),
              ),
            );
          },
        ),
      );
    } else {
      // Show edit dialog for existing items
      showDialog(
        context: context,
        builder: (context) => AddItemDialog(item: item),
      );
    }
  }
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _patternController = TextEditingController();
  final _fabricController = TextEditingController();
  final _fitController = TextEditingController();
  final _tagsController = TextEditingController();

  ClothingType _selectedType = ClothingType.top;
  String _selectedColor = 'black';
  Season _selectedSeason = Season.allSeason;
  int _rating = 0;

  final List<String> _colors = [
    'black', 'white', 'gray', 'navy', 'brown', 'beige',
    'red', 'blue', 'green', 'yellow', 'pink', 'purple', 'orange'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _selectedType = widget.item!.type;
      _selectedColor = widget.item!.color;
      _patternController.text = widget.item!.pattern ?? '';
      _fabricController.text = widget.item!.fabric ?? '';
      _fitController.text = widget.item!.fit ?? '';
      _selectedSeason = widget.item!.season;
      _tagsController.text = widget.item!.tags.join(', ');
      _rating = widget.item!.rating;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.item == null ? 'Add New Item' : 'Edit Item',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an item name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<ClothingType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: ClothingType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedType = value!),
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedColor,
                        decoration: InputDecoration(
                          labelText: 'Color',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        items: _colors.map((color) {
                          return DropdownMenuItem(
                            value: color,
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _getColorFromName(color),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(color.toUpperCase()),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedColor = value!),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _patternController,
                        decoration: const InputDecoration(
                          labelText: 'Pattern (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _fabricController,
                        decoration: const InputDecoration(
                          labelText: 'Fabric (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _fitController,
                        decoration: const InputDecoration(
                          labelText: 'Fit (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<Season>(
                        value: _selectedSeason,
                        decoration: const InputDecoration(
                          labelText: 'Season',
                          border: OutlineInputBorder(),
                        ),
                        items: Season.values.map((season) {
                          return DropdownMenuItem(
                            value: season,
                            child: Text(season.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedSeason = value!),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags (comma separated)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rating:'),
                          Row(
                            children: List.generate(5, (index) {
                              return IconButton(
                                onPressed: () => setState(() => _rating = index + 1),
                                icon: Icon(
                                  index < _rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.item == null ? 'Add' : 'Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final item = WardrobeItem(
        id: widget.item?.id ?? const Uuid().v4(),
        name: _nameController.text,
        type: _selectedType,
        color: _selectedColor,
        pattern: _patternController.text.isEmpty ? null : _patternController.text,
        fabric: _fabricController.text.isEmpty ? null : _fabricController.text,
        fit: _fitController.text.isEmpty ? null : _fitController.text,
        season: _selectedSeason,
        tags: tags,
        rating: _rating,
        wearCount: widget.item?.wearCount ?? 0,
        lastWorn: widget.item?.lastWorn ?? DateTime.now(),
        createdAt: widget.item?.createdAt ?? DateTime.now(),
      );

      if (widget.item == null) {
        context.read<WardrobeProvider>().addWardrobeItem(item);
      } else {
        context.read<WardrobeProvider>().updateWardrobeItem(item);
      }

      Navigator.pop(context);
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
      case 'gray': case 'grey': return Colors.grey;
      case 'brown': return Colors.brown;
      case 'pink': return Colors.pink;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'navy': return Colors.indigo;
      case 'beige': return const Color(0xFFF5F5DC);
      default: return Colors.grey[300]!;
    }
  }
}

class _ImageAnalysisScreen extends StatefulWidget {
  final File imageFile;

  const _ImageAnalysisScreen({required this.imageFile});

  @override
  State<_ImageAnalysisScreen> createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends State<_ImageAnalysisScreen> {
  bool _isAnalyzing = true;
  Map<String, dynamic>? _analysisResult;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _patternController;
  late TextEditingController _fabricController;
  late TextEditingController _fitController;
  late TextEditingController _tagsController;
  
  ClothingType _selectedType = ClothingType.top;
  String _selectedColor = 'black';
  Season _selectedSeason = Season.allSeason;
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
    _nameController = TextEditingController();
    _patternController = TextEditingController();
    _fabricController = TextEditingController();
    _fitController = TextEditingController();
    _tagsController = TextEditingController();
  }

  Future<void> _analyzeImage() async {
    try {
      final result = await ImageAnalysisService.analyzeClothingImage(widget.imageFile);
      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
        
        // Populate form with AI results
        _nameController.text = result['name'] ?? '';
        _selectedType = result['type'] ?? ClothingType.top;
        _selectedColor = result['color'] ?? 'black';
        _patternController.text = result['pattern'] ?? '';
        _fabricController.text = result['fabric'] ?? '';
        _fitController.text = result['fit'] ?? '';
        _selectedSeason = result['season'] ?? Season.allSeason;
        _tagsController.text = (result['tags'] as List<String>?)?.join(', ') ?? '';
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Item Analysis'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isAnalyzing ? _buildAnalyzingView() : _buildResultView(),
    );
  }

  Widget _buildAnalyzingView() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(widget.imageFile),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Analyzing your clothing item...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI is detecting colors, patterns, and fabric details',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final confidence = (_analysisResult?['confidence'] ?? 0.0) * 100;
    
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image and analysis results
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(widget.imageFile),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: confidence > 70 ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Confidence: ${confidence.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: confidence > 70 ? AppColors.success : AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_analysisResult?['secondaryColors'] != null) ..[
                                const Text('Detected Colors:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  children: (_analysisResult!['secondaryColors'] as List<String>)
                                      .take(3)
                                      .map((color) => Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: _getColorFromName(color),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.border),
                                        ),
                                      ))
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_analysisResult?['suggestions'] != null) ..[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Suggestions:',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            ...(_analysisResult!['suggestions'] as List<String>)
                                .take(2)
                                .map((suggestion) => Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    '• $suggestion',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'Review & Edit Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Enhanced form fields with AI-detected values
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: const OutlineInputBorder(),
                  suffixIcon: _analysisResult?['name'] != null 
                    ? const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 16)
                    : null,
                ),
                validator: (value) => value?.isEmpty == true ? 'Please enter a name' : null,
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ClothingType>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        border: const OutlineInputBorder(),
                        suffixIcon: _analysisResult?['type'] != null 
                          ? const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 16)
                          : null,
                      ),
                      items: ClothingType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedType = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedColor,
                      decoration: InputDecoration(
                        labelText: 'Color',
                        border: const OutlineInputBorder(),
                        suffixIcon: _analysisResult?['color'] != null 
                          ? const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 16)
                          : null,
                      ),
                      items: ['black', 'white', 'gray', 'navy', 'brown', 'beige', 'red', 'blue', 'green', 'yellow', 'pink', 'purple', 'orange']
                          .map((color) => DropdownMenuItem(
                            value: color,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _getColorFromName(color),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(color.toUpperCase()),
                              ],
                            ),
                          ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedColor = value!),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _patternController,
                      decoration: InputDecoration(
                        labelText: 'Pattern',
                        border: const OutlineInputBorder(),
                        suffixIcon: _analysisResult?['pattern'] != null 
                          ? const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 16)
                          : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _fabricController,
                      decoration: InputDecoration(
                        labelText: 'Fabric',
                        border: const OutlineInputBorder(),
                        suffixIcon: _analysisResult?['fabric'] != null 
                          ? const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 16)
                          : null,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Item'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final item = WardrobeItem(
        id: const Uuid().v4(),
        name: _nameController.text,
        type: _selectedType,
        color: _selectedColor,
        pattern: _patternController.text.isEmpty ? null : _patternController.text,
        fabric: _fabricController.text.isEmpty ? null : _fabricController.text,
        fit: _fitController.text.isEmpty ? null : _fitController.text,
        season: _selectedSeason,
        imagePath: widget.imageFile.path,
        tags: _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
        rating: _rating,
        wearCount: 0,
        lastWorn: DateTime.now(),
        createdAt: DateTime.now(),
      );

      context.read<WardrobeProvider>().addWardrobeItem(item);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added with ${(_analysisResult?['confidence'] * 100 ?? 0).toStringAsFixed(0)}% AI confidence!'),
          backgroundColor: AppColors.success,
        ),
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
      case 'gray': case 'grey': return Colors.grey;
      case 'brown': return Colors.brown;
      case 'pink': return Colors.pink;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'navy': return Colors.indigo;
      case 'beige': return const Color(0xFFF5F5DC);
      default: return Colors.grey[300]!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _patternController.dispose();
    _fabricController.dispose();
    _fitController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}