#!/bin/bash

# Build and Deploy Script for Modelo App
echo "🚀 Building Modelo APK and updating website..."

# Navigate to app directory
cd app

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build APK
echo "📱 Building APK..."
flutter build apk --release

# Check if build was successful
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "✅ APK built successfully!"
    
    # Copy APK to website folder
    echo "📋 Copying APK to website folder..."
    cp build/app/outputs/flutter-apk/app-release.apk ../website/modelo-app.apk
    
    # Get APK size
    APK_SIZE=$(du -h ../website/modelo-app.apk | cut -f1)
    echo "📦 APK size: $APK_SIZE"
    
    echo "🎉 Build and deployment complete!"
    echo "📍 APK location: website/modelo-app.apk"
    echo "🌐 You can now serve the website with the updated APK"
    
else
    echo "❌ APK build failed!"
    exit 1
fi

# Navigate back to root
cd ..

echo "💡 To serve the website locally, run: cd website && python -m http.server 8080"