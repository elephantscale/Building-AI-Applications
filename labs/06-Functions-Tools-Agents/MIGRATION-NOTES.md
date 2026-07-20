# Migration Notes: OpenAI → Anthropic Claude

This lab was migrated from OpenAI to Anthropic Claude. Prompt text and example
data are unchanged wherever possible. Every notebook reads its model from
`LLM_MODEL` (default `claude-haiku-4-5`).

## Per-lesson changes

### Lesson 1 — raw function calling → Anthropic SDK tool use
- Replaced the OpenAI client (`OpenAI().chat.completions.create`) with the
  Anthropic SDK (`anthropic.Anthropic().messages.create(..., tools=[...])`).
- Tool schema uses Anthropic's `input_schema` (JSON Schema) instead of OpenAI's
  `parameters`. The example tool `get_current_weather` is kept unchanged.
- Tool calls are read from `tool_use` content blocks (`tool_use.name`,
  `tool_use.input`); `tool_use.input` is already a parsed dict (no `json.loads`).
- `function_call="auto"/"none"/{"name":...}` → `tool_choice={"type":"auto"}` /
  `{"type":"none"}` / `{"type":"tool","name":...}`.
- The result round-trip uses a `tool_result` block (`tool_use_id` + `content`)
  in a `user` message, following the claude-api tool-use pattern.

### Lessons 2–6 — LangChain
- `ChatOpenAI` → `ChatAnthropic` (`langchain_anthropic`) throughout.
- `convert_to_openai_function(...)` + `.bind(functions=...)` /
  `.bind(functions=..., function_call=...)` → `.bind_tools([...])` (with
  `tool_choice="ToolName"` where a tool was forced). Pydantic schemas are kept.
- Function-output parsers (`JsonOutputFunctionsParser`,
  `JsonKeyOutputFunctionsParser`) and `OpenAIFunctionsAgentOutputParser` were
  removed in favor of provider-agnostic handling:
  - **Lesson 4** (tagging/extraction): `model.with_structured_output(PydanticModel)`
    returns a validated Pydantic object; `.model_dump()` / a small lambda pulls
    out a dict or a sub-list.
  - **Lesson 5** (routing): routing branches on `AIMessage.tool_calls` directly.
  - **Lesson 6** (agent): the manual loop builds the scratchpad from
    `AIMessage` + `ToolMessage` objects; the final chatbot uses
    `create_tool_calling_agent` + `AgentExecutor` + `ConversationBufferMemory`.
- Schema-viewing cells use `convert_to_openai_tool` (from `langchain_core`). This
  is a **provider-agnostic LangChain utility** that produces a standard JSON
  Schema tool definition — the same shape `ChatAnthropic.bind_tools` uses
  internally. It makes no OpenAI API calls and does not require an OpenAI key.
- Deprecated import paths were updated (`langchain_community.vectorstores`,
  `langchain_community.document_loaders`), and direct tool `__call__` was
  changed to `.invoke(...)`.

## Things that could not move to Claude

- **Embeddings (Lesson 2, "More complex chain").** Anthropic has no embeddings
  API. The RAG retriever now uses a local, provider-agnostic HuggingFace model
  (`sentence-transformers/all-MiniLM-L6-v2` via `langchain_huggingface`). This
  keeps the example fully functional with **no OpenAI dependency** — the first
  run downloads the small embedding model. No `OPENAI_API_KEY` is needed.

## Behavioral notes

- **Lesson 2 fallbacks.** The fallback demo (`simple_chain.with_fallbacks([...])`)
  originally relied on a weak completion model producing malformed JSON. Claude
  reliably returns valid JSON, so the fallback path rarely triggers — the
  mechanism is still demonstrated.
- **`temperature=0`.** Kept where the original set it. It works on the default
  `claude-haiku-4-5` but returns HTTP 400 on Opus 4.7+/Sonnet 5 — remove it if
  you override `LLM_MODEL` to one of those models (see README).

## Dependency changes

- **Removed:** `openai`, `langchain_openai`, `tiktoken`, `openapi-schema-pydantic`
  (the OpenAPI-spec imports in Lesson 5 were unused and dropped).
- **Added:** `anthropic`, `langchain-anthropic`, `langchain-huggingface`,
  `sentence-transformers`, `beautifulsoup4` (used by `WebBaseLoader` in Lesson 4).
- **Env:** only `ANTHROPIC_API_KEY` is required. No `OPENAI_API_KEY`.
