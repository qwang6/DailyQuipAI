# Google Gemini Integration Setup

## ✅ Configuration Complete

Your DailyQuipAI app is now configured to use **Google Gemini 2.0 Flash** for generating knowledge cards!

## Current Configuration

- **Provider**: Google Gemini
- **Model**: `gemini-2.0-flash-exp`
- **API Key**: Configured and ready to use
- **No Mock Data**: App will only use real Gemini API responses

## How It Works

### When You Open the App:

1. App reads your selected categories (History, Science, etc.)
2. App reads your daily goal (e.g., 5 cards per day)
3. For each card, Gemini generates:
   - A compelling title
   - Engaging educational content (150-300 words)
   - Credible source citation
   - Relevant tags
   - Difficulty level (1-5)

### API Request Flow:

```
User opens app
    ↓
App calls Gemini API with prompt
    ↓
Gemini generates JSON response
    ↓
App parses and displays card
```

## API Details

### Endpoint
```
https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent
```

### Request Format
```json
{
  "contents": [{
    "parts": [{"text": "Generate a knowledge card about..."}]
  }],
  "generationConfig": {
    "temperature": 0.8,
    "maxOutputTokens": 1000,
    "responseMimeType": "application/json"
  }
}
```

### Response Format
```json
{
  "title": "The Quantum Entanglement Phenomenon",
  "content": "Quantum entanglement is one of the most fascinating...",
  "source": "Einstein, A. et al. (1935). Physical Review",
  "tags": ["quantum mechanics", "physics", "science"],
  "difficulty": 4
}
```

## Cost Estimates

### Gemini 2.0 Flash Pricing
- **Input**: $0.075 per 1M tokens
- **Output**: $0.30 per 1M tokens

### Daily Cost Per User
Assuming 5 cards per day:
- Input tokens: ~1,500 tokens (prompts)
- Output tokens: ~2,500 tokens (responses)

**Cost**: ~$0.001 per user per day (~$0.03/month)

### Monthly Cost Estimates
| Users | Daily API Calls | Estimated Monthly Cost |
|-------|----------------|------------------------|
| 100   | 500            | $3                     |
| 1,000 | 5,000          | $30                    |
| 10,000| 50,000         | $300                   |

## Features

### ✅ Real-time Generation
- Fresh content every day
- No duplicate cards
- Personalized based on user interests

### ✅ Category Support
All 6 categories are supported:
- 📚 History
- 🔬 Science
- 🎨 Art
- 🌱 Life
- 💰 Finance
- 🤔 Philosophy

### ✅ Quality Control
Gemini is prompted to:
- Use credible sources
- Write at appropriate difficulty levels
- Include surprising/thought-provoking elements
- Keep content engaging and accessible

## Testing

### Manual Test
1. Open the app in simulator
2. Complete onboarding and select categories
3. Wait for cards to load (2-5 seconds)
4. Verify cards display with:
   - Relevant title
   - Educational content
   - Source citation
   - Proper category tag

### Debug Logs
Check Xcode console for API responses:
```
Generating card for category: Science
Gemini API call successful
Card generated: "The Butterfly Effect in Chaos Theory"
```

## Error Handling

The app handles common errors gracefully:

### API Key Issues
- ❌ Invalid key → Shows error message
- ❌ Expired key → Prompts to update

### Network Issues
- ❌ No internet → Shows retry option
- ❌ Slow connection → Shows loading state

### Rate Limiting
- ❌ Quota exceeded → Shows informative message
- ✅ Implements retry logic with exponential backoff

## Security

### API Key Storage
- ✅ Hardcoded in code (for demo/development)
- 🔄 TODO: Move to Keychain for production
- 🔄 TODO: Add Settings UI for users to input their own key

### Best Practices
1. Never commit API keys to public repositories
2. Use environment variables for sensitive data
3. Implement key rotation policies
4. Monitor usage to detect anomalies

## Monitoring & Analytics

### Recommended Tracking
- Cards generated per day
- API response times
- Error rates
- User engagement with generated content

### Google Cloud Console
Monitor your API usage at:
https://console.cloud.google.com/apis/dashboard

## Alternative Models

You can switch to other Gemini models by modifying `LLMCardGenerator.swift`:

```swift
// For Gemini Pro (more powerful, higher cost)
let model = "gemini-1.5-pro"

// For Gemini Flash (faster, lower cost) - Current
let model = "gemini-2.0-flash-exp"
```

## Troubleshooting

### Cards Not Loading
1. Check internet connection
2. Verify API key is correct
3. Check Gemini API status: https://status.cloud.google.com/
4. Review Xcode console for error messages

### Poor Quality Cards
1. Adjust temperature in `generationConfig` (0.7-0.9)
2. Modify the prompt template for better results
3. Increase `maxOutputTokens` for longer content

### API Quota Exceeded
1. Check usage in Google Cloud Console
2. Request quota increase if needed
3. Implement caching to reduce API calls

## Support

For questions or issues:
- Check Gemini API docs: https://ai.google.dev/docs
- Review code in `LLMCardGenerator.swift`
- Check Xcode console logs for detailed error messages

---

**Status**: ✅ Ready to use
**Last Updated**: 2025-10-04
