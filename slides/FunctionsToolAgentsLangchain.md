# OpenAI Function Calling

---

# Setup

---
## Introduction
- Learn how to use OpenAI’s function calling feature.
- Key steps covered:
  - Setting up your environment to interact with OpenAI APIs.
  - Defining and using custom functions to enhance AI interactions.
  - Understanding and handling function calls in AI workflows.
- Why this is important:
  - Function calling enables structured and programmatic AI interactions,
    expanding the possibilities of automation and integration.

---

## Setup
- Import necessary libraries and configure API keys:
```python
import os
import openai
from dotenv import load_dotenv

load_dotenv()  # Load environment variables from a .env file
openai.api_key = os.getenv('OPENAI_API_KEY')  # Set OpenAI API key
```

- Key Insight:
  - Proper setup ensures secure and seamless access to OpenAI’s powerful APIs.

---

## Defining a Custom Function
- Create a function to simulate weather retrieval:
```python
import json

def get_current_weather(location, unit="fahrenheit"):
    """Get the current weather in a given location"""
    weather_info = {
        "location": location,
        "temperature": "72",
        "unit": unit,
        "forecast": ["sunny", "windy"],
    }
    return json.dumps(weather_info)
```

- Why define custom functions:
  - Custom functions extend the capabilities of AI by integrating domain-specific logic.

---

## Registering the Function
- Define the function’s schema for OpenAI:
```python
functions = [{
    "name": "get_current_weather",
    "description": "Get the current weather in a given location",
    "parameters": {
        "type": "object",
        "properties": {
            "location": {
                "type": "string",
                "description": "The city and state, e.g., San Francisco, CA",
            },
            "unit": {
                "type": "string",
                "enum": ["celsius", "fahrenheit"]
            },
        },
        "required": ["location"],
    },
}]
```

- Why this is important:
  - Function schemas define how the AI can interact with your functions, ensuring
    proper input and output handling.

---

## Sending a User Message
- Example user message:
```python
messages = [{
    "role": "user",
    "content": "What's the weather like in Boston?"
}]
```

---

## Invoking the Function
- Send the message and function schema to OpenAI:
```python
response = openai.ChatCompletion.create(
    model="gpt-4-0613",
    messages=messages,
    functions=functions
)
print(response)
```

- Why this matters:
  - Sending both user input and function schemas allows the AI to choose whether
    to call the function for additional information.

---

## Handling Function Output
- Extract and execute the function call:
```python
function_call = response.choices[0].message.function_call
args = json.loads(function_call.arguments)
print(get_current_weather(**args))
```

- Key Insight:
  - Handling function calls programmatically enables seamless integration of
    AI-generated logic with external systems.

---

## Next Steps
- Extend this workflow by:
  - Adding more complex functions and schemas.
  - Integrating with real-world APIs for dynamic data.
- Why it’s important:
  - Leveraging OpenAI’s function calling enhances AI's ability to operate as an
    intelligent assistant in diverse applications.

---

# LCEL

---

## Introduction
- This lesson focuses on understanding and implementing LCEL techniques.
- Key objectives:
  - Exploring the fundamental concepts.
  - Hands-on coding to demonstrate LCEL principles.
  - Practical applications for real-world scenarios.

---

## LCEL
- LCEL stands for LangChain Expression Language
- a declarative framework within the LangChain ecosystem 
- designed to simplify the creation and management of complex chains involving Large Language Models (LLMs). 
- By allowing developers to describe desired operations rather than detailing procedural steps
- LCEL enables more efficient and optimized execution of tasks such as 
  - streaming
  - batch processing
  - and asynchronous operations

---

## Setup
- Import necessary libraries:
```python
import os
from dotenv import load_dotenv

load_dotenv()  # Load environment variables from a .env file
```

- Ensure your environment is configured with all dependencies.

---

## Code Example: Basic LCEL Implementation
- Here’s an example of LCEL in action:
```python
def example_function():
    print("This is an LCEL example function.")
    return True

example_function()
```

---

## Next Steps
- Apply LCEL concepts to more complex scenarios.
- Experiment with additional libraries and techniques.
- Analyze results to refine your understanding of LCEL.

---

# OpenAI Function with LangChain

---

## Introduction
- This lesson integrates OpenAI’s function calling capabilities with LangChain.
- Key steps covered:
  - Setting up LangChain to work with OpenAI APIs.
  - Defining and invoking functions using LangChain workflows.
  - Demonstrating use cases for enhanced automation and efficiency.
- **Why this is important**:
  - LangChain extends OpenAI’s function calling by providing a structured framework
    for building intelligent workflows, enabling scalability and customization.

---

## Setup
- Import required libraries:
```python
import os
from langchain.schema import HumanMessage
from langchain_openai import AzureChatOpenAI
from dotenv import load_dotenv

load_dotenv()  # Load environment variables securely
```

- **What this does**:
  - Ensures secure configuration for OpenAI and LangChain integration by loading
    API keys and environment variables.

