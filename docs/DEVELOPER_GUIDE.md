# Modelo - Developer Guide

## 👨‍💻 Development Overview

This guide provides comprehensive information for developers working on the Modelo project, including architecture patterns, coding standards, and best practices.

## 🏗️ Project Structure

### Repository Organization
```
modelo/
├── app/                    # Flutter mobile application
│   ├── lib/
│   │   ├── models/         # Data models and entities
│   │   ├── services/       # Business logic and AI services
│   │   ├── providers/      # State management
│   │   ├── screens/        # UI screens and pages
│   │   ├── widgets/        # Reusable UI components
│   │   ├── utils/          # Utilities and helpers
│   │   └── main.dart       # Application entry point
│   ├── test/               # Unit and widget tests
│   ├── android/            # Android-specific configuration
│   ├── ios/                # iOS-specific configuration
│   └── pubspec.yaml        # Flutter dependencies
├── backend/                # Python FastAPI backend
│   ├── api/                # API endpoints and routes
│   ├── ml_models/          # Machine learning models
│   ├── data/               # Data storage and processing
│   └── requirements.txt    # Python dependencies
├── website/                # Marketing website
│   ├── index.html          # Main website page
│   ├── styles.css          # Website styling
│   └── script.js           # Website functionality
├── docs/                   # Project documentation
└── README.md               # Project overview
```

## 📱 Flutter Development

### Architecture Pattern

Modelo follows a **Clean Architecture** approach with clear separation of concerns:

```
Presentation Layer (UI)
├── Screens (Pages)
├── Widgets (Components)
└── Providers (State Management)

Business Logic Layer
├── Services (Core Logic)
├── AI Models (Intelligence)
└── Utils (Helpers)

Data Layer
├── Models (Entities)
├── Database (Local Storage)
└── API (Remote Data)
```

### State Management

#### Provider Pattern Implementation
```dart
// Provider setup in main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => WardrobeProvider()),
    ChangeNotifierProvider(create: (_) => ProfileProvider()),
    ChangeNotifierProvider(create: (_) => OutfitProvider()),
  ],
  child: MyApp(),
)

// Provider usage in widgets
Consumer<WardrobeProvider>(
  builder: (context, wardrobeProvider, child) {
    return ListView.builder(
      itemCount: wardrobeProvider.items.length,
      itemBuilder: (context, index) {
        return WardrobeItemCard(item: wardrobeProvider.items[index]);
      },
    );
  },
)
```

#### State Management Best Practices
- **Single Source of Truth**: Use providers for centralized state
- **Immutable State**: Create new objects instead of modifying existing ones
- **Selective Rebuilds**: Use `Consumer` and `Selector` for efficient updates
- **Error Handling**: Implement proper error states in providers

### Data Models

#### Model Structure
```dart
class WardrobeItem {
  final String id;
  final String name;
  final ClothingType type;
  final String color;
  final String? pattern;
  final String? fabric;
  final String? fit;
  final Season season;
  final List<String> tags;
  final int rating;
  final int wearCount;
  final DateTime lastWorn;
  final DateTime createdAt;

  WardrobeItem({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    this.pattern,
    this.fabric,
    this.fit,
    required this.season,
    required this.tags,
    this.rating = 0,
    this.wearCount = 0,
    required this.lastWorn,
    required this.createdAt,
  });

  // Serialization methods
  Map<String, dynamic> toMap() { /* ... */ }
  factory WardrobeItem.fromMap(Map<String, dynamic> map) { /* ... */ }
  
  // Copy method for immutable updates
  WardrobeItem copyWith({ /* parameters */ }) { /* ... */ }
}
```

#### Model Guidelines
- **Immutability**: Use `final` fields and `copyWith` methods
- **Serialization**: Implement `toMap()` and `fromMap()` for database storage
- **Validation**: Add validation in constructors or factory methods
- **Documentation**: Document all fields and methods

### Service Layer

#### Service Structure
```dart
class AIStylingService {
  // Static methods for stateless operations
  static List<Outfit> generateOutfitSuggestions({
    required List<WardrobeItem> wardrobeItems,
    required UserProfile userProfile,
    required String occasion,
    String? weather,
    int maxSuggestions = 5,
  }) {
    // Implementation
  }

  // Private helper methods
  static bool _areColorsCompatible(String color1, String color2) {
    // Implementation
  }
}
```

#### Service Guidelines
- **Single Responsibility**: Each service handles one domain
- **Static Methods**: Use for stateless operations
- **Error Handling**: Wrap operations in try-catch blocks
- **Logging**: Add logging for debugging and monitoring
- **Testing**: Write unit tests for all service methods

### Database Layer

#### SQLite Implementation
```dart
class DatabaseService {
  static Database? _database;
  
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'modelo.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wardrobe_items(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type INTEGER NOT NULL,
        color TEXT NOT NULL,
        pattern TEXT,
        fabric TEXT,
        fit TEXT,
        season INTEGER NOT NULL,
        tags TEXT,
        rating INTEGER DEFAULT 0,
        wearCount INTEGER DEFAULT 0,
        lastWorn INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');
  }
}
```

