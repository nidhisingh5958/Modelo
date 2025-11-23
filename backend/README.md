# Modelo Backend API

AI-powered backend service for wardrobe management and outfit recommendations.

## Features

### 🤖 Machine Learning Models
- **Outfit Recommender**: Color harmony, body type analysis, occasion-based styling
- **Image Analyzer**: Color extraction, pattern detection, fabric texture analysis
- **Style Engine**: Personalized recommendations based on user preferences

### 🚀 API Endpoints

#### Outfit Recommendations
- `POST /api/recommendations/outfits` - Generate outfit suggestions
- `POST /api/recommendations/style-tips` - Get personalized style advice

#### Analysis Services
- `POST /api/analysis/color-compatibility` - Analyze color combinations
- `POST /api/analysis/body-type-score` - Body type compatibility scoring
- `POST /api/upload/image` - Upload and analyze clothing images

#### Data Services
- `GET /api/data/color-harmony` - Color harmony rules
- `GET /api/data/body-type-rules` - Body type styling guidelines
- `GET /api/data/occasion-styles` - Occasion-based style rules

## Setup & Installation

### Prerequisites
- Python 3.8+
- pip package manager

### Installation

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the server**
   ```bash
   cd api
   python run.py
   ```

The API will be available at `http://localhost:8000`

### API Documentation
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## ML Models

### Outfit Recommender
- **Color Harmony**: 13 base colors with compatibility rules
- **Body Type Analysis**: Pear, apple, hourglass, rectangle styling
- **Occasion Matching**: Casual, work, formal, party, date, workout
- **Weather Adaptation**: Season-based item filtering

### Image Analyzer
- **Color Extraction**: K-means clustering for dominant colors
- **Pattern Detection**: Computer vision for stripes, dots, solids
- **Fabric Analysis**: Texture classification using Local Binary Patterns
- **Type Classification**: Clothing category identification

## API Usage Examples

### Generate Outfit Recommendations
```python
import requests

data = {
    "wardrobeItems": [
        {
            "id": "item1",
            "name": "White Shirt",
            "type": "top",
            "color": "white",
            "season": "allSeason",
            "tags": ["professional", "versatile"]
        }
    ],
    "userProfile": {
        "id": "user1",
        "name": "User",
        "bodyType": "hourglass",
        "skinUndertone": "warm",
        "favoriteColors": ["blue", "white"]
    },
    "occasion": "work",
    "maxSuggestions": 5
}

response = requests.post("http://localhost:8000/api/recommendations/outfits", json=data)
recommendations = response.json()
```

### Analyze Color Compatibility
```python
data = {"color1": "blue", "color2": "white"}
response = requests.post("http://localhost:8000/api/analysis/color-compatibility", json=data)
compatibility = response.json()
```

### Upload and Analyze Image
```python
files = {"file": open("clothing_item.jpg", "rb")}
response = requests.post("http://localhost:8000/api/upload/image", files=files)
result = response.json()
```

## Model Architecture

### Recommendation Algorithm
1. **Item Filtering**: Season, occasion, user preferences
2. **Compatibility Scoring**: Color harmony, body type, style
3. **Combination Generation**: Dress-based and separates outfits
4. **Ranking**: Score-based sorting and top-k selection

### Scoring Components
- **Color Compatibility**: 0.3-0.9 based on harmony rules
- **Body Type Fit**: 0.5-1.0 based on styling guidelines
- **Occasion Match**: 0.5-1.0 based on tag alignment
- **User Preference**: 0.5-0.8 based on favorite colors

## Deployment

### Docker Deployment
```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["python", "api/run.py"]
```

### Environment Variables
- `PORT`: Server port (default: 8000)
- `DEBUG`: Enable debug mode (default: False)
- `CORS_ORIGINS`: Allowed CORS origins

## Future Enhancements

### Advanced ML Features
- **Deep Learning**: CNN models for clothing classification
- **Recommendation Learning**: User feedback integration
- **Trend Analysis**: Fashion trend prediction
- **Seasonal Updates**: Dynamic style rule updates

### API Extensions
- **User Authentication**: JWT-based auth system
- **Data Persistence**: Database integration
- **Image Storage**: Cloud storage for uploaded images
- **Real-time Updates**: WebSocket support

### Performance Optimizations
- **Model Caching**: Redis for recommendation caching
- **Batch Processing**: Bulk recommendation generation
- **Load Balancing**: Multi-instance deployment
- **CDN Integration**: Fast image delivery

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

This project is licensed under the MIT License.