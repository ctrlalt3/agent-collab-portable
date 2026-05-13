#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED="$ROOT/shared"
USAGE_ALL="$HOME/.agent-collab/usage-all.jsonl"
# Accumulate usage before clearing
mkdir -p "$HOME/.agent-collab"
if [ -f "$SHARED/usage.jsonl" ]; then
  cat "$SHARED/usage.jsonl" >> "$USAGE_ALL"
fi
# Count accumulated tokens and print
if [ -f "$USAGE_ALL" ]; then
  TOTAL=$(python3 -c "
import sys, json
total = 0
for line in open('$USAGE_ALL'):
    try:
        d = json.loads(line)
        p = d.get('part', {})
        t = p.get('tokens', {})
        total += t.get('total', 0)
    except: pass
print(f'{total:,}')
" 2>/dev/null || echo "0")
  echo "OpenCode tokens saved all sessions: $TOTAL  (saved to $USAGE_ALL)"
fi
# Clear run artifacts
rm -f "$SHARED/plan.md" "$SHARED/plan-ready.flag" "$SHARED/code-done.flag" \
      "$SHARED/error.flag" "$SHARED/retest.flag" "$SHARED/run.log" "$SHARED/usage.jsonl"
rm -f "$SHARED/channel/context-ready.flag" "$SHARED/channel/test-ready.flag"
> "$SHARED/channel/planner_inbox.md"
> "$SHARED/channel/opencode_inbox.md"
rm -rf "$SHARED/output/"*
echo "Workspace reset. task.md and channel history preserved."
echo ""
echo "Current task:"
cat "$SHARED/task.md" 2>/dev/null || echo "(no task set)"
