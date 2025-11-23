# Modelo - API Documentation

## 🔗 API Overview

The Modelo backend provides a RESTful API built with FastAPI that serves AI-powered styling recommendations and analysis services.

**Base URL**: `http://localhost:8000`
**API Version**: v1.0.0
**Content-Type**: `application/json`

## 📡 API Endpoints

### Health Check

#### GET `/`
Basic health check endpoint.

**Response:**
```json
{
  "message": "Modelo API is running"
}
```

#### GET `/health`
Detailed health check with service status.

**Response:**
```json
{
  "status": "healthy",
  "service": "Modelo API"
}
```

---

## 🎯 Recommendations API

### Get Outfit Recommendations

#### POST `/api/recommendations/outfits`
Generate AI-powered outfit recommendations based on user profile and wardrobe.

**Request Body:**
```json
{
  "wardrobeItems": [
    {
      "id": "item_1",
      "name": "Blue Jeans",
      "type": "bottom",
      "color": "blue",
      "pattern": "solid",
      "fabric": "denim",
      "fit": "skinny",
      "season": "allSeason",
      "tags": ["casual", "versatile"],
      "rating": 4,
      "wearCount": 15
    }
  ],
  "userProfile": {
    "id": "user_1",
    "name": "Jane Doe",
    "gender": "female",
    "bodyType": "hourglass",
    "skinUndertone": "warm",
    "faceShape": "oval",
    "favoriteColors": ["blue", "white", "black"],
    "dislikedPatterns": ["polka_dots"],
    "measurements": {
      "bust": "34",
      "waist": "26",
      "hips": "36"
    },
    "stylePreferences": {
      "style": "classic",
      "formality": "medium"
    }
  },
  "occasion": "work",
  "weather": "mild",
  "maxSuggestions": 5
}
```

**Response:**
```json
[
  {
    "items": ["item_1", "item_2", "item_3"],
    "score": 0.92,
    "type": "separates",
    "occasion": "work",
    "weather": "mild"
  },
  {
    "items": ["item_4", "item_5"],
    "score": 0.88,
    "type": "dress",
    "occasion": "work",
    "weather": "mild"
  }
]
```

### Get Style Tips

#### POST `/api/recommendations/style-tips`
Get personalized style recommendations based on user profile.

**Request Body:**
```json
{
  "id": "user_1",
  "name": "Jane Doe",
  "gender": "female",
  "bodyType": "hourglass",
  "skinUndertone": "warm",
  "faceShape": "oval",
  "favoriteColors": ["blue", "white", "black"],
  "dislikedPatterns": ["polka_dots"],
  "measurements": {
    "bust": "34",
    "waist": "26",
    "hips": "36"
  },
  "stylePreferences": {
    "style": "classic",
    "formality": "medium"
  }
}
```

**Response:**
```json
{
  "tips": [
    "For your hourglass shape, emphasize your waist with belted styles",
    "Warm colors like coral, peach, and gold complement your skin tone",
    "Choose fitted clothing that follows your natural curves"
  ]
}
```

---

## 🔍 Analysis API

### Analyze Color Compatibility

#### POST `/api/analysis/color-compatibility`
Analyze compatibility between two colors using color theory.

**Request Body:**
```json
{
  "color1": "blue",
  "color2": "white"
}
```

**Response:**
```json
{
  "color1": "blue",
  "color2": "white",
  "compatibility_score": 0.85,
  "compatible": true
}
```

### Get Body Type Score

#### POST `/api/analysis/body-type-score`
Calculate how well an item suits a specific body type.

**Request Body:**
```json
{
  "item_attributes": {
    "fit": "fitted",
    "style": "wrap",
    "neckline": "v_neck"
  },
  "body_type": "hourglass",
  "item_type": "top"
}
```

**Response:**
```json
{
  "body_type": "hourglass",
  "item_type": "top",
  "compatibility_score": 0.92,
  "suitable": true
}
```

---

## 📊 Data API

### Get Color Harmony Rules

