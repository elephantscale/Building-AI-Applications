# Module 2 — AI with Enterprise Data (RAG)

Elephant Scale

---

## Module 2 Agenda

- Why the model doesn't know *your* data
- Embeddings and semantic similarity
- Keyword vs. dense retrieval, and reranking
- **Lab 03 — Semantic Search**
- Retrieval-Augmented Generation (RAG): retrieve → augment → generate
- Document loading, chunking, and the vector-database landscape
- Conversational RAG with memory
- **Lab 04 — RAG: Chat With Your Data**
- LangChain fundamentals: models, prompts, parsers, memory, chains, evaluation
- **Lab 05 — LangChain Fundamentals**

---

## Where We Are

Yesterday you learned to **talk to the model** — prompts, the messages API, structured
output, streaming. That model is fluent and capable, but it has one glaring gap: it knows
only what it was trained on. It has never seen your contracts, your wiki, your tickets, or
last week's release notes.

Today is about **closing that gap**. We give the model access to your organization's
knowledge — safely, cheaply, and without retraining anything.

> The whole day builds to one pattern: **RAG** — Retrieval-Augmented Generation. Everything
> before it (embeddings, retrieval, reranking) is a piece of that machine.

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
Generation**. Next we assemble those pieces into a reusable architecture and point it at
*your own documents*: PDFs, web pages, wikis.

> Quick debrief: on which query did semantic search clearly beat keyword search? And where
> did reranking change which document came out on top?

---

# Retrieval-Augmented Generation (RAG)

---

## The RAG Architecture

RAG has two phases. **Indexing** happens once, ahead of time. **Querying** happens on every
question. The pattern is always: **retrieve → augment → generate.**

```
  INDEXING (offline)                     QUERYING (per request)
  ┌────────────┐                         ┌──────────────┐
  │ documents  │                         │ user question│
  └─────┬──────┘                         └──────┬───────┘
        │ load                                  │ embed
        ▼                                        ▼
  ┌────────────┐    chunk    ┌──────────┐  retrieve  ┌──────────────┐
  │  raw text  │ ─────────►  │  chunks  │ ◄───────── │ vector store │
  └────────────┘             └────┬─────┘            └──────────────┘
                             embed│                          │ top-k chunks
                                  ▼                          ▼
                          ┌──────────────┐        AUGMENT: question + chunks
                          │ vector store │                  │
                          └──────────────┘                  ▼
                                                    GENERATE: the model
                                                    writes a grounded answer
```

> Retrieve the relevant chunks, **augment** the prompt with them, **generate** the answer.
> Master this diagram and you understand every RAG system you'll ever meet.

---

## Step 1 — Document Loading

Before you can search knowledge, you have to **load** it. Enterprise knowledge lives in many
formats, and a **loader** turns each into plain text plus metadata (source, page, URL).

- PDFs, Word docs, HTML pages, Markdown, Notion exports, YouTube transcripts, databases.
- Metadata matters — it's how you later **cite** the source and **filter** retrieval.

```python
from langchain_community.document_loaders import PyPDFLoader

pages = PyPDFLoader("docs/handbook.pdf").load()
print(pages[0].page_content[:200])
print(pages[0].metadata)     # {'source': 'docs/handbook.pdf', 'page': 0}
```

> Garbage in, garbage out. Clean, well-attributed loading is the unglamorous foundation of a
> RAG system that actually cites its sources.

---

## Step 2 — Chunking

Whole documents are too big to embed or to stuff into a prompt. **Splitting** breaks them
into chunks small enough to retrieve precisely but large enough to stay meaningful.

- **Chunk size** — too big wastes context and blurs meaning; too small loses the surrounding
  thought. A few hundred tokens is a common starting point.
- **Overlap** — repeat a little text between adjacent chunks so an idea split across a
  boundary isn't lost.
- Split on natural boundaries (paragraphs, sentences) when you can.

```python
from langchain.text_splitter import RecursiveCharacterTextSplitter

splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=150)
chunks = splitter.split_documents(pages)
```

