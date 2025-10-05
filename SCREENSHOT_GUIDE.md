# DailyQuipAI - Screenshot Guide for App Store

## Required Screenshots

Apple requires screenshots for the following device sizes:

### iPhone 6.9" (iPhone 17 Pro Max) - **REQUIRED**
- Resolution: 1320 x 2868 pixels
- Device: iPhone 17 Pro Max, iPhone 15 Pro Max
- Minimum: 3 screenshots
- Maximum: 10 screenshots

### iPhone 6.7" (iPhone 15 Plus) - **REQUIRED**
- Resolution: 1290 x 2796 pixels
- Device: iPhone 15 Plus, iPhone 14 Plus
- Minimum: 3 screenshots
- Maximum: 10 screenshots

### iPad Pro 12.9" (6th Gen) - **Optional**
- Resolution: 2048 x 2732 pixels (portrait)
- Only required if you support iPad

---

## Recommended Screenshot Set (5 Screenshots)

### 📸 Screenshot 1: Welcome/Hero Screen
**Purpose:** Show the app's beautiful design and value proposition

**Content:**
- Main daily cards view with glass morphism design
- Show 2-3 overlapping cards with different categories
- Category filter bar visible at top
- Clean, vibrant, eye-catching

**Categories to show:**
- History (purple gradient)
- Science (blue gradient)
- Art (pink gradient)

**Text overlay (optional):**
> "Discover Something New Every Day"

**iPhone simulator commands:**
```bash
# Launch app on iPhone 17 Pro Max simulator
xcrun simctl boot "iPhone 17 Pro Max"
open -a Simulator

# Take screenshot (Cmd+S in Simulator)
# Or: xcrun simctl io booted screenshot screenshot_1.png
```

---

### 📸 Screenshot 2: Category Selection
**Purpose:** Showcase all 6 knowledge categories

**Content:**
- Settings view showing category preferences
- OR: Custom view with all 6 categories displayed
- Show category icons and colors clearly

**Categories to highlight:**
- 🏛️ History (Purple)
- 🔬 Science (Blue)
- 🎨 Art (Pink)
- 💡 Life (Orange)
- 💰 Finance (Green)
- 🧘 Philosophy (Indigo)

**Text overlay (optional):**
> "6 Engaging Categories"

---

### 📸 Screenshot 3: Card Content Detail
**Purpose:** Show the quality and depth of content

**Content:**
- Single expanded card (flipped to show full content)
- Use a History or Science card
- Show well-formatted, readable text
- Category tag visible
- Beautiful background gradient

**Example card title:**
> "The Butterfly Effect in Chaos Theory"

**Text overlay (optional):**
> "Rich, AI-Generated Content"

---

### 📸 Screenshot 4: Swipe Gestures
**Purpose:** Demonstrate intuitive interaction

**Content:**
- Card mid-swipe with visual indicators
- Show swipe left (mark as learned) gesture
- OR: Show overlay graphics with swipe directions

**Visual elements:**
- Arrow indicating swipe direction
- "Swipe left to mark as learned" text
- "Swipe right to save" text
- Card with slight rotation/movement

**Text overlay:**
> "Simple Swipe Gestures"

**Note:** You may need to mock this with design tools (Figma, Sketch) or add temporary UI elements for the screenshot.

---

### 📸 Screenshot 5: Premium/Paywall
**Purpose:** Show subscription options clearly

**Content:**
- Paywall view with all 3 tiers
- Monthly: $4.99/month
- Annual: $39.99/year (SAVE 33%)
- Lifetime: $79.99

**Highlight features:**
- ✓ Unlimited daily cards
- ✓ All categories
- ✓ Advanced analytics
- ✓ Ad-free experience

**Text overlay (optional):**
> "Unlock Unlimited Knowledge"

---

## Alternative Screenshot Ideas

### 📸 Alt A: Progress Tracking
- Show statistics: cards learned, days streak, etc.
- Elegant charts and visualizations
- (If you implement analytics UI)

### 📸 Alt B: Onboarding Flow
- Welcome screen with app logo
- "Set your daily learning goal"
- Beautiful, inviting design

### 📸 Alt C: Dark Mode (if supported)
- Same views but in dark mode
- Shows versatility and modern design

---

## Screenshot Requirements

### Technical Specifications
- **Format:** PNG or JPEG
- **Color Space:** sRGB or Display P3
- **No transparency**
- **No alpha channel**
- **File size:** Under 500 KB per screenshot recommended

### Content Guidelines
✅ **DO:**
- Use actual app UI
- Show real, high-quality content
- Make text readable
- Use vibrant, appealing colors
- Show key features clearly
- Add subtle text overlays if helpful

❌ **DON'T:**
- Use placeholder text ("Lorem ipsum")
- Include device frames (Apple adds these automatically)
- Show bugs or errors
- Use copyrighted images
- Mislead about features
- Include pricing in screenshots (can change)

---

## How to Capture Screenshots

### Method 1: Xcode Simulator (Recommended)

