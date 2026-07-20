# Lab 01 — Prompt Engineering (Claude)

Hands-on prompt-engineering with Anthropic Claude. You will work through the core
patterns for getting reliable, well-structured output from a large language model.

## Notebooks

| # | Notebook | Topic |
|---|----------|-------|
| 01 | `01-Guidelines.ipynb` | Two principles: clear instructions & giving the model time to think |
| 02 | `02-Iterative.ipynb` | Iteratively refining a prompt (marketing copy from a fact sheet) |
| 03 | `03-Summarizing.ipynb` | Summarizing with focus, and extract-vs-summarize |
| 04 | `04-Inferring.ipynb` | Sentiment, emotion, and topic inference |
| 05 | `05-Transforming.ipynb` | Translation, tone, format conversion, proofreading |
| 06 | `06-Expanding.ipynb` | Generating a tailored customer-service reply |
| 07 | `07-Chatbot.ipynb` | The chat format, system prompts, and an OrderBot |

## Setup

```sh
python -m venv myenv
source myenv/bin/activate      # Windows: myenv\Scripts\activate
pip install -r requirements.txt

cp .env.example .env           # then edit .env and add your ANTHROPIC_API_KEY
jupyter lab                    # or: jupyter notebook
```

## Model

The notebooks call Claude through a small `get_completion()` helper and default to
**`claude-haiku-4-5`** — fast and inexpensive, ideal for the many small calls in these
labs. Override the model with `LLM_MODEL` in your `.env` (for example
`claude-opus-4-8`).

> **Note on temperature:** `07-Chatbot.ipynb` passes `temperature` to demonstrate
> creative vs. deterministic output. This is supported on Claude Haiku 4.5. If you switch
> `LLM_MODEL` to Claude Opus 4.7 or newer (or Sonnet 5), remove the `temperature`
> argument — those models reject it.

## Notes

- This lab is migrated to Claude from a lab inspired by DeepLearning.AI's
  *ChatGPT Prompt Engineering for Developers*. Credit for the inspiration is
  acknowledged: https://learn.deeplearning.ai/chatgpt-prompt-eng/lesson/1/introduction
- Only the setup cells changed. Every prompt is provider-agnostic and runs unchanged —
  the whole point of the lab is the prompts, not the vendor.
