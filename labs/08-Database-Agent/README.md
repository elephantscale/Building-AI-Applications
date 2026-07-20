# 08 — Building Your Own Database Agent (with Anthropic Claude)

Hands-on lab on building database agents, migrated from Azure OpenAI to
**Anthropic Claude**. Every notebook talks to Claude — via LangChain
(`ChatAnthropic`) or the Anthropic Python SDK directly. The dataset is the COVID
Tracking Project "all states history" CSV, loaded into a SQLite database
(`test.db`).

## Lessons

| # | Notebook | Topic |
|---|----------|-------|
| L1 | `L1_Your_First_AI_Agent.ipynb` | Your first LLM call with LangChain `ChatAnthropic` — translate a sentence. |
| L2 | `L2_Interacting_with_a_CSV_Data.ipynb` | Natural-language querying of a CSV via a pandas dataframe agent (`create_pandas_dataframe_agent`) backed by `ChatAnthropic`. |
| L3 | `L3_Connecting_to_a_SQL_Database.ipynb` | A SQL agent over SQLite using `SQLDatabaseToolkit` + `create_sql_agent`, driven by `ChatAnthropic`. |
| L4 | `L4_Azure_OpenAI_Function_Calling_Feature.ipynb` | Function calling → **Claude tool use** with the Anthropic SDK (`client.messages.create(..., tools=[...])`): a weather example and a SQL-helper example. |
| L5 | `L5_Leveraging_Assistants_API_for_SQL_Databases.ipynb` | The OpenAI Assistants API lesson, **rebuilt** as a Claude tool-use agent answering the same NL questions over the SQL DB (Claude has no Assistants-API equivalent — see MIGRATION-NOTES.md). |

## Setup

```bash
python -m venv myenv
source myenv/bin/activate
pip install -r requirements.txt

cp .env.example .env
# edit .env and add your ANTHROPIC_API_KEY
```

### API key

- **`ANTHROPIC_API_KEY`** — required for all notebooks. This lab is
  Claude-only; no OpenAI/Azure key is needed.

## Data & database

- `data/all-states-history.csv` — the source COVID dataset.
- `test.db` — the SQLite database (ships pre-built; L3 and L4 also rebuild it
  from the CSV). L3/L4/L5 query the `all_states_history` table.

## Model and temperature

- Default model: **`claude-haiku-4-5`**. Override with the `LLM_MODEL`
  environment variable, e.g. `LLM_MODEL=claude-opus-4-8`.
- Each Claude call uses `max_tokens=2048` (Anthropic requires an explicit
  `max_tokens`).
- **Temperature note:** L3 constructs `ChatAnthropic(..., temperature=0, ...)`
  for deterministic SQL. Temperature **works on Claude Haiku 4.5**, so the whole
  lab runs as written on the default model. It is **removed on Opus 4.7+ and
  Sonnet 5**, which return a `400` if `temperature` is passed. If you set
  `LLM_MODEL` to `claude-opus-4-8` (or any Opus 4.7+/Sonnet 5 model), delete the
  `temperature=0` argument in L3's `ChatAnthropic(...)` first.

## Credit

Based on the DeepLearning.AI short course *"Building Your Own Database Agent"*,
migrated from Azure OpenAI to Anthropic Claude for the Building AI Applications
course.
