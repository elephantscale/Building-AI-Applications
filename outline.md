# Building AI Applications
*From your first prompt to a secured, agentic, production AI system — built on Claude.*

© Elephant Scale

July 14, 2026

## Course Description

Artificial Intelligence is transforming how organizations build software, automate
workflows, analyze documents, and interact with enterprise data. Modern AI systems go
far beyond simple chatbots — organizations now build AI-enabled applications that
understand their documents, assist their engineers, automate repetitive work, securely
interact with internal systems, and reason over operational data.

In this course, developers learn to design, build, secure, and deploy modern AI
applications using current enterprise practices. The course is **hands-on and
progressive**: students build steadily more capable systems across five days —
prompting, retrieval-augmented generation (RAG), tool-using agents, serverless
deployment, and finally a full security-hardening pass over everything they built.

The course standardizes on **Anthropic Claude** (Claude Opus 4.8 for reasoning, agents,
and RAG; Claude Haiku 4.5 for high-volume classroom exercises), with **Claude on Amazon
Bedrock** for the serverless/AWS material. Concepts transfer to any modern model
provider — the emphasis is on the patterns, not the vendor.

The final day — **Securing AI Applications** — is what sets this course apart. Most AI
courses teach you to build; this one also teaches you to defend what you built: prompt
injection, RAG poisoning, unsafe tool execution, guardrails, and least-privilege agent
design, all applied to the students' own code from days 1–4.

---

## Why This Course Matters

Every developer is becoming an AI developer. But shipping an AI feature is not the same
as shipping a *safe* one. Teams that only learn to build produce systems that:

- leak data through prompt injection
- execute unsafe tool calls on behalf of an attacker
- return confidently wrong answers with no validation
- grant agents far more authority than the task requires
- expose secrets and credentials to the model

This course closes that gap. Students leave able to **build** modern AI applications and
to **harden** them — the two halves of actually shipping AI to production.

---

## Audience

- Developers and software engineers
- Architects and technical leads
- Data scientists moving into applied AI
- DevOps / platform engineers supporting AI workloads
- Technical managers who want a working understanding
- Government and enterprise technical teams

---

## Skill Level

Intermediate. No prior AI development experience required.

---

## Prerequisites

- General software development experience
- Familiarity with APIs is helpful
- Basic Python exposure is beneficial
- General understanding of cloud concepts is helpful

---

## Duration

5 Days

---

## Learning Outcomes

By the end of the course, students can:

- Explain how AI applications differ from conventional software
- Write effective prompts and structured-output prompts
- Call the Claude API programmatically and handle responses safely
- Build a semantic-search and RAG system over private documents
- Turn plain functions into model tools and build tool-using agents
- Query structured data (CSV / SQL) with an AI agent
- Deploy serverless AI pipelines on AWS with Claude on Bedrock
- Apply guardrails and knowledge bases to production agents
- Detect and defend against prompt injection and RAG poisoning
- Design least-privilege, human-in-the-loop agent architectures
- Harden an end-to-end AI application for production

---

## Format

- Lectures and hands-on labs
- Approximately 50% lecture / 50% labs

## Lab Environment

- Cloud-hosted lab environment provided
- No local installation required
- A shared Anthropic API key (Claude) is provided for class exercises;
  AWS accounts are provided for the Bedrock labs

## Students Will Need

- Modern laptop
- Chrome browser
- Internet access without restrictive VPN / firewall limitations

---

# Day 1 — Foundations & Prompt Engineering

## Module 1 — Introduction to Modern AI Applications
*Lab: none — orientation & discussion*

- Course orientation and teaching philosophy ("learn by doing")
- Evolution of AI systems; foundation models and LLMs
- Reasoning models; hosted vs. local AI
- Why building with AI is now cheap (falling token prices)
- Enterprise AI use cases, capabilities, and limitations
- Hallucinations and reliability concerns
- The Claude model family (Opus 4.8, Sonnet 5, Haiku 4.5) and how to choose

## Module 2 — Prompt & Context Engineering
*Lab: Lab 01 — `01-Prompt-Engineering`*

- Principle 1: write clear, specific instructions (delimiters, structured output,
  condition checks, few-shot)
- Principle 2: give the model time to reason (multi-step, self-verification)
- Iterative prompt refinement
- Summarizing, inferring (sentiment / topics), transforming, expanding
- The chat format, system prompts, and multi-turn conversations
- Model limitations and hallucination mitigation

## Module 3 — Working with the Claude API
*Lab: Lab 02 — `02-Claude-API`*

- The Messages API: requests, responses, content blocks
- Token usage and cost; choosing Opus vs. Haiku
- Structured outputs and JSON generation
- Streaming responses
- Handling responses safely; basic application integration patterns

**Day 1 labs:** effective prompting exercises (guidelines → iterative → summarizing →
inferring → transforming → expanding → chatbot); building a simple Claude-powered
assistant with structured output.

---

# Day 2 — AI with Enterprise Data (RAG)

