# App Store Publishing Checklist

## Pre-Submission Requirements

### 1. Apple Developer Account
- [ ] Enrolled in Apple Developer Program ($99/year)
- [ ] Team Agent or Admin role
- [ ] Agreements, Tax, and Banking completed

### 2. App Store Connect Setup
- [ ] Create App ID in Certificates, Identifiers & Profiles
  - Bundle ID: `com.qwang.dailyquipai` (or your chosen ID)
  - Enable capabilities: In-App Purchase
- [ ] Create App in App Store Connect
- [ ] Fill in App Information

### 3. Code & Build Preparation

#### Update Info.plist
- [ ] Set CFBundleShortVersionString (e.g., "1.0.0")
- [ ] Set CFBundleVersion (e.g., "1")
- [ ] Add Privacy Usage Descriptions:
  - NSUserTrackingUsageDescription (if tracking)
  - NSCalendarsUsageDescription (if using calendar)

#### Remove Debug Code
- [x] Remove debug logging from production
- [x] Remove debug sections from Settings
- [ ] Verify no test API keys are hardcoded

#### Code Signing
- [ ] Create Distribution Certificate
- [ ] Create App Store Provisioning Profile
- [ ] Configure signing in Xcode:
  - Target → Signing & Capabilities
  - Team: Select your team
  - Provisioning Profile: Select distribution profile

### 4. In-App Purchases Setup

Create 3 IAP products in App Store Connect:

#### Monthly Subscription
- [ ] Product ID: `com.qwang.dailyquipai.monthly`
- [ ] Reference Name: "DailyQuipAI Monthly Premium"
- [ ] Type: Auto-Renewable Subscription
- [ ] Subscription Group: "DailyQuipAI Premium"
- [ ] Price: $4.99/month
- [ ] Localization added
- [ ] Screenshot uploaded

#### Annual Subscription
- [ ] Product ID: `com.qwang.dailyquipai.annual`
- [ ] Reference Name: "DailyQuipAI Annual Premium"
- [ ] Type: Auto-Renewable Subscription
- [ ] Subscription Group: "DailyQuipAI Premium"
- [ ] Price: $39.99/year
- [ ] Localization added
- [ ] Screenshot uploaded

#### Lifetime Purchase
- [ ] Product ID: `com.qwang.dailyquipai.lifetime`
- [ ] Reference Name: "DailyQuipAI Lifetime Premium"
- [ ] Type: Non-Consumable
- [ ] Price: $79.99
- [ ] Localization added
- [ ] Screenshot uploaded

### 5. App Icon & Assets

- [ ] App Icon (1024x1024 PNG, no transparency, no alpha channel)
  - Required for App Store listing
- [ ] All icon sizes in Assets.xcassets
  - 20pt, 29pt, 40pt, 60pt, 76pt, 83.5pt (1x, 2x, 3x as needed)

### 6. Screenshots

Capture screenshots for:
- [ ] iPhone 6.9" (iPhone 17 Pro Max) - Required
- [ ] iPhone 6.7" (iPhone 15 Pro Max) - Required
- [ ] iPad 12.9" - Required (if supporting iPad)

Minimum:
- [ ] 3 screenshots per device size
- [ ] Maximum: 10 screenshots per device size

### 7. App Store Listing Content

- [x] App name (30 chars max): "DailyQuipAI"
- [x] Subtitle (30 chars max): "Daily Knowledge Cards"
- [x] Description (4000 chars max): See APP_STORE_LISTING.md
- [x] Keywords (100 chars): See APP_STORE_LISTING.md
- [x] Promotional text (170 chars): See APP_STORE_LISTING.md
- [ ] Support URL: Create and add
- [ ] Marketing URL: Create and add (optional)
- [x] Privacy Policy URL: Need to create
- [ ] Category: Education (Primary), Reference (Secondary)
- [ ] Age Rating: 4+

