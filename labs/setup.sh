#!/usr/bin/env bash
#
# One-command setup for a SINGLE lab.
#
#   cd labs/01-Prompt-Engineering
#   ../setup.sh
#
# Creates a per-lab virtual environment (myenv), registers a Jupyter kernel,
# installs that lab's requirements, and makes sure the shared labs/.env exists.
#
# (To set up / test ALL labs at once instead, use ../verify-setup.sh --install
#  or ../test-all-labs.sh from the repo root.)
set -eo pipefail

LAB_DIR="$(pwd)"
LABS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$LABS_ROOT/.env"
ENV_EXAMPLE="$LABS_ROOT/.env.example"

if [[ ! -f "$LAB_DIR/requirements.txt" ]]; then
  echo "ERROR: no requirements.txt found in $LAB_DIR"
  echo "cd into a lab directory (e.g. labs/01-Prompt-Engineering) and run:  ../setup.sh"
  exit 1
fi

echo "==> Setting up lab: $(basename "$LAB_DIR")"

# 1. Create and activate the virtual environment
python3 -m venv myenv
source myenv/bin/activate

# 2. Tooling + Jupyter kernel
pip install --quiet --upgrade pip
pip install --quiet ipykernel
python -m ipykernel install --user --name=myenv --display-name "My env"

# 3. Lab requirements
pip install --quiet -r requirements.txt

# 4. Shared .env for API keys (ONE file at the labs root, used by every lab)
if [[ ! -f "$ENV_FILE" ]]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "==> Created $ENV_FILE from the template — add your key:  ANTHROPIC_API_KEY=sk-ant-..."
else
  echo "==> Using existing $ENV_FILE"
fi

echo
echo "Done. To use this environment:"
echo "  - In Jupyter/VS Code, select the kernel:  My env"
echo "  - Or in a shell:  source myenv/bin/activate"
echo "  - Make sure $ENV_FILE has your ANTHROPIC_API_KEY"
