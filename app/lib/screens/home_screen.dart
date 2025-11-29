import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:badges/badges.dart' as badges;
import '../providers/wardrobe_provider.dart';
import '../widgets/outfit_suggestion_card.dart';
import '../widgets/quick_stats_widget.dart';
import '../models/wardrobe_item.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import 'wardrobe_screen.dart';
import 'outfit_generator_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const WardrobeScreen(),
    const OutfitGeneratorScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: badges.Badge(
                badgeContent: Consumer<WardrobeProvider>(
                  builder: (context, provider, child) => Text(
                    '${provider.wardrobeItems.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                child: const Icon(Icons.checkroom_outlined),
              ),
              activeIcon: const Icon(Icons.checkroom),
              label: 'Wardrobe',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: 'Outfits',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Modelo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<WardrobeProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back${provider.userProfile?.name != null ? ', ${provider.userProfile!.name}' : ''}!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text('Ready to look amazing today?'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Quick stats
                const QuickStatsWidget(),
                
                const SizedBox(height: 16),
                
                // Search bar
                ModernCard(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(4),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search your wardrobe...',
                      hintStyle: TextStyle(color: AppColors.textLight),
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                
                // Demo data option (show only if wardrobe is empty)
                if (provider.wardrobeItems.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, size: 32, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Get Started with AI Styling',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Load sample wardrobe items and discover personalized outfit recommendations',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadDemoData(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.secondary,
                          ),
                          child: const Text('Load Demo Data'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Categories section
                if (provider.wardrobeItems.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shop by Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF232F3E),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryCard('Tops', Icons.checkroom, provider.getItemsByType(ClothingType.top).length),
                        _buildCategoryCard('Bottoms', Icons.checkroom, provider.getItemsByType(ClothingType.bottom).length),
                        _buildCategoryCard('Dresses', Icons.checkroom, provider.getItemsByType(ClothingType.dress).length),
                        _buildCategoryCard('Shoes', Icons.directions_walk, provider.getItemsByType(ClothingType.shoes).length),
                        _buildCategoryCard('Accessories', Icons.watch, provider.getItemsByType(ClothingType.accessory).length),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Today's suggestions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AI Outfit Suggestions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF232F3E),
                      ),
                    ),
                    if (provider.outfitSuggestions.isNotEmpty)
                      TextButton(
                        onPressed: () {},
                        child: const Text('View all'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (provider.outfitSuggestions.isEmpty && provider.wardrobeItems.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 48),
                          const SizedBox(height: 8),
                          const Text('No suggestions yet'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              await provider.generateOutfitSuggestions(
                                occasion: 'casual',
                                weather: 'mild',
                              );
                            },
                            child: const Text('Generate Suggestions'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (provider.wardrobeItems.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.checkroom_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          const Text('Add items to get suggestions'),
                          const SizedBox(height: 8),
                          const Text(
                            'Build your wardrobe first to receive personalized outfit recommendations',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (provider.outfitSuggestions.isNotEmpty)
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.85),
                      itemCount: provider.outfitSuggestions.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: OutfitSuggestionCard(
                            outfit: provider.outfitSuggestions[index],
                            wardrobeItems: provider.wardrobeItems,
                          ),
                        );
                      },
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                const SizedBox(height: 24),
                
                // Style tips
                if (provider.userProfile != null) ...[
                  const Text(
                    'Personalized Style Tips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF232F3E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...provider.getStyleTips().map((tip) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9900).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFFFF9900),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCategoryCard(String title, IconData icon, int count) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF232F3E), size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Wardrobe'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Search for items...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}