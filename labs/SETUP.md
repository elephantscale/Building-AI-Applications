# Lab Setup — Building AI Applications

The labs are **pure Python** Jupyter notebooks that call hosted AI APIs. There is
**no Docker, no Kubernetes, and no local server** to run:

- Vector stores run **embedded in-process** (Chroma), so there's nothing to stand up.
- The database-agent lab uses a **SQLite file**.
- The model, search, and cloud services are all **hosted APIs** (HTTPS calls out).

So a plain Ubuntu VM with Python and internet access is all that's required.

## VM Requirements (what to provision)

- **Ubuntu** (standard defaults — 22.04 / 24.04 LTS both fine)
- **Python 3.10+** with `pip` and the `venv` module (`sudo apt install -y python3-venv python3-pip`)
- **~8 GB RAM**, a few GB free disk (for pip packages and one small local embedding model)
- **Outbound HTTPS** to: `pypi.org` / `files.pythonhosted.org` (pip), `huggingface.co`
  (one small embedder), and the AI service endpoints — `api.anthropic.com`,
  `api.openai.com`, `api.cohere.com`, `api.tavily.com`, and AWS (`*.amazonaws.com`) for the Day-4 labs.
- **No Docker required.**

> For Protech: an Ubuntu VM with **standard defaults + Python 3.10+ and internet
> egress** is sufficient. **8 GB** is enough (Docker's 12 GB tier is not needed).

## Per-Lab Python Environment

Each lab folder has its own `requirements.txt`. From a lab folder:

```bash
python3 -m venv myenv
source myenv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
cp .env.example .env      # then fill in the API keys
jupyter lab               # or: jupyter notebook
```

## API Keys (provided by the instructor, set in each lab's `.env`)

| Key | Needed for |
|-----|-----------|
| `ANTHROPIC_API_KEY` | **All labs** (the model) |
| `OPENAI_API_KEY` | RAG labs 04 & 05 (embeddings only) |
| `COHERE_API_KEY` | Lab 03 (Cohere embeddings + rerank) |
| `TAVILY_API_KEY` | Lab 07 (agent web research) |
| AWS credentials | Day-4 labs 09 & 10 (Claude on Amazon Bedrock) |

Keys are **not** something Protech provides — the instructor supplies them in class.

## Verify the VM

Run the readiness check from the repo root:

```bash
./labs/verify-setup.sh            # environment + key + connectivity checks
./labs/verify-setup.sh --install  # also create each lab's venv and install its requirements
./labs/verify-setup.sh --live     # also make one tiny live Claude call to confirm the key works
```

Exit code 0 = ready.
