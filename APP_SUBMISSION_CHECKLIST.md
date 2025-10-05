# DailyQuipAI - App Store Submission Checklist

**App Name:** DailyQuipAI
**Bundle ID:** com.qwang.dailyquipai
**Version:** 1.0.0
**Build:** 1
**Last Updated:** October 4, 2025

---

## ✅ PRE-SUBMISSION CHECKLIST

### 1. Apple Developer Account
- [ ] Enrolled in Apple Developer Program ($99/year)
- [ ] Team Agent or Admin role verified
- [ ] Agreements, Tax, and Banking completed in App Store Connect

### 2. App Store Connect Setup
- [ ] Create App ID: `com.qwang.dailyquipai`
  - Enable: In-App Purchase capability
- [ ] Create new App in App Store Connect
- [ ] Select name: **DailyQuipAI**

### 3. In-App Purchase Products

Create these 3 IAP products in App Store Connect → Features → In-App Purchases:

#### Monthly Subscription
- **Product ID:** `com.qwang.dailyquipai.monthly`
- **Reference Name:** DailyQuipAI Monthly Premium
- **Type:** Auto-Renewable Subscription
- **Subscription Group:** DailyQuipAI Premium
- **Price:** $4.99/month
- **Localization:** English (US)
- **Review Screenshot:** Required

#### Annual Subscription
- **Product ID:** `com.qwang.dailyquipai.annual`
- **Reference Name:** DailyQuipAI Annual Premium
- **Type:** Auto-Renewable Subscription
- **Subscription Group:** DailyQuipAI Premium
- **Price:** $39.99/year
- **Localization:** English (US)
- **Review Screenshot:** Required

#### Lifetime Purchase
- **Product ID:** `com.qwang.dailyquipai.lifetime`
- **Reference Name:** DailyQuipAI Lifetime Premium
- **Type:** Non-Consumable
- **Price:** $79.99
- **Localization:** English (US)
- **Review Screenshot:** Required

**Important:** All IAP products must be "Ready to Submit" before app submission.

---

## 📱 APP ASSETS REQUIRED

### App Icon (Required)
- [ ] **1024x1024 PNG** for App Store listing
  - No transparency
  - No alpha channel
  - RGB color space
  - Upload to App Store Connect → App Information

- [ ] All icon sizes in `Assets.xcassets/AppIcon.appiconset/`:
  - iPhone: 60pt@2x, 60pt@3x, 40pt@2x, 40pt@3x, 29pt@2x, 29pt@3x, 20pt@2x, 20pt@3x
  - iPad: 76pt@2x, 40pt@2x, 29pt@2x, 20pt@2x

**Current Status:** ⚠️ **MISSING - Need to create app icon**

### Screenshots (Required)

**iPhone 6.9" (iPhone 17 Pro Max)** - Required
- [ ] Screenshot 1: Welcome screen with glass morphism cards
- [ ] Screenshot 2: Category selection showing all 6 categories
- [ ] Screenshot 3: Single card expanded (History category)
- [ ] Screenshot 4: Swipe gestures demonstration
- [ ] Screenshot 5: Premium paywall screen

**iPhone 6.7" (iPhone 15 Pro Max)** - Required
- [ ] Same 5 screenshots at 6.7" resolution

**iPad Pro 12.9"** - Optional but Recommended
- [ ] Same 5 screenshots at iPad resolution

**Specifications:**
- Format: PNG or JPEG
- Color space: sRGB or Display P3
- Minimum 3 screenshots, maximum 10 per device size
- No alpha channel

**Current Status:** ⚠️ **NEED TO CAPTURE**

---

## 📝 APP STORE METADATA

### App Information
- [x] **App Name:** DailyQuipAI (30 chars max)
- [x] **Subtitle:** Daily Knowledge Cards (30 chars max)
- [x] **Primary Category:** Education
- [x] **Secondary Category:** Reference
- [x] **Age Rating:** 4+

### Description & Marketing
- [x] **Promotional Text:** (170 chars)
  > Discover fascinating knowledge every day with beautiful, swipeable cards. Learn about history, science, art, and more in just minutes.

- [x] **Description:** (4000 chars) - See APP_STORE_LISTING.md

- [x] **Keywords:** (100 chars)
  > knowledge,learning,education,daily,facts,trivia,science,history,art,cards,study,brain,smart

### URLs & Contact
- [ ] **Support URL:** https://dailyquipai.app/support
  - ⚠️ **Action needed:** Create website or landing page

- [x] **Privacy Policy URL:** https://dailyquipai.app/privacy
  - ⚠️ **Action needed:** Host PRIVACY_POLICY.md online

