# Your First Agent with Amazon Bedrock

---

# Setup

---

## Introduction
- Build a simple cloud-based agent with Amazon Bedrock.
- Understand agent setup, invocation, and tracing.

---

## Steps to Create an Agent
1. Import required libraries:
```python
import boto3
from dotenv import load_dotenv

load_dotenv()
bedrock_agent = boto3.client('bedrock', region_name='us-west-2')
```

2. Create an agent:
```python
agent_response = bedrock_agent.create_agent(
    agentName='CustomerSupportAgent',
    foundationModelIdentifier='anthropic_claude_3',
    instructions='You are an advanced AI agent acting as a customer support agent.',
    resourceRoleArn=os.getenv("RESOURCE_ROLE_ARN")
)
```

3. Prepare and configure the agent.

---

## Observing the Agent Workflow
- Transition through states: `creating`, `not-prepared`, and `prepared`.
- Assign an alias to invoke the agent.
- Use the runtime client to interact with the agent.

---

## Key Takeaways
- Agents require configuration for production use.
- Aliases ensure stability and version control for deployment.

---

# Connecting Your Agent to a CRM

---

## Introduction
- Enable your agent to integrate with external systems, such as CRMs.
- Use Lambda functions to handle customer data and support requests.

---

## Setting Up Actions and Action Groups
1. Define action groups:
```python
action_response = bedrock_agent.create_agent_action_group(
    agentId='YOUR_AGENT_ID',
    actionGroupName='CustomerSupportActions',
    actionGroupExecutor={
        "type": "Lambda",
        "resourceArn": os.getenv("LAMBDA_FUNCTION_ARN")
    },
    functionSchemas=[
        {
            "name": "CustomerID",
            "description": "Get customer ID based on email, name, or phone.",
            "parameters": {
                "email": {"type": "string", "description": "Customer email"},
                "name": {"type": "string", "description": "Customer name"},
                "phone": {"type": "string", "description": "Customer phone"}
            }
        },
        {
            "name": "SendToSupport",
            "description": "Escalate a case to human support.",
            "parameters": {
                "customerId": {"type": "string", "description": "Customer ID"},
                "supportSummary": {"type": "string", "description": "Summary of the issue"}
            }
        }
    ]
)
```

---

## Observing the Agent in Action
- Agents dynamically call functions to retrieve or log data.
- Example: Resolve a refund request by combining multiple steps.

Notes:
Farshid puts his notes
---

## Key Takeaways
- Actions expand the agent's utility and connectivity.
- Ensure descriptions and parameters align with expected workflows.

---

# Adding Calculations

---

## Introduction
- Extend the agent's capabilities by enabling code execution for calculations.
- Use the ephemeral Code Interpreter feature for precise logic.

---

## Setting Up Code Interpreter
1. Add a new action group for the Code Interpreter:
```python
interpreter_response = bedrock_agent.create_agent_action_group(
    agentId='YOUR_AGENT_ID',
    actionGroupName='CodeInterpreterActions',
    parentActionGroupSignature='AmazonCodeInterpreter',
    agentVersion='draft'
)
```

2. Observe the agent write and execute code:
```python
print("Calculating the date 10 weeks ago...")
code = """
import datetime
today = datetime.date.today()
purchase_date = today - datetime.timedelta(weeks=10)
print(purchase_date)
"""
```

---

## Key Takeaways
- Code Interpreter enables advanced logic within workflows.
- Outputs are ephemeral and improve decision-making accuracy.

---

# Guardrails for Your Agent

---

## Introduction
- Protect your agent from inappropriate behavior and sensitive data leakage.
- Implement guardrails as a safety net.

---

## Creating Guardrails
1. Define topic and content policies:
```python
guardrail_response = bedrock.create_guardrail(
    name="SupportGuardrails",
    description="Prevent leakage of sensitive data.",
    topicPolicyConfiguration={
        "topics": [{"name": "InternalCustomerInfo", "action": "Deny"}]
    },
    contentPolicyConfiguration={
        "filters": [
            {"type": "HateSpeech", "strength": "High"},
            {"type": "Violence", "strength": "High"},
            {"type": "Insults", "strength": "High"}
        ]
    },
    blockingInputMessage="Sorry, the model cannot process this input.",
    blockingOutputMessage="Sorry, the model cannot provide this output."
)
```

2. Connect the guardrail to your agent:
```python
bedrock_agent.update_agent(
    agentId='YOUR_AGENT_ID',
    guardrailConfigurations=[{
        "guardrailIdentifier": guardrail_id,
        "guardrailVersion": guardrail_version
    }]
)
```

---

## Key Takeaways
- Guardrails act as a last line of defense for agent safety.
- Combine with prompt engineering for robust control.

---

# Using a Knowledge Base

---

## Introduction
- Integrate a knowledge base to empower your agent with direct answers.
- Allow the agent to handle simple queries autonomously.

---

## Setting Up a Knowledge Base
1. Associate a knowledge base with your agent:
```python
knowledge_base_response = bedrock_agent.associate_agent_knowledge_base(
    agentId='YOUR_AGENT_ID',
    knowledgeBaseId='YOUR_KB_ID',
    agentVersion='draft',
    description='Adding knowledge base for customer support.'
)
```

2. Prepare the agent for deployment:
```python
bedrock_agent.prepare_agent(agentId='YOUR_AGENT_ID')
```

---

## Observing the Agent in Action
- Handle simple issues like "My mug is chipped. What can I do?"
- Escalate complex issues like refund requests to human workflows.

---

## Key Takeaways
- Knowledge bases reduce the need for human intervention.
- Enable the agent to address FAQs effectively.
