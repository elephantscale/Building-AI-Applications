# Module 3 — AI Agents, Tools & Workflows

Elephant Scale

---

## Module 3 Agenda

- From prompts to **actions**: what a tool is and how tool use works
- The request → tool_use → execute → tool_result loop
- Structured extraction and tagging with tools
- **Lab 06 — Functions, Tools & Agents**
- Assistants vs. agents; degrees of autonomy
- Planning, reflection, and multi-agent workflows; human-in-the-loop
- **Lab 07 — Build an Agentic Workflow**
- Agents over structured data (CSV / SQL) and the **Model Context Protocol**
- **Lab 08 — AI Agent over a Database**

---

## Where We've Been, Where We're Going

- **Day 1** — you learned to *talk* to the model: prompts, structured output, the messages API.
- **Day 2** — you gave it *knowledge*: embeddings, retrieval, RAG over your own documents.
- **Day 3 (today)** — you give it *hands*. The model stops only answering and starts **doing** — calling functions, running queries, coordinating work.

> Yesterday the model read your data. Today it acts on your systems. That single shift —
> from text out to actions taken — is what turns a chatbot into an application.

---

# From Prompts to Actions

---

## What Is a Tool?

A **tool** (also called a **function**) is a capability you expose to the model: a plain
function in your code — get the weather, run a SQL query, send an email — described in a way
the model can understand and request.

The model itself never runs your code. It can only **ask** for a tool by name, with arguments.
Your application runs the function and hands back the result.

- You describe each tool: a **name**, a **description**, and a typed **input schema** (JSON Schema).
- The model decides *whether* and *when* to call it, and with *what* arguments.
- This is often called **tool use** or **function calling** — the same idea, two names.

> A tool schema is a job posting. You advertise what the tool does and what inputs it needs;
> the model decides when the job is worth doing and fills in the application.

---

## How Tool Use Works — The Loop

Tool use is a **conversation loop**, not a single call. The model asks; you answer; it continues.

```
  ┌──────────────────────────────────────────────────────────┐
  │                                                          │
  │   USER: "What's the weather in Boston?"                  │
  │                    │                                     │
  │                    ▼                                     │
  │   ┌──────────┐   request + tool schemas   ┌───────────┐ │
  │   │   YOUR   │ ─────────────────────────▶ │    THE    │ │
  │   │   APP    │                            │   MODEL   │ │
  │   │          │ ◀───────────────────────── │           │ │
  │   └──────────┘   stop_reason: tool_use    └───────────┘ │
  │        │          {name, input}                         │
  │        ▼                                                │
  │   EXECUTE get_current_weather("Boston")  →  "72°F sunny" │
  │        │                                                │
  │        ▼         tool_result block                      │
  │   ┌──────────┐ ─────────────────────────▶ ┌───────────┐ │
  │   │   YOUR   │                            │    THE    │ │
  │   │   APP    │ ◀───────────────────────── │   MODEL   │ │
  │   └──────────┘   final text answer        └───────────┘ │
  │                                                          │
  └──────────────────────────────────────────────────────────┘
```

> The loop can repeat many times — the model can call several tools in a row before it has
> enough to answer. Your app is the runtime; the model is the planner.

---

## Defining a Tool

You hand the model a list of tool definitions alongside the user's message. Each definition is
a name, a description, and a JSON Schema for the inputs.

```python
import anthropic

client = anthropic.Anthropic()

tools = [{
    "name": "get_current_weather",
    "description": "Get the current weather in a given location",
    "input_schema": {
        "type": "object",
        "properties": {
            "location": {"type": "string",
                         "description": "City and state, e.g. Boston, MA"},
            "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
        },
        "required": ["location"],
    },
}]
```

- The **description** is prompt engineering — a clear one makes the model call the tool correctly.
- The **schema** is a contract: the model must produce arguments that fit it.

> Rule of thumb: if you can't describe a tool clearly to a new teammate in one sentence, the
> model won't use it well either.

---

## The Tool-Use Loop in Code

