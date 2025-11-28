import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/outfit_suggestion_card.dart';
import '../models/wardrobe_item.dart';
import '../utils/app_colors.dart';

class OutfitGeneratorScreen extends StatefulWidget {
  const OutfitGeneratorScreen({super.key});

  @override
  State<OutfitGeneratorScreen> createState() => _OutfitGeneratorScreenState();
}

class _OutfitGeneratorScreenState extends State<OutfitGeneratorScreen> {
  String _selectedOccasion = 'casual';
  String? _selectedWeather;

  final List<String> _occasions = [
    'casual', 'work', 'formal', 'party', 'date', 'workout', 'travel'
  ];

  final List<String> _weatherOptions = [
    'hot', 'warm', 'mild', 'cool', 'cold', 'rainy', 'snowy'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Generator'),

      ),
      body: Consumer<WardrobeProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Generation controls
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generate Outfits',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<String>(
                          value: _selectedOccasion,
                          decoration: const InputDecoration(
                            labelText: 'Occasion',
                            border: OutlineInputBorder(),
                          ),
                          items: _occasions.map((occasion) {
                            return DropdownMenuItem(
                              value: occasion,
                              child: Text(occasion.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedOccasion = value!),
                        ),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<String?>(
                          value: _selectedWeather,
                          decoration: const InputDecoration(
                            labelText: 'Weather (optional)',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Any')),
                            ..._weatherOptions.map((weather) {
                              return DropdownMenuItem(
                                value: weather,
                                child: Text(weather.toUpperCase()),
                              );
                            }),
                          ],
                          onChanged: (value) => setState(() => _selectedWeather = value),
                        ),
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: provider.wardrobeItems.isEmpty
                                ? null
                                : () {
                                    provider.generateOutfitSuggestions(
                                      occasion: _selectedOccasion,
                                      weather: _selectedWeather,
                                      maxSuggestions: 6,
                                    );
                                  },
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Generate Suggestions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Suggestions
                if (provider.wardrobeItems.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.checkroom_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Add items to your wardrobe first',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You need clothing items before we can generate outfit suggestions',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (provider.outfitSuggestions.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No suggestions yet',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Click "Generate Suggestions" to get AI-powered outfit ideas',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Suggestions for ${_selectedOccasion.toUpperCase()}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${provider.outfitSuggestions.length} outfits',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: provider.outfitSuggestions.length,
                    itemBuilder: (context, index) {
                      final outfit = provider.outfitSuggestions[index];
                      return GestureDetector(
                        onTap: () => _showOutfitDetails(context, outfit, provider),
                        child: OutfitSuggestionCard(
                          outfit: outfit,
                          wardrobeItems: provider.wardrobeItems,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOutfitDetails(BuildContext context, outfit, WardrobeProvider provider) {
    final outfitItems = provider.getItemsById(outfit.itemIds);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  outfit.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                
                Text(
                  'For ${outfit.occasion.toUpperCase()}${outfit.weather != null ? ' • ${outfit.weather!.toUpperCase()}' : ''}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: outfitItems.length,
                    itemBuilder: (context, index) {
                      final item = outfitItems[index];
                      return Card(
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getColorFromName(item.color),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getIconForType(item.type),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(item.name),
                          subtitle: Text('${item.type.name.toUpperCase()} • ${item.color}'),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          provider.saveOutfit(outfit);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Outfit saved!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save Outfit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
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

  IconData _getIconForType(ClothingType type) {
    switch (type) {
      case ClothingType.top:
        return Icons.checkroom;
      case ClothingType.bottom:
        return Icons.checkroom;
      case ClothingType.dress:
        return Icons.checkroom;
      case ClothingType.outerwear:
        return Icons.checkroom;
      case ClothingType.shoes:
        return Icons.directions_walk;
      case ClothingType.accessory:
        return Icons.watch;
    }
  }
}