---

## Connecting to OpenAI
- Initialize the OpenAI model with LangChain:
```python
model = AzureChatOpenAI(
    openai_api_key=os.getenv('OPENAI_API_KEY'),
    azure_deployment=os.getenv('AZURE_DEPLOYMENT'),
    azure_endpoint=os.getenv('AZURE_ENDPOINT'),
    openai_api_version=os.getenv('OPENAI_API_VERSION'),
)
```

- **Key insight**:
  - Establishing this connection allows LangChain to leverage OpenAI’s capabilities
    for building conversational AI agents and automation workflows.

---

## Defining a Custom Function
- Define a function schema in LangChain for OpenAI:
```python
functions = [{
    "name": "example_function",
    "description": "An example function schema to demonstrate functionality",
    "parameters": {
        "type": "object",
        "properties": {
            "parameter1": {"type": "string", "description": "A sample parameter"},
        },
        "required": ["parameter1"],
    },
}]
```

- **Why this is important**:
  - Defining function schemas ensures that OpenAI can correctly interpret and
    execute tasks according to your specifications.

---

## Preparing a User Query
- Example of a user message:
```python
messages = [
    {"role": "user", "content": "Perform the example function with parameter1 set to 'value'."}
]
```

- **What happens here**:
  - The user’s input is structured into a message object that LangChain can
    process and pass to OpenAI for further action.

---

## Function Invocation and Response
- Execute the function call and handle the response:
```python
response = model.invoke(messages, functions=functions)
print(response)
```

- **Understanding the response**:
  - The output includes both the user’s original message and the response generated
    by the function, providing a complete interaction log.

---

## Advanced Example: Weather Function Integration
- Example: Integrate a weather function using LangChain:
```python
def get_weather(location):
    return f"The current weather in {location} is sunny and 75°F."

functions = [{
    "name": "get_weather",
    "description": "Get the current weather for a specified location",
    "parameters": {
        "type": "object",
        "properties": {
            "location": {"type": "string", "description": "The city or place name"},
        },
        "required": ["location"],
    },
}]
messages = [
    {"role": "user", "content": "What’s the weather like in New York City?"}
]
response = model.invoke(messages, functions=functions)
print(response)
```

- **Key takeaway**:
  - This example demonstrates how to integrate external logic (e.g., weather data)
    into LangChain workflows using OpenAI’s function calling.

---

## Debugging and Logging
- Log function calls for debugging and transparency:
```python
for choice in response.choices:
    print(f"Function Call: {choice.message.function_call}")
    print(f"Arguments: {choice.message.function_call.arguments}")
```

- **Why this matters**:
  - Debugging ensures that your workflows are functioning as expected and helps
    identify any issues in function invocation.

---

## Next Steps
- Experiment with:
  - Creating and testing more complex functions.
  - Integrating APIs for dynamic data retrieval and processing.
- Build workflows for:
  - Conversational agents.
  - Task automation.
  - Data analysis pipelines.
- **Real-world impact**:
  - Combining LangChain with OpenAI’s function calling unlocks powerful possibilities
    for building adaptive, intelligent systems.

---

# Tagging and Extraction Using OpenAI

---

## Introduction
- This lesson explores how to use OpenAI functions for tagging and information extraction.
- Key objectives:
  - Understand tagging and its applications in data categorization.
  - Implement information extraction using function calling.
  - Automate structured data generation from unstructured text.
- **Why this is important**:
  - Automating tagging and data extraction saves time and reduces errors in
    information processing tasks.

---

## Setup
- Import necessary libraries:
```python
import os
import openai
from dotenv import load_dotenv

load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")
```

- **What this does**:
  - Ensures secure and seamless configuration for accessing OpenAI’s API.

---

## Defining a Function for Tagging
- Example: Create a tagging function schema:
```python
functions = [{
    "name": "tag_content",
    "description": "Extract tags from the provided content",
    "parameters": {
        "type": "object",
        "properties": {
            "content": {"type": "string", "description": "The text to be tagged"},
        },
        "required": ["content"],
    },
}]
```

---

## Invoking the Function
- Provide input for tagging:
```python
messages = [
    {"role": "user", "content": "Tag the following content: 'AI is transforming the world of automation.'"}
]
```
- Use OpenAI to call the tagging function:
```python
response = openai.ChatCompletion.create(
    model="gpt-4-0613",
    messages=messages,
    functions=functions
)
print(response)
```

- **Expected output**:
  - Extracted tags such as `["AI", "automation"]`.

---

## Extracting Specific Data
- Example: Create a schema for extracting structured data:
```python
functions = [{
    "name": "extract_data",
    "description": "Extract specific data points from a given text",
    "parameters": {
        "type": "object",
        "properties": {
            "text": {"type": "string", "description": "Input text"},
            "fields": {
                "type": "array",
                "items": {"type": "string"},
                "description": "List of fields to extract",
            },
        },
        "required": ["text", "fields"],
    },
}]
messages = [
    {"role": "user", "content": "Extract 'author' and 'publication year' from 'OpenAI was founded in 2015 by Sam Altman.'"}
]
response = openai.ChatCompletion.create(
    model="gpt-4-0613",
    messages=messages,
    functions=functions
)
print(response)
```

