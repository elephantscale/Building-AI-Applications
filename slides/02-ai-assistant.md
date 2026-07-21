# Working with the AI API

Elephant Scale

---

## Calling the AI from Code

Everything the model does goes through **one endpoint**: a `messages` call.

```python
import anthropic

client = anthropic.Anthropic()   # reads the API key from the environment

message = client.messages.create(
    model="claude-haiku-4-5",
    max_tokens=1024,
    messages=[{"role": "user", "content": "What is the capital of France?"}],
)
print(message.content[0].text)
```

- `messages` — the conversation so far (a list of `{role, content}`).
- `max_tokens` — a hard cap on the response length.
- The reply is a list of **content blocks**; for plain text you read `content[0].text`.

> The API is **stateless** — it has no memory. To continue a conversation, you send the
> whole history back each time. Your app owns the memory, not the API.

---

## Tokens & Cost

Models don't see characters — they see **tokens** (roughly ¾ of a word). You pay per token,
input and output, and the context window is measured in tokens.

- Cost = (input tokens × input rate) + (output tokens × output rate).
- Different model tiers, different rates — the fast tier is cheapest, the top tier most capable.
- `max_tokens` caps *output* length (and therefore output cost).

```python
n = client.messages.count_tokens(
    model="claude-haiku-4-5",
    messages=[{"role": "user", "content": long_text}],
).input_tokens
```

> Practical habit: reach for the **fast/cheap** tier for high-volume, simple calls; the
> **top** tier when the task is hard enough to justify it. Choosing the model *is* cost engineering.

---

## Structured Output You Can Rely On

For real applications you need output your code can parse — every time, no stray prose.

```python
message = client.messages.create(
    model="claude-opus-4-8",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Extract the name and email: ..."}],
    output_config={"format": {"type": "json_schema", "schema": {
        "type": "object",
        "properties": {"name": {"type": "string"}, "email": {"type": "string"}},
        "required": ["name", "email"],
        "additionalProperties": False,
    }}},
)
```

- **Structured outputs** constrain the response to your JSON schema.
- Alternative: **tool use** with a typed schema — same idea, different shape.

> This is how you move from "the model usually returns JSON" to "the model *always* returns valid JSON."

---

## Streaming & Handling Responses Safely

- **Streaming** — get tokens as they're generated, for responsive UIs and long outputs.
- **`stop_reason`** — always check *why* the model stopped: `end_turn` (done), `max_tokens` (truncated — raise the cap), `tool_use` (wants a tool), `refusal` (declined).

```python
with client.messages.stream(
    model="claude-haiku-4-5", max_tokens=1024,
    messages=[{"role": "user", "content": "Write a short poem about the sea."}],
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
```

> Defensive habit: never assume `content[0].text` exists — check `stop_reason` first.
> A truncated or refused response has a different shape than a happy one.

---

## Lab 02 — Build an AI-Powered Assistant

**Stop here and run the lab now.** You'll turn the prompting skills from Lab 01 into a
small, real application that calls the AI from code.

You will:
1. Initialize the client and make structured calls to the messages API
2. Maintain a multi-turn conversation (your app holds the history)
3. Force reliable **JSON output** with a schema and parse it in code
4. Add **streaming** for a responsive experience
5. Handle `stop_reason` and errors defensively
6. Wire it together into a simple task assistant

Environment: Jupyter + AI Python SDK · fast + top model tiers · **45–60 minutes**

> **Optional:** repeat the same assistant against a different provider (e.g. ChatGPT) to
> see how portable these concepts are — the ideas carry, only the client and model name change.
