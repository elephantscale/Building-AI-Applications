#!/usr/bin/env bash
#
# verify-setup.sh — readiness check for the "Building AI Applications" lab VM.
#
# The labs are pure Python + hosted APIs. NO Docker is required.
#
# Usage:
#   ./verify-setup.sh            # environment, connectivity, and API-key checks (fast)
#   ./verify-setup.sh --install  # also create each lab's venv and pip install its requirements
#   ./verify-setup.sh --live     # also make ONE tiny live Claude call to confirm the key works
#
# Exit code 0 = ready, non-zero = one or more checks FAILED.
# Safe to re-run; makes no changes unless --install is given.

set -u

INSTALL=0; LIVE=0
for a in "$@"; do
  case "$a" in
    --install) INSTALL=1 ;;
    --live) LIVE=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $a"; exit 2 ;;
  esac
done

if [ -t 1 ]; then G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; B=$'\e[1m'; N=$'\e[0m'; else G=; R=; Y=; B=; N=; fi
PASS=0; FAIL=0; WARN=0
ok()   { printf "  ${G}PASS${N}  %s\n" "$1"; PASS=$((PASS+1)); }
bad()  { printf "  ${R}FAIL${N}  %s\n" "$1"; FAIL=$((FAIL+1)); }
warn() { printf "  ${Y}WARN${N}  %s\n" "$1"; WARN=$((WARN+1)); }
head() { printf "\n${B}%s${N}\n" "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../labs
LABS_DIR="$SCRIPT_DIR"

printf "${B}Building AI Applications — VM readiness check${N}\n"
printf "host: %s   user: %s\n" "$(hostname)" "$(id -un)"

# --- 1. OS & resources ------------------------------------------------------
head "1. Operating system & resources"
if [ "$(uname -s)" = "Linux" ]; then ok "OS is Linux ($(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-unknown}"))"
else warn "OS is $(uname -s) — course targets Ubuntu/Linux"; fi
mem_gb=$(awk '/MemTotal/ {printf "%.1f", $2/1024/1024}' /proc/meminfo 2>/dev/null)
[ -n "$mem_gb" ] && { awk "BEGIN{exit !($mem_gb+0 >= 7.0)}" && ok "RAM ${mem_gb} GB (8 GB is plenty; no Docker)" \
  || warn "RAM ${mem_gb} GB — 8 GB recommended"; }
ok "No Docker required for these labs"

# --- 2. Python toolchain ----------------------------------------------------
head "2. Python toolchain"
if have python3; then
  pv=$(python3 -c 'import sys;print("%d.%d"%sys.version_info[:2])' 2>/dev/null)
  python3 -c 'import sys;exit(0 if sys.version_info[:2]>=(3,10) else 1)' 2>/dev/null \
    && ok "python3 $pv (>= 3.10)" || bad "python3 $pv — need 3.10+"
else bad "python3 not installed — sudo apt install -y python3 python3-venv python3-pip"; fi
have pip3 || python3 -m pip --version >/dev/null 2>&1 && ok "pip available" || bad "pip missing — sudo apt install -y python3-pip"
python3 -m venv --help >/dev/null 2>&1 && ok "venv module available" || bad "venv missing — sudo apt install -y python3-venv"

# --- 3. Outbound connectivity ----------------------------------------------
head "3. Outbound connectivity (HTTPS)"
_reach_py() { # url -> exit 0 if the host answered (any HTTP status counts)
  python3 - "$1" <<'PY' 2>/dev/null
import sys, ssl, urllib.request, urllib.error
try:
    urllib.request.urlopen(urllib.request.Request(sys.argv[1]), timeout=12,
                           context=ssl.create_default_context()); sys.exit(0)
except urllib.error.HTTPError:
    sys.exit(0)   # got an HTTP response => host reached
except Exception:
    sys.exit(1)
PY
}
check_host() { # name url  — prefer curl, fall back to python3 (curl is optional on the VM)
  if have curl; then
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 12 "$2" 2>/dev/null)
    [ "$code" != "000" ] && ok "reach $1 (HTTP $code)" || bad "cannot reach $1 ($2)"
  elif have python3; then
    _reach_py "$2" && ok "reach $1 (python)" || bad "cannot reach $1 ($2)"
  elif have wget; then
    wget -q --spider --timeout=12 --tries=1 "$2" 2>/dev/null && ok "reach $1 (wget)" || warn "reach $1 inconclusive (wget)"
  else warn "no curl/python3/wget available to test $1"; fi
}
check_host "PyPI"          "https://pypi.org/simple/"
check_host "Anthropic API" "https://api.anthropic.com/v1/models"
check_host "OpenAI API"    "https://api.openai.com/v1/models"
check_host "Cohere API"    "https://api.cohere.com/v1/models"
check_host "Hugging Face"  "https://huggingface.co"

