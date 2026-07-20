# Migration Notes — Azure OpenAI → Anthropic Claude

This lab was migrated from Azure OpenAI to Anthropic Claude. Summary of changes.

## Global changes

- **`AzureChatOpenAI` → `ChatAnthropic`** (`from langchain_anthropic import
  ChatAnthropic`) in the LangChain lessons (L1, L2, L3).
- **`AzureOpenAI` (SDK) → `Anthropic` SDK** (`from anthropic import Anthropic`)
  in the raw-SDK lessons (L4, L5).
- Every Claude model is constructed as
  `ChatAnthropic(model=os.getenv("LLM_MODEL", "claude-haiku-4-5"), max_tokens=2048)`
  (and, for the SDK, `client.messages.create(model=os.getenv("LLM_MODEL",
  "claude-haiku-4-5"), max_tokens=2048, ...)`). Anthropic requires an explicit
  `max_tokens`.
- Model selection is via the `LLM_MODEL` env var, defaulting to
  `claude-haiku-4-5`. The old Azure config (`OPENAI_API_VERSION`,
  `AZURE_DEPLOYMENT`, `AZURE_OPENAI_API_KEY`, `AZURE_ENDPOINT`) is gone.
- `.env` / `.env.example`: Azure keys replaced with `ANTHROPIC_API_KEY`.
- `requirements.txt`: dropped `openai`, `langchain-openai`, and `pyodbc`
  (Azure/MSSQL-only). Added `anthropic` and `langchain-anthropic`; kept
  `langchain-experimental` (L2 dataframe agent), `sqlalchemy`, `pandas`,
  `numpy`, `tabulate`.

## Temperature (works on Haiku, 400s on Opus 4.7+/Sonnet 5)

L3 keeps `temperature=0` for deterministic SQL generation. This runs fine on the
default **Claude Haiku 4.5**. Opus 4.7+, Sonnet 5, and Fable 5 **removed the
sampling parameters** and return a `400` if `temperature` is passed. To run the
lab on `claude-opus-4-8` (or similar), remove the `temperature=0` argument from
L3's `ChatAnthropic(...)` constructor. The other lessons pass no temperature and
work on any current model.

## Per-lesson

- **L1 (first agent):** `AzureChatOpenAI` → `ChatAnthropic`. Prompt/`invoke`
  logic unchanged.
- **L2 (CSV / dataframe agent):** `AzureChatOpenAI` → `ChatAnthropic`.
  `create_pandas_dataframe_agent` accepts any LangChain chat model, so the agent
  construction and prompts are unchanged.
- **L3 (SQL agent):** `AzureChatOpenAI` → `ChatAnthropic` (with `temperature=0`,
  `max_tokens=500` preserved). `SQLDatabaseToolkit` and `create_sql_agent` accept
  any LangChain chat model; the prompt templates and the SQLite DB are unchanged.
- **L4 (function calling → Claude tool use):** Migrated from the Azure OpenAI SDK
  to Claude **tool use** with the Anthropic SDK. Tool definitions were converted
  from OpenAI's `{"type":"function","function":{...,"parameters":{...}}}` shape to
  Claude's `{"name","description","input_schema":{...}}`. The
  request/response loop now uses `client.messages.create(..., tools=...,
  tool_choice={"type":"auto"})`, reads `tool_use` content blocks, and returns
  results as `tool_result` blocks in a single follow-up user message. Both the
  weather example and the SQL-helper example were migrated. Query examples and
  the SQLite data are unchanged.

- **L5 (OpenAI Assistants API → Claude tool-use agent) — the notable
  substitution:** Anthropic Claude has **no equivalent of the OpenAI Assistants
  API** (no `client.beta.assistants`, threads, runs, or hosted
  `code_interpreter`). This lesson was **rebuilt** as a Claude tool-use agent: a
  small `run_conversation()` loop that calls `client.messages.create(...,
  tools=Helper.tools_sql)` and executes the same SQL helper functions
  (`get_hospitalized_increase_for_state_on_date`,
  `get_positive_cases_for_state_on_date`) until Claude returns a final answer. It
  answers the same natural-language questions over the same SQLite database
  (e.g. "how many hospitalized people we had in Alaska the 2021-03-05?"). The
  original Assistants-API flow (assistant/thread/run polling) and the second
  `code_interpreter` + file-upload section were removed — there is no direct
  Claude analog, and the tool-use agent covers the same learning goal. **No calls
  to `client.beta.assistants` / `chat.completions` remain.**

- **Helper.py:** `tools_sql` was converted from the OpenAI function-calling
  schema to Claude's tool-use schema (`name` / `description` / `input_schema`).
  The SQL helper functions and data-loading logic are unchanged.
