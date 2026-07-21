# Module 1 — Foundations & Prompt Engineering

Elephant Scale

---

## Module 1 Agenda

- What modern AI applications actually are (and aren't)
- Foundation models, LLMs, and how to choose one
- Why building with AI is suddenly cheap
- Prompt engineering: two principles that carry the whole course
- **Lab 01 — Prompt Engineering**
- Talking to AI from code: the messages API
- Structured output, tokens, and streaming
- **Lab 02 — Build an AI-Powered Assistant**

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

---

# Prompt & Context Engineering

---

## What Is a Prompt?

A **prompt** is the instruction and context you hand the model. Prompt engineering is the
craft of writing prompts that reliably produce the output you want.

It is the highest-leverage skill in this course: the same model, given a better prompt,
goes from useless to production-ready. Two principles carry almost everything.

- **Principle 1 — Write clear and specific instructions.**
- **Principle 2 — Give the model time to think.**

> "Clear" is not the same as "short." A longer prompt with more context usually beats a terse one.

---

## Principle 1 — Clear & Specific Instructions

The model can't read your mind. Ambiguity is where wrong answers come from. Four tactics:

- **Tactic 1 — Use delimiters** to mark distinct parts of the input (```` ``` ````, `"""`, `<tag>`).
- **Tactic 2 — Ask for structured output** (JSON, HTML) so you can parse it downstream.
- **Tactic 3 — Ask the model to check conditions** before acting ("if the text has steps, list them; otherwise say 'no steps'").
- **Tactic 4 — Few-shot prompting** — show one or two examples of the input→output you want.

---

## Tactic 1 & 2 — Delimiters and Structured Output

```python
text = """
You should express what you want a model to do by providing
instructions that are as clear and specific as you can make them.
"""

prompt = f"""
Summarize the text delimited by triple backticks into a single sentence.
```{text}```
"""
response = get_completion(prompt)
```

Ask for JSON when you need to *use* the output, not just read it:

```python
prompt = """
Generate three made-up book titles with authors and genres.
Return JSON with keys: book_id, title, author, genre.
"""
```

> Delimiters also reduce **prompt injection** risk — they mark "this is data, not instructions." More on that Day 5.

---

## Principle 2 — Give the Model Time to Think

Ask for the answer too fast and the model guesses. Ask it to **work step by step** and it reasons.

- **Specify the steps** of a task explicitly (summarize → translate → extract names → output JSON).
- **Ask it to work out its own solution first**, *then* judge — don't ask "is this student's answer right?" (it rushes to "yes"); ask it to solve the problem itself, then compare.

```python
prompt = f"""
First work out your OWN solution to the problem.
Then compare it to the student's solution and decide if the student is correct.
Don't decide until you've solved it yourself.

Question: ```{question}```
Student's solution: ```{student_solution}```
"""
```

> This is the seed of "reasoning." Modern models do more of it automatically — but explicit structure still helps on hard tasks.

---

## The Everyday Prompting Toolkit

The same two principles power a set of tasks you'll use constantly:

- **Iterative refinement** — a prompt is a first draft. Run it, see what's wrong (too long? wrong focus? missing a table?), refine, repeat.
- **Summarizing** — with a word limit, or focused on a specific angle (shipping, price). Try "extract" instead of "summarize" for facts.
- **Inferring** — sentiment, emotion, topics — as one call returning structured JSON.
- **Transforming** — translation, tone (slang → business), format (JSON → HTML), proofreading.
- **Expanding** — turn a few facts into a tailored email or description.

> These aren't separate features — they're all the *same* API call with a different prompt. That's the point.

---

## The Chat Format & System Prompts

Real applications hold a **conversation**, not a single call. Two ideas:

- **Roles** — a conversation is a list of messages with roles: `user` and `assistant`.
- **System prompt** — a top-level instruction that sets the assistant's persona and rules for the whole conversation ("You are a friendly support agent for Acme").

```python
message = client.messages.create(
    model=MODEL,
    max_tokens=1024,
    system="You are an assistant that speaks like Shakespeare.",
    messages=[{"role": "user", "content": "Tell me a joke."}],
)
```

> Note: in this API the **system prompt is its own parameter**, not a message in the list —
> a small but important difference between providers. You'll see it in the lab.

---

## Lab 01 — Prompt Engineering

**Stop here and run the lab now.** You'll put both principles and the whole toolkit to
work against a real AI model.

You will:
1. Set up your environment and make your first AI call via `get_completion()`
2. Practice clear instructions: delimiters, structured JSON output, condition checks, few-shot
3. Give the model time to think — multi-step prompts and self-verification
4. Iterate a prompt from bad → good on a real product fact sheet
5. Summarize, infer sentiment/topics, transform, and expand text
6. Build a multi-turn chatbot and a working **OrderBot** with a system prompt

Environment: Jupyter + AI Python SDK · fast/cheap model tier · **60–75 minutes**

---

## Part 2 — From Prompts to Applications (after the lab)

Welcome back. You've made the model summarize, classify, transform, and hold a conversation —
all by changing the prompt, never the model.

Now we go from notebook experiments to **application code**: how you actually call the AI
from a program, handle its responses safely, and get structured data back every time.

> Quick debrief: which prompt surprised you most — where a small wording change flipped
> the output? Where did the model still get it wrong, and how did you fix it?

---

# Working with the AI API

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
- Alternative: **tool use** with a typed schema (Day 3) — same idea, different shape.

> This is how you move from "the model usually returns JSON" to "the model *always* returns valid JSON."

---

## Streaming & Handling Responses Safely

- **Streaming** — get tokens as they're generated, for responsive UIs and long outputs.
- **`stop_reason`** — always check *why* the model stopped: `end_turn` (done), `max_tokens` (truncated — raise the cap), `tool_use` (wants a tool — Day 3), `refusal` (declined).

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

---

## Module 1 Summary

- Modern AI apps are models **wired into real systems and data** — not just chat.
- Building with AI is cheap now; the value is in the **application layer**.
- Providers ship a *family* of models — choose the tier per job behind one API.
- Prompt engineering rests on two principles: **be clear and specific**, and **give the model time to think**.
- The same API call — reworded — summarizes, infers, transforms, and converses.
- Production calls need **structured output**, **token/cost awareness**, streaming, and defensive handling.

---

## What's Next

**Day 2 — AI with Enterprise Data (RAG)**

The model is powerful but doesn't know *your* documents. Tomorrow we fix that:

- Embeddings and semantic search
- Retrieval-Augmented Generation (RAG)
- Vector databases and document pipelines
- Building an assistant that answers from your own knowledge base

> You've learned to talk to AI. Next you'll teach it what your organization knows.

---