> Chunking is where RAG quality is quietly won or lost. If retrieval feels "off," the chunk
> size is the first knob to turn.

---

## Step 3 — Embed into a Vector Store

Each chunk is embedded and stored in a **vector database** — an index built for fast
nearest-neighbor search over embeddings. The labs use **Chroma** with an embedding model.

```python
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma

embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
vectordb = Chroma.from_documents(
    documents=chunks,
    embedding=embeddings,
    persist_directory="docs/chroma/",
)
```

- Embed once, store, reuse across every future query.
- Update your knowledge by **re-indexing** changed files — no retraining.

> Note: the generation model is Claude, but embeddings run on a separate embedding model —
> most LLM providers keep those as distinct endpoints. Two providers, one pipeline.

---

## Step 4 — Retrieval Strategies

A **retriever** wraps the vector store and answers "give me the k chunks most relevant to
this query." How it picks matters:

- **Similarity** — the top-k nearest vectors. Simple and the default.
- **MMR (Maximal Marginal Relevance)** — balances relevance with **diversity**, so you don't
  get five near-duplicate chunks saying the same thing.
- **Metadata filtering / self-query** — restrict to a source, date, or section before ranking.

```python
retriever = vectordb.as_retriever(search_type="mmr", search_kwargs={"k": 4})
docs = retriever.get_relevant_documents("What is the refund policy?")
```

> `k` is a cost/quality dial: more chunks give the model more to work with, but cost more
> tokens and can bury the key fact. Tune it.

---

## Step 5 — The QA Chain

Now assemble retrieve → augment → generate into one call. A **QA chain** takes a question,
retrieves chunks, builds the augmented prompt, and asks the model for a grounded answer.

```python
from langchain_anthropic import ChatAnthropic
from langchain.chains import RetrievalQA

llm = ChatAnthropic(model=os.getenv("LLM_MODEL", "claude-haiku-4-5"), max_tokens=2048)

qa = RetrievalQA.from_chain_type(llm=llm, retriever=retriever,
                                 return_source_documents=True)
result = qa.invoke({"query": "How many vacation days do new hires get?"})
print(result["result"])            # grounded answer
print(result["source_documents"])  # the chunks it used — your citations
```

- **Strategies for long context:** `stuff` (all chunks in one prompt), `map_reduce`,
  `refine` — different ways to fold many chunks into one answer.

> `return_source_documents=True` is what separates a demo from a trustworthy app: every
> answer can point back to the documents that produced it.

---

## Step 6 — Conversational RAG with Memory

Real users ask **follow-ups**: "What about part-time staff?" That question only makes sense
in context. Conversational RAG adds **memory** so the chain can rewrite a follow-up into a
standalone query before retrieving.

```python
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationalRetrievalChain

memory = ConversationBufferMemory(memory_key="chat_history", return_messages=True)
chat = ConversationalRetrievalChain.from_llm(llm=llm, retriever=retriever, memory=memory)

chat.invoke({"question": "How many vacation days do new hires get?"})
chat.invoke({"question": "What about part-time staff?"})   # resolved from history
```

- The chain **condenses** history + new question into one retrieval query.
- Memory lives in your app, not the model — same statelessness lesson as Day 1.

> This is the leap from "search box" to "assistant that remembers the conversation" — and
> it's the shape of most production RAG chatbots.

---

## The Vector Database Landscape

Chroma is perfect for learning and prototyping. In production you choose based on scale,
existing infrastructure, and ops appetite — but the **interface is the same**: store
vectors + metadata, query by nearest neighbor.

- **Chroma** — lightweight, embeddable, great for dev and small apps (our default).
- **pgvector** — vectors inside PostgreSQL; reuse the database you already run and back up.
- **OpenSearch / Elasticsearch** — mature search stack; strong **hybrid** (keyword + vector).
- **Pinecone** — fully managed, serverless, scales to billions of vectors.
- **Weaviate** — open-source, built-in vectorization and hybrid search.

