# App Store Submission Checklist

## 🚀 Complete Step-by-Step Guide

---

## PHASE 1: Pre-Submission Preparation

### ✅ 1.1 App Binary & Build

- [ ] **Clean build** with no warnings or errors
- [ ] **Archive created** successfully in Xcode
- [ ] **Build uploaded** to App Store Connect
- [ ] **Processing complete** (wait for "Ready to Submit" status)
- [ ] **TestFlight testing** completed (optional but recommended)

**How to Archive:**
```bash
# In Xcode:
1. Product → Clean Build Folder (⇧⌘K)
2. Select "Any iOS Device" as target
3. Product → Archive
4. Wait for archive to complete
5. Organizer → Distribute App → App Store Connect
```

---

### ✅ 1.2 App Icon

- [ ] **1024x1024 icon** created and added to Assets.xcassets
- [ ] **No transparency** (must be opaque)
- [ ] **No rounded corners** (Apple adds them automatically)
- [ ] **High quality** PNG format
- [ ] **Icon displays** in App Store Connect

**Current icon location:**
`DailyQuipAI/Assets.xcassets/AppIcon.appiconset/icon_1024x1024.png`

---

### ✅ 1.3 Screenshots

- [ ] **Minimum 3 screenshots** for iPhone 6.7" (1290 x 2796 px)
- [ ] Screenshots show **real app content** (not placeholders)
- [ ] **Text is readable** on all screenshots
- [ ] **No sensitive information** visible
- [ ] Screenshots are **in order** (best first)

**Required sizes:**
- iPhone 6.7": 1290 x 2796 px (iPhone 15 Pro Max)
- Optional: 6.5" and 5.5" sizes

**See:** `SCREENSHOT_REQUIREMENTS.md` for details

---

### ✅ 1.4 Website & Legal Pages

- [ ] **GitHub Pages enabled** with `/docs` folder
- [ ] **Privacy Policy** live at: https://qwang6.github.io/DailyQuipAI/privacy.html
- [ ] **Support page** live at: https://qwang6.github.io/DailyQuipAI/support.html
- [ ] **Terms of Service** live at: https://qwang6.github.io/DailyQuipAI/terms.html
- [ ] All pages **accessible** and **load correctly**

**Setup guide:** `GITHUB_PAGES_SETUP.md`

---

## PHASE 2: App Store Connect Configuration

### ✅ 2.1 App Information

Navigate to: **App Store Connect → My Apps → DailyQuipAI → App Information**

- [ ] **Bundle ID:** `com.yourcompany.DailyQuipAI` (verify correct)
- [ ] **SKU:** `DAILYQUIPAI001` (or your unique identifier)
- [ ] **Primary Language:** English (U.S.)
- [ ] **Category:** Education
- [ ] **Secondary Category:** Reference (optional)
- [ ] **Privacy Policy URL:** https://qwang6.github.io/DailyQuipAI/privacy.html
- [ ] **Copyright:** © 2025 DailyQuipAI. All rights reserved.

---

### ✅ 2.2 Pricing & Availability

- [ ] **Price:** Free (with In-App Purchases)
- [ ] **Availability:** All countries and regions
- [ ] **Pre-Order:** Not available (for first version)

---

### ✅ 2.3 App Privacy

Navigate to: **App Privacy**

- [ ] **Do you collect data from this app?** Select **NO**
- [ ] Privacy policy URL confirmed
- [ ] Privacy questionnaire completed

**Important:** We don't collect ANY data, so answer NO to all questions.

---

### ✅ 2.4 In-App Purchases

Navigate to: **Features → In-App Purchases**

Create 3 IAPs:

#### IAP 1: Monthly Premium
- [ ] **Type:** Auto-Renewable Subscription
- [ ] **Product ID:** `com.dailyquipai.premium.monthly`
- [ ] **Reference Name:** Monthly Premium Subscription
- [ ] **Price:** $0.99
- [ ] **Subscription Duration:** 1 month
- [ ] **Review screenshot** uploaded
- [ ] **Review notes** added
- [ ] **Status:** Ready to Submit

