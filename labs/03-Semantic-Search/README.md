# Lab 03 — Semantic Search (RAG)

Hands-on lab for the **Building AI Applications** course. You build a semantic
search / retrieval-augmented-generation (RAG) pipeline: keyword search, dense
retrieval, reranking, and finally grounded answer generation.

## Model note

Embeddings, reranking, and vector retrieval **stay on Cohere and Weaviate by
design** — they are the teaching subject of this lab and have no Claude
equivalent. Only the final **answer-generation** step was migrated to
**Claude** via the Anthropic Python SDK.

- Answer generation uses `client.messages.create(...)`.
- Model defaults to `claude-haiku-4-5`; override with the `LLM_MODEL`
  environment variable (e.g. `claude-opus-4-8`).

## Lessons

| Lesson | Topic | Provider(s) |
| ------ | ----- | ----------- |
| Lesson1_Keyword_Search   | Keyword search with Weaviate / BM25         | Weaviate |
| Lesson2_Embeddings       | Embeddings + UMAP visualization             | Cohere embeddings |
| Lesson3_Dense_Retrieval  | Dense retrieval with an Annoy index         | Cohere embeddings + Annoy |
| Lesson4_ReRank           | Reranking retrieved results                 | Cohere Rerank |
| Lesson5_Generating_Answers | Grounded answer generation (RAG)          | Cohere/Annoy retrieval **+ Claude generation** |

## Setup

1. Create and activate a virtual environment.
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Copy `.env.example` to `.env` and fill in your keys:
   - `ANTHROPIC_API_KEY` — for the Claude answer-generation step
   - `COHERE_API_KEY` — for embeddings and rerank
   - `WEAVIATE_API_URL` / `WEAVIATE_API_KEY` — for vector search
   - Optional: `LLM_MODEL` (default `claude-haiku-4-5`), `COHERE_RERANK_MODEL`
4. Launch Jupyter and open the lesson notebooks in order.

## Credit

Based on the DeepLearning.AI short course **"Large Language Models with
Semantic Search."** The answer-generation step has been adapted to use Claude
for this course.
