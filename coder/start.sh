#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHARED="$ROOT/shared"
CHANNEL="$SHARED/channel"
DOCS="$ROOT/docs"

OC_MODEL=$(cat "$SHARED/opencode-model.txt" 2>/dev/null || echo "opencode-go/deepseek-v4-flash")

echo "Waiting for plan-ready.flag..."
while [ ! -f "$SHARED/plan-ready.flag" ]; do sleep 2; done
echo "Plan ready. Starting OpenCode coder..."

# Write AGENTS.md to output
mkdir -p "$SHARED/output"
cat > "$SHARED/output/AGENTS.md" << 'EOF'
# OpenCode Coder Agent

You are the CODER in a two-agent pipeline.
- Read plan.md carefully and implement every file exactly as specified
- Write all files to the paths specified in the plan
- When complete, run: touch <SHARED>/code-done.flag
- If you encounter a blocking error, write details to <SHARED>/error.flag
EOF
sed -i.bak "s|<SHARED>|$SHARED|g" "$SHARED/output/AGENTS.md" && rm -f "$SHARED/output/AGENTS.md.bak"

opencode run \
  --model "$OC_MODEL" \
  --dir "$SHARED/output" \
  --file "$SHARED/plan.md" \
  --dangerously-skip-permissions \
  2>&1 | tee -a "$SHARED/usage.jsonl"

touch "$SHARED/code-done.flag"
echo "Coder done. code-done.flag created."
