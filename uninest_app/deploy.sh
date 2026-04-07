#!/bin/bash

echo "🚀 Deploying UNINEST App to Firebase Hosting..."

# Build the Flutter web app
echo "📦 Building Flutter web app..."
flutter build web --release

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "❌ Flutter build failed!"
    exit 1
fi

echo "✅ Build completed successfully"

# Deploy to Firebase
echo "🔥 Deploying to Firebase Hosting..."
firebase deploy --only hosting

# Check if deployment was successful
if [ $? -eq 0 ]; then
    echo "🎉 Deployment successful!"
    echo "🌐 Your app is now live at: https://uninest-app-1.web.app"
    echo "📱 Hosting URL: https://uninest-app-1.firebaseapp.com"
else
    echo "❌ Deployment failed!"
    exit 1
fi