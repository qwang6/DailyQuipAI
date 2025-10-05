# App Store Screenshots Requirements

## 📸 Required Screenshot Sizes

### iPhone (Required)

| Device Size | Resolution | Devices | Required |
|------------|------------|---------|----------|
| 6.7" | 1290 x 2796 px | iPhone 15 Pro Max, 14 Pro Max | ✅ Yes |
| 6.5" | 1242 x 2688 px | iPhone 11 Pro Max, XS Max | Recommended |
| 5.5" | 1242 x 2208 px | iPhone 8 Plus | Optional |

**Number needed:** 3-10 screenshots per size

### iPad (Optional but Recommended)

| Device Size | Resolution | Devices |
|------------|------------|---------|
| 12.9" | 2048 x 2732 px | iPad Pro 12.9" |
| 11" | 1668 x 2388 px | iPad Pro 11", iPad Air |

---

## 🎯 How to Take Screenshots

### Method 1: iPhone Simulator (Easiest)

```bash
# In Xcode:
1. Select iPhone 15 Pro Max simulator
2. Run app (⌘R)
3. Navigate to screen
4. File → New Screen Shot (⌘S)
5. Screenshot saves to ~/Desktop
```

### Method 2: Real Device

```bash
1. Run app on iPhone
2. Press Power + Volume Up
3. AirDrop to Mac or use Image Capture
```

---

## 📋 Required Screenshots (Minimum 3)

### Screenshot 1: Main Card View
**What to show:** Beautiful knowledge card with text visible
**Tips:**
- Choose History or Art category (most visual)
- Ensure card text is readable
- Show glass morphism effect

### Screenshot 2: Category Selection
**What to show:** All 6 categories displayed
**Tips:**
- During onboarding OR main screen category filter
- All icons visible and clear

### Screenshot 3: Feature Highlight
**What to show:** Swipe controls, progress, or settings
**Tips:**
- Show what makes app unique
- Can add text overlay explaining feature

---

## 💡 Quick Start Guide

**Fastest way (10 minutes):**

1. Open Xcode project
2. Select iPhone 15 Pro Max simulator
3. Run app
4. Take 3 screenshots:
   - Card view
   - Category view
   - One more feature screen
5. Upload to App Store Connect

**That's it!** Don't overthink screenshots for v1.0. You can improve them later.

---

## 🚨 Common Issues

**Problem:** Screenshots wrong size
**Solution:** Use exact simulator size (iPhone 15 Pro Max for 6.7")

**Problem:** Status bar shows wrong time
**Solution:** Use simulator (always shows 9:41)

**Problem:** Content not showing
**Solution:** Ensure API key is configured and app has internet

---

## ✅ Screenshot Checklist

- [ ] 3 screenshots minimum for iPhone 6.7"
- [ ] Screenshots show real app content (not placeholders)
- [ ] Text is readable
- [ ] No personal information visible
- [ ] Correct resolution (1290 x 2796 for 6.7")
- [ ] PNG or JPEG format
- [ ] File size under 500KB each

---

**File location after taking screenshots:**
`~/Desktop/Simulator Screen Shot - iPhone 15 Pro Max - [date].png`
