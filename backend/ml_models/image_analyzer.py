import cv2
import numpy as np
from sklearn.cluster import KMeans
import webcolors
from PIL import Image
import tensorflow as tf

class ImageAnalyzer:
    def __init__(self):
        self.color_names = {
            'red': (255, 0, 0),
            'blue': (0, 0, 255),
            'green': (0, 255, 0),
            'yellow': (255, 255, 0),
            'black': (0, 0, 0),
            'white': (255, 255, 255),
            'gray': (128, 128, 128),
            'brown': (165, 42, 42),
            'pink': (255, 192, 203),
            'purple': (128, 0, 128),
            'orange': (255, 165, 0),
            'navy': (0, 0, 128),
            'beige': (245, 245, 220)
        }

    def extract_dominant_colors(self, image_path, k=5):
        """Extract dominant colors from clothing item image"""
        try:
            # Load image
            image = cv2.imread(image_path)
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            
            # Reshape image to be a list of pixels
            data = image.reshape((-1, 3))
            data = np.float32(data)
            
            # Apply K-means clustering
            criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 20, 1.0)
            _, labels, centers = cv2.kmeans(data, k, None, criteria, 10, cv2.KMEANS_RANDOM_CENTERS)
            
            # Convert back to uint8 and get unique colors
            centers = np.uint8(centers)
            
            # Calculate color percentages
            unique_labels, counts = np.unique(labels, return_counts=True)
            percentages = counts / len(labels)
            
            # Map colors to names
            color_info = []
            for i, (center, percentage) in enumerate(zip(centers, percentages)):
                color_name = self._get_closest_color_name(center)
                color_info.append({
                    'rgb': center.tolist(),
                    'hex': '#{:02x}{:02x}{:02x}'.format(center[0], center[1], center[2]),
                    'name': color_name,
                    'percentage': float(percentage)
                })
            
            # Sort by percentage
            color_info.sort(key=lambda x: x['percentage'], reverse=True)
            
            return color_info
            
        except Exception as e:
            print(f"Error extracting colors: {e}")
            return []

    def _get_closest_color_name(self, rgb_color):
        """Find the closest named color to the given RGB value"""
        min_distance = float('inf')
        closest_color = 'unknown'
        
        for color_name, color_rgb in self.color_names.items():
            # Calculate Euclidean distance
            distance = np.sqrt(sum((c1 - c2) ** 2 for c1, c2 in zip(rgb_color, color_rgb)))
            
            if distance < min_distance:
                min_distance = distance
                closest_color = color_name
        
        return closest_color

    def detect_patterns(self, image_path):
        """Detect patterns in clothing items"""
        try:
            image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
            
            # Apply edge detection
            edges = cv2.Canny(image, 50, 150)
            
            # Detect lines (for stripes)
            lines = cv2.HoughLinesP(edges, 1, np.pi/180, threshold=100, minLineLength=50, maxLineGap=10)
            
            patterns = []
            
            if lines is not None and len(lines) > 10:
                # Check for horizontal lines (horizontal stripes)
                horizontal_lines = [line for line in lines 
                                 if abs(line[0][1] - line[0][3]) < 10]
                if len(horizontal_lines) > 5:
                    patterns.append('horizontal_stripes')
                
                # Check for vertical lines (vertical stripes)
                vertical_lines = [line for line in lines 
                                if abs(line[0][0] - line[0][2]) < 10]
                if len(vertical_lines) > 5:
                    patterns.append('vertical_stripes')
            
            # Detect circles (for polka dots)
            circles = cv2.HoughCircles(image, cv2.HOUGH_GRADIENT, 1, 20,
                                     param1=50, param2=30, minRadius=5, maxRadius=50)
            
            if circles is not None and len(circles[0]) > 10:
                patterns.append('polka_dots')
            
            # If no specific patterns detected, classify as solid
            if not patterns:
                patterns.append('solid')
            
            return patterns
            
        except Exception as e:
            print(f"Error detecting patterns: {e}")
            return ['solid']

    def analyze_fabric_texture(self, image_path):
        """Analyze fabric texture from image"""
        try:
            image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
            
            # Calculate texture features using Local Binary Pattern
            def local_binary_pattern(image, radius=3, n_points=24):
                # Simplified LBP implementation
                height, width = image.shape
                lbp = np.zeros((height, width), dtype=np.uint8)
                
                for i in range(radius, height - radius):
                    for j in range(radius, width - radius):
                        center = image[i, j]
                        binary_string = ''
                        
                        # Sample points around the center
                        for k in range(n_points):
                            angle = 2 * np.pi * k / n_points
                            x = int(i + radius * np.cos(angle))
                            y = int(j + radius * np.sin(angle))
                            
                            if 0 <= x < height and 0 <= y < width:
                                binary_string += '1' if image[x, y] >= center else '0'
                        
                        lbp[i, j] = int(binary_string, 2) if binary_string else 0
                
                return lbp
            
            lbp = local_binary_pattern(image)
            
            # Calculate texture statistics
            texture_variance = np.var(lbp)
            texture_mean = np.mean(lbp)
            
            # Classify fabric type based on texture
            if texture_variance > 1000:
                fabric_type = 'textured'  # Wool, tweed, etc.
            elif texture_variance > 500:
                fabric_type = 'medium'    # Cotton, linen
            else:
                fabric_type = 'smooth'    # Silk, satin, polyester
            
            return {
                'fabric_type': fabric_type,
                'texture_variance': float(texture_variance),
                'texture_mean': float(texture_mean)
            }
            
        except Exception as e:
            print(f"Error analyzing fabric texture: {e}")
            return {'fabric_type': 'unknown', 'texture_variance': 0, 'texture_mean': 0}

    def classify_clothing_type(self, image_path):
        """Classify the type of clothing item from image"""
        # This would typically use a trained CNN model
        # For now, return a placeholder implementation
        
        try:
            image = cv2.imread(image_path)
            height, width = image.shape[:2]
            
            # Simple heuristic based on aspect ratio
            aspect_ratio = height / width
            
            if aspect_ratio > 1.5:
                return 'dress'
            elif aspect_ratio > 1.2:
                return 'top'
            elif aspect_ratio < 0.8:
                return 'bottom'
            else:
                return 'unknown'
                
        except Exception as e:
            print(f"Error classifying clothing type: {e}")
            return 'unknown'

    def analyze_image(self, image_path):
        """Complete image analysis pipeline"""
        try:
            results = {
                'colors': self.extract_dominant_colors(image_path),
                'patterns': self.detect_patterns(image_path),
                'fabric': self.analyze_fabric_texture(image_path),
                'clothing_type': self.classify_clothing_type(image_path)
            }
            
            # Extract primary color
            if results['colors']:
                results['primary_color'] = results['colors'][0]['name']
            else:
                results['primary_color'] = 'unknown'
            
            # Extract primary pattern
            if results['patterns']:
                results['primary_pattern'] = results['patterns'][0]
            else:
                results['primary_pattern'] = 'solid'
            
            return results
            
        except Exception as e:
            print(f"Error in image analysis: {e}")
            return {
                'colors': [],
                'patterns': ['solid'],
                'fabric': {'fabric_type': 'unknown'},
                'clothing_type': 'unknown',
                'primary_color': 'unknown',
                'primary_pattern': 'solid'
            }