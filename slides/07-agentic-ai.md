# Building Agentic AI

Elephant Scale

---

# Building Agentic AI Systems

---

## Assistants vs. Agents

Not everything that uses an LLM is an agent. The line is **who drives the workflow**.

- **Assistant** — you drive. Single-turn or short back-and-forth: a chatbot, a sentiment
  classifier, a document extractor. The model responds; you decide what's next.
- **Agent** — the model drives. It manages the workflow: decides which steps to take, calls
  tools, judges whether it's done, and corrects itself along the way — within your guardrails.

```
  ASSISTANT              AGENT
  you → model → you      goal → [ model → tool → observe → decide ]↺ → done
  (you plan each step)   (the model plans the steps)
```

> Uses an LLM but is *not* an agent: simple chatbots, single-turn calls, classifiers, one-shot
> extraction. That's fine — most tasks don't need an agent. Reach for one only when the path is unknown up front.

---

## When Should You Build an Agent?

Agents add power *and* unpredictability. Use one when the problem earns it.

**Good fit for an agent:**
- The steps aren't known in advance — they depend on what's found along the way.
- The task needs several tools and real decisions about which to use.
- Judgment and self-correction beat a fixed script.

**Reach for a plain workflow instead when:**
- The steps are fixed — just call them in order (cheaper, faster, testable).
- One prompt or one tool call already does the job.
- You can't afford nondeterministic behavior or cost.

> Every bit of autonomy you grant is control you give up. The engineering question is never
> "can it be an agent?" but "how *little* autonomy does this task actually need?"

---

## Degrees of Autonomy

"Agentic" is a dial, not a switch. Systems sit somewhere on a spectrum from fully scripted to
fully autonomous.

- **Fixed workflow** — you code every step; the model fills in text. Maximum control.
- **Model-chosen tools** — you supply the tools; the model picks which and when.
- **Model-planned steps** — the model decomposes the goal into its own sub-steps.
- **Fully autonomous** — the model sets goals, plans, acts, and evaluates with minimal oversight.

The right level is a **design decision**, weighed against cost, latency, safety, and how much a
wrong action would hurt.

<!-- image: autonomy spectrum, scripted → autonomous -->

> Move up the dial only as far as the task requires — and pair every step up with a matching
> increase in guardrails and oversight.

---

## Anatomy of an Agent

Strip away the hype and an agent is three parts working in a loop.

- **A model** to manage execution — decide the next step, recognize when the goal is met, and
  correct course if a step fails.
- **Tools** to interact with the world — gather context and take actions, with the model
  *dynamically selecting* the right tool for each step.
- **Guardrails** — the boundaries the agent must operate within: what it may touch, spend, and
  do without asking.

```
        ┌──────────── GOAL ────────────┐
        ▼                               │
   ┌─────────┐   plan    ┌─────────┐    │
   │  MODEL  │ ────────▶ │  TOOLS  │    │ within
   │ (brain) │ ◀──────── │ (hands) │    │ GUARDRAILS
   └─────────┘  observe  └─────────┘    │
        │  "am I done?" ─── no ─────────┘
        └── yes ─▶ answer
```

> Brain, hands, and a fence. Remove the fence and you don't have a more capable agent — you have
> a liability.

---

## Planning & Reflection Loops

The behavior that makes agents feel intelligent is **reflection** — the model reviews its own
work and improves it, instead of accepting the first attempt.

- **Plan** — break the goal into steps before acting.
- **Act** — take a step (write code, call a tool, draft an answer).
- **Reflect** — critique the result against the goal. Good enough? If not, why?
- **Revise** — fix and try again. Loop until the work passes or a limit is hit.

```
   plan → act → observe result → critique → revise
                     ▲                        │
                     └──────── loop ──────────┘
```

> A concrete example from the lab: the agent writes chart code, *runs it*, looks at the chart it
> produced, decides it's wrong, and rewrites the code (V1 → V2). Self-correction, not luck.

---

