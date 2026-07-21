# Retrieval-Augmented Generation (RAG)

Elephant Scale

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
- Memory lives in your app, not the model.

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

> Quick debrief: where did chunk size or `k` change your answers? Did MMR reduce repetitive
> retrieved chunks? Where did the model still miss, and why?
