# VM Requirements — DEL-217,348 (Building AI Applications, 7/27–7/31)

Requirements for the Protech Ubuntu VM. Items marked **VERIFIED** were checked directly
on the provisioned VM on 2026-07-20.

## Must be installed / available

1. **`git`** — **VERIFIED MISSING** (`git: command not found`). Needed to clone the labs.
   `sudo apt install -y git`
2. **`curl`** — **VERIFIED MISSING**. `sudo apt install -y curl`
3. **Usable `sudo` for the `protech` user** — `sudo` currently **prompts for a password**
   (`[sudo] password for protech:`). Please either pre-install the packages below so no
   in-class `sudo` is needed, **or** confirm the `protech` password works for `sudo`, **or**
   grant passwordless sudo.
4. **`python3-venv` and `python3-pip`** — each lab builds a virtual environment.
   `sudo apt install -y python3-venv python3-pip`
5. **Python 3.10+** — Ubuntu 22.04 / 24.04 default is fine.
6. **Unrestricted outbound HTTPS** to: PyPI (`pypi.org`, `files.pythonhosted.org`),
   `huggingface.co`, and the AI service endpoints — `api.anthropic.com`, `api.openai.com`,
   `api.cohere.com`, and AWS (`*.amazonaws.com`, incl. `bedrock-runtime.*`).

> **Simplest for Protech:** bake **`git`, `curl`, `python3-venv`, `python3-pip`** into the
> VM image so nothing needs installing during class.

## Confirmed NOT needed

- **No Docker / containers.**
- **8 GB RAM** is sufficient (no need for the 12 GB Docker tier).

## Still to verify (blocked — needs the sudo password / GitHub PAT, which the instructor enters)

- Outbound egress to the AI endpoints — will confirm via `labs/verify-setup.sh` once `git`
  and `curl` are installed and the repo is cloned.
