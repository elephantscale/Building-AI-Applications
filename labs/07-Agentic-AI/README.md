# 07 · Agentic AI

Hands-on ungraded labs for the **Agentic AI** module of the *Building AI Applications* course. These labs walk through core agentic design patterns — reflection, tool calling, evaluation, and multi-agent orchestration.

This edition has been **migrated to Anthropic Claude**. All LLM text, reasoning, vision, and tool-calling now run on Claude. See [`MIGRATION-NOTES.md`](./MIGRATION-NOTES.md) for details (including the one step that stays on OpenAI).

## Modules

| Module | Notebook | Topic | What it demonstrates |
|--------|----------|-------|----------------------|
| **M2** | `M2/ungraded_labs/M2_UGL_1/M2_UGL_1.ipynb` | Reflection loop for chart generation | An agent generates matplotlib code, executes it, visually critiques the chart, and rewrites the code (V1 → V2). |
| **M3** | `M3/ungraded_labs/M3_UGL_1/M3_UGL_1.ipynb` | Turning functions into tools | Plain Python functions (time, weather, QR code, file writing) become LLM tools via `aisuite`; automatic and manual tool-calling. |
| **M4** | `M4/ungraded_labs/M4_UGL_1/M4_UGL_1.ipynb` | Component-level evaluation | A research agent (arXiv / Tavily / Wikipedia) with a preferred-domains evaluation of its web-search step. |
| **M5** | `M5/ungraded_labs/M5_UGL_2/M5_UGL_2.ipynb` | Multi-agent market-research team | Research → image generation → copywriting → executive report, orchestrated across specialized agents. |

## Setup

1. **Create and activate a virtual environment**, then install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

2. **Configure environment variables.** Keys come from the shared `labs/.env`
   (copy `labs/.env.example` → `labs/.env` once, in the repo's `labs/` directory).
   No per-lab `.env` needed — every lab reads it automatically. The keys this lab uses:

   | Variable | Required for | Notes |
   |----------|--------------|-------|
   | `ANTHROPIC_API_KEY` | All labs | Claude — every LLM call. |
   | `TAVILY_API_KEY` | M4, M5 | Tavily web search. |
   | `OPENAI_API_KEY` | M5 only — optional | DALL·E 3 image generation only (Claude cannot generate images); not used for embeddings. |
   | `LLM_MODEL` | Optional | Overrides the Claude model everywhere. |

3. **Launch Jupyter** and open any lab notebook:

   ```bash
   jupyter notebook
   ```

## Model and temperature

- **Default model:** `claude-haiku-4-5` — fast and cost-effective, and a good fit for these tool-calling and reasoning labs.
- **Override:** set the `LLM_MODEL` environment variable to any Claude model id (for example `claude-opus-4-8`) before starting Jupyter. Every LLM call across all four labs picks it up. In the `aisuite` labs (M3–M5) the `anthropic:` provider prefix is added automatically.
- **Temperature:** the migrated labs do **not** set `temperature`. Current Claude models (Opus 4.7/4.8, Sonnet 5) reject sampling parameters, so behavior is steered through prompting rather than temperature. (The earlier OpenAI version set `temperature` in one unused helper; that has been removed for cross-model compatibility.)

## Credit

These labs are adapted from DeepLearning.AI's *Agentic AI* course:
<https://learn.deeplearning.ai/courses/agentic-ai/lesson/k2vehc/benefits-of-agentic-ai>

Course community: <https://community.deeplearning.ai/c/course-q-a/agentic-ai/567>
