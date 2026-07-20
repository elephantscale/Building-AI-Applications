# Module 4 — Production & Serverless AI on the Cloud

Elephant Scale

---

## Module 4 Agenda

- From notebooks to production: why serverless for AI
- Foundation models on a managed cloud AI service (Amazon Bedrock)
- Calling the model from code with `boto3`
- A real serverless pipeline: transcribe audio → summarize
- Logging and observability with CloudWatch
- Deploying the pipeline as an AWS Lambda function
- Event-driven architecture: an S3 upload triggers the pipeline
- **Lab 09 — Serverless AI on AWS Lambda**
- Building a cloud agent with action groups
- Guardrails: topic and content policies
- Attaching a Knowledge Base for grounded answers
- **Lab 10 — Cloud Agent + Guardrails + Knowledge Base**
- *(Optional)* Multimodal and long-context models
- *(Optional)* **Lab 11 — Multimodal & Long Context**

---

## Where We Are

Days 1–3 you built AI on your laptop: prompts, RAG, and agents, all calling the model
through an SDK from a notebook. That's exactly how you *prototype*.

Today we cross into **production**. The same model, the same patterns — but now running
as cloud infrastructure that scales, logs, and reacts to events without a machine you
babysit.

- **Yesterday:** you drove the model from code you ran by hand.
- **Today:** the cloud runs that code for you, on demand, at scale.

> The AI concepts don't change. What changes is *where the code lives* and *who runs it* —
> and that's the difference between a demo and a product.

---

# Foundation Models on a Managed Cloud Service

---

## Why Serverless for AI

A production AI feature has an awkward shape: bursty traffic, heavy per-call compute,
and long idle stretches. Running a server 24/7 for that is wasteful; scaling one under a
spike is painful.

**Serverless** flips it around — you deploy a *function*, and the platform runs it only
when there's work, scaling from zero to thousands of concurrent calls automatically.

- **No servers to manage** — no patching, no capacity planning.
- **Pay per invocation** — nothing runs, nothing costs.
- **Scales with demand** — one call or ten thousand, same code.
- **Event-driven** — code runs *in response to* things happening (a file lands, a request arrives).

> AI workloads are spiky and compute-heavy — exactly the shape serverless was built for.

---

## A Managed Cloud AI Service: Amazon Bedrock

You don't want to host a foundation model yourself — GPUs, weights, scaling, uptime. A
**managed cloud AI service** hands you the model behind an API instead. On AWS, that
service is **Amazon Bedrock**.

- **One API, many models** — access a range of foundation models through a single interface.
- **No infrastructure** — no model to download, deploy, or keep running.
- **In your AWS account** — calls stay inside your cloud's security and networking boundary.
- **Pay per token**, like any hosted model — no idle GPU bill.

> Same idea as Day 1's hosted API — the provider does the hard, expensive part (the model),
> you build the application on top. Here the provider is your cloud, and the model runs
> next to the rest of your infrastructure.

- In this course, **Claude runs as the model on Bedrock** — the same Claude you've used all week, now served by AWS.

---

## Calling the Model with `boto3`

`boto3` is the AWS SDK for Python — one client per service. For model calls you use the
**`bedrock-runtime`** client and its `invoke_model` call.

```python
import boto3
import json

bedrock_runtime = boto3.client('bedrock-runtime', region_name='us-west-2')
```

- **`bedrock`** — the control plane: create agents, guardrails, knowledge bases.
- **`bedrock-runtime`** — the data plane: actually *invoke* a model and get a response.
- Credentials and region come from your AWS environment — no API key in the code.

> The pattern is identical to Day 1 — construct a client, send a request, read the
> response. Only the transport changed: you're going through your cloud, not a public SDK.

---

## Invoking Claude on Bedrock

`invoke_model` takes a **model id** and a JSON **body**. For Claude, the body is the same
messages shape you already know, wrapped for Bedrock:

```python
prompt = "Write a one-sentence summary of Las Vegas."

body = json.dumps({
    "anthropic_version": "bedrock-2023-05-31",
    "max_tokens": 512,
    "messages": [{"role": "user", "content": prompt}],
})

response = bedrock_runtime.invoke_model(
    modelId="us.anthropic.claude-haiku-4-5",
    contentType="application/json",
    body=body,
)

result = json.loads(response["body"].read())
print(result["content"][0]["text"])
```

