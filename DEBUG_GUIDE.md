# Debugging Guide for Gemini Integration

## Fixed Issues

### ✅ String Index Out of Bounds Error
**Problem**: `Fatal error: String index is out of bounds`

**Cause**: When parsing JSON from LLM response, the code tried to extract JSON using `range(of:)` but didn't validate that the end position came after the start position.

**Solution**: Added validation:
```swift
if let jsonStart = response.range(of: "{"),
   let jsonEnd = response.range(of: "}", options: .backwards),
   jsonStart.lowerBound <= jsonEnd.upperBound {  // ✅ Added this check
    jsonString = String(response[jsonStart.lowerBound...jsonEnd.upperBound])
}
```

## Debug Logging

The app now includes comprehensive logging for Gemini API calls:

### Logs You'll See

1. **API Call Started**
   ```
   🚀 Calling Gemini API with model: gemini-2.0-flash-exp
   📤 Request body prepared
   ```

2. **API Response**
   ```
   📥 Received response with status: 200
   ✅ Successfully got text from Gemini
   ```

3. **JSON Parsing**
   ```
   📝 Raw LLM Response: {"title": "...", "content": "..."}
   ✅ Extracted JSON: {"title": "...", "content": "..."}
   ✅ Successfully decoded card: The Quantum Entanglement Phenomenon
   ```

### Error Logs

1. **API Errors**
   ```
   ❌ API Error: {"error": {"code": 400, "message": "..."}}
   ```

2. **Parsing Errors**
   ```
   ❌ Failed to parse response
   📄 Full response: [actual response content]
   ```

3. **JSON Decode Errors**
   ```
   ❌ JSON Decode Error: keyNotFound(...)
   ❌ JSON String: {"incomplete json..."}
   ```

## How to Debug in Xcode

### 1. Enable Console Output
1. Run app in Xcode
2. Open Debug Console (⌘⇧Y)
3. Look for emoji-prefixed logs

### 2. Check API Response
When cards don't load, look for:
```
📥 Received response with status: [code]
```

**Common Status Codes:**
- `200` - Success ✅
- `400` - Bad Request (check prompt format)
- `401` - Invalid API Key
- `403` - API Disabled or Quota Exceeded
- `429` - Rate Limit Exceeded
- `500` - Gemini Server Error

### 3. Inspect JSON Response
Look for the raw response:
```
📝 Raw LLM Response: ...
```

**Valid Response Should Contain:**
```json
{
  "title": "Card Title",
  "content": "Card content here...",
  "source": "Reference",
  "tags": ["tag1", "tag2"],
  "difficulty": 3
}
```

## Common Issues & Solutions

### Issue 1: Cards Not Loading
**Symptoms**: Loading indicator stays forever

**Debug Steps:**
1. Check console for error messages
2. Look for HTTP status code
3. Verify API key is correct

**Solutions:**
- If status 401: Check API key
- If status 429: Wait for rate limit reset
- If status 400: Check prompt format

### Issue 2: Invalid JSON Response
**Symptoms**: `❌ JSON Decode Error` in console

**Debug Steps:**
1. Check `📝 Raw LLM Response` in console
2. Verify JSON structure matches `LLMCardResponse`

**Solutions:**
- Gemini might return explanation text before JSON
- Parser tries to extract JSON between `{` and `}`
- If that fails, ensure `responseMimeType: "application/json"` in request

### Issue 3: Empty or Incomplete Cards
**Symptoms**: Cards display but missing fields

**Debug Steps:**
1. Check decoded card log: `✅ Successfully decoded card: [title]`
2. Verify all required fields are present

**Solutions:**
- Update prompt to be more explicit about required fields
- Add default values for optional fields

## Testing API Directly

### Using curl:
```bash
curl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{"text": "Generate a JSON with title, content, source, tags array, and difficulty number for a science topic"}]
    }],
    "generationConfig": {
      "temperature": 0.8,
      "maxOutputTokens": 1000,
      "responseMimeType": "application/json"
    }
  }'
```

### Expected Response:
```json
{
  "candidates": [{
    "content": {
      "parts": [{
        "text": "{\"title\":\"...\",\"content\":\"...\",\"source\":\"...\",\"tags\":[...],\"difficulty\":3}"
      }]
    }
  }]
}
```

## Performance Monitoring

### Track in Console:
- Time between API calls
- Response sizes
- Success/failure rates

### Typical Performance:
- API Call: 1-3 seconds
- JSON Parsing: < 0.1 seconds
- Total per card: 1-3 seconds

### For 5 cards:
- Sequential: 5-15 seconds
- Could optimize with concurrent requests

## API Quota Monitoring

### Free Tier Limits (Gemini):
- 15 requests per minute
- 1500 requests per day
- 1 million tokens per minute

### Monitoring Tips:
1. Count API calls in logs
2. Track 429 errors (rate limit)
3. Implement exponential backoff for retries

## Troubleshooting Checklist

- [ ] API key is correct and not expired
- [ ] Internet connection is working
- [ ] Gemini API is not down (check status.cloud.google.com)
- [ ] Request format matches Gemini API spec
- [ ] Response contains expected JSON structure
- [ ] All required JSON fields are present
- [ ] JSON parsing doesn't throw errors
- [ ] Cards display correctly in UI

## Advanced Debugging

### Add Breakpoint in `callGeminiAPI`:
```swift
let (data, response) = try await session.data(for: request)
// Add breakpoint here
```

**Inspect:**
- `data`: Raw response data
- `response.statusCode`: HTTP status
- Convert data to string: `String(data: data, encoding: .utf8)`

### Add Breakpoint in `parseCardFromResponse`:
```swift
let cardData = try decoder.decode(LLMCardResponse.self, from: data)
// Add breakpoint here
```

**Inspect:**
- `jsonString`: Extracted JSON
- `cardData`: Decoded object
- Individual fields: `cardData.title`, etc.

## Support Resources

1. **Gemini API Docs**: https://ai.google.dev/docs
2. **Status Page**: https://status.cloud.google.com/
3. **API Console**: https://console.cloud.google.com/apis/dashboard
4. **Error Codes**: https://ai.google.dev/api/rest/v1/Status

## Reporting Issues

When reporting bugs, include:
1. Console logs (all emoji-prefixed messages)
2. HTTP status code
3. Raw LLM response (if visible)
4. Steps to reproduce
5. Expected vs actual behavior
