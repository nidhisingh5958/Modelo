# Modelo - Deployment Guide

## 🚀 Deployment Overview

This guide covers deploying all components of the Modelo project to production environments, including the Flutter mobile app, Python backend, and marketing website.

## 📱 Mobile App Deployment

### Android Deployment (Google Play Store)

#### Prerequisites
- Google Play Console account ($25 one-time fee)
- Android signing key
- App icons and screenshots
- Privacy policy and terms of service

#### Step 1: Prepare Release Build
```bash
cd app

# Clean previous builds
flutter clean
flutter pub get

# Build release APK (for testing)
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### Step 2: Sign the App
```bash
# Generate signing key (first time only)
keytool -genkey -v -keystore ~/modelo-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias modelo

# Create key.properties file
echo "storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=modelo
storeFile=/path/to/modelo-release-key.keystore" > android/key.properties
```

#### Step 3: Configure Gradle
```gradle
// android/app/build.gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### Step 4: Upload to Play Store
1. **Create App Listing**:
   - App name: "Modelo - AI Personal Stylist"
   - Short description: "AI-powered wardrobe management and outfit recommendations"
   - Full description: Include features and benefits
   - Screenshots: 2-8 screenshots per device type
   - Feature graphic: 1024 x 500 pixels

2. **Upload App Bundle**:
   - Go to Play Console → App releases → Production
   - Upload the `.aab` file from `build/app/outputs/bundle/release/`
   - Fill in release notes

3. **Content Rating**:
   - Complete content rating questionnaire
   - Modelo should receive "Everyone" rating

4. **Pricing & Distribution**:
   - Set as free app
   - Select countries for distribution
   - Agree to content policies

### iOS Deployment (Apple App Store)

#### Prerequisites
- Apple Developer account ($99/year)
- macOS with Xcode
- iOS distribution certificate
- App Store Connect access

#### Step 1: Configure iOS Project
```bash
cd app

# Open iOS project in Xcode
open ios/Runner.xcworkspace
```

#### Step 2: Xcode Configuration
1. **Bundle Identifier**: Set unique bundle ID (e.g., `com.yourcompany.modelo`)
2. **Team**: Select your development team
3. **Deployment Target**: iOS 12.0 or later
4. **App Icons**: Add all required icon sizes
5. **Launch Screen**: Configure launch screen

#### Step 3: Build and Archive
```bash
# Build iOS release
flutter build ios --release

# In Xcode:
# 1. Select "Any iOS Device" as target
# 2. Product → Archive
# 3. Upload to App Store Connect
```

#### Step 4: App Store Connect
1. **App Information**:
   - Name: "Modelo - AI Personal Stylist"
   - Bundle ID: Match Xcode configuration
   - SKU: Unique identifier

2. **App Store Listing**:
   - Screenshots: Required for all device sizes
   - App preview videos: Optional but recommended
   - Description: Highlight AI features and benefits
   - Keywords: "fashion, AI, wardrobe, styling, outfits"

3. **App Review Information**:
   - Contact information
   - Demo account (if needed)
   - Review notes

4. **Submit for Review**:
   - Complete all required fields
   - Submit for Apple review (typically 24-48 hours)

## 🐍 Backend Deployment

### Cloud Deployment Options

#### Option 1: AWS Deployment

##### Prerequisites
- AWS account
- AWS CLI configured
- Docker installed

##### Step 1: Containerize Application
```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

##### Step 2: Build and Push to ECR
```bash
# Build Docker image
docker build -t modelo-backend .

# Create ECR repository
aws ecr create-repository --repository-name modelo-backend

# Get login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Tag and push image
docker tag modelo-backend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/modelo-backend:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/modelo-backend:latest
```

##### Step 3: Deploy with ECS
```yaml
# docker-compose.yml for ECS
version: '3.8'
services:
  modelo-backend:
    image: <account-id>.dkr.ecr.us-east-1.amazonaws.com/modelo-backend:latest
    ports:
      - "8000:8000"
    environment:
      - ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - SECRET_KEY=${SECRET_KEY}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

#### Option 2: Google Cloud Platform

##### Step 1: Prepare for Cloud Run
```yaml
# cloudbuild.yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/modelo-backend', '.']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/modelo-backend']
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'deploy'
      - 'modelo-backend'
      - '--image'
      - 'gcr.io/$PROJECT_ID/modelo-backend'
      - '--region'
      - 'us-central1'
      - '--platform'
      - 'managed'
      - '--allow-unauthenticated'
```

