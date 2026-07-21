# Serverless AI on the Cloud

Elephant Scale

---

## Where We Are

Days 1–3 you built AI on your laptop: prompts, RAG, and agents, all calling the model
through an SDK from a notebook. That's exactly how you *prototype*.

Now we cross into **production**. The same model, the same patterns — but now running
as cloud infrastructure that scales, logs, and reacts to events without a machine you
babysit.

- **Before:** you drove the model from code you ran by hand.
- **Now:** the cloud runs that code for you, on demand, at scale.

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

> Same idea as a hosted API — the provider does the hard, expensive part (the model),
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

> The pattern is identical to a direct SDK call — construct a client, send a request, read the
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
- The function's **IAM role** grants exactly the permissions it needs (invoke Bedrock, read S3) — least privilege.
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

## Part 2 — Serverless Pipeline Debrief (after the lab)

Welcome back. You just shipped a serverless pipeline: an upload triggers a chain of
managed services and a summary comes out — no server, no babysitting.

But notice what that pipeline *isn't*: it's a fixed sequence you wired by hand. Every
step, every branch, decided in advance.

> Quick debrief: where did the async, event-driven nature bite you — a job that wasn't
> ready yet, a file that hadn't landed? How is that different from a single blocking API call?
