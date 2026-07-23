# Migration Notes — OpenAI → Anthropic Claude

## Update — embeddings moved to a local on-device model

Embeddings in notebooks 04 (Q&A) and 05 (Evaluation) were switched from OpenAI
(`OpenAIEmbeddings`) to a **local HuggingFace embedder**
(`HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")`
from `langchain-huggingface`). This drops the OpenAI dependency entirely:
`langchain-openai` was removed from `requirements.txt` (replaced by
`langchain-huggingface` + `sentence-transformers`) and `OPENAI_API_KEY` was
removed from `.env.example`. The vector index (`VectorstoreIndexCreator` /
`DocArrayInMemorySearch`) and all other code are unchanged. **The lab now needs
only `ANTHROPIC_API_KEY`.** The "KEPT OpenAIEmbeddings" notes below are
historical and no longer apply.

---

This lab was migrated from OpenAI to Anthropic Claude. Summary of what changed.

## Global changes

- **`ChatOpenAI` → `ChatAnthropic`** (`from langchain_anthropic import ChatAnthropic`)
  everywhere it was used for generation.
- Every `ChatAnthropic(...)` is constructed as
  `ChatAnthropic(model=os.getenv("LLM_MODEL", "claude-haiku-4-5"), max_tokens=2048, ...)`.
  Anthropic requires an explicit `max_tokens`, so `max_tokens=2048` was added.
- `LLM_MODEL` now defaults to `claude-haiku-4-5` (previously read as a bare
  `os.environ['LLM_MODEL']` / OpenAI model name). Override via the `LLM_MODEL`
  env var, e.g. `claude-opus-4-8`.
- `temperature` values from the lessons (`0.0`, and `0.9` in notebook 03) were
  kept because they work on Haiku 4.5. They **must be removed** if you switch
  `LLM_MODEL` to Opus 4.7+ or Sonnet 5, which reject `temperature` with a 400.
- `.env` keys: `OPENAI_API_KEY` → `ANTHROPIC_API_KEY` as the primary key.
  `OPENAI_API_KEY` is still needed for notebooks 04 and 05 (embeddings).

## Per-notebook

- **01 (model/prompts/parsers):** The "direct API call" section moved from the
  `openai` SDK to the **`anthropic` SDK** (`anthropic.Anthropic().messages.create`).
  `ChatOpenAI` → `ChatAnthropic`. Deprecated `chat(messages)` calls updated to
  `chat.invoke(messages)`. Prompt/parser logic unchanged.
- **02 (memory):** `ChatOpenAI` → `ChatAnthropic`. Removed the unused
  `from langchain.llms import OpenAI` import. Memory logic unchanged. Token-buffer
  and summary memory use the Claude LLM for their token counting / summarization.
- **03 (chains):** `ChatOpenAI` → `ChatAnthropic` in all three model
  constructions. Sequential and router chain logic unchanged.
- **04 (Q&A / vectors):** LLM moved to `ChatAnthropic`; the `OpenAI(...)` LLM used
  by `index.query` also became `ChatAnthropic`. **`OpenAIEmbeddings` KEPT** for
  the vector index — this notebook needs both `ANTHROPIC_API_KEY` and
  `OPENAI_API_KEY`.
- **05 (evaluation):** LLM and the `QAGenerateChain` / `QAEvalChain` eval LLM all
  use `ChatAnthropic`. **`OpenAIEmbeddings` KEPT** for the vector index (needs
  both keys).
- **06 (agent):** Migrated from OpenAI functions to Claude/provider-agnostic
  **tool calling**:
  - `ChatOpenAI(...).bind(functions=...)` → `ChatAnthropic(...).bind_tools(tools)`.
  - `format_tool_to_openai_function` removed (no longer needed with `bind_tools`).
  - `OpenAIFunctionsAgentOutputParser` → `ToolsAgentOutputParser`
    (`langchain.agents.output_parsers.tools`).
  - `format_to_openai_functions` → `format_to_tool_messages`
    (`langchain.agents.format_scratchpad.tools`).
  - The tools parser returns a **list** of actions (Claude can request several at
    once), so intermediate inspection cells were adapted (`result.tool` →
    `result[0].tool`, etc.) and the manual `run_agent` loops index the first
    action. The `AgentExecutor` + Panel chatbot handles the list internally.
  - Fixed a pre-existing bug in `search_wikipedia`: `self.wiki_client.exceptions.*`
    → `wikipedia.exceptions.*` (the `self` reference was undefined).
  - The weather and Wikipedia tools were kept unchanged.

## What was NOT moved to Claude

- **OpenAI embeddings** (`OpenAIEmbeddings`) in notebooks 04 and 05. Only the LLM
  was migrated to Claude; the embeddings/vector index remain on OpenAI, so those
  two labs require both `ANTHROPIC_API_KEY` and `OPENAI_API_KEY`.