> Don't agonize over this early. The RAG *pattern* is portable — swapping the vector store is
> usually a few lines. Start with Chroma; graduate when scale demands it.

---

## Lab 04 — RAG: Chat With Your Data

**Stop here and run the lab now.** You'll build an end-to-end RAG app over real documents —
load, split, embed to Chroma, retrieve, answer, and finally *chat* with your data.

You will:
1. **Load** documents (PDF, web, and other sources) into a common format
2. **Split** them into overlapping chunks with a recursive splitter
3. Embed the chunks into a **Chroma** vector store and inspect similarity search
4. Compare **retrieval strategies** — similarity vs. MMR vs. metadata-filtered
5. Build a **`RetrievalQA`** chain that answers grounded in retrieved context
6. Add memory with **`ConversationalRetrievalChain`** and a chatbot UI for multi-turn Q&A

Environment: Jupyter + LangChain + Chroma + embedding & AI APIs · fast model tier · **75–90 minutes**

> Two keys today: one for generation (the AI API) and one for the embedding model — the
> vector store and the LLM are different services working together.

---

## Part 2 — Frameworks & LangChain (after the lab)

Welcome back. You now own a working RAG assistant that answers from your own documents and
remembers the conversation. Notice how much of it was **LangChain** — loaders, splitters,
vector stores, retrievers, chains, memory — all snapping together.

That's the point of a framework: standard building blocks with a common interface. Let's
step back and learn those blocks properly, so you can compose them for tasks beyond RAG.

> Quick debrief: where did chunk size or `k` change your answers? Did MMR reduce repetitive
> retrieved chunks? Where did the model still miss, and why?

---

# LangChain Fundamentals

---

## Why a Framework?

You *can* build everything with raw API calls — you did on Day 1. A framework like
**LangChain** earns its place when apps get complex:

- **Common interface** — swap the model, the vector store, or the embedding provider by
  changing a line, not rewriting the app.
- **Building blocks** — loaders, splitters, retrievers, memory, parsers, chains, agents —
  already built and composable.
- **Chains** — wire multiple steps (and multiple model calls) into one reusable pipeline.

The labs use **`ChatAnthropic`** as the model everywhere and **`OpenAIEmbeddings`** for the
vector index — the framework hides the differences behind one API.

> A framework is scaffolding, not magic. Everything it does, you could do by hand — it just
> saves you from rebuilding the same plumbing on every project.

---

## Models, Prompts & Parsers

Three primitives you'll use constantly:

- **Model** — the LLM wrapped in a uniform interface.
- **Prompt template** — a reusable prompt with `{variables}` filled in per call.
- **Output parser** — turns the model's text into structured data your code can use.

```python
from langchain_anthropic import ChatAnthropic
from langchain.prompts import ChatPromptTemplate

chat = ChatAnthropic(model=os.getenv("LLM_MODEL", "claude-haiku-4-5"), max_tokens=2048)

prompt = ChatPromptTemplate.from_template(
    "Extract the sentiment and product from this review as JSON:\n{review}")
response = chat.invoke(prompt.format_messages(review=text))
```

- Pair a template with a **`StructuredOutputParser`** to get reliable, typed output — the
  framework version of Day 1's structured-output lesson.

> Prompt templates turn ad-hoc prompt strings into reusable, testable components. This is
> prompt engineering, version-controlled.

---

## Memory Types

Conversation memory is what makes a chatbot feel continuous. LangChain offers several
strategies, trading completeness against token cost:

- **Buffer** — keep the full transcript. Simple; grows without bound.
- **Window** — keep only the last *k* turns. Bounded, but forgets older context.
- **Token buffer** — keep as many recent turns as fit in a token budget.
- **Summary** — the model **summarizes** older turns to compress long histories.

```python
from langchain.memory import ConversationBufferMemory

memory = ConversationBufferMemory()
memory.save_context({"input": "Hi!"}, {"output": "Hello! How can I help?"})
memory.load_memory_variables({})
```

