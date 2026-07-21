# LangChain Fundamentals

Elephant Scale

---

## Why a Framework?

You *can* build everything with raw API calls. A framework like
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

- Pair a template with a **`StructuredOutputParser`** to get reliable, typed output.

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

> Chains are composition for LLM apps: small, testable steps you can reorder and reuse.

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
  paraphrase.

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
6. Assemble a small tool-using conversational agent

Environment: Jupyter + LangChain (`ChatAnthropic`) + embeddings · fast model tier · **60–75 minutes**

> Notebooks 04–05 need both keys — `ChatAnthropic` for generation, `OpenAIEmbeddings` for the
> index. The framework makes mixing providers a one-liner.
