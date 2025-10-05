# DailyQuipAI - Website Requirements for App Store Submission

## Overview

Apple requires several URLs to be accessible before app submission:
1. **Privacy Policy URL** (Required)
2. **Terms of Service URL** (Required for apps with subscriptions)
3. **Support URL** (Required)
4. **Marketing URL** (Optional but recommended)

All URLs must be publicly accessible and cannot return 404 errors.

---

## Required Pages

### 1. Privacy Policy
**URL:** https://dailyquipai.app/privacy

**Content:** See `PRIVACY_POLICY.md`

**Key sections:**
- What data we collect (minimal)
- How data is used (locally stored)
- Third-party services (Gemini API)
- User rights
- Contact information

---

### 2. Terms of Service
**URL:** https://dailyquipai.app/terms

**Content:** See `TERMS_OF_SERVICE.md`

**Key sections:**
- Subscription terms
- Refund policy
- User responsibilities
- Content ownership
- Liability disclaimers
- Age requirements

---

### 3. Support Page
**URL:** https://dailyquipai.app/support

**Content suggestions:**

```markdown
# DailyQuipAI Support

## Frequently Asked Questions

### How do I get started?
1. Download DailyQuipAI from the App Store
2. Complete the onboarding to select your interests
3. Start swiping through daily knowledge cards!

### How many cards do I get for free?
Free users get 5 knowledge cards per day. Premium subscribers get unlimited cards.

### What categories are available?
- History - Historical events, figures, and cultural phenomena
- Science - Physics, chemistry, biology, and astronomy
- Art - Painting, music, architecture, and design
- Life - Health, psychology, and sociology
- Finance - Economics and investment strategies
- Philosophy - Wisdom and ways of thinking

### How do I upgrade to Premium?
1. Open the app
2. Tap the Premium button or try to view more than 5 cards
3. Choose your subscription tier:
   - Monthly: $4.99/month
   - Annual: $39.99/year (save 33%)
   - Lifetime: $79.99 one-time

### How do I cancel my subscription?
1. Open iOS Settings
2. Tap your name at the top
3. Tap Subscriptions
4. Select DailyQuipAI
5. Tap Cancel Subscription

### How do I restore my purchases?
If you previously purchased Premium:
1. Open DailyQuipAI
2. Go to Settings
3. Tap "Restore Purchases"

### The app says I've reached my daily limit
Free users are limited to 5 cards per day. The limit resets at midnight in your local timezone. Upgrade to Premium for unlimited cards!

### Where does the content come from?
DailyQuipAI uses Google's Gemini AI to generate fresh, engaging knowledge cards based on your selected categories. Each card is unique and tailored to be informative and accessible.

### Is my data private?
Yes! DailyQuipAI stores all your preferences and progress locally on your device. We don't collect personal information or track your behavior. See our [Privacy Policy](/privacy) for details.

### How do I change my category preferences?
1. Open Settings in the app
2. Tap "Category Preferences"
3. Select/deselect categories
4. Your next batch of cards will reflect your choices

### I found a bug or have a suggestion
We'd love to hear from you! Email us at support@dailyquipai.app

## Contact Us

**Email:** support@dailyquipai.app

**Response time:** We aim to respond within 24-48 hours.

## Additional Resources

- [Privacy Policy](/privacy)
- [Terms of Service](/terms)
- [App Store Page](https://apps.apple.com/app/quipcardai)

---

© 2025 DailyQuipAI. All rights reserved.
```

---

### 4. Marketing/Landing Page (Optional)
**URL:** https://dailyquipai.app

**Content suggestions:**

