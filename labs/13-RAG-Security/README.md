# Lab 13 — RAG Security (Claude)

**Building AI Applications · Day 5 (Security)**

Hands-on hardening of a Retrieval-Augmented Generation pipeline. You will poison a
live RAG app with a booby-trapped PDF, take over the assistant, then rebuild the
pipeline so the same attack fails — without breaking legitimate answers.

## Notebook

`13-rag-security.ipynb`

## You will

1. Build a small **RAG pipeline** — a few trusted docs in a Chroma vector store plus
   a retrieve → augment → generate answer function backed by Claude.
2. Craft a **poisoned PDF** with hidden instructions (white text, font-size ~0) using
   `reportlab`.
3. **Extract** its text with `pypdf`, **ingest** it, and confirm the hidden line is
   embedded in the store.
4. Ask an **innocent question** and watch the assistant follow the injected instruction.
5. Add **ingestion sanitization** — strip near-invisible PDF text, HTML comments, and
   zero-width / invisible Unicode; scan the cleaned text for injection patterns and
   **quarantine** hits before they are ever embedded.
6. Assign **trust levels** to sources (`SYSTEM > INTERNAL > EXTERNAL > USER`) and
   enforce a **retrieval policy** that excludes `USER`-trust chunks from sensitive queries.
7. **Re-run the attack** and verify it is blocked while legitimate answers still work.

## Setup

```sh
python -m venv myenv
source myenv/bin/activate      # Windows: myenv\Scripts\activate
pip install -r requirements.txt

jupyter lab                    # or: jupyter notebook
```

> **Keys** come from the shared `labs/.env` (copy `labs/.env.example` → `labs/.env`
> once, in the repo's `labs/` directory). No per-lab `.env` needed — every lab reads it automatically.

**Single key.** The lab needs only an `ANTHROPIC_API_KEY`. The vector store is
**Chroma** with its built-in default embedding function (ONNX all-MiniLM), which
runs locally with no API key — the first run downloads a small (~80 MB) model.

## Model & temperature

The notebook calls Claude through a small `llm()` helper and defaults to
**`claude-haiku-4-5`** — fast and inexpensive for class use. Override the model with
`LLM_MODEL` in your `.env` (for example `claude-opus-4-8`).

No `temperature` is passed anywhere, so the notebook runs unchanged on newer Claude
models (Opus 4.7+ / Sonnet 5) that reject sampling parameters.
