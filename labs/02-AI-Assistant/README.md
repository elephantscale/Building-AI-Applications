# Build an AI-Powered Assistant

The second Day-1 lab. In Lab 01 you learned to *prompt* a model. Here you turn those
prompting skills into **application code** against the Messages API — the one endpoint
every AI feature goes through.

You work through a single notebook, `02-ai-assistant.ipynb`, one section per step.

## You will

1. Initialize the client and make a basic **Messages API** call; read `message.content[0].text`
2. Maintain a **multi-turn conversation** — your app holds the history, the API is stateless (a small `ConversationManager` class)
3. Force reliable **JSON output** with a schema (`output_config.format`) and parse it in code
4. Add **streaming** with `client.messages.stream(...)` for a responsive experience
5. Handle **`stop_reason`** (`end_turn` / `max_tokens` / `refusal`) and errors defensively — never blindly read `content[0].text`
6. Wire it together into a simple **task assistant**

## Setup

```sh
python -m venv myenv
source myenv/bin/activate      # Windows: myenv\Scripts\activate
pip install -r requirements.txt

cp .env.example .env           # then edit .env and add your ANTHROPIC_API_KEY
jupyter lab                    # or: jupyter notebook
```

Only `ANTHROPIC_API_KEY` is required to run the whole notebook end to end.

## Model

The notebook defaults to **`claude-haiku-4-5`** — fast and inexpensive, ideal for a
teaching lab. Override it with `LLM_MODEL` in your `.env` (for example
`claude-opus-4-8`).

> **Note on temperature:** the streaming section (step 4) passes a `temperature`
> argument to show deterministic vs. creative output. This works on **Claude Haiku 4.5**
> but returns a **400 error on Opus 4.7+ and Sonnet 5**, which reject sampling
> parameters. If you set `LLM_MODEL` to one of those models, remove the `temperature=`
> argument from that cell before running it.
