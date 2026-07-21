# Multimodal & Long-Context AI

Elephant Scale

---

# Multimodal & Long Context *(Optional)*

---

## Multimodal Models *(Optional)*

> **This section is optional.** It frames capabilities available across modern foundation
> models. Concepts are generic; use whichever multimodal model your platform provides.

A **multimodal model** accepts more than text — most commonly images alongside a prompt.
That unlocks a class of applications text alone can't reach.

- **Image reasoning** — describe a photo, answer questions about a chart, compare two images.
- **Grounding** — point to *where* in an image something is (locate the defect, the label, the object).
- **Document understanding** — read a scanned invoice or form and pull out structured fields, layout and all.

> The interface barely changes — you add an image block to the same messages call. The
> *capability* is what's new: the model now reasons over what it sees, not just what it reads.

---

## Long-Context Tasks *(Optional)*

> **This section is optional.** Context limits from Module 1 apply — large, but finite.

Frontier models accept very large inputs — hundreds of pages at once. That changes what a
single call can do.

- **Whole-document summarization** — a full report or transcript in one pass, no chunking.
- **Multi-document reasoning** — compare and synthesize across several sources together.
- **Codebase Q&A** — load many files and ask questions that span them.

- **Prompt optimization** — systematically refine prompts against examples instead of by hand.
- **Synthetic data generation** — have the model produce training or test data on demand.

> Long context is *not* a replacement for RAG. Retrieval scales to millions of documents
> and stays cheap; long context shines when you truly need everything in view at once.
> Knowing which to reach for is the skill.

---

## Lab 11 — Multimodal & Long Context *(Optional)*

**Stop here and run the lab now — if time allows.** This lab is **optional** and
provider-native: it explores vision and long-context capabilities that may use a different
model than the rest of the course. Treat it as a deep-dive; the concepts transfer to any
multimodal model, including Claude's vision.

You will:
1. Send an image with a prompt and have the model reason about what it sees
2. Ground a response — locate and describe specific regions of an image
3. Extract structured fields from a document (form or invoice) in one call
4. Summarize a long document in a single long-context pass
5. Ask questions that span multiple documents or files at once
6. *(If included)* try prompt optimization and synthetic data generation

Environment: Jupyter + a multimodal foundation model · **optional · 45–60 minutes**
