# Groq Python Usage Example

```python
import os
from groq import Groq

client = Groq(api_key=os.environ.get("GROQ_API_KEY"))  # set env externally

response = client.chat.completions.create(
    model="llama-3.1-70b-versatile",  # or "llama-3.1-8b-instant" for lower latency
    messages=[{"role": "user", "content": "Hello, Groq!"}],
    max_tokens=256,
    temperature=0.7,
)

print(response.choices[0].message.content)
```

## Environment Variable
Set the key in your shell (do NOT commit the raw key):

```bash
export GROQ_API_KEY="your_groq_key_here"
# Windows PowerShell
$Env:GROQ_API_KEY="your_groq_key_here"
```

## Flutter Integration
Run the Flutter app passing the same key:

```powershell
flutter run --dart-define=GROQ_API_KEY=$Env:GROQ_API_KEY
```

`GroqChatService` then reads it via `String.fromEnvironment('GROQ_API_KEY')`.

## Troubleshooting
- 401 / 403: Key invalid or missing; verify env and dart-define.
- 400 model error: Check model string spelling or try fallback `llama-3.1-8b-instant`.
- Timeouts: Network instability; retries handled automatically in `GroqChatService`.