## Multi-Agent Workflows

Hard problems often split better across **several specialized agents** than one generalist. Each
agent owns a role, and the output of one feeds the next.

- **Specialization** — a researcher, an analyst, a writer, a critic — each with its own tools and prompt.
- **Orchestration** — a coordinator routes work between them and assembles the result.
- **Pipelines** — research → generate → write → review, passed hand to hand.

```
  RESEARCHER ──▶ IMAGE GEN ──▶ COPYWRITER ──▶ REPORT
   (Tavily,       (visuals)     (draft copy)   (exec summary)
    arXiv, wiki)
```

- More modular and testable — you can evaluate each agent's step on its own.
- Also more moving parts, more cost, and more places for errors to compound.

> The lab builds exactly this: a market-research team where specialized agents hand off work to
> produce a final executive report.

---

## Human-in-the-Loop

Full autonomy is rarely the goal. The most useful production agents pause and ask a human at the
moments that matter.

- **Approval gates** — the agent proposes an action (send the email, run the DELETE); a human
  approves before it executes.
- **Checkpoints** — surface the plan for review before the agent acts on it.
- **Escalation** — low confidence, high stakes, or an unfamiliar situation → hand off to a person.

> Human-in-the-loop is not a failure of autonomy — it's the design that makes autonomy shippable.
> The skill is choosing *which* actions deserve a human's second look.

---

## Evaluating Agents

An agent that's right most of the time can still be wrong in expensive ways. You have to
**measure** it — and not just the final answer.

- **Component-level evaluation** — score individual steps, not only the end result. Did the
  research step pull from trustworthy sources? Did the tool get the right arguments?
- **Trajectories** — inspect the *path* the agent took, not just where it landed.
- **Guardrail checks** — verify it stayed inside its boundaries every run.

> The lab evaluates a research agent's web-search step against a list of *preferred domains* —
> a small, concrete example of grading one component instead of trusting the whole.

---

## The Model Context Protocol (MCP)

Every tool so far was wired up by hand. That doesn't scale: every agent re-implements a connector
for every data source. **MCP** is the emerging open standard that fixes this.

- Think **"a universal port for AI"** — one protocol to connect any agent to any tool or data
  source, instead of N×M custom integrations.
- A **server** exposes tools, data, and prompts; any MCP-aware **client** (agent) can discover and
  use them — no bespoke glue per pairing.
- Vendor-neutral and model-neutral: write a connector once, and any compliant agent can use it.

```
   ┌────────┐        MCP         ┌──────────────┐
   │ AGENT  │ ◀───────────────▶ │  MCP SERVER  │──▶ database / files / SaaS API
   │(client)│   standard tools   └──────────────┘
   └────────┘   & data over one protocol
```

> Tool use taught the model to call *a* function. MCP standardizes how it discovers and reaches
> *every* function — the difference between a one-off cable and a USB port.

---

## Lab 07 — Build an Agentic Workflow

**Stop here and run the lab now.** You'll build the core agentic patterns — reflection, tools,
evaluation, and multi-agent orchestration — one at a time.

You will:
1. Build a **reflection loop**: the agent writes chart code, runs it, critiques the chart, and rewrites it (V1 → V2)
2. Turn plain functions (time, weather, QR code, file writing) into **tools**, with automatic and manual tool-calling
3. Build a **research agent** (arXiv / web search / Wikipedia) and **evaluate** its search step against preferred domains
4. Orchestrate a **multi-agent team**: research → image → copywriting → executive report
5. See where **human oversight** and guardrails belong in each pattern

Environment: Jupyter + Anthropic Claude (tool use & reasoning) · fast model tier · **75–90 minutes**

---

## Part 2 — Reflecting on the Agentic Patterns (after the lab)

Welcome back. You've built agents that plan, reflect, use tools, and cooperate.

> Quick debrief: in the reflection lab, did the critique actually make V2 better — or just
> *different*? How would you *measure* that improvement rather than eyeball it?
