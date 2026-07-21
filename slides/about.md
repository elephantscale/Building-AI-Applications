# Building AI Applications

Elephant Scale

---

## How This Course Works

- **Concepts and fundamentals first** — the APIs change monthly; the ideas don't.
- **API-driven** — nothing to memorize. You'll always have the docs.
- **Highly interactive** — questions and tangents are welcome.
- **Hands-on** — you learn by doing. Every topic lands in a lab.

> Analogy: learning to fly. Instruction gets you in the cockpit — but it's the **flight time** that makes you a pilot. This course is mostly flight time.

---

## About You

Quick round the room:

- Your name
- Your background — developer, data scientist, architect, manager?
- Technologies you work with day to day
- Your AI/ML familiarity, 1–4 (1 = brand new, 4 = you've shipped it)
- One non-technical thing about you (favorite food, hobby, anything)

---

# Modern AI Applications Today

---

## Beyond the Chatbot

The popular image of AI is a chat window. The reality in production is bigger.
Organizations are building applications that:

- understand their **documents** and internal knowledge
- **assist** engineers, analysts, and support staff
- **automate** repetitive, judgment-light workflows
- securely **interact** with internal systems and data
- **generate** reports, summaries, and drafts
- **reason** over operational and business data

> The chat box is the demo. The **application** — AI wired into real systems and data — is the product.

---

## It's Now Cheap to Build with AI

> "It is indeed expensive to train cutting-edge foundation models. But it's now very inexpensive to **build** a wide range of AI applications." — Andrew Ng

- Training a frontier model: hundreds of millions of dollars.
- **Using** one through an API: fractions of a cent per call.
- Token prices have fallen dramatically year over year.

The economic shift: the hard, expensive part is done by the model providers. Your job —
and this course — is the **application layer** on top.

<!-- image: falling token-price chart -->

---

## Why This Class Is Different

- **Before:** we taught machine learning. Students enjoyed the show but didn't leave able to do magic.
- **Now:** we teach *building with AI*. You leave able to ship things that felt like magic a year ago.

The difference isn't the students — it's that the capability moved into an **API call**.
The skill is no longer training models; it's **composing** them into applications.

---

## Foundation Models & LLMs

A **foundation model** is a large model pre-trained on broad data, then adapted to many tasks.
A **Large Language Model (LLM)** is a foundation model for text (and increasingly images, audio, code).

What an LLM does, mechanically: given some text, predict what comes next — trained at
enormous scale until "what comes next" includes reasoning, translation, summarization,
and code.

- **Reasoning models** spend extra compute "thinking" before answering — better on hard, multi-step problems.
- **Hosted vs. local** — call a provider's API (fast to start, always current) or run an open model yourself (control, privacy, cost at scale). We start hosted.

> You don't need to know how the engine is built to drive the car well. You *do* need to know its capabilities and limits.

---

## Capabilities and Limits

**Strong at:** summarizing, drafting, classifying, extracting structure, translating,
explaining, writing and reviewing code, following instructions, using tools.

**Watch out for:**
- **Hallucinations** — a confident, fluent answer that is simply wrong.
- **No inherent truth check** — the model predicts plausible text, not verified fact.
- **Knowledge cutoff** — it doesn't know last week unless you give it the data.
- **Context limits** — there's a ceiling on how much it can consider at once (large, but finite).

> Design principle for the whole course: **trust the model's fluency, verify its facts.**
> The techniques ahead — RAG, tools, guardrails — are largely about closing that gap.

---

## Choosing an AI Model

Providers ship a *family* of models. You pick the tier to fit the job — a real
cost/quality decision you'll make in every application:

- **Most capable** — hardest reasoning, agents, RAG, tool use. Highest cost per call.
- **Balanced** — strong quality at lower cost; good default for production volume.
- **Fast & cheap** — simple, high-volume calls where speed and price matter most.

- Frontier models offer large context windows and long outputs.
- A good API keeps **one interface** across the whole family — swap tiers by changing a string.

> The labs in this course run on **Anthropic's Claude** models — the *most capable* tier for
> agents and RAG, the *fast & cheap* tier for high-volume exercises. Everything you learn
> applies to any modern LLM; only the model name changes.
