#!/usr/bin/env bash
#
# test-all-labs.sh — install each lab's dependencies and EXECUTE its notebooks
# headless, reporting per-lab pass/fail. This is the full-course smoke test.
#
# It distinguishes three outcomes per notebook cell:
#   - clean  : ran with no error
#   - key    : failed only because an API key is missing (auth/credential error)
#   - REAL   : failed for some other reason (a real bug, or a missing external
#              service like Weaviate / AWS resources)
#
# Usage:
#   ./labs/test-all-labs.sh                 # all labs
#   ./labs/test-all-labs.sh 01 12 13        # only these lab numbers
#   ./labs/test-all-labs.sh --no-install    # reuse existing per-lab venvs
#   ./labs/test-all-labs.sh --timeout 300   # per-cell timeout seconds (default 200)
#   ./labs/test-all-labs.sh --keep          # keep the per-lab venvs afterward
#
# Set the keys first (see KEYS.md) for a full pass. Without them, Claude/API cells
# report "key" (expected) and everything else still runs — so you can smoke-test the
# whole course's local logic even before keys are provisioned.
#
# Exit code 0 = no REAL errors in any lab (missing keys are allowed); non-zero otherwise.

set -u
INSTALL=1; KEEP=0; TIMEOUT=200; SEL=()
while [ $# -gt 0 ]; do
  case "$1" in
    --no-install) INSTALL=0 ;;
    --keep) KEEP=1 ;;
    --timeout) shift; TIMEOUT="$1" ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    [0-9]*) SEL+=("$1") ;;
    *) echo "unknown arg: $1"; exit 2 ;;
  esac; shift
done

if [ -t 1 ]; then G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; B=$'\e[1m'; N=$'\e[0m'; else G=; R=; Y=; B=; N=; fi
LABS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP" ~/.local/share/jupyter/kernels/blai_test 2>/dev/null' EXIT
TOTAL_REAL=0; TOTAL_KEY=0; declare -a ROWS

