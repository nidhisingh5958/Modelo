import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import '../models/wardrobe_item.dart';

class QuickStatsWidget extends StatelessWidget {
  const QuickStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WardrobeProvider>(
      builder: (context, provider, child) {
        final totalItems = provider.wardrobeItems.length;
        final topCount = provider.getItemsByType(ClothingType.top).length;
        final bottomCount = provider.getItemsByType(ClothingType.bottom).length;
        final dressCount = provider.getItemsByType(ClothingType.dress).length;
        final shoeCount = provider.getItemsByType(ClothingType.shoes).length;
        final totalOutfits = provider.outfits.length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wardrobe Stats',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.checkroom,
                        label: 'Total Items',
                        value: totalItems.toString(),
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.auto_awesome,
                        label: 'Outfits',
                        value: totalOutfits.toString(),
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.checkroom,
                        label: 'Tops',
                        value: topCount.toString(),
                        color: Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.checkroom,
                        label: 'Bottoms',
                        value: bottomCount.toString(),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.checkroom,
                        label: 'Dresses',
                        value: dressCount.toString(),
                        color: Colors.pink,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.directions_walk,
                        label: 'Shoes',
                        value: shoeCount.toString(),
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}