- **Why this matters**:
  - Enables precise and automated extraction of structured data from natural language inputs.

---

## Debugging and Validation
- Log and validate function outputs for correctness:
```python
for choice in response.choices:
    print(f"Function Call: {choice.message.function_call}")
    print(f"Arguments: {choice.message.function_call.arguments}")
```

- **Key insight**:
  - Validation ensures that the extracted data meets the expected criteria,
    reducing errors in automated workflows.

---

# Tools and Routing

---

## Introduction
- This lesson demonstrates how to use tools and routing in AI workflows.
- Key objectives:
  - Understand the concept of tools in AI systems.
  - Implement routing logic to handle diverse workflows.
  - Leverage OpenAI’s capabilities for dynamic task management.

---

## Setup
- Import required libraries:
```python
import os
from langchain.schema import HumanMessage
from langchain.tools import Tool
from langchain.routing import Router
from dotenv import load_dotenv

load_dotenv()
```

---

## Tools in AI Workflows
- Define tools for specific tasks:
```python
tools = [
    Tool(
        name="Translate",
        func=lambda text: f"Translated: {text}",
        description="Translate text from one language to another."
    ),
    Tool(
        name="Summarize",
        func=lambda text: f"Summary: {text[:50]}...",
        description="Summarize a given text."
    ),
]
```

- **Why tools matter**:
  - Tools encapsulate functionality for specific tasks, making workflows modular
    and reusable.

---

## Routing Logic
- Implement a router for task delegation:
```python
router = Router(
    routes={
        "translate": tools[0],
        "summarize": tools[1]
    }
)

message = {"role": "user", "content": "Translate: Hello, world!"}
route = router.get_route(message)
response = route.func(message['content'])
print(response)
```

- **Key insight**:
  - Routing logic dynamically determines which tool to invoke based on user input,
    enabling flexible and adaptive workflows.

---

## Next Steps
- Experiment with:
  - Creating additional tools for tasks like data analysis or image generation.
  - Building more complex routing logic for multi-step workflows.
- **Real-world applications**:
  - Use tools and routing to design scalable AI systems for customer support,
    data processing, and more.

---

# Conversational Agent

---

## Introduction
- This lesson focuses on building a conversational agent using OpenAI’s models.
- Key objectives:
  - Understand the principles of conversational AI.
  - Implement a simple chatbot that interacts dynamically.
  - Explore advanced features like context handling and function calls.

---

## Setup
- Import necessary libraries:
```python
import os
from langchain.chat_models import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage, AIMessage
from dotenv import load_dotenv

load_dotenv()  # Load environment variables securely
```

- **What this does**:
  - Prepares your environment for creating and managing conversational agents.

---

## Initializing the Chat Model
- Set up the conversational model:
```python
model = ChatOpenAI(
    openai_api_key=os.getenv('OPENAI_API_KEY'),
    temperature=0.7
)
```

- **Why this is important**:
  - Configuring the model ensures appropriate behavior, such as creativity and
    relevance, during conversations.

---

## Basic Conversation
- Example of a basic conversation flow:
```python
messages = [
    HumanMessage(content="Hi, how are you?"),
    AIMessage(content="I'm doing great! How can I assist you today?")
]

response = model(messages)
print(response)
```

- **What happens here**:
  - The model processes user input and generates appropriate responses,
    simulating a conversational interaction.

---

## Context Handling
- Add context to the conversation:
```python
messages = [
    SystemMessage(content="You are a helpful assistant."),
    HumanMessage(content="Can you summarize the latest news?")
]

response = model(messages)
print(response)
```

- **Why this matters**:
  - Including system messages guides the AI’s behavior, ensuring responses align
    with the intended role or tone.

---

## Advanced Features: Function Calling
- Define a function for the conversational agent:
```python
def weather_info(location):
    return f"The current weather in {location} is sunny with a temperature of 75°F."

functions = [{
    "name": "weather_info",
    "description": "Get weather details for a specific location",
    "parameters": {
        "type": "object",
        "properties": {
            "location": {"type": "string", "description": "The city or location name"},
        },
        "required": ["location"]
    }
}]
```

- Call the function during a conversation:
```python
messages = [
    HumanMessage(content="What's the weather in New York?"),
]

response = model.invoke(messages, functions=functions)
print(response)
```

- **Key Insight**:
  - Function calling adds dynamic capabilities, enabling the conversational agent
    to perform tasks or fetch data beyond static responses.

---

## Next Steps
- Experiment with:
  - Integrating APIs for real-time information retrieval.
  - Implementing multi-turn dialogues with context-aware responses.
- **Real-world applications**:
  - Build intelligent assistants for customer support, education, and personal
    productivity.
