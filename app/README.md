# Modelo - AI-Powered Wardrobe Manager

A comprehensive Flutter mobile app for managing your wardrobe and getting personalized outfit recommendations using AI styling algorithms.

## Features

### 🎯 Core Functionality
- **Digital Wardrobe Management**: Upload and categorize clothing items with detailed attributes
- **AI Outfit Suggestions**: Get personalized outfit recommendations based on occasion, weather, and personal style
- **User Profile & Preferences**: Complete body analysis, style preferences, and color harmony settings
- **Interactive UI**: Visual outfit boards with drag-and-drop functionality
- **Smart Analytics**: Track clothing usage and get style insights

### 👤 User Profile & Analysis
- Body type assessment (pear, apple, hourglass, rectangle, inverted triangle)
- Skin undertone analysis (warm, cool, neutral)
- Face shape identification
- Personal style preferences and favorite colors
- Measurements tracking

### 👗 Wardrobe Inventory
- Comprehensive item categorization (tops, bottoms, dresses, shoes, accessories)
- Color, pattern, fabric, and fit tracking
- Seasonal categorization
- Rating and usage statistics
- Photo support for visual identification

### 🤖 AI Styling Engine
- Color harmony algorithms
- Body type-specific recommendations
- Occasion-based outfit generation
- Weather-appropriate suggestions
- Style learning from user feedback

### 📱 User Experience
- Clean, intuitive interface
- Bottom navigation for easy access
- Grid and list views for wardrobe items
- Detailed item and outfit views
- Quick stats dashboard

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- iOS Simulator / Android Emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd la_moda
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## App Structure

### Core Modules

#### 1. User Profile & Preferences
- Personal information collection
- Body measurements and analysis
- Style preferences and color choices
- Personalization settings

#### 2. Wardrobe Inventory
- Item management (add, edit, delete)
- Categorization and filtering
- Photo upload and storage
- Usage tracking and ratings

#### 3. AI Styling Engine
- Color harmony analysis
- Body type recommendations
- Outfit generation algorithms
- Style tip generation

#### 4. Outfit Management
- AI-generated suggestions
- Manual outfit creation
- Outfit history and favorites
- Occasion-based filtering

### Technical Architecture

```
lib/
├── models/           # Data models
│   ├── user_profile.dart
│   ├── wardrobe_item.dart
│   └── outfit.dart
├── services/         # Business logic
│   ├── database_service.dart
│   └── ai_styling_service.dart
├── providers/        # State management
│   └── wardrobe_provider.dart
├── screens/          # UI screens
│   ├── home_screen.dart
│   ├── wardrobe_screen.dart
│   ├── outfit_generator_screen.dart
│   └── profile_screen.dart
├── widgets/          # Reusable components
│   ├── wardrobe_item_card.dart
│   ├── outfit_suggestion_card.dart
│   ├── add_item_dialog.dart
│   └── quick_stats_widget.dart
└── main.dart         # App entry point
```

## Usage Guide

### 1. Setting Up Your Profile
1. Navigate to the **Profile** tab
2. Fill in your basic information (name, gender)
3. Complete the body analysis section:
   - Select your body type
   - Choose your skin undertone
   - Identify your face shape
4. Set style preferences:
   - Select favorite colors
   - Choose disliked patterns
5. Save your profile

### 2. Building Your Wardrobe
1. Go to the **Wardrobe** tab
2. Tap the **+** button to add items
3. Fill in item details:
   - Name and type (top, bottom, dress, etc.)
   - Color and pattern
   - Fabric and fit information
   - Season and tags
   - Rate the item (1-5 stars)
4. Save the item to your digital wardrobe

### 3. Getting Outfit Suggestions
1. Navigate to the **Outfits** tab
2. Select an occasion (casual, work, formal, etc.)
3. Optionally choose weather conditions
4. Tap **Generate Suggestions**
5. Browse AI-generated outfit combinations
6. Tap on any outfit to see details
7. Save favorite outfits for future use

### 4. Dashboard Overview
The **Home** tab provides:
- Welcome message with personalization
- Quick wardrobe statistics
- Today's outfit suggestions
- Personalized style tips based on your profile

## AI Styling Features

### Color Harmony Engine
- Analyzes color compatibility between items
- Considers skin undertone for optimal color choices
- Suggests complementary color combinations

### Body Type Recommendations
- **Pear Shape**: Emphasizes upper body, balances proportions
- **Apple Shape**: Creates waist definition, elongates silhouette
- **Hourglass**: Highlights natural curves, maintains balance
- **Rectangle**: Adds curves and visual interest

### Occasion-Based Styling
- **Casual**: Comfortable, relaxed combinations
- **Work**: Professional, polished looks
- **Formal**: Elegant, sophisticated outfits
- **Party**: Fun, trendy, statement pieces

### Weather Adaptation
- **Hot/Sunny**: Light fabrics, breathable materials
- **Cold/Snowy**: Layering options, warm materials
- **Mild/Rainy**: Versatile pieces, weather-appropriate choices

## Future Enhancements

### Planned Features
- **AR Try-On**: Virtual outfit preview using camera
- **Social Sharing**: Share outfits with friends and community
- **Shopping Integration**: Purchase recommendations with direct links
- **Sustainability Tracking**: Monitor garment usage and eco-friendly choices
- **Trend Updates**: Seasonal fashion trends and style tips
- **Advanced Analytics**: Detailed wardrobe insights and optimization

### Technical Improvements
- Cloud synchronization across devices
- Machine learning model improvements
- Enhanced image recognition for automatic item tagging
- Integration with fashion APIs and databases

## Dependencies

### Core Dependencies
- `flutter`: UI framework
- `provider`: State management
- `sqflite`: Local database storage
- `uuid`: Unique identifier generation

### UI & Media
- `flutter_staggered_grid_view`: Grid layouts
- `image_picker`: Photo capture and selection
- `cached_network_image`: Image caching
- `flutter_colorpicker`: Color selection

### Utilities
- `shared_preferences`: Local settings storage
- `path`: File path utilities
- `intl`: Internationalization support

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the code examples

---

**Modelo** - Empowering confident style choices through AI-powered wardrobe management.