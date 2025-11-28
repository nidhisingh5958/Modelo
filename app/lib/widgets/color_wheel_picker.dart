import 'package:flutter/material.dart';
import 'dart:math' as math;

class ColorWheelPicker extends StatefulWidget {
  final Function(Color, String) onColorSelected;
  final Color? initialColor;

  const ColorWheelPicker({
    Key? key,
    required this.onColorSelected,
    this.initialColor,
  }) : super(key: key);

  @override
  State<ColorWheelPicker> createState() => _ColorWheelPickerState();
}

class _ColorWheelPickerState extends State<ColorWheelPicker> {
  Color selectedColor = Colors.red;
  
  final Map<String, Color> fashionColors = {
    'red': Colors.red,
    'blue': Colors.blue,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'black': Colors.black,
    'white': Colors.white,
    'gray': Colors.grey,
    'navy': const Color(0xFF000080),
    'brown': Colors.brown,
    'beige': const Color(0xFFF5F5DC),
    'burgundy': const Color(0xFF800020),
    'olive': const Color(0xFF808000),
    'coral': const Color(0xFFFF7F50),
    'teal': Colors.teal,
    'mint': const Color(0xFF98FB98),
    'cream': const Color(0xFFFFFDD0),
  };

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor ?? Colors.red;
  }

  String _getColorName(Color color) {
    for (var entry in fashionColors.entries) {
      if (entry.value.value == color.value) {
        return entry.key;
      }
    }
    return 'custom';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selected color display
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: selectedColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 2),
          ),
        ),
        const SizedBox(height: 16),
        
        // Fashion color grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: fashionColors.length,
          itemBuilder: (context, index) {
            final entry = fashionColors.entries.elementAt(index);
            final isSelected = selectedColor.value == entry.value.value;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = entry.value;
                });
                widget.onColorSelected(entry.value, entry.key);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: entry.value,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: entry.key == 'white' 
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                    )
                  : null,
              ),
            );
          },
        ),
      ],
    );
  }
}

class ColorCompatibilityWidget extends StatefulWidget {
  const ColorCompatibilityWidget({Key? key}) : super(key: key);

  @override
  State<ColorCompatibilityWidget> createState() => _ColorCompatibilityWidgetState();
}

class _ColorCompatibilityWidgetState extends State<ColorCompatibilityWidget> {
  Color color1 = Colors.red;
  Color color2 = Colors.blue;
  String colorName1 = 'red';
  String colorName2 = 'blue';
  double? compatibilityScore;
  bool? isCompatible;

  Future<void> _testCompatibility() async {
    // This would call your API endpoint
    // For now, using a simple mock calculation
    setState(() {
      compatibilityScore = 0.75; // Mock score
      isCompatible = compatibilityScore! >= 0.6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Compatibility'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Color 1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ColorWheelPicker(
                        initialColor: color1,
                        onColorSelected: (color, name) {
                          setState(() {
                            color1 = color;
                            colorName1 = name;
                            compatibilityScore = null;
                            isCompatible = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Color 2', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ColorWheelPicker(
                        initialColor: color2,
                        onColorSelected: (color, name) {
                          setState(() {
                            color2 = color;
                            colorName2 = name;
                            compatibilityScore = null;
                            isCompatible = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _testCompatibility,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Test Compatibility', style: TextStyle(fontSize: 16)),
            ),
            
            const SizedBox(height: 24),
            
            if (compatibilityScore != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCompatible! ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompatible! ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      isCompatible! ? '✅ Compatible!' : '❌ Not Compatible',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isCompatible! ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Colors: $colorName1 + $colorName2',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Compatibility Score: ${(compatibilityScore! * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}