- `messages`, `max_tokens`, roles — the concepts carry over exactly from Module 1.
- The response `body` is a **stream** you read and JSON-decode.
- Swap `modelId` to change tiers (Haiku for volume, Opus for hard tasks) — one string.

> The AI stays the same; the plumbing is AWS. Everything you learned about prompts, tokens,
> and structured output still applies.

---

# A Serverless AI Pipeline

---

## The Pipeline: Audio → Summary

Let's build something real: drop in an audio recording of a meeting, get back a written
summary. That's two managed services chained together — one for speech-to-text, one for
the language model.

```
   audio file            transcript              summary
  (dialog.mp3)            (text)                  (text)
      │                     │                        │
      ▼                     ▼                        ▼
┌───────────┐        ┌──────────────┐        ┌──────────────┐
│    S3     │ ─────▶ │   Amazon     │ ─────▶ │   Bedrock    │
│  (audio)  │        │  Transcribe  │        │  (Claude)    │
└───────────┘        └──────────────┘        └──────────────┘
   store              speech → text            summarize
```

- **Amazon Transcribe** — a managed speech-to-text service.
- **Amazon S3** — object storage; the audio goes in, the transcript comes out.
- **Bedrock (Claude)** — turns the raw transcript into a useful summary.

> Each box is a managed service. You're not building AI infrastructure — you're *composing* it.

---

## Step 1 — Transcribe the Audio

Upload the file to S3, then start a transcription job pointed at it. Transcribe can even
label who spoke.

```python
s3_client = boto3.client('s3', region_name='us-west-2')
s3_client.upload_file(file_name, bucket_name, file_name)

transcribe_client = boto3.client('transcribe', region_name='us-west-2')

response = transcribe_client.start_transcription_job(
    TranscriptionJobName=job_name,
    Media={'MediaFileUri': f's3://{bucket_name}/{file_name}'},
    MediaFormat='mp3',
    LanguageCode='en-US',
    OutputBucketName=bucket_name,
    Settings={'ShowSpeakerLabels': True, 'MaxSpeakerLabels': 2},
)
```

- The job runs **asynchronously** — you start it, then poll for completion.
- Output is a JSON transcript written back to S3, with per-word speaker labels.

> This is the async cloud pattern: kick off work, get an id back, check on it later —
> not every call returns instantly.

---

## Step 2 — Summarize with the Model

Once the transcript is ready, hand it to Claude. This is a plain prompt — everything from
Module 1 applies. Delimiters mark the transcript as *data*, not instructions.

```python
prompt = f"""The text between the <transcript> tags is a conversation.
Write a short summary of the conversation.

<transcript>
{dialogue_text}
</transcript>
"""

body = json.dumps({
    "anthropic_version": "bedrock-2023-05-31",
    "max_tokens": 512,
    "messages": [{"role": "user", "content": prompt}],
})
response = bedrock_runtime.invoke_model(
    modelId="us.anthropic.claude-haiku-4-5", body=body,
)
summary = json.loads(response["body"].read())["content"][0]["text"]
```

> Two managed services, a prompt in between, and you have a meeting-summarizer. The whole
> value is in the *composition*, not any one piece.

---

## Observability: Logging with CloudWatch

In a notebook you watch output scroll by. In production, code runs unattended — you need a
record of *what happened* after the fact. On AWS that record lives in **CloudWatch**.

- **Why log** — debug failures, watch latency and cost, spot abuse and anomalies.
- **What to log** — the request, the response, timing, errors, token usage.
- **Bedrock model-invocation logging** — turn it on and every model call is captured to
  CloudWatch (and optionally S3) automatically.

```python
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

try:
    response = bedrock_runtime.invoke_model(modelId=MODEL_ID, body=body)
    logger.info("Model invoked, %d bytes", len(response["body"].read()))
except Exception as e:
    logger.error("Error invoking model: %s", e)
```

> You can't fix — or trust — what you can't see. Observability is not optional in production;
> it's how you know the system is behaving.

---

## Deploying as an AWS Lambda Function