```markdown
# DailyQuipAI - Your Daily Knowledge Companion

## Transform Idle Moments into Learning Opportunities

Discover fascinating facts, insights, and knowledge across 6 engaging categories. Beautiful design meets powerful AI to bring you bite-sized learning every day.

### 📱 Download on the App Store
[Download Now](https://apps.apple.com/app/quipcardai)

---

## Why DailyQuipAI?

### 🎨 Beautifully Designed
Experience knowledge through stunning glass morphism design. Each category has its own vibrant color palette, making learning visually delightful.

### 🧠 6 Knowledge Categories
- **History** - Events, figures, and cultural phenomena
- **Science** - Physics, chemistry, biology, astronomy
- **Art** - Painting, music, architecture, design
- **Life** - Health, psychology, sociology
- **Finance** - Economics and investment strategies
- **Philosophy** - Wisdom and ways of thinking

### 🤖 AI-Powered Content
Fresh, engaging cards generated daily using advanced AI. Each card is designed to be read in 30 seconds to 2 minutes.

### 👆 Intuitive Gestures
- Swipe left to mark as learned
- Swipe right to save for later
- Swipe up/down to navigate
- Tap to flip and reveal details

---

## Pricing

### Free
**$0**
- 5 cards per day
- All 6 categories
- Basic tracking

### Monthly
**$4.99/month**
- Unlimited daily cards
- Priority content
- Advanced analytics
- Ad-free

### Annual
**$39.99/year**
- Save 33%!
- Unlimited daily cards
- Priority content
- Advanced analytics
- Ad-free

### Lifetime
**$79.99 one-time**
- Unlimited forever
- All features
- One-time payment
- Best value

---

## What Users Are Saying

> "DailyQuipAI has become part of my morning routine. I learn something new every day!"

> "The design is stunning and the content is always interesting."

> "Finally, an app that makes learning feel effortless."

---

## Download Today

[Download on the App Store](https://apps.apple.com/app/quipcardai)

Available on iPhone and iPad • iOS 26.0 or later

---

## Links

- [Support](/support)
- [Privacy Policy](/privacy)
- [Terms of Service](/terms)

---

© 2025 DailyQuipAI. All rights reserved.
```

---

## Implementation Options

### Option 1: Simple Static Site (Fastest)
Host on **GitHub Pages** (Free)

1. Create a new repo: `quipcardai-website`
2. Create `index.html`, `privacy.html`, `terms.html`, `support.html`
3. Enable GitHub Pages in settings
4. Configure custom domain: `dailyquipai.app`

**Time:** 1-2 hours

---

### Option 2: Vercel/Netlify (Recommended)
**Why:** Fast, free, custom domain support, automatic HTTPS

**Steps:**
1. Create a simple Next.js or static site
2. Add pages: `/`, `/privacy`, `/terms`, `/support`
3. Deploy to Vercel/Netlify
4. Configure custom domain `dailyquipai.app`

**Time:** 2-3 hours

---

### Option 3: Simple HTML Site
Create 4 HTML files and host anywhere (Cloudflare Pages, etc.)

**Advantages:**
- No build tools required
- Fast to set up
- Easy to maintain

**Files needed:**
- `index.html` (landing page)
- `privacy.html` (privacy policy)
- `terms.html` (terms of service)
- `support.html` (support/FAQ)

**Time:** 1-2 hours

---

## Quickstart: GitHub Pages Setup

### 1. Create Repository
```bash
# Create new repo on GitHub
# Name: quipcardai-website

# Clone locally
git clone https://github.com/yourusername/quipcardai-website.git
cd quipcardai-website
```

### 2. Create Pages
```bash
# Create HTML files
touch index.html privacy.html terms.html support.html

# Add basic structure
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DailyQuipAI - Daily Knowledge Cards</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
        }
        h1 { color: #6366f1; }
        .cta {
            background: #6366f1;
            color: white;
            padding: 12px 24px;
            border-radius: 8px;
            text-decoration: none;
            display: inline-block;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <h1>DailyQuipAI</h1>
    <p>Your daily knowledge companion</p>
    <a href="#" class="cta">Download on App Store</a>
    <nav>
        <a href="/support.html">Support</a> |
        <a href="/privacy.html">Privacy</a> |
        <a href="/terms.html">Terms</a>
    </nav>
</body>
</html>
EOF
```

### 3. Convert Markdown to HTML
```bash
# Use a tool like pandoc to convert MD to HTML
pandoc PRIVACY_POLICY.md -o privacy.html --standalone
pandoc TERMS_OF_SERVICE.md -o terms.html --standalone
```

### 4. Push and Enable GitHub Pages
```bash
git add .
git commit -m "Initial website"
git push

# Then in GitHub:
# Settings → Pages → Source: main branch → Save
# Your site will be at: https://yourusername.github.io/quipcardai-website/
```

