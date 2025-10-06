# In-App Purchase Screenshot Guide

## What You Need

For each IAP (Monthly, Annual, Lifetime), you need to upload a screenshot showing the premium feature.

## How to Take IAP Screenshots

### Option 1: Use Paywall Screen
1. Run app in simulator (iPhone 15 Pro Max)
2. Navigate to the paywall that shows subscription options
3. Take screenshot (⌘S)
4. This screenshot can be used for all three IAPs

### Option 2: Use Settings/Premium Screen
1. Run app in simulator
2. Go to Settings or Premium features screen
3. Take screenshot showing what premium unlocks
4. Upload to all three IAPs

## Screenshot Requirements

- **Minimum size:** 640 x 920 pixels
- **Recommended:** Use iPhone 6.7" display (1290 x 2796 px)
- **Format:** PNG or JPG
- **Content:** Must show the premium feature or subscription options

## Quick Steps

```bash
# 1. Open Xcode
# 2. Run on iPhone 15 Pro Max simulator
# 3. Navigate to paywall or premium screen
# 4. Press ⌘S to save screenshot
# 5. Find screenshot in ~/Desktop/
# 6. Upload to App Store Connect for each IAP
```

## Where to Upload

1. Go to App Store Connect
2. Your Apps → DailyQuipAI
3. Features → In-App Purchases
4. Click on each IAP (Monthly/Annual/Lifetime)
5. Scroll to "Review Information"
6. Upload screenshot under "App Review Screenshot"
7. Click "Save"
8. Repeat for all 3 IAPs
9. Submit each IAP for review

## Important Notes

- You can use the SAME screenshot for all 3 IAPs
- Screenshot just needs to show premium features exist
- After uploading screenshots, remember to "Submit for Review" for each IAP
- Don't submit app update until all IAPs are "Ready to Submit"

## Current IAPs to Screenshot

1. **Monthly Premium** - $0.99/month
   - Product ID: `com.dailyquipai.premium.monthly`

2. **Annual Premium** - $9.99/year
   - Product ID: `com.dailyquipai.premium.annual`

3. **Lifetime Premium** - $19.99 one-time
   - Product ID: `com.dailyquipai.premium.lifetime`