#### IAP 2: Annual Premium
- [ ] **Type:** Auto-Renewable Subscription
- [ ] **Product ID:** `com.dailyquipai.premium.annual`
- [ ] **Reference Name:** Annual Premium Subscription
- [ ] **Price:** $9.99
- [ ] **Subscription Duration:** 1 year
- [ ] **Review screenshot** uploaded
- [ ] **Review notes** added
- [ ] **Status:** Ready to Submit

#### IAP 3: Lifetime Premium
- [ ] **Type:** Non-Consumable
- [ ] **Product ID:** `com.dailyquipai.premium.lifetime`
- [ ] **Reference Name:** Lifetime Premium Access
- [ ] **Price:** $19.99
- [ ] **Review screenshot** uploaded
- [ ] **Review notes** added
- [ ] **Status:** Ready to Submit

**Important:** Create subscription group for auto-renewable subscriptions

---

### ✅ 2.5 Age Rating

Navigate to: **App Information → Age Rating**

Answer questionnaire:
- [ ] **All violence questions:** None
- [ ] **Sexual content:** None
- [ ] **Profanity:** None
- [ ] **Alcohol/Drugs:** None
- [ ] **Mature themes:** None
- [ ] **Gambling:** None
- [ ] **Horror:** None

**Result should be:** 4+ (Everyone)

---

## PHASE 3: Version Information

Navigate to: **iOS App → [Version] → Prepare for Submission**

### ✅ 3.1 Screenshots & App Preview

- [ ] **6.7" Display screenshots** uploaded (3-10 images)
- [ ] **6.5" Display screenshots** uploaded (optional)
- [ ] **5.5" Display screenshots** uploaded (optional)
- [ ] **iPad screenshots** uploaded (if supporting iPad)
- [ ] Screenshots in **correct order**

---

### ✅ 3.2 Promotional Text (170 char max)

```
🎉 NEW: Category filters, improved AI content, and beautiful redesign!
Discover fascinating knowledge across 6 categories. Start learning smarter today!
```

- [ ] **Promotional text** entered
- [ ] **Character count** under 170

---

### ✅ 3.3 Description (4000 char max)

Copy from: `APP_STORE_METADATA.md` → English Description

- [ ] **App description** entered
- [ ] **Highlights key features**
- [ ] **Includes subscription info**
- [ ] **No spelling errors**
- [ ] **Character count** under 4000

---

### ✅ 3.4 Keywords (100 char max)

```
learning,education,knowledge,daily,AI,cards,facts,trivia,study,brain
```

- [ ] **Keywords** entered (comma-separated)
- [ ] **Character count** under 100
- [ ] **No app name** in keywords
- [ ] **No duplicate words**

---

### ✅ 3.5 Support URL

```
https://qwang6.github.io/DailyQuipAI/support.html
```

- [ ] **Support URL** entered and accessible

---

### ✅ 3.6 Marketing URL (Optional)

```
https://qwang6.github.io/DailyQuipAI/
```

- [ ] **Marketing URL** entered (optional)

---

### ✅ 3.7 What's New (4000 char max)

Copy from: `APP_STORE_METADATA.md` → Version 1.0.0 Release Notes

- [ ] **Release notes** entered
- [ ] **Highlights main features** for v1.0
- [ ] **Character count** under 4000

---

## PHASE 4: Build Selection

### ✅ 4.1 Select Build

- [ ] **Build** selected from dropdown
- [ ] **Correct version number** (e.g., 1.0.0)
- [ ] **Build number** correct (e.g., 1)
- [ ] **Export Compliance** answered (usually NO for educational apps)

**Export Compliance:**
- Does your app use encryption? → **NO** (unless using custom encryption)

---

## PHASE 5: App Review Information

### ✅ 5.1 Contact Information

- [ ] **First Name:** [Your Name]
- [ ] **Last Name:** [Your Last Name]
- [ ] **Phone Number:** [Your Phone]
- [ ] **Email:** support@dailyquipai.app

---

### ✅ 5.2 Demo Account (if needed)

- [ ] **Sign-in required?** NO
- [ ] *(Skip username/password)*

---

### ✅ 5.3 Notes for Reviewer

Copy from: `APP_STORE_METADATA.md` → Notes for Reviewer