##### Step 2: Deploy to Cloud Run
```bash
# Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com

# Deploy using Cloud Build
gcloud builds submit --config cloudbuild.yaml

# Or deploy directly
gcloud run deploy modelo-backend \
    --source . \
    --region us-central1 \
    --platform managed \
    --allow-unauthenticated
```

#### Option 3: Heroku Deployment

##### Step 1: Prepare Heroku Files
```python
# Procfile
web: uvicorn api.main:app --host 0.0.0.0 --port $PORT
```

```txt
# runtime.txt
python-3.9.18
```

##### Step 2: Deploy to Heroku
```bash
# Install Heroku CLI and login
heroku login

# Create Heroku app
heroku create modelo-backend

# Set environment variables
heroku config:set ENV=production
heroku config:set SECRET_KEY=your-secret-key

# Deploy
git add .
git commit -m "Deploy to Heroku"
git push heroku main
```

### Database Setup

#### PostgreSQL on AWS RDS
```bash
# Create RDS instance
aws rds create-db-instance \
    --db-instance-identifier modelo-db \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --master-username modelo \
    --master-user-password your-password \
    --allocated-storage 20 \
    --vpc-security-group-ids sg-xxxxxxxx
```

#### Environment Variables
```bash
# Production environment variables
export DATABASE_URL="postgresql://modelo:password@modelo-db.region.rds.amazonaws.com:5432/modelo"
export SECRET_KEY="your-super-secret-key"
export ENV="production"
export ALLOWED_ORIGINS="https://modelo-app.com,https://www.modelo-app.com"
```

### Production Configuration

#### Security Settings
```python
# api/main.py - Production settings
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Modelo API",
    description="AI-Powered Wardrobe Management API",
    version="1.0.0",
    docs_url="/docs" if os.getenv("ENV") != "production" else None,
    redoc_url="/redoc" if os.getenv("ENV") != "production" else None,
)

# Production CORS settings
allowed_origins = os.getenv("ALLOWED_ORIGINS", "").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)
```

#### Monitoring and Logging
```python
# Add logging configuration
import logging
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

# Add health check endpoint
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "Modelo API",
        "version": "1.0.0"
    }
```

## 🌐 Website Deployment

### Static Site Hosting Options

#### Option 1: Netlify Deployment

##### Step 1: Prepare for Deployment
```bash
cd website

# Create _redirects file for SPA routing (if needed)
echo "/*    /index.html   200" > _redirects

# Optimize images and assets
# Minify CSS and JavaScript (optional)
```

##### Step 2: Deploy to Netlify
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login to Netlify
netlify login

# Deploy site
netlify deploy --prod --dir .

# Or connect GitHub repository for automatic deployments
```

##### Step 3: Configure Custom Domain
1. **Add Custom Domain**: In Netlify dashboard, add your domain
2. **DNS Configuration**: Update DNS records to point to Netlify
3. **SSL Certificate**: Netlify provides free SSL certificates

#### Option 2: Vercel Deployment

##### Step 1: Deploy to Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod

# Or connect GitHub repository
```

##### Step 2: Configuration
```json
// vercel.json
{
  "version": 2,
  "builds": [
    {
      "src": "**/*",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/$1"
    }
  ]
}
```

#### Option 3: AWS S3 + CloudFront

##### Step 1: Create S3 Bucket
```bash
# Create S3 bucket
aws s3 mb s3://modelo-website

# Configure for static website hosting
aws s3 website s3://modelo-website --index-document index.html --error-document error.html

# Upload files
aws s3 sync . s3://modelo-website --delete
```

##### Step 2: Configure CloudFront
```bash
# Create CloudFront distribution
aws cloudfront create-distribution --distribution-config file://distribution-config.json
```

```json
// distribution-config.json
{
  "CallerReference": "modelo-website-2024",
  "Comment": "Modelo website distribution",
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-modelo-website",
        "DomainName": "modelo-website.s3.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-modelo-website",
    "ViewerProtocolPolicy": "redirect-to-https",
    "MinTTL": 0,
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    }
  },
  "Enabled": true
}
```

### Performance Optimization

#### Image Optimization
```bash
# Optimize images before deployment
# Install imagemin-cli
npm install -g imagemin-cli

# Optimize images
imagemin images/*.jpg --out-dir=images/optimized --plugin=imagemin-mozjpeg
imagemin images/*.png --out-dir=images/optimized --plugin=imagemin-pngquant
```

