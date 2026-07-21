# Capstone — Harden Your AI Application

Elephant Scale

---

## Capstone — Harden Your AI Application

Everything comes together. You take an AI assistant — RAG + tools + agent, the shape of a
real production app — and defend it end to end while a simulated attacker comes at every
surface at once.

The attacker will attempt:
- **Prompt injection** — direct and indirect, to override your rules
- **Retrieval poisoning** — a malicious document to hijack answers
- **Tool abuse** — driving your agent into an action it shouldn't take
- **Credential theft** — extracting any secret the model can see
- **Excessive consumption** — burning tokens to run up the bill

> This is the whole day, live. There's no single "right" answer — there's a system that
> holds up. Your goal is to make every one of those attacks *fail*, or at least *cost more
> than it's worth*.

---

## Lab 16 — Capstone: Harden Your AI Application

**Stop here and run the lab now.** Teams defend a full AI assistant against a live attacker
across every surface from this module.

You will:
1. Build **input inspection** and prompt-injection detection on the entry channel
2. Stand up a **sanitized, provenance-aware RAG** pipeline that rejects poisoned uploads
3. Convert tools to **least-privilege, approval-gated** designs with scoped credentials
4. Enforce **output guardrails and validation** on everything the model returns
5. Add **abuse monitoring** — rate limits, token budgets, and alerting
6. Turn on **audit logging** and produce a short incident report of what the attacker tried
   and how each control responded

Environment: Jupyter + AI SDK + Chroma + Bedrock Guardrails · full stack · **90 minutes**

> This is your proof of skill: an AI app you built **and** defended.
