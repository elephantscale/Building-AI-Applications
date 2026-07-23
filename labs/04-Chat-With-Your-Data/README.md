# Chat With Your Data (LangChain RAG)

A hands-on lab for the **Building AI Applications** course. You build a
Retrieval-Augmented Generation (RAG) pipeline over your own documents:
load → split → embed into Chroma → retrieve → answer with a chat model,
then add memory for a multi-turn conversational chatbot.

This lab uses **Claude (Anthropic)** as the generation model and a **local,
on-device embedder** (`sentence-transformers/all-MiniLM-L6-v2` via
`langchain-huggingface`) for the vector store. Embeddings run on your machine
with no API key, so the lab requires **only** an `ANTHROPIC_API_KEY`.

> Adapted from the DeepLearning.AI short course
> [*LangChain: Chat with Your Data*](https://www.deeplearning.ai/short-courses/langchain-chat-with-your-data/),
> migrated from OpenAI chat models to Anthropic Claude.

## Notebooks

| Notebook | Topic | Provider(s) used |
| --- | --- | --- |
| `Lesson1_Document_Loading.ipynb` | Loading PDFs, YouTube transcripts, URLs, Notion | — (loaders only) |
| `Lesson2_Document_Splitting.ipynb` | Text/character/token splitters | — (splitters only) |
| `Lesson3_VectorStores_And_Embeddings.ipynb` | Embeddings + Chroma vector store | local embeddings |
| `Lesson4_Retrieval.ipynb` | Similarity / MMR / self-query retrieval | local embeddings |
| `Lesson5_Question_Answer.ipynb` | `RetrievalQA` chain | **Claude** (gen) + local embeddings |
| `Lesson6_Chat.ipynb` | `ConversationalRetrievalChain` + memory + Panel chatbot | **Claude** (gen) + local embeddings |

## Setup

1. Create and activate a virtual environment (Python 3.10+).
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Keys come from the shared `labs/.env` (copy `labs/.env.example` → `labs/.env`
   once, in the repo's `labs/` directory). No per-lab `.env` needed — every lab
   reads it automatically. This lab needs only `ANTHROPIC_API_KEY` (no OpenAI key —
   embeddings run on a local on-device embedder).
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

## Embeddings run on-device

Claude has no first-party embeddings endpoint. Rather than depend on a second
provider, the vector store uses a **local** HuggingFace embedder
(`sentence-transformers/all-MiniLM-L6-v2` via `HuggingFaceEmbeddings`). The model
downloads once from the HuggingFace Hub and then runs on your machine — no API
key and no per-call cost for embeddings. Only the *generation* step calls a
hosted API (Claude), so `ANTHROPIC_API_KEY` is the only key required.
