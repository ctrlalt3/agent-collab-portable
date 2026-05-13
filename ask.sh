#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANNEL="$ROOT/shared/channel"
TIMESTAMP=$(date '+%H:%M:%S')

usage() {
  echo "Usage: $0 [-p|-c|-b] \"message\""
  echo "  -p  to planner inbox only (default)"
  echo "  -c  to coder/opencode inbox only"
  echo "  -b  to both inboxes"
  exit 1
}

TARGET="planner"
while getopts "pcb" opt; do
  case $opt in
    p) TARGET="planner" ;;
    c) TARGET="coder" ;;
    b) TARGET="both" ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

MSG="$*"
[ -z "$MSG" ] && usage

echo "[$TIMESTAMP] USER -> $MSG" >> "$CHANNEL/chat.log"

if [ "$TARGET" = "planner" ] || [ "$TARGET" = "both" ]; then
  echo "$MSG" >> "$CHANNEL/planner_inbox.md"
fi
if [ "$TARGET" = "coder" ] || [ "$TARGET" = "both" ]; then
  echo "$MSG" >> "$CHANNEL/opencode_inbox.md"
fi
echo "Message sent to $TARGET"