## Module 4 — Embeddings & Semantic Search
*Lab: Lab 03 — `03-Semantic-Search`*

- Keyword search and its limits
- Embeddings and semantic similarity
- Dense retrieval and approximate nearest neighbor (ANN)
- Reranking retrieved results
- Generating grounded answers from retrieved context

## Module 5 — Retrieval-Augmented Generation with LangChain
*Lab: Lab 04 — `04-Chat-With-Your-Data`*

- Document loading (PDF, web, and other sources) and chunking
- Embeddings into a vector store (Chroma)
- Retrieval strategies (similarity, MMR)
- Building a QA chain over private documents
- Conversational retrieval with memory
- Vector database landscape: Chroma, pgvector, OpenSearch, Pinecone, Weaviate

## Module 6 — LangChain Fundamentals
*Lab: Lab 05 — `05-LangChain-Fundamentals`*

- Models, prompts, and output parsers (`ChatAnthropic`)
- Memory types (buffer, summary, token)
- Chains: sequential and router chains
- QA over a product-catalog dataset
- LLM-based evaluation of outputs

**Day 2 labs:** build a semantic-search pipeline (keyword → embeddings → dense retrieval
→ rerank → grounded answer); build a "chat with your own documents" RAG app; LangChain
fundamentals over a real dataset.

---

# Day 3 — AI Agents, Tools & Workflows

## Module 7 — Functions, Tools & Agents
*Lab: Lab 06 — `06-Functions-Tools-Agents`*

- Tool use / function calling with Claude
- Turning plain Python functions into model tools
- Structured extraction and tagging with tools
- Tools and routing; agent executors
- A conversational agent with memory

## Module 8 — Building Agentic AI Systems
*Lab: Lab 07 — `07-Agentic-AI`*

- What is an agent? assistants vs. agents; degrees of autonomy
- Planning, reasoning, and reflection loops (self-correcting code generation)
- Tool-using agents (weather, file writing, research)
- Multi-agent workflows and coordination
- Human-in-the-loop patterns and agent evaluation

## Module 9 — AI Agents over Structured Data
*Lab: Lab 08 — `08-Database-Agent`*

- Natural-language querying of CSV data (pandas agent)
- SQL agents over a relational database
- Function calling against a database
- Safety: injection prevention, RBAC, read-only access

**Day 3 labs:** build a tool-calling agent; build a self-correcting / multi-agent
workflow; build a natural-language database agent over CSV and SQL.

---

# Day 4 — Production & Serverless AI on the Cloud

## Module 10 — Serverless LLM Applications on AWS
*Lab: Lab 09 — `09-Serverless-LLM-Bedrock`*

- Amazon Bedrock and Claude on Bedrock
- Generating text with foundation models via `boto3`
- A real pipeline: transcribe audio (Amazon Transcribe) → summarize (Claude)
- Enabling CloudWatch logging and observability
- Deploying the pipeline as an AWS Lambda function
- Event-driven architecture (S3 upload triggers the pipeline)

## Module 11 — Agents & Guardrails on Bedrock
*Lab: Lab 10 — `10-Agentic-On-Bedrock`*

- Creating a Bedrock agent
- Connecting the agent to a system (action groups + Lambda)
- Adding capabilities (calculation, code)
- Bedrock Guardrails: topic and content policies
- Attaching a knowledge base for grounded, autonomous answers

## Module 12 — Multimodal & Advanced Models (optional)
*Lab: optional — `11-Multimodal` (Llama 4, provider-native)*

- Multimodal reasoning: image and document understanding
- Long-context tasks (summarization, multi-document, codebase QA)
- Prompt optimization and synthetic data generation
- Note: this module uses Meta's Llama 4 and is provider-native; run it as an optional
  deep-dive or substitute Claude vision where equivalent

**Day 4 labs:** deploy a serverless summarization pipeline on AWS Lambda + Bedrock;
build a Bedrock agent with action groups, guardrails, and a knowledge base.

---

# Day 5 — Securing AI Applications *(NEW)*

*The defensive counterpart to days 1–4: students harden the systems they just built.*

## Module 13 — The AI Application Threat Model
*Lab: none — interactive threat-modeling of the students' own apps*

- How AI apps differ from normal apps (semantic vs. syntactic attacks)
- The OWASP GenAI / LLM Top 10, at a builder's altitude
- Where the risk lives: prompt, retrieval, tools, output, identity
- Mapping the days 1–4 systems to their attack surface

## Module 14 — Prompt Injection Defense
*Lab: Lab 12 — `12-Prompt-Injection`*

- Direct and indirect prompt injection
- Hidden instructions in documents, HTML, and Markdown
- Jailbreaks, role confusion, and context-override attacks
- Layered defenses: instruction/data separation, input inspection,
  the operator (system) channel, allow/deny policies
- Attack a chatbot, bypass a naïve filter, then build layered detection

