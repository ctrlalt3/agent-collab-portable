#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED="$ROOT/shared"
DOCS="$ROOT/docs"
STATE_FILE="$DOCS/.doc-state.json"
FLAG="/tmp/doc-updater-done.flag"

# Detect what changed (git or mtime-based)
# Launch OpenCode to update CHANGELOG.md, ARCHITECTURE.md, per-script docs
# Save state to $STATE_FILE (with relative paths only)
# All paths derived from ROOT - no hardcoded paths

OC_MODEL=$(cat "$SHARED/opencode-model.txt" 2>/dev/null || echo "deepseek/deepseek-chat-v3-0324")

rm -f "$FLAG"

# Detect changed files
if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  CHANGED=$(git -C "$ROOT" diff --name-only HEAD~1 HEAD 2>/dev/null | head -20)
else
  # Fallback: files changed in last 24h
  CHANGED=$(find "$ROOT" -name "*.sh" -newer "$STATE_FILE" 2>/dev/null | sed "s|$ROOT/||" | head -20)
fi

[ -z "$CHANGED" ] && echo "No changes detected. Docs up to date." && exit 0

echo "Updating docs for changed files: $CHANGED"

opencode run "Update documentation in $DOCS/ for these changed files: $CHANGED. 
Update CHANGELOG.md (add entry), ARCHITECTURE.md if structure changed.
For each script, update or create docs/scripts/<name>.md.
All output must go to $DOCS/ directory.
When done: touch $FLAG" \
  --model "$OC_MODEL" \
  --dangerously-skip-permissions

# Wait for flag
for i in $(seq 1 60); do
  [ -f "$FLAG" ] && break
  sleep 2
done

[ -f "$FLAG" ] && echo "Docs updated." || echo "Doc updater timed out."

# Save state
python3 -c "
import json, os, time
state = {'last_run': '$(date -u +%Y-%m-%dT%H:%M:%SZ)', 'files': []}
with open('$STATE_FILE', 'w') as f:
    json.dump(state, f, indent=2)
"
