# Effective Prompting 

# Guidelines

---
## Introduction
* Topic: Effective Prompting Techniques for Language Models
* Focus:
  * Principles of clear communication with AI models
  * Tactics to improve AI interaction
  * Practical examples and structured outputs

---
## Principle 1: Write Clear and Specific Instructions
* Avoid short or vague prompts.
* Provide detailed and unambiguous instructions.
* Benefits:
  * Better context understanding.
  * More accurate and relevant responses.

---
## Principle 1 Tactic 1: Use Delimiters
* Delimiters clearly indicate distinct parts of the input.
* Examples:
  * Backticks: ```
  * Quotes: """ or ""
  * Tags: `<tag>` and `</tag>`
* Code Example:
  ```python
  text = """..."""
  prompt = "Summarize the text delimited by triple backticks..."
  ```

---
## Principle 1 Tactic 2: Ask for Structured Output
* Request output in formats like JSON or HTML.
* Code Example:
  ```python
  prompt = """
  Generate three book titles with authors and genres in JSON format.
  """
  ```
* Benefit:
  * Makes parsing and automation easier.

---
## Principle 1 Tactic 3: Check Conditions
* Ensure AI validates requirements.
* Example:
  * Rewriting a recipe into structured steps.
* Code Example:
  ```python
  prompt = """
  Rewrite instructions as Step 1, Step 2, ...
  """
  ```

---
## Principle 1 Tactic 4: Few-shot Prompting
* Provide examples in the prompt to guide the model.
* Example:
  ```python
  prompt = """
  <child>: Teach me about resilience.
  <grandparent>: Example response here.
  """
  ```

---
## Principle 2: Give the Model Time to “Think”
* Encourage multi-step problem-solving.
* Specify logical steps explicitly.
* Example Tasks:
  * Summarization.
  * Translation.
  * Counting items in text.

---
## Principle 2 Tactic 1: Multi-step Instructions
* Example:
  ```python
  prompt = """
  1. Summarize the text.
  2. Translate into French.
  3. List names in the summary.
  4. Provide output in JSON format.
  """
  ```
* Benefit:
  * Reduces errors in complex tasks.

---
## Principle 2 Tactic 2: Self-Verification
* Ask the model to solve the problem and compare.
* Example:
  ```python
  prompt = """
  Solve the problem yourself and compare with the student's solution.
  """
  ```
* Application:
  * Validation of reasoning and results.

---
## Model Limitations: Hallucinations
* Example:
  * "AeroGlide UltraSlim Smart Toothbrush by Boie" - invented product.
* Key Insight:
  * Cross-check AI outputs for factual accuracy.

---
## Experimentation
* Try new prompt
---

# Iterative

---
## Introduction
* Focus:
  * Generate effective product descriptions from technical fact sheets.
  * Address challenges such as length, relevance, and organization.
  * Tailor outputs for specific audiences like furniture retailers.

---
## Generate Product Descriptions
* Input: Fact sheet for a mid-century-inspired office chair.
* Task: Create a retail website description.
* Example prompt:
  ```python
  prompt = """
  Write a product description based on the technical specifications.
  Specifications: ```<fact_sheet>```
  """
  ```

---
## Issue 1: Text is Too Long
* Challenge:
  * Descriptions can exceed the desired word count or character limit.
* Solution:
  * Specify limits such as "50 words" or "3 sentences."
* Example:
  ```python
  prompt = """
  Write a description in at most 50 words.
  Specifications: ```<fact_sheet>```
  """
  ```

---
## Issue 2: Focus on Relevant Details
* Challenge:
  * Initial descriptions may emphasize less relevant aspects.
* Solution:
  * Instruct the model to focus on key materials or construction details.
* Example:
  ```python
  prompt = """
  Focus on materials and construction. Use at most 50 words.
  Specifications: ```<fact_sheet>```
  """
  ```

---
## Issue 3: Include a Table of Dimensions
* Challenge:
  * Audience requires clear dimensions in tabular format.
* Solution:
  * Generate descriptions with an appended HTML table.
* Example:
  ```python
  prompt = """
  Include dimensions in a two-column table titled 'Product Dimensions.'
  Specifications: ```<fact_sheet>```
  """
  ```

---
## Example HTML Output
* HTML for product descriptions:
  ```html
  <div>
    A detailed product description.
  </div>
  <table>
    <tr><th>Dimension</th><th>Measurement</th></tr>
    <tr><td>Width</td><td>20.87"</td></tr>
    <tr><td>Height</td><td>31.50"</td></tr>
  </table>
  ```

---
## Experimentation
* Test and refine prompts to align with audience needs.
* Incorporate specific requests like IDs or formatting styles.
* Adjust for tone, technical depth, and visual layout.

# Summarizing 

---
## Introduction
* Topic: Summarizing content effectively using AI.
* Purpose: Learn how to extract key insights from complex documents.
* Applications:
  * Quick comprehension.
  * Simplified communication.
  * Enhanced productivity.

---
## Principles of Summarization
* Focus on the main idea.
* Eliminate unnecessary details.
* Adapt summaries for specific audiences.
* Use structured formats like lists or tables.

---
## Use Case: Summarizing Technical Documents
* Example: Product fact sheets, research papers, or technical guides.
* Challenges:
  * Dense, detailed information.
  * Varying audience needs (technical vs. non-technical).
* AI Role:
  * Automates the summarization process.
  * Ensures clarity and conciseness.

---
## Techniques in AI Summarization
* Extractive Summarization:
  * Pulls key sentences or phrases from the original text.
* Abstractive Summarization:
  * Generates new sentences to convey the core message.
* Hybrid Models:
  * Combines extraction and abstraction for nuanced summaries.

---
## Practical Example
* Input: Technical fact sheet for an office chair.
* Task: Generate a concise product description.
* Key Features:
  * Material details.
  * Dimensions and specifications.
  * Adaptation to retailer or end-user needs.

---
## Addressing Common Issues
* Text is too long:
  * Limit output by words, sentences, or characters.
* Focus on the wrong details:
  * Specify important aspects (e.g., materials, features).
* Lack of clarity:
  * Use structured prompts for better results.

---
## Experimentation and Customization
* Test various prompts for optimal output.
* Adjust summarization based on:
  * Audience.
  * Context.
  * Desired output format (e.g., list, table, prose).
* Leverage AI’s flexibility for diverse use cases.

---
## Conclusion
* AI-powered summarization saves time and effort.
* Tailored techniques ensure relevance and clarity.
* Experiment with prompts to refine summaries.
* Applications span technical, creative, and general domains.

---


# Inferring

---
## Introduction
* Sentiment and Topics in Text Data
* Learn how to infer sentiment and topics from text.
* Explore product reviews and news articles.
* Utilize OpenAI’s LLM models for analysis.

---
## Setup
* Import necessary libraries:
  * `openai` for API interactions.
  * `dotenv` for environment variable management.
* Load API keys securely:
  * Use `.env` files to manage credentials.
* Define the model:
  * Assign the preferred LLM model to `MODEL`.

---
## Key Functionality
* Define the `get_completion` function:
  * Takes a prompt and uses OpenAI's API to generate responses.
  * Sends structured user prompts as `messages`.
  * Customizable `temperature` for output diversity.

---
## Product Review Analysis
* Analyze the following product review text:

```text
Needed a nice lamp for my bedroom, and this one had additional storage
and not too high of a price point. Got it fast. The string to our lamp broke 
during the transit and the company happily sent over a new one. 
Came within a few days as well. It was easy to put together. 
I had a missing part, so I contacted their support 
and they very quickly got me the missing piece! 
Lumina seems to me to be a great company that cares 
about their customers and products!!
```
---
* Extract sentiment and key themes.

---
## Next Steps
* Expand analysis:
* Apply similar techniques to news articles.
* Broaden insights with topic extraction.
* Explore advanced LLM capabilities:
* Fine-tune temperature and prompt engineering.
* Integrate into larger workflows for text analysis.

---

# Expanding

---
## Introduction
* Generating Customized Customer Responses
  * Generate tailored customer service emails.
  * Respond effectively to customer reviews and sentiments.
  * Leverage Large Language Models (LLMs) to automate and personalize communications.

---
## Setup
* Import key libraries:
  * `openai` for API interactions.
  * `dotenv` for securely loading environment variables.
* Secure API credentials:
  * Use `.env` files for managing sensitive information.
* Assign the model:
  * Define your LLM model in the variable `MODEL`.

---
## Key Functionality
* Define the `get_completion` function:
  * Inputs a prompt and communicates with OpenAI's API.
  * Processes structured `messages` for tailored responses.
  * Adjustable `temperature` for varying creativity in outputs.

---
## Customizing Customer Replies
* Automate responses based on inferred sentiment.
* Example:
  * Sentiment: **Negative**
  * Customer Review (about a blender):
    ```
    So, they still had the 17 piece system on seasonal sale for around $49 in the month of November, about half off, but for some reason (call it price gouging) around the second week of December the prices all went up to about anywhere from between $70-$89 for the same system. And the 11 piece system went up around $10 or so in price also from the earlier sale price of $29. ...
    ```
* Generate empathetic and constructive responses addressing specific concerns.

---
## Next Steps
* Expand use cases:
  * Automate replies for diverse products and services.
  * Adapt tone and content to align with customer sentiment.
* Enhance workflows:
  * Integrate response generation into customer support pipelines.
  * Experiment with more creative and domain-specific responses.

---

# The Chat Format

---
## Introduction
* Personalized and Specialized Chatbots
* Explore extended conversations using the chat format.
* Create chatbots personalized for specific tasks or behaviors.
* Leverage Large Language Models (LLMs) for dynamic interaction.

---
## Setup
* Import required libraries:
  * `openai` for API communication.
  * `dotenv` for secure management of API keys.
* Configure environment variables:
  * Use `.env` files to store sensitive information.
* Assign the preferred model:
  * Define `MODEL` for chatbot responses.

---
## Key Functions
* Define `get_completion`:
  * Accepts a prompt and interacts with OpenAI’s API.
  * Generates responses based on user input.
* Define `get_completion_from_messages`:
  * Processes a sequence of conversation messages.
  * Supports continuity in chatbot interactions.

---
## Example: Chatbot in Shakespearean Style
* Conversation setup:
  * Role: "You are an assistant that speaks like Shakespeare."
* Example interaction:

```text
User: Tell me a joke. 
Assistant: Why did the chicken cross the road? 
User: I don't know. 
Assistant: To takeeth a gander at yonder other side!
```

---
## Customization and Use Cases
* Create specialized assistants:
* Define system roles for behavior control.
* Tailor responses to specific contexts (e.g., humor, professionalism).
* Use temperature parameter to adjust creativity:
* Higher values for more random responses.
* Lower values for deterministic outputs.

---
## Next Steps
* Experiment with system roles:
* Design bots for teaching, storytelling, or technical support.
* Enhance conversational depth:
* Utilize `get_completion_from_messages` for context-aware dialogues.
* Explore integrations:
* Embed chatbots into websites, applications, or customer service workflows.

---