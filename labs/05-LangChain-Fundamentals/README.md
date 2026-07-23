# 05 — LangChain Fundamentals (with Anthropic Claude)

Hands-on LangChain lab migrated from OpenAI to **Anthropic Claude**. The
generation model is Claude everywhere; notebooks 04 and 05 build their vector
index with a **local, on-device embedder** (see the note below). No OpenAI key
is needed.

## Notebooks

| # | Notebook | Topic |
|---|----------|-------|
| 01 | `01-model-prompts-parsers.ipynb` | Models, prompts, and output parsers. Direct Anthropic SDK call + LangChain `ChatAnthropic`, prompt templates, `StructuredOutputParser`. |
| 02 | `02-memory.ipynb` | Conversation memory: buffer, window, token-buffer, and summary memory. |
| 03 | `03-chain.ipynb` | Chains: `LLMChain`, `SimpleSequentialChain`/`SequentialChain`, and a router chain (`MultiPromptChain`). |
| 04 | `04-QnA.ipynb` | Q&A over a product-catalog CSV using embeddings + `VectorstoreIndexCreator` / `DocArrayInMemorySearch` and `RetrievalQA`. |
| 05 | `05-Evaluation.ipynb` | Evaluating a Q&A app: example generation (`QAGenerateChain`) and LLM-assisted grading (`QAEvalChain`). |
| 06 | `06-functional_conversation-student.ipynb` | A tool-calling agent (weather + Wikipedia tools) built with `ChatAnthropic.bind_tools(...)`, wrapped in an `AgentExecutor` + Panel chatbot UI. |

## Setup

```bash
python -m venv myenv
source myenv/bin/activate
pip install -r requirements.txt

cp .env.example .env
# edit .env and fill in your keys
```

### API keys

- **`ANTHROPIC_API_KEY`** — required for all notebooks (the Claude LLM). This is
  the **only** key needed.
- **Embeddings run on-device.** Notebooks 04 and 05 build their vector index with
  a local HuggingFace embedder (`sentence-transformers/all-MiniLM-L6-v2` via
  `HuggingFaceEmbeddings`). The model downloads once from the HuggingFace Hub and
  then runs locally — no OpenAI key and no per-call embedding cost.

## Model and temperature

- Default generation model: **`claude-haiku-4-5`**. Override with the
  `LLM_MODEL` environment variable, e.g. `LLM_MODEL=claude-opus-4-8`.
- Each `ChatAnthropic` is constructed with `max_tokens=2048` (Anthropic requires
  an explicit `max_tokens`).
- **Temperature note:** the lessons set `temperature=0.0` (and `0.9` in one chain
  cell). Temperature **works on Claude Haiku 4.5**, so the default model runs as
  written. It is **removed on Opus 4.7+ and Sonnet 5** — passing `temperature`
  there returns a `400` error. If you set `LLM_MODEL` to `claude-opus-4-8` (or a
  Sonnet 5 / Opus 4.7 model), delete the `temperature=...` argument from the
  `ChatAnthropic(...)` calls first.

## Credit

Inspired by the [LangChain short courses on DeepLearning.AI](https://learn.deeplearning.ai/langchain/).
