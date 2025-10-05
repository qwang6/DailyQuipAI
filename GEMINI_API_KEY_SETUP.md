# Gemini API Key Configuration Guide

**⚠️ SECURITY NOTICE:** API keys are NEVER hardcoded. Use environment variables or .env files.

---

## Quick Setup

### Option 1: .env File (Recommended for Development)

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit .env and add your API key:**
   ```bash
   GEMINI_API_KEY=your_actual_api_key_here
   ```

3. **Run the app** - API key will be loaded automatically from .env

**Advantages:**
- ✅ Never committed to Git (in .gitignore)
- ✅ Easy to switch between different keys
- ✅ Team members can have their own keys
- ✅ Works in both Xcode and command-line builds

---

### Option 2: Xcode Environment Variable

1. **In Xcode:**
   - Product → Scheme → Edit Scheme... (or ⌘<)
   - Select "Run" on the left
   - Go to "Arguments" tab
   - Under "Environment Variables" click **+**
   - Name: `GEMINI_API_KEY`
   - Value: `YOUR_API_KEY_HERE`
   - ✅ Check "Enabled"
   - Click Close

2. **Run the app** - API key will be loaded from Xcode scheme

**Advantages:**
- ✅ Different keys for different schemes (Debug/Release/Archive)
- ✅ Per-developer configuration

---

## How It Works

**New Configuration System (`Configuration.swift`):**

```swift
// Centralized configuration management
let apiKey = Configuration.geminiAPIKey
```

**Priority order:**
1. **Xcode Environment Variable** `GEMINI_API_KEY`
2. **.env file** in project root
3. **Empty string** (will show warning in debug mode)

The system automatically searches for .env files and loads them securely.

---

## For App Store Submission

### Before Archive:

**Option A: Use Environment Variable**
1. Edit Scheme → Archive
2. Add `GEMINI_API_KEY` environment variable
3. Archive normally

**Option B: Provide via Settings UI**
1. User enters key in Settings after installing
2. Include instructions in app onboarding

**Recommended:** Option B for production (user provides their own key)

---

## Security Best Practices

### ✅ DO:
- Use environment variables for development
- Store in UserDefaults for user-provided keys
- Use Xcode schemes for different environments
- Add `.env` files to `.gitignore`

### ❌ DON'T:
- Hardcode API keys in source code
- Commit API keys to Git/GitHub
- Share API keys publicly
- Use same key for dev/prod

---

## Verify Configuration

**In Xcode console, you should see:**

**✅ When configured correctly:**
```
🚀 Calling Gemini API with model: gemini-2.5-flash
📤 Request body prepared
📥 Received response with status: 200
✅ Successfully got text from Gemini
```

**⚠️ When NOT configured:**
```
⚠️ WARNING: No Gemini API key configured!
💡 Set via:
   1. Xcode → Edit Scheme → Environment Variables → GEMINI_API_KEY
   2. Settings in-app (UserDefaults)
```

---

## Troubleshooting

### "No API key configured" warning

**Solution:**
1. Check Xcode scheme environment variables
2. Check if key is saved in Settings (if implemented)
3. Verify key is correct (starts with `AIza...`)

### API returns 400 error

**Solution:**
- Invalid API key
- Check for extra spaces or characters
- Verify key at: https://console.cloud.google.com/apis/credentials

### API returns 429 (Rate Limit)

**Solution:**
- Too many requests
- Wait a few minutes
- Check quota in Google Cloud Console

---

## Getting Your API Key

**⚠️ Important:**
- Never share API keys in documentation or code
- Each developer should use their own key
- Get new key at: https://aistudio.google.com/app/apikey

---

## Rotating API Key

**If the key was exposed:**

1. **Disable old key:**
   - Go to Google Cloud Console
   - API & Services → Credentials
   - Find the API key
   - Click "Disable" or "Delete"

2. **Create new key:**
   - Click "+ CREATE CREDENTIALS"
   - Select "API key"
   - Copy the new key
   - Restrict it to "Generative Language API"

3. **Update in Xcode:**
   - Edit Scheme → Environment Variables
   - Update `GEMINI_API_KEY` value
   - Re-run app

---

## For Team Development

**If working in a team:**

1. Create `.env` file (NOT committed to Git):
   ```bash
   GEMINI_API_KEY=your_actual_api_key_here
   ```

2. Add to `.gitignore`:
   ```
   .env
   *.env
   Config.plist
   ```

3. Each developer maintains their own `.env` file locally

---

## Next Steps

- [ ] Set up environment variable in Xcode scheme
- [ ] Test API key is working
- [ ] (Optional) Implement Settings UI for user-provided keys
- [ ] (Optional) Rotate API key if compromised
- [ ] Document for team members

**Status:** ✅ Hardcoded key removed, environment variable support added

---

**For more info:**
- Google AI Studio: https://makersuite.google.com/
- Gemini API Docs: https://ai.google.dev/tutorials/setup
