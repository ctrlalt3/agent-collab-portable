#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK_FILE="$ROOT/shared/task.md"
mkdir -p "$ROOT/shared"
if [ -n "$1" ]; then
  printf "# Task\n\n%s\n" "$*" > "$TASK_FILE"
  echo "Task set: $*"
else
  ${EDITOR:-nano} "$TASK_FILE"
fi