### 5. Configure Custom Domain
1. Buy domain `dailyquipai.app` (Namecheap, Google Domains, etc.)
2. Add CNAME record: `dailyquipai.app` → `yourusername.github.io`
3. In GitHub repo settings → Pages → Custom domain: `dailyquipai.app`
4. Wait for DNS propagation (5-30 minutes)

---

## Domain Registration

### Recommended Registrars
1. **Namecheap** - Affordable, good UI
2. **Cloudflare** - At-cost pricing, excellent DNS
3. **Google Domains** (Now Squarespace)
4. **Porkbun** - Cheap .app domains

### Cost
- `.app` domain: ~$12-20/year
- Renewal: ~$12-20/year

### Purchase Steps
1. Search for `dailyquipai.app`
2. Add to cart and checkout
3. Configure DNS to point to hosting
4. Enable HTTPS (usually automatic with GitHub Pages/Vercel)

---

## Pre-Submission Checklist

Before submitting to App Store:

- [ ] Domain `dailyquipai.app` registered
- [ ] DNS configured and propagated
- [ ] Privacy policy accessible at `/privacy`
- [ ] Terms of service accessible at `/terms`
- [ ] Support page accessible at `/support`
- [ ] All pages load correctly (no 404s)
- [ ] HTTPS enabled (required by Apple)
- [ ] Email `support@dailyquipai.app` set up and working
- [ ] Mobile-responsive design (test on phone)

---

## Email Setup

You'll need `support@dailyquipai.app` for:
- App Store contact
- User support
- Privacy/terms contact

### Options:

**1. Cloudflare Email Routing (Free)**
- Forward `support@dailyquipai.app` to your personal email
- Easy to set up
- No cost

**2. Google Workspace (Paid)**
- Professional email
- $6/user/month
- Full Gmail interface

**3. ProtonMail (Free tier available)**
- Privacy-focused
- Custom domain support
- Free tier: 1 address

**Recommended:** Cloudflare Email Routing for MVP

---

## Simple HTML Template

Create a professional-looking site with this minimal template:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DailyQuipAI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #1f2937;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 60px 20px;
            text-align: center;
        }
        h1 { font-size: 3rem; margin-bottom: 1rem; }
        .cta {
            background: white;
            color: #667eea;
            padding: 15px 30px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            display: inline-block;
            margin-top: 20px;
        }
        footer {
            background: #f9fafb;
            padding: 40px 20px;
            text-align: center;
            margin-top: 60px;
        }
        footer a {
            color: #667eea;
            text-decoration: none;
            margin: 0 15px;
        }
    </style>
</head>
<body>
    <header>
        <h1>DailyQuipAI</h1>
        <p>Your Daily Knowledge Companion</p>
        <a href="#" class="cta">Download on App Store</a>
    </header>

    <main class="container">
        <!-- Content here -->
    </main>

    <footer>
        <a href="/support.html">Support</a>
        <a href="/privacy.html">Privacy Policy</a>
        <a href="/terms.html">Terms of Service</a>
        <p style="margin-top: 20px; color: #6b7280;">© 2025 DailyQuipAI</p>
    </footer>
</body>
</html>
```

---

## Timeline

**Minimum viable website setup:**
- Domain registration: 10 minutes
- Create HTML pages: 1-2 hours
- Deploy to GitHub Pages/Vercel: 30 minutes
- Configure DNS: 5 minutes (+ wait for propagation)
- Email setup: 15 minutes
- **Total: 2-3 hours** (+ DNS propagation time)

**Can submit app review as soon as:**
- All URLs return 200 OK
- HTTPS is enabled
- Content is accurate and complete

---

## Summary

### Required URLs:
1. ✅ **https://dailyquipai.app/privacy** - Privacy Policy
2. ✅ **https://dailyquipai.app/terms** - Terms of Service
3. ✅ **https://dailyquipai.app/support** - Support/FAQ

### Recommended:
4. **https://dailyquipai.app** - Landing page
5. **support@dailyquipai.app** - Email

### Quick Path:
1. Register `dailyquipai.app` on Namecheap/Cloudflare
2. Create GitHub Pages site with 4 HTML files
3. Configure custom domain
4. Set up Cloudflare Email Routing
5. Wait for DNS propagation
6. Test all URLs
7. Submit app to App Store ✅

**Need help?** The simplest path is GitHub Pages + Cloudflare for email. Free and works perfectly for App Store requirements.
