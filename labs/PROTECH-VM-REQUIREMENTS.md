# VM Requirements — DEL-217,348 (Building AI Applications, 7/27–7/31)

Running list of requirements for the Protech Ubuntu VM. Draft — still collecting.

## Requested

1. **`sudo` access** for the `protech` user — needed to install packages and prep the lab environment.
2. **`curl` installed** (`sudo apt install -y curl`) — confirmed missing on the current VM.

## Also verified on the current VM (recommend including)

3. **`python3-venv` and `python3-pip`** present (`sudo apt install -y python3-venv python3-pip`) — each lab builds a venv.
4. **Python 3.10+** (Ubuntu 22.04/24.04 default is fine).
5. **Unrestricted outbound HTTPS** to: PyPI (`pypi.org`, `files.pythonhosted.org`),
   `huggingface.co`, and the AI service endpoints — `api.anthropic.com`, `api.openai.com`,
   `api.cohere.com`, and AWS (`*.amazonaws.com`, incl. `bedrock-runtime.*`).

## Confirmed NOT needed

- **No Docker / containers.**
- **8 GB RAM** is sufficient (no need for the 12 GB Docker tier).

<!-- add more items below as they come in -->