### 8. Privacy & Legal

#### Create Privacy Policy
- [ ] Host at: https://dailyquipai.app/privacy
- [ ] Include:
  - What data is collected (minimal)
  - How data is used
  - Third-party services (Gemini API)
  - User rights
  - Contact information

#### Create Terms of Service
- [ ] Host at: https://dailyquipai.app/terms
- [ ] Include:
  - Subscription terms
  - Refund policy
  - User responsibilities
  - Content ownership
  - Liability disclaimers

#### App Privacy in App Store Connect
- [ ] Complete privacy questionnaire
- [ ] Declare data collection practices
- [ ] Specify third-party SDKs used

### 9. Testing

- [ ] Test all subscription tiers
- [ ] Test restore purchases
- [ ] Test on multiple devices/iOS versions
- [ ] Test all swipe gestures
- [ ] Test category switching
- [ ] Test onboarding flow
- [ ] Test error handling (no network, etc.)
- [ ] Verify LLM API is working
- [ ] TestFlight beta testing (recommended)

### 10. Build & Upload

#### Archive the App
1. [ ] Select "Any iOS Device (arm64)" as build target
2. [ ] Product → Archive
3. [ ] Wait for archive to complete
4. [ ] Validate Archive
5. [ ] Distribute to App Store Connect

#### In App Store Connect
- [ ] Select uploaded build
- [ ] Add "What's New" notes
- [ ] Set release option:
  - Manual release (recommended for v1.0)
  - Automatic release
  - Scheduled release
- [ ] Enable App Store Search Ads (optional)

### 11. App Review Information

- [ ] Sign-in required: No
- [ ] Demo account: N/A
- [ ] Contact information:
  - First name
  - Last name
  - Email
  - Phone number
- [ ] Notes for reviewer:
  ```
  DailyQuipAI uses the Gemini API to generate knowledge cards.
  Free tier: 5 cards/day
  Premium unlocks unlimited cards.

  Test credentials not required - app works without sign-in.

  To test premium features, tap any subscription tier
  and use sandbox tester account.
  ```

### 12. Export Compliance

- [ ] Answer export compliance questions
  - Does your app use encryption?
  - If yes, is it exempt? (likely yes for HTTPS only)

### 13. Final Checks Before Submission

- [ ] All text proofread (no typos)
- [ ] All screenshots look professional
- [ ] App icon looks good in all contexts
- [ ] Privacy Policy & Terms accessible
- [ ] Support email/website working
- [ ] In-app purchases tested in sandbox
- [ ] All required metadata filled
- [ ] Age rating appropriate

### 14. Submit for Review

- [ ] Click "Submit for Review"
- [ ] Wait for "Waiting for Review" status
- [ ] Typical review time: 24-48 hours

### 15. Post-Submission

- [ ] Monitor status in App Store Connect
- [ ] Respond quickly to any rejection feedback
- [ ] Prepare social media announcements
- [ ] Create Product Hunt launch page
- [ ] Set up analytics/monitoring

## Common Rejection Reasons to Avoid

1. **Misleading metadata** - Ensure screenshots match actual app
2. **Broken features** - Test everything thoroughly
3. **Privacy issues** - Complete privacy questionnaire accurately
4. **Incomplete IAP** - All IAP products must be ready
5. **Guideline violations** - Review App Store Review Guidelines
6. **Missing information** - Fill all required fields completely

## After Approval

- [ ] Celebrate! 🎉
- [ ] Monitor crash reports
- [ ] Track analytics
- [ ] Respond to user reviews
- [ ] Plan v1.1 features
- [ ] Marketing & promotion

## Useful Links

- App Store Connect: https://appstoreconnect.apple.com
- Developer Portal: https://developer.apple.com/account
- Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

## Estimated Timeline

- Preparation: 1-3 days
- App Review: 1-3 days
- Total: 2-6 days from submission to launch

Good luck with your launch! 🚀
