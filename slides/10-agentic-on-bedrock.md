# Cloud Agents & Guardrails

Elephant Scale

---

## A Cloud Agent on Bedrock

Earlier you built agents in code — you ran the reasoning loop yourself. Bedrock offers a
**managed agent**: you declare the model, the instructions, and the tools, and the
platform runs the loop, the tracing, and the scaling.

```python
bedrock_agent = boto3.client('bedrock-agent', region_name='us-west-2')

create_agent_response = bedrock_agent.create_agent(
    agentName='customer-support-agent',
    foundationModel='us.anthropic.claude-haiku-4-5',
    instruction="You are a front-line customer support agent.",
    agentResourceRoleArn=RESOURCE_ROLE_ARN,
)
agentId = create_agent_response['agent']['agentId']
```

- **`instruction`** — the agent's persona and rules (a system prompt, at agent scope).
- Agents move through states — `creating` → `not-prepared` → `prepared` — then you assign an **alias** to invoke a stable version.
- The **runtime client** (`invoke_agent`) sends a message and streams back the agent's reasoning and reply.

> Same agent *concepts* as when you built one by hand — planning, tools, memory — but the cloud owns the loop.

---

## Giving the Agent Actions

An agent that can only talk is a chatbot. To *act*, it needs tools. On Bedrock, tools are
**action groups** — a schema of functions, backed by a Lambda that actually runs them.

```python
bedrock_agent.create_agent_action_group(
    agentId=agentId,
    actionGroupName='CustomerSupportActions',
    actionGroupExecutor={"lambda": LAMBDA_FUNCTION_ARN},
    functionSchema={"functions": [
        {"name": "CustomerID",
         "description": "Look up a customer ID from email, name, or phone.",
         "parameters": {"email": {"type": "string", "required": False}}},
        {"name": "SendToSupport",
         "description": "Escalate a case to a human agent.",
         "parameters": {"customerId": {"type": "string", "required": True}}},
    ]},
)
```

- **Description-driven** — the model reads your descriptions to decide *when* to call each function. Write them like documentation.
- The **executor Lambda** connects the agent to real systems: a CRM, a database, an API.
- Bedrock also offers a built-in **Code Interpreter** action group for calculations and code — precise where language models are shaky.

> This is tool use, hosted: same "functions become tools" idea, wired into cloud
> infrastructure instead of your local loop.

---

## Guardrails: Topic & Content Policies

An autonomous agent talking to customers needs a safety net that doesn't depend on the
prompt behaving. **Bedrock Guardrails** are that net — policy enforced *around* the model,
on both input and output.

```python
bedrock.create_guardrail(
    name="support-guardrails",
    topicPolicyConfig={"topicsConfig": [{
        "name": "Internal Customer Information",
        "definition": "Data available only through internal systems, e.g. customer IDs.",
        "type": "DENY",
    }]},
    contentPolicyConfig={"filtersConfig": [
        {"type": "SEXUAL",   "inputStrength": "HIGH", "outputStrength": "HIGH"},
        {"type": "VIOLENCE", "inputStrength": "HIGH", "outputStrength": "HIGH"},
        {"type": "INSULTS",  "inputStrength": "HIGH", "outputStrength": "HIGH"},
    ]},
    blockingInputMessage="Sorry, I can't process that request.",
    blockingOutputMessage="Sorry, I can't provide that response.",
)
```

- **Topic policy** — deny whole subjects (off-limits topics, internal data).
- **Content policy** — filter categories like hate, violence, insults, at tunable strength.
- Attach the guardrail to the agent; it applies to *every* turn, independent of the prompt.

> Guardrails are the **last line of defense**, not the only one. They complement prompt
> design — the foundation of defending AI systems in depth.

---

## Attaching a Knowledge Base

For an agent to answer from *your* content — an FAQ, a product manual — you attach a
**Knowledge Base**: managed RAG that Bedrock retrieves from
automatically, no retrieval code of your own.

```python
bedrock_agent.associate_agent_knowledge_base(
    agentId=agentId,
    agentVersion='DRAFT',
    knowledgeBaseId=knowledgeBaseId,
    description="Customer support FAQ and product manuals.",
)
bedrock_agent.prepare_agent(agentId=agentId)
```

- The Knowledge Base ingests your documents, embeds them, and stores the vectors — the RAG pipeline you built by hand, as a managed service.
- The agent decides *on its own* when to retrieve: simple FAQ ("my mug is chipped — what can I do?") it answers directly; a refund it escalates via an action group.
- **Grounded answers** — responses come from your documents, cutting hallucination.

> Retrieval + tools + guardrails on one agent: it *knows* your content, can *act* on your
> systems, and stays *within* policy — a production assistant, assembled from managed parts.

---

## Lab 10 — Cloud Agent + Guardrails + Knowledge Base

**Stop here and run the lab now.** You'll build a managed customer-support agent on
Bedrock, give it tools, fence it with guardrails, and ground it in a knowledge base.

You will:
1. Create a Bedrock agent (model + instructions) and invoke it through an alias
2. Add an action group backed by a Lambda so the agent can look up and escalate cases
3. Add the Code Interpreter action group for a calculation the model shouldn't do in its head
4. Create a guardrail with topic and content policies and attach it to the agent
5. Associate a knowledge base and watch the agent answer FAQs from your documents
6. Trace a full conversation — retrieve, act, and stay within policy

Environment: Jupyter + `boto3` + AWS account (Bedrock Agents, Guardrails, Knowledge Bases, Lambda) · **60–75 minutes**

---

## Part 2 — Cloud Agent Debrief (after the lab)

Welcome back. You've built a cloud agent that retrieves, acts, and stays in bounds — the
production shape of a full AI assistant, running as managed infrastructure.

> Quick debrief: which mattered more for keeping your agent safe and useful — the
> guardrail, the knowledge base, or the tool descriptions? Where would a bad description
> have sent the agent wrong?