#### Database Guidelines
- **Migrations**: Plan for schema changes with version management
- **Indexes**: Add indexes for frequently queried columns
- **Transactions**: Use transactions for multi-table operations
- **Connection Management**: Properly manage database connections
- **Backup**: Implement data export/import functionality

### UI Development

#### Widget Structure
```dart
class WardrobeItemCard extends StatelessWidget {
  final WardrobeItem item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WardrobeItemCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 8),
              _buildContent(),
              SizedBox(height: 8),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() { /* ... */ }
  Widget _buildContent() { /* ... */ }
  Widget _buildActions() { /* ... */ }
}
```

#### UI Guidelines
- **Reusability**: Create reusable widgets for common UI patterns
- **Composition**: Prefer composition over inheritance
- **Responsiveness**: Design for different screen sizes
- **Accessibility**: Add semantic labels and proper contrast
- **Performance**: Use `const` constructors where possible

### Testing Strategy

#### Unit Tests
```dart
// test/services/ai_styling_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:modelo/services/ai_styling_service.dart';
import 'package:modelo/models/wardrobe_item.dart';
import 'package:modelo/models/user_profile.dart';

void main() {
  group('AIStylingService', () {
    test('should generate outfit suggestions', () {
      // Arrange
      final wardrobeItems = [/* test data */];
      final userProfile = UserProfile(/* test data */);
      
      // Act
      final suggestions = AIStylingService.generateOutfitSuggestions(
        wardrobeItems: wardrobeItems,
        userProfile: userProfile,
        occasion: 'work',
      );
      
      // Assert
      expect(suggestions, isNotEmpty);
      expect(suggestions.length, lessThanOrEqualTo(5));
    });
  });
}
```

#### Widget Tests
```dart
// test/widgets/wardrobe_item_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modelo/widgets/wardrobe_item_card.dart';
import 'package:modelo/models/wardrobe_item.dart';

void main() {
  testWidgets('WardrobeItemCard displays item information', (tester) async {
    // Arrange
    final item = WardrobeItem(/* test data */);
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WardrobeItemCard(item: item),
        ),
      ),
    );
    
    // Assert
    expect(find.text(item.name), findsOneWidget);
    expect(find.text(item.color), findsOneWidget);
  });
}
```

#### Testing Guidelines
- **Coverage**: Aim for 80%+ code coverage
- **Test Pyramid**: More unit tests, fewer integration tests
- **Mocking**: Use mocks for external dependencies
- **Test Data**: Create reusable test data factories
- **CI/CD**: Run tests automatically on commits

## 🐍 Backend Development

### FastAPI Structure

#### API Organization
```python
# api/main.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(
    title="Modelo API",
    description="AI-Powered Wardrobe Management API",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models
class WardrobeItem(BaseModel):
    id: str
    name: str
    type: str
    color: str
    pattern: Optional[str] = None
    # ... other fields

class OutfitRequest(BaseModel):
    wardrobeItems: List[WardrobeItem]
    userProfile: UserProfile
    occasion: str
    weather: Optional[str] = None
    maxSuggestions: int = 5

# API endpoints
@app.post("/api/recommendations/outfits")
async def get_outfit_recommendations(request: OutfitRequest):
    try:
        # Process request
        recommendations = recommender.generate_outfit_recommendations(
            wardrobe_items=[item.dict() for item in request.wardrobeItems],
            user_profile=request.userProfile.dict(),
            occasion=request.occasion,
            weather=request.weather,
            max_suggestions=request.maxSuggestions
        )
        return recommendations
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

#### Backend Guidelines
- **Type Hints**: Use type hints for all functions and variables
- **Pydantic Models**: Use Pydantic for request/response validation
- **Error Handling**: Implement comprehensive error handling
- **Documentation**: Use FastAPI's automatic documentation
- **Logging**: Add structured logging for debugging

### Machine Learning Models

#### Model Structure
```python
# ml_models/outfit_recommender.py
import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

class OutfitRecommender:
    def __init__(self):
        self.color_harmony = {
            'red': ['white', 'black', 'navy', 'beige', 'gray'],
            'blue': ['white', 'beige', 'gray', 'navy', 'brown'],
            # ... more color rules
        }
        
        self.body_type_rules = {
            'pear': {
                'emphasize': ['tops', 'upper_body'],
                'colors_top': ['bright', 'light'],
                'colors_bottom': ['dark', 'neutral'],
            },
            # ... more body type rules
        }

    def generate_outfit_recommendations(self, wardrobe_items, user_profile, 
                                      occasion='casual', weather=None, max_suggestions=5):
        """Generate outfit recommendations using ML algorithms"""
        # Implementation
        pass

    def calculate_color_compatibility(self, color1, color2):
        """Calculate compatibility score between two colors"""
        # Implementation
        pass
