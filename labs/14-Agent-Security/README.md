# Lab 14 — Agent Security (Claude)

Harden a tool-using AI agent. You take a small agent that can read a customer database and
send email, **exploit it** with an indirect prompt-injection attack, then lock it down
control by control. Everything is **simulated locally** — an in-memory SQLite database and
Python functions that only *record* what the agent tried to do. No real email, network, or
production data is ever touched. The only thing you need is an `ANTHROPIC_API_KEY`.

## Notebook

| Notebook | Topic |
|----------|-------|
| `14-agent-security.ipynb` | Attack a tool-using agent, then defend it: allowlist, typed tools, approval gates, egress control, logging |

## You will

1. Trigger an **indirect tool execution** attack — a poisoned database record makes the
   agent call `send_email` to exfiltrate data.
2. Apply a **tool allowlist** (deny-by-default dispatch keyed to the agent's role) and
   re-run — the disallowed call is rejected.
3. Replace the raw `execute_sql` tool with a **typed, parameterized, read-only** tool
   (`get_order`).
4. Add an **approval gate** on `send_email` — the agent proposes, the code decides;
   an unauthorized send is blocked (fails closed).
5. Enforce an **egress allowlist** so a tool can't POST to an attacker domain.
6. Turn on **tool-call logging** and find the attack in the logs.

Each step has a runnable **ATTACK**, then the **DEFENSE**, prints the before/after, and ends
with an **Exercise** TODO.

## Setup

```sh
python -m venv myenv
source myenv/bin/activate      # Windows: myenv\Scripts\activate
pip install -r requirements.txt

jupyter lab                    # or: jupyter notebook
```

> **Keys** come from the shared `labs/.env` (copy `labs/.env.example` → `labs/.env`
> once, in the repo's `labs/` directory). No per-lab `.env` needed — every lab reads it automatically.

`sqlite3` is part of the Python standard library — no separate install.

## Model & temperature

The notebook calls Claude through the `anthropic` SDK and a small tool-use loop, defaulting
to **`claude-haiku-4-5`** — fast and inexpensive, ideal for a class lab. Override the model
with `LLM_MODEL` in your `.env` (for example `claude-opus-4-8`).

The requests pass **no `temperature`** argument. This keeps the notebook portable: Opus-class
models (Opus 4.7+ / Sonnet 5) reject `temperature`, so you can switch `LLM_MODEL` to any
current model and the notebook runs unchanged.

> **Note:** the agent's behaviour under attack is model-driven and therefore not perfectly
> deterministic — the exact tool calls can vary run to run. That is the point of the lab: the
> *structural* controls (Steps 2–6) hold regardless of what the model decides, while the
> prompt-only defense in Step 1 does not.
