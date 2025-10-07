#!/bin/bash

# 验证最新Archive中是否包含API key

echo "🔍 Finding latest Archive..."
ARCHIVE=$(ls -t ~/Library/Developer/Xcode/Archives/*/*/*.xcarchive 2>/dev/null | head -1)

if [ -z "$ARCHIVE" ]; then
    echo "❌ No archives found. Please create an Archive first."
    echo "   Product → Archive"
    exit 1
fi

echo "📦 Latest Archive: $(basename "$ARCHIVE")"
echo ""

INFO_PLIST="$ARCHIVE/Products/Applications/DailyQuipAI.app/Info.plist"

if [ ! -f "$INFO_PLIST" ]; then
    echo "❌ Info.plist not found in archive"
    exit 1
fi

echo "🔑 Checking for GEMINI_API_KEY..."
API_KEY=$(/usr/libexec/PlistBuddy -c "Print :GEMINI_API_KEY" "$INFO_PLIST" 2>/dev/null)

if [ -z "$API_KEY" ]; then
    echo "❌ GEMINI_API_KEY NOT FOUND in archive!"
    echo ""
    echo "The archive does NOT contain the API key."
    echo "You need to add it to Info before archiving."
    exit 1
else
    echo "✅ GEMINI_API_KEY FOUND in archive!"
    echo ""
    echo "API Key: ${API_KEY:0:20}... (truncated for security)"
    echo ""
    echo "The archive is ready to upload! 🚀"
fi
