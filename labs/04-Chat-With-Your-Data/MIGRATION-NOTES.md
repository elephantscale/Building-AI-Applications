# Migration Notes — OpenAI → Anthropic Claude

## Update — embeddings moved to a local on-device model

Embeddings were switched from OpenAI (`OpenAIEmbeddings`,
`text-embedding-3-small`) to a **local HuggingFace embedder**
(`HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")`
from `langchain-huggingface`) in Lessons 3, 4, 5, and 6. This drops the OpenAI
dependency entirely: the `import openai` / `openai.api_key = ...` bootstrap cells
were removed, `langchain-openai` and `openai` were removed from
`requirements.txt` (replaced by `langchain-huggingface` + `sentence-transformers`),
and `OPENAI_API_KEY` was removed from `.env.example`. The vector stores (Chroma,
`DocArrayInMemorySearch`) and all other code are unchanged. **The lab now needs
only `ANTHROPIC_API_KEY`.** The "What stayed on OpenAI" section below is
historical and no longer applies.

---

Source: `building-ai-applications-labs/Chat-with-your-own-data-Langchain/`
This lab is a RAG pipeline (load → split → embed to Chroma → RetrievalQA →
ConversationalRetrievalChain with memory). Only the **generation LLM** was
migrated to Claude; embeddings, loaders, splitters, and the vector store are
unchanged.

## What changed

### Generation LLM: `ChatOpenAI` → `ChatAnthropic`
Everywhere the OpenAI chat model drove generation, it was replaced with:

```python
from langchain_anthropic import ChatAnthropic
llm = ChatAnthropic(model=os.getenv("LLM_MODEL", "claude-haiku-4-5"), max_tokens=2048)
```

Cells touched:

- **`Lesson5_Question_Answer.ipynb`**
  - Cell `5141fd1faaa30180`: `ChatOpenAI(model_name=llm_name, temperature=0)`
    → `ChatAnthropic(...)`. This `llm` feeds every `RetrievalQA.from_chain_type`
    call in the notebook (default, prompt-templated, `map_reduce`, `refine`).
- **`Lesson6_Chat.ipynb`**
  - Cell `b08cc64374443f9e`: `ChatOpenAI(model=llm_name, temperature=0)` →
    `ChatAnthropic(...)` (used by `RetrievalQA` and `ConversationalRetrievalChain`).
  - Cell `fd89dc1548944bfb`: import `from langchain.chat_models import ChatOpenAI`
    → `from langchain_anthropic import ChatAnthropic`.
  - Cell `527816ab3207a036` (`load_db`): the `ConversationalRetrievalChain.from_llm`
    LLM `ChatOpenAI(model_name=llm_name, temperature=0)` → `ChatAnthropic(...)`.
    Powers the Panel chatbot in this lesson.

### `temperature` dropped
The original code used `temperature=0`. It is intentionally **not** passed to
`ChatAnthropic`. `temperature` works on Haiku 4.5 but **400s on Opus 4.7+ and
Sonnet 5**, so omitting it keeps the lab model-agnostic.

### `max_tokens=2048`
Added an explicit output cap (LangChain's `ChatAnthropic` requires/benefits
from an explicit `max_tokens`; the OpenAI wrapper defaulted it).

## What stayed on OpenAI (and why)

- **Embeddings — `OpenAIEmbeddings` (`text-embedding-3-small`)**: kept in
  Lessons 3, 4, 5, and 6 (Chroma store + `DocArrayInMemorySearch` in
  `load_db`). Anthropic has no first-party embeddings endpoint, so the vector
  store must use another provider. **This lab therefore requires BOTH
  `ANTHROPIC_API_KEY` and `OPENAI_API_KEY`.**

## What was NOT touched

- Document loaders (`PyPDFLoader`, YouTube/Notion/URL loaders) — Lessons 1–2.
- Text splitters (`RecursiveCharacterTextSplitter`, etc.) — Lesson 2.
- Chroma / `DocArrayInMemorySearch` vector stores and retrievers.
- Prompt templates (`QA_CHAIN_PROMPT`), memory (`ConversationBufferMemory`),
  and all chain wiring / Panel UI code.
- The `import openai` + `openai.api_key = ...` bootstrap cells (harmless; the
  OpenAI key is still needed for embeddings).

## Dead-code note

The `llm_name` date-based cells (Lesson 5 `f14948cb92dd6a51`, Lesson 6
`3182f43001edf7c0`) still compute an OpenAI model string. They are now **unused**
(the Claude model comes from `LLM_MODEL`) but were left in place to minimize
churn to logic cells. They can be deleted safely.

## Supporting files added

- `requirements.txt` — added `anthropic`, `langchain-anthropic`; kept
  `langchain-openai` / `openai` for embeddings.
- `.env.example` — `ANTHROPIC_API_KEY` + `OPENAI_API_KEY` (+ optional
  `LLM_MODEL`, LangSmith vars).
- `README.md` — notebook table, setup, model/temperature note, DeepLearning.AI
  credit.

## Excluded from copy

`myenv/`, `Transcription/`, `.ipynb_checkpoints/`, `.virtual_documents/`,
`__pycache__/`, and `docs/chroma/` (64 MB, regenerable by running Lesson 3).