> Memory is a cost/fidelity trade-off. Long conversations force a choice: pay for the full
> transcript, or summarize and lose a little detail. Summary memory even uses the LLM itself.

---

## Chains

A **chain** links steps into a pipeline — the output of one feeds the next. This is how you
build multi-step logic instead of one giant prompt.

- **`LLMChain`** — a prompt + model as one reusable unit.
- **`SequentialChain`** — run steps in order (translate → summarize → extract).
- **Router chain** (`MultiPromptChain`) — inspect the input and **route** it to the right
  specialized sub-chain (e.g. a math prompt vs. a history prompt).

```python
from langchain.chains import SimpleSequentialChain

overall = SimpleSequentialChain(chains=[first_chain, second_chain])
overall.run("A cozy wool sweater for winter hiking")
```

> Chains are composition for LLM apps: small, testable steps you can reorder and reuse —
> exactly the direction we head tomorrow with agents.

---

## Evaluation

How do you know your RAG or QA app is any good? You **evaluate** it — and at scale, you let
a model help. Two moves from the labs:

- **Generate test examples** — a chain reads your documents and writes question/answer pairs
  automatically (`QAGenerateChain`).
- **LLM-assisted grading** — a model compares each predicted answer to the expected one and
  judges correctness (`QAEvalChain`), catching right answers that are worded differently.

```python
from langchain.evaluation.qa import QAEvalChain

eval_chain = QAEvalChain.from_llm(llm)
graded = eval_chain.evaluate(examples, predictions)
```

- Exact-string matching is too brittle for free-form text; an **LLM judge** understands
  paraphrase. (We'll return to LLM-as-judge — and its risks — on Day 5.)

> If you can't measure it, you can't improve it. Automated evaluation is what turns "it seems
> fine" into a number you can track as you change prompts, chunking, and models.

---

## Lab 05 — LangChain Fundamentals

**Stop here and run the lab now.** You'll work through LangChain's core building blocks —
the same pieces that powered your RAG app — on a real product-catalog dataset.

You will:
1. Use **models, prompt templates, and output parsers** to get structured results
2. Add **memory** and compare buffer, window, token-buffer, and summary types
3. Build **chains** — `LLMChain`, sequential chains, and a router chain
4. Do **Q&A over a product-catalog CSV** with embeddings + a vector index
5. **Evaluate** the Q&A app with generated examples and LLM-assisted grading
6. Assemble a small tool-using conversational agent — a preview of Day 3

Environment: Jupyter + LangChain (`ChatAnthropic`) + embeddings · fast model tier · **60–75 minutes**

> Notebooks 04–05 need both keys — `ChatAnthropic` for generation, `OpenAIEmbeddings` for the
> index. The framework makes mixing providers a one-liner.

---

## Module 2 Summary

- The model doesn't know your data — the cheap, updatable fix is **retrieval**, not retraining.
- **Embeddings** turn text into vectors so similarity of *meaning* becomes distance in space.
- Retrieval is a pipeline: **keyword → dense retrieval (ANN) → rerank → grounded generation.**
- **RAG** = retrieve → augment → generate: load, chunk, embed to a vector store, retrieve
  the relevant chunks, and have the model answer grounded in them — with citations.
- Add **memory** to turn RAG into a real conversational assistant.
- **LangChain** supplies the building blocks — models, prompts, parsers, memory, chains,
  evaluation — behind one interface, so providers and stores are swappable.

---

## What's Next

**Day 3 — AI Agents, Tools & Workflows**

So far the model only *reads* and *writes* text. Tomorrow it starts to **act**:

- Turning plain functions into **tools** the model can call
- Tool use / function calling, routing, and agent executors
- Building **agentic** workflows that plan, reason, and self-correct
- Agents over structured data (CSV and SQL)

> Today you taught the model what your organization *knows*. Next you'll give it the ability
> to *do* things — safely.

---