```bash
# 1. Launch iPhone 17 Pro Max simulator
xcrun simctl boot "iPhone 17 Pro Max"
open -a Simulator

# 2. Run your app
# (Use Xcode: Product → Run)

# 3. Navigate to the screen you want to capture

# 4. Take screenshot
# Option A: Press Cmd+S in Simulator
# Option B: xcrun simctl io booted screenshot ~/Desktop/screenshot_1.png

# 5. Repeat for iPhone 15 Plus (6.7")
xcrun simctl boot "iPhone 15 Plus"
# ... repeat steps
```

### Method 2: Real Device
1. Connect iPhone to Mac
2. Open Xcode → Window → Devices and Simulators
3. Select your device
4. Click "Take Screenshot" button
5. Screenshot appears on Desktop

### Method 3: Simulator with Debug Menu
1. Run app in Simulator
2. Navigate to screen
3. Simulator → File → New Screen Shot (⌘S)

---

## Screenshot Editing

### Tools to Use
- **Preview** (macOS built-in) - Basic cropping/resizing
- **Figma** - Add text overlays, mockups
- **Sketch** - Professional design
- **Pixelmator Pro** - Advanced editing

### Common Edits
1. **Add text overlays** (feature highlights)
2. **Crop to exact dimensions** (if needed)
3. **Enhance colors** slightly (don't overdo)
4. **Add subtle shadows** to cards (if not showing)

### Text Overlay Best Practices
- Use system fonts (SF Pro)
- Keep text minimal (5-8 words max)
- Ensure high contrast (white text on dark, etc.)
- Position text in safe areas (not too close to edges)

---

## Upload to App Store Connect

1. Log in to App Store Connect
2. Select your app: **DailyQuipAI**
3. Navigate to: App Store → [Your Version] → App Store Screenshots
4. Select device size (6.9", 6.7", etc.)
5. Drag and drop screenshots **in order**
6. Rearrange as needed (first screenshot is most important!)
7. Add localized screenshots (if supporting multiple languages)

---

## Screenshot Localization (Optional)

If you plan to support multiple languages:

- **English** (Required)
- **Chinese (Simplified)** (If targeting China)
- **Spanish** (Large market)
- **French, German, Japanese** (Consider later)

For each language:
- Translate text overlays
- Keep UI in English or localize app first

---

## Device Simulators to Use

### For 6.9" Screenshots:
```bash
xcrun simctl list devices | grep "iPhone 17 Pro Max"
# Or: iPhone 15 Pro Max
```

### For 6.7" Screenshots:
```bash
xcrun simctl list devices | grep "iPhone 15 Plus"
# Or: iPhone 14 Plus
```

### For iPad (if supporting):
```bash
xcrun simctl list devices | grep "iPad Pro (12.9-inch)"
```

---

## Screenshot Checklist

Before uploading to App Store Connect:

- [ ] All screenshots are correct dimensions
- [ ] Screenshots show actual app UI (not mockups)
- [ ] Text is readable and clear
- [ ] No spelling errors in overlays
- [ ] Colors are vibrant and appealing
- [ ] No personal information visible
- [ ] No debug UI or test data
- [ ] Screenshots accurately represent features
- [ ] File sizes are optimized (<500 KB each)
- [ ] Screenshots are in correct order (best first)

---

## Pro Tips

1. **First screenshot is crucial** - This appears in search results. Make it your best!

2. **Show, don't tell** - Visual features are better than text descriptions

3. **Use actual content** - Real cards, real categories, real UI

4. **Consistency** - Use same style/quality across all screenshots

5. **Test on real device** - Simulators are close but not perfect

6. **Keep it simple** - Don't overcrowd with text overlays

7. **Update regularly** - Refresh screenshots when you add major features

---

## Example Screenshot Order

**Recommended order for App Store:**

1. **Hero/Welcome** - Most visually striking, shows value
2. **Categories** - Demonstrates breadth of content
3. **Card Detail** - Shows content quality
4. **Gestures** - Explains interaction
5. **Premium** - Drives conversion

**Alternative order (feature-focused):**

1. **Card Detail** - Immediately shows content quality
2. **Hero/Welcome** - Beautiful design
3. **Categories** - Content variety
4. **Premium** - Monetization
5. **Gestures** - How to use

---

## Need Help?

- **Apple Guidelines:** https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications
- **App Store Marketing:** https://developer.apple.com/app-store/product-page/
- **Design Resources:** https://developer.apple.com/design/resources/

---

## Summary

**Total screenshots needed:**
- Minimum: 3 per device size
- Recommended: 5 per device size
- Device sizes: 2 required (6.9" + 6.7")

**Time estimate:**
- Capturing: 30-60 minutes
- Editing: 1-2 hours
- Total: 2-3 hours for professional screenshots

**Priority:**
Create screenshots for iPhone 6.9" and 6.7" first. iPad can wait.

Good luck capturing beautiful screenshots for DailyQuipAI! 📸