- [x] **Terms of Service URL:** https://dailyquipai.app/terms
  - ⚠️ **Action needed:** Host TERMS_OF_SERVICE.md online

- [ ] **Marketing URL:** https://dailyquipai.app (optional)

### What's New
- [x] **Version 1.0.0 Release Notes:**
  ```
  Initial release of DailyQuipAI - your daily knowledge companion.

  Features:
  • Beautiful glass morphism design
  • 6 knowledge categories
  • Swipe-based interactions
  • Daily learning goals
  • Smart content generation
  • Premium subscription options

  Start your learning journey today!
  ```

---

## 🔐 PRIVACY & COMPLIANCE

### App Privacy Questionnaire
Complete in App Store Connect → App Privacy:

**Data Collection:**
- [ ] **User Content:** Device-local preferences only
  - Purpose: App functionality
  - Not linked to identity
  - Not used for tracking

- [ ] **Identifiers:** None collected

- [ ] **Third-party APIs:**
  - Google Gemini API (content generation)
  - No personal data shared

**Answers:**
- Do you collect data from this app? → **No** (all data stored locally)
- Does this app use third-party SDKs? → **Yes** (Gemini API for content)
- Does this app track users? → **No**

### Export Compliance
- [ ] **Does your app use encryption?**
  - Answer: **Yes** (HTTPS only)
  - Qualifies for exemption: **Yes**
  - Category: Standard encryption (HTTPS/TLS)

---

## 🧪 TESTING CHECKLIST

### Functional Testing
- [ ] Test free tier (5 cards/day limit)
- [ ] Test daily reset at midnight
- [ ] Test all 6 categories load correctly
- [ ] Test swipe gestures (left, right, up, down)
- [ ] Test card flip animation
- [ ] Test subscription purchase flow (sandbox)
- [ ] Test restore purchases
- [ ] Test premium unlimited cards
- [ ] Test onboarding flow (first launch)
- [ ] Test settings persistence
- [ ] Test offline mode (graceful error handling)

### Device Testing
- [ ] iPhone SE (smallest screen)
- [ ] iPhone 15 Pro (standard)
- [ ] iPhone 17 Pro Max (largest)
- [ ] iPad 11" (if supporting iPad)
- [ ] iPad 12.9" Pro (if supporting iPad)

### iOS Version Testing
- [ ] iOS 26.0 (minimum supported version)
- [ ] Latest iOS version

### Gemini API Testing
- [ ] Verify API key is configured (via settings or environment)
- [ ] Test card generation succeeds
- [ ] Test error handling (invalid API key, network error)
- [ ] Verify batch generation (5 cards per request)
- [ ] Check API cost monitoring

---

## 🔧 BUILD PREPARATION

### Code Configuration
- [x] **Bundle Identifier:** com.qwang.dailyquipai
- [x] **Version Number:** 1.0.0 (CFBundleShortVersionString)
- [x] **Build Number:** 1 (CFBundleVersion)
- [x] **Deployment Target:** iOS 26.0
- [x] **Debug code removed:** Settings debug tools removed
- [ ] **Gemini API Key:**
  - ⚠️ **Action:** Add via Settings UI or environment variable
  - Never hardcode in source

### Code Signing
- [ ] **Distribution Certificate:** Created in developer portal
- [ ] **App Store Provisioning Profile:** Created for com.qwang.dailyquipai
- [ ] **Signing configured in Xcode:**
  - Target → Signing & Capabilities
  - Team: Select your team
  - Profile: Distribution (App Store)

### Build Settings
- [ ] **Build Configuration:** Release
- [ ] **Optimization Level:** -O (Optimize for Speed)
- [ ] **Strip Debug Symbols:** Yes
- [ ] **Enable Bitcode:** No (deprecated)

---

## 📦 ARCHIVE & UPLOAD

### Archive Process
1. [ ] Select build target: **Any iOS Device (arm64)**
2. [ ] Clean build folder: Product → Clean Build Folder
3. [ ] Archive: Product → Archive
4. [ ] Wait for archive to complete

### Validation
1. [ ] Open Organizer → Archives
2. [ ] Select DailyQuipAI archive
3. [ ] Click **Validate App**
4. [ ] Choose distribution method: **App Store Connect**
5. [ ] Review validation results
6. [ ] Fix any errors or warnings

### Upload to App Store Connect
1. [ ] Click **Distribute App**
2. [ ] Choose: **App Store Connect**
3. [ ] Upload options:
   - [ ] Include bitcode: No
   - [ ] Upload symbols: Yes
   - [ ] Manage Version and Build Number: Automatic
4. [ ] Review summary and upload
5. [ ] Wait for processing (10-30 minutes)

---

## 📤 SUBMISSION