#### GET `/api/data/color-harmony`
Retrieve color harmony rules used by the AI system.

**Response:**
```json
{
  "color_harmony": {
    "red": ["white", "black", "navy", "beige", "gray"],
    "blue": ["white", "beige", "gray", "navy", "brown"],
    "green": ["white", "beige", "brown", "navy", "black"]
  }
}
```

### Get Body Type Rules

#### GET `/api/data/body-type-rules`
Retrieve body type styling rules.

**Response:**
```json
{
  "body_type_rules": {
    "pear": {
      "emphasize": ["tops", "upper_body"],
      "colors_top": ["bright", "light"],
      "colors_bottom": ["dark", "neutral"],
      "avoid": ["tight_bottoms", "horizontal_stripes_bottom"]
    },
    "hourglass": {
      "emphasize": ["waist", "curves"],
      "fits": ["fitted", "tailored"],
      "styles": ["wrap", "belted"],
      "avoid": ["baggy", "shapeless"]
    }
  }
}
```

### Get Occasion Styles

#### GET `/api/data/occasion-styles`
Retrieve occasion-based styling guidelines.

**Response:**
```json
{
  "occasion_styles": {
    "work": {
      "formality": 0.8,
      "colors": ["navy", "black", "gray", "white", "burgundy"],
      "patterns": ["solid", "subtle_stripes", "small_prints"],
      "fits": ["tailored", "professional", "conservative"]
    },
    "casual": {
      "formality": 0.3,
      "colors": ["any"],
      "patterns": ["any"],
      "fits": ["comfortable", "relaxed"]
    }
  }
}
```

---

## 📤 Upload API

### Upload Image

#### POST `/api/upload/image`
Upload clothing item image for analysis.

**Request:**
- Content-Type: `multipart/form-data`
- File field: `file`

**Response:**
```json
{
  "filename": "shirt.jpg",
  "file_path": "uploads/shirt.jpg",
  "message": "Image uploaded successfully"
}
```

---

## 🔧 Flutter API Service Integration

### ApiService Class Usage

```dart
// Get outfit recommendations
List<Outfit> outfits = await ApiService.getOutfitRecommendations(
  wardrobeItems: wardrobeItems,
  userProfile: userProfile,
  occasion: 'work',
  weather: 'mild',
  maxSuggestions: 5,
);

// Get style tips
List<String> tips = await ApiService.getStyleTips(userProfile);

// Analyze color compatibility
Map<String, dynamic> result = await ApiService.analyzeColorCompatibility(
  'blue', 'white'
);

// Upload image
String? filePath = await ApiService.uploadImage(imageFile);
```

---

## ⚠️ Error Handling

### Error Response Format
```json
{
  "detail": "Error message description",
  "status_code": 400
}
```

### Common HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad Request - Invalid input data |
| 404 | Not Found - Endpoint doesn't exist |
| 422 | Unprocessable Entity - Validation error |
| 500 | Internal Server Error - Server-side error |

### Error Examples

**400 Bad Request:**
```json
{
  "detail": "Both colors must be provided",
  "status_code": 400
}
```

**500 Internal Server Error:**
```json
{
  "detail": "Error generating recommendations: Model not initialized",
  "status_code": 500
}
```

---

## 🚀 API Performance

### Response Times
- Health checks: < 50ms
- Outfit recommendations: < 2s
- Style tips: < 500ms
- Color analysis: < 100ms
- Image upload: < 5s (depending on file size)

### Rate Limiting
- No rate limiting implemented (development)
- Consider implementing for production deployment

### Caching
- No caching implemented (development)
- Consider Redis for production caching

---

## 🔒 Security Considerations

### CORS Configuration
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Input Validation
- Pydantic models for request validation
- Type checking and data sanitization
- File upload restrictions

### Production Security
- Configure specific CORS origins
- Add authentication middleware
- Implement rate limiting
- Add request logging
- Use HTTPS in production

---

This API documentation provides complete reference for integrating with the Modelo backend services.