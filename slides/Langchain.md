# Langchain

---

# Model, Prompts, and Parsers

---

## Introduction
- This lesson explores foundational concepts for interacting with AI models.
- Key objectives:
  - Understanding how to craft effective prompts.
  - Exploring the role of parsers in processing model outputs.
  - Demonstrating practical examples of prompts and parsers.
- **Why this is important**:
  - Effective prompts and parsers ensure that AI models deliver accurate, usable results.
  - Combining the right prompts with parsers transforms unstructured AI outputs into actionable insights.

---

## Setup
- Import required libraries:
```python
import os
import openai
from dotenv import load_dotenv

load_dotenv()  # Load environment variables securely
openai.api_key = os.getenv('OPENAI_API_KEY')
```

- **Key Insight**:
  - This setup avoids hardcoding sensitive information like API keys, ensuring security and flexibility.

---

## Crafting Effective Prompts
- Example of a simple prompt:
```python
prompt = "Write a short story about a brave knight and a dragon."
response = openai.Completion.create(
    model="text-davinci-003",
    prompt=prompt,
    max_tokens=150
)
print(response.choices[0].text.strip())
```

- **Key Insight**:
  - Clear and concise prompts improve the relevance and quality of model responses.
  - This example demonstrates creative content generation, showcasing OpenAI’s capability for storytelling.

---

## Using Parsers
- Parse model outputs for structured results:
```python
import json

response_text = '{"name": "John", "age": 30}'
parsed_output = json.loads(response_text)
print(parsed_output)
```

- **Why Parsers Matter**:
  - AI outputs are often free-form text; parsers convert them into structured formats like JSON for easier downstream processing.
  - Parsing enhances automation and usability, especially in workflows requiring integration with databases or analytics.

---

## Combining Prompts and Parsers
- Example workflow:
```python
prompt = "Generate a JSON object with details about a fictional character."
response = openai.Completion.create(
    model="text-davinci-003",
    prompt=prompt,
    max_tokens=100
)
parsed_character = json.loads(response.choices[0].text.strip())
print(parsed_character)
```

- **What this does**:
  - This combination allows seamless interaction between natural language prompts and structured outputs, bridging the gap between human-readable and machine-readable formats.

---

## Next Steps
- Experiment with different prompt structures to optimize results.
- Explore advanced parsing techniques for specific use cases.
- **Real-World Applications**:
  - Automated content generation.
  - Generating structured data for analytics.
  - Building tools for summarization and classification.

---

# Memory

---

## Introduction
- This lesson explores memory components in AI systems and how to manage context.
- Key objectives:
  - Implement memory for conversational agents.
  - Understand techniques to handle context over multiple interactions.
- **Why this is important**:
  - Memory enables continuity in conversations, making interactions more human-like and personalized.

---

## Setup
- Import required libraries:
```python
import os
from langchain.memory import ConversationBufferMemory
```

- **What this does**:
  - Sets up the tools needed to store and retrieve conversation history for creating coherent multi-turn interactions.

---

## Creating Memory
- Example of a conversation buffer memory:
```python
memory = ConversationBufferMemory()
memory.save_context(
    {"input": "Hello!"},
    {"output": "Hi there! How can I assist you?"}
)
print(memory.load_memory_variables({}))
```

- **What this does**:
  - Stores interactions to maintain context across a session, ensuring responses are contextual and relevant.

---

## Advanced Memory Techniques
- Combine memory with conversational agents:
```python
from langchain.chat_models import ChatOpenAI

chat = ChatOpenAI(temperature=0.7)
response = chat(memory=memory)
print(response)
```

- **Why this matters**:
  - Enhances user experience by maintaining a history of interactions, enabling more meaningful and personalized conversations.

---

## Next Steps
- Experiment with different memory types:
  - ConversationBufferMemory: For a full transcript.
  - ConversationSummaryMemory: For concise history summaries.
- **Applications**:
  - Personalized customer support bots.
  - Persistent virtual assistants.

---

# Chain

---

## Introduction
- This lesson introduces chains in LangChain to connect multiple steps in workflows.
- Key objectives:
  - Learn how to use chains to create multi-step interactions.
  - Implement custom chains for complex tasks.
- **Why this is important**:
  - Chains simplify the design of workflows by linking multiple steps logically and sequentially.

---

## Creating a Chain
- Example of a simple chain:
```python
def step_one(input_text):
    return input_text.upper()

def step_two(uppercase_text):
    return f"Processed: {uppercase_text}"

chain = SimpleChain([step_one, step_two])
result = chain.run("hello world")
print(result)
```

- **What this does**:
  - Combines multiple functions into a single pipeline, making workflows modular and easier to manage.

---

## Next Steps
- Explore advanced chains like SequentialChain and TransformChain.
- Combine chains with tools for dynamic task handling.
- **Real-World Applications**:
  - Multi-step data processing.
  - Automated workflows for content generation and transformation.

---

# QnA

---

## Introduction
- Learn how to implement QnA systems using OpenAI models.
- Key objectives:
  - Build simple question-and-answer pipelines.
  - Extend capabilities with context-aware responses.
- **Why this is important**:
  - QnA systems are foundational for chatbots, knowledge bases, and AI-driven assistants.

---

## Building a QnA System
- Example:
```python
prompt = PromptTemplate(
    input_variables=["question"],
    template="Answer the question: {question}"
)
qna_chain = QnAChain(prompt=prompt)
response = qna_chain.run("What is the capital of France?")
print(response)
```

- **What this does**:
  - Simplifies the process of retrieving precise answers to user queries by leveraging well-constructed prompts.

---

## Next Steps
- Combine QnA systems with memory for multi-turn interactions.
- Integrate external knowledge bases for domain-specific applications.
- **Applications**:
  - Chatbots, FAQs, and support systems.

---

# Evaluation

---

## Introduction
- This lesson covers evaluation techniques for AI workflows.
- Key objectives:
  - Implement methods to test and refine AI outputs.
  - Automate evaluation metrics for efficiency.

---

## Evaluation Workflow
- Example of evaluating outputs:
```python
def evaluate_output(output, expected):
    return output == expected

print(evaluate_output("Paris", "Paris"))
```

- **Why this is important**:
  - Evaluation ensures that workflows meet quality standards and function correctly.

---

## Next Steps
- Explore advanced metrics for evaluating generative models.
- Implement feedback loops for continuous improvement.
- **Applications**:
  - Testing and monitoring production AI systems.
  - Building feedback-driven improvement systems.

---

# Functional Conversations

---

## Introduction
- Learn how to implement functional conversations in AI workflows.
- Key objectives:
  - Use functions to enhance interaction capabilities.
  - Handle complex tasks with modular components.

---

## Example Workflow
- Example:
```python
def fetch_weather(location):
    return f"The weather in {location} is sunny."

response = fetch_weather("New York")
print(response)
```

- **Why this is important**:
  - Functional components allow AI systems to handle tasks dynamically and flexibly.

---

## Next Steps
- Combine functional conversations with multi-turn memory for dynamic interactions.
- Integrate APIs for real-time functionality.
- **Applications**:
  - Virtual assistants with task execution capabilities.
  - Domain-specific AI agents for business operations.
