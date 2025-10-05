# DailyQuipAI Website

This directory contains the GitHub Pages website for DailyQuipAI.

## Live URLs

Once GitHub Pages is enabled:
- **Main Site**: https://qwang6.github.io/DailyQuipAI/
- **Custom Domain**: https://dailyquipai.app (if DNS configured)
- **Privacy Policy**: https://qwang6.github.io/DailyQuipAI/privacy.html
- **Support**: https://qwang6.github.io/DailyQuipAI/support.html
- **Terms**: https://qwang6.github.io/DailyQuipAI/terms.html

## Files

- `index.html` - Marketing landing page
- `privacy.html` - Privacy Policy (required for App Store)
- `support.html` - Support & FAQ page (required for App Store)
- `terms.html` - Terms of Service (required for App Store)
- `CNAME` - Custom domain configuration (optional)

## Setup GitHub Pages

1. Go to repository Settings
2. Navigate to "Pages" section
3. Under "Source", select "Deploy from a branch"
4. Choose branch: `main`
5. Choose folder: `/docs`
6. Click Save

GitHub Pages will be live at: https://qwang6.github.io/DailyQuipAI/

## Custom Domain Setup (Optional)

If you own `dailyquipai.app`:

1. In your domain registrar (e.g., Namecheap, GoDaddy):
   - Add A records pointing to GitHub's IPs:
     - 185.199.108.153
     - 185.199.109.153
     - 185.199.110.153
     - 185.199.111.153
   - Add CNAME record: `www` → `qwang6.github.io`

2. In GitHub repository settings → Pages:
   - Enter custom domain: `dailyquipai.app`
   - Check "Enforce HTTPS"

## For App Store Submission

Use these URLs in App Store Connect:

- **Privacy Policy URL**: `https://qwang6.github.io/DailyQuipAI/privacy.html`
- **Support URL**: `https://qwang6.github.io/DailyQuipAI/support.html`

## Local Testing

Open `index.html` in a browser to preview locally.
