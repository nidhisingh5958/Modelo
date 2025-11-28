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
            # Neutrals - compatible with everything
            'black': ['white', 'gray', 'beige', 'red', 'blue', 'yellow', 'green', 'navy', 'brown'],
            'white': ['black', 'gray', 'navy', 'red', 'blue', 'green', 'brown', 'beige'],
            'gray': ['black', 'white', 'beige', 'navy', 'red', 'blue', 'yellow', 'purple'],
            'beige': ['white', 'brown', 'navy', 'blue', 'green', 'burgundy', 'olive'],
            
            # Primary and secondary colors
            'red': ['white', 'black', 'gray', 'beige', 'navy', 'green'],
            'blue': ['white', 'gray', 'beige', 'navy', 'orange', 'brown'],
            'yellow': ['white', 'gray', 'navy', 'purple', 'brown'],
            'green': ['white', 'beige', 'brown', 'navy', 'red', 'cream'],
            
            # Popular fashion colors
            'navy': ['white', 'beige', 'gray', 'coral', 'yellow', 'khaki', 'cream'],
            'brown': ['white', 'beige', 'cream', 'blue', 'green', 'orange'],
            'burgundy': ['white', 'gray', 'beige', 'navy', 'mint', 'cream'],
            'olive': ['white', 'beige', 'brown', 'navy', 'cream'],
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

    def hex_to_color_name(self, hex_color):
        """Convert hex color to closest color name"""
        hex_to_name = {
            '#FF0000': 'red', '#DC143C': 'red', '#B22222': 'red',
            '#0000FF': 'blue', '#000080': 'navy', '#4169E1': 'blue',
            '#FFFF00': 'yellow', '#FFD700': 'yellow', '#FFA500': 'orange',
            '#008000': 'green', '#00FF00': 'green', '#90EE90': 'green',
            '#800080': 'purple', '#9370DB': 'purple', '#E6E6FA': 'lavender',
            '#FFA500': 'orange', '#FF7F50': 'coral', '#FF6347': 'coral',
            '#000000': 'black', '#FFFFFF': 'white', '#808080': 'gray',
            '#F5F5DC': 'beige', '#FFFDD0': 'cream', '#FFFFF0': 'ivory',
            '#A52A2A': 'brown', '#8B4513': 'brown', '#D2691E': 'brown',
            '#800020': 'burgundy', '#808000': 'olive', '#008080': 'teal',
            '#98FB98': 'mint'
        }
        return hex_to_name.get(hex_color.upper(), 'unknown')

    def calculate_color_compatibility(self, color1, color2, hex1=None, hex2=None):
        """Enhanced color compatibility using color theory principles"""
        # Convert hex to color names if provided
        if hex1:
            color1 = self.hex_to_color_name(hex1)
        if hex2:
            color2 = self.hex_to_color_name(hex2)
            
        c1, c2 = color1.lower().strip(), color2.lower().strip()
        
        # Same color - high compatibility
        if c1 == c2:
            return 0.95
        
        # Define color categories
        neutrals = {'black', 'white', 'gray', 'grey', 'beige', 'cream', 'ivory', 'taupe'}
        warm_colors = {'red', 'orange', 'yellow', 'coral', 'peach', 'gold', 'burgundy', 'maroon'}
        cool_colors = {'blue', 'green', 'purple', 'navy', 'teal', 'turquoise', 'mint', 'lavender'}
        earth_tones = {'brown', 'tan', 'khaki', 'olive', 'rust', 'terracotta'}
        
        # Neutral combinations - always compatible
        if c1 in neutrals and c2 in neutrals:
            return 0.9
        
        # One neutral + any color - highly compatible
        if c1 in neutrals or c2 in neutrals:
            return 0.85
        
        # Complementary pairs (opposite on color wheel)
        complementary = {
            ('red', 'green'), ('blue', 'orange'), ('yellow', 'purple'),
            ('navy', 'coral'), ('teal', 'coral'), ('burgundy', 'mint')
        }
        if (c1, c2) in complementary or (c2, c1) in complementary:
            return 0.8
        
        # Analogous colors (next to each other on color wheel)
        analogous = {
            ('red', 'orange'), ('orange', 'yellow'), ('yellow', 'green'),
            ('green', 'blue'), ('blue', 'purple'), ('purple', 'red'),
            ('navy', 'blue'), ('teal', 'green')
        }
        if (c1, c2) in analogous or (c2, c1) in analogous:
            return 0.75
        
        # Same temperature colors
        if (c1 in warm_colors and c2 in warm_colors) or (c1 in cool_colors and c2 in cool_colors):
            return 0.7
        
        # Earth tones with neutrals or warm colors
        if (c1 in earth_tones and (c2 in neutrals or c2 in warm_colors)) or \
           (c2 in earth_tones and (c1 in neutrals or c1 in warm_colors)):
            return 0.75
        
        # Classic combinations
        classic_pairs = {
            ('navy', 'white'), ('black', 'white'), ('denim', 'white'),
            ('khaki', 'navy'), ('brown', 'cream'), ('burgundy', 'gray')
        }
        if (c1, c2) in classic_pairs or (c2, c1) in classic_pairs:
            return 0.85
        
        # Default for unmatched combinations
        return 0.4

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