# Gemini API Key Configuration Guide

**⚠️ SECURITY NOTICE:** The hardcoded API key has been removed from the codebase for security.

---

## Quick Setup

### Option 1: Xcode Environment Variable (Recommended for Development)

1. **In Xcode:**
   - Product → Scheme → Edit Scheme... (or ⌘<)
   - Select "Run" on the left
   - Go to "Arguments" tab
   - Under "Environment Variables" click **+**
   - Name: `GEMINI_API_KEY`
   - Value: `YOUR_API_KEY_HERE`
   - ✅ Check "Enabled"
   - Click Close

2. **Your API key:**
   ```
   AIzaSyAxsKxX4ED02mnA5pOe9n86WIE5-PD5sv4
   ```

3. **Run the app** - API key will be loaded automatically

**Advantages:**
- ✅ Not committed to Git
- ✅ Easy to change
- ✅ Different keys for different schemes (Debug/Release)

---

### Option 2: Settings in App (User-Friendly)

**TODO:** Add Settings UI to configure API key

1. Open app → Settings
2. Tap "API Configuration"
3. Enter Gemini API key
4. Save

**Implementation needed in SettingsView.swift:**

```swift
Section("API Configuration") {
    SecureField("Gemini API Key", text: $apiKey)
        .autocapitalization(.none)
        .autocorrectionDisabled()

    Button("Save API Key") {
        UserDefaults.standard.set(apiKey, forKey: "geminiAPIKey")
    }
    .disabled(apiKey.isEmpty)
}
```

---

## How It Works

**Code changes in `DailyCardsViewModel.swift`:**

```swift
// Get API key from environment variable or UserDefaults
let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"]
    ?? UserDefaults.standard.string(forKey: "geminiAPIKey")
    ?? ""
```

**Priority order:**
1. **Environment variable** `GEMINI_API_KEY` (Xcode scheme)
2. **UserDefaults** `geminiAPIKey` (Settings in-app)
3. **Empty string** (will show warning in debug mode)

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

## Current API Key (For Reference)

**Key:** `AIzaSyAxsKxX4ED02mnA5pOe9n86WIE5-PD5sv4`

**⚠️ Important:**
- This key is already exposed in previous GitHub commits
- Consider rotating it if this is a production key
- Get new key at: https://makersuite.google.com/app/apikey

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
   GEMINI_API_KEY=AIzaSyAxsKxX4ED02mnA5pOe9n86WIE5-PD5sv4
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
