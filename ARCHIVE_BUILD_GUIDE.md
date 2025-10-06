# Archive Build Guide - How to Add API Key for App Store Submission

## Problem
When you archive the app for App Store submission, the `.env` file is not included in the build. This causes the app to fail with a 403 error because it can't find the API key.

## Solution
Add the API key to Info.plist **ONLY when creating an Archive for App Store submission**.

⚠️ **IMPORTANT: Do NOT commit Info.plist with the API key to GitHub!**

---

## Step-by-Step Guide

### When Creating an Archive Build

#### 1. Open Info.plist
```
DailyQuipAI/Info.plist
```

#### 2. Add API Key Entry
- Right-click in Info.plist
- Select "Add Row"
- Key: `GEMINI_API_KEY` (Type: String)
- Value: `YOUR_GEMINI_API_KEY_HERE`

Or manually add to Info.plist:
```xml
<key>GEMINI_API_KEY</key>
<string>YOUR_GEMINI_API_KEY_HERE</string>
```

#### 3. Create Archive
```
Product → Archive
```

#### 4. Upload to App Store Connect
```
Window → Organizer → Distribute App → App Store Connect
```

#### 5. **IMMEDIATELY REMOVE API KEY FROM INFO.PLIST**
After uploading, delete the GEMINI_API_KEY entry from Info.plist to prevent accidentally committing it.

---

## Alternative: Use Xcode Configuration

### Option A: Add to Release Scheme (Safer)

1. **Product → Scheme → Edit Scheme**
2. Select **Archive** (not Run)
3. Go to **Arguments** tab
4. Add Environment Variable:
   - Name: `GEMINI_API_KEY`
   - Value: `YOUR_GEMINI_API_KEY_HERE`
5. Archive the app

This way the API key is only in the scheme file (which can be excluded from git).

### Option B: Build Script (Advanced)

Create a build script that injects the API key during archive:

1. **Target → Build Phases → + → New Run Script Phase**
2. Add script:
```bash
if [ "${CONFIGURATION}" = "Release" ]; then
    /usr/libexec/PlistBuddy -c "Add :GEMINI_API_KEY string YOUR_GEMINI_API_KEY_HERE" "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
fi
```

---

## Verification

After archive, verify the API key is included:

1. Window → Organizer
2. Right-click archive → Show in Finder
3. Right-click .xcarchive → Show Package Contents
4. Products → Applications → DailyQuipAI.app → Show Package Contents
5. Open Info.plist and verify `GEMINI_API_KEY` exists

---

## Security Best Practices

### ✅ DO:
- Add API key to Info.plist ONLY when archiving
- Remove API key from Info.plist immediately after upload
- Keep API key in `.env` for local development
- Add Info.plist changes to .gitignore if needed

### ❌ DON'T:
- Commit Info.plist with API key to GitHub
- Leave API key in Info.plist after archiving
- Use the same API key for dev and production (ideally)

---

## Current Setup

**Development (Local Testing):**
- API key loaded from `.env` file
- `.env` is in `.gitignore` (never uploaded to GitHub)

**Production (App Store Build):**
- API key must be in Info.plist
- Add manually before Archive
- Remove immediately after upload

---

## Troubleshooting

### App crashes with 403 error in TestFlight
- API key was not included in the archive
- Rebuild archive with API key in Info.plist

### API key appears on GitHub
- You committed Info.plist with the key
- Follow the "API Key Compromised" guide in CLAUDE.md
- Revoke old key, create new key, force push to GitHub

---

**Created:** October 6, 2025
**For:** App Store Submission Build
