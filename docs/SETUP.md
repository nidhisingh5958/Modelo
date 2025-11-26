# Modelo - Setup Guide

## 🚀 Quick Start

This guide will help you set up the complete Modelo project including the Flutter app, Python backend, and website.

## 📋 Prerequisites

### System Requirements
- **Operating System**: macOS, Windows, or Linux
- **RAM**: Minimum 8GB, Recommended 16GB
- **Storage**: At least 5GB free space
- **Internet**: Required for initial setup and dependencies

### Required Software

#### 1. Flutter Development
- **Flutter SDK**: Version 3.0 or higher
- **Dart SDK**: Version 3.0 or higher (included with Flutter)
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Platform Tools**: 
  - Android SDK (for Android development)
  - Xcode (for iOS development on macOS)

#### 2. Python Backend
- **Python**: Version 3.8 to 3.12 (3.13 not yet fully supported by scikit-learn)
- **pip**: Python package manager
- **Virtual Environment**: venv or conda (recommended)

#### 3. Development Tools
- **Git**: Version control system
- **Code Editor**: VS Code, Android Studio, or preferred IDE
- **Browser**: Modern browser for website testing

## 🔧 Installation Steps

### Step 1: Clone the Repository

```bash
# Clone the project
git clone https://github.com/yourusername/modelo.git
cd modelo

# Verify project structure
ls -la
# Should show: app/, backend/, website/, docs/, README.md
```

### Step 2: Flutter App Setup

#### Install Flutter Dependencies
```bash
cd app
flutter pub get
```

#### Verify Flutter Installation
```bash
flutter doctor
```

Expected output should show:
- ✅ Flutter (Channel stable, 3.0+)
- ✅ Android toolchain
- ✅ Xcode (macOS only)
- ✅ VS Code or Android Studio

#### Configure IDE
For **VS Code**:
```bash
# Install Flutter extension
code --install-extension Dart-Code.flutter
```

For **Android Studio**:
- Install Flutter plugin
- Install Dart plugin
- Configure Flutter SDK path

### Step 3: Python Backend Setup

#### Create Virtual Environment
```bash
cd backend

# Using venv
python -m venv modelo_env

# Activate virtual environment
# On macOS/Linux:
source modelo_env/bin/activate
# On Windows:
modelo_env\Scripts\activate
```

#### Install Python Dependencies

**For Python 3.13 users** (scikit-learn compatibility issue):
```bash
# Option 1: Use conda instead of pip
conda install scikit-learn opencv fastapi uvicorn numpy pandas
pip install -r requirements.txt --no-deps

# Option 2: Install pre-release version
pip install --pre scikit-learn
pip install -r requirements.txt

# Option 3: Use Python 3.12 (recommended)
# Create new environment with Python 3.12
conda create -n modelo_env python=3.12
conda activate modelo_env
pip install -r requirements.txt
```

**For Python 3.8-3.12 users**:
```bash
pip install -r requirements.txt
```

#### Verify Backend Installation
```bash
python -c "import fastapi, uvicorn, sklearn, cv2; print('All dependencies installed successfully')"
```

### Step 4: Website Setup

The website is a static HTML/CSS/JS project that doesn't require additional setup.

```bash
cd website
# Verify files exist
ls -la
# Should show: index.html, styles.css, script.js
```

## 🏃‍♂️ Running the Project

### Option 1: Run All Components

#### Terminal 1 - Backend Server
```bash
cd backend
source modelo_env/bin/activate  # Activate virtual environment
python api/main.py
```

Expected output:
```
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

#### Terminal 2 - Flutter App
```bash
cd app
flutter run
```

Choose your target device:
- Android emulator
- iOS simulator
- Physical device
- Chrome (for web testing)

#### Terminal 3 - Website (Optional)
```bash
cd website
# Option 1: Use Python's built-in server
python -m http.server 3000

# Option 2: Use Node.js live-server (if installed)
npx live-server --port=3000

# Option 3: Open directly in browser
open index.html  # macOS
start index.html  # Windows
```

### Option 2: Run Individual Components

#### Backend Only
```bash
cd backend
source modelo_env/bin/activate
python api/main.py
```

#### Flutter App Only
```bash
cd app
flutter run
```

#### Website Only
```bash
cd website
open index.html
```

## 🔍 Verification

### 1. Backend Health Check
Visit: `http://localhost:8000/health`

Expected response:
```json
{
  "status": "healthy",
  "service": "Modelo API"
}
```

### 2. Flutter App Connection
- Open the app
- Navigate to outfit generation
- Verify AI recommendations are working
- Check that wardrobe items can be added

### 3. Website Functionality
- Open `http://localhost:3000` (if using local server)
- Verify all sections load correctly
- Test interactive demo tabs
- Check responsive design on different screen sizes