The model's reply is a list of **content blocks**. When it wants a tool, `stop_reason` is
`tool_use` and one block is a `tool_use` block. You run the function and send back a
`tool_result`.

```python
messages = [{"role": "user", "content": "What's the weather in Boston?"}]

resp = client.messages.create(
    model="claude-haiku-4-5", max_tokens=1024, tools=tools, messages=messages,
)

if resp.stop_reason == "tool_use":
    block = next(b for b in resp.content if b.type == "tool_use")
    result = get_current_weather(**block.input)          # your code runs

    messages.append({"role": "assistant", "content": resp.content})
    messages.append({"role": "user", "content": [{
        "type": "tool_result",
        "tool_use_id": block.id,
        "content": result,
    }]})
    resp = client.messages.create(                       # model finishes the answer
        model="claude-haiku-4-5", max_tokens=1024, tools=tools, messages=messages,
    )
```

> Notice the `tool_result` goes back in a **user** message, tagged with the `tool_use_id`.
> That id is how the model matches the answer to the question it asked.

---

## Structured Extraction & Tagging with Tools

Tool use isn't only for taking actions — it's the most reliable way to get **structured data
out** of unstructured text. You define a tool whose *only* job is to receive well-typed fields.

- **Tagging** — classify a passage: sentiment, language, topic, urgency.
- **Extraction** — pull entities into records: people, dates, amounts, line items.

```python
from langchain_anthropic import ChatAnthropic
from pydantic import BaseModel, Field

class Tagging(BaseModel):
    sentiment: str = Field(description="positive, negative, or neutral")
    language: str = Field(description="ISO language of the text")

model = ChatAnthropic(model="claude-haiku-4-5", max_tokens=1024)
tagger = model.with_structured_output(Tagging)
tagger.invoke("Adoro questo prodotto, è fantastico!")
# Tagging(sentiment='positive', language='it')
```

> Same mechanism as calling a real function — but the "function" is a schema, so the model is
> *forced* to return data that fits it. This is Day 1's structured output, now typed and named.

---

## Tools in a Framework — bind_tools

Frameworks like LangChain smooth over the loop. You decorate plain functions, `bind` them to
the model, and the framework handles the schema generation and block plumbing.

```python
from langchain_core.tools import tool

@tool
def get_current_temperature(location: str, unit: str = "fahrenheit") -> str:
    """Get the current temperature for a location."""
    return f"72 degrees {unit} and sunny in {location}"

model = ChatAnthropic(model="claude-haiku-4-5", max_tokens=1024)
model_with_tools = model.bind_tools([get_current_temperature])

ai_msg = model_with_tools.invoke("What's the temperature in Boston?")
print(ai_msg.tool_calls)   # [{'name': 'get_current_temperature', 'args': {...}}]
```

- The function's **docstring** becomes the tool description; its **type hints** become the schema.
- One interface, many providers — the same `bind_tools` call works across models.

> The raw SDK teaches you what's happening; the framework saves you from writing it every time.
> You'll do both in the lab so the abstraction never becomes magic.

---

## Tools, Routing & Agents

Give the model *several* tools and it must **route** — pick the right one for each request. Chain
that decision into an execution loop and you have an **agent executor**.

- **Routing** — the model inspects the request and selects a tool (or none) from many.
- **Agent executor** — runs the tool, feeds the result back, and lets the model decide the next step until the task is done.
- **Memory** — carry the conversation forward so the agent remembers earlier turns and tool results.

```python
from langchain.agents import create_tool_calling_agent, AgentExecutor

agent = create_tool_calling_agent(model, tools, prompt)
executor = AgentExecutor(agent=agent, tools=tools, memory=memory)
executor.invoke({"input": "What's the weather in Boston, and QR-code that answer?"})
```

> The jump from "call one tool" to "an executor that keeps calling tools until done" is exactly
> the jump from a *function call* to an *agent*. Hold that thought — it's the whole next section.

---

## Lab 06 — Functions, Tools & Agents

**Stop here and run the lab now.** You'll turn plain Python functions into model tools and work
the tool-use loop end to end — first by hand, then with a framework.