# --- 4. API keys ------------------------------------------------------------
head "4. API keys (instructor-provided; checks env and any labs/*/.env)"
# aggregate keys visible either in the environment or in a lab .env file
env_or_dotenv() { # KEY
  [ -n "${!1:-}" ] && { echo set; return; }
  grep -rhoE "^\s*$1\s*=\s*\S+" "$LABS_DIR"/*/.env 2>/dev/null | grep -qvE "=\s*(sk-ant-xxx|YOUR|xxxx|\s*$)" && echo dotenv || echo unset
}
for spec in "ANTHROPIC_API_KEY:required:all labs" \
            "OPENAI_API_KEY:optional:RAG labs 04/05 embeddings" \
            "COHERE_API_KEY:optional:lab 03" \
            "TAVILY_API_KEY:optional:lab 07"; do
  key="${spec%%:*}"; rest="${spec#*:}"; req="${rest%%:*}"; note="${rest#*:}"
  state=$(env_or_dotenv "$key")
  if [ "$state" != "unset" ]; then ok "$key present ($state) — $note"
  elif [ "$req" = required ]; then warn "$key not set — required at class time ($note)"
  else warn "$key not set — needed only for $note"; fi
done
if have aws && aws sts get-caller-identity >/dev/null 2>&1; then ok "AWS credentials valid (Day-4 Bedrock labs)"
else warn "AWS credentials not configured — needed only for Day-4 labs 09/10 (Bedrock)"; fi

# --- 5. Per-lab install (only with --install) ------------------------------
if [ "$INSTALL" = 1 ]; then
  head "5. Per-lab environments (--install)"
  for lab in "$LABS_DIR"/*/; do
    req="$lab/requirements.txt"; [ -f "$req" ] || continue
    name=$(basename "$lab")
    printf "  installing %s ..." "$name"
    ( cd "$lab" && python3 -m venv myenv >/dev/null 2>&1 \
        && ./myenv/bin/pip install --upgrade pip >/dev/null 2>&1 \
        && ./myenv/bin/pip install -r requirements.txt >/tmp/pip-$name.log 2>&1 )
    if [ $? -eq 0 ]; then printf "\r"; ok "$name — requirements installed"
    else printf "\r"; bad "$name — pip install failed (see /tmp/pip-$name.log)"; fi
  done
else
  head "5. Per-lab environments"
  warn "skipped — run with --install to build each lab's venv and install requirements"
fi

# --- 6. Live model call (only with --live) ---------------------------------
if [ "$LIVE" = 1 ]; then
  head "6. Live model call (--live)"
  # prefer a lab venv that has anthropic; else system python
  PY=python3
  for cand in "$LABS_DIR"/01-Prompt-Engineering/myenv/bin/python "$LABS_DIR"/*/myenv/bin/python; do
    [ -x "$cand" ] && "$cand" -c 'import anthropic' 2>/dev/null && { PY="$cand"; break; }
  done
  if "$PY" -c 'import anthropic' 2>/dev/null; then
    out=$("$PY" - <<'PYEOF' 2>/tmp/live.err
import os, sys
try:
    from dotenv import load_dotenv, find_dotenv; load_dotenv(find_dotenv())
except Exception:
    pass
import anthropic
try:
    m = anthropic.Anthropic().messages.create(
        model=os.getenv("LLM_MODEL", "claude-haiku-4-5"),
        max_tokens=5,
        messages=[{"role": "user", "content": "Say OK"}],
    )
    print("OK:" + m.content[0].text.strip())
except Exception as e:
    print("ERR:" + type(e).__name__ + ":" + str(e)[:120]); sys.exit(1)
PYEOF
)
    case "$out" in
      OK:*) ok "live Claude call succeeded ($PY)";;
      *)    bad "live call failed — ${out:-see /tmp/live.err}";;
    esac
  else warn "anthropic not importable — run --install first, then --live"; fi
fi

# --- summary ----------------------------------------------------------------
head "Summary"
printf "  ${G}%d passed${N}, ${Y}%d warnings${N}, ${R}%d failed${N}\n" "$PASS" "$WARN" "$FAIL"
if [ "$FAIL" -eq 0 ]; then
  printf "  ${G}${B}VM looks ready for the Building AI Applications labs.${N}\n"; exit 0
else
  printf "  ${R}${B}Not ready — resolve the FAIL items above (see labs/SETUP.md).${N}\n"; exit 1
fi