## 🛠️ Configuration

### Flutter App Configuration

#### API Endpoint Configuration
Edit `app/lib/services/api_service.dart`:
```dart
class ApiService {
  static const String baseUrl = 'http://localhost:8000';  // Change if needed
  // ... rest of the code
}
```

#### Database Configuration
The app uses SQLite by default. No additional configuration needed.

### Backend Configuration

#### Server Configuration
Edit `backend/api/main.py`:
```python
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)  # Change port if needed
```

#### CORS Configuration
For production, update CORS settings:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://yourdomain.com"],  # Specify allowed origins
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)
```

## 📱 Device Setup

### Android Development

#### Enable Developer Options
1. Go to Settings > About Phone
2. Tap "Build Number" 7 times
3. Go to Settings > Developer Options
4. Enable "USB Debugging"

#### Connect Device
```bash
# Check connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### iOS Development (macOS only)

#### Xcode Setup
1. Install Xcode from App Store
2. Open Xcode and accept license
3. Install iOS Simulator

#### Run on iOS
```bash
# List iOS simulators
flutter devices

# Run on iOS simulator
flutter run -d "iPhone 14"
```

## 🔧 Troubleshooting

### Common Flutter Issues

#### Issue: "Flutter command not found"
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"

# Or add to ~/.bashrc or ~/.zshrc
echo 'export PATH="$PATH:/path/to/flutter/bin"' >> ~/.bashrc
```

#### Issue: "Android SDK not found"
```bash
# Set Android SDK path
export ANDROID_HOME=/path/to/android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

#### Issue: "CocoaPods not installed" (macOS)
```bash
sudo gem install cocoapods
cd app/ios
pod install
```

### Common Backend Issues

#### Issue: "scikit-learn compilation error" (Python 3.13)
```bash
# Solution 1: Use conda
conda install scikit-learn

# Solution 2: Use pre-release
pip install --pre scikit-learn

# Solution 3: Downgrade Python
conda create -n modelo_env python=3.12
conda activate modelo_env
pip install -r requirements.txt
```

#### Issue: "Module not found"
```bash
# Ensure virtual environment is activated
source modelo_env/bin/activate

# Reinstall dependencies
pip install -r requirements.txt
```

#### Issue: "Port already in use"
```bash
# Kill process on port 8000
lsof -ti:8000 | xargs kill -9

# Or use different port
uvicorn main:app --port 8001
```

#### Issue: "OpenCV installation failed"
```bash
# Install system dependencies (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install python3-opencv

# Or use conda
conda install opencv
```

### Common Website Issues

#### Issue: "CORS errors in browser"
- Use a local server instead of opening HTML directly
- Use `python -m http.server` or similar

#### Issue: "Fonts not loading"
- Check internet connection for Google Fonts
- Verify font URLs in CSS

## 📊 Performance Optimization

### Flutter App Optimization
```bash
# Build release version for better performance
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### Backend Optimization
```bash
# Install production ASGI server
pip install gunicorn

# Run with Gunicorn (production)
gunicorn -w 4 -k uvicorn.workers.UvicornWorker api.main:app
```

## 🔄 Development Workflow

### Recommended Development Setup
1. **Terminal 1**: Backend server (`python api/main.py`)
2. **Terminal 2**: Flutter hot reload (`flutter run`)
3. **Terminal 3**: Available for git commands and testing
4. **Browser**: Website testing and API documentation

### Hot Reload
- **Flutter**: Automatic hot reload on file changes
- **Backend**: Manual restart required (or use `--reload` flag)
- **Website**: Refresh browser or use live-server

### Debugging
```bash
# Flutter debugging
flutter run --debug

# Backend debugging
python -m debugpy --listen 5678 --wait-for-client api/main.py

# View logs
flutter logs  # Flutter logs
tail -f backend.log  # Backend logs (if configured)
```

## 📚 Next Steps

After successful setup:

1. **Read the [User Guide](./USER_GUIDE.md)** to understand app features
2. **Review the [Developer Guide](./DEVELOPER_GUIDE.md)** for development best practices
3. **Check the [API Documentation](./API.md)** for backend integration
4. **Explore the [Features Documentation](./FEATURES.md)** for detailed capabilities

## 🆘 Getting Help

If you encounter issues:

1. **Check the logs**: Flutter logs, backend logs, browser console
2. **Verify prerequisites**: Ensure all required software is installed
3. **Review documentation**: Check relevant documentation sections
4. **Search issues**: Look for similar problems in project issues
5. **Ask for help**: Contact the development team

---

**Setup Complete!** 🎉 You should now have a fully functional Modelo development environment.