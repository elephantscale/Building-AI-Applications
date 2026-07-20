# Lab 16 — Capstone: Harden Your AI Application (Claude)

**Day 5 · Security · ~90 minutes**

The proof-of-skill for the whole course. You take **AcmeAssist** — a simulated
enterprise AI assistant (RAG + tools + agent), already in production and already
vulnerable — and defend it end to end while a simulated attacker hits every
surface at once. This capstone integrates Labs 12–15.

## Scenario

AcmeAssist is the shape of the app you built all week: a RAG layer over a company
knowledge base, an agent with tools (look up an order, send an email), and the
model that ties them together. A five-vector attacker comes at it:

| Attack | OWASP LLM | Surface |
|---|---|---|
| Prompt injection | LLM01 | Prompt |
| Retrieval poisoning | LLM08 | Retrieval |
| Tool abuse | LLM07 | Tools |
| Credential theft | LLM06 | Prompt / Output |
| Excessive consumption | LLM10 | Whole app |

The notebook hands you the **vulnerable assistant** and an **attack harness**, runs
a **scoreboard** (all five attacks succeed), and then walks you through installing
one control per section until every attack fails.

## What you build

1. **Input inspection & injection detection** on the entry channel
2. **Sanitized, provenance-aware RAG** that quarantines poisoned uploads
3. **Least-privilege, approval-gated tools** with scoped credentials
4. **Output guardrails & validation** (secret redaction, exfil-link stripping)
5. **Abuse monitoring** — rate limits and token budgets
6. **Audit logging**, then a short **incident report** of what the attacker tried
   and how each control responded

Each section is a scaffolded **TODO** for you to try, followed by a **reference
solution** cell you can run to install a working control. Running the reference
cells top to bottom takes the notebook from *5/5 attacks succeed* to *0/5*.

## Setup

```sh
python -m venv myenv
source myenv/bin/activate      # Windows: myenv\Scripts\activate
pip install -r requirements.txt

cp .env.example .env           # then edit .env and add your ANTHROPIC_API_KEY
jupyter lab                    # or: jupyter notebook
```

Then open `16-capstone.ipynb` and run the cells top to bottom.

## Model & temperature

The notebook calls Claude through a small `get_completion()` helper and defaults
to **`claude-haiku-4-5`** — fast and inexpensive for this lab's many small calls.
Override with `LLM_MODEL` in your `.env` (for example `claude-opus-4-8`). No
`temperature` is passed, so every model in the current lineup works unchanged.

## Runs on a single key

Everything runs locally with only `ANTHROPIC_API_KEY`:

- **Chroma** with its built-in default embeddings (no OpenAI/Cohere key),
- an in-memory **SQLite** database for orders and the audit log,
- all tools **simulated locally** (no real email, no external calls).

> Vendor-neutral by design: the code calls Claude, but every defense — input
> inspection, provenance-aware RAG, least-privilege tools, output validation,
> abuse controls, audit logging — applies to any LLM you build on.