You will:
1. Call a tool from the raw SDK: define `get_current_weather`, read the `tool_use` block, return a `tool_result`
2. Build simple chains with LCEL and add a retriever
3. Generate tool schemas from **Pydantic** models and force a tool with `tool_choice`
4. Do **tagging and extraction** with `with_structured_output`
5. Define several `@tool`s, bind them, and **route** between them from `tool_calls`
6. Assemble a **conversational agent** with memory (manual loop, then `AgentExecutor`)

Environment: Jupyter + Anthropic SDK & LangChain (`ChatAnthropic`) · fast model tier · **60–75 minutes**

> The labs run on **Claude** — tool use via the `anthropic` SDK and `bind_tools`. The pattern
> (schema in, `tool_use` out, `tool_result` back) is identical on any modern tool-capable LLM.

---

## Part 2 — From Tools to Agents (after the lab)

Welcome back. You made the model call your functions, extract typed data, route between tools,
and remember a conversation. You built the *mechanism* of agency.

Now we step up a level: when does a pile of tool calls become an **agent**? What makes a system
"agentic," how much autonomy should you grant it, and how do agents plan, reflect, and cooperate?

> Quick debrief: in Lesson 6, where did the agent choose a tool you didn't expect — or skip one
> you did? What in the tool's *description* drove that choice?

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
> a liability. We'll spend all of Day 5 on that fence.

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
> The skill is choosing *which* actions deserve a human's second look. (Day 5 makes these gates a
> security control.)

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

## Part 2 — Agents Meet Your Data (after the lab)

Welcome back. You've built agents that plan, reflect, use tools, and cooperate. So far their
"world" has been APIs and files.

The highest-value enterprise target is different: your **structured data** — the CSVs and SQL
databases that run the business. Next we point an agent at a database and let people ask it
questions in plain English.

> Quick debrief: in the reflection lab, did the critique actually make V2 better — or just
> *different*? How would you *measure* that improvement rather than eyeball it?

---

# Agents over Structured Data

---

## The Structured-Data Problem

Most enterprise value lives in tables — CSVs, spreadsheets, SQL databases. The people who need
answers usually can't write the query.

- Analysts wait on engineers for one-off SQL.
- Dashboards answer yesterday's questions, not today's.
- The data is right there — the **interface** is the bottleneck.

An agent closes that gap: the user asks in natural language, the agent translates to a query,
runs it, reads the result, and answers — looping if the first query wasn't right.

> This is RAG's cousin. RAG retrieves from *unstructured* text; a data agent retrieves from
> *structured* rows. Both ground the model in real data instead of its memory.

---

## Agents over CSV Data

The simplest data agent runs over a dataframe. It writes and executes **pandas** code to answer
questions about the file.

```python
from langchain_experimental.agents import create_pandas_dataframe_agent
import pandas as pd

df = pd.read_csv("all-states-history.csv")
agent = create_pandas_dataframe_agent(
    ChatAnthropic(model="claude-haiku-4-5", max_tokens=2048),
    df, verbose=True, allow_dangerous_code=True,
)
agent.invoke("How many patients were hospitalized in Texas on 2021-03-01?")
```

- The agent **writes pandas code**, runs it, reads the result, and phrases an answer.
- Great for exploration; note `allow_dangerous_code` — it *executes generated code*.

> Convenient and a little scary at once. Executing model-written code is a real capability and a
> real attack surface — file it under "things Day 5 will make you lock down."

---

## Agents over SQL Databases

For real databases, a **SQL agent** inspects the schema, writes SQL, runs it, and recovers from
its own errors — reading a failed query's message and trying again.

```python
from langchain_community.agent_toolkits import SQLDatabaseToolkit, create_sql_agent
from langchain_community.utilities import SQLDatabase

db = SQLDatabase.from_uri("sqlite:///test.db")
model = ChatAnthropic(model="claude-opus-4-8", max_tokens=2048)

agent = create_sql_agent(model, toolkit=SQLDatabaseToolkit(db=db, llm=model),
                         verbose=True)
agent.invoke("Which state had the most hospitalizations, and on what date?")
```