## Module 15 — Securing RAG Pipelines
*Lab: Lab 13 — `13-RAG-Security`*

- The RAG attack surface: ingestion, embeddings, retrieval, generation
- Poisoned documents and indirect injection via retrieved content
- Data exfiltration and cross-document contamination
- Defenses: ingestion sanitization, provenance/trust scoring, metadata isolation,
  retrieval policies, output validation
- Case study: upload a poisoned PDF and take over the assistant — then stop it

## Module 16 — Safe Tools & Agent Execution
*Lab: Lab 14 — `14-Agent-Security`*

- Excessive agency and tool abuse
- Unsafe tool execution; SQL/command injection through agents
- Least-privilege tool design and scoped credentials
- Approval gates, human-in-the-loop, and sandboxing
- Secrets management: keep credentials out of prompts, tools, and memory
- Harden the Day 3 database agent and tool-using agent

## Module 17 — Guardrails, Validation & Responsible AI
*Lab: Lab 15 — `15-Guardrails`*

- Output validation and structured-output enforcement
- Guardrails: topic, content, and safety policies (incl. Bedrock Guardrails)
- Handling refusals and unsafe generations
- Governance, auditability, logging, and human oversight
- Cost / abuse controls (rate limiting, denial-of-wallet basics)

## Module 18 — Capstone: Harden Your AI Application
*Lab: Lab 16 — `16-Capstone`*

Students take an AI assistant (RAG + tools + agent) and defend it end to end while a
simulated attacker attempts prompt injection, retrieval poisoning, tool abuse, credential
theft, and excessive consumption. Teams build:

- input inspection and prompt-injection detection
- a sanitized, provenance-aware RAG pipeline
- least-privilege, approval-gated tools
- output guardrails and validation
- logging and abuse monitoring

---

# Labs

The labs are what make the course compelling. Students build a progressively richer AI
system across days 1–4, then spend day 5 defending it.

## Day ↔ Lab map

| Lab | Folder | Title | Day |
|---|---|---|---|
| Lab 01 | `01-Prompt-Engineering` | Effective prompting, end to end | Day 1 |
| Lab 02 | `02-Claude-API` | Build a Claude-powered assistant | Day 1 |
| Lab 03 | `03-Semantic-Search` | Semantic search & retrieval | Day 2 |
| Lab 04 | `04-Chat-With-Your-Data` | RAG over your own documents | Day 2 |
| Lab 05 | `05-LangChain-Fundamentals` | LangChain building blocks | Day 2 |
| Lab 06 | `06-Functions-Tools-Agents` | Tools & function calling | Day 3 |
| Lab 07 | `07-Agentic-AI` | Build an agentic workflow | Day 3 |
| Lab 08 | `08-Database-Agent` | Natural-language database agent | Day 3 |
| Lab 09 | `09-Serverless-LLM-Bedrock` | Serverless AI on AWS Lambda | Day 4 |
| Lab 10 | `10-Agentic-On-Bedrock` | Bedrock agent + guardrails + KB | Day 4 |
| Lab 11 | `11-Multimodal` | Multimodal & long context *(optional)* | Day 4 |
| Lab 12 | `12-Prompt-Injection` | Attack & defend a chatbot | Day 5 |
| Lab 13 | `13-RAG-Security` | Poison and secure a RAG pipeline | Day 5 |
| Lab 14 | `14-Agent-Security` | Secure a tool-using agent | Day 5 |
| Lab 15 | `15-Guardrails` | Guardrails & output validation | Day 5 |
| Lab 16 | `16-Capstone` | Harden your AI application | Day 5 |

Labs 01–10 are adapted from the existing course materials and **standardized on Claude**
(the two Bedrock labs already run on Claude via Amazon Bedrock). Lab 11 is optional and
provider-native (Llama 4). Labs 12–16 are **new**, built for the security day.

---

# Technology Stack

- **Primary model provider:** Anthropic Claude
  - Claude Opus 4.8 (`claude-opus-4-8`) — agents, RAG, tool use, reasoning
  - Claude Haiku 4.5 (`claude-haiku-4-5`) — high-volume classroom exercises
  - Claude on Amazon Bedrock — serverless / AWS days
- **Frameworks:** the Anthropic Python SDK; LangChain (`ChatAnthropic`)
- **Retrieval:** Chroma (primary); survey of pgvector, OpenSearch, Pinecone, Weaviate
- **Cloud:** AWS (Bedrock, Lambda, S3, Transcribe, CloudWatch, Guardrails)
- **Optional / provider-native:** Meta Llama 4 (multimodal module only)

---

# Strategic Positioning

This is NOT "an AI course with a security afterthought."

This IS: **every developer is now responsible for the safety of the AI systems they
ship.** Days 1–4 make students productive AI builders on the latest Claude models. Day 5
makes them the ones who can ship those systems to production without getting breached.

> Hands-on muscle to build modern AI applications on Claude — and the security skills to
> defend prompt injection, RAG poisoning, and agent abuse before they reach production.