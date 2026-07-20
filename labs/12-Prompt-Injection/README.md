# Lab 12 — Prompt Injection (Claude)

Day 5 · Security. A hands-on lab for developers hardening AI applications. You build a
small vulnerable chatbot, attack it, watch a naïve filter fall over, and then stack
layered defenses that actually hold up.

The lab runs on Anthropic Claude via the `anthropic` Python SDK, but nothing here is
Claude-specific — every concept applies to any LLM you build on. In the prose we say
"the model" and "the AI app"; Claude appears only in the code.

## You will

1. Attack the chatbot with **direct injection** — override its system prompt and extract a
   fake secret it was told to keep.
2. Add a naïve **keyword filter** and watch it block the obvious payloads.
3. **Bypass** the filter with paraphrasing, Unicode homoglyphs, and base64-encoded
   instructions.
4. Land an **indirect injection** — plant the malicious instruction inside a "retrieved
   document" string the app concatenates into the prompt.
5. Build **layered defenses** — delimiter / instruction-data separation, input inspection
   (regex + a semantic check), and an allow-policy on topics.
6. Re-run every attack and print a table of what's now caught vs. what still slips through.

No embeddings or external services are needed — the "retrieved document" is just a
string. The lab runs end-to-end with only an `ANTHROPIC_API_KEY`.

## Notebook

| Notebook | Topic |
|----------|-------|
| `12-prompt-injection.ipynb` | Direct & indirect prompt injection, filter bypasses, layered defenses |

## Setup

```sh
python -m venv myenv
source myenv/bin/activate      # Windows: myenv\Scripts\activate
pip install -r requirements.txt

cp .env.example .env           # then edit .env and add your ANTHROPIC_API_KEY
jupyter lab                    # or: jupyter notebook
```

## Model

The notebook calls Claude and defaults to **`claude-haiku-4-5`** — fast and inexpensive,
ideal for the many small calls in this lab. Override the model with `LLM_MODEL` in your
`.env` (for example `claude-opus-4-8`).

> **Note on temperature:** the semantic-detector cell passes `temperature=0` to make the
> classifier deterministic. This works on Claude Haiku 4.5. If you switch `LLM_MODEL` to
> Claude Opus 4.7+ or Sonnet 5, those models **reject `temperature` with a 400** — remove
> the `temperature=0` argument from that one cell before running on a newer model.

## Safety note

The "secret" in this lab is a made-up string in the chatbot's system prompt. The attacks
target a toy app you run locally. Use these techniques only against systems you own or are
authorized to test.