```

#### ML Guidelines
- **Model Versioning**: Version your models for reproducibility
- **Data Validation**: Validate input data before processing
- **Performance**: Optimize for real-time inference
- **Monitoring**: Track model performance and accuracy
- **Updates**: Plan for model updates and retraining

## 🌐 Website Development

### HTML Structure
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modelo - AI-Powered Personal Styling Assistant</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <!-- Navigation content -->
    </nav>
    
    <!-- Main content sections -->
    <main>
        <section id="hero" class="hero">
            <!-- Hero content -->
        </section>
        
        <section id="features" class="features">
            <!-- Features content -->
        </section>
    </main>
    
    <script src="script.js"></script>
</body>
</html>
```

### CSS Organization
```css
/* styles.css */

/* Reset and base styles */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

/* CSS Custom Properties */
:root {
    --primary-color: #6366f1;
    --secondary-color: #8b5cf6;
    --text-color: #1e293b;
    --background-color: #ffffff;
    --border-radius: 12px;
    --box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

/* Component styles */
.navbar { /* ... */ }
.hero { /* ... */ }
.features { /* ... */ }

/* Responsive design */
@media (max-width: 768px) {
    /* Mobile styles */
}
```

### JavaScript Functionality
```javascript
// script.js

// Smooth scrolling
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({ behavior: 'smooth' });
        }
    });
});

// Interactive demo tabs
function initializeDemoTabs() {
    const tabs = document.querySelectorAll('.demo-tab');
    const panels = document.querySelectorAll('.demo-panel');
    
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            // Remove active class from all tabs and panels
            tabs.forEach(t => t.classList.remove('active'));
            panels.forEach(p => p.classList.remove('active'));
            
            // Add active class to clicked tab and corresponding panel
            tab.classList.add('active');
            const targetPanel = document.getElementById(tab.dataset.tab);
            if (targetPanel) {
                targetPanel.classList.add('active');
            }
        });
    });
}

// Initialize on DOM load
document.addEventListener('DOMContentLoaded', initializeDemoTabs);
```

## 🔧 Development Tools

### Code Quality

#### Linting Configuration
```yaml
# analysis_options.yaml (Flutter)
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - prefer_single_quotes
    - require_trailing_commas
```

#### Pre-commit Hooks
```bash
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/psf/black
    rev: 22.3.0
    hooks:
      - id: black
        language_version: python3
  
  - repo: https://github.com/pycqa/flake8
    rev: 4.0.1
    hooks:
      - id: flake8
```

### Debugging

#### Flutter Debugging
```dart
// Debug logging
import 'dart:developer' as developer;

void debugLog(String message, {String name = 'Modelo'}) {
  developer.log(message, name: name);
}

// Error handling
try {
  // Risky operation
} catch (e, stackTrace) {
  debugLog('Error: $e\nStack trace: $stackTrace');
  // Handle error appropriately
}
```

#### Backend Debugging
```python
# Python logging
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

def debug_function():
    logger.info("Function called")
    try:
        # Risky operation
        pass
    except Exception as e:
        logger.error(f"Error occurred: {e}", exc_info=True)
```

## 🚀 Deployment

### Flutter App Deployment

#### Android Release
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### iOS Release
```bash
# Build iOS release
flutter build ios --release

# Archive for App Store
# Use Xcode for final archive and upload
```

### Backend Deployment

#### Docker Configuration
```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Production Configuration
```python
# Production settings
import os

# Environment variables
DATABASE_URL = os.getenv("DATABASE_URL")
SECRET_KEY = os.getenv("SECRET_KEY")
DEBUG = os.getenv("DEBUG", "False").lower() == "true"

# CORS for production
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "").split(",")
```

## 📊 Performance Optimization

### Flutter Performance
- **Widget Rebuilds**: Use `const` constructors and `RepaintBoundary`
- **List Performance**: Use `ListView.builder` for large lists
- **Image Optimization**: Compress images and use appropriate formats
- **Memory Management**: Dispose controllers and streams properly

### Backend Performance
- **Database Optimization**: Use indexes and optimize queries
- **Caching**: Implement Redis for frequently accessed data
- **Async Operations**: Use async/await for I/O operations
- **Load Balancing**: Use multiple workers for production

## 🔒 Security Considerations

### Flutter Security
- **Data Storage**: Use secure storage for sensitive data
- **Network Security**: Implement certificate pinning
- **Code Obfuscation**: Obfuscate release builds
- **Input Validation**: Validate all user inputs

### Backend Security
- **Authentication**: Implement JWT or OAuth2
- **Input Validation**: Use Pydantic for request validation
- **CORS**: Configure CORS properly for production
- **Rate Limiting**: Implement rate limiting for API endpoints

## 📚 Contributing Guidelines

### Code Style
- **Flutter**: Follow Dart style guide and use `dart format`
- **Python**: Follow PEP 8 and use Black formatter
- **JavaScript**: Use ESLint and Prettier
- **Documentation**: Document all public APIs and complex logic

### Git Workflow
```bash
# Feature branch workflow
git checkout -b feature/new-feature
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
# Create pull request
```

### Commit Messages
```
feat: add new feature
fix: resolve bug in outfit generation
docs: update API documentation
style: format code according to style guide
refactor: improve code structure
test: add unit tests for service layer
```

---

This developer guide provides the foundation for contributing to the Modelo project. Follow these guidelines to maintain code quality, consistency, and project standards.