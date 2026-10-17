## Exercise 21

curl http://127.0.0.1:11434/api/generate \
  -d '{"model":"qwen2.5:1.5b","prompt":"Give the meaning and one example sentence for: resilient","stream":false}'


{
  "model": "qwen2.5:1.5b",
  "format": "json",
  "options": {
    "temperature": 0.2
  },
  "prompt": "You are a vocabulary assistant. For the word \"Carnival\", return exactly one valid JSON object and nothing else—no Markdown, explanation, or code fence.\n\nUse exactly these string keys:\n- \"Meaning\"\n- \"Context\"\n- \"Context Meaning\"\n- \"Example\"\n\nRules:\n- Give the most common meaning of the word.\n- Context must be a short category or situation where the word is used.\n- Context Meaning must explain the word in that context.\n- Example must be one simple, grammatically correct sentence using the word.\n\nRequired output shape:\n{\n  \"Meaning\": \"...\",\n  \"Context\": \"...\",\n  \"Context Meaning\": \"...\",\n  \"Example\": \"...\"\n}"
}

