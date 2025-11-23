import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wardrobe_provider.dart';
import '../models/wardrobe_item.dart';
import '../widgets/wardrobe_item_card.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/shimmer_loading.dart';
import '../utils/app_colors.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  ClothingType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().loadWardrobeItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', null),
                ...ClothingType.values.map((type) => _buildFilterChip(
                  type.name.toUpperCase(),
                  type,
                )),
              ],
            ),
          ),
          Expanded(
            child: Consumer<WardrobeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemCount: 6,
                      itemBuilder: (context, index) => const ShimmerCard(),
                    ),
                  );
                }

                List<WardrobeItem> items = _selectedFilter == null
                    ? provider.wardrobeItems
                    : provider.getItemsByType(_selectedFilter!);

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.checkroom_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _selectedFilter == null ? 'Your wardrobe is empty' : 'No ${_selectedFilter!.name}s found',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF232F3E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFilter == null ? 'Add your first item to get started' : 'Try a different filter or add new items',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => AddItemDialog.show(context),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return WardrobeItemCard(
                        item: items[index],
                        onTap: () => _showItemDetails(context, items[index]),
                        onEdit: () => _showEditItemDialog(context, items[index]),
                        onDelete: () => _confirmDelete(context, items[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddItemDialog.show(context),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }



  void _showEditItemDialog(BuildContext context, WardrobeItem item) {
    AddItemDialog.show(context, item: item);
  }

  void _showItemDetails(BuildContext context, WardrobeItem item) {
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
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (item.imagePath != null)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(item.imagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Type', item.type.name.toUpperCase()),
                  _buildDetailRow('Color', item.color),
                  if (item.pattern != null) _buildDetailRow('Pattern', item.pattern!),
                  if (item.fabric != null) _buildDetailRow('Fabric', item.fabric!),
                  if (item.fit != null) _buildDetailRow('Fit', item.fit!),
                  _buildDetailRow('Season', item.season.name.toUpperCase()),
                  _buildDetailRow('Rating', '${item.rating}/5 ⭐'),
                  _buildDetailRow('Worn', '${item.wearCount} times'),
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: item.tags.map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.grey[200],
                      )).toList(),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WardrobeItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WardrobeProvider>().deleteWardrobeItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, ClothingType? type) {
    final isSelected = _selectedFilter == type;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => setState(() => _selectedFilter = selected ? type : null),
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
      ),
    );
  }
  
  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort by',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Rating'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Recently Added'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Most Worn'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Name'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}