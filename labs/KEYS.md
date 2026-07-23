# API Keys for the Labs

Which key each lab needs, where to get it, and how to deploy it. For a small class
(2 students + instructor = 3 machines) you provision **one set of keys** and drop it on
each machine.

## Deployment

1. In each lab folder: `cp .env.example .env`, then paste the keys into `.env`.
   (Or set them once as environment variables in the shell profile on each machine.)
2. Verify each machine: `./labs/verify-setup.sh --live` (exit 0 = ready).

## The keys

| Key | Labs | Where to get it | Cost | Notes |
|-----|------|-----------------|------|-------|
| `ANTHROPIC_API_KEY` | **all** | console.anthropic.com → API keys | Paid; ~$5 credit is plenty. Haiku 4.5 ≈ $1/$5 per 1M tokens — a whole class run costs cents. | **Required.** The model for everything. |
| AWS credentials | 09, 10 | AWS account → enable **Amazon Bedrock model access for Claude** (Bedrock console → Model access) | Pay-per-use; tiny for a class | Needs Bedrock + S3 + Transcribe + Lambda + CloudWatch permissions. |
| `TAVILY_API_KEY` | 07 | tavily.com | **Free** tier (~1,000 credits/mo) | Web research for the agent lab. |
| `COHERE_API_KEY` | 03 | dashboard.cohere.com | **Free** trial tier | Embeddings + rerank (the lab's subject). |
| Weaviate URL/key | 03 | weaviate.io → **free** Cloud sandbox | **Free** sandbox | Vector DB for lab 03. |
| Llama/Together key | 11 (optional) | together.ai or the Llama API | Free/paid | Optional multimodal lab; skip to avoid another account. |

> **Note:** labs 04 & 05 previously needed `OPENAI_API_KEY` for embeddings — they now use a
> local on-device embedder (no key). OpenAI is no longer required anywhere in the course.

## Fewest accounts possible (recommended for a 2-student class)

- ✅ **Done:** labs 04 & 05 now use the on-device embedder (`sentence-transformers/all-MiniLM-L6-v2`,
  the same path labs 06 and 12–16 use) — **`OPENAI_API_KEY` is no longer needed anywhere.**
- **Skip lab 11** (it's optional) → no Llama/Together account.

That leaves:

- **`ANTHROPIC_API_KEY`** — every core lab (01–08, 12–16)
- **AWS creds** — the Day-4 cloud labs (09, 10)
- **`TAVILY_API_KEY`** (free) — lab 07
- **`COHERE_API_KEY` + Weaviate sandbox** (both free) — lab 03

**Absolute minimum** — if you also run lab 03 as an instructor demo (or skip it), the class
needs only **`ANTHROPIC_API_KEY`** (+ AWS for the one cloud day). Everything else is free-tier
or removable.
