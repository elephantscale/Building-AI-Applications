# Lab 15 — Guardrails, Validation & Responsible AI (Claude)

Wrap a Claude-powered assistant in a layer of policy checks, output validation, and abuse
controls so the system stays **provably in-bounds** — even when the prompt is hostile or the
traffic is abusive. For developers adding guardrails and validation to an AI application.

## You will

1. **Enforce structured output** with a JSON schema (an `enum` action) and reject anything off-schema.
2. Add **input & output guardrails** — a topic check, a content/safety check, and PII/secret filtering (regex for emails, keys, and credit cards, plus a cheap Claude classifier).
3. Wire up **Amazon Bedrock Guardrails** as an *optional* managed policy layer, with the local guardrail as a fallback.
4. Handle **refusals** gracefully via `stop_reason == "refusal"` — a normal path, not a crash.
5. Add **abuse controls** — a `count_tokens` input limit, a `max_tokens` output cap, and a per-user rate limiter.
6. Turn on **audit logging** and trace a blocked request end to end.

## Notebook

| Notebook | Topic |
|----------|-------|
| `15-guardrails.ipynb` | Structured output, input/output guardrails, Bedrock (optional), refusals, abuse controls, audit logging |

## Setup

```sh
python -m venv myenv
source myenv/bin/activate      # Windows: myenv\Scripts\activate
pip install -r requirements.txt

cp .env.example .env           # then edit .env and add your ANTHROPIC_API_KEY
jupyter lab                    # or: jupyter notebook
```

The lab runs **end-to-end with only `ANTHROPIC_API_KEY`**. The Amazon Bedrock Guardrails step
(Step 3) is optional and skippable — when AWS credentials aren't present, that step falls back
to the local guardrail from Step 2, so nothing else changes. To try Bedrock, install `boto3`
(commented in `requirements.txt`) and set the AWS variables in `.env`.

## Model & temperature

The notebook calls Claude through the `anthropic` SDK and defaults to **`claude-haiku-4-5`** —
fast and inexpensive, ideal for the many small guardrail/classifier calls here. Override the
model with `LLM_MODEL` in your `.env` (for example `claude-opus-4-8`).

> **No `temperature` is passed anywhere.** Current top-tier models (Opus 4.7+, Sonnet 5) reject
> the parameter, and guardrails want *deterministic*, in-schema output rather than creative
> variance. Structured output is enforced with `output_config.format` and a JSON schema, which
> Claude Haiku 4.5 and the Opus/Sonnet tiers all support.

## Notes

- Vendor-neutral prose; the code is Claude-specific via the official `anthropic` SDK.
- Part of Module 5 (Securing AI Applications), Day 5 of *Building AI Applications*.
