import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import LabelEncoder
import pickle
import json

class OutfitRecommender:
    def __init__(self):
        self.color_harmony = {
            'red': ['white', 'black', 'navy', 'beige', 'gray'],
            'blue': ['white', 'beige', 'gray', 'navy', 'brown'],
            'green': ['white', 'beige', 'brown', 'navy', 'black'],
            'yellow': ['white', 'navy', 'gray', 'brown', 'black'],
            'black': ['white', 'red', 'blue', 'yellow', 'pink'],
            'white': ['black', 'navy', 'red', 'blue', 'green'],
            'navy': ['white', 'beige', 'red', 'yellow', 'pink'],
            'gray': ['white', 'black', 'red', 'blue', 'yellow'],
            'brown': ['white', 'beige', 'blue', 'green', 'yellow'],
            'beige': ['navy', 'brown', 'blue', 'red', 'green'],
        }
        
        self.body_type_rules = {
            'pear': {
                'emphasize': ['tops', 'upper_body'],
                'colors_top': ['bright', 'light'],
                'colors_bottom': ['dark', 'neutral'],
                'avoid': ['tight_bottoms', 'horizontal_stripes_bottom']
            },
            'apple': {
                'emphasize': ['legs', 'lower_body'],
                'necklines': ['v_neck', 'scoop_neck'],
                'waist': ['empire', 'loose'],
                'avoid': ['tight_tops', 'high_waisted']
            },
            'hourglass': {
                'emphasize': ['waist', 'curves'],
                'fits': ['fitted', 'tailored'],
                'styles': ['wrap', 'belted'],
                'avoid': ['baggy', 'shapeless']
            },
            'rectangle': {
                'create': ['curves', 'definition'],
                'styles': ['peplum', 'ruffles', 'layered'],
                'bottoms': ['wide_leg', 'flared'],
                'avoid': ['straight', 'boxy']
            }
        }
        
        self.occasion_styles = {
            'casual': ['comfortable', 'relaxed', 'everyday'],
            'work': ['professional', 'polished', 'conservative'],
            'formal': ['elegant', 'sophisticated', 'dressy'],
            'party': ['fun', 'trendy', 'statement'],
            'date': ['romantic', 'flattering', 'stylish'],
            'workout': ['athletic', 'breathable', 'flexible']
        }

    def calculate_color_compatibility(self, color1, color2):
        """Calculate compatibility score between two colors"""
        if color1.lower() == color2.lower():
            return 0.9
        
        compatible_colors = self.color_harmony.get(color1.lower(), [])
        if color2.lower() in compatible_colors:
            return 0.8
        
        return 0.3

    def get_body_type_score(self, item_attributes, body_type, item_type):
        """Score item based on body type recommendations"""
        rules = self.body_type_rules.get(body_type.lower(), {})
        score = 0.5  # Base score
        
        # Check fit recommendations
        if 'fits' in rules and item_attributes.get('fit'):
            if item_attributes['fit'].lower() in rules['fits']:
                score += 0.3
        
        # Check style recommendations
        if 'styles' in rules and item_attributes.get('style'):
            if item_attributes['style'].lower() in rules['styles']:
                score += 0.2
        
        return min(score, 1.0)

    def calculate_occasion_score(self, item_tags, occasion):
        """Score item based on occasion appropriateness"""
        occasion_keywords = self.occasion_styles.get(occasion.lower(), [])
        
        if not item_tags:
            return 0.5
        
        tag_matches = sum(1 for tag in item_tags if tag.lower() in occasion_keywords)
        return min(0.5 + (tag_matches * 0.2), 1.0)

    def generate_outfit_recommendations(self, wardrobe_items, user_profile, occasion='casual', weather=None, max_suggestions=5):
        """Generate outfit recommendations using ML algorithms"""
        recommendations = []
        
        # Filter items by season if weather specified
        if weather:
            season_map = {
                'hot': 'summer', 'sunny': 'summer',
                'cold': 'winter', 'snowy': 'winter',
                'mild': 'spring', 'rainy': 'spring',
                'cool': 'fall'
            }
            target_season = season_map.get(weather.lower(), 'allSeason')
            wardrobe_items = [item for item in wardrobe_items 
                            if item.get('season') == target_season or item.get('season') == 'allSeason']
        
        # Group items by type
        items_by_type = {}
        for item in wardrobe_items:
            item_type = item.get('type', 'unknown')
            if item_type not in items_by_type:
                items_by_type[item_type] = []
            items_by_type[item_type].append(item)
        
        # Generate dress-based outfits
        dresses = items_by_type.get('dress', [])
        for dress in dresses[:max_suggestions//2]:
            outfit_score = self._calculate_outfit_score(
                [dress], user_profile, occasion, weather
            )
            
            outfit = {
                'items': [dress['id']],
                'score': outfit_score,
                'type': 'dress',
                'occasion': occasion,
                'weather': weather
            }
            
            # Add accessories
            shoes = self._find_matching_items(dress, items_by_type.get('shoes', []), user_profile)
            accessories = self._find_matching_items(dress, items_by_type.get('accessory', []), user_profile)
            
            if shoes:
                outfit['items'].append(shoes[0]['id'])
            if accessories:
                outfit['items'].append(accessories[0]['id'])
            
            recommendations.append(outfit)
        
        # Generate top + bottom combinations
        tops = items_by_type.get('top', [])
        bottoms = items_by_type.get('bottom', [])
        
        for top in tops:
            for bottom in bottoms:
                if len(recommendations) >= max_suggestions:
                    break
                
                # Check color compatibility
                color_score = self.calculate_color_compatibility(
                    top.get('color', ''), bottom.get('color', '')
                )
                
                if color_score < 0.6:
                    continue
                
                outfit_items = [top, bottom]
                outfit_score = self._calculate_outfit_score(
                    outfit_items, user_profile, occasion, weather
                )
                
                outfit = {
                    'items': [top['id'], bottom['id']],
                    'score': outfit_score,
                    'type': 'separates',
                    'occasion': occasion,
                    'weather': weather
                }
                
                # Add matching accessories
                shoes = self._find_matching_items(top, items_by_type.get('shoes', []), user_profile)
                if shoes:
                    outfit['items'].append(shoes[0]['id'])
                
                recommendations.append(outfit)
        
        # Sort by score and return top recommendations
        recommendations.sort(key=lambda x: x['score'], reverse=True)
        return recommendations[:max_suggestions]

    def _calculate_outfit_score(self, items, user_profile, occasion, weather):
        """Calculate overall outfit score"""
        scores = []
        
        for item in items:
            # Body type compatibility
            body_score = self.get_body_type_score(
                item, user_profile.get('bodyType', ''), item.get('type', '')
            )
            scores.append(body_score)
            
            # Occasion appropriateness
            occasion_score = self.calculate_occasion_score(
                item.get('tags', []), occasion
            )
            scores.append(occasion_score)
            
            # User preference alignment
            fav_colors = user_profile.get('favoriteColors', [])
            if item.get('color', '').lower() in [c.lower() for c in fav_colors]:
                scores.append(0.8)
            else:
                scores.append(0.5)
        
        return np.mean(scores) if scores else 0.5

    def _find_matching_items(self, main_item, candidate_items, user_profile):
        """Find items that match well with the main item"""
        matches = []
        
        for item in candidate_items:
            color_score = self.calculate_color_compatibility(
                main_item.get('color', ''), item.get('color', '')
            )
            
            if color_score >= 0.6:
                matches.append({
                    'item': item,
                    'score': color_score
                })
        
        matches.sort(key=lambda x: x['score'], reverse=True)
        return [match['item'] for match in matches]

    def get_style_recommendations(self, user_profile):
        """Generate personalized style recommendations"""
        recommendations = []
        
        body_type = user_profile.get('bodyType', '').lower()
        skin_tone = user_profile.get('skinUndertone', '').lower()
        
        # Body type recommendations
        if body_type in self.body_type_rules:
            rules = self.body_type_rules[body_type]
            if 'emphasize' in rules:
                recommendations.append(f"Emphasize your {', '.join(rules['emphasize'])} to flatter your {body_type} shape")
        
        # Color recommendations based on skin tone
        if skin_tone == 'warm':
            recommendations.append("Warm colors like coral, peach, and gold complement your skin tone")
        elif skin_tone == 'cool':
            recommendations.append("Cool colors like blue, purple, and silver enhance your complexion")
        elif skin_tone == 'neutral':
            recommendations.append("You can wear both warm and cool colors - lucky you!")
        
        return recommendations

    def save_model(self, filepath):
        """Save the model to disk"""
        model_data = {
            'color_harmony': self.color_harmony,
            'body_type_rules': self.body_type_rules,
            'occasion_styles': self.occasion_styles
        }
        
        with open(filepath, 'wb') as f:
            pickle.dump(model_data, f)

    def load_model(self, filepath):
        """Load the model from disk"""
        with open(filepath, 'rb') as f:
            model_data = pickle.load(f)
        
        self.color_harmony = model_data['color_harmony']
        self.body_type_rules = model_data['body_type_rules']
        self.occasion_styles = model_data['occasion_styles']