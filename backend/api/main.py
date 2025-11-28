from fastapi import FastAPI, HTTPException, Depends, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from ml_models.outfit_recommender import OutfitRecommender
import json

app = FastAPI(title="Modelo API", description="AI-Powered Wardrobe Management API", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize ML model
recommender = OutfitRecommender()

# Mount static files
app.mount("/static", StaticFiles(directory="static"), name="static")

# Pydantic models
class UserProfile(BaseModel):
    id: str
    name: str
    gender: str
    bodyType: str
    skinUndertone: str
    faceShape: str
    favoriteColors: List[str]
    dislikedPatterns: List[str]
    measurements: Dict[str, str]
    stylePreferences: Dict[str, Any]

class WardrobeItem(BaseModel):
    id: str
    name: str
    type: str
    color: str
    pattern: Optional[str] = None
    fabric: Optional[str] = None
    fit: Optional[str] = None
    season: str
    imagePath: Optional[str] = None
    tags: List[str]
    rating: int = 0
    wearCount: int = 0

class OutfitRequest(BaseModel):
    wardrobeItems: List[WardrobeItem]
    userProfile: UserProfile
    occasion: str
    weather: Optional[str] = None
    maxSuggestions: int = 5

class OutfitRecommendation(BaseModel):
    items: List[str]
    score: float
    type: str
    occasion: str
    weather: Optional[str] = None

@app.get("/")
async def root():
    return {"message": "Modelo API is running"}

@app.post("/api/recommendations/outfits", response_model=List[OutfitRecommendation])
async def get_outfit_recommendations(request: OutfitRequest):
    """Generate outfit recommendations using ML model"""
    try:
        # Convert Pydantic models to dictionaries
        wardrobe_items = [item.dict() for item in request.wardrobeItems]
        user_profile = request.userProfile.dict()
        
        # Generate recommendations
        recommendations = recommender.generate_outfit_recommendations(
            wardrobe_items=wardrobe_items,
            user_profile=user_profile,
            occasion=request.occasion,
            weather=request.weather,
            max_suggestions=request.maxSuggestions
        )
        
        return [OutfitRecommendation(**rec) for rec in recommendations]
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating recommendations: {str(e)}")

@app.post("/api/recommendations/style-tips")
async def get_style_tips(user_profile: UserProfile):
    """Get personalized style recommendations"""
    try:
        tips = recommender.get_style_recommendations(user_profile.dict())
        return {"tips": tips}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating style tips: {str(e)}")

class ColorCompatibilityRequest(BaseModel):
    color1: str
    color2: str
    hex1: Optional[str] = None
    hex2: Optional[str] = None

@app.post("/api/analysis/color-compatibility")
async def analyze_color_compatibility(request: ColorCompatibilityRequest):
    """Analyze color compatibility between items"""
    try:
        if not request.color1 or not request.color2:
            raise HTTPException(status_code=400, detail="Both colors must be provided")
        
        compatibility_score = recommender.calculate_color_compatibility(
            request.color1, request.color2, request.hex1, request.hex2
        )
        
        return {
            "color1": request.color1,
            "color2": request.color2,
            "compatibility_score": compatibility_score,
            "compatible": compatibility_score >= 0.6
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error analyzing color compatibility: {str(e)}")

@app.post("/api/analysis/body-type-score")
async def get_body_type_score(data: Dict[str, Any]):
    """Get body type compatibility score for an item"""
    try:
        item_attributes = data.get("item_attributes", {})
        body_type = data.get("body_type", "")
        item_type = data.get("item_type", "")
        
        score = recommender.get_body_type_score(item_attributes, body_type, item_type)
        
        return {
            "body_type": body_type,
            "item_type": item_type,
            "compatibility_score": score,
            "suitable": score >= 0.6
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error calculating body type score: {str(e)}")

@app.get("/api/data/color-harmony")
async def get_color_harmony():
    """Get color harmony rules"""
    return {"color_harmony": recommender.color_harmony}

@app.get("/api/data/body-type-rules")
async def get_body_type_rules():
    """Get body type styling rules"""
    return {"body_type_rules": recommender.body_type_rules}

@app.get("/api/data/occasion-styles")
async def get_occasion_styles():
    """Get occasion-based styling guidelines"""
    return {"occasion_styles": recommender.occasion_styles}

@app.get("/api/data/color-wheel")
async def get_color_wheel():
    """Get color wheel data for visual color picker"""
    return {
        "color_wheel": {
            "primary": [
                {"name": "red", "hex": "#FF0000", "position": 0},
                {"name": "blue", "hex": "#0000FF", "position": 120},
                {"name": "yellow", "hex": "#FFFF00", "position": 240}
            ],
            "secondary": [
                {"name": "orange", "hex": "#FFA500", "position": 30},
                {"name": "green", "hex": "#008000", "position": 150},
                {"name": "purple", "hex": "#800080", "position": 270}
            ],
            "neutrals": [
                {"name": "black", "hex": "#000000"},
                {"name": "white", "hex": "#FFFFFF"},
                {"name": "gray", "hex": "#808080"},
                {"name": "beige", "hex": "#F5F5DC"},
                {"name": "cream", "hex": "#FFFDD0"},
                {"name": "ivory", "hex": "#FFFFF0"}
            ],
            "fashion_colors": [
                {"name": "navy", "hex": "#000080"},
                {"name": "burgundy", "hex": "#800020"},
                {"name": "olive", "hex": "#808000"},
                {"name": "brown", "hex": "#A52A2A"},
                {"name": "coral", "hex": "#FF7F50"},
                {"name": "teal", "hex": "#008080"},
                {"name": "mint", "hex": "#98FB98"},
                {"name": "lavender", "hex": "#E6E6FA"}
            ]
        }
    }

@app.post("/api/upload/image")
async def upload_image(file: UploadFile = File(...)):
    """Upload and process clothing item image"""
    try:
        # Save uploaded file
        file_path = f"uploads/{file.filename}"
        os.makedirs("uploads", exist_ok=True)
        
        with open(file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        # TODO: Add image processing and color extraction
        # For now, return basic info
        return {
            "filename": file.filename,
            "file_path": file_path,
            "message": "Image uploaded successfully"
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error uploading image: {str(e)}")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "Modelo API"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)