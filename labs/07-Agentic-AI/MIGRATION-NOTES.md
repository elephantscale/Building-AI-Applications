# Migration Notes — OpenAI / aisuite → Anthropic Claude

This lab set was migrated from OpenAI (plus `aisuite`'s OpenAI backend) to **Anthropic Claude**. All text, reasoning, vision, and tool-calling now run on Claude. This document records what changed, what stayed, and why.

## Summary

| Lab | Original LLM usage | After migration |
|-----|--------------------|-----------------|
| **M2** | `utils.get_response` / vision helpers on `gpt-4o-mini`, `o4-mini` | Claude via the **Anthropic Python SDK** directly (`client.messages.create`, incl. vision). |
| **M3** | `aisuite` with `openai:gpt-4o`, `openai:o4-mini` (auto + manual tool calling) | `aisuite` with `anthropic:claude-...` model strings. |
| **M4** | `aisuite` with `openai:gpt-4o` (research agent + tools) | `aisuite` with `anthropic:claude-...`. |
| **M5** | `aisuite` with `openai:o4-mini` (4 agents) **+ OpenAI DALL·E 3** for images | `aisuite` with `anthropic:claude-...` for all 4 agents; **DALL·E 3 kept on OpenAI** for image generation. |

## Model selection

Every notebook reads the model from an environment variable with a Claude default:

```python
LLM_MODEL = os.getenv("LLM_MODEL", "claude-haiku-4-5")
```

- **Default:** `claude-haiku-4-5`.
- **Override:** `export LLM_MODEL=claude-opus-4-8` (or any Claude id).
- In the `aisuite` labs (M3–M5) the code adds the `anthropic:` provider prefix automatically when the value has no `provider:` prefix, so `aisuite` receives e.g. `anthropic:claude-opus-4-8`.

## Approach per lab

### M2 — Anthropic SDK directly
M2's helper module and dataset were **absent from the source** repository (the notebook imports `utils` and reads `coffee_sales.csv`, neither of which existed). To keep the lab runnable:

- A new **`utils.py`** was written using the **Anthropic Python SDK** (`anthropic.Anthropic().messages.create`). It implements `get_response` (text), `image_anthropic_call` (Claude vision for the reflection step), `encode_image_b64`, `load_and_prepare_data`, `ensure_execute_python_tags`, and `print_html`.
- `image_openai_call` is retained as a thin compatibility shim that delegates to the Claude vision call, since the notebook's model-name branch (`"claude" in model_name`) now always routes to Claude.
- A small **synthetic `coffee_sales.csv`** (~970 rows spanning Q1 2024 and Q1 2025) was generated so the reflection workflow has data to plot. It is synthetic sample data, not the original DeepLearning.AI dataset.

### M3, M4 — aisuite retained
Only the model strings changed (`openai:...` → `anthropic:...` via `LLM_MODEL`). `aisuite` normalizes Anthropic responses into the OpenAI-compatible shape the notebooks already use (`response.choices[0].message`, `.tool_calls`, `tool_call.function.arguments`, `tool_call.id`), so both the automatic (`max_turns`) and manual tool-calling paths work unchanged. Prompts and logic are untouched.

- **M4:** `research_tools.py` (arXiv, Tavily, Wikipedia) and `utils.py` (evaluation helpers) contain **no LLM calls** and were not modified. Tavily still requires `TAVILY_API_KEY`.

### M5 — aisuite retained + one OpenAI step for images
All four agents (Market Research, Graphic Designer *text*, Copywriter, Packaging) run on Claude via `aisuite`, including the Copywriter's **multimodal** image+text call (`aisuite` converts the OpenAI-style `image_url` data URL into a Claude image block).

`inventory_utils.py`'s `call_llm_for_reflection` helper (unused by this notebook, but present) was also switched from `gpt-4o` to the Claude `LLM_MODEL`, and its `temperature` argument was removed for compatibility with current Claude models.

## ⚠️ Image generation stays on OpenAI (the key decision)

**Claude has no image-generation capability.** M5's Graphic Designer Agent needs to *create* a campaign image, not just describe one. The migration therefore:

1. Uses **Claude** to write the image **prompt** and the marketing **caption** (this is reasoning/text — moved to Claude).
2. Keeps a **single OpenAI call to DALL·E 3** to render that Claude-written prompt into the actual campaign visual.

This is the **only** remaining OpenAI usage in the entire lab set. It requires `OPENAI_API_KEY` (used solely for this step; M2/M3/M4 do not need it). We chose to keep a real image-generation step rather than stub it with a placeholder, so the multi-agent pipeline stays end-to-end functional and the downstream Copywriter (Claude vision) and Packaging agents have a real image to work with.

If you do not have an OpenAI key, you can stub the image step: replace the `openai_client.images.generate(...)` block in `graphic_designer_agent` with code that copies a local placeholder image to `image_path`. The rest of the pipeline (all Claude) will run unchanged.

## Dependencies / keys

- Added: `anthropic`. Retained: `aisuite` (Anthropic backend), `openai` (image step only), `tavily-python`, `wikipedia`, `pandas`, `duckdb`, `matplotlib`, `Pillow`, `qrcode`.
- Keys: `ANTHROPIC_API_KEY` (all labs), `TAVILY_API_KEY` (M4, M5), `OPENAI_API_KEY` (M5 image step only). See `.env.example`.

## Not modified

The source `slides/` and `images/` directories were copied verbatim. Excluded from the copy: `myenv/`, `Transcription/`, `.ipynb_checkpoints/`, `.virtual_documents/`, `__pycache__/`.
