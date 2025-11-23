#!/bin/bash

echo "🚀 Setting up Modelo - AI Wardrobe Manager"
echo "=========================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Setup Flutter app
echo "📱 Setting up Flutter app..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Flutter dependencies installed successfully"
else
    echo "❌ Failed to install Flutter dependencies"
    exit 1
fi

# Setup Python backend
echo "🐍 Setting up Python backend..."
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✅ Python dependencies installed successfully"
else
    echo "❌ Failed to install Python dependencies"
    exit 1
fi

cd ..

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "To run the application:"
echo "1. Start the backend server:"
echo "   cd backend && source venv/bin/activate && python api/run.py"
echo ""
echo "2. In a new terminal, run the Flutter app:"
echo "   flutter run"
echo ""
echo "📚 Documentation:"
echo "   - Flutter app: README.md"
echo "   - Backend API: backend/README.md"
echo "   - Features: FEATURES.md"
echo ""
echo "🌟 Enjoy using Modelo!"