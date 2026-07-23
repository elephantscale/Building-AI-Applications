# Functions, Tools and Agents with Claude + LangChain

Hands-on lab for the **Building AI Applications** course, migrated from OpenAI to
Anthropic Claude. Lesson 1 uses the Anthropic Python SDK directly; Lessons 2–6
use LangChain with `ChatAnthropic` and provider-agnostic tool calling
(`.bind_tools`, `with_structured_output`, `create_tool_calling_agent`).

## Notebooks

| Notebook | Topic |
| --- | --- |
| `Lesson1_OpenAI_function_Calling.ipynb` | Claude tool use with the raw Anthropic SDK (`client.messages.create(..., tools=[...])`, handling `tool_use` / `tool_result` blocks). Example tool: `get_current_weather`. |
| `Lesson2_LCEL.ipynb` | LangChain Expression Language (LCEL): simple chains, a RAG retriever (local HuggingFace embeddings), `.bind_tools`, fallbacks, and the Runnable interface. |
| `Lesson3_OpenAI_function_Calling_In_Langchain.ipynb` | Pydantic schemas → tool definitions; `.bind_tools`, forcing a tool with `tool_choice`, and using tools in a chain. |
| `Lesson4__Tagging_Extraction_Using_OpenAI_functions.ipynb` | Tagging and extraction using `ChatAnthropic.with_structured_output` with Pydantic models. |
| `Lesson5_Tools_And_Routing.ipynb` | Defining `@tool`s, binding them, and routing between tools based on `AIMessage.tool_calls`. |
| `Lesson6_Conversational_Agent.ipynb` | A conversational agent with memory: manual agent loop, then `create_tool_calling_agent` + `AgentExecutor` + `ConversationBufferMemory`, with a Panel chat UI. |

## Setup

```sh
python -m venv myenv
source myenv/bin/activate          # Windows: myenv\Scripts\activate
pip install -r requirements.txt

jupyter notebook
```

> **Keys** come from the shared `labs/.env` (copy `labs/.env.example` → `labs/.env`
> once, in the repo's `labs/` directory). No per-lab `.env` needed — every lab reads it automatically.

## Model configuration

All notebooks read the model from an `LLM_MODEL` environment variable and fall
back to **`claude-haiku-4-5`**:

```python
MODEL = os.environ.get("LLM_MODEL", "claude-haiku-4-5")
```

Override it in `.env` (for example `LLM_MODEL=claude-opus-4-8`) to run against a
stronger model.

### A note on `temperature`

Several notebooks construct the model with `temperature=0` for deterministic
output. This works on **Claude Haiku 4.5** (the default), but `temperature` is
**rejected with an HTTP 400 on Opus 4.7+ and Sonnet 5**. If you switch
`LLM_MODEL` to one of those models, remove the `temperature=0` argument from the
`ChatAnthropic(...)` calls.

## Credit

Lesson content is adapted from DeepLearning.AI's short course
*"Functions, Tools and Agents with LangChain"*, migrated here to use Anthropic
Claude instead of OpenAI.