### App Review Information
- [ ] **Sign-in required:** No
- [ ] **Demo account:** N/A

- [ ] **Contact Information:**
  - First name: [Your first name]
  - Last name: [Your last name]
  - Email: support@dailyquipai.app
  - Phone: [Your phone number]

- [ ] **Notes for Reviewer:**
  ```
  DailyQuipAI uses the Google Gemini API to generate knowledge cards.

  Free tier: 5 cards/day
  Premium: Unlimited cards

  The app works without sign-in - no account required.

  To test premium features:
  1. Tap any subscription tier in the paywall
  2. Use Apple's sandbox tester account for testing

  Gemini API key is configured via environment variable for testing.

  All data is stored locally on device - no backend server.
  ```

### Final Checks
- [ ] All screenshots uploaded
- [ ] App icon uploaded (1024x1024)
- [ ] Privacy policy accessible online
- [ ] Terms of service accessible online
- [ ] Support URL working
- [ ] All metadata proofread (no typos)
- [ ] All IAP products "Ready to Submit"
- [ ] Age rating set to 4+
- [ ] Categories selected (Education, Reference)

### Submit
- [ ] Click **Add for Review**
- [ ] Select build from dropdown
- [ ] Review all information
- [ ] Click **Submit for Review**

---

## ⏱️ AFTER SUBMISSION

### Monitor Status
- [ ] Check App Store Connect for status updates
- [ ] Expected states:
  - Waiting for Review (1-2 days)
  - In Review (24-48 hours)
  - Pending Developer Release / Ready for Sale

### Respond to Feedback
- [ ] Check for App Review messages daily
- [ ] Respond within 24 hours if contacted
- [ ] Address any rejection feedback promptly

### Common Rejection Reasons to Avoid
1. ❌ **Screenshots don't match app** - Ensure accuracy
2. ❌ **Broken features** - Test thoroughly
3. ❌ **Privacy policy incomplete** - Be comprehensive
4. ❌ **IAP not configured** - All products must be ready
5. ❌ **Misleading metadata** - Be accurate and honest

---

## 🚀 POST-APPROVAL

### Launch Checklist
- [ ] Verify app is live on App Store
- [ ] Test download and installation
- [ ] Test in-app purchases in production
- [ ] Monitor crash reports
- [ ] Monitor user reviews
- [ ] Respond to user feedback

### Marketing & Promotion
- [ ] Announce on social media
- [ ] Submit to Product Hunt
- [ ] Contact tech bloggers/reviewers
- [ ] Create press kit
- [ ] Set up analytics tracking

### Ongoing Maintenance
- [ ] Monitor API costs (Gemini usage)
- [ ] Track subscription metrics
- [ ] Plan v1.1 features based on feedback
- [ ] Prepare bug fix updates if needed

---

## 📊 METRICS TO TRACK

- Downloads
- Daily Active Users (DAU)
- Free → Premium conversion rate
- Subscription retention rate
- Gemini API costs
- Crash-free sessions
- App Store rating & reviews

---

## ⚠️ CRITICAL ACTION ITEMS

### Before Submission:
1. **CREATE APP ICON** (1024x1024 PNG + all sizes)
2. **CAPTURE SCREENSHOTS** (iPhone 6.9", 6.7", optional iPad)
3. **HOST PRIVACY POLICY** (at https://dailyquipai.app/privacy)
4. **HOST TERMS OF SERVICE** (at https://dailyquipai.app/terms)
5. **CREATE SUPPORT PAGE** (at https://dailyquipai.app/support)
6. **CONFIGURE GEMINI API KEY** (via Settings or env variable)
7. **CREATE IAP PRODUCTS** (monthly, annual, lifetime)
8. **CREATE DISTRIBUTION CERTIFICATE & PROFILE**
9. **TEST ON REAL DEVICES** (iPhone + iPad)

### Estimated Timeline:
- **Preparation:** 2-3 days (assets + testing)
- **App Review:** 1-3 days
- **Total:** 3-6 days from readiness to launch

---

## 📞 SUPPORT CONTACTS

- **Apple Developer Support:** https://developer.apple.com/contact/
- **App Store Connect Help:** https://developer.apple.com/help/app-store-connect/
- **App Review:** https://developer.apple.com/contact/app-store/

---

## ✅ FINAL SIGN-OFF

Before clicking "Submit for Review", confirm:
- [ ] I have tested the app thoroughly
- [ ] All assets are uploaded and correct
- [ ] Privacy policy and terms are accessible
- [ ] IAP products are configured and ready
- [ ] I have read App Store Review Guidelines
- [ ] I am ready for launch 🚀

**Good luck with your DailyQuipAI launch!**