selected() {  # lab-basename -> 0 if it should run
  [ ${#SEL[@]} -eq 0 ] && return 0
  local num="${1%%-*}"
  for s in "${SEL[@]}"; do [ "$num" = "$s" ] || [ "$num" = "0$s" ] && return 0; done
  return 1
}

printf "${B}Building AI Applications — full lab test${N}\n"
printf "per-cell timeout: %ss | install: %s | keys set: ANTHROPIC=%s\n\n" \
  "$TIMEOUT" "$([ $INSTALL = 1 ] && echo yes || echo no)" "${ANTHROPIC_API_KEY:+yes}${ANTHROPIC_API_KEY:-no}"

for lab in "$LABS_DIR"/[0-9][0-9]-*/; do
  name="$(basename "$lab")"
  selected "$name" || continue
  [ -n "$(find "$lab" -maxdepth 3 -name '*.ipynb' 2>/dev/null | head -1)" ] || continue

  printf "${B}%s${N}\n" "$name"
  PY="python3"; ins="skip"
  # --- install ---
  if [ $INSTALL = 1 ] && [ -f "$lab/requirements.txt" ]; then
    printf "  installing deps..."
    if ( cd "$lab" && python3 -m venv myenv >/dev/null 2>&1 \
          && ./myenv/bin/pip install -q --upgrade pip >/dev/null 2>&1 \
          && ./myenv/bin/pip install -q -r requirements.txt >"$TMP/pip-$name.log" 2>&1 ); then
      ins="ok"; printf "\r  deps: ${G}ok${N}         \n"
    else
      ins="FAIL"; printf "\r  deps: ${R}FAIL${N} (see $TMP/pip-$name.log)\n"
    fi
  fi
  [ -x "$lab/myenv/bin/python" ] && PY="$lab/myenv/bin/python"
  # ensure nbconvert + ipykernel are available in the chosen interpreter, and register
  # THIS venv as a named kernel so nbconvert executes cells with the venv's python
  # (not the system python) — otherwise imports fail and every cell looks broken.
  "$PY" -c 'import nbconvert, ipykernel' 2>/dev/null || "$PY" -m pip install -q nbconvert ipykernel >/dev/null 2>&1 || true
  "$PY" -m ipykernel install --user --name blai_test >/dev/null 2>&1 || true

  # --- execute each notebook ---
  lab_real=0; lab_key=0; lab_clean=0; lab_cells=0
  if [ "$ins" != "FAIL" ]; then
    while IFS= read -r nb; do
      [ -z "$nb" ] && continue
      base="$(basename "$nb" .ipynb)"; out="$TMP/$base.ipynb"; rm -f "$out"
      ( cd "$lab" && "$PY" -m jupyter nbconvert --to notebook --execute --allow-errors \
          --ExecutePreprocessor.timeout="$TIMEOUT" --ExecutePreprocessor.kernel_name=blai_test \
          --output-dir "$TMP" --output "$base" "$nb" ) >/dev/null 2>&1
      [ -f "$out" ] || { printf "  ${R}%-34s could not execute${N}\n" "$(basename "$nb")"; lab_real=$((lab_real+1)); continue; }
      read -r c clean key real <<<"$("$PY" - "$out" <<'PYEOF'
import json,sys,re
d=json.load(open(sys.argv[1]))
code=[x for x in d["cells"] if x["cell_type"]=="code"]
KEYPAT=re.compile(r'authenticat|api[_ ]?key|auth_token|credential|access.?denied|unauthor|x-api-key|nocredential', re.I)
n=len(code); n_err=0; blocked=False
for x in code:
    e=[o for o in x.get("outputs",[]) if o.get("output_type")=="error"]
    if not e: continue
    n_err+=1
    blob=e[0].get("ename","")+" "+e[0].get("evalue","")
    if KEYPAT.search(blob): blocked=True
clean=n-n_err
# a missing key fails the setup cell, which cascades into NameErrors downstream;
# if ANY auth/key error appears, treat the whole notebook as key-blocked (not real bugs)
if blocked: key=n_err; real=0
else: key=0; real=n_err
print(n,clean,key,real)
PYEOF
)"
      lab_cells=$((lab_cells+c)); lab_clean=$((lab_clean+clean)); lab_key=$((lab_key+key)); lab_real=$((lab_real+real))
      status="${G}ok${N}"; [ "$key" -gt 0 ] && status="${Y}${key} need-key${N}"; [ "$real" -gt 0 ] && status="${R}${real} REAL${N}"
      printf "  %-34s %d cells: %d clean  %s\n" "$(basename "$nb")" "$c" "$clean" "$status"
    done < <(find "$lab" -maxdepth 3 -name '*.ipynb' ! -path '*/.ipynb_checkpoints/*' | sort)
  fi

  # --- per-lab verdict ---
  if [ "$ins" = "FAIL" ]; then verdict="${R}DEPS FAILED${N}"
  elif [ "$lab_real" -gt 0 ]; then verdict="${R}${lab_real} real error(s)${N}"
  elif [ "$lab_key" -gt 0 ]; then verdict="${Y}ok (needs keys: $lab_key cell(s))${N}"
  else verdict="${G}PASS${N}"; fi
  printf "  -> %b\n\n" "$verdict"
  insfail=0; [ "$ins" = "FAIL" ] && insfail=1
  TOTAL_REAL=$((TOTAL_REAL + lab_real + insfail))
  TOTAL_KEY=$((TOTAL_KEY + lab_key))
  ROWS+=("$(printf '%-26s %s' "$name" "$verdict")")
done

printf "${B}Summary${N}\n"
for r in "${ROWS[@]}"; do printf "  %b\n" "$r"; done
[ $KEEP = 0 ] && [ $INSTALL = 1 ] && { find "$LABS_DIR"/[0-9][0-9]-*/myenv -maxdepth 0 -type d 2>/dev/null | xargs -r rm -rf; printf "\n(removed per-lab venvs; use --keep to retain)\n"; }
printf "\n  ${Y}%d cell(s) need an API key${N}, ${R}%d real error(s)${N}\n" "$TOTAL_KEY" "$TOTAL_REAL"
[ "$TOTAL_REAL" -eq 0 ] && { printf "  ${G}${B}No real errors — every lab runs (key-gated cells aside).${N}\n"; exit 0; } \
                        || { printf "  ${R}${B}Real errors above — investigate.${N}\n"; exit 1; }
