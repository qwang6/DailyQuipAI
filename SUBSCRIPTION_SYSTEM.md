# Subscription System

## Overview

DailyQuipAI implements a freemium model with daily card limits for free users and unlimited access for premium subscribers.

## Subscription Types

### Free (Default)
- **Daily Limit**: 5 cards per day
- **Cost**: Free
- **Features**: Basic access to all categories

### Premium Tiers

1. **Monthly** - $0.99/month
   - Unlimited daily cards
   - All categories
   - Advanced analytics

2. **Annual** - $7.99/year (Save 17%)
   - Same as Monthly
   - Best value for regular users

3. **Lifetime** - $12.99 (one-time)
   - Same as Monthly/Annual
   - No recurring payments

## Implementation

### Core Components

1. **SubscriptionType Enum** (User.swift:10-36)
   - Defines subscription tiers
   - `isPremium`: Boolean flag
   - `dailyCardLimit`: Optional limit (nil = unlimited)

2. **SubscriptionManager** (SubscriptionManager.swift)
   - Singleton service managing subscription state
   - Tracks daily card views
   - Resets count at midnight
   - Persists to UserDefaults

3. **User Model** (User.swift:39-99)
   - `subscriptionType`: Current subscription
   - `subscriptionExpiryDate`: For monthly/annual
   - `isPremium`: Computed property
   - `dailyCardLimit`: Computed property
   - `isSubscriptionActive`: Validity check

### Daily Limit Enforcement

**Flow:**
```
User swipes card
    ↓
DailyCardsViewModel.moveToNextCard()
    ↓
SubscriptionManager.incrementCardsViewed()
    ↓
Check: canViewMoreCards?
    ↓ No (Free user, 5+ cards)
Show Paywall
    ↓ Yes (Premium or < 5 cards)
Show next card
```

**Code Location:** DailyCardsViewModel.swift:274-306

### Paywall UI

**Trigger Conditions:**
1. Free user reaches 5 cards in a day
2. User manually clicks "Upgrade" in Settings

**PaywallView.swift Components:**
- Feature highlights (unlimited cards, analytics, etc.)
- Pricing options with badges
- "Maybe Later" option
- Full-screen modal

**Design:**
- Gradient background (brand colors)
- Large icon and clear messaging
- Three pricing tiers with clear CTAs
- Non-blocking (user can dismiss)

### Settings Integration

**SettingsView Subscription Section:**
- Shows current subscription type (Free/Premium)
- Displays remaining cards for free users
- "Upgrade" button for free users
- Premium users see "Unlimited cards"

## Storage

### UserDefaults Keys

```swift
"userSubscriptionType"      // String: "Free", "Monthly", "Annual", "Lifetime"
"cardsViewedToday"          // Int: Count of cards viewed today
"lastCardsResetDate"        // Date: Last time count was reset
```

### Data Persistence

- **Subscription Type**: Persists across app restarts
- **Daily Count**: Resets at midnight (Calendar-based)
- **Expiry Date**: For monthly/annual subscriptions

## Daily Reset Logic

**SubscriptionManager.resetDailyCountIfNeeded():**
1. Get today's start of day: `Calendar.current.startOfDay(for: Date())`
2. Compare with last reset date
3. If different day → reset count to 0
4. Update last reset date

**Runs automatically on:**
- App launch
- SubscriptionManager initialization

## Testing

### Debug Helpers (SubscriptionManager.swift)

```swift
#if DEBUG
// Switch between subscription types
subscriptionManager.switchToFree()
subscriptionManager.switchToPremium()

// Reset daily count
subscriptionManager.resetViewedCount()
#endif
```

### Manual Testing Checklist

**Free User Flow:**
- [ ] App shows "5 cards remaining today" on launch
- [ ] After viewing 5 cards, paywall appears
- [ ] "Maybe Later" dismisses paywall
- [ ] Cannot view 6th card without upgrading
- [ ] Count resets next day

**Premium User Flow:**
- [ ] No daily limit shown
- [ ] Can view unlimited cards
- [ ] No paywall appears
- [ ] Settings shows "Unlimited cards"

**Upgrade Flow:**
- [ ] Paywall shows three pricing options
- [ ] Selecting option updates subscription
- [ ] Paywall dismisses
- [ ] Settings reflects new status
- [ ] Can now view unlimited cards

## Future Enhancements

### Phase 1 (Current)
- ✅ Local subscription management
- ✅ Daily limit enforcement
- ✅ Paywall UI

### Phase 2 (Next)
- [ ] StoreKit integration (real IAP)
- [ ] Receipt validation
- [ ] Restore purchases
- [ ] Subscription renewal handling

### Phase 3 (Advanced)
- [ ] Server-side subscription verification
- [ ] Family sharing support
- [ ] Promotional offers
- [ ] Analytics tracking

## Pricing Strategy

### Market Research
- Duolingo: $6.99/month, $47.99/year
- Blinkist: $7.99/month, $79.99/year
- Elevate: $4.99/month, $39.99/year

### Our Pricing
- **Monthly**: $0.99 (lowest tier, attract trials)
- **Annual**: $7.99 (17% savings, encourage commitment)
- **Lifetime**: $12.99 (2 years worth, appeals to long-term users)

### Revenue Model
- Target: 5% conversion to paid
- Free users: API costs ~$0.001/day
- Premium users: Higher engagement, better retention

## Subscription Analytics (Future)

Track key metrics:
- **Conversion Rate**: Free → Paid
- **Paywall Impressions**: How often shown
- **Upgrade Click Rate**: CTA effectiveness
- **Churn Rate**: Monthly/annual cancellations
- **Lifetime Value (LTV)**: Revenue per user

## Legal Requirements

### App Store Guidelines
- Clear pricing display ✅
- Easy cancellation ✅
- Privacy policy (TODO)
- Terms of service (TODO)

### User Rights
- No forced upgrade (free tier available)
- Data portability
- Account deletion
- Refund policy (7 days)

## Summary

**Current Implementation:**
- ✅ Subscription tiers defined
- ✅ Daily limit enforcement (5 cards/day for free)
- ✅ Paywall UI with pricing
- ✅ Settings integration
- ✅ Local state management

**Next Steps:**
- Integrate StoreKit for real payments
- Add receipt validation
- Implement restore purchases
- Add analytics tracking

The subscription system is designed to be:
1. **Non-intrusive**: Free tier is genuinely useful
2. **Clear**: Pricing and limits are transparent
3. **Flexible**: Multiple payment options
4. **Scalable**: Ready for StoreKit integration
