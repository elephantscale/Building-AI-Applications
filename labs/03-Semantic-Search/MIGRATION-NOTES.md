# Migration Notes — Lab 03 Semantic Search

## Scope: what changed vs. what stayed

This is primarily a **Cohere / Weaviate** lab. Only the **final
answer-generation step** was migrated to Claude. Everything else stays on the
original providers **by design** — they are the subject being taught and have
no Claude equivalent.

### Migrated to Claude (Anthropic Python SDK)

| Location | Before | After |
| -------- | ------ | ----- |
| `Lesson5_Generating_Answers.ipynb` → `ask_andrews_article()` | `co.generate(model="command-nightly", ...)` | `client.messages.create(model=os.getenv("LLM_MODEL", "claude-haiku-4-5"), max_tokens=2048, messages=[...])` → returns `message.content[0].text` |
| `utils.py` → `generate_given_context()` | `co_client.generate(...)` | `claude_client.messages.create(...)` → returns `message.content[0].text` |

Details of the notebook change:
- Added `import anthropic` to the imports cell.
- Added `client = anthropic.Anthropic()` alongside the existing Cohere client.
- `ask_andrews_article()` now loops `num_generations` times calling Claude and
  returns a list of answer strings (preserving the original notebook's
  downstream `num_generations` behavior). The retrieval helper
  `search_andrews_article()` (Cohere embeddings + Annoy) and the prompt text
  are **unchanged**.

### Deliberately stays on Cohere / Weaviate (the teaching subject)

- **Cohere embeddings** (`co.embed`) — Lessons 2, 3, 5. NOT replaced.
- **Cohere Rerank** — Lesson 4. NOT replaced.
- **Weaviate keyword/BM25 + dense retrieval** — Lesson 1 and `utils.py`
  (`keyword_search`, `dense_retrieval`, `search_wikipedia_subset`). NOT replaced.
- **Annoy** dense-retrieval index over Cohere embeddings — Lessons 3 and 5.
  NOT replaced.
- **UMAP** visualization — Lesson 2 / `utils.py`. NOT replaced.

Prompts and retrieval/context-building logic were kept identical; only the LLM
call that turns retrieved context into a text answer was swapped.

## Model

- Default: `claude-haiku-4-5`.
- Override via `LLM_MODEL` (e.g. `claude-opus-4-8`).
- Params: `max_tokens=2048`; message built from the retrieved-context prompt.

## Required keys (see `.env.example`)

| Key | Used for |
| --- | -------- |
| `ANTHROPIC_API_KEY` | Claude answer generation (Lesson 5, `utils.py`) |
| `COHERE_API_KEY` | Cohere embeddings + rerank |
| `WEAVIATE_API_URL` | Weaviate cluster endpoint |
| `WEAVIATE_API_KEY` | Weaviate auth |
| `LLM_MODEL` | Optional Claude model override (default `claude-haiku-4-5`) |
| `COHERE_RERANK_MODEL` | Optional Cohere rerank model (Lesson 4) |

## Note

The original Lesson 5 used Cohere's `generate` API with `command-nightly`,
which Cohere has since disabled (`generate API is not supported` 400 error).
The Claude migration also resolves that breakage.
