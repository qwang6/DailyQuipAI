# LLM Integration Guide

## Overview

DailyQuipAI uses LLM (Large Language Model) APIs to generate personalized knowledge cards on-demand. This eliminates the need for a backend server and allows for fresh, relevant content every day.

## Architecture

The app generates knowledge cards in real-time using:
- **Development**: Mock data with realistic examples
- **Production**: LLM API (OpenAI, Claude, or other providers)

## Supported LLM Providers

### OpenAI (Recommended)
- **Model**: GPT-4 or GPT-3.5-turbo
- **API Endpoint**: `https://api.openai.com/v1/chat/completions`
- **Cost**: ~$0.03 per user per day (based on 5 cards)

### Claude (Anthropic)
- **Model**: Claude 3 Sonnet or Opus
- **API Endpoint**: `https://api.anthropic.com/v1/messages`
- **Cost**: ~$0.04 per user per day

### Custom LLM
You can integrate any LLM that supports chat completion API.

## Configuration

### 1. Get API Key

**For OpenAI:**
1. Visit https://platform.openai.com/api-keys
2. Create a new API key
3. Copy the key (starts with `sk-`)

**For Claude:**
1. Visit https://console.anthropic.com/
2. Create an API key
3. Copy the key

### 2. Add API Key to App

**Option A: Settings UI (Recommended for users)**
1. Open app Settings
2. Navigate to "API Configuration"
3. Enter your API key
4. The key is stored securely in Keychain

**Option B: User Defaults (Development only)**
```swift
UserDefaults.standard.set("your-api-key-here", forKey: "llmAPIKey")
```

**Option C: Environment Variable (Best for development)**
Add to your scheme's environment variables:
```
LLM_API_KEY = your-api-key-here
```

### 3. Configure Provider (Optional)

To change the LLM provider, modify `LLMCardGenerator.swift`:

```swift
// For Claude
init(apiKey: String, baseURL: URL = URL(string: "https://api.anthropic.com/v1")!) {
    self.apiKey = apiKey
    self.baseURL = baseURL
    self.session = URLSession.shared
}
```

## How It Works

### Card Generation Flow

1. User opens app
2. App reads user's selected categories from UserDefaults
3. App calls `LLMCardGenerator.generateDailyCards(categories:count:)`
4. For each card:
   - Generate a prompt based on category
   - Call LLM API with the prompt
   - Parse JSON response into Card object
   - Assign category-appropriate image from Unsplash
5. Display cards to user

### Sample Prompt

```
Generate an interesting and educational knowledge card for the category: History.

Requirements:
- Title: A compelling, concise title (max 60 characters)
- Content: An engaging explanation of a fascinating fact, concept, or story (150-300 words)
- Make it accessible to general audiences
- Include a surprising or thought-provoking element
- Cite a credible source

Respond in JSON format:
{
    "title": "Your title here",
    "content": "Your detailed content here",
    "source": "Source/reference",
    "tags": ["tag1", "tag2", "tag3"],
    "difficulty": 3
}
```

### Sample Response

```json
{
    "title": "The Butterfly Effect in Chaos Theory",
    "content": "The butterfly effect is a concept in chaos theory that suggests small changes in initial conditions can lead to vastly different outcomes...",
    "source": "Lorenz, E. (1963). Journal of the Atmospheric Sciences",
    "tags": ["chaos theory", "mathematics", "weather"],
    "difficulty": 3
}
```

## Development Mode

In DEBUG builds, the app uses mock data instead of calling real APIs:
- No API calls are made
- Mock responses are returned instantly
- No API costs incurred
- Perfect for testing and development

## Production Considerations

### Cost Optimization

1. **Cache Generated Cards**: Store cards in CoreData for 24 hours
2. **Batch Generation**: Generate multiple cards in one API call
3. **Use Cheaper Models**: GPT-3.5-turbo is 10x cheaper than GPT-4
4. **Rate Limiting**: Limit card generation to once per day per user

### Error Handling

The app gracefully handles:
- API errors (network, rate limits, invalid keys)
- Invalid JSON responses
- Empty or malformed content
- Missing API configuration

### Privacy

- API keys are stored securely in iOS Keychain
- No user data is sent to LLM providers
- Only category preferences are used to generate content
- Cards are generated on-device context, not personalized user data

## Future Enhancements

1. **Multi-Provider Support**: Allow users to choose their preferred LLM
2. **Local LLMs**: Support on-device LLMs (e.g., Llama, Mistral)
3. **Image Generation**: Use DALL-E or Midjourney for card images
4. **Voice Narration**: Text-to-speech for audio learning
5. **Translation**: Generate cards in multiple languages

## Troubleshooting

### "No cards generated"
- Check API key is configured correctly
- Verify internet connection
- Check API provider status page

### "API Error: Rate Limit"
- You've exceeded your API quota
- Wait for quota to reset or upgrade plan
- Consider implementing caching

### "Invalid Response"
- LLM returned unexpected format
- Check prompt template in code
- Verify model supports JSON mode

## API Cost Estimates

Based on 5 cards per day per user:

| Provider | Model | Cost per User/Day | Cost per User/Month |
|----------|-------|-------------------|---------------------|
| OpenAI | GPT-4 | $0.03 | $0.90 |
| OpenAI | GPT-3.5 | $0.003 | $0.09 |
| Claude | Sonnet | $0.04 | $1.20 |
| Claude | Haiku | $0.01 | $0.30 |

*Costs are estimates and may vary based on actual usage and pricing changes*

## Support

For issues or questions:
1. Check the code documentation in `LLMCardGenerator.swift`
2. Review error logs in Xcode console
3. Contact support at support@dailyquipai.app
