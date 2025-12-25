#!/bin/bash

# Build and install ZoomIt to /Applications
# This ensures the permission stays consistent

echo "🔨 Building ZoomIt..."
cd "$(dirname "$0")"

xcodebuild -project ZoomIt.xcodeproj \
    -scheme ZoomIt \
    -configuration Release \
    build \
    CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION=YES \
    2>&1 | grep -E "error:|BUILD"

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "📦 Installing to /Applications..."

# Find the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/ZoomIt-*/Build/Products/Release -name "ZoomIt.app" -type d 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
    # Try Debug if Release not found
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/ZoomIt-*/Build/Products/Debug -name "ZoomIt.app" -type d 2>/dev/null | head -1)
fi

if [ -z "$APP_PATH" ]; then
    echo "❌ Could not find built app"
    exit 1
fi

echo "Found app at: $APP_PATH"

# Remove old version if exists
if [ -d "/Applications/ZoomIt.app" ]; then
    echo "🗑️  Removing old version..."
    rm -rf "/Applications/ZoomIt.app"
fi

# Copy new version
echo "📋 Copying to /Applications..."
cp -R "$APP_PATH" "/Applications/"

if [ $? -eq 0 ]; then
    echo "✅ ZoomIt installed successfully!"
    echo ""
    echo "🚀 Opening ZoomIt..."
    open "/Applications/ZoomIt.app"
else
    echo "❌ Failed to copy to /Applications"
    echo "   Try: sudo ./install.sh"
    exit 1
fi

