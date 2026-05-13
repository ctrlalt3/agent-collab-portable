#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED="$ROOT/shared"
CHANNEL="$SHARED/channel"

echo "=== agent-collab status ==="
echo ""
echo "Flags:"
for flag in plan-ready code-done error retest; do
  if [ -f "$SHARED/$flag.flag" ]; then
    echo "  + $flag.flag"
  else
    echo "  . $flag.flag (absent)"
  fi
done
for flag in context-ready test-ready; do
  if [ -f "$CHANNEL/$flag.flag" ]; then
    echo "  + channel/$flag.flag"
  else
    echo "  . channel/$flag.flag (absent)"
  fi
done
echo ""
echo "Task preview:"
head -3 "$SHARED/task.md" 2>/dev/null || echo "  (no task)"
echo ""
echo "Run log (last 5):"
tail -5 "$SHARED/run.log" 2>/dev/null || echo "  (no log)"
echo ""
echo "Channel inboxes:"
echo "  planner_inbox: $(wc -l < "$CHANNEL/planner_inbox.md" 2>/dev/null || echo 0) lines"
echo "  opencode_inbox: $(wc -l < "$CHANNEL/opencode_inbox.md" 2>/dev/null || echo 0) lines"
