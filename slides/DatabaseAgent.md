# Your First AI Database Agent

---

# Setup

---

## Introduction
- Learn how to build and interact with an AI agent using LangChain.
- Key steps covered:
  - Connecting to the Azure OpenAI endpoint.
  - Preparing prompts for interaction.
  - Receiving and processing model responses.
- **Why this is important**:
  - AI agents automate repetitive tasks and improve efficiency in real-world applications like translation and summarization.

---

## Setup
- Import necessary libraries:
```python
    import os
    from dotenv import load_dotenv
    from langchain.schema import HumanMessage
    from langchain_openai import AzureChatOpenAI

    load_dotenv()
```

- **What you’ll learn**:
  - How to set up your Python environment to interact with Azure OpenAI using LangChain.
  - Securely manage sensitive data like API keys and credentials without hardcoding them in your scripts.

---

## Connecting to Azure OpenAI

- Initialize the Azure OpenAI model:

```python
    model = AzureChatOpenAI(
        openai_api_version=os.getenv('OPENAI_API_VERSION'),
        azure_deployment=os.getenv('AZURE_DEPLOYMENT'),
        openai_api_key=os.getenv('AZURE_API_KEY'),
        azure_endpoint=os.getenv('AZURE_ENDPOINT')
    )
```

- **Key concept**:
  - Establishing a connection is the first step to leveraging the power of Azure OpenAI for building AI agents.

---

## Preparing your prompt
- Define your input message:
```python
    message = HumanMessage(
        content="Translate this sentence from English "
                "to French and Spanish. I like red cars and "
                "blue houses, but my dog is yellow."
    )
```
- **Why prompts matter**:
  - Clear and specific prompts help AI agents deliver accurate and contextually relevant outputs.

---

## Engaging the model to receive a response
- Invoke the model with your prompt:
```python
    response = model.invoke([message])
    print(response)
```
- **What happens here**:
  - The AI model processes your input prompt and generates responses in both French and Spanish.

---

## Next Steps
- Experiment with different prompts:
  - Translation
  - Summarization
  - Creative writing
- Extend the agent’s functionality:
  - Connect to APIs for real-world applications.
  - Incorporate context-based interactions using LangChain tools.
- **Why it matters**:
  - Expanding functionality enhances your AI agent’s adaptability for diverse tasks.

---

# Manipulating CSV Files

---

## Introduction
- Learn how to interact with CSV data files using Python.
- Key steps covered:
  - Reading CSV files into Python.
  - Manipulating data using pandas.
  - Writing processed data back to a CSV file.
  - Handling edge cases such as missing or malformed data.
- **Why CSV manipulation is essential**:
  - CSV files are a common format for data exchange in analytics, making this a vital skill.

---

## Setup
- Import necessary libraries:

```python
    import pandas as pd
    import os
    from dotenv import load_dotenv    
```    

- **Why pandas**:
  - Pandas simplifies reading, processing, and analyzing structured data efficiently.

---

## Reading a CSV File

```python
# Load data from a CSV file:
    df = pd.read_csv("data.csv")
    print(df.head())

# Handle missing files with error handling:
    try:
        df = pd.read_csv("data.csv")
    except FileNotFoundError:
        print("File not found. Please check the file path.")
```

- **Why this is critical**:
  - Ensures your program handles unexpected scenarios gracefully, improving reliability.

---

## Manipulating Data
- Example: Filter rows where the "Age" column is greater than 30.

```python
    filtered_df = df[df['Age'] > 30]
    print(filtered_df)
```
- **Additional operations**:
  - Renaming columns:

 ```python
        df.rename(columns={"old_column": "new_column"}, inplace=True)
 ```
  - Adding new columns:
```python
        df['Age_in_months'] = df['Age'] * 12
```
- **Key takeaway**:
  - Data manipulation allows for creating more meaningful datasets tailored to specific use cases.

---

## Writing to a New CSV File
- Save processed data to a new CSV file:
 ```python
    filtered_df.to_csv("filtered_data.csv", index=False)
 ```

- Ensure UTF-8 encoding for compatibility:
 ```python
    filtered_df.to_csv("filtered_data.csv", index=False, encoding="utf-8")
 ```

- **Why this is important**:
  - Exporting clean, processed data ensures compatibility and usability in downstream applications.

---

## Next Steps
- Experiment with additional operations:
  - Data aggregation (e.g., group by categories).
  - Sorting, ranking, and deduplication.
- Automate CSV processing in workflows using Python scripts or cron jobs.
- Visualize data trends using libraries like Matplotlib or Seaborn.
- **Why it matters**:
  - Automating and visualizing data insights drives efficiency and informed decision-making.

---

# Working with SQL Databases

---

## Introduction
- Learn how to connect and interact with SQL databases using Python.
- Key steps covered:
  - Setting up a connection to a SQL database.
  - Executing queries to retrieve and manipulate data.
  - Using pandas for data analysis with SQL results.
- **Why SQL is foundational**:
  - SQL is critical for managing and querying structured data in most real-world applications.

---

## Setup
- Import necessary libraries:
```python
    import sqlite3
    import pandas as pd
```
- **What this enables**:
  - Combines database interactions with data manipulation for end-to-end analytics.

---

## Connecting to the Database

```python
# Establish a connection to the database:
    connection = sqlite3.connect("example.db")
# Create a cursor object to execute SQL commands:
    cursor = connection.cursor()
```
- **Key insight**:
  - Connections form the bridge between Python and your database for seamless interaction.

---

## Creating a Table
```python
# Example: Create a table named `users`:
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            name TEXT,
            age INTEGER
        )
    ''')
    connection.commit()
```
- **Why this matters**:
  - Structuring data in tables is the backbone of relational database design.