#### CSS and JavaScript Minification
```bash
# Install minification tools
npm install -g clean-css-cli uglify-js

# Minify CSS
cleancss -o styles.min.css styles.css

# Minify JavaScript
uglifyjs script.js -o script.min.js
```

#### Caching Configuration
```html
<!-- Add cache headers -->
<meta http-equiv="Cache-Control" content="public, max-age=31536000">
<meta http-equiv="Expires" content="Wed, 31 Dec 2025 23:59:59 GMT">
```

## 🔧 CI/CD Pipeline

### GitHub Actions Workflow

#### Flutter App CI/CD
```yaml
# .github/workflows/flutter.yml
name: Flutter CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
    - run: flutter pub get
    - run: flutter test
    - run: flutter analyze

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
    - run: flutter pub get
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v3
      with:
        name: android-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

#### Backend CI/CD
```yaml
# .github/workflows/backend.yml
name: Backend CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.9'
    - name: Install dependencies
      run: |
        cd backend
        pip install -r requirements.txt
    - name: Run tests
      run: |
        cd backend
        python -m pytest

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    - name: Deploy to Heroku
      uses: akhileshns/heroku-deploy@v3.12.12
      with:
        heroku_api_key: ${{secrets.HEROKU_API_KEY}}
        heroku_app_name: "modelo-backend"
        heroku_email: "your-email@example.com"
        appdir: "backend"
```

## 📊 Monitoring and Analytics

### Application Monitoring

#### Backend Monitoring
```python
# Add monitoring endpoints
from fastapi import FastAPI
import psutil
import time

@app.get("/metrics")
async def get_metrics():
    return {
        "cpu_usage": psutil.cpu_percent(),
        "memory_usage": psutil.virtual_memory().percent,
        "disk_usage": psutil.disk_usage('/').percent,
        "uptime": time.time() - start_time,
    }
```

#### Error Tracking
```python
# Add error tracking (e.g., Sentry)
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn="your-sentry-dsn",
    integrations=[FastApiIntegration()],
    traces_sample_rate=1.0,
)
```

### Analytics Integration

#### Google Analytics (Website)
```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

#### Firebase Analytics (Mobile App)
```yaml
# pubspec.yaml
dependencies:
  firebase_analytics: ^10.0.0
  firebase_core: ^2.0.0
```

```dart
// Initialize Firebase Analytics
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await analytics.logEvent(name: name, parameters: parameters);
  }
}
```

## 🔒 Security Considerations

### SSL/TLS Configuration
- **Mobile App**: Use certificate pinning for API calls
- **Backend**: Deploy with HTTPS (Let's Encrypt or cloud provider certificates)
- **Website**: Enable HTTPS through hosting provider

### Environment Variables
```bash
# Production environment variables
DATABASE_URL=postgresql://user:pass@host:port/db
SECRET_KEY=your-super-secret-key
JWT_SECRET=your-jwt-secret
SENTRY_DSN=your-sentry-dsn
ALLOWED_ORIGINS=https://modelo-app.com
```

### Security Headers
```python
# Add security headers
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware

# HTTPS redirect in production
if os.getenv("ENV") == "production":
    app.add_middleware(HTTPSRedirectMiddleware)

# Trusted hosts
app.add_middleware(
    TrustedHostMiddleware, 
    allowed_hosts=["modelo-app.com", "*.modelo-app.com"]
)
```

## 📋 Deployment Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Environment variables configured
- [ ] Database migrations ready
- [ ] SSL certificates configured
- [ ] Monitoring and logging set up

### Mobile App Deployment
- [ ] App signed with release key
- [ ] Store listings complete
- [ ] Screenshots and descriptions updated
- [ ] Privacy policy and terms of service published
- [ ] App submitted for review

### Backend Deployment
- [ ] Docker image built and tested
- [ ] Database configured and migrated
- [ ] Environment variables set
- [ ] Health checks working
- [ ] Monitoring configured

### Website Deployment
- [ ] Assets optimized
- [ ] DNS configured
- [ ] SSL certificate active
- [ ] Analytics configured
- [ ] Performance tested

### Post-Deployment
- [ ] Smoke tests passed
- [ ] Monitoring alerts configured
- [ ] Performance metrics baseline established
- [ ] Documentation updated
- [ ] Team notified of deployment

---

This deployment guide ensures a smooth transition from development to production for all Modelo components. Follow the checklists and best practices to maintain high availability and performance in production environments.