```
Thank you for reviewing DailyQuipAI!

TESTING INSTRUCTIONS:
1. Launch app and complete onboarding
2. View daily knowledge cards (free tier: 5 cards/day)
3. Test swipe gestures (left=learned, right=save, up=next, down=previous)
4. Test category filtering
5. Check subscription paywall appears after 5 cards

IMPORTANT NOTES:
- Requires internet connection for generating cards (Google Gemini API)
- No user data collected - all stored locally
- Educational content appropriate for all ages (4+)

Contact: support@dailyquipai.app if questions.

Thank you!
```

- [ ] **Notes** entered
- [ ] **Clear instructions** for reviewer
- [ ] **API key note** included
- [ ] **Contact info** provided

---

### ✅ 5.4 Attachments (if needed)

- [ ] Upload any demo videos or documents (optional)

---

## PHASE 6: Version Release

### ✅ 6.1 Version Release Options

Choose one:
- [ ] **Manually release this version** (recommended for first release)
- [ ] Automatically release after approval
- [ ] Automatically release on specific date

**Recommendation:** Choose manual for first release

---

## PHASE 7: Pre-Submission Final Checks

### ✅ 7.1 Review Everything

- [ ] **All required fields** filled
- [ ] **No typos** in description or metadata
- [ ] **Screenshots look good**
- [ ] **Icon displays** correctly
- [ ] **Build selected** and correct
- [ ] **IAPs created** and ready
- [ ] **Privacy settings** correct
- [ ] **Age rating** correct (4+)

---

### ✅ 7.2 Test One More Time

- [ ] **Run app** from the uploaded build via TestFlight
- [ ] **No crashes** on app launch
- [ ] **Cards generate** correctly
- [ ] **Swipe gestures** work
- [ ] **Subscriptions** can be initiated (test in sandbox)
- [ ] **Settings** work
- [ ] **No console errors**

---

### ✅ 7.3 Links Work

- [ ] **Privacy Policy URL** loads
- [ ] **Support URL** loads
- [ ] **Marketing URL** loads (if added)
- [ ] All links open in browser correctly

---

## PHASE 8: SUBMIT! 🚀

### ✅ 8.1 Final Submission

- [ ] Scroll to bottom of page
- [ ] Click **"Submit for Review"** button
- [ ] Confirm submission
- [ ] **Status changes** to "Waiting for Review"

---

### ✅ 8.2 After Submission

**What happens next:**

1. **Waiting for Review** (1-3 days usually)
   - Apple reviews your submission
   - You'll receive emails about status changes

2. **In Review** (1-2 days)
   - Apple is actively reviewing
   - Don't make changes now!

3. **Pending Developer Release** or **Ready for Sale**
   - If approved: Congrats! 🎉
   - If rejected: Read feedback and resubmit

**Timeline:** Usually 2-7 days from submission to decision

---

### ✅ 8.3 Common Rejection Reasons & Fixes

**If rejected, common issues:**

1. **Icon issue**
   - Fix: Re-export icon without transparency

2. **Missing subscription terms**
   - Fix: Ensure IAP descriptions are clear

3. **Privacy policy unclear**
   - Fix: Update privacy.html to be more specific

4. **Crashes on review**
   - Fix: Test more thoroughly, fix bugs, resubmit

5. **Misleading screenshots**
   - Fix: Use actual app screenshots only

6. **API key not working**
   - Fix: Ensure .env or environment variable is set

**Always respond promptly** to Apple's feedback and resubmit quickly.

---

## ✅ QUICK REFERENCE CHECKLIST

**Before clicking Submit:**

- [ ] Build uploaded & processed ✅
- [ ] Icon 1024x1024 no transparency ✅
- [ ] 3+ screenshots (1290x2796) ✅
- [ ] Privacy Policy live & linked ✅
- [ ] Support URL live & linked ✅
- [ ] Description, keywords filled ✅
- [ ] IAPs created & ready ✅
- [ ] Age rating 4+ ✅
- [ ] App Privacy: NO data collection ✅
- [ ] Reviewer notes added ✅
- [ ] Tested in TestFlight ✅

**All checked?** → **SUBMIT!** 🎉

---

## 📧 Support

**Questions during submission?**
- Email: support@dailyquipai.app
- Check: `APP_STORE_METADATA.md` for copy-paste content
- See: `GITHUB_PAGES_SETUP.md` for website setup

---

**Last Updated:** October 4, 2025
**Version:** 1.0.0

**GOOD LUCK!** 🍀🚀