- The toolkit gives the agent tools to **list tables, read schema, run a query, and check it**.
- The self-correction loop — read the error, rewrite the SQL — is the reflection pattern again.

> Under the hood it's still tool use: the "tools" are `run_query` and `get_schema`. Everything
> today rests on the loop you built in Lab 06.

---

## Function Calling Against a Database

Beyond the prebuilt toolkits, you can expose your *own* database operations as tools — giving you
exact control over what the agent may do.

```python
tools = [{
    "name": "query_states_history",
    "description": "Run a read-only SQL SELECT against the all_states_history table.",
    "input_schema": {
        "type": "object",
        "properties": {"sql": {"type": "string",
                               "description": "A single SELECT statement"}},
        "required": ["sql"],
    },
}]
# model asks → you validate the SQL → execute → return rows as a tool_result
```

- You decide the tool's *shape*: one narrow `query_states_history`, not open database access.
- Every argument passes through **your** code — the natural place to validate before executing.

> A narrow tool is a security boundary. "Run any SQL" and "run one read-only SELECT against one
> table" are the same feature to the model and worlds apart to your database.

---

## Safety for Data Agents

An agent that writes and runs queries is powerful and dangerous. Bake in safety from the start —
today's preview of Day 5.

- **Read-only by default** — connect with a role that *cannot* write, drop, or delete.
- **Least privilege / RBAC** — scope the agent's database user to exactly the tables it needs.
- **Injection awareness** — the user's words become a query; treat every input as untrusted and
  validate generated SQL before it runs.
- **Bound the blast radius** — timeouts, row limits, and no destructive statements.

> The agent will do *exactly* what its credentials allow. The single highest-leverage control
> isn't a clever prompt — it's a **read-only database user**. Security lives in the permissions,
> not the politeness.

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

## Lab 08 — AI Agent over a Database

**Stop here and run the lab now.** You'll build agents that answer natural-language questions
over a real dataset (COVID "all states history"), first as a CSV, then as a SQL database.

You will:
1. Make a first agent call with `ChatAnthropic` to warm up
2. Query a **CSV** in plain English with a **pandas dataframe agent**
3. Build a **SQL agent** over SQLite with `SQLDatabaseToolkit` + `create_sql_agent`
4. Expose the database through your own **tool use** (`tools=[...]`) for precise control
5. Rebuild an assistant-style Q&A over the SQL data as a Claude tool-use agent
6. Note where **read-only access, RBAC, and query validation** belong

Environment: Jupyter + Anthropic Claude & LangChain · fast + top model tiers · **60–75 minutes**

---

## Module 3 Summary

- A **tool** is a function you describe to the model; the model *asks*, your app *executes*.
- Tool use is a **loop**: request → `tool_use` → run it → `tool_result` → answer, repeated as needed.
- The same mechanism gives you reliable **structured extraction and tagging**.
- An **agent** is a model that drives its own workflow — plan, act, reflect, correct — within guardrails.
- Grant the **least autonomy** the task needs; add human-in-the-loop where actions matter.
- **Multi-agent** pipelines split hard work across specialists; evaluate steps, not just answers.
- Agents over **CSV/SQL** turn plain English into queries — powerful, and unsafe without read-only access, RBAC, and validation.
- **MCP** is the emerging standard for connecting any agent to any tool or data source.

---

## What's Next

**Day 4 — Production & Serverless AI on the Cloud**

You can build agents. Tomorrow you learn to **deploy** them — off your laptop and into
production, event-driven and pay-per-use:

- Foundation models on **Amazon Bedrock** (Claude via `boto3`)
- A real serverless pipeline: transcribe audio → summarize, on **AWS Lambda**
- Event-driven architecture (an S3 upload triggers the whole pipeline)
- Bedrock **agents, action groups, guardrails, and knowledge bases**
- Logging and observability with CloudWatch

> You've built the brains and the hands. Next you give them somewhere to *live* — a serverless
> home that scales to zero and wakes on demand.

---
