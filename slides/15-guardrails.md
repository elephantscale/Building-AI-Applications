# Guardrails, Validation & Responsible AI

Elephant Scale

---

## Output Validation & Structured-Output Enforcement

Never trust model output by default — validate it before anything consumes it. The
strongest form is to constrain the shape at generation time.

```python
message = client.messages.create(
    model="claude-opus-4-8",
    max_tokens=1024,
    messages=[{"role": "user", "content": user_request}],
    output_config={"format": {"type": "json_schema", "schema": {
        "type": "object",
        "properties": {
            "action":  {"type": "string", "enum": ["refund", "escalate", "reply"]},
            "amount":  {"type": "number"},
        },
        "required": ["action"],
        "additionalProperties": False,
    }}},
)
```

- **Structured outputs** force the response into your schema — an `enum` means the model
  *cannot* invent an action you didn't allow.
- After parsing, still **validate the values** (is `amount` within policy limits?) and
  never `exec`/render raw output.

> This turns "the model usually behaves" into "the output is provably in-bounds." A schema
> is a guardrail the attacker can't talk their way around.

---

## Guardrails — Topic, Content & Safety

Guardrails are policy checks that sit **around** the model, inspecting what goes in and what
comes out — independent of the prompt.

- **Topic** — keep the assistant on-scope ("only ACME product questions"); refuse off-topic.
- **Content** — block disallowed categories (hate, violence, self-harm, sexual content).
- **Safety / data** — filter PII, secrets, and profanity from inputs and responses.

On AWS you get this as a managed service — **Amazon Bedrock Guardrails** — that you can
apply to any model you run on Bedrock:

```python
import boto3
guardrail = boto3.client("bedrock-runtime")

resp = guardrail.apply_guardrail(
    guardrailIdentifier="gr-abc123", guardrailVersion="1",
    source="OUTPUT",                       # check the model's response
    content=[{"text": {"text": model_answer}}],
)
if resp["action"] == "GUARDRAIL_INTERVENED":
    model_answer = "I can't help with that request."   # blocked / masked
```

> Bedrock Guardrails can wrap an agent for quality — and the same control, seen through a
> security lens, is a policy layer that holds even when the prompt is compromised.

---

## Refusals, Governance & Auditability

**Handle refusals as a normal path.** Always check `stop_reason` — a `refusal` (or a
guardrail intervention) has a different shape than a happy answer. Don't crash, and don't
blindly retry an unsafe request.

```python
if message.stop_reason == "refusal":
    return "I'm not able to help with that."   # expected, not an error
```

**Govern the system so you can answer "what happened?"**
- **Log every consequential step** — the input, the tool calls and their arguments, the
  policy decision, whether a human approved. For agents, log the *reasoning chain*, not just
  the HTTP request. Log **denied** actions too — they're often the most informative.
- **Human oversight** for high-stakes or irreversible decisions.
- Keep an audit trail you can reconstruct after an incident.

> If you can't reconstruct *why* the agent did something, you can't investigate it,
> improve it, or prove to anyone that it was safe. Auditability is a security control.

---

## Abuse Controls — Rate Limiting & Denial-of-Wallet

AI calls cost real money per token, so a resource attack is also a **financial** attack —
"denial-of-wallet." One crafted request can look normal and still cost a fortune.

- **Token flooding** — a 50,000-word prompt: "summarize this."
- **Output amplification** — "write a 10,000-word essay on…"
- **Automated scraping** — a bot hammering your endpoint with max-token calls.

Controls a builder owns:

```python
MAX_INPUT_TOKENS = 8000
n = client.messages.count_tokens(model="claude-haiku-4-5",
                                 messages=[{"role": "user", "content": user_input}]).input_tokens
if n > MAX_INPUT_TOKENS:
    raise ValueError("Request too large")

# also: cap max_tokens on output · per-user & per-key rate limits
# · a daily spend budget with alerting · route cheap work to the fast tier
```

> Cost engineering *is* security engineering here. A `max_tokens` cap, a rate limit, and a
> billing alarm are three of the cheapest controls you'll ever add — and they stop the
> attack that quietly bankrupts the project.

---

## Lab 15 — Guardrails

**Stop here and run the lab now.** You'll wrap an assistant in validation and guardrails,
then confirm it stays safe and in-budget under abuse.

You will:
1. Enforce **structured output** with a JSON schema and reject anything off-schema
2. Add **input & output guardrails** — topic, content, and PII/secret filtering
3. Wire up **Bedrock Guardrails** (or an equivalent policy layer) and test an intervention
4. Handle **refusals** gracefully via `stop_reason`
5. Add **abuse controls** — token limits, `max_tokens` caps, and per-user rate limiting
6. Turn on **audit logging** and trace a blocked request end to end

Environment: Jupyter + AI SDK + Bedrock Guardrails · fast + top model tiers · **60–75 minutes**

---

## Part 2 — Defense in Depth, Reviewed (after the lab)

Welcome back. You now have all five layers: hardened prompts, a sanitized RAG pipeline,
least-privilege tools, validated output, and abuse controls. None is sufficient alone;
together they're a real posture.

Look back across these labs — each defense plugged a specific hole an attack drove
through. That's defense in depth: not one wall, but layers that each catch the last one's
misses.

> Quick debrief: if you could add only **one** control to your real app on Monday, which
> would it be — and why that one? Hold that answer.