So far the pipeline runs in a notebook. To make it *serverless*, we move the code into an
**AWS Lambda function** — code the cloud runs on demand, with no server underneath.

```python
import json
import boto3

def lambda_handler(event, context):
    bedrock_runtime = boto3.client('bedrock-runtime', region_name='us-west-2')
    response = bedrock_runtime.invoke_model(
        modelId="us.anthropic.claude-haiku-4-5",
        body=json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 512,
            "messages": [{"role": "user", "content": event["prompt"]}],
        }),
    )
    result = json.loads(response["body"].read())
    return {"statusCode": 200, "body": result["content"][0]["text"]}
```

- **`lambda_handler(event, context)`** — the entry point AWS calls; `event` carries the input.
- The function's **IAM role** grants exactly the permissions it needs (invoke Bedrock, read S3) — least privilege, a Day 5 theme.
- No server, no scaling config — AWS runs a fresh copy per invocation.

> A Lambda is just your function, deployed. The cloud handles *when* and *how many times* it runs.

---

## Event-Driven Architecture

A deployed function still needs something to *call* it. The elegant pattern: let the cloud
call it automatically **when something happens**. Configure S3 so that dropping an audio
file **triggers** the Lambda — no one clicks "run."

```
  user uploads              S3 event               summary
   dialog.mp3                fires                 written back
      │                        │                        │
      ▼                        ▼                        ▼
┌───────────┐          ┌──────────────┐         ┌───────────┐
│ S3 bucket │ ──trigger▶ │    Lambda    │ ──────▶ │ S3 bucket │
│  (audio)  │          │ transcribe + │         │  (text)   │
│           │          │  summarize   │         │           │
└───────────┘          └──────────────┘         └───────────┘
```

- **The trigger** — an S3 "object created" event, filtered to `.mp3` files.
- **The handler** reads `event['Records'][0]['s3']` to find which file landed.
- The whole pipeline now runs itself — upload, and the summary appears.

> This is production AI's natural shape: **events in, results out**, with no human in the
> loop and nothing running when nothing's happening.

<!-- image: S3-triggers-Lambda event-driven diagram -->

---

## Lab 09 — Serverless AI on AWS Lambda

**Stop here and run the lab now.** You'll build the transcribe-then-summarize pipeline on
real AWS services and deploy it as an event-driven Lambda.

You will:
1. Invoke a foundation model on Bedrock from `boto3` and read the response
2. Transcribe an audio file with Amazon Transcribe (audio in S3 → text)
3. Summarize the transcript by prompting Claude on Bedrock
4. Enable CloudWatch logging and inspect the invocation logs
5. Package the pipeline as an AWS Lambda function with a scoped IAM role
6. Add an S3 trigger so uploading an `.mp3` runs the pipeline end to end

Environment: Jupyter + `boto3` + AWS account (Bedrock, S3, Transcribe, Lambda, CloudWatch) · **60–75 minutes**

---

## Part 2 — From Pipelines to Agents (after the lab)

Welcome back. You just shipped a serverless pipeline: an upload triggers a chain of
managed services and a summary comes out — no server, no babysitting.

But notice what that pipeline *isn't*: it's a fixed sequence you wired by hand. Next we let
the **model decide** what to do — a cloud **agent** that picks actions, calls systems, and
answers on its own, all managed by Bedrock.

> Quick debrief: where did the async, event-driven nature bite you — a job that wasn't
> ready yet, a file that hadn't landed? How is that different from a single blocking API call?

---

# Cloud Agents & Guardrails

---

## A Cloud Agent on Bedrock

Day 3 you built agents in code — you ran the reasoning loop yourself. Bedrock offers a
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

> Same agent *concepts* as Day 3 — planning, tools, memory — but the cloud owns the loop.

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

> This is Day 3's tool use, hosted: same "functions become tools" idea, wired into cloud
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
> design — a preview of Day 5, where we go deep on defending AI systems.

---

## Attaching a Knowledge Base

