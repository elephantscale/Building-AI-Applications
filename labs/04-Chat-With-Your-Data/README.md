# Chat With Your Data (LangChain RAG)

A hands-on lab for the **Building AI Applications** course. You build a
Retrieval-Augmented Generation (RAG) pipeline over your own documents:
load → split → embed into Chroma → retrieve → answer with a chat model,
then add memory for a multi-turn conversational chatbot.

This lab uses **Claude (Anthropic)** as the generation model and **OpenAI
embeddings** for the vector store, so it requires **both** an
`ANTHROPIC_API_KEY` and an `OPENAI_API_KEY`.

> Adapted from the DeepLearning.AI short course
> [*LangChain: Chat with Your Data*](https://www.deeplearning.ai/short-courses/langchain-chat-with-your-data/),
> migrated from OpenAI chat models to Anthropic Claude.

## Notebooks

| Notebook | Topic | Provider(s) used |
| --- | --- | --- |
| `Lesson1_Document_Loading.ipynb` | Loading PDFs, YouTube transcripts, URLs, Notion | — (loaders only) |
| `Lesson2_Document_Splitting.ipynb` | Text/character/token splitters | — (splitters only) |
| `Lesson3_VectorStores_And_Embeddings.ipynb` | Embeddings + Chroma vector store | OpenAI embeddings |
| `Lesson4_Retrieval.ipynb` | Similarity / MMR / self-query retrieval | OpenAI embeddings |
| `Lesson5_Question_Answer.ipynb` | `RetrievalQA` chain | **Claude** (gen) + OpenAI (embeddings) |
| `Lesson6_Chat.ipynb` | `ConversationalRetrievalChain` + memory + Panel chatbot | **Claude** (gen) + OpenAI (embeddings) |

## Setup

1. Create and activate a virtual environment (Python 3.10+).
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Copy `.env.example` to `.env` and fill in your keys:
   ```bash
   cp .env.example .env
   # edit .env — set ANTHROPIC_API_KEY and OPENAI_API_KEY
   ```
4. Launch Jupyter and run the notebooks in order:
   ```bash
   jupyter notebook
   ```

Lessons 3–4 build the Chroma store under `docs/chroma/` (regenerable; not
shipped with this lab). Run Lesson 3 before Lessons 5–6 so the store exists.

## Model note

- The generation model defaults to **`claude-haiku-4-5`**. Override it with the
  `LLM_MODEL` environment variable (e.g. `LLM_MODEL=claude-opus-4-8`).
- The chains construct the model as
  `ChatAnthropic(model=os.getenv("LLM_MODEL", "claude-haiku-4-5"), max_tokens=2048)`.
- **Temperature:** the original OpenAI code passed `temperature=0`. That
  parameter is intentionally omitted here. `temperature` still works on
  Haiku 4.5, but **returns a 400 error on Opus 4.7+ and Sonnet 5**, so leaving
  it off keeps the lab working across every current Claude model.

## Why two providers?

Claude has no first-party embeddings endpoint, so the vector store keeps using
OpenAI's `text-embedding-3-small` (`OpenAIEmbeddings`). Only the *generation*
step was moved to Claude. That is why both API keys are required.