---

## Inserting Data
- Insert rows into the `users` table:

```python
    cursor.execute('''
        INSERT INTO users (name, age)
        VALUES ('Alice', 30), ('Bob', 25), ('Charlie', 35)
    ''')
    connection.commit()
```

- **Why it’s useful**:
  - Populating tables with data enables queries and analytics on real-world datasets.

---

## Querying Data
- Retrieve data from the table:

```python
    result = cursor.execute('SELECT * FROM users').fetchall()
    print(result)
```

- **Key takeaway**:
  - Querying allows extracting meaningful insights from your database efficiently.

---

## Using pandas for SQL Queries
- Read SQL query results into a pandas DataFrame:

```python
    df = pd.read_sql_query('SELECT * FROM users', connection)
    print(df)
```

- Perform pandas operations on the retrieved data:

```python
    df['is_adult'] = df['age'] > 18
    print(df)
```

- **Why combine SQL and pandas**:
  - It bridges structured database storage with powerful Python-based data analytics.

---

## Closing the Connection
- Close the database connection to free resources:

```python
    connection.close()
```

- **Best practice**:
  - Always release database connections to prevent resource leaks and ensure system stability.
---

## Next Steps
- Explore advanced SQL operations:
  - Joins, nested queries, and window functions.
  - Using ORMs like SQLAlchemy for complex applications.
- Optimize database performance:
  - Indexing and query optimization.
- **Why it matters**:
  - Mastery of SQL and database management is essential for scalable and efficient applications.

---

# Integrating Azure OpenAI

---

## Introduction
- Learn how to use the Azure OpenAI Function Calling feature.
- Key steps covered:
  - Setting up an Azure OpenAI environment.
  - Registering and invoking serverless functions.
  - Integrating with external APIs and services.
- **Why use function calling**:
  - Enables automation of workflows and seamless integration with external systems.

---

## Setup

- Import required libraries:
- Load environment variables securely using dotenv:
- Set up Azure credentials:

```python
    import os
    from dotenv import load_dotenv
    from azure.identity import DefaultAzureCredential
    from azure.ai.openai import OpenAIClient

    load_dotenv()

    credential = DefaultAzureCredential()
    endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
```

---

## Connecting to Azure OpenAI
- Initialize the OpenAI client:
```python
    client = OpenAIClient(credential=credential, endpoint=endpoint)
```
- **What this does**:
  - Sets up your application to interact with Azure OpenAI services programmatically.

---

## Defining a Function
- Define a function for specific tasks:
```python
    def translate_text(input_text, target_language):
        return f"Translated text in {target_language}"
```
- **Key insight**:
  - Custom functions enable modular, reusable components in larger workflows.

---

## Registering the Function with Azure
- Register the function:
```python
    function_registry = {"translate": translate_text}
```
- **Why register functions**:
  - It provides a structured way to integrate external logic into Azure workflows.

---

## Invoking the Function
- Call the registered function:
```python
    input_data = {"input_text": "Hello, world!", "target_language": "Spanish"}
    result = function_registry["translate"](**input_data)
    print(result)
```
- **Why this matters**:
  - Function calling automates repetitive tasks, enabling efficient processing at scale.

---

## Next Steps
- Extend Azure Function capabilities:
  - Register advanced functions for data analysis and transformation.
  - Integrate with cloud-hosted databases and APIs.
- Build end-to-end workflows with serverless architecture.
- **Real-world impact**:
  - Azure Function Calling unlocks scalable, real-time automation for enterprise applications.

---

# Enhancing SQL Interactions

---

## Introduction
- Learn how to use Assistant APIs to interact with SQL databases efficiently.
- Key steps covered:
  - Setting up and authenticating the Assistant API.
  - Querying SQL databases using natural language.
  - Automating data retrieval and updates with API workflows.
- **Why it matters**:
  - Natural language interfaces simplify complex database interactions for non-technical users.

---

## Setup
- Import necessary libraries:
```python
    import os
    import requests
    from dotenv import load_dotenv

    load_dotenv()
```
- **What this does**:
  - Ensures secure configuration for API-based SQL interactions.

---

## Authenticating the API
- Authenticate with the Assistant API using API keys:
```python
    api_key = os.getenv("ASSISTANT_API_KEY")
    base_url = os.getenv("ASSISTANT_API_BASE_URL")
    headers = {"Authorization": f"Bearer {api_key}"}
```
- **Why authentication**:
  - Secures access to the API, ensuring only authorized users can interact with your database.

---

## Sending a Query
- Send a SQL query to the Assistant API:
```python
    payload = {"query": "SELECT * FROM users WHERE age > 30", "database": "example_db"}
    response = requests.post(f"{base_url}/query", json=payload, headers=headers)
    result = response.json()
    print(result)
```
- **Key insight**:
  - The API enables seamless execution of complex SQL queries with minimal code.

---

## Automating Queries
- Automate SQL queries with natural language inputs:
```python
    payload = {"query": "Show me all users older than 30", "database": "example_db", "nl_query": True}
    response = requests.post(f"{base_url}/query", json=payload, headers=headers)
    print(response.json())
```
- **Why this is valuable**:
  - Automating query workflows reduces manual effort and accelerates data analysis.

---

## Next Steps
- Expand capabilities with advanced features:
  - Automate data pipelines using API queries.
  - Build dashboards to visualize query results in real time.
- Ensure secure database operations:
  - Validate queries to prevent injection attacks.
  - Use role-based access control.
- **Why it’s critical**:
  - Secure, automated SQL workflows empower businesses to derive insights efficiently and safely.
