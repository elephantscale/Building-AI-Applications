# Functions, Tools & Agents

Elephant Scale

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
> *forced* to return data that fits it. This is the structured-output pattern, now typed and named.

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

> Quick debrief: in Lesson 6, where did the agent choose a tool you didn't expect — or skip one
> you did? What in the tool's *description* drove that choice?
