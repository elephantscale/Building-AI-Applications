# Prompt & Context Engineering

Elephant Scale

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

> Delimiters also reduce **prompt injection** risk — they mark "this is data, not instructions."

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

## Debrief — After the Lab

Welcome back. You've made the model summarize, classify, transform, and hold a conversation —
all by changing the prompt, never the model.

> Quick debrief: which prompt surprised you most — where a small wording change flipped
> the output? Where did the model still get it wrong, and how did you fix it?
