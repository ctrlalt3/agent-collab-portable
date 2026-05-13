#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHARED="$ROOT/shared"
TASK_FILE="$SHARED/task.md"
SETTINGS="$(dirname "${BASH_SOURCE[0]}")/.claude/settings.json"

# Auto-select model based on task complexity
TASK_TEXT=$(cat "$TASK_FILE" 2>/dev/null || echo "")
WORD_COUNT=$(echo "$TASK_TEXT" | wc -w | tr -d ' ')
HARD_KEYWORDS="architect|migrat|refactor|rewrite|complex|entire|multiple|system|parallel|concurrent"

if [ "$WORD_COUNT" -ge 80 ] || echo "$TASK_TEXT" | grep -qiE "$HARD_KEYWORDS"; then
  MODEL="claude-opus-4-7"
  LABEL="OPUS"
else
  MODEL="claude-sonnet-4-6"
  LABEL="SONNET"
fi

echo "Starting Claude $LABEL ($MODEL)..."
# Write model to settings.json
python3 -c "
import json
with open('$SETTINGS') as f:
    s = json.load(f)
s['model'] = '$MODEL'
with open('$SETTINGS', 'w') as f:
    json.dump(s, f, indent=2)
"

cd "$(dirname "${BASH_SOURCE[0]}")"
exec claude