For an agent to answer from *your* content — an FAQ, a product manual — you attach a
**Knowledge Base**: managed RAG (Day 2's pattern) that Bedrock retrieves from
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

- The Knowledge Base ingests your documents, embeds them, and stores the vectors — the RAG pipeline you built by hand on Day 2, as a managed service.
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

## Part 2 — Beyond Text (after the lab)

Welcome back. You've built a cloud agent that retrieves, acts, and stays in bounds — the
production shape of everything from Days 1–3, running as managed infrastructure.

Everything so far has been **text in, text out**. But modern foundation models also *see*:
they read images, understand documents, and reason over very long inputs. The optional
section ahead is a tour of that frontier.

> Quick debrief: which mattered more for keeping your agent safe and useful — the
> guardrail, the knowledge base, or the tool descriptions? Where would a bad description
> have sent the agent wrong?

---

# Multimodal & Long Context *(Optional)*

---

## Multimodal Models *(Optional)*

> **This section is optional.** It frames capabilities available across modern foundation
> models. Concepts are generic; use whichever multimodal model your platform provides.

A **multimodal model** accepts more than text — most commonly images alongside a prompt.
That unlocks a class of applications text alone can't reach.

- **Image reasoning** — describe a photo, answer questions about a chart, compare two images.
- **Grounding** — point to *where* in an image something is (locate the defect, the label, the object).
- **Document understanding** — read a scanned invoice or form and pull out structured fields, layout and all.

> The interface barely changes — you add an image block to the same messages call. The
> *capability* is what's new: the model now reasons over what it sees, not just what it reads.

---

## Long-Context Tasks *(Optional)*

> **This section is optional.** Context limits from Module 1 apply — large, but finite.

Frontier models accept very large inputs — hundreds of pages at once. That changes what a
single call can do.

- **Whole-document summarization** — a full report or transcript in one pass, no chunking.
- **Multi-document reasoning** — compare and synthesize across several sources together.
- **Codebase Q&A** — load many files and ask questions that span them.

- **Prompt optimization** — systematically refine prompts against examples instead of by hand.
- **Synthetic data generation** — have the model produce training or test data on demand.

> Long context is *not* a replacement for RAG. Retrieval scales to millions of documents
> and stays cheap; long context shines when you truly need everything in view at once.
> Knowing which to reach for is the skill.

---

## Lab 11 — Multimodal & Long Context *(Optional)*

**Stop here and run the lab now — if time allows.** This lab is **optional** and
provider-native: it explores vision and long-context capabilities that may use a different
model than the rest of the course. Treat it as a deep-dive; the concepts transfer to any
multimodal model, including Claude's vision.

You will:
1. Send an image with a prompt and have the model reason about what it sees
2. Ground a response — locate and describe specific regions of an image
3. Extract structured fields from a document (form or invoice) in one call
4. Summarize a long document in a single long-context pass
5. Ask questions that span multiple documents or files at once
6. *(If included)* try prompt optimization and synthetic data generation

Environment: Jupyter + a multimodal foundation model · **optional · 45–60 minutes**

---

## Module 4 Summary

- AI workloads are spiky and compute-heavy — **serverless** fits them: pay per call, scale from zero, run on events.
- A **managed cloud AI service** (Amazon Bedrock) serves foundation models through one API, inside your AWS account — with **Claude as the model**.
- You call it with **`boto3`** — same messages, tokens, and prompts you know; only the transport is AWS.
- A real pipeline chains managed services: **S3 → Transcribe → Bedrock** turns audio into a summary.
- Production means **observability** (CloudWatch), deployment as a **Lambda**, and **event-driven** triggers (S3 → Lambda).
- **Bedrock agents** run the agent loop for you; **action groups** give them tools, **Guardrails** keep them safe, a **Knowledge Base** grounds them in your content.
- Modern models also go **multimodal** and **long-context** — the same interface, broader capability.

---

## What's Next

**Day 5 — Securing AI Applications**

You can now build modern AI applications and ship them to the cloud. Tomorrow we turn
around and **attack** what you built — then defend it:

- The AI application threat model — semantic attacks, the OWASP LLM Top 10
- Prompt injection: direct, indirect, and hidden instructions
- Securing RAG pipelines against poisoned documents
- Safe tools and least-privilege, human-in-the-loop agents
- Guardrails, validation, and a capstone: harden your own AI application

> You've learned to build AI systems — including the guardrails preview today. Next you
> learn to **defend** them, before an attacker gets the chance.

---
