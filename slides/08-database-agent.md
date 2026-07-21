# AI Agents over Structured Data

Elephant Scale

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
> real attack surface — file it under things you'll want to lock down.

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
> here rests on the tool-use loop.

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

An agent that writes and runs queries is powerful and dangerous. Bake in safety from the start.

- **Read-only by default** — connect with a role that *cannot* write, drop, or delete.
- **Least privilege / RBAC** — scope the agent's database user to exactly the tables it needs.
- **Injection awareness** — the user's words become a query; treat every input as untrusted and
  validate generated SQL before it runs.
- **Bound the blast radius** — timeouts, row limits, and no destructive statements.

> The agent will do *exactly* what its credentials allow. The single highest-leverage control
> isn't a clever prompt — it's a **read-only database user**. Security lives in the permissions,
> not the politeness.

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
