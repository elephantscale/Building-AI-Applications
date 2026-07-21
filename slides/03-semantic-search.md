# Semantic Search & Retrieval

Elephant Scale

---

# Why the Model Doesn't Know Your Data

---

## The Knowledge Gap

A foundation model is trained once, on public data, up to a **cutoff date**. That gives it
three permanent blind spots:

- **Private data** — your documents were never in the training set.
- **Fresh data** — anything after the cutoff simply doesn't exist to the model.
- **Specific facts** — asked about your data, the model does what it always does: predicts
  plausible text. That's where **hallucinations** come from.

The fix is not to make the model *smarter*. It's to **put the right facts in front of it**
at the moment you ask the question.

> The model is a brilliant reasoner with amnesia about your world. Our job is to hand it the
> right page from your files, right before it answers.

---

## Three Ways to Give the Model Knowledge

- **Fine-tuning** — retrain the model on your data. Powerful, but expensive, slow to update,
  and it bakes facts into weights (hard to change, hard to cite).
- **Long context** — paste everything into the prompt. Simple, but limited by the context
  window, costly per call, and wasteful when you only need three paragraphs out of a
  thousand pages.
- **Retrieval (RAG)** — store your knowledge in a searchable index, fetch only the relevant
  pieces per question, and hand *those* to the model.

Retrieval wins for most enterprise use cases: **cheap to update** (re-index a file),
**cite-able** (you know which document answered), and **scalable** to millions of documents.

> This module is the retrieval path. To retrieve by *meaning*, we first need a way to turn
> meaning into math — **embeddings**.

---

# Embeddings & Semantic Search

---

## Keyword Search and Its Limits

The oldest retrieval tool is **keyword search**: match the words in the query against the
words in the documents (BM25, TF-IDF, an inverted index).

- Fast, well-understood, and great when the user knows the exact term.
- But it matches **strings, not meaning**. Search "car" and you miss "automobile."
  Search "how do I reset my password" and a doc titled "credential recovery" never surfaces.

```python
from sklearn.feature_extraction.text import CountVectorizer

vectorizer = CountVectorizer()
X = vectorizer.fit_transform(documents)
scores = (X @ vectorizer.transform(["quick fox"]).T).toarray()
```

> Keyword search asks "do these documents contain these words?" What we actually want is
> "which documents *mean* the same thing as this question?"

---

## Embeddings — Meaning as Vectors

An **embedding model** turns a piece of text into a list of numbers — a **vector** — that
captures its meaning. Texts that mean similar things land near each other in this space.

- A sentence becomes a point in a high-dimensional space (hundreds to thousands of numbers).
- "car" and "automobile" end up **close**; "car" and "banana" end up **far apart**.
- The model learned this geometry from enormous amounts of text.

```python
# An embedding model maps text -> a fixed-length vector
embedding = embed("The capital of France is Paris.")
len(embedding)   # e.g. 1024 numbers
```

> You don't read embeddings — you compute with them. The magic is that *distance between
> vectors* now approximates *difference in meaning*.

---

## Semantic Similarity

Once text is a vector, "how similar are these two texts?" becomes a math question. The
standard measure is **cosine similarity** — the angle between two vectors.

- Score near **1.0** → very similar meaning.
- Score near **0** → unrelated.

```python
from sklearn.metrics.pairwise import cosine_similarity

query_vec = embed("Find documents about journeys.")
scores = cosine_similarity([query_vec], document_vectors)
```

This is the core move of **semantic search**: embed the query, embed the documents, and rank
documents by similarity to the query — matching on **meaning**, not shared words.

> Synonyms, paraphrases, translations — all handled for free, because they land near each
> other in vector space.

---

## Dense Retrieval & ANN

**Dense retrieval** = semantic search at scale. Every document is embedded once and stored;
at query time you embed the question and find its nearest neighbors.

- Comparing against *every* vector is exact but slow for millions of documents.
- **Approximate Nearest Neighbor (ANN)** indexes (Annoy, HNSW, FAISS) trade a tiny bit of
  accuracy for **massive speed** — the engine inside every vector database.

```
                embed query
                     |
   [ query vector ]  v
        │  nearest-neighbor search (ANN index)
        ▼
   top-k most similar document chunks
```

- "Dense" (one rich meaning-vector) vs. "sparse" (keyword counts) retrieval.
- Many production systems run **both** and combine them — *hybrid search*.

> Dense retrieval is why you can search millions of documents by meaning in milliseconds.

---

## Reranking

The first retrieval pass favors **recall** — cast a wide net, grab the top 20 or 50
candidates fast. But the best answer isn't always ranked first.

A **reranker** is a second, more careful model that scores each candidate *against the
query directly* and reorders them. Slower per item, so you only run it on the shortlist.

```
retrieve top-50 (fast, ANN)  ->  rerank to top-5 (accurate)  ->  send to the model
```

- Retrieval optimizes **"find the plausible candidates."**
- Reranking optimizes **"put the truly relevant ones on top."**
- Feeding the model 5 great chunks beats feeding it 50 mediocre ones — better answers,
  fewer tokens, lower cost.

> Two-stage retrieval — cheap-and-wide, then precise-and-narrow — is the standard pattern in
> serious RAG systems.

---

## Grounded Answer Generation

Retrieval finds the facts. Now the model **writes the answer from those facts** — this is the
"generation" half of RAG. You put the retrieved text into the prompt as **context** and ask
the model to answer *using only that context*.

```python
import anthropic, os

client = anthropic.Anthropic()

def generate_given_context(query, context):
    prompt = f"Answer the question using only the context below.\n\n" \
             f"Context:\n{context}\n\nQuestion: {query}"
    message = client.messages.create(
        model=os.getenv("LLM_MODEL", "claude-haiku-4-5"),
        max_tokens=2048,
        messages=[{"role": "user", "content": prompt}],
    )
    return message.content[0].text
```

- The context **grounds** the answer in real documents — dramatically fewer hallucinations.
- Because you know which chunks you retrieved, you can **cite sources**.

> "Answer only from the context" is the single most important instruction in RAG. It turns a
> confident guesser into a grounded assistant.

---

## Lab 03 — Semantic Search

**Stop here and run the lab now.** You'll build a full search pipeline — keyword → dense
retrieval → rerank → grounded answer — and *feel* the difference between matching words and
matching meaning.

You will:
1. Run **keyword search** (BM25) over a Wikipedia subset and see where it falls short
2. Generate **embeddings** for text and visualize how meaning clusters in vector space
3. Build **dense retrieval** with an ANN index and query it by meaning
4. Add a **reranker** to reorder the retrieved candidates by true relevance
5. Wire retrieval into **grounded answer generation** — the retrieved context feeds the model
6. Compare keyword vs. semantic results on the same queries

Environment: Jupyter + embeddings/rerank APIs + AI Python SDK · fast model tier · **60–75 minutes**

> These labs run on Claude for generation, but the retrieval concepts — embeddings,
> similarity, ANN, reranking — apply to any LLM and any embedding model.

---

## Part 2 — From Search to RAG (after the lab)

Welcome back. You just built every piece of a retrieval system by hand: you embedded text,
searched by meaning, reranked, and had the model answer *only* from what you retrieved.

That last pipeline — **retrieve, then generate** — has a name: **Retrieval-Augmented
Generation**.

> Quick debrief: on which query did semantic search clearly beat keyword search? And where
> did reranking change which document came out on top?
