#!/bin/bash

echo "🔍 Checking latest Archive for API key..."
echo ""

# Find the most recent archive
ARCHIVE=$(ls -t ~/Library/Developer/Xcode/Archives/*/*/*.xcarchive 2>/dev/null | head -1)

if [ -z "$ARCHIVE" ]; then
    echo "❌ No archive found!"
    echo "Please create an Archive first (Product → Archive in Xcode)"
    exit 1
fi

echo "📦 Archive found: $(basename "$ARCHIVE")"
echo "📅 Date: $(basename $(dirname "$ARCHIVE"))"
echo ""

# Check if GeneratedConfig.swift is compiled into the binary
APP_PATH="$ARCHIVE/Products/Applications/DailyQuipAI.app/DailyQuipAI"

if [ ! -f "$APP_PATH" ]; then
    echo "❌ App binary not found at: $APP_PATH"
    exit 1
fi

# Use strings to check if the API key is in the binary
if strings "$APP_PATH" | grep -q "AIzaSy"; then
    echo "✅ API KEY FOUND in compiled binary!"
    echo ""
    echo "🎉 Archive is ready for upload to App Store Connect"
else
    echo "❌ API KEY NOT FOUND in binary!"
    echo ""
    echo "⚠️  Please check:"
    echo "   1. Config.xcconfig exists and has GEMINI_API_KEY"
    echo "   2. GeneratedConfig.swift exists with the API key"
    echo "   3. Configuration.swift references GeneratedConfig"